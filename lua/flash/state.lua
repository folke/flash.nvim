local require = require("flash.require")

local Config = require("flash.config")
local Highlight = require("flash.highlight")
local Searcher = require("flash.searcher")
local Jump = require("flash.jump")

---@class Flash.State
---@field buf buffer
---@field win window
---@field wins window[]
---@field pos number[]
---@field results Flash.Match[]
---@field pattern string
---@field opts Flash.Config
---@field current number
---@field labeler Flash.Labeler
---@field changedtick number
---@field ns number
local M = {}

function M.is_search()
  local t = vim.fn.getcmdtype()
  return t == "/" or t == "?"
end

---@param opts? Flash.Config
function M.new(opts)
  local self = setmetatable({}, { __index = M })
  self.opts = Config.get(opts)
  self.results = {}
  self.wins = {}
  self.pattern = ""
  self.current = 1
  self.labeler = require("flash.labeler").new(self)
  self.ns = vim.api.nvim_create_namespace(self.opts.ns or "flash")
  self:update()
  return self
end

---@param match Flash.Match
---@protected
function M:_jump(match)
  Jump.jump(match, self)
  Jump.on_jump(self)
end

---@param label? string
---@return Flash.Match?
function M:jump(label)
  local match = self:get(label)
  if match then
    self:_jump(match)
    return match
  end
end

-- Returns the current match or the match with the given label.
---@param label? string
---@return Flash.Match?
function M:get(label)
  if not label then
    return self.results[self.current]
  end
  for _, m in ipairs(self.results) do
    if m.label == label then
      return m
    end
  end
end

-- Moves the results cursor by `amount` (default 1) and wraps around.
-- When forward is `nil` it uses the current search direction.
-- Otherwise it uses the given direction.
---@param amount? number
---@param forward? boolean
function M:advance(amount, forward)
  amount = amount or 1
  if forward == nil then
    forward = self.opts.search.forward
  end
  self.current = self.current + (forward and amount or -amount)
  -- wrap around
  self.current = (self.current - 1) % #self.results + 1
end

-- Moves the results cursor by `amount` (default 1) and wraps around.
-- Always moves forward, regardless of the search direction.
function M:next(amount)
  self:advance(math.abs(amount or 1), true)
end

-- Moves the results cursor by `amount` (default 1) and wraps around.
-- Always moves backward, regardless of the search direction.
function M:prev(amount)
  self:advance(-math.abs(amount or 1), true)
end

-- Checks if the given pattern is a jump label and jumps to it.
---@param pattern string
function M:check_jump(pattern)
  if pattern:find(self.pattern, 1, true) == 1 and #pattern == #self.pattern + 1 then
    local label = pattern:sub(-1)
    if self:jump(label) then
      return true
    end
  end
end

function M:is_dirty()
  if self.buf ~= vim.api.nvim_get_current_buf() then
    return true
  end
  if self.changedtick ~= vim.b[self.buf].changedtick then
    return true
  end
end

---@param opts? {search:string, labels:boolean, results?:Flash.Match[], highlight:boolean}
---@return boolean? abort `true` if the search was aborted
function M:update(opts)
  opts = opts or {}

  local dirty = self:is_dirty()

  if dirty then
    self.win = vim.api.nvim_get_current_win()
    self.buf = vim.api.nvim_win_get_buf(self.win)
    self.pos = vim.api.nvim_win_get_cursor(self.win)
    self.changedtick = vim.b[self.buf].changedtick
  end

  -- prioritize current window
  ---@type window[]
  local wins = self.opts.search.multi_window and vim.api.nvim_tabpage_list_wins(0) or {}
  ---@param win window
  wins = vim.tbl_filter(function(win)
    return win ~= self.win
  end, wins)
  table.insert(wins, 1, self.win)
  self.wins = wins

  if opts.results then
    self:set(opts.results)
  elseif opts.search then
    -- abort if pattern is a jump label
    if self:check_jump(opts.search) then
      return true
    end
    self:search(opts.search)
  elseif dirty then
    self:search(self.pattern)
  end

  if self.opts.jump.auto_jump and #self.results == 1 then
    return self:jump()
  end

  if opts.labels ~= false then
    self.labeler:update()
  end
  if opts.highlight ~= false then
    self:highlight()
  end
end

function M:search(pattern)
  self.labeler:reset()
  self.pattern = pattern
  local results = {}
  if pattern ~= "" then
    for _, win in ipairs(self.wins) do
      vim.list_extend(results, Searcher.search(win, self))
      if #results >= self.opts.search.max_matches then
        break
      end
    end
  end
  self:set(results)
end

---@param results Flash.Match[]
---@param opts? {sort:boolean}
function M:set(results, opts)
  opts = opts or {}
  if opts.sort ~= false then
    table.sort(results, function(a, b)
      if a.win ~= b.win then
        local aw = a.win == self.win and 0 or a.win
        local bw = b.win == self.win and 0 or b.win
        return aw < bw
      end
      if a.from[1] ~= b.from[1] then
        return a.from[1] < b.from[1]
      end
      return a.from[2] < b.from[2]
    end)
  end
  self.results = {}
  local done = {}

  for _, match in ipairs(results) do
    local key = match.win .. ":" .. match.from[1] .. ":" .. match.from[2]
    if not done[key] then
      done[key] = true
      table.insert(self.results, match)
    end
  end

  self.current = 1
  for m, match in ipairs(self.results) do
    if match.first and match.win == self.win then
      self.current = m
      break
    end
  end
end

function M:highlight()
  Highlight.update(self)
end

function M:clear()
    Highlight.clear(self.ns)
end

return M
