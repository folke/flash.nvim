local require = require("flash.require")

local Util = require("flash.util")
local Repeat = require("flash.repeat")
local Config = require("flash.config")
local Labeler = require("flash.labeler")

local M = {}

---@alias Flash.Char.Motion "'f'" | "'F'" | "'t'" | "'T'"
M.motion = "f" ---@type Flash.Char.Motion
M.char = nil ---@type string?
M.jumping = false
M.state = nil ---@type Flash.State?
M.jump_labels = false

---@type table<Flash.Char.Motion, Flash.State.Config>
M.motions = {
  f = { label = { after = { 0, 0 }, before = false } },
  t = {},
  F = { search = { forward = false }, label = { after = { 0, 0 }, before = false } },
  T = { search = { forward = false }, label = { before = true, after = false } },
}

function M.new()
  local State = require("flash.state")
  local opts = Config.get({
    mode = "char",
    labeler = M.labeler,
    search = {
      multi_window = false,
      mode = M.mode(M.motion),
      max_length = 1,
    },
    prompt = {
      enabled = false,
    },
  }, M.motions[M.motion])

  -- never show the current match label
  opts.highlight.groups.current = M.motion:lower() == "f" and opts.highlight.groups.label
    or opts.highlight.groups.match

  -- exclude the motion labels so we can use them for next/prev
  opts.labels = opts.labels:gsub(M.motion:lower(), "")
  opts.labels = opts.labels:gsub(M.motion:upper(), "")
  return State.new(opts)
end

function M.labeler(matches, state)
  if M.jump_labels then
    if not state._labeler then
      state._labeler = Labeler.new(state)
    end
    state._labeler:update()
  else
    -- set to empty label, so that the character will just be highlighted
    for _, m in ipairs(matches) do
      m.label = ""
    end
  end
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

  local keys = {}

  for k, v in pairs(Config.modes.char.keys) do
    keys[type(k) == "number" and v or k] = v
  end

  for _, key in ipairs({ "f", "F", "t", "T", ";", "," }) do
    if keys[key] then
      vim.keymap.set({ "n", "x", "o" }, keys[key], function()
        M.jumping = true
        local autohide = Config.get("char").autohide
        if Repeat.is_repeat then
          M.jump_labels = false -- never show jump labels when repeating
          M.state:jump({ count = vim.v.count1 })
          M.state:show()
        else
          M.jump(key)
        end
        vim.schedule(function()
          M.jumping = false
          if M.state and autohide then
            M.state:hide()
          end
        end)
      end, {
        silent = true,
      })
    end
  end

  vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "InsertEnter" }, {
    group = vim.api.nvim_create_augroup("flash_char", { clear = true }),
    callback = function(event)
      local hide = event.event == "InsertEnter" or not M.jumping
      if hide and M.state then
        M.state:hide()
      end
    end,
  })

  vim.on_key(function(key)
    if M.state and key == Util.ESC and (vim.fn.mode() == "n" or vim.fn.mode() == "v") then
      M.state:hide()
    end
  end)
end

function M.parse(key)
  -- repeat last search when hitting the same key
  -- don't repeat when executing a macro
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

  local is_op = vim.fn.mode(true):sub(1, 2) == "no"

  -- always re-calculate when not visible
  M.state = M.visible() and M.state or M.new()

  -- get a new target
  if M.motions[key] or not M.char then
    local char = M.state:get_char()
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

  local jump = key == "," and M.prev or M.next

  M.jump_labels = Config.get("char").jump_labels
  jump()
  M.state:update({ force = true })

  if M.jump_labels then
    M.state:loop({
      restore = is_op,
      jump_on_max_length = false,
      actions = {
        [Util.CR] = function()
          return false
        end,
        [";"] = M.next,
        [","] = M.prev,
        [M.motion:lower()] = M.next,
        [M.motion:upper()] = M.prev,
      },
    })
  end

  return M.state
end

function M.next()
  M.state:jump({ count = vim.v.count1, forward = M.state.opts.search.forward })
  return true
end

function M.prev()
  M.state:jump({ count = vim.v.count1, forward = not M.state.opts.search.forward })
  -- check if we should enable wrapping.
  if not M.state.opts.search.wrap then
    local before = M.state:find({ count = 1, forward = false })
    if before and (before.pos < M.state.pos) == M.state.opts.search.forward then
      M.state.opts.search.wrap = true
      M.state._labeler = nil
      M.state:update({ force = true })
    end
  end
  return true
end

return M
