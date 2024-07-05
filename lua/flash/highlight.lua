local M = {}

function M.clear(ns)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

function M.setup()
  if vim.g.vscode then
    local hls = {
      FlashBackdrop = { fg = "#545c7e" },
      FlashCurrent = { bg = "#ff966c", fg = "#1b1d2b" },
      FlashLabel = { bg = "#ff007c", bold = true, fg = "#c8d3f5" },
      FlashMatch = { bg = "#3e68d7", fg = "#c8d3f5" },
      FlashCursor = { reverse = true },
    }
    for hl_group, hl in pairs(hls) do
      hl.default = true
      vim.api.nvim_set_hl(0, hl_group, hl)
    end
  else
    local links = {
      FlashBackdrop = "Comment",
      FlashMatch = "Search",
      FlashCurrent = "IncSearch",
      FlashLabel = "Substitute",
      FlashPrompt = "MsgArea",
      FlashPromptIcon = "Special",
      FlashCursor = "Cursor",
    }
    for hl_group, link in pairs(links) do
      vim.api.nvim_set_hl(0, hl_group, { link = link, default = true })
    end
  end
end
M.setup()

---@param state Flash.State
function M.backdrop(state)
  for _, win in ipairs(state.wins) do
    local info = vim.fn.getwininfo(win)[1]
    local buf = vim.api.nvim_win_get_buf(win)
    local from = { info.topline, 0 }
    local to = { info.botline + 1, 0 }
    if state.win == win and not state.opts.search.wrap then
      if state.opts.search.forward then
        from = { state.pos[1], state.pos[2] + 1 }
      else
        to = state.pos
      end
    end
    -- we need to create a backdrop for each line because of the way
    -- extmarks priority rendering works
    for line = from[1], to[1] do
      vim.api.nvim_buf_set_extmark(buf, state.ns, line - 1, line == from[1] and from[2] or 0, {
        hl_group = state.opts.highlight.groups.backdrop,
        end_row = line == to[1] and line - 1 or line,
        hl_eol = line ~= to[1],
        end_col = line == to[1] and to[2] or from[2],
        priority = state.opts.highlight.priority,
        strict = false,
      })
    end
  end
end

---@param state Flash.State
function M.cursor(state)
  for _, win in ipairs(state.wins) do
    if vim.api.nvim__redraw then
      vim.api.nvim__redraw({ cursor = true, win = win })
    else
      local cursor = vim.api.nvim_win_get_cursor(win)
      local buf = vim.api.nvim_win_get_buf(win)
      vim.api.nvim_buf_set_extmark(buf, state.ns, cursor[1] - 1, cursor[2], {
        hl_group = "FlashCursor",
        end_col = cursor[2] + 1,
        priority = state.opts.highlight.priority + 3,
        strict = false,
      })
    end
  end
end

---@param state Flash.State
function M.update(state)
  M.clear(state.ns)

  if state.opts.highlight.backdrop then
    M.backdrop(state)
  end

  local style = state.opts.label.style
  if style == "inline" and vim.fn.has("nvim-0.10.0") == 0 then
    style = "overlay"
  end

  local after = state.opts.label.after
  after = after == true and { 0, 1 } or after
  ---@cast after number[]
  local before = state.opts.label.before
  before = before == true and { 0, -1 } or before
  ---@cast before number[]

  if style == "inline" and before then
    before[2] = before[2] + 1
  end

  local target = state.target

  ---@type table<string, {buf: number, row: number, col: number, text:string[][]}>
  local extmarks = {}

  ---@param match Flash.Match
  ---@param pos number[]
  ---@param offset number[]
  ---@param is_after boolean
  local function label(match, pos, offset, is_after)
    local buf = vim.api.nvim_win_get_buf(match.win)
    local cursor = vim.api.nvim_win_get_cursor(match.win)
    local pos2 = require("flash.util").offset_pos(buf, pos, offset)
    local row, col = pos2[1] - 1, pos2[2]
    -- dont show the label if the cursor is on the same position
    -- in the same window
    -- and the label is not a range
    if cursor[1] == row + 1 and cursor[2] == col and match.win == state.win and state.opts.jump.pos ~= "range" then
      return
    end
    if match.fold then
      -- set the row to the fold start
      row = match.fold - 1
      col = 0
    end

    local hl_group = state.opts.highlight.groups.label
    if state.rainbow then
      hl_group = state.rainbow:get(match)
    elseif
      -- set hl_group to current if the match is the current target
      -- and the target is a single character
      target
      and target.pos[1] == row + 1
      and target.pos[2] == col
      and target.pos == target.end_pos
    then
      hl_group = state.opts.highlight.groups.current
    end
    if match.label == "" then
      -- when empty label, highlight the position
      vim.api.nvim_buf_set_extmark(buf, state.ns, row, col, {
        hl_group = hl_group,
        end_row = row,
        end_col = col + 1,
        strict = false,
        priority = state.opts.highlight.priority + 2,
      })
    else
      -- else highlight the label
      local key = buf .. ":" .. row .. ":" .. col
      extmarks[key] = extmarks[key] or { buf = buf, row = row, col = col, text = {} }
      local text = state.opts.label.format({
        state = state,
        match = match,
        hl_group = hl_group,
        after = is_after,
      })
      for i = #text, 1, -1 do
        table.insert(extmarks[key].text, 1, text[i])
      end
    end
  end

  for _, match in ipairs(state.results) do
    local buf = vim.api.nvim_win_get_buf(match.win)

    local highlight = state.opts.highlight.matches
    if match.highlight ~= nil then
      highlight = match.highlight
    end

    if highlight then
      vim.api.nvim_buf_set_extmark(buf, state.ns, match.pos[1] - 1, match.pos[2], {
        end_row = match.end_pos[1] - 1,
        end_col = match.end_pos[2] + 1,
        hl_group = target and match.pos == target.pos and state.opts.highlight.groups.current
          or state.opts.highlight.groups.match,
        strict = false,
        priority = state.opts.highlight.priority + 1,
      })
    end
  end

  for _, match in ipairs(state.results) do
    if match.label and after then
      label(match, match.end_pos, after, true)
    end
    if match.label and before then
      label(match, match.pos, before, false)
    end
  end

  for _, extmark in pairs(extmarks) do
    vim.api.nvim_buf_set_extmark(extmark.buf, state.ns, extmark.row, extmark.col, {
      virt_text = extmark.text,
      virt_text_pos = style,
      strict = false,
      priority = state.opts.highlight.priority + 2,
    })
  end

  M.cursor(state)
end

return M
