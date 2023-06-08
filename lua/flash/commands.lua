local State = require("flash.state")

---@class Flash.Commands

local M = {}

local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

---@param opts? Flash.Config
function M.jump(opts)
  local state = State.new({ config = opts })

  while true do
    local ok, n = pcall(vim.fn.getchar)
    if not ok then
      break
    end

    local c = (type(n) == "number" and vim.fn.nr2char(n) or n)
    -- cancel
    if c == t("<esc>") then
      break
    -- jump to first
    elseif c == t("<cr>") then
      state:jump(true)
      break
    end

    local pattern = state.pattern
    if c == t("<bs>") then
      pattern = state.pattern:sub(1, -2)
    else
      pattern = state.pattern .. c
    end

    -- break if we jumped
    if state:update(pattern) then
      break
    end

    -- exit if no results
    if #state.results == 0 then
      break
    end
  end
  state:clear()
end

return M
