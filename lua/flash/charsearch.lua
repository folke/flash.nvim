local State = require("flash.state")

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
    vim.keymap.set({ "n", "x", "o" }, key, function()
      return M.jump(key)
    end, {
      silent = true,
      noremap = true,
    })
  end

  vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "ModeChanged" }, {
    callback = function(event)
      local pos = vim.api.nvim_win_get_cursor(0)

      if M.last.match and event.event == "CursorMoved" and vim.deep_equal(pos, M.last.match.from) then
        return
      end

      if not M.pending then
        M.clear()
      end
    end,
  })
end

---@return boolean updated
function M.get_state()
  local move = M.last.move
  if M.state and M.last.move == move then
    return false
  end

  M.state = State.new({
    labels = M.keys[move].before,
    config = {
      jump = { auto_jump = false },
      search = {
        forward = M.keys[move].forward,
        wrap = false,
        multi_window = false,
        abort_pattern = false,
        regex = true,
      },
      highlight = {
        groups = {
          match = not M.keys[move].before and "FlashLabel" or nil,
        },
        backdrop = false,
      },
    },
  })
  if move == "T" then
    M.state.config.highlight.label_before = true
    M.state.config.highlight.label_after = false
  end
  return true
end

function M.parse(key)
  -- repeat last search when hitting the same key
  if M.state and M.last.move == key then
    key = ";"
  end

  local move = key
  if key == ";" or key == "," then
    move = M.last.move
  end
  M.last.move = move
  return key
end

function M.get_char()
  vim.cmd.redraw()
  local ok, c = pcall(vim.fn.getchar)
  M.last.char = ok and type(c) == "number" and vim.fn.nr2char(c) or nil
  return M.last.char
end

function M.search()
  local char = M.last.char:gsub("\\", "\\\\")
  local pattern
  if M.last.move == "t" then
    pattern = "\\m.\\ze\\V" .. char
  elseif M.last.move == "T" then
    pattern = "\\V" .. char .. "\\zs\\m."
  else
    pattern = "\\V" .. char
  end

  M.state:update(pattern)
  if M.keys[M.last.move].before then
    for _, m in ipairs(M.state.results) do
      m.label = M.last.char
    end
  end
end

function M.jump(key)
  key = M.parse(key)

  if not M.last.move then
    return
  end

  local updated = M.get_state()

  M.pending = true

  local count = vim.v.count == 0 and 1 or vim.v.count

  if key == ";" then
    count = count
  elseif key == "," then
    count = -count
  elseif not M.get_char() then
    return M.clear()
  end

  if updated then
    M.search()
    count = count - 1
  end

  M.state:advance(count)
  M.last.match = M.state:jump()
  require("flash.highlight").update(M.state)
  M.pending = false
end

function M.clear()
  if M.state then
    M.state:clear()
    M.state = nil
  end
end

return M
