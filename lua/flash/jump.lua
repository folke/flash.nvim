local Hacks = require("flash.hacks")
local Pos = require("flash.search.pos")
local Util = require("flash.util")
local M = {}

---@param match Flash.Match
---@param state Flash.State
---@return Flash.Match?
function M.jump(match, state)
  local register = vim.v.register
  -- add to jump list
  if state.opts.jump.jumplist then
    vim.cmd("normal! m'")
  end

  local mode = vim.fn.mode(true)
  local is_op = mode:sub(1, 2) == "no"
  local is_visual = mode:sub(1, 1) == "v"

  if is_op and (state.opts.remote_op.motion or match.win ~= vim.api.nvim_get_current_win()) then
    -- use our special logic for remote operator pending mode
    return M.remote_op(match, state, register)
  end

  -- change window if needed
  if match.win ~= vim.api.nvim_get_current_win() then
    if is_visual then
      -- cancel visual mode in the current window,
      -- to avoid issues with the remote window
      vim.cmd("normal! v")
    end

    vim.api.nvim_set_current_win(match.win)

    if is_visual then
      -- enable visual mode in the remote window,
      -- from its current cursor position
      vim.cmd("normal! v")
    end
  end

  M._jump(match, state, { op = is_op })
end

function M.fix_selection()
  local selection = vim.go.selection
  vim.go.selection = "inclusive"
  vim.schedule(function()
    vim.go.selection = selection
  end)
end

-- Remote operator pending mode.Cancel the operator and
-- re-trigger the operator in the remote window.
---@param match Flash.Match
---@param state Flash.State
---@param register string
---@return Flash.Match?
function M.remote_op(match, state, register)
  Util.exit()
  -- schedule this so that the  active operator is properly cancelled
  vim.schedule(function()
    local motion = state.opts.remote_op.motion
    if motion == nil then
      motion = match.win ~= vim.api.nvim_get_current_win()
    end

    vim.api.nvim_set_current_win(match.win)

    -- use a new motion to select the text-object to act on,
    -- unless we're jumping to a range
    if motion then
      if vim.fn.mode() == "v" then
        vim.cmd("normal! v")
      end

      if state.opts.jump.pos == "range" then
        vim.api.nvim_win_set_cursor(match.win, match.pos)
        vim.cmd("normal! v")
        vim.api.nvim_win_set_cursor(match.win, match.end_pos)
      else
        vim.api.nvim_win_set_cursor(match.win, state.opts.jump.pos == "start" and match.pos or match.end_pos)
      end

    -- otherwise, use the remote window's cursor position
    else
      local from = vim.api.nvim_win_get_cursor(match.win)
      M._jump(match, state, { op = true })
      local to = vim.api.nvim_win_get_cursor(match.win)

      -- if a range was selected, use that instead
      if vim.fn.mode() == "v" then
        vim.cmd("normal! v") -- end the selection
        from = vim.api.nvim_buf_get_mark(0, "<")
        to = vim.api.nvim_buf_get_mark(0, ">")
      end

      -- vim.api.nvim_buf_set_mark(0, "[", from[1], from[2], {})
      -- vim.api.nvim_buf_set_mark(0, "]", to[1], to[2], {})

      -- select the range for the operator
      vim.api.nvim_win_set_cursor(0, from)
      vim.cmd("normal! v")
      vim.api.nvim_win_set_cursor(0, to)
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local opmap = vim.fn.maparg(vim.v.operator, "", false, true) --[[@as any]]
    if not vim.tbl_isempty(opmap) then
      vim.keymap.del("", vim.v.operator)
    end

    -- re-trigger the operator
    vim.api.nvim_input('"' .. register .. vim.v.operator)
    if state.opts.remote_op.restore then
      vim.schedule(function()
        if not vim.tbl_isempty(opmap) then
          vim.fn.mapset(opmap.mode, false, opmap)
        end
        M.restore_remote(state)
      end)
    end
  end)
end

-- Restore window views after the remote operation ends
---@param state Flash.State
function M.restore_remote(state)
  local restore = vim.schedule_wrap(function()
    state:restore()
  end)

  -- wait till getting user input clears
  if not Hacks.mappings_enabled() then
    return Util.on_done(function()
      return Hacks.mappings_enabled()
    end, function()
      M.restore_remote(state)
    end)

  -- wait till operator pending mode ends
  elseif vim.fn.mode(true):sub(1, 2) == "no" then
    return Util.on_done(function()
      return vim.fn.mode(true):sub(1, 2) ~= "no"
    end, function()
      M.restore_remote(state)
    end)

  -- restore after making edits
  elseif vim.fn.mode() == "i" and vim.v.operator == "c" then
    vim.api.nvim_create_autocmd("InsertLeave", {
      once = true,
      callback = restore,
    })
  else
    restore()
  end
end

-- Performs the actual jump in the current window,
-- taking operator-pending mode into account.
---@param match Flash.Match
---@param state Flash.State
---@param opts? {op:boolean}
---@return Flash.Match?
function M._jump(match, state, opts)
  opts = opts or {}
  M.fix_selection()
  M.open_folds(match)
  -- select range
  if state.opts.jump.pos == "range" then
    if vim.fn.mode() == "v" then
      vim.cmd("normal! v")
    end
    vim.api.nvim_win_set_cursor(match.win, match.pos)
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(match.win, match.end_pos)
  else
    local pos = state.opts.jump.pos == "start" and match.pos or match.end_pos

    if opts.op then
      -- fix inclusive/exclusive
      -- default is exclusive
      if state.opts.jump.inclusive ~= false then
        vim.cmd("normal! v")
      end
    end
    local current = Pos(match.win)
    local offset = state.opts.jump.offset

    if not offset and state.opts.jump.pos == "end" and pos < current then
      offset = 1
    end

    pos = Pos(require("flash.util").offset_pos(vim.api.nvim_win_get_buf(match.win), pos, { 0, offset or 0 }))
    pos[2] = math.max(0, pos[2])

    vim.api.nvim_win_set_cursor(match.win, pos)
  end
end

---@param match Flash.Match
function M.open_folds(match)
  local cursor = vim.api.nvim_win_get_cursor(match.win)
  local from = match.pos[1]
  local to = match.end_pos[1]
  local is_visual = vim.fn.mode(true):find("v")
  local opened = false
  for line = from, to do
    if vim.fn.foldclosed(line) ~= -1 then
      vim.api.nvim_win_set_cursor(match.win, { line, 0 })
      vim.cmd("normal! zO")
      opened = true
    end
  end
  if opened then
    vim.api.nvim_win_set_cursor(match.win, cursor)
    if is_visual then
      vim.cmd("normal! v")
    end
  end
end

---@param state Flash.State
function M.on_jump(state)
  -- fix or restore the search register
  local sf = vim.v.searchforward
  if state.opts.jump.register then
    vim.fn.setreg("/", state.pattern.search)
  end
  vim.v.searchforward = sf

  -- add the real search pattern to the history
  if state.opts.jump.history then
    vim.fn.histadd("search", state.pattern.search)
  end

  -- clear the highlight
  if state.opts.jump.nohlsearch then
    vim.cmd.nohlsearch()
  elseif state.opts.jump.register then
    -- this will show the search matches again
    vim.cmd("set hlsearch")
  end
end

return M
