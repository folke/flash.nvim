local State = require("flash.state")
local Util = require("flash.util")
local Repeat = require("flash.repeat")

local M = {}

M.last = {
  ---@type "t" | "T" | "f" | "F" | nil
  move = nil,
  ---@type string
  char = nil,
  ---@type Flash.Match?
  match = nil,
}
M.pending = false
---@type Flash.State?
M.state = nil

---@type table<string, {forward:boolean, before:boolean}>
M.keys = {
  f = { forward = true, before = false },
  t = { forward = true, before = true },
  F = { forward = false, before = false },
  T = { forward = false, before = true },
  [";"] = { forward = true, before = false },
  [","] = { forward = false, before = false },
}

function M.setup()
  for key in pairs(M.keys) do
    vim.keymap.set(
      { "n", "x", "o" },
      key,
      Repeat.wrap(function(is_repeat)
        M.jump(is_repeat and ";" or key)
      end),
      {
        silent = true,
        expr = true,
      }
    )
  end

  vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "InsertEnter" }, {
    callback = function(event)
      local pos = vim.api.nvim_win_get_cursor(0)

      if
        M.last.match
        and event.event == "CursorMoved"
        and vim.deep_equal(pos, M.last.match.from)
      then
        return
      end

      if not M.pending and M.state then
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

---@return boolean updated
function M.get_state()
  if M.state and M.state.visible then
    return false
  end

  local move = M.last.move
  M.state = State.new({
    jump = { auto_jump = false },
    search = {
      forward = M.keys[move].forward,
      wrap = false,
      multi_window = false,
      abort_pattern = false,
      mode = "search",
    },
    highlight = {
      backdrop = false,
    },
  })
  if move == "T" then
    -- set the label before the jump position
    M.state.opts.highlight.label.before = true
    M.state.opts.highlight.label.after = false
  elseif move == "f" or move == "F" then
    -- set the label at the jump position
    M.state.opts.highlight.label.after = { 0, 0 }
  end
  return true
end

function M.parse(key)
  -- repeat last search when hitting the same key
  if M.state and M.last.move == key and M.state.visible then
    key = ";"
  end

  local move = key
  if key == ";" or key == "," then
    move = M.last.move
  end

  if M.last.move ~= move and M.state then
    M.state:hide()
  end

  M.last.move = move
  return key
end

function M.search()
  local char = M.last.char:gsub("\\", "\\\\")
  local pattern ---@type string
  if M.last.move == "t" then
    pattern = "\\m.\\ze\\V" .. char
  elseif M.last.move == "T" then
    pattern = "\\V" .. char .. "\\zs\\m."
  else
    pattern = "\\V" .. char
  end

  M.state:search(pattern)
  for _, m in ipairs(M.state.results) do
    m.label = M.last.char
  end
end

function M.jump(key)
  key = M.parse(key)

  if not M.last.move then
    return
  end

  local updated = M.get_state()
  M.state:show()

  M.pending = true

  local count = vim.v.count1

  if key == ";" then
    count = vim.v.count1
  elseif key == "," then
    count = -vim.v.count1
  else
    count = count - 1
    M.last.char = Util.get_char()
    if not M.last.char then
      return M.state:hide()
    end
  end

  if updated then
    M.search()
  end

  M.state:advance(count)

  M.last.match = M.state:jump()
  M.state:update()
  M.pending = false
  return M.state
end

function M.clear()
  if M.state then
    M.state:hide()
    M.state = nil
  end
end

return M
