local Repeat = require("flash.repeat")
local Util = require("flash.util")
local Config = require("flash.config")

local M = {}

---@param win window
---@param state Flash.State
function M.matcher(win, state)
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)

  -- get all ranges of the current node and its parents
  local ranges = {} ---@type TSNode[]

  local pos = win == state.win and state.pos or nil
  local node = vim.treesitter.get_node({
    bufnr = buf,
    pos = pos and { pos[1] - 1, pos[2] } or nil,
  })

  while node do
    local range = { node:range() }
    if not vim.deep_equal(range, ranges[#ranges]) then
      table.insert(ranges, range)
    end
    node = node:parent()
  end

  local labels = state:labels()

  -- convert ranges to matches
  ---@type Flash.Match[]
  local ret = {}
  local first = true
  for _, range in ipairs(ranges) do
    ---@type Flash.Match
    local match = {
      pos = { range[1] + 1, range[2] },
      end_pos = { range[3] + 1, range[4] - 1 },
      label = table.remove(labels, 1),
      first = first,
    }
    first = false
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

---@param opts? Flash.Config
function M.jump(opts)
  local state = Repeat.get_state(
    "treesitter",
    Config.get({ mode = "treesitter" }, opts, {
      matcher = M.matcher,
      labeler = function() end,
      search = { multi_window = false, wrap = true },
    })
  )

  local pos = vim.api.nvim_win_get_cursor(0)
  ---@type Flash.Match?
  local current
  for _, m in ipairs(state.results) do
    ---@cast m Flash.Match | {first?:boolean}
    if m.first then
      current = m
    end
  end
  current = state:jump(current)

  while true do
    local char = Util.get_char()
    if not char then
      vim.cmd([[normal! v]])
      vim.api.nvim_win_set_cursor(0, pos)
      break
    elseif char == ";" then
      current = state:jump({ match = current, forward = false })
    elseif char == "," then
      current = state:jump({ forward = true, match = current })
    elseif char == Util.CR then
      state:jump(current and current.label or nil)
      break
    else
      if not state:jump(char) then
        vim.api.nvim_input(char)
      end
      break
    end
  end
  state:hide()
  return state
end

return M
