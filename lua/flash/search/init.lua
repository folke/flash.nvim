local Pos = require("flash.search.pos")
local Hacks = require("flash.hacks")
local Pattern = require("flash.search.pattern")
local Matcher = require("flash.matcher")

---@class Flash.Search: Flash.Matcher
---@field state Flash.State
---@field win window
---@field pattern Flash.Pattern
local M = {}
M.__index = M

---@param win number
---@param state Flash.State
function M.new(win, state)
  local self = setmetatable({}, M)
  self.state = state
  self.win = win
  self.pattern = Pattern.new(self.state.pattern, self.state.opts.search.mode)
  return self
end

function M:_validate()
  if self.state.pattern ~= self.pattern.pattern then
    self.pattern = Pattern.new(self.state.pattern, self.state.opts.search.mode)
  end
end

---@param flags? string
---@return Flash.Match?
function M:_next(flags)
  flags = flags or ""
  local pos = vim.fn.searchpos(self.pattern.search, flags or "")
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
  self:_validate()

  if self.pattern.search == "" then
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
  self:_validate()

  if self.pattern.search == "" then
    return
  end

  opts = Matcher.defaults(opts)
  local flags = (opts.forward and "" or "b")
    .. (opts.wrap and "w" or "W")
    .. (opts.count == 0 and "c" or "")

  ---@type Flash.Match?
  local ret

  self:_call(opts.pos, function()
    for _ = 1, math.max(opts.count, 1) do
      ret = self:_next(flags)
    end
  end)

  if not ret or (opts.count == 0 and ret.pos ~= opts.pos) then
    return
  end
  return ret
end

---@param labels string[]
---@return string[]|nil returns labels to skip or `nil` when all labels should be skipped
function M:skip(labels)
  self:_validate()
  local pattern = self.pattern.skip
  if pattern == "" then
    return
  end

  vim.api.nvim_win_call(self.win, function()
    -- skip all labels if the pattern ends with a backslash
    -- except if it's escaped
    if pattern:find("\\$") and not pattern:find("\\\\$") then
      labels = nil
      return
    end

    while #labels > 0 do
      local p = pattern .. "\\m\\zs[" .. table.concat(labels, "") .. "]"
      local ok, pos = pcall(vim.fn.searchpos, p, "cnw")

      -- skip all labels on an invalid pattern
      if not ok then
        labels = nil
        return
      end

      -- not found, we're done
      if pos[1] == 0 then
        break
      end

      local char = vim.fn.getline(pos[1]):sub(pos[2], pos[2])
      -- HACK: this will fail if the pattern is an incomplete regex
      -- In that case, we skip all labels
      if not vim.tbl_contains(labels, char) then
        labels = nil
        return
      end

      labels = vim.tbl_filter(function(c)
        -- when ignorecase is set, we need to skip
        -- both the upper and lower case labels
        if vim.go.ignorecase then
          return c:lower() ~= char:lower()
        end
        return c ~= char
      end, labels)
    end
  end)
  return labels
end

return M
