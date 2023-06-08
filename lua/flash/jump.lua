local M = {}

---@param state Flash.State
function M.labels(state)
  local skip = {}
  for _, m in ipairs(state.results) do
    skip[m.next] = true
  end

  local labels = {}
  for _, l in ipairs(vim.split(state.config.labels .. state.config.labels:upper(), "")) do
    if not skip[l] then
      labels[#labels + 1] = l
      skip[l] = true
    end
  end
  return labels
end

---@param state Flash.State
function M.update(state)
  -- sort by current win, other win, then by distance
  table.sort(state.results, function(a, b)
    if a.win ~= b.win then
      local aw = a.win == state.win and 0 or a.win
      local bw = b.win == state.win and 0 or b.win
      return aw < bw
    end
    if a.from[1] ~= b.from[1] then
      if a.win == state.win then
        local da = math.abs(a.from[1] - state.pos[1])
        local db = math.abs(b.from[1] - state.pos[1])
        return da < db
      end
      return a.from[1] < b.from[1]
    end
    if a.win == state.win then
      local da = math.abs(a.from[2] - state.pos[2])
      local db = math.abs(b.from[2] - state.pos[2])
      return da < db
    end
    return a.from[2] < b.from[2]
  end)

  local labels = M.labels(state)
  for _, m in ipairs(state.results) do
    -- only label visible matches
    -- and don't label the first match in the current window
    if m.visible and not (m.first and m.win == state.win and not state.config.highlight.label_first) then
      m.label = table.remove(labels, 1)
    end
  end
end

---@param label string|boolean
---@param state Flash.State
function M.jump(label, state)
  for _, match in ipairs(state.results) do
    if match.label == label or match.first == label then
      local pos = match.from

      local is_search = require("flash.state").is_search()

      local on_jump = function()
        M.on_jump(match, state, {
          search_reg = vim.fn.getreg("/"),
          jump = not is_search or not state.op,
        })
      end

      if is_search then
        -- For operator pending mode, set the search pattern to the
        -- first character on the match position
        if state.op then
          local pos_pattern = ("\\%%%dl\\%%%dc."):format(pos[1], pos[2] + 1)
          vim.fn.setcmdline(pos_pattern)
        end

        -- schedule a <cr> input to trigger the search
        vim.schedule(function()
          vim.api.nvim_input(state.op and "<cr>" or "<esc>")
        end)

        -- restore the real search pattern after the search
        -- and perform the jump when not in operator pending mode
        vim.api.nvim_create_autocmd("CmdlineLeave", {
          once = true,
          callback = vim.schedule_wrap(on_jump),
        })
      else
        on_jump()
      end
      return true
    end
  end
end

---@param match Flash.Match
---@param state Flash.State
---@param opts {search_reg:string, jump:boolean}
function M.on_jump(match, state, opts)
  if opts.jump then
    if match.win ~= vim.api.nvim_get_current_win() then
      vim.api.nvim_set_current_win(match.win)
    end
    vim.api.nvim_win_set_cursor(match.win, match.from)
  else
    -- delete the special search pattern from the history
    vim.fn.histdel("search", -1)
  end

  -- fix or restore the search register
  local sf = vim.v.searchforward
  if state.config.jump.register then
    vim.fn.setreg("/", state.pattern)
  else
    vim.fn.setreg("/", opts.search_reg)
  end
  vim.v.searchforward = sf

  -- add the real search pattern to the history
  if state.config.jump.history then
    vim.fn.histadd("search", state.pattern)
  end

  -- clear the highlight
  if state.config.jump.nohlsearch then
    vim.cmd.nohlsearch()
  end
end

return M
