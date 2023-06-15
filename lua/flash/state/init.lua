local require = require("flash.require")

local Config = require("flash.config")
local Highlight = require("flash.highlight")
local Jump = require("flash.jump")
local Matcher = require("flash.matcher")
local Search = require("flash.search")
local View = require("flash.state.view")
local Hacks = require("flash.hacks")
local Pos = require("flash.search.pos")

---@class Flash.State.Config: Flash.Config
---@field matcher? fun(win: window, state:Flash.State): Flash.Match[]
---@field pattern? string
---@field labeler? fun(state:Flash.State)

---@class Flash.State
---@field win window
---@field wins window[]
---@field view Flash.State.View
---@field pos Pos
---@field results Flash.Match[]
---@field target? Flash.Match
---@field pattern string
---@field opts Flash.State.Config
---@field labeler fun(state:Flash.State)
---@field visible boolean
---@field matcher fun(win: window, state:Flash.State): Flash.Matcher
---@field matchers Flash.Matcher[]
---@field ns number
local M = {}
M.__index = M

---@type Flash.State[]
M._states = setmetatable({}, { __mode = "v" })

function M.setup()
  local ns = vim.api.nvim_create_namespace("flash")
  vim.api.nvim_set_decoration_provider(ns, {
    on_start = function()
      for _, state in ipairs(M._states) do
        local ok, err = pcall(state.update, state)
        if not ok then
          vim.schedule(function()
            vim.notify(err)
          end)
        end
      end
    end,
  })
end

function M.is_search()
  local t = vim.fn.getcmdtype()
  return t == "/" or t == "?"
end

---@param opts? Flash.State.Config
function M.new(opts)
  local self = setmetatable({}, M)
  self.opts = Config.get(opts)
  self.results = {}
  self.matchers = {}
  self.wins = {}
  self.matcher = self.opts.matcher and Matcher.from(self.opts.matcher) or Search.new
  self.pattern = self.opts.pattern or ""
  self.visible = true
  self.view = View.new(self)
  self.labeler = self.opts.labeler or require("flash.labeler").new(self):labeler()
  self.ns = vim.api.nvim_create_namespace(self.opts.ns or "flash")
  table.insert(M._states, self)
  self:update()
  return self
end

---@param match Flash.Match
---@protected
function M:_jump(match)
  Jump.jump(match, self)
  Jump.on_jump(self)
end

---@param target? string|Flash.Match.Find
---@return Flash.Match?
function M:jump(target)
  local match ---@type Flash.Match?
  if type(target) == "string" then
    match = self:find({ label = target })
  elseif target then
    match = self:find(target)
  else
    match = self.target
  end
  if match then
    self:_jump(match)
    return match
  end
end

function M:get_matcher(win)
  self.matchers[win] = self.matchers[win] or self.matcher(win, self)
  return self.matchers[win]
end

---@param opts? Flash.Match.Find | {label?:string, pos?: Pos}
function M:find(opts)
  opts = Matcher.defaults({
    forward = self.opts.search.forward,
    wrap = self.opts.search.wrap,
  }, opts)

  ---@cast opts Flash.Match.Find | {label?:string, pos?: Pos}
  if opts.label then
    for _, m in ipairs(self.results) do
      if m.label == opts.label then
        return m
      end
    end
    return
  end

  ---@cast opts Flash.Match.Find
  local matcher = self:get_matcher(self.win)
  local ret = matcher:find(opts)

  local info = vim.fn.getwininfo(self.win)[1]

  local function is_visible()
    return ret and ret.pos[1] >= info.topline and ret.pos[1] <= info.botline
  end

  if not self.opts.search.incremental and not is_visible() then
    opts.forward = not opts.forward
    ret = matcher:find(opts)
    return is_visible() and ret or nil
  end
  return ret
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

---@param opts? {search:string, force:boolean}
---@return boolean? abort `true` if the search was aborted
function M:update(opts)
  opts = opts or {}

  if opts.search then
    -- abort if pattern is a jump label
    if self:check_jump(opts.search) then
      return true
    end
    self.pattern = opts.search
  end

  if not self.visible then
    return
  end

  if self.view:update() or opts.force then
    self:_update()
  end
end

function M:hide()
  if self.visible then
    self.visible = false
    Highlight.clear(self.ns)
  end
end

function M:show()
  if not self.visible then
    self.visible = true
    self:update()
  end
end

function M:_update()
  -- This is needed because we trigger searches during redraw.
  -- We need to save the state of the incsearch so that current match
  -- will still be displayed correctly.
  if M.is_search() then
    Hacks.save_incsearch_state()
  end

  self.results = {}
  local done = {} ---@type table<string, boolean>
  ---@type Flash.Matcher[]
  local matchers = {}
  for _, win in ipairs(self.wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    matchers[win] = self:get_matcher(win)
    local state = self.view:get_state(win)
    for _, m in ipairs(state and state.matches or {}) do
      local id = m.pos:id(buf) .. m.end_pos:id(buf)
      if not done[id] then
        done[id] = true
        table.insert(self.results, m)
      end
    end
  end
  self.matchers = matchers
  self.target = self:find({ count = vim.v.count1 })
  self.labeler(self)

  if M.is_search() then
    Hacks.restore_incsearch_state()
  end

  Highlight.update(self)
end

return M
