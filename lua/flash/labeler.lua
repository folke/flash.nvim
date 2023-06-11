---@class Flash.Labeler
---@field state Flash.State
---@field used table<string, string>
---@field labels string[]
local M = {}
M.__index = M

function M.new(state)
  local self = setmetatable({}, M)
  self.state = state
  self.used = {}
  self:reset()
  return self
end

function M:update()
  local matches = self:filter()
  for _, match in ipairs(matches) do
    if not self:label(match, true) then
      break
    end
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
  for _, l in ipairs(vim.split(self.state.config.labels .. self.state.config.labels:upper(), "")) do
    if not skip[l] then
      self.labels[#self.labels + 1] = l
      skip[l] = true
    end
  end
end

---@param fn fun(labels: string[]): string[]
function M:validate(fn)
  self.labels = fn(self.labels)
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
  local pos = table.concat(m.from, ":")
  local label ---@type string?
  if used then
    label = self.used[pos]
  else
    label = self.labels[1]
  end
  if label and self:valid(label) then
    self:use(label)
    self.used[pos] = label
    m.label = label
  end
  return #self.labels > 0
end

function M:filter()
  ---@type Flash.Match[]
  local ret = {}

  -- only label visible matches
  -- and don't label the first match in the current window
  for m, match in ipairs(self.state.results) do
    if
      match.visible ~= false
      and not (
        self.state.current == m
        and not self.state.config.highlight.label.current
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
    if a.from[1] ~= b.from[1] then
      if a.win == self.state.win then
        local da = math.abs(a.from[1] - self.state.pos[1])
        local db = math.abs(b.from[1] - self.state.pos[1])
        return da < db
      end
      return a.from[1] < b.from[1]
    end
    if a.win == self.state.win then
      local da = math.abs(a.from[2] - self.state.pos[2])
      local db = math.abs(b.from[2] - self.state.pos[2])
      return da < db
    end
    return a.from[2] < b.from[2]
  end)
  return ret
end

return M
