local M = {}

---@param state Flash.State
function M.labeler(state)
  local skip = {}
  for _, m in ipairs(state.results) do
    skip[m.next] = true
  end

  local upper = {}
  local lower = {}

  for _, label in ipairs(vim.split(state.config.labels, "")) do
    local l = label:lower()
    if not skip[l] then
      lower[#lower + 1] = l
    end
    local u = label:upper()
    if u ~= l and not skip[u] then
      upper[#upper + 1] = u
    end
  end

  return {
    ---@param uppercase? boolean
    ---@return string?
    next = function(uppercase)
      if uppercase and #upper > 0 then
        return table.remove(upper, 1)
      end
      if not uppercase and #lower > 0 then
        return table.remove(lower, 1)
      end
      return table.remove(lower, 1) or table.remove(upper, 1) or nil
    end,
  }
end

---@param state Flash.State
function M.update(state)
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

  ---@param a number[]
  ---@param b number[]
  local function is_before(a, b)
    if a[1] == b[1] then
      return a[2] < b[2]
    end
    return a[1] < b[1]
  end

  local labeler = M.labeler(state)
  for _, m in ipairs(state.results) do
    if m.visible and not (state.is_search() and m.first and m.win == state.win) then
      -- if m.win == State.win then
      --   local forward = is_before(State.pos, m.from)
      --   m.label = labeler.next(forward ~= State.forward)
      -- else
      m.label = labeler.next()
      -- end
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

      local on_jump = vim.schedule_wrap(function()
        M.on_jump(match, state, {
          search_reg = vim.fn.getreg("/"),
          jump = not is_search or not state.op,
        })
      end)

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
          callback = on_jump,
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
