local M = {}

---@class Flash.Match
---@field win window
---@field from number[]
---@field to number[]
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

  local pattern = state.pattern

  if state.config.search.mode == "exact" then
    pattern = "\\V" .. pattern:gsub("\\", "\\\\")
  elseif state.config.search.mode == "fuzzy" then
    pattern = M.fuzzy(pattern)
  end

  state.labeler:validate(function(labels)
    return M.get_valid_labels(pattern, labels)
  end)

  local matches = M.get_matches(pattern, flags, Config.search.max_matches)
  local first = matches[1]
  if first and state.win == win and state.is_search() then
    info.topline = first.from[1] - info.height
    info.botline = first.from[1] + info.height
  end

  for _, m in ipairs(matches) do
    m.win = win
    m.visible = m.from[1] >= info.topline and m.from[1] <= info.botline
  end
  return matches
end

---@param pattern string
---@param flags? string
---@param k? number
function M.get_matches(pattern, flags, k)
  local view = vim.fn.winsaveview()

  flags = (flags or "") .. ""

  ---@type Flash.Match[]
  local matches = {}

  while true do
    local from = vim.fn.searchpos(pattern, flags)
    if from[1] == 0 then
      break
    end
    from = { from[1], from[2] - 1 } or nil
    if not from or vim.deep_equal(from, matches[1] and matches[1].from) then
      break
    end
    local line = vim.api.nvim_buf_get_lines(0, from[1] - 1, from[1], false)[1]
    local to = vim.fn.matchstrpos(line, pattern, from[2])
    if to[2] == -1 or to[2] ~= from[2] then
      vim.notify("matchstrpos failed:\n" .. vim.inspect({
        line = line,
        from = from,
        to = to,
      }), vim.log.levels.ERROR, { title = "flash.nvim" })
    else
      table.insert(matches, {
        from = from,
        to = { from[1], math.max(to[3] - 1, 0) },
        first = #matches == 0,
      })
    end

    if k and #matches >= k then
      break
    end
  end

  vim.fn.winrestview(view)
  return matches
end

---@param opts? {ignorecase: boolean, smartcase: boolean, whitespace:boolean}
function M.fuzzy(pattern, opts)
  opts = vim.tbl_deep_extend("force", {
    ignorecase = vim.go.ignorecase,
    smartcase = vim.go.smartcase,
    whitespace = false,
  }, opts or {})

  if opts.ignorecase and opts.smartcase and pattern:find("[A-Z]") then
    opts.ignorecase = false
  end

  local sep = opts.whitespace and ".\\{-}" or "\\[^\\ ]\\{-}"

  local chars = vim.tbl_map(function(c)
    return c == "\\" and "\\\\" or c
  end, vim.split(pattern, ""))

  return "\\V" .. table.concat(chars, sep) .. (opts.ignorecase and "\\c" or "\\C")
end

---@param pattern string
---@param labels string[]
---@return string[]
function M.get_valid_labels(pattern, labels)
  while #labels > 0 do
    local p = pattern .. "\\m\\zs[" .. table.concat(labels, "") .. "]\\C"
    local ok, pos = pcall(vim.fn.searchpos, p, "cnw")

    -- skip all labels on an invalid pattern
    if not ok then
      return {}
    end

    -- not found, we're done
    if pos[1] == 0 then
      break
    end

    local char = vim.fn.getline(pos[1]):sub(pos[2], pos[2])
    -- HACK: this will fail if the pattern is an incomplete regex
    -- In that case, we skip all labels
    if not vim.tbl_contains(labels, char) then
      return {}
    end

    labels = vim.tbl_filter(function(c)
      return c ~= char
    end, labels)
  end
  return labels
end

return M
