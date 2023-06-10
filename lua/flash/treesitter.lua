local State = require("flash.state")

local M = {}

function M.get_nodes()
  local ret = {} ---@type TSNode[]
  local node = vim.treesitter.get_node()
  while node do
    local range = { node:range() }
    if not vim.deep_equal(range, ret[#ret]) then
      table.insert(ret, range)
    end
    node = node:parent()
  end
  return ret
end

M.state = nil
function M.jump()
  local nodes = M.get_nodes()

  if M.state then
    M.state:clear()
    M.state = nil
  end

  M.state = State.new({
    config = {
      labels = "abcdefghijklmnopqrstuvwxyz",
      search = { multi_window = false },
      jump = { auto_jump = false },
      highlight = {
        backdrop = true,
        label = {
          before = true,
          after = true,
          style = "inline",
        },
        matches = false,
      },
    },
  })

  for _, range in ipairs(nodes) do
    table.insert(M.state.results, {
      win = M.state.win,
      from = { range[1] + 1, range[2] },
      to = { range[3] + 1, range[4] - 1 },
      visible = true,
      next = "",
    })
  end

  M.state.labeler:update()
  M.state:highlight()
  vim.cmd.redraw()
  local ok, c = pcall(vim.fn.getchar)
  local char = ok and type(c) == "number" and vim.fn.nr2char(c) or nil
  if char then
    if vim.fn.mode() == "v" then
      vim.cmd("normal! v")
    end
    local match = M.state:jump(char)
    if match then
      vim.cmd("normal! v")
      vim.api.nvim_win_set_cursor(M.state.win, match.to)
    else
      vim.api.nvim_input(char)
    end
  end
  M.state:clear()
end

return M
