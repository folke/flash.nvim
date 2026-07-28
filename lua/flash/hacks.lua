local Pos = require("flash.search.pos")

local M = {}

---@type ffi.namespace*
local C
local incsearch_state = {}
local new_search_state = vim.fn.has("nvim-0.13") == 1

local function _ffi()
  if not C then
    local ffi = require("ffi")
    ffi.cdef([[
      int no_mapping;
      void setcursor_mayforce(bool force);
    ]])
    if new_search_state then
      ffi.cdef([[
        typedef struct {
          bool hl_match;
          int32_t match_lines;
          int32_t match_endcol;
          int32_t first_line;
          int32_t last_line;
          bool no_smartcase;
          int cmdlen;
          bool no_hlsearch;
        } SearchState;
        SearchState Search;
      ]])
    else
      ffi.cdef([[
        int search_match_endcol;
        unsigned int search_match_lines;
      ]])
    end
    C = ffi.C
  end
  return C
end

local function _get_search_state()
  _ffi()
  if new_search_state then
    return C.Search.match_lines, C.Search.match_endcol
  end
  return C.search_match_lines, C.search_match_endcol
end

local function _set_search_state(lines, endcol)
  _ffi()
  if new_search_state then
    C.Search.match_lines, C.Search.match_endcol = lines, endcol
  else
    C.search_match_lines, C.search_match_endcol = lines, endcol
  end
end

---@private
---@param from Pos
function M.get_end_pos(from)
  local match_lines, match_endcol = _get_search_state()
  local ret = Pos({
    from[1] + match_lines,
    math.max(0, match_endcol - 1),
  })
  local line = vim.api.nvim_buf_get_lines(0, ret[1] - 1, ret[1], false)[1]
  local char_idx = vim.fn.charidx(line, ret[2])
  ret[2] = vim.fn.byteidx(line, char_idx)
  return ret
end

function M.save_incsearch_state()
  incsearch_state.match_lines, incsearch_state.match_endcol = _get_search_state()
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
  _set_search_state(incsearch_state.match_lines, incsearch_state.match_endcol)
end

return M
