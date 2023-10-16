local Hacks = require("flash.hacks")
local require = require("flash.require")

local M = {}

function M.t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

M.CR = M.t("<cr>")
M.ESC = M.t("<esc>")
M.BS = M.t("<bs>")
M.EXIT = M.t("<C-\\><C-n>")
M.LUA_CALLBACK = "\x80\253g"
M.CMD = "\x80\253h"

function M.exit()
  vim.api.nvim_feedkeys(M.EXIT, "nx", false)
  vim.api.nvim_feedkeys(M.ESC, "n", false)
end

---@param buf number
---@param pos number[] (1,0)-indexed position
---@param offset number[]
---@return number[] (1,0)-indexed position
function M.offset_pos(buf, pos, offset)
  local row = pos[1] + offset[1]
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, row - 1, row, true)
  if not ok or lines == nil then
    -- fallback to old behavior if anything wrong happens
    return { row, math.max(pos[2] + offset[2], 0) }
  end

  local line = lines[1]
  local charidx = vim.fn.charidx(line, pos[2])
  local col = vim.fn.byteidx(line, charidx + offset[2])

  return { row, math.max(col, 0) }
end

function M.get_char()
  Hacks.setcursor()
  vim.cmd("redraw")
  local ok, ret = pcall(vim.fn.getcharstr)
  return ok and ret ~= M.ESC and ret or nil
end

function M.layout_wins()
  local queue = { vim.fn.winlayout() }
  ---@type table<window, window>
  local wins = {}
  while #queue > 0 do
    local node = table.remove(queue)
    if node[1] == "leaf" then
      wins[node[2]] = node[2]
    else
      vim.list_extend(queue, node[2])
    end
  end
  return wins
end

function M.save_layout()
  local current_win = vim.api.nvim_get_current_win()
  local wins = M.layout_wins()
  ---@type table<window, table>
  local state = {}
  for _, win in pairs(wins) do
    state[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  end
  return function()
    for win, s in pairs(state) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        -- never restore terminal buffers to prevent flickering
        if vim.bo[buf].buftype ~= "terminal" then
          pcall(vim.api.nvim_win_call, win, function()
            vim.fn.winrestview(s)
          end)
        end
      end
    end
    vim.api.nvim_set_current_win(current_win)
    state = {}
  end
end

---@param done fun():boolean
---@param on_done fun()
function M.on_done(done, on_done)
  local check = assert(vim.loop.new_check())
  local fn = function()
    if check:is_closing() then
      return
    end
    if done() then
      check:stop()
      check:close()
      on_done()
    end
  end
  check:start(vim.schedule_wrap(fn))
end

return M
