local M = {}

---@type {is_repeat:boolean, fn:fun()}[]
M._funcs = {}
M._repeat = nil

-- Sets the current operatorfunc to the given function.
function M.set(fn)
  vim.go.operatorfunc = [[{x -> x}]]
  local visual = vim.fn.mode() == "v"
  vim.cmd("normal! g@l")
  if visual then
    vim.cmd("normal! gv")
  end
  M._repeat = fn
  vim.go.operatorfunc = [[v:lua.require'flash.repeat'._repeat]]
end

---@private
function M._execute(id)
  local state = M._funcs[id]
  if state then
    local is_repeat = state.is_repeat
    state.is_repeat = true
    state.fn(is_repeat)
  else
    error("Invalid repeat id: " .. id)
  end
end

-- Wraps a function as a keymap expression so that it can be dot repeated.
---@param fn fun(repeat:boolean)
function M.wrap(fn)
  local state = { fn = fn, is_repeat = false }
  table.insert(M._funcs, state)
  local id = #M._funcs

  return function()
    state.is_repeat = false
    vim.schedule(function()
      if not state.is_repeat then
        vim.notify(
          "Did you forget to map with `expr=true`?",
          vim.log.levels.WARN,
          { title = "flash.nvim" }
        )
      end
    end)
    return ("<cmd>lua require'flash.repeat'._execute(%d)<cr>"):format(id)
  end
end

return M
