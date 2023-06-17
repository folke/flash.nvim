local Search = require("flash.search")
local State = require("flash.state")

describe("search", function()
  before_each(function()
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.api.nvim_buf_set_lines(1, 0, -1, false, {})
  end)

  ---@param opts? Flash.State.Config | string
  local function get_search(opts)
    if type(opts) == "string" then
      opts = { pattern = opts }
    end
    local state = State.new(opts)
    local win = vim.api.nvim_get_current_win()
    return Search.new(win, state)
  end

  local function set(text, pos)
    local lines = vim.split(vim.trim(text), "\n")
    lines = vim.tbl_map(function(line)
      return vim.trim(line)
    end, lines)
    vim.api.nvim_buf_set_lines(1, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, pos or { 1, 0 })
  end

  it("finds matches", function()
    set([[
      foobar
      line1
      line2
    ]])

    local search = get_search("line")
    local matches = search:get()
    assert.same("\\Vline", search.state.pattern.search)
    assert.same({
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 3 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 3 } },
    }, matches)
    assert.same({ win = 1000, pos = { 2, 0 }, end_pos = { 2, 3 } }, search:find())
    assert.same({ win = 1000, pos = { 3, 0 }, end_pos = { 3, 3 } }, search:find({ count = 2 }))
    assert.same(
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 3 } },
      search:find({ forward = false })
    )
  end)
end)
