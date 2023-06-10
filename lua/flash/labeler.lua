---@class Flash.Labeler
---@field state Flash.State
---@field used table<string, string>
local M = {}
M.__index = M

function M.new(state)
  local self = setmetatable({}, M)
  self.state = state
  self.used = {}
  return self
end

function M:update()
  local labeler = self:labeler()
  local matches = self:filter()
  for _, match in ipairs(matches) do
    if not labeler(match, true) then
      break
    end
  end
  for _, match in ipairs(matches) do
    if not labeler(match) then
      break
    end
  end
end

function M:labeler()
  local skip = {} ---@type table<string, boolean>
  for _, m in ipairs(self.state.results) do
    if m.next then
      skip[m.next] = true
    end
  end

  ---@type table<string, boolean>
  local available = {}
  local labels = {} ---@type string[]
  for _, l in ipairs(vim.split(self.state.config.labels .. self.state.config.labels:upper(), "")) do
    if not skip[l] then
      labels[#labels + 1] = l
      available[l] = true
      skip[l] = true
    end
  end

  ---@param m Flash.Match
  ---@param used boolean?
  return function(m, used)
    if m.label then
      return true
    end
    local pos = table.concat(m.from, ":")
    local label ---@type string?
    if used then
      label = available[self.used[pos]] and self.used[pos] or nil
    else
      label = table.remove(labels, 1)
      while label and not available[label] do
        label = table.remove(labels, 1)
      end
    end
    if label then
      self.used[pos] = label
      m.label = label
      available[label] = nil
    end
    return #labels > 0
  end
end

function M:filter()
  ---@type Flash.Match[]
  local ret = {}

  -- only label visible matches
  -- and don't label the first match in the current window
  for m, match in ipairs(self.state.results) do
    if match.visible ~= false and not (self.state.current == m and not self.state.config.highlight.label.current) then
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
