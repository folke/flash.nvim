local require = require("flash.require")

local Config = require("flash.config")
local Labeler = require("flash.labeler")
local Repeat = require("flash.repeat")
local Util = require("flash.util")

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
  F = {
    jump = { inclusive = false },
    search = { forward = false },
    label = { after = { 0, 0 }, before = false },
  },
  T = {
    jump = { inclusive = false },
    search = { forward = false },
    label = { before = true, after = false },
  },
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

---@param motion Flash.Char.Motion
function M.mode(motion)
  ---@param c string
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
    if not Config.get("char").multi_line then
      local pos = vim.api.nvim_win_get_cursor(0)
      pattern = ("\\%%%dl"):format(pos[1]) .. pattern
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
    if vim.g.mapleader ~= v and vim.g.maplocalleader ~= v then
      keys[type(k) == "number" and v or k] = v
    end
  end

  -- don't override ;, mappings if they exist
  for _, key in ipairs({ ";", "," }) do
    local mapping = vim.fn.maparg(key, "n", false, false)
    if keys[key] == key and mapping ~= "" then
      keys[key] = nil
    end
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
  ---@class Flash.Char.Parse
  local ret = {
    jump = M.next,
    actions = {}, ---@type table<string, fun()>
    getchar = false,
  }
  -- repeat last search when hitting the same key
  -- don't repeat when executing a macro
  if M.visible() and vim.fn.reg_executing() == "" and M.motion:lower() == key:lower() then
    ret.actions = M.actions(M.motion)
    if ret.actions[key] then
      ret.jump = ret.actions[key]
      return ret
    else
      -- no action defined, so clear the state
      M.motion = ""
    end
  end

  -- different motion, clear the state
  if M.motions[key] and M.motion ~= key then
    if M.state then
      M.state:hide()
    end
    M.motion = key
  end

  ret.actions = M.actions(M.motion)

  if M.motions[key] then
    ret.getchar = true
  else -- ;,
    ret.jump = ret.actions[key] or M.next
  end

  return ret
end

---@param motion Flash.Char.Motion
---@return table<string, fun()>
function M.actions(motion)
  local ret = Config.get("char").char_actions(motion)
  for key, value in pairs(ret) do
    ret[key] = M[value]
  end
  return ret
end

function M.jump(key)
  local parsed = M.parse(key)
  if not M.motion then
    return
  end

  local is_op = vim.fn.mode(true):sub(1, 2) == "no"

  -- always re-calculate when not visible
  M.state = M.visible() and M.state or M.new()

  -- get a new target
  if parsed.getchar or not M.char then
    local char = M.state:get_char()
    if char then
      M.char = char
    else
      return M.state:hide()
    end
  end

  -- HACK: When the motion is t or T, we need to set the current position as a valid target
  -- but only when we are not repeating
  M.current = M.motion:lower() == "t" and parsed.getchar

  -- update the state when needed
  if M.state.pattern:empty() then
    M.state:update({ pattern = M.char })
  end

  local jump = parsed.jump

  M.jump_labels = Config.get("char").jump_labels
  jump()
  M.state:update({ force = true })

  if M.jump_labels then
    parsed.actions[Util.CR] = function()
      return false
    end
    M.state:loop({
      restore = is_op,
      abort = function()
        Util.exit()
      end,
      jump_on_max_length = false,
      actions = parsed.actions,
    })
  end

  return M.state
end

M.current = false

function M.right()
  return M.state.opts.search.forward and M.next() or M.prev()
end

function M.left()
  return M.state.opts.search.forward and M.prev() or M.next()
end

function M.next()
  M.state:jump({
    count = vim.v.count1,
    forward = M.state.opts.search.forward,
    current = M.current,
  })
  M.current = false
  return true
end

function M.prev()
  M.state:jump({
    count = vim.v.count1,
    forward = not M.state.opts.search.forward,
    current = M.current,
  })
  M.current = false
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
