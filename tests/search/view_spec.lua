local Search = require("flash.search")
local State = require("flash.state")

describe("search.view", function()
  before_each(function()
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.api.nvim_buf_set_lines(1, 0, -1, false, {})
  end)

  local function get_matches(pattern)
    local state = State.new({ pattern = pattern, search = {
      mode = "search",
    } })
    local win = vim.api.nvim_get_current_win()
    local search = Search.new(win, state)
    return search:get()
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

    local matches = get_matches("line")
    assert.same({
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 3 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 3 } },
    }, matches)
  end)

  it("finds multi matches on same line", function()
    set([[
      foobar foobar
      line1
      lineFoo
    ]])

    local matches = get_matches("foo")
    assert.same({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 2 } },
      { win = 1000, pos = { 1, 7 }, end_pos = { 1, 9 } },
      { win = 1000, pos = { 3, 4 }, end_pos = { 3, 6 } },
    }, matches)
  end)

  it("deals with case", function()
    set([[
      foobar
      Line1
      line2
    ]])

    local matches = get_matches("line")
    assert.same({
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 3 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 3 } },
    }, matches)
  end)

  it("deals with smartcase", function()
    set([[
      foobar
      Line1
      line2
    ]])

    local matches = get_matches("Line")
    assert.same({
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 3 } },
    }, matches)
  end)

  it("finds matches on each line", function()
    set([[
      line1
      line2
      line3
    ]])

    local matches = get_matches("line")
    assert.same({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 3 } },
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 3 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 3 } },
    }, matches)
  end)

  it("handles '\\Vi\\zs\\.'", function()
    set([[
      line1
      line2
      line3
    ]])

    local matches = get_matches([[\Vi\zs\m.]])
    assert.same({
      { win = 1000, pos = { 1, 2 }, end_pos = { 1, 2 } },
      { win = 1000, pos = { 2, 2 }, end_pos = { 2, 2 } },
      { win = 1000, pos = { 3, 2 }, end_pos = { 3, 2 } },
    }, matches)
  end)

  it("handles ^", function()
    set([[
      foobar
      line1
      line2
    ]])

    local matches = get_matches("^")
    assert.same({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 0 } },
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 0 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 0 } },
    }, matches)
  end)

  it("handles ^", function()
    set([[
      foobar
      line1
      line2
    ]])

    local matches = get_matches("^")
    assert.same({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 0 } },
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 0 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 0 } },
    }, matches)
  end)

  it("handles ^.\\?", function()
    set([[
      foobar
      line1
      line2
    ]])

    local matches = get_matches("^.\\?")
    assert.same({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 0 } },
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 0 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 0 } },
    }, matches)
  end)

  it("handles ^l", function()
    set([[
      foobar
      line1
      line2
    ]])

    local matches = get_matches("^l")
    assert.same({
      { win = 1000, pos = { 2, 0 }, end_pos = { 2, 0 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 0 } },
    }, matches)
  end)

  it("handles wrapping", function()
    set(
      [[
      foo
      line1
      foo
    ]],
      { 3, 0 }
    )

    local matches = get_matches("foo")
    assert.same({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 2 } },
      { win = 1000, pos = { 3, 0 }, end_pos = { 3, 2 } },
    }, matches)
  end)
end)
