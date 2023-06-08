---@type Flash.Commands
local M = {}

function M.setup()
  require("flash.config").setup()
end

return setmetatable(M, {
  __index = function(_, k)
    return require("flash.commands")[k]
  end,
})
