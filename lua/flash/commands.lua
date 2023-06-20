local Util = require("flash.util")
local Repeat = require("flash.repeat")

---@class Flash.Commands
local M = {}

---@param opts? Flash.State.Config
function M.jump(opts)
  local state = Repeat.get_state("jump", opts)

  while true do
    local c = Util.get_char()
    if c == nil then
      break
    -- jump to first
    elseif c == Util.CR then
      state:jump()
      break
    end

    -- break if we jumped
    if state:update({ pattern = state.pattern:extend(c) }) then
      break
    end

    -- exit if no results
    if #state.results == 0 and not state.pattern:empty() then
      break
    end
  end
  state:hide()
  return state
end

---@param opts? Flash.State.Config
function M.treesitter(opts)
  return require("flash.plugins.treesitter").jump(opts)
end

return M
