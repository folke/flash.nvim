---@type Flash.Config
local M = {}

---@class Flash.Config
local defaults = {
  -- labels = "abcdefghijklmnopqrstuvwxyz",
  labels = "asdfghjklqwertyuiopzxcvbnm",
  jump = {
    -- add pattern to search history
    history = false,
    -- add pattern to search register
    -- useful to use with `n` and `N` to repeat the jump
    register = true,
    -- clear highlight after jump
    nohlsearch = true,
    -- jump when only one match is found
    auto_jump = false,
  },
  search = {
    -- search/jump in all windows
    multi_window = true,
    -- when more than `max_matches` are found in a window,
    -- the search will be aborted for that window.
    max_matches = 2000,
    -- when this pattern matches the search pattern,
    -- flash will be aborted. This is needed to be able
    -- to search with regular expressions
    abort_pattern = "[^a-zA-Z0-9_.()]",
    -- limit matches in a certain direction
    direction = nil, ---@type "forward" | "backward" | nil
  },
  ui = {
    backdrop = true,
    priority = 500,
  },
}

---@type Flash.Config
local options

---@param opts? Flash.Config
function M.setup(opts)
  options = M.get(opts)
  require("flash.highlight").setup()
  require("flash.state").setup()
end

---@param opts? Flash.Config
function M.get(opts)
  return vim.tbl_deep_extend("force", {}, defaults, options or {}, opts or {})
end

return setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    return options[key]
  end,
})
