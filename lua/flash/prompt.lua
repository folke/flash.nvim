local Config = require("flash.config")

---@class Flash.Prompt
---@field win number
---@field buf number
---@field prompt string
local M = {}

local ns = vim.api.nvim_create_namespace("flash_prompt")

function M.visible()
  return M.win and vim.api.nvim_win_is_valid(M.win) and M.buf and vim.api.nvim_buf_is_valid(M.buf)
end

function M.show()
  if M.visible() then
    return
  end
  require("flash.highlight")

  M.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[M.buf].buftype = "nofile"
  vim.bo[M.buf].bufhidden = "wipe"
  vim.bo[M.buf].filetype = "flash_prompt"

  local config = vim.deepcopy(Config.prompt.win_config)

  if config.width <= 1 then
    config.width = config.width * vim.go.columns
  end

  if config.row < 0 then
    config.row = vim.go.lines + config.row
  end

  if config.col < 0 then
    config.col = vim.go.columns + config.col
  end

  config = vim.tbl_extend("force", config, {
    style = "minimal",
    focusable = false,
    noautocmd = true,
  })

  M.win = vim.api.nvim_open_win(M.buf, false, config)
  vim.wo[M.win].winhighlight = "Normal:FlashPrompt"
end

function M.hide()
  M.prompt = ""

  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_delete(M.buf, { force = true })
    M.buf = nil
  end
end

---@param pattern string
---@param show boolean
function M.set(pattern, show)
  local text = vim.deepcopy(Config.prompt.prefix)
  text[#text + 1] = { pattern }

  local str = ""
  for _, item in ipairs(text) do
    str = str .. item[1]
  end

  M.prompt = str

  if not show then
    return
  end

  M.show()

  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, { str })
  vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
  local col = 0
  for _, item in ipairs(text) do
    local width = vim.fn.strlen(item[1])
    if item[2] then
      vim.api.nvim_buf_set_extmark(M.buf, ns, 0, col, {
        hl_group = item[2],
        end_col = col + width,
      })
    end
    col = col + width
  end
end

return M
