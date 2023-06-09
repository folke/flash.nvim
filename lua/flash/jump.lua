local M = {}

---@param label string?
---@param state Flash.State
---@return Flash.Match?
function M.jump(label, state)
  ---@type Flash.Match
  local match

      end
    end
  end
end

---@param label string|boolean
---@param state Flash.State
---@return Flash.Match?
function M.jump(label, state)
  for _, match in ipairs(state.results) do
    if match.label == label or match.current == label then
      local pos = match.from

      local is_search = state.is_search()

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
      return match
    end
  end
end

---@param match Flash.Match
---@param state Flash.State
---@param opts {search_reg:string, jump:boolean}
function M.on_jump(match, state, opts)
  if opts.jump then
    if state.config.jump.jumplist then
      vim.cmd("normal! m'")
    end
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
