local M = {}

local ns = vim.api.nvim_create_namespace("flash")
local check = assert(vim.loop.new_check())

---@class SearchResult
---@field row number 1-indexed
---@field col number 0-indexed
---@field next string next character
---@field label string
---@field pos number[] 1-0-indexed

---@type string[]
M.labels = {}

---@type table<string, SearchResult>
M.results = {}
M.cmdline = ""

function M.search(search)
  local view = vim.fn.winsaveview()
  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  local pos = vim.api.nvim_win_get_cursor(0)

  ---@type SearchResult[]
  local matches = {}
  while true do
    if vim.fn.search(search, "W") == 0 then
      break
    end
    local start = vim.api.nvim_win_get_cursor(0)
    vim.fn.search(search, "ceW")

    local new_pos = vim.api.nvim_win_get_cursor(0)
    if new_pos[1] == pos[1] and new_pos[2] == pos[2] then
      break
    end
    pos = new_pos

    local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1] or ""
    table.insert(matches, {
      row = pos[1],
      col = pos[2],
      pos = start,
      next = line:sub(pos[2] + 2, pos[2] + 2),
    })
  end
  vim.fn.winrestview(view)
  return matches
end

function M.nohlsearch()
  check:start(vim.schedule_wrap(function()
    if vim.o.hlsearch and vim.v.hlsearch == 0 then
      check:stop()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      end
    end
  end))
end

function M.press(key)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "nt", true)
end

function M.setup()
  local labels = "abcdefghijklmnopqrstuvwxyz"
  labels = labels .. labels:upper()
  for i = 1, #labels do
    M.labels[i] = labels:sub(i, i)
  end

  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = vim.api.nvim_create_augroup("flash", { clear = true }),
    callback = function()
      if vim.fn.getcmdtype() == "/" then
        M.run()
      end
    end,
  })
end

function M.run()
  local info = { type = vim.fn.getcmdtype(), line = vim.fn.getcmdline() }
  if info.line == "" then
    M.cmdline = ""
    M.nohlsearch()
  end
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  for char, match in pairs(M.results) do
    if info.line == M.cmdline .. char then
      local pos = match.pos
      if vim.v.operator ~= "" then
        local s = ("\\%%%dl\\%%%dc."):format(pos[1], pos[2] + 1)
        vim.fn.setcmdline(s)
        M.press("<CR>")
      else
        M.press("<esc>")
        -- vim.fn.setcmdline(M.cmdline)
        -- M.press("<CR>")
        vim.schedule(function()
          vim.api.nvim_win_set_cursor(0, pos)
        end)
      end
      return
    end
  end
  M.cmdline = info.line
  local matches = M.search(info.line)

  ---@type table<string, boolean>
  local next_chars = {}
  for _, match in ipairs(matches) do
    next_chars[match.next] = true
  end

  M.results = {}

  local l = 0
  for _, match in ipairs(matches) do
    l = l + 1
    while M.labels[l] and next_chars[M.labels[l]] do
      l = l + 1
    end
    if not M.labels[l] then
      break
    end
    match.label = M.labels[l]
    M.results[match.label] = match
    local text = " " .. match.label
    text = match.label
    vim.api.nvim_buf_set_extmark(0, ns, match.row - 1, 0, {
      virt_text = { { text, "Foo" } },
      virt_text_pos = "overlay",
      virt_text_win_col = match.col + 1,
    })
  end
end
