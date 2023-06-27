local require = require("flash.require")

local Util = require("flash.util")
local Repeat = require("flash.repeat")
local Config = require("flash.config")

local M = {}

---@alias Flash.Char.Motion "'f'" | "'F'" | "'t'" | "'T'"
M.motion = nil ---@type Flash.Char.Motion?
M.char = nil ---@type string?
M.jumping = false
M.state = nil ---@type Flash.State?

---@type table<Flash.Char.Motion, Flash.State.Config>
M.motions = {
  f = { highlight = { label = { after = { 0, 0 }, before = false } } },
  t = {},
  F = { search = { forward = false }, highlight = { label = { after = { 0, 0 }, before = false } } },
  T = { search = { forward = false }, highlight = { label = { before = true, after = false } } },
}

function M.new()
  local State = require("flash.state")
  return State.new(Config.get({
    mode = "char",
    labeler = function(matches)
      -- set to empty label, so that the character will just be highlighted
      for _, m in ipairs(matches) do
        m.label = ""
      end
    end,
    search = {
      multi_window = false,
      mode = M.mode(M.motion),
    },
  }, M.motions[M.motion]))
end

function M.mode(motion)
  return function(c)
    c = c:gsub("\\", "\\\\")
    local pattern ---@type string
    if motion == "t" then
      pattern = "\\m.\\ze\\V" .. c
    elseif motion == "T" then
      pattern = "\\V" .. c .. "\\zs\\m."
    else
      pattern = "\\V" .. c
    end
    return pattern
  end
end

function M.visible()
  return M.state and M.state.visible
end

function M.setup()
  Repeat.setup()

  for _, key in ipairs({ "f", "F", "t", "T", ";", "," }) do
    if vim.tbl_contains(Config.modes.char.keys, key) then
      vim.keymap.set({ "n", "x", "o" }, key, function()
        if Repeat.is_repeat then
          M.jumping = true
          M.state:jump({ count = vim.v.count1 })
          M.state:show()
          vim.schedule(function()
            M.jumping = false
          end)
        else
          M.jump(key)
        end
      end, {
        silent = true,
      })
    end
  end

  vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "InsertEnter" }, {
    group = vim.api.nvim_create_augroup("flash_char", { clear = true }),
    callback = function(event)
      if (event.event == "InsertEnter" or not M.jumping) and M.state then
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
  if M.visible() and vim.fn.reg_executing() == "" then
    if M.motion:lower() == key then
      key = ";"
    elseif M.motion:upper() == key then
      key = ","
    end
  end
  -- different motion, clear the state
  if M.motions[key] and M.motion ~= key then
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
  if M.motions[key] or not M.char then
    local char = Util.get_char()
    if char then
      M.char = char
    else
      return M.state:hide()
    end
  end

  -- update the state when needed
  if M.state.pattern:empty() then
    M.state:update({ pattern = M.char })
  end

  local forward = M.state.opts.search.forward
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

  M.state:jump({ count = vim.v.count1, forward = forward })

  vim.schedule(function()
    M.jumping = false
  end)
  return M.state
end

return M
