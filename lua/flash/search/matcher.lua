local Pos = require("flash.search.pos")

---@class Flash.Match
---@field win number
---@field pos Pos -- (1,0) indexed
---@field end_pos Pos -- (1,0) indexed
---@field label? string|false -- set to false to disable label
---@field highlight? boolean
---@field fold? number

---@alias Flash.Match.Find {forward?:boolean, wrap?:boolean, count?:number, pos?: Pos, match?:Flash.Match, current?:boolean}

---@class Flash.Matcher
---@field win number
---@field get fun(self, opts?: {from?:Pos, to?:Pos}): Flash.Match[]
---@field find fun(self, opts?: Flash.Match.Find): Flash.Match
---@field labels fun(self, labels: string[]): string[]
---@field update? fun(self)

---@class Flash.Matcher.Custom: Flash.Matcher
---@field matches Flash.Match[]
local M = {}
M.__index = M

function M.new(win)
  local self = setmetatable({}, M)
  self.matches = {}
  self.win = win
  return self
end

---@param fn fun(win: number, state:Flash.State, opts: {from:Pos, to:Pos}): Flash.Match[]
function M.from(fn)
  ---@param win number
  ---@param state Flash.State
  return function(win, state)
    local ret = M.new(win)
    ret.get = function(self, opts)
      local matches = fn(win, state, opts)
      if state.opts.filter then
        matches = state.opts.filter(matches, state) or matches
      end
      self:set(matches)
      return M.get(self, opts)
    end

    return ret
  end
end

---@param ...? Flash.Match.Find
---@return Flash.Match.Find
function M.defaults(...)
  local other = vim.tbl_filter(function(k)
    return k ~= nil
  end, { ... })

  local opts = vim.tbl_extend("force", {
    pos = vim.api.nvim_win_get_cursor(0),
    forward = true,
    wrap = true,
    count = 1,
  }, {}, unpack(other))
  opts.pos = Pos(opts.pos)
  return opts
end

---@param opts? Flash.Match.Find
function M:find(opts)
  opts = M.defaults(opts)

  if opts.count == 0 then
    for _, match in ipairs(self.matches) do
      if match.pos == opts.pos then
        return match
      end
    end
    return
  end

  ---@type number?
  local idx

  if opts.match then
    for m, match in ipairs(self.matches) do
      if match.pos == opts.match.pos and match.end_pos == opts.match.end_pos then
        idx = m + (opts.forward and 1 or -1)
        break
      end
    end
  elseif opts.forward then
    for i = 1, #self.matches, 1 do
      if self.matches[i].pos > opts.pos then
        idx = i
        break
      end
    end
  else
    for i = #self.matches, 1, -1 do
      if self.matches[i].pos < opts.pos then
        idx = i
        break
      end
    end
  end

  if not idx then
    if not opts.wrap then
      return
    end
    idx = opts.forward and 1 or #self.matches
  end

  if opts.forward then
    idx = idx + opts.count - 1
  else
    idx = idx - opts.count + 1
  end

  if opts.wrap then
    idx = (idx - 1) % #self.matches + 1
  end
  return self.matches[idx]
end

---@param labels string[]
function M:labels(labels)
  return labels
end

---@param opts? {from?:Pos, to?:Pos}
function M:get(opts)
  return M.filter(self.matches, opts)
end

---@param matches Flash.Match[]
---@param opts? {from?:Pos, to?:Pos}
function M.filter(matches, opts)
  opts = opts or {}
  opts.from = opts.from and Pos(opts.from)
  opts.to = opts.to and Pos(opts.to)
  ---@param match Flash.Match
  return vim.tbl_filter(function(match)
    if opts.from and match.end_pos < opts.from then
      return false
    end
    if opts.to and match.pos > opts.to then
      return false
    end
    return true
  end, matches)
end

---@param matches Flash.Match[]
function M:set(matches)
  for _, match in ipairs(matches) do
    match.pos = Pos(match.pos)
    match.end_pos = Pos(match.end_pos)
    match.win = match.win or self.win
  end

  table.sort(matches, function(a, b)
    if a.win ~= b.win then
      return a.win < b.win
    end
    if a.pos ~= b.pos then
      return a.pos < b.pos
    end
    local da = a.depth or 0
    local db = b.depth or 0
    if da ~= db then
      return da < db
    end
    return a.end_pos < b.end_pos
  end)
  self.matches = matches
end

return M
