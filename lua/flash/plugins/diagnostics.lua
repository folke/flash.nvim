local M = {}

-- Example plugin that shows labels at positions with diagnostics.
function M.show()
  require("flash").jump({
    search = { multi_window = true, wrap = true },
    highlight = { backdrop = true, label = { current = true } },
    matcher = function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      ---@param diag Diagnostic
      return vim.tbl_map(function(diag)
        return {
          pos = { diag.lnum + 1, diag.col },
          end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
        }
      end, vim.diagnostic.get(buf))
    end,
    action = function(match, state)
      vim.api.nvim_win_call(match.win, function()
        vim.api.nvim_win_set_cursor(match.win, match.pos)
        vim.diagnostic.open_float()
        vim.api.nvim_win_set_cursor(match.win, state.pos)
      end)
    end,
  })
end

return M
