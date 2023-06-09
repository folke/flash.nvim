local State = require("flash.state")

local M = {}

---@class CharSearch
---@field char string
---@field forward boolean
---@field before boolean

M.timer = assert(vim.loop.new_timer(), "failed to create timer")
M.last = {
  ---@type string
  key = nil,
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

---@param move string
---@return Flash.State state, boolean is_new
function M.get_state(move)
  if M.state and M.last.key == move then
    return M.state, false
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
  return M.state, true
end

function M.jump(key)
  -- repeat last search when hitting the same key
  if M.state and M.last.key == key then
    key = ";"
  end

  local is_repeat = key == ";" or key == ","

  if is_repeat and not M.last.key then
    return
  end

  local move = is_repeat and M.last.key or key

  local _, needs_update = M.get_state(move)

  M.last.key = move
  M.pending = true

  local count = vim.v.count == 0 and 1 or vim.v.count

  if key == ";" then
    count = count
  elseif key == "," then
    count = -count
  else
    vim.cmd.redraw()
    local ok, c = pcall(vim.fn.getchar)
    if ok and type(c) == "number" then
      M.last.char = vim.fn.nr2char(c)
    else
      return M.clear()
    end
  end

  if needs_update then
    local char = M.last.char:gsub("\\", "\\\\")
    local pattern
    if move == "t" then
      pattern = "\\m.\\ze\\V" .. char
    elseif move == "T" then
      pattern = "\\V" .. char .. "\\zs\\m."
    else
      pattern = "\\V" .. char
    end

    M.state:update(pattern)
    if M.keys[move].before then
      for _, m in ipairs(M.state.results) do
        m.label = M.last.char
      end
    end
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
