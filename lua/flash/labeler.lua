---@class Flash.Labeler
---@field state Flash.State
---@field used table<string, string>
---@field labels string[]
local M = {}
M.__index = M

function M.new(state)
  local self
  self = setmetatable({}, M)
  self.state = state
  self.used = {}
  self:reset()
  return self
end

function M:labeler()
  return function()
    return self:update()
  end
end

function M:update()
  self:reset()

  if #self.state.pattern() < self.state.opts.label.min_pattern_length then
    return
  end

  local matches = self:filter()

  for _, match in ipairs(matches) do
    self:label(match, true)
  end

  for _, match in ipairs(matches) do
    if not self:label(match) then
      break
    end
  end
end

function M:reset()
  local skip = {} ---@type table<string, boolean>
  self.labels = {}

  for _, l in ipairs(self.state:labels()) do
    if not skip[l] then
      self.labels[#self.labels + 1] = l
      skip[l] = true
    end
  end
  if
    not self.state.opts.search.max_length
    or #self.state.pattern() < self.state.opts.search.max_length
  then
    for _, win in pairs(self.state.wins) do
      self.labels = self:skip(win, self.labels)
    end
  end
  for _, m in ipairs(self.state.results) do
    if m.label ~= false then
      m.label = nil
    end
  end
end

function M:valid(label)
  return vim.tbl_contains(self.labels, label)
end

function M:use(label)
  self.labels = vim.tbl_filter(function(c)
    return c ~= label
  end, self.labels)
end

---@param m Flash.Match
---@param used boolean?
function M:label(m, used)
  if m.label ~= nil then
    return true
  end
  local pos = m.pos:id(m.win)
  local label ---@type string?
  if used then
    label = self.used[pos]
  else
    label = self.labels[1]
  end
  if label and self:valid(label) then
    self:use(label)
    local reuse = self.state.opts.label.reuse == "all"
      or (self.state.opts.label.reuse == "lowercase" and label:lower() == label)

    if reuse then
      self.used[pos] = label
    end
    m.label = label
  end
  return #self.labels > 0
end

function M:filter()
  ---@type Flash.Match[]
  local ret = {}

  local target = self.state.target

  local from = vim.api.nvim_win_get_cursor(self.state.win)
  ---@type table<number, boolean>
  local folds = {}

  -- only label visible matches
  for _, match in ipairs(self.state.results) do
    -- and don't label the first match in the current window
    local skip = (target and match.pos == target.pos)
      and not self.state.opts.label.current
      and match.win == self.state.win

    -- Only label the first match in each fold
    if not skip and match.fold then
      if folds[match.fold] then
        skip = true
      else
        folds[match.fold] = true
      end
    end

    if not skip then
      table.insert(ret, match)
    end
  end

  -- sort by current win, other win, then by distance
  table.sort(ret, function(a, b)
    local use_distance = self.state.opts.label.distance and a.win == self.state.win

    if a.win ~= b.win then
      local aw = a.win == self.state.win and 0 or a.win
      local bw = b.win == self.state.win and 0 or b.win
      return aw < bw
    end
    if use_distance then
      local dfrom = from[1] * vim.go.columns + from[2]
      local da = a.pos[1] * vim.go.columns + a.pos[2]
      local db = b.pos[1] * vim.go.columns + b.pos[2]
      return math.abs(dfrom - da) < math.abs(dfrom - db)
    end
    if a.pos[1] ~= b.pos[1] then
      return a.pos[1] < b.pos[1]
    end
    return a.pos[2] < b.pos[2]
  end)
  return ret
end

-- Returns valid labels for the current search pattern
-- in this window.
---@param labels string[]
---@return string[] returns labels to skip or `nil` when all labels should be skipped
function M:skip(win, labels)
  local pattern = self.state.pattern.skip

  -- skip all labels if the pattern is empty
  if pattern == "" then
    return {}
  end

  -- skip all labels if the pattern is invalid
  local ok = pcall(vim.regex, pattern)
  if not ok then
    return {}
  end

  -- skip all labels if the pattern ends with a backslash
  -- except if it's escaped
  if pattern:find("\\$") and not pattern:find("\\\\$") then
    return {}
  end

  vim.api.nvim_win_call(win, function()
    while #labels > 0 do
      -- this is needed, since an uppercase label would trigger smartcase
      local label_group = table.concat(labels, "")
      if vim.go.ignorecase then
        label_group = label_group:lower()
      end

      local p = "\\%(" .. pattern .. "\\)\\m\\zs[" .. label_group .. "]"
      local pos
      ok, pos = pcall(vim.fn.searchpos, p, "cnw")

      if not ok then
        labels = {}
        break
      end

      -- not found, we're done
      if pos[1] == 0 then
        return
      end

      local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
      local char = vim.fn.strpart(line, pos[2] - 1, 1, true)

      local label_count = #labels
      labels = vim.tbl_filter(function(c)
        -- when ignorecase is set, we need to skip
        -- both the upper and lower case labels
        if vim.go.ignorecase then
          return c:lower() ~= char:lower()
        end
        return c ~= char
      end, labels)

      -- HACK: this will fail if the pattern is an incomplete regex
      -- In that case, we skip all labels
      if label_count == #labels then
        labels = {}
        break
      end
    end
  end)
  return labels
end

return M
