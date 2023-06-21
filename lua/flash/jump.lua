local M = {}

---@param match Flash.Match
---@param state Flash.State
---@return Flash.Match?
function M.jump(match, state)
  -- fix inclusive/exclusive
  if vim.fn.mode(true):sub(1, 2) == "no" and state.opts.jump.pos ~= "range" then
    vim.cmd("normal! v")
  end

  -- add to jump list
  if state.opts.jump.jumplist then
    vim.cmd("normal! m'")
  end

  -- change window if needed
  if match.win ~= vim.api.nvim_get_current_win() then
    vim.api.nvim_set_current_win(match.win)
  end

  -- jump to start
  if state.opts.jump.pos == "start" then
    vim.api.nvim_win_set_cursor(match.win, match.pos)

  -- jump to end
  elseif state.opts.jump.pos == "end" then
    vim.api.nvim_win_set_cursor(match.win, match.end_pos)

  -- select range
  else
    if vim.fn.mode() == "v" then
      vim.cmd("normal! v")
    end
    vim.api.nvim_win_set_cursor(match.win, match.pos)
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(match.win, match.end_pos)
  end
end

---@param state Flash.State
function M.on_jump(state)
  -- fix or restore the search register
  local sf = vim.v.searchforward
  if state.opts.jump.register then
    vim.fn.setreg("/", state.pattern.search)
  end
  vim.v.searchforward = sf

  -- add the real search pattern to the history
  if state.opts.jump.history then
    vim.fn.histadd("search", state.pattern.search)
  end

  -- clear the highlight
  if state.opts.jump.nohlsearch then
    vim.cmd.nohlsearch()
  end
end

return M
