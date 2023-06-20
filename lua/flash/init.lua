---@type Flash.Commands
local M = {}

---@param opts? Flash.Config
function M.setup(opts)
  require("flash.config").setup(opts)
end

return setmetatable(M, {
  __index = function(_, k)
    return require("flash.commands")[k]
  end,
})
