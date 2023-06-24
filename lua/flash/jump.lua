local Pos = require("flash.search.pos")
local M = {}

---@param match Flash.Match
---@param state Flash.State
---@return Flash.Match?
function M.jump(match, state)
  -- add to jump list
  if state.opts.jump.jumplist then
    vim.cmd("normal! m'")
  end

  -- change window if needed
  if match.win ~= vim.api.nvim_get_current_win() then
    vim.api.nvim_set_current_win(match.win)
  end

  -- select range
  if state.opts.jump.pos == "range" then
    if vim.fn.mode() == "v" then
      vim.cmd("normal! v")
    end
    vim.api.nvim_win_set_cursor(match.win, match.pos)
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(match.win, match.end_pos)
  else
    local mode = vim.fn.mode(true)

    local pos = state.opts.jump.pos == "start" and match.pos or match.end_pos

    if mode:sub(1, 2) == "no" then
      -- fix inclusive/exclusive
      -- default is exclusive
      if state.opts.jump.inclusive ~= false then
        vim.cmd("normal! v")
      end

      local current = Pos(vim.api.nvim_win_get_cursor(match.win))
      local offset = state.opts.jump.offset

      if not offset and state.opts.jump.pos == "end" and pos < current then
        offset = 1
      end

      pos = pos + Pos({ 0, offset or 0 })
      ---@cast pos Pos
      pos[2] = math.max(0, pos[2])
    end

    vim.api.nvim_win_set_cursor(match.win, pos)
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
  end
end

return M
