local M = {}

M.ns = vim.api.nvim_create_namespace("flash")

function M.clear()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
  end
end

function M.setup()
  vim.api.nvim_set_hl(0, "FlashBackdrop", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "FlashMatch", { link = "Search", default = true })
  vim.api.nvim_set_hl(0, "FlashCurrent", { link = "IncSearch", default = true })
  vim.api.nvim_set_hl(0, "FlashLabel", { link = "Substitute", default = true })
end

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
      vim.api.nvim_buf_set_extmark(buf, M.ns, line - 1, line == from[1] and from[2] or 0, {
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
function M.update(state)
  M.clear()

  if state.opts.highlight.backdrop then
    M.backdrop(state)
  end

  local style = state.opts.highlight.label.style
  if style == "inline" and vim.fn.has("nvim-0.10.0") == 0 then
    style = "overlay"
  end

  local after = state.opts.highlight.label.after
  after = after == true and { 0, 1 } or after
  local before = state.opts.highlight.label.before
  before = before == true and { 0, -1 } or before

  if style == "inline" and before then
    before[2] = before[2] + 1
  end

  ---@param match Flash.Match
  ---@param pos number[]
  ---@param offset number[]
  local function label(match, pos, offset)
    local buf = vim.api.nvim_win_get_buf(match.win)
    local row = pos[1] - 1 + offset[1]
    local col = pos[2] + offset[2]
    vim.api.nvim_buf_set_extmark(buf, M.ns, row, col, {
      virt_text = { { match.label, state.opts.highlight.groups.label } },
      virt_text_pos = style,
      strict = false,
      priority = state.opts.highlight.priority + 2,
    })
  end

  for m, match in ipairs(state.results) do
    local buf = vim.api.nvim_win_get_buf(match.win)

    if state.opts.highlight.matches then
      vim.api.nvim_buf_set_extmark(buf, M.ns, match.from[1] - 1, match.from[2], {
        end_row = match.to[1] - 1,
        end_col = match.to[2] + 1,
        hl_group = state.current == m and state.opts.highlight.groups.current
          or state.opts.highlight.groups.match,
        strict = false,
        priority = state.opts.highlight.priority + 1,
      })
    end

    if match.label then
      if after then
        label(match, match.to, after)
      end
      if before then
        label(match, match.from, before)
      end
    end
  end
end

return M
