-- Original code by @max397574
-- https://github.com/folke/flash.nvim/discussions/24

local Config = require("flash.config")

---@class Flash.Remote
---@field opfunc? string
---@field operator? string
---@field register? string
---@field win? window
---@field view? any
local M = {}

function M.op()
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, vim.api.nvim_buf_get_mark(0, "["))
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, vim.api.nvim_buf_get_mark(0, "]"))
  vim.go.operatorfunc = M.opfunc
  vim.api.nvim_input('"' .. M.register .. M.operator)

  if M.operator == "c" then
    vim.api.nvim_create_autocmd("InsertLeave", {
      once = true,
      callback = M.restore,
    })
  else
    vim.schedule(M.restore)
  end
end

function M.restore()
  vim.api.nvim_set_current_win(M.win)
  vim.fn.winrestview(M.view)
end

---@param opts? Flash.State.Config
function M.jump(opts)
  M.operator = vim.v.operator
  M.register = vim.v.register
  M.view = vim.fn.winsaveview()
  M.win = vim.api.nvim_get_current_win()
  M.opfunc = vim.go.operatorfunc

  opts = Config.get(opts, { mode = "remote" }, {
    action = function(match)
      vim.api.nvim_set_current_win(match.win)
      vim.api.nvim_win_set_cursor(match.win, match.pos)
      vim.go.operatorfunc = "v:lua.require'flash.plugins.remote'.op"
      vim.api.nvim_feedkeys("g@", "n", false)
    end,
  })

  vim.api.nvim_input("<esc>")
  vim.schedule(function()
    require("flash").jump(opts)
  end)
end

return M
