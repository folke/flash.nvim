local require = require("flash.require")

local Config = require("flash.config")
local Jump = require("flash.jump")
local State = require("flash.state")
local Util = require("flash.util")

local M = {}

---@type Flash.State?
M.state = nil
M.op = false
M.enabled = true

---@param enabled? boolean
function M.toggle(enabled)
  if enabled == nil then
    enabled = not M.enabled
  end

  if M.enabled == enabled then
    return M.enabled
  end

  M.enabled = enabled

  if State.is_search() then
    if M.enabled then
      M.start()
      M.update(false)
    elseif M.state then
      M.state:hide()
      M.state = nil
    end
    -- redraw to show the change
    vim.cmd("redraw")
    -- trigger incsearch to update the matches
    vim.api.nvim_feedkeys(" " .. Util.BS, "n", true)
  end
  return M.enabled
end

---@param check_jump? boolean
function M.update(check_jump)
  if not M.state then
    return
  end

  local pattern = vim.fn.getcmdline()

  -- when doing // or ??, get the pattern from the search register
  -- See :h search-commands
  if pattern:sub(1, 1) == vim.fn.getcmdtype() then
    pattern = vim.fn.getreg("/") .. pattern:sub(2)
  end
  M.state:update({ pattern = pattern, check_jump = check_jump })
end

function M.start()
  M.state = State.new({
    mode = "search",
    action = M.jump,
    search = {
      forward = vim.fn.getcmdtype() == "/",
      mode = "search",
      incremental = vim.go.incsearch,
    },
  })
  if M.op then
    M.state.opts.search.multi_window = false
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("flash", { clear = true })
  M.enabled = Config.modes.search.enabled or false

  local function wrap(fn)
    return function(...)
      if M.state then
        return fn(...)
      end
    end
  end

  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    callback = wrap(function()
      M.update()
    end),
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = wrap(function()
      M.state:hide()
      M.state = nil
    end),
  })
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
    callback = function()
      if State.is_search() and M.enabled then
        M.start()
        M.set_op(vim.fn.mode() == "v")
      end
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:c",
    group = group,
    callback = function()
      M.set_op(vim.v.event.old_mode:sub(1, 2) == "no" or vim.fn.mode() == "v")
    end,
  })
end

function M.set_op(op)
  M.op = op
  if M.op and M.state then
    M.state.opts.search.multi_window = false
  end
end

---@param self Flash.State
---@param match Flash.Match
function M.jump(match, self)
  local pos = match.pos
  local search_reg = vim.fn.getreg("/")

  -- For operator pending mode, set the search pattern to the
  -- first character on the match position
  if M.op then
    local pos_pattern = ("\\%%%dl\\%%%dc."):format(pos[1], pos[2] + 1)
    vim.fn.setcmdline(pos_pattern)
  end

  -- schedule a <cr> input to trigger the search
  vim.schedule(function()
    vim.api.nvim_input(M.op and "<cr>" or "<esc>")
  end)

  -- restore the real search pattern after the search
  -- and perform the jump when not in operator pending mode
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    once = true,
    callback = vim.schedule_wrap(function()
      -- delete the search pattern.
      -- The correct one will be added in `on_jump`
      vim.fn.histdel("search", -1)
      if M.op then
        -- restore original search pattern
        vim.fn.setreg("/", search_reg)
      else
        Jump.jump(match, self)
      end
      Jump.on_jump(self)
    end),
  })
end

return M
