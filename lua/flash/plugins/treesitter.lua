local State = require("flash.state")
local Util = require("flash.util")

local M = {}

function M.matcher(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)

  -- get all ranges of the current node and its parents
  local ranges = {} ---@type TSNode[]
  local node = vim.treesitter.get_node()

  while node do
    local range = { node:range() }
    if not vim.deep_equal(range, ranges[#ranges]) then
      table.insert(ranges, range)
    end
    node = node:parent()
  end

  -- convert ranges to matches
  ---@type Flash.Match[]
  local ret = {}
  for _, range in ipairs(ranges) do
    ---@type Flash.Match
    local match = {
      pos = { range[1] + 1, range[2] },
      end_pos = { range[3] + 1, range[4] - 1 },
    }
    -- If the match is at the end of the buffer,
    -- then move it to the last character of the last line.
    if match.end_pos[1] > line_count then
      match.end_pos[1] = line_count
      match.end_pos[2] =
        #vim.api.nvim_buf_get_lines(buf, match.end_pos[1] - 1, match.end_pos[1], false)[1]
    end
    ret[#ret + 1] = match
  end
  return ret
end

M.state = nil
function M.jump()
  if M.state then
    M.state:hide()
    M.state = nil
  end

  M.state = State.new({
    matcher = M.matcher,
    labels = "abcdefghijklmnopqrstuvwxyz",
    search = { multi_window = false, wrap = true },
    jump = { pos = "range" },
    highlight = {
      backdrop = false,
      label = {
        current = true,
        before = true,
        after = true,
        style = "inline",
      },
      matches = false,
    },
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
      current = M.state:jump({ match = current, forward = false })
    elseif char == "," then
      current = M.state:jump({ forward = true, match = current })
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

return M
