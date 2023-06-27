local Repeat = require("flash.repeat")
local Util = require("flash.util")
local Config = require("flash.config")
local Pos = require("flash.search.pos")

local M = {}

---@param win window
---@param pos? Pos
function M.get_nodes(win, pos)
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)

  -- get all ranges of the current node and its parents
  local ranges = {} ---@type TSNode[]

  local node = vim.treesitter.get_node({
    bufnr = buf,
    pos = pos and { pos[1] - 1, pos[2] } or nil,
  })

  while node do
    local range = { node:range() }
    table.insert(ranges, range)
    node = node:parent()
  end

  -- convert ranges to matches
  ---@type Flash.Match[]
  local ret = {}
  local first = true
  ---@type table<string,boolean>
  local done = {}
  for _, range in ipairs(ranges) do
    ---@type Flash.Match
    local match = {
      pos = { range[1] + 1, range[2] },
      end_pos = { range[3] + 1, range[4] - 1 },
      first = first,
    }
    first = false
    -- If the match is at the end of the buffer,
    -- then move it to the last character of the last line.
    if match.end_pos[1] > line_count then
      match.end_pos[1] = line_count
      match.end_pos[2] =
        #vim.api.nvim_buf_get_lines(buf, match.end_pos[1] - 1, match.end_pos[1], false)[1]
    elseif match.end_pos[2] == -1 then
      -- If the end points to the start of the next line, move it to the
      -- end of the previous line.
      -- Otherwise operations include the first character of the next line
      local line =
        vim.api.nvim_buf_get_lines(buf, match.end_pos[1] - 2, match.end_pos[1] - 1, false)[1]
      match.end_pos[1] = match.end_pos[1] - 1
      match.end_pos[2] = #line
    end
    local id = table.concat({ unpack(match.pos), unpack(match.end_pos) }, ".")
    if not done[id] then
      done[id] = true
      ret[#ret + 1] = match
    end
  end

  for m, match in ipairs(ret) do
    match.pos = Pos(match.pos)
    match.end_pos = Pos(match.end_pos)
    match.win = win
    match.depth = #ret - m
  end
  return ret
end

---@param win window
---@param state Flash.State
function M.matcher(win, state)
  local labels = state:labels()
  local ret = M.get_nodes(win, state.pos)

  for i = 1, #ret do
    ret[i].label = table.remove(labels, 1)
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
      search = { multi_window = false, wrap = true, incremental = false },
    })
  )

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
      state:restore()
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

---@param opts? Flash.Config
function M.search(opts)
  local state = Repeat.get_state(
    "treesitter-search",
    Config.get({ mode = "treesitter_search" }, opts, {
      matcher = function(win, _state, _opts)
        local Search = require("flash.search")
        local search = Search.new(win, _state)
        local matches = {} ---@type Flash.Match[]
        for _, m in ipairs(search:get(_opts)) do
          -- don't add labels to the search results
          m.label = false
          table.insert(matches, m)
          for _, n in ipairs(M.get_nodes(win, m.pos)) do
            -- don't highlight treesitter nodes. Use labels only
            n.highlight = false
            table.insert(matches, n)
          end
        end
        return matches
      end,
      jump = { pos = "range" },
    })
  )
  state:loop()
  return state
end

return M
