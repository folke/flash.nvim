local require = require("flash.require")

local Config = require("flash.config")
local Highlight = require("flash.highlight")
local Jump = require("flash.jump")
local Matcher = require("flash.search.matcher")
local Search = require("flash.search")
local Cache = require("flash.cache")
local Hacks = require("flash.hacks")
local Pattern = require("flash.search.pattern")
local Util = require("flash.util")
local Prompt = require("flash.prompt")
local Rainbow = require("flash.rainbow")

---@class Flash.State.Config: Flash.Config
---@field matcher? fun(win: window, state:Flash.State, pos: {from:Pos, to:Pos}): Flash.Match[]
---@field pattern? string
---@field labeler? fun(matches:Flash.Match[], state:Flash.State)

---@class Flash.State
---@field win window
---@field wins window[]
---@field cache Flash.Cache
---@field pos Pos
---@field view any
---@field results Flash.Match[]
---@field target? Flash.Match
---@field pattern Flash.Pattern
---@field opts Flash.State.Config
---@field labeler fun(matches:Flash.Match[], state:Flash.State)
---@field visible boolean
---@field matcher fun(win: window, state:Flash.State): Flash.Matcher
---@field matchers Flash.Matcher[]
---@field restore_windows? fun()
---@field rainbow? Flash.Rainbow
---@field ns number
local M = {}
M.__index = M

---@type table<Flash.State, boolean>
M._states = setmetatable({}, { __mode = "k" })

function M.setup()
  if M._did_setup then
    return
  end
  M._did_setup = true
  local ns = vim.api.nvim_create_namespace("flash")
  vim.api.nvim_set_decoration_provider(ns, {
    on_start = function()
      for state in pairs(M._states) do
        if state.visible then
          local ok, err = pcall(state.update, state)
          if not ok then
            vim.schedule(function()
              vim.notify(
                "Flash error during redraw:\n" .. err,
                vim.log.levels.ERROR,
                { title = "flash.nvim" }
              )
            end)
          end
        end
      end
    end,
  })
end

function M:labels()
  local labels = self.opts.labels
  if self.opts.highlight.label.uppercase then
    labels = labels .. self.opts.labels:upper()
  end
  local list = vim.fn.split(labels, "\\zs")
  local ret = {} ---@type string[]
  local added = {} ---@type table<string, boolean>
  for _, l in ipairs(list) do
    if not added[l] then
      added[l] = true
      ret[#ret + 1] = l
    end
  end
  return ret
end

function M.is_search()
  local t = vim.fn.getcmdtype()
  return t == "/" or t == "?"
end

---@param opts? Flash.State.Config
function M.new(opts)
  M.setup()
  local self = setmetatable({}, M)
  self.opts = Config.get(opts)
  self.results = {}
  self.matchers = {}
  self.wins = {}
  self.matcher = self.opts.matcher
  if type(self.matcher) == "function" then
    self.matcher = Matcher.from(self.opts.matcher)
  elseif self.matcher == nil then
    self.matcher = Search.new
  end
  self.pattern = Pattern.new(self.opts.pattern, self.opts.search.mode, self.opts.search.trigger)
  self.visible = true
  self.cache = Cache.new(self)
  self.labeler = self.opts.labeler or require("flash.labeler").new(self):labeler()
  self.ns = vim.api.nvim_create_namespace(self.opts.ns or "flash")
  M._states[self] = true
  if self.opts.highlight.label.rainbow.enabled then
    self.rainbow = Rainbow.new(self)
  end
  self:update()
  return self
end

---@param target? string|Flash.Match.Find|Flash.Match
---@return Flash.Match?
function M:jump(target)
  local match ---@type Flash.Match?
  if type(target) == "string" then
    match = self:find({ label = target })
  elseif target and target.end_pos then
    match = target
  elseif target then
    match = self:find(target)
  else
    match = self.target
  end
  if match then
    if self.opts.action then
      self.opts.action(match, self)
    else
      Jump.jump(match, self)
      Jump.on_jump(self)
    end
    return match
  end
end

-- Will restore all window views
function M:restore()
  if self.restore_windows then
    self.restore_windows()
  end
end

function M:get_matcher(win)
  self.matchers[win] = self.matchers[win] or self.matcher(win, self)
  return self.matchers[win]
end

---@param opts? Flash.Match.Find | {label?:string, pos?: Pos}
function M:find(opts)
  if opts and opts.label then
    for _, m in ipairs(self.results) do
      if m.label == opts.label then
        return m
      end
    end
    return
  end

  opts = Matcher.defaults({
    forward = self.opts.search.forward,
    wrap = self.opts.search.wrap,
  }, opts)

  local matcher = self:get_matcher(self.win)
  local ret = matcher:find(opts)

  if ret then
    for _, m in ipairs(self.results) do
      if m.pos == ret.pos and m.end_pos == ret.end_pos then
        return m
      end
    end
  end
  return ret
end

-- Checks if the given pattern is a jump label and jumps to it.
---@param pattern string
function M:check_jump(pattern)
  if self.opts.search.trigger ~= "" and self.pattern():sub(-1) ~= self.opts.search.trigger then
    return
  end
  if
    pattern:find(self.pattern(), 1, true) == 1
    and vim.fn.strwidth(pattern) == vim.fn.strwidth(self.pattern()) + 1
  then
    local label = pattern:sub(-1)
    if self:jump(label) then
      return true
    end
  end
end

---@param opts? {pattern:string, force:boolean}
---@return boolean? abort `true` if the search was aborted
function M:update(opts)
  opts = opts or {}

  if opts.pattern then
    -- abort if pattern is a jump label
    if self:check_jump(opts.pattern) then
      return true
    end
    self.pattern:set(opts.pattern)
  end

  if not self.visible then
    return
  end

  if self.cache:update() or opts.force then
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
    -- force cache to update win and position
    self.win = nil
    self:update({ force = true })
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
    local state = self.cache:get_state(win)
    for _, m in ipairs(state and state.matches or {}) do
      local id = m.pos:id(buf) .. m.end_pos:id(buf)
      if not done[id] then
        done[id] = true
        table.insert(self.results, m)
      end
    end
  end
  self.matchers = matchers

  self:update_target()
  self.labeler(self.results, self)

  if M.is_search() then
    Hacks.restore_incsearch_state()
  end

  Highlight.update(self)
end

function M:update_target()
  -- set target to next match.
  -- When not using incremental search,
  -- we need to set the target to the previous match
  self.target = self:find({
    pos = self.pos,
    count = vim.v.count1,
  })

  local info = vim.fn.getwininfo(self.win)[1]
  local function is_visible()
    return self.target and self.target.pos[1] >= info.topline and self.target.pos[1] <= info.botline
  end

  if self.opts.search.incremental then
    -- only update cursor if the target is not visible
    -- and we are not activated
    if self.target and not self.is_search() then
      vim.api.nvim_win_set_cursor(self.win, self.target.pos)
    end
  elseif not is_visible() then
    self.target = self:find({
      pos = self.pos,
      count = vim.v.count1,
      forward = not self.opts.search.forward,
    })
    if not is_visible() then
      self.target = nil
    end
  end
end

function M:step()
  if self.opts.prompt.enabled and not M.is_search() then
    Prompt.set(self.pattern())
  end
  local c = Util.get_char()
  if c == nil then
    self:restore()
    return
    -- jump to first
  elseif c == Util.CR then
    self:jump()
    return
  end

  local orig = self.pattern()

  -- break if we jumped
  if self:update({ pattern = self.pattern:extend(c) }) then
    return
  end

  -- when we exceed max length, either jump to the label,
  -- or input the last key and break
  if self.opts.search.max_length and #self.pattern() > self.opts.search.max_length then
    self:update({ pattern = orig })
    self:jump()
    vim.api.nvim_input(c)
    return
  end

  -- exit if no results
  if #self.results == 0 and not self.pattern:empty() then
    return
  end

  -- autojump if only one result
  if #self.results == 1 and self.opts.jump.autojump then
    self:jump()
    return
  end
  return true
end

function M:loop()
  while self:step() do
  end
  self:hide()
  Prompt.hide()
end

return M
