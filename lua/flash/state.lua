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
---@field config Flash.Config
---@field current number
---@field labeler Flash.Labeler
local M = {}

function M.is_search()
  local t = vim.fn.getcmdtype()
  return t == "/" or t == "?"
end

---@param opts? {win:number, config:Flash.Config, wrap:boolean}
function M.new(opts)
  opts = opts or {}
  local self = setmetatable({}, { __index = M })
  self.config = Config.get(opts.config)
  self.win = opts.win or vim.api.nvim_get_current_win()
  self.buf = vim.api.nvim_win_get_buf(self.win)
  self.pos = vim.api.nvim_win_get_cursor(self.win)
  self.results = {}
  self.wins = { self.win }
  self.pattern = ""
  self.current = 1
  self.labeler = require("flash.labeler").new(self)
  self:update()
  return self
end

---@param match Flash.Match
function M:on_jump(match)
  Jump.jump(match, self)
  Jump.on_jump(self)
end

function M:is_current_buf()
  return self.buf == vim.api.nvim_get_current_buf()
end

---@param label? string
---@return Flash.Match?
function M:jump(label)
  local match = self:get(label)
  if match then
    self:on_jump(match)
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
    forward = self.config.search.forward
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

---@param pattern string
function M:validate(pattern)
  if
    self.config.search.regex
    and self.config.search.abort_pattern
    and pattern:match(self.config.search.abort_pattern)
  then
    self:clear()
    self.results = {}
    return false
  end
  return true
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

---@param opts? {search:string, labels:boolean, results?:Flash.Match[]}
---@return boolean? abort `true` if the search was aborted
function M:update(opts)
  opts = opts or {}

  -- prioritize current window
  ---@type window[]
  local wins = self.config.search.multi_window and vim.api.nvim_tabpage_list_wins(0) or {}
  ---@param win window
  wins = vim.tbl_filter(function(win)
    return win ~= self.win
  end, wins)
  table.insert(wins, 1, self.win)
  self.wins = wins

  if opts.results then
    self:set(opts.results)
  elseif opts.search then
    -- abort if pattern is invalid or a jump label
    if not self:validate(opts.search) or self:check_jump(opts.search) then
      return true
    end
    self:search(opts.search)
  end

  if self.config.jump.auto_jump and #self.results == 1 then
    return self:jump()
  end

  if opts.labels ~= false then
    self.labeler:update()
  end
  self:highlight()
end

function M:search(pattern)
  self.pattern = pattern
  local results = {}
  if pattern ~= "" then
    for _, win in ipairs(self.wins) do
      local r = Searcher.search(win, self)
      -- max results reached, so stop searching
      if not r then
        break
      end
      vim.list_extend(results, r)
    end
  end
  self:set(results)
end

---@param results Flash.Match[]
---@param opts? {sort:boolean}
function M:set(results, opts)
  opts = opts or {}
  self.results = results
  if opts.sort then
    table.sort(self.results, function(a, b)
      if a.win ~= b.win then
        return a.win < b.win
      end
      if a.from[1] ~= b.from[1] then
        return a.from[1] < b.from[1]
      end
      return a.from[2] < b.from[2]
    end)
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
  Highlight.clear()
end

return M
