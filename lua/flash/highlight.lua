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
    local cursor = vim.api.nvim_win_get_cursor(win)
    local buf = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_buf_set_extmark(buf, state.ns, cursor[1] - 1, cursor[2], {
      hl_group = "Cursor",
      end_col = cursor[2] + 1,
      priority = state.opts.highlight.priority + 1,
      strict = false,
    })
  end
end

---@param state Flash.State
function M.update(state)
  local Rainbow = require("flash.rainbow")
  M.clear(state.ns)

  M.cursor(state)

  if state.opts.highlight.backdrop then
    M.backdrop(state)
  end

  local style = state.opts.highlight.label.style
  if style == "inline" and vim.fn.has("nvim-0.10.0") == 0 then
    style = "overlay"
  end

  local after = state.opts.highlight.label.after
  after = after == true and { 0, 1 } or after
  ---@cast after number[]
  local before = state.opts.highlight.label.before
  before = before == true and { 0, -1 } or before
  ---@cast before number[]

  if style == "inline" and before then
    before[2] = before[2] + 1
  end

  local target = state.target
  local label_idx = 0

  ---@param match Flash.Match
  ---@param pos number[]
  ---@param offset number[]
  local function label(match, pos, offset)
    local buf = vim.api.nvim_win_get_buf(match.win)
    local row = pos[1] - 1 + offset[1]
    local col = math.max(pos[2] + offset[2], 0)
    local hl_group = state.opts.highlight.groups.label
    if state.opts.highlight.label.rainbow.enabled then
      hl_group = Rainbow.get(label_idx, state.opts.highlight.label.rainbow.shade)
    end
    local extmark = match.label == ""
        -- when empty label, highlight the position
        and {
          hl_group = hl_group,
          end_row = row,
          end_col = col + 1,
          strict = false,
          priority = state.opts.highlight.priority + 2,
        }
      -- else highlight the label
      or {
        virt_text = { { match.label, hl_group } },
        virt_text_pos = style,
        strict = false,
        priority = state.opts.highlight.priority + 2,
      }
    vim.api.nvim_buf_set_extmark(buf, state.ns, row, col, extmark)
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

    if match.label then
      label_idx = label_idx + 1
      if after then
        label(match, match.end_pos, after)
      end
      if before then
        label(match, match.pos, before)
      end
    end
  end
end

return M
