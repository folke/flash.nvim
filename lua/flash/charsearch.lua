local State = require("flash.state")
local Util = require("flash.util")
local Repeat = require("flash.repeat")

local M = {}

M.motion = nil ---@type "t" | "T" | "f" | "F" | nil
M.char = nil ---@type string?
M.jumping = false
M.state = nil ---@type Flash.State?

---@type table<string, {forward:boolean, before:boolean}>
M.keys = {
  f = { forward = true, before = false },
  t = { forward = true, before = true },
  F = { forward = false, before = false },
  T = { forward = false, before = true },
  [";"] = { forward = true, before = false },
  [","] = { forward = false, before = false },
}

---@class Flash.CharSearchState : Flash.State
local S = setmetatable({}, State)
S.__index = S

function S.new()
  local self = State.new({
    jump = { auto_jump = false },
    search = {
      forward = M.keys[M.motion].forward,
      wrap = false,
      multi_window = false,
      abort_pattern = false,
      mode = "search",
    },
    highlight = {
      backdrop = true,
    },
  })
  setmetatable(self, S)

  if M.motion == "T" then
    -- set the label before the jump position
    self.opts.highlight.label.before = true
    self.opts.highlight.label.after = false
  elseif M.motion == "f" or M.motion == "F" then
    -- set the label at the jump position
    self.opts.highlight.label.after = { 0, 0 }
  end
  return self
end

-- Override search to set the correct pattern,
-- and set the label for each match to the character.
---@param char string
function S:search(char)
  local c = char:gsub("\\", "\\\\")
  local pattern ---@type string
  if M.motion == "t" then
    pattern = "\\m.\\ze\\V" .. c
  elseif M.motion == "T" then
    pattern = "\\V" .. c .. "\\zs\\m."
  else
    pattern = "\\V" .. c
  end
  State.search(self, pattern)
  for _, m in ipairs(self.results) do
    m.label = char
  end
end

function M.visible()
  return M.state and M.state.visible
end

function M.setup()
  for key in pairs(M.keys) do
    vim.keymap.set(
      { "n", "x", "o" },
      key,
      Repeat.wrap(function(is_repeat)
        if is_repeat and M.state then
          -- update the state and jump to the next match
          M.state:update()
          M.state:advance(vim.v.count1 - 1)
          M.state:jump()
          vim.schedule(function()
            -- update the state and show it
            M.state:update()
            M.state:show()
          end)
          return
        end
        M.jump(key)
      end),
      {
        silent = true,
        expr = true,
      }
    )
  end

  vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "InsertEnter" }, {
    callback = function()
      if not M.jumping and M.state then
        M.state:hide()
      end
    end,
  })

  vim.on_key(function(key)
    if M.state and key == Util.ESC and vim.fn.mode() == "n" then
      M.state:hide()
    end
  end)
end

function M.parse(key)
  -- repeat last search when hitting the same key
  if M.visible() and M.motion == key then
    key = ";"
  end

  -- different motion, clear the state
  if key:find("[ftFT]") and M.motion ~= key then
    if M.state then
      M.state:hide()
    end
    M.motion = key
  end

  return key
end

function M.jump(key)
  key = M.parse(key)

  if not M.motion then
    return
  end

  -- always re-calculate when not visible
  M.state = M.visible() and M.state or S.new()

  M.jumping = true

  -- get a new target
  if key:find("[ftFT]") or not M.char then
    M.char = Util.get_char()
    if not M.char then
      return M.state:hide()
    end
  end

  -- update the state when needed
  if M.state.pattern == "" then
    M.state:update({ search = M.char })
  end

  local count = vim.v.count1
  if key == "," then
    count = -count
    -- if we're at the first match, we show all matches
    -- in the buffer and wrap around
    if M.state:get().first then
      local at_current = M.state:at_current()
      M.state = S.new()
      M.state.opts.search.wrap = true
      M.state:update({ search = M.char })
      if at_current then
        count = count - 1
      end
    end
  -- if we're not on the current match, we need to advance one
  elseif not M.state:at_current() then
    count = count - 1
  end

  M.state:advance(count, { wrap = false })
  M.state:jump()

  vim.schedule(function()
    M.jumping = false
  end)
  return M.state
end

return M
