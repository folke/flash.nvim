---@type Flash.Config
local M = {}

---@class Flash.Config
---@field mode? string
---@field ns? string
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
    -- save location in the jumplist
    jumplist = true,
    pos = "start", -- "start" | "end" | "range"
  },
  search = {
    -- search/jump in all windows
    multi_window = true,
    -- when more than `max_matches` are found in a window,
    -- labels will not be shown. Only results.
    max_matches = 500,
    -- search direction
    -- NOTE: will be overriden in a regular search with `/` or `?`
    forward = true,
    -- when `false`, find only matches in the given direction
    wrap = true,
    ---@type "exact" | "search" | "fuzzy"
    -- Each mode will take ignorecase and smartcase into account.
    -- * exact: exact match
    -- * search: regular search
    -- * fuzzy: fuzzy search
    -- NOTE: Mode is always set to `search` when triggering flash
    -- in a regular search.
    mode = "exact",
    -- behave like `incsearch`. Enabled for regular search,
    -- when `incsearch` is enabled.
    incremental = false,
    filetype_exclude = { "notify", "noice" },
  },
  highlight = {
    label = {
      -- add a label for the first match in the current window.
      -- you can always jump to the first match with `<CR>`
      current = false,
      -- show the label after the match
      after = true, ---@type boolean|number[]
      -- show the label before the match
      before = false, ---@type boolean|number[]
      -- position of the label extmark
      style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
      -- when `true`, labels will be re-used when possible for the same position
      stable = true,
    },
    -- show a backdrop with hl FlashBackdrop
    backdrop = true,
    -- Will apply the same highlights as a regular search.
    -- This is useful to prevent flickring during search.
    -- Especially with plugins like noice.nvim.
    matches = true,
    -- extmark priority
    priority = 5000,
    groups = {
      match = "FlashMatch",
      current = "FlashCurrent",
      backdrop = "FlashBackdrop",
      label = "FlashLabel",
    },
  },
  -- You can override the default options for a specific mode.
  -- Use it with `require("flash").jump({mode = "forward"})`
  ---@type table<string, Flash.Config>
  modes = {
    search = {
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
  require("flash.repeat").setup()
  require("flash.plugins.search").setup()
  require("flash.plugins.charsearch").setup()
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
