local Pos = require("flash.search.pos")
local Matcher = require("flash.matcher")
local Hacks = require("flash.hacks")

---@class Flash.Search.View
---@field win window
---@field buf buffer
---@field pattern string
---@field changedtick number
---@field topline? number
---@field botline? number
---@field matches Flash.Match[]
---@field stats {searches: number}
local M = {}
M.__index = M

function M.new(win, pattern)
  local self = setmetatable({}, M)
  self.win = win
  if win == 0 or win == nil then
    self.win = vim.api.nvim_get_current_win()
  end
  self.pattern = pattern
  self.stats = { searches = 0 }
  self:_validate()
  return self
end

---@param pattern? string
function M:reset(pattern)
  if pattern then
    self.pattern = pattern
  end
  self.buf = vim.api.nvim_win_get_buf(self.win)
  self.changedtick = vim.b[self.buf].changedtick
  self.topline = nil
  self.botline = nil
  self.matches = {}
end

---@private
function M:_validate()
  if
    self.buf ~= vim.api.nvim_win_get_buf(self.win)
    or self.changedtick ~= vim.b[self.buf].changedtick
  then
    self:reset()
  end
end

---@param topline? number
---@param botline? number
---@return Flash.Match[]
function M:get(topline, botline)
  self:_validate()
  local info = vim.fn.getwininfo(self.win)[1]
  topline = topline or info.topline
  botline = botline or info.botline
  if topline == 0 then
    topline = 1
  end
  if botline == -1 then
    botline = vim.api.nvim_buf_line_count(self.buf)
  end
  self:_update(topline, botline)

  return vim.tbl_filter(function(m)
    return m.pos[1] >= topline and m.pos[1] <= botline
  end, self.matches)
end

---@private
function M:_update(topline, botline)
  local overlaps = self.topline
    and self.botline
    and topline <= self.botline
    and botline >= self.topline

  -- when the search range overlaps the current search range
  -- we can just search the new parts
  if overlaps then
    if self.topline and topline < self.topline then
      topline = math.max(topline, 1)
      self:_search(topline, self.topline - 1, true)
      self.topline = topline
    end
    if self.botline and botline > self.botline then
      botline = math.min(botline, vim.api.nvim_buf_line_count(self.buf))
      self:_search(self.botline + 1, botline)
      self.botline = botline
    end
  -- otherwise we have to search the whole range
  else
    self.matches = {}
    topline = math.max(topline, 1)
    botline = math.min(botline, vim.api.nvim_buf_line_count(self.buf))
    self:_search(topline, botline)
    self.topline = topline
    self.botline = botline
  end
end

local cache = {}
---@private
---@param flags? string
---@return Pos?
function M:_next(flags)
  flags = flags or ""
  -- local cursor = vim.api.nvim_win_get_cursor(self.win)
  -- local key = table.concat({ cursor[1], cursor[2], flags }, ":")
  -- if cache[key] then
  --   if cache[key] == "NOT" then
  --     return nil
  --   end
  --   if not flags:find("n", 1, true) then
  --     vim.api.nvim_win_set_cursor(self.win, cache[key])
  --   end
  --   return cache[key] ~= "NOT" and cache[key] or nil
  -- end
  self.stats.searches = (self.stats.searches or 0) + 1
  local from = vim.fn.searchpos(self.pattern, flags or "")
  local ret = from[1] ~= 0 and Pos({ from[1], from[2] - 1 }) or nil
  -- cache[key] = ret or "NOT"
  return ret
end

---@param pos Pos
function M:contains(pos)
  return self.topline and self.botline and self.topline <= pos[1] and self.botline >= pos[1]
end

---@param pos Pos
---@param count? number
---@param flags? string
function M:one(pos, flags, count)
  count = count or 1
  local view = vim.api.nvim_win_call(self.win, vim.fn.winsaveview)
  ---@type Pos?
  local ret
  vim.api.nvim_win_call(self.win, function()
    vim.api.nvim_win_set_cursor(self.win, pos)
    for _ = 1, count do
      ret = self:_next(flags)
    end
    vim.fn.winrestview(view)
  end)
  return ret
end

--- @param opts? Flash.Match.Find
--- @return Flash.Match?
function M:find(opts)
  self:_validate()
  if self.pattern == "" then
    return
  end

  opts = Matcher.defaults(opts)

  local mopts = Matcher.defaults(opts, { wrap = false })

  local match = self:contains(opts.pos) and Matcher.find(self, mopts)
  if match then
    return match
  end

  local flags = (opts.forward and "" or "b") .. (opts.wrap and "w" or "W")
  local next = self:one(opts.pos, flags, opts.count)
  if next then
    if opts.forward then
      self:_update(next < opts.pos and 1 or self.topline or next[1], next[1])
    else
      self:_update(
        next[1],
        next > opts.pos and vim.api.nvim_buf_line_count(self.buf) or self.botline or next[1]
      )
    end
    local ret = Matcher.find(self, opts)
    return ret
  end
end

---@private
function M:_search(topline, botline, before)
  if self.pattern == "" then
    return
  end
  local idx = before and 1 or (#self.matches + 1)
  local view = vim.api.nvim_win_call(self.win, vim.fn.winsaveview)
  vim.api.nvim_win_call(self.win, function()
    local ok = pcall(vim.api.nvim_win_set_cursor, self.win, { topline, 0 })
    if ok then
      -- local next = Cache.search(self.win, self.pattern, {
      --   at = true,
      --   pos = { topline, 0 },
      -- })
      --
      -- while next and next.pos[1] <= botline do
      --   table.insert(self.matches, idx, next)
      --   idx = idx + 1
      --   next = Cache.search(self.win, self.pattern, {
      --     pos = next.pos,
      --   })
      -- end

      local pos = self:_next("cW")
      while pos and pos[1] <= botline do
        table.insert(self.matches, idx, {
          pos = pos,
          end_pos = Hacks.get_end_pos(pos),
          win = self.win,
        })

        idx = idx + 1
        pos = self:_next("W")
      end
    end
    vim.fn.winrestview(view)
  end)
end

return M
