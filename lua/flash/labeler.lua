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
  for _, matcher in pairs(self.state.matchers) do
    self.labels = matcher:labels(self.labels)
  end
  for _, m in ipairs(self.state.results) do
    m.label = nil
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
  if m.label then
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
    if self.state.opts.highlight.label.reuse ~= "lowercase" or label:lower() == label then
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

  -- only label visible matches
  -- and don't label the first match in the current window
  for _, match in ipairs(self.state.results) do
    if
      not (
        (target and match.pos == target.pos)
        and not self.state.opts.highlight.label.current
        and match.win == self.state.win
      )
    then
      table.insert(ret, match)
    end
  end

  -- sort by current win, other win, then by distance
  table.sort(ret, function(a, b)
    if a.win ~= b.win then
      local aw = a.win == self.state.win and 0 or a.win
      local bw = b.win == self.state.win and 0 or b.win
      return aw < bw
    end
    if a.pos[1] ~= b.pos[1] then
      if a.win == self.state.win then
        local da = math.abs(a.pos[1] - from[1])
        local db = math.abs(b.pos[1] - from[1])
        return da < db
      end
      return a.pos[1] < b.pos[1]
    end
    if a.win == self.state.win then
      local da = math.abs(a.pos[2] - from[2])
      local db = math.abs(b.pos[2] - from[2])
      return da < db
    end
    return a.pos[2] < b.pos[2]
  end)
  return ret
end

return M
