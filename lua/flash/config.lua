---@type Flash.Config
local M = {}

---@class Flash.Config
---@field mode? string
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
    auto_jump = true,
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
    -- search direction
    -- NOTE: will be overriden in a regular search with `/` or `?`
    forward = true,
    -- when `false`, find only matches in the given direction
    wrap = true,
  },
  highlight = {
    -- add a label for the first match in the current window.
    -- you can always jump to the first match with `<CR>`
    label_first = false,
    -- show a backdrop with hl FlashBackdrop
    backdrop = true,
    -- Will apply the same highlights as a regular search.
    -- This is useful to prevent flickring during search.
    -- Especially with plugins like noice.nvim.
    matches = true,
    -- extmark priority
    priority = 5000,
  },
  -- You can override the default options for a specific mode.
  -- Use it with `require("flash").jump({mode = "forward"})`
  ---@type table<string, Flash.Config>
  modes = {
    search = {
      jump = { auto_jump = false },
      highlight = { backdrop = false },
    },
    forward = {
      search = { forward = true, wrap = false, multi_window = false },
    },
    backward = {
      search = { forward = false, wrap = false, multi_window = false },
    },
  },
}

---@type Flash.Config
local options

---@param opts? Flash.Config
function M.setup(opts)
  opts = opts or {}
  opts.mode = nil
  options = M.get(opts)
  require("flash.highlight").setup()
  require("flash.state").setup()
end

---@param opts? Flash.Config
function M.get(opts)
  return vim.tbl_deep_extend(
    "force",
    {},
    defaults,
    options or {},
    opts and opts.mode and options.modes[opts.mode] or {},
    opts or {}
  )
end

return setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    return options[key]
  end,
})
