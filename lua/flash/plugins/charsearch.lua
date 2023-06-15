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

function M.new()
  local self
  self = State.new({
    labeler = function(state)
      -- set to empty label, so that the character will just be highlighted
      for _, m in ipairs(state.results) do
        m.label = ""
      end
    end,
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
    jump = {
      register = false,
    },
  })

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

function M.pattern()
  local c = M.char:gsub("\\", "\\\\")
  local pattern ---@type string
  if M.motion == "t" then
    pattern = "\\m.\\ze\\V" .. c
  elseif M.motion == "T" then
    pattern = "\\V" .. c .. "\\zs\\m."
  else
    pattern = "\\V" .. c
  end
  return pattern
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
          M.jumping = true
          M.state:jump()
          vim.schedule(function()
            M.jumping = false
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
  M.state = M.visible() and M.state or M.new()

  M.jumping = true

  -- get a new target
  if key:find("[ftFT]") or not M.char then
    local char = Util.get_char()
    if char then
      M.char = char
    else
      return M.state:hide()
    end
  end

  -- update the state when needed
  if M.state.pattern == "" then
    M.state:update({ search = M.pattern() })
  end

  local count = vim.v.count1
  local forward = M.keys[M.motion].forward
  if key == "," then
    forward = not forward

    -- check if we should enable wrapping.
    if not M.state.opts.search.wrap then
      local before = M.state:find({ count = 1, forward = forward })
      if before and (before.pos < M.state.pos) == M.state.opts.search.forward then
        M.state.opts.search.wrap = true
        M.state:update({ force = true })
      end
    end
  end

  M.state:jump({ count = count, forward = forward })

  vim.schedule(function()
    M.jumping = false
  end)
  return M.state
end

return M
