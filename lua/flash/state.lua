local Config = require("flash.config")
local Highlight = require("flash.highlight")
local Search = require("flash.search")

---@class Flash.State
---@field buf buffer
---@field win window
---@field wins window[]
---@field pos number[]
---@field op boolean operator pending mode
---@field results Flash.Match[]
---@field pattern string
---@field config Flash.Config
---@field labels boolean
---@field current number
---@field labeler Flash.Labeler
local M = {}

---@type Flash.State?
M.state = nil

function M.is_search()
  local t = vim.fn.getcmdtype()
  return t == "/" or t == "?"
end

function M.setup()
  local group = vim.api.nvim_create_augroup("flash", { clear = true })

  local function wrap(fn)
    return function(...)
      if M.state then
        return fn(...)
      end
    end
  end

  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    callback = wrap(function()
      M.state:update(vim.fn.getcmdline())
    end),
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = wrap(function()
      M.state:clear()
      M.state = nil
    end),
  })
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
    callback = function()
      if M.is_search() then
        M.state = M.new({
          op = vim.fn.mode() == "v",
          config = {
            mode = "search",
            search = {
              forward = vim.fn.getcmdtype() == "/",
              regex = true,
            },
          },
        })
      end
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:c",
    group = group,
    callback = wrap(function()
      local op = vim.v.event.old_mode:sub(1, 2) == "no" or vim.fn.mode() == "v"
      M.state.op = op
      M.state:update()
    end),
  })
end

---@param opts? {win:number, op:boolean, config:Flash.Config, wrap:boolean, labels:boolean}
function M.new(opts)
  opts = opts or {}
  local self = setmetatable({}, { __index = M })
  self.config = Config.get(opts.config)
  self.labels = opts.labels == nil and true or opts.labels
  self.op = opts.op or false
  self.win = opts.win or vim.api.nvim_get_current_win()
  self.buf = vim.api.nvim_win_get_buf(self.win)
  self.pos = vim.api.nvim_win_get_cursor(self.win)
  self.mode = opts.mode or vim.api.nvim_get_mode().mode
  self.results = {}
  self.wins = {}
  self.pattern = ""
  self.current = 1
  self.labeler = require("flash.labeler").new(self)
  self:update("")
  return self
end

---@param label? string
---@return Flash.Match?
function M:jump(label)
  local Jump = require("flash.jump")
  return Jump.jump(label, self)
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
  self:advance(math.abs(amount), true)
end

-- Moves the results cursor by `amount` (default 1) and wraps around.
-- Always moves backward, regardless of the search direction.
function M:prev(amount)
  self:advance(-math.abs(amount), true)
end

---@param pattern string?
function M:update(pattern)
  pattern = pattern or self.pattern or ""

  if self.config.search.regex and pattern:match(self.config.search.abort_pattern) then
    Highlight.clear()
    self.results = {}
    return
  end

  if pattern:find(self.pattern, 1, true) == 1 and #pattern == #self.pattern + 1 then
    local label = pattern:sub(-1)
    if self:jump(label) then
      return true
    end
  end

  self.pattern = pattern
  self.results = {}

  -- prioritize current window
  ---@type window[]
  local wins = (self.op or not self.config.search.multi_window) and {} or vim.api.nvim_tabpage_list_wins(0)
  wins = vim.tbl_filter(function(win)
    return win ~= self.win
  end, wins)
  table.insert(wins, 1, self.win)
  self.wins = wins

  if pattern ~= "" then
    for _, win in ipairs(wins) do
      local results = Search.search(win, self)
      -- max results reached, so stop searching
      if not results then
        break
      end
      vim.list_extend(self.results, results)
    end
    table.sort(self.results, function(a, b)
      if a.win ~= b.win then
        return a.win < b.win
      end
      if a.from[1] ~= b.from[1] then
        return a.from[1] < b.from[1]
      end
      return a.from[2] < b.from[2]
    end)

    for m, match in ipairs(self.results) do
      if match.first and match.win == self.win then
        self.current = m
        break
      end
    end
  end

  if self.config.jump.auto_jump and #self.results == 1 then
    return self:jump()
  end

  if self.labels then
    self.labeler:update()
  end
  Highlight.update(self)
end

function M:clear()
  Highlight.clear()
end

return M
