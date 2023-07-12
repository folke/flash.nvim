local require = require("flash.require")

local State = require("flash.state")

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

M.is_repeat = false
function M.setup()
  if M._did_setup then
    return
  end
  M._did_setup = true
  vim.on_key(function(key)
    if key == "." and vim.fn.reg_executing() == "" and vim.fn.reg_recording() == "" then
      M.is_repeat = true
      vim.schedule(function()
        M.is_repeat = false
      end)
    end
  end)
end

---@type table<string, Flash.State>
M._states = {}

---@param mode string
---@param opts? Flash.State.Config
function M.get_state(mode, opts)
  M.setup()
  local last = M._states[mode]
  if (M.is_repeat or (opts and opts.continue)) and last then
    last:show()
    return last
  end
  M._states[mode] = State.new(opts)
  return M._states[mode]
end

return M
