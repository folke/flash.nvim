local M = {}

M.ns = vim.api.nvim_create_namespace("flash")

function M.clear()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
  end
end

---@param state Flash.State
function M.update(state)
  M.clear()
  local State = require("flash.state")
  for _, match in ipairs(state.results) do
    local buf = vim.api.nvim_win_get_buf(match.win)

    if not State.is_search() then
      vim.api.nvim_buf_set_extmark(buf, M.ns, match.from[1] - 1, match.from[2], {
        end_row = match.to[1] - 1,
        end_col = match.to[2] + 1,
        hl_group = match.first and match.win == state.win and "CurSearch" or "Search",
      })
    end

    if match.label then
      local col = math.min(match.to[2], #match.line - 1)
      vim.api.nvim_buf_set_extmark(buf, M.ns, match.to[1] - 1, col + 1, {
        virt_text = { { match.label, "Foo" } },
        virt_text_pos = "overlay",
      })
    end
  end
end

return M
