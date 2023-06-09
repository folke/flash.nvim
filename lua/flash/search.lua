local State = require("flash.state")

local M = {}

---@type Flash.State?
M.state = nil

function M.setup()
  local group = vim.api.nvim_create_augroup("flash", { clear = true })

  local function wrap(fn)
    return function(...)
      if M.state then
        return fn(...)
      end
    end
  end

  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    callback = wrap(function()
      M.state:update(vim.fn.getcmdline())
    end),
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = wrap(function()
      M.state:clear()
      M.state = nil
    end),
  })
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
    callback = function()
      if State.is_search() then
        M.state = State.new({
          op = vim.fn.mode() == "v",
          config = {
            mode = "search",
            search = {
              forward = vim.fn.getcmdtype() == "/",
              regex = true,
            },
          },
        })
      end
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:c",
    group = group,
    callback = wrap(function()
      local op = vim.v.event.old_mode:sub(1, 2) == "no" or vim.fn.mode() == "v"
      M.state.op = op
      M.state:update()
    end),
  })
end

return M
