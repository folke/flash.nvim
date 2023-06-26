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
    ]])
    C = ffi.C
  end
  return C
end

---@private
---@param from Pos
function M.get_end_pos(from)
  _ffi()
  return Pos({
    from[1] + C.search_match_lines,
    math.max(0, C.search_match_endcol - 1),
  })
end

function M.save_incsearch_state()
  _ffi()
  incsearch_state = {
    match_endcol = C.search_match_endcol,
    match_lines = C.search_match_lines,
  }
end

function M.mappings_disabled()
  _ffi()
  return C.no_mapping == 1
end

function M.restore_incsearch_state()
  _ffi()
  C.search_match_endcol = incsearch_state.match_endcol
  C.search_match_lines = incsearch_state.match_lines
end

return M
