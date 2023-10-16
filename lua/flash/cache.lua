local Pattern = require("flash.search.pattern")
local Pos = require("flash.search.pos")
local Util = require("flash.util")

---@class Flash.State.Window
---@field win number
---@field buf number
---@field topline number
---@field botline number
---@field changedtick number

---@class Flash.Cache
---@field state Flash.State
---@field pattern Flash.Pattern
---@field wins Flash.State.Window[]
local M = {}
M.__index = M

---@type table<Flash.State.Window, {matches: Flash.Match[]}>
M.cache = setmetatable({}, { __mode = "k" })

---@param state Flash.State
function M.new(state)
  local self = setmetatable({}, M)
  self.state = state
  self.pattern = Pattern.new("", state.opts.search.mode, state.opts.search.trigger)
  self.wins = {}
  return self
end

---@return boolean dirty Returns true when dirty
function M:update()
  local dirty = false

  if self.pattern ~= self.state.pattern then
    self.pattern = self.state.pattern:clone()
    dirty = true
    M.cache = {}
  end

  local win = vim.api.nvim_get_current_win()
  if self.state.win ~= win then
    self.state.win = win
    self.state.pos = Pos(win)
    self.state.restore_windows = Util.save_layout()
    M.cache = {}
    dirty = true
  end

  self:_update_wins()

  for _, w in ipairs(self.state.wins) do
    if self:_dirty(w) then
      dirty = true
    end
  end
  return dirty
end

---@param win window
function M:get_state(win)
  local window = self:get(win)
  if not window then
    return
  end
  if M.cache[window] then
    return M.cache[window]
  end

  local from = Pos({ window.topline, 0 })
  local to = Pos({ window.botline + 1, 0 })

  if not self.state.opts.search.wrap and win == self.state.win then
    if self.state.opts.search.forward then
      from = self.state.pos
    else
      to = self.state.pos
    end
  end

  local matcher = self.state:get_matcher(win)
  if matcher.update then
    matcher:update()
  end

  M.cache[window] = {
    matches = matcher:get({ from = from, to = to }),
  }
  return M.cache[window]
end

---@param win window
---@return Flash.State.Window
function M:get(win)
  return self.wins[win]
end

function M:_update_wins()
  -- prioritize current window
  self.state.wins = { self.state.win }

  if self.state.opts.search.multi_window then
    local keep_current = false

    ---@param w window
    self.state.wins = vim.tbl_filter(function(w)
      local buf = vim.api.nvim_win_get_buf(w)
      local ft = vim.bo[buf].filetype

      for _, exclude in ipairs(self.state.opts.search.exclude) do
        if type(exclude) == "string" and exclude == ft then
          return false
        elseif type(exclude) == "function" and exclude(w) then
          return false
        end
      end
      if w == self.state.win then
        keep_current = true
        return false
      end
      return true
    end, vim.api.nvim_tabpage_list_wins(0))
    if keep_current then
      table.insert(self.state.wins, 1, self.state.win)
    end
  end
end

---@param win window
function M:_dirty(win)
  local info = vim.fn.getwininfo(win)[1]
  local buf = vim.api.nvim_win_get_buf(win)

  ---@type Flash.State.Window
  local state = {
    win = win,
    buf = buf,
    cursor = vim.api.nvim_win_get_cursor(win),
    topline = info.topline,
    botline = info.botline,
    changedtick = vim.b[buf].changedtick,
  }
  if not vim.deep_equal(state, self.wins[win]) then
    self.wins[win] = state
    return true
  end
end

return M
