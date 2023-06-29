---@class Pos
---@field row number
---@field col number
---@field [1] number
---@field [2] number
---@overload fun(pos?: number[] | { row: number, col: number } | number): Pos
local P = {}

---@param pos? number[] | { row: number, col: number } | number
function P.new(pos)
  if pos == nil then
    pos = vim.api.nvim_win_get_cursor(0)
  elseif type(pos) == "number" then
    pos = vim.api.nvim_win_get_cursor(pos)
  end

  if getmetatable(pos) == P then
    return pos
  end
  local self = setmetatable({}, P)
  self[1] = pos[1] or pos.row
  self[2] = pos[2] or pos.col
  return self
end

function P:__index(key)
  if key == "row" then
    return rawget(self, 1)
  elseif key == "col" then
    return rawget(self, 2)
  end
  return P[key]
end

function P:__newindex(key, value)
  if key == "row" then
    rawset(self, 1, value)
  elseif key == "col" then
    rawset(self, 2, value)
  else
    rawset(self, key, value)
  end
end

function P:__eq(other)
  return self[1] == other[1] and self[2] == other[2]
end

function P:__tostring()
  return ("[%d, %d]"):format(self[1], self[2])
end

function P:id(buf)
  return table.concat({ buf, self[1], self[2] }, ":")
end

function P:dist(other)
  return math.abs(self[1] - other[1]) + math.abs(self[2] - other[2])
end

function P:__add(other)
  other = P(other)
  return P.new({ self[1] + other[1], self[2] + other[2] })
end

function P:__sub(other)
  other = P(other)
  return P.new({ self[1] - other[1], self[2] - other[2] })
end

function P:__lt(other)
  other = P(other)
  return self[1] < other[1] or (self[1] == other[1] and self[2] < other[2])
end

function P:__le(other)
  other = P(other)
  return self < other or self == other
end

return setmetatable(P, {
  __call = function(_, pos)
    return P.new(pos)
  end,
})
