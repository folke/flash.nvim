local State = require("flash.state")
local Util = require("flash.util")

local M = {}

M.state = nil
function M.jump()
  if M.state then
    M.state:hide()
    M.state = nil
  end

  M.state = State.new({
    search = { multi_window = true, wrap = true },
    highlight = { backdrop = true },
    matcher = function(win)
      return vim.tbl_map(function(jump)
        local pos = { jump.lnum, jump.col }
        return { pos = pos, end_pos = pos }
      end, vim.fn.getjumplist(win)[1])
    end,
  })

  local pos = vim.api.nvim_win_get_cursor(0)
  local current = M.state:jump("a")

  while true do
    local char = Util.get_char()
    if not char then
      vim.cmd([[normal! v]])
      vim.api.nvim_win_set_cursor(0, pos)
      break
    elseif char == ";" then
      current = M.state:jump({ match = current, forward = true })
    elseif char == "," then
      current = M.state:jump({ forward = false, match = current })
    elseif char == Util.CR then
      M.state:jump(current and current.label or nil)
      break
    else
      if not M.state:jump(char) then
        vim.api.nvim_input(char)
      end
      break
    end
  end
  M.state:hide()
end

M.jump()

return M
