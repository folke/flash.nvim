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

---@param opts? {win:number, op:boolean, config:Flash.Config, wrap:boolean}
function M.new(opts)
  opts = opts or {}
  local self = setmetatable({}, { __index = M })
  self.config = Config.get(opts.config)
  self.op = opts.op or false
  self.win = opts.win or vim.api.nvim_get_current_win()
  self.buf = vim.api.nvim_win_get_buf(self.win)
  self.pos = vim.api.nvim_win_get_cursor(self.win)
  self.mode = opts.mode or vim.api.nvim_get_mode().mode
  self.results = {}
  self.wins = {}
  self.pattern = ""
  self:update("")
  return self
end

function M:jump(label)
  local Jump = require("flash.jump")
  if Jump.jump(label, self) then
    return true
  end
end

---@param pattern string?
function M:update(pattern)
  pattern = pattern or self.pattern or ""

  if pattern:match(self.config.search.abort_pattern) then
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
  end

  if self.config.jump.auto_jump and #self.results == 1 then
    return self:jump(true)
  end

  local Jump = require("flash.jump")
  Jump.update(self)
  Highlight.update(self)
  vim.cmd.redraw()
end

function M:clear()
  Highlight.clear()
end

return M
