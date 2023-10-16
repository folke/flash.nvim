local require = require("flash.require")

local Hacks = require("flash.hacks")
local Matcher = require("flash.search.matcher")
local Pos = require("flash.search.pos")

---@class Flash.Search: Flash.Matcher
---@field state Flash.State
---@field win window
local M = {}
M.__index = M

---@param win number
---@param state Flash.State
function M.new(win, state)
  local self = setmetatable({}, M)
  self.state = state
  self.win = win
  return self
end

---@param flags? string
---@return Flash.Match?
function M:_next(flags)
  flags = flags or ""
  local ok, pos = pcall(vim.fn.searchpos, self.state.pattern.search, flags or "")
  -- incomplete or invalid pattern
  if not ok then
    return
  end
  if pos[1] == 0 then
    return
  end
  pos = Pos({ pos[1], pos[2] - 1 })
  return { win = self.win, pos = pos, end_pos = Hacks.get_end_pos(pos) }
end

---@param pos Pos
---@param fn function
function M:_call(pos, fn)
  pos = Pos(pos)

  local view = vim.api.nvim_win_call(self.win, vim.fn.winsaveview)
  local buf = vim.api.nvim_win_get_buf(self.win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  if pos[1] > line_count then
    pos[1] = line_count
    local line = vim.api.nvim_buf_get_lines(buf, pos[1] - 1, pos[1], false)[1]
    pos[2] = #line - 1
  end
  vim.api.nvim_win_set_cursor(self.win, pos)
  ---@type boolean, any?
  local ok, err
  vim.api.nvim_win_call(self.win, function()
    ok, err = pcall(fn)
    vim.fn.winrestview(view)
  end)
  return not ok and error(err) or err
end

---@param opts? {from?:Pos, to?:Pos}
function M:get(opts)
  if self.state.pattern:empty() then
    return {}
  end

  opts = opts or {}
  opts.from = opts.from and Pos(opts.from) or nil
  opts.to = opts.to and Pos(opts.to) or nil

  ---@type Flash.Match[]
  local ret = {}

  self:_call(opts.from or { 1, 0 }, function()
    local next = self:_next("cW")
    while next and (not opts.to or next.pos <= opts.to) do
      table.insert(ret, next)
      next = self:_next("W")
    end
  end)
  return ret
end

-- Moves the results cursor by `amount` (default 1) and wraps around.
-- When forward is `nil` it uses the current search direction.
-- Otherwise it uses the given direction.
---@param opts? Flash.Match.Find
function M:find(opts)
  if self.state.pattern:empty() then
    return
  end

  opts = Matcher.defaults(opts)
  local flags = (opts.forward and "" or "b")
    .. (opts.wrap and "w" or "W")
    .. ((opts.count == 0 or opts.current) and "c" or "")
  if opts.match then
    opts.pos = opts.match.pos
  end

  ---@type Flash.Match?
  local ret

  self:_call(opts.pos, function()
    for _ = 1, math.max(opts.count, 1) do
      ret = self:_next(flags)
      flags = flags:gsub("c", "")
    end
  end)

  if not ret or (opts.count == 0 and ret.pos ~= opts.pos) then
    return
  end
  return ret
end

return M
