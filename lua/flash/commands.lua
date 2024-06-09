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
function M.treesitter_search(opts)
  return require("flash.plugins.treesitter").search(opts)
end

---@param opts? Flash.State.Config
function M.remote(opts)
  local Config = require("flash.config")
  opts = Config.get({ mode = "remote" }, opts)
  return M.jump(opts)
end

---@param enabled? boolean
function M.toggle(enabled)
  local Search = require("flash.plugins.search")
  return Search.toggle(enabled)
end

---@return string
function M.prompt()
  return require("flash.prompt").prompt or ""
end

return M
