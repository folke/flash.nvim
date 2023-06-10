local M = {}

---@class Flash.Match
---@field win window
---@field from number[]
---@field to number[]
---@field next? string next character
---@field label? string
---@field visible? boolean
---@field first boolean

---@param win window
---@param state Flash.State
---@return Flash.Match[]
function M.search(win, state)
  return vim.api.nvim_win_call(win, function()
    return M._search(win, state)
  end)
end

---@param state Flash.State
---@return Flash.Match[]
function M._search(win, state)
  local Config = require("flash.config")

  local info = vim.fn.getwininfo(win)[1]
  local view = vim.fn.winsaveview()
  local buf = vim.api.nvim_win_get_buf(0)
  if win == state.win then
    vim.api.nvim_win_set_cursor(win, state.pos)
  end

  local flags = ""
  if not state.config.search.wrap then
    flags = flags .. "W"
  end
  if not state.config.search.forward then
    flags = flags .. "b"
  end

  local first ---@type number[]
  local last ---@type number[]

  local pattern = state.pattern

  if not state.config.search.regex then
    pattern = "\\V" .. pattern:gsub("\\", "\\\\")
  end

  ---@type Flash.Match[]
  local matches = {}
  while true do
    -- beginning of match
    local ok, ret = pcall(vim.fn.search, pattern, flags)
    if not ok or ret == 0 then
      break
    end
    local from = vim.api.nvim_win_get_cursor(0)

    -- search is back at the start
    if vim.deep_equal(first, from) or vim.deep_equal(from, last) then
      break
    end
    last = from

    if not first then
      first = from
      -- incsearch changes the cursor position,
      -- so update the view here
      if vim.api.nvim_get_current_win() == win and state.is_search() then
        info.topline = first[1] - info.height
        info.botline = first[1] + info.height
      end
    end

    -- end of match
    if vim.fn.search(pattern, "ce") == 0 then
      break
    end
    local to = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, from)

    local line = vim.api.nvim_buf_get_lines(buf, to[1] - 1, to[1], false)[1] or ""
    table.insert(matches, {
      win = win,
      from = from,
      to = to,
      next = line:sub(to[2] + 2, to[2] + 2),
      visible = from[1] >= info.topline and from[1] <= info.botline,
      first = vim.deep_equal(from, first),
    })
    if #matches > Config.search.max_matches then
      -- vim.notify("Too many matches", vim.log.levels.WARN, { title = "flash.nvim" })
      break
    end
  end
  vim.fn.winrestview(view)
  return matches
end

return M
