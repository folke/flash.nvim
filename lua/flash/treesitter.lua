local State = require("flash.state")
local Util = require("flash.util")

local M = {}

function M.get_nodes()
  local win = vim.api.nvim_get_current_win()
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
      win = win,
      from = { range[1] + 1, range[2] },
      to = { range[3] + 1, range[4] - 1 },
    }
    -- If the match is at the end of the buffer,
    -- then move it to the last character of the last line.
    if match.to[1] > line_count then
      match.to[1] = line_count
      match.to[2] = #vim.api.nvim_buf_get_lines(buf, match.to[1] - 1, match.to[1], false)[1]
    end
    ret[#ret + 1] = match
  end
  return ret
end

M.state = nil
function M.jump()
  if M.state then
    M.state:clear()
    M.state = nil
  end

  M.state = State.new({
    config = {
      labels = "abcdefghijklmnopqrstuvwxyz",
      search = { multi_window = false },
      jump = { auto_jump = false, pos = "range" },
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
    },
  })

  M.state:set(M.get_nodes(), { sort = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  M.state:jump()

  M.state:update()

  while true do
    local char = Util.get_char()
    if not char then
      vim.cmd([[normal! v]])
      vim.api.nvim_win_set_cursor(0, pos)
      break
    elseif char == ";" then
      M.state:next()
    elseif char == "," then
      M.state:prev()
    elseif char == Util.CR then
      M.state:jump()
      break
    else
      if not M.state:jump(char) then
        vim.api.nvim_input(char)
      end
      break
    end
    M.state:jump()
    M.state:highlight()
  end
  M.state:clear()
end

return M
