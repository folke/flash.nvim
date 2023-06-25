local Repeat = require("flash.repeat")

---@class Flash.Commands
local M = {}

---@param opts? Flash.State.Config
function M.jump(opts)
  local state = Repeat.get_state("jump", opts)
  state:loop()
  return state
end

---@param opts? Flash.State.Config
function M.treesitter(opts)
  return require("flash.plugins.treesitter").jump(opts)
end

---@param opts? Flash.State.Config
function M.remote(opts)
  return require("flash.plugins.remote").jump(opts)
end

return M
