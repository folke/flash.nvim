# ⚡flash.nvim

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
