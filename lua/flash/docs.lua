local Docs = require("lazy.docs")

local M = {}

function M.update()
  local config = Docs.extract("lua/flash/config.lua", "\nlocal defaults = ({.-\n})")
  config = config:gsub("%s*debug = false.\n", "\n")
  Docs.save({
    config = config,
  })
end
M.update()

return M
