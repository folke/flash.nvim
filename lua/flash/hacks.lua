local Pos = require("flash.search.pos")

local M = {}

---@type ffi.namespace*
local C
local incsearch_state = {}

local function _ffi()
  if not C then
    local ffi = require("ffi")
    ffi.cdef([[
      int search_match_endcol;
      int no_mapping;
      unsigned int search_match_lines;
      void setcursor_mayforce(bool force);
    ]])
    C = ffi.C
  end
  return C
end

---@private
---@param from Pos
function M.get_end_pos(from)
  _ffi()
  local ret = Pos({
    from[1] + C.search_match_lines,
    math.max(0, C.search_match_endcol - 1),
  })
  local line = vim.api.nvim_buf_get_lines(0, ret[1] - 1, ret[1], false)[1]
  local char_idx = vim.fn.charidx(line, ret[2])
  ret[2] = vim.fn.byteidx(line, char_idx)
  return ret
end

function M.save_incsearch_state()
  _ffi()
  incsearch_state = {
    match_endcol = C.search_match_endcol,
    match_lines = C.search_match_lines,
  }
end

function M.mappings_enabled()
  _ffi()
  return C.no_mapping == 0
end

function M.setcursor(force)
  if vim.api.nvim__redraw then
    vim.api.nvim__redraw({ cursor = true })
  else
    if force == nil then
      force = false
    end
    _ffi()
    return C.setcursor_mayforce(force)
  end
end

function M.restore_incsearch_state()
  _ffi()
  C.search_match_endcol = incsearch_state.match_endcol
  C.search_match_lines = incsearch_state.match_lines
end

return M
