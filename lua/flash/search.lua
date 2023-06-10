local require = require("flash.require")

local Jump = require("flash.jump")
local State = require("flash.state")

local M = {}

---@type Flash.State?
M.state = nil
M.op = false

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
      M.state:update({ search = vim.fn.getcmdline() })
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
          config = {
            mode = "search",
            search = {
              forward = vim.fn.getcmdtype() == "/",
              regex = true,
            },
          },
        })
        M.state.on_jump = M.on_jump
        M.set_op(vim.fn.mode() == "v")
      end
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:c",
    group = group,
    callback = wrap(function()
      M.set_op(vim.v.event.old_mode:sub(1, 2) == "no" or vim.fn.mode() == "v")
      M.state:update()
    end),
  })
end

function M.set_op(op)
  M.op = op
  if M.op and M.state then
    M.state.config.search.multi_window = false
  end
end

---@param self Flash.State
---@param match Flash.Match
function M:on_jump(match)
  local pos = match.from
  local search_reg = vim.fn.getreg("/")

  -- For operator pending mode, set the search pattern to the
  -- first character on the match position
  if M.op then
    local pos_pattern = ("\\%%%dl\\%%%dc."):format(pos[1], pos[2] + 1)
    vim.fn.setcmdline(pos_pattern)
  end

  -- schedule a <cr> input to trigger the search
  vim.schedule(function()
    vim.api.nvim_input(M.op and "<cr>" or "<esc>")
  end)

  -- restore the real search pattern after the search
  -- and perform the jump when not in operator pending mode
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    once = true,
    callback = vim.schedule_wrap(function()
      if M.op then
        -- delete the special search pattern from the history
        vim.fn.histdel("search", -1)
        -- restore original search pattern
        vim.fn.setreg("/", search_reg)
      else
        Jump.jump(match, self)
      end
      Jump.on_jump(self)
    end),
  })
end

return M
