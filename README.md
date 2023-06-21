# ⚡flash.nvim

`flash.nvim` lets you navigate your code with search labels,
enhanced character motions, and Treesitter integration.

## ✨ Features

- 🔍 **Search Integration**: integrate flash.nvim with your regular
  search using / or ?. Labels appear next to the matches,
  allowing you to quickly jump to any location.
- ⚡ **Enhanced f,t,F,T motions**
- 🌳 **Treesitter Integration**: all parents of the Treesitter node
  under your cursor are highlighted with a label for quick selection
  of a specific Treesitter node.
- 🎯 **Jump Mode**: a standalone jumping mode similar to search
- 🔎 **Search Modes**: `exact`, `search` (regex), and `fuzzy` search modes
- 🪟 **Multi Window** jumping

## 📦 Installation

Install the plugin with your preferred package manager:

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  keys = {
    {
      "S",
      mode = { "o", "x" },
      function()
        require("flash").treesitter()
      end,
    },
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
    },
  },
}
```

## ⚙️ Configuration

**flash.nvim** is highly configurable. Please refer to the default settings below.

<details><summary>Default Settings</summary>

```lua
{
  -- labels = "abcdefghijklmnopqrstuvwxyz",
  labels = "asdfghjklqwertyuiopzxcvbnm",
  search = {
    -- search/jump in all windows
    multi_window = true,
    -- search direction
    forward = true,
    -- when `false`, find only matches in the given direction
    wrap = true,
    ---@type Flash.Pattern.Mode
    -- Each mode will take ignorecase and smartcase into account.
    -- * exact: exact match
    -- * search: regular search
    -- * fuzzy: fuzzy search
    -- * fun(str): custom function that returns a pattern
    --   For example, to only match at the beginning of a word:
    --   mode = function(str)
    --     return "\\<" .. str
    --   end,
    mode = "exact",
    -- behave like `incsearch`
    incremental = false,
    filetype_exclude = { "notify", "noice" },
  },
  jump = {
    -- save location in the jumplist
    jumplist = true,
    -- jump position
    pos = "start", ---@type "start" | "end" | "range"
    -- add pattern to search history
    history = false,
    -- add pattern to search register
    register = false,
    -- clear highlight after jump
    nohlsearch = false,
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
    },
    -- show a backdrop with hl FlashBackdrop
    backdrop = true,
    -- Highlight the search matches
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
    -- options used when flash is activated through
    -- a regular search with `/` or `?`
    search = {
      enabled = true, -- enable flash for search
      highlight = { backdrop = false },
      jump = { history = true, register = true, nohlsearch = true },
      search = {
        -- `forward` will be automatically set to the search direction
        -- `mode` is always set to `search`
        -- `incremental` is set to `true` when `incsearch` is enabled
      },
    },
    -- options used when flash is activated through
    -- `f`, `F`, `t`, `T`, `;` and `,` motions
    char = {
      enabled = true,
      search = { wrap = false },
      highlight = { backdrop = true },
      jump = { register = false },
    },
    -- options used for treesitter selections
    -- `require("flash").treesitter()`
    treesitter = {
      labels = "abcdefghijklmnopqrstuvwxyz",
      jump = { pos = "range" },
      highlight = {
        label = { before = true, after = true, style = "inline" },
        backdrop = false,
        matches = false,
      },
    },
  },
}
```

</details>

## 🚀 Usage

- `require("flash").jump(opts?)` opens **flash** with the given options
- `require("flash").treesitter(opts?)` opens **flash** in **Treesitter** mode

## Examples

<details><summary>Forward search only</summary>

```lua
require("flash").jump({
  search = { forward = true, wrap = false, multi_window = false },
})
```

</details>

<details><summary>Backward search only</summary>

```lua
require("flash").jump({
  search = { forward = false, wrap = false, multi_window = false },
})
```

</details>

## 📦 Alternatives

- [leap.nvim](https://github.com/ggandor/leap.nvim)
- [lightspeed.nvim](https://github.com/ggandor/lightspeed.nvim)
- [mini.jump](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump.md)
- [mini.jump2d](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-jump2d.md)
- [hop.nvim](https://github.com/phaazon/hop.nvim)
- [pounce.nvim](https://github.com/rlane/pounce.nvim)
- [sj.nvim](https://github.com/woosaaahh/sj.nvim)
- [nvim-treehopper](https://github.com/mfussenegger/nvim-treehopper)
- [flit.nvim](https://github.com/ggandor/flit.nvim)
