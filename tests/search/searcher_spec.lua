local Searcher = require("flash.searcher")

describe("searcher", function()
  before_each(function()
    vim.api.nvim_buf_set_lines(1, 0, -1, false, {})
  end)

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

    local matches = Searcher.get_matches("line")
    assert.same({
      { first = true, from = { 2, 0 }, to = { 2, 3 } },
      { first = false, from = { 3, 0 }, to = { 3, 3 } },
    }, matches)
  end)

  it("finds matches on each line", function()
    set([[
      line1
      line2
      line3
    ]])

    local matches = Searcher.get_matches("line")
    assert.same({
      { first = true, from = { 2, 0 }, to = { 2, 3 } },
      { first = false, from = { 3, 0 }, to = { 3, 3 } },
      { first = false, from = { 1, 0 }, to = { 1, 3 } },
    }, matches)
  end)

  it("handles ^", function()
    set([[
      foobar
      line1
      line2
    ]])

    local matches = Searcher.get_matches("^")
    assert.same({
      { first = true, from = { 2, 0 }, to = { 2, 0 } },
      { first = false, from = { 3, 0 }, to = { 3, 0 } },
      { first = false, from = { 1, 0 }, to = { 1, 0 } },
    }, matches)
  end)

  it("handles ^.\\?", function()
    set([[
      foobar
      line1
      line2
    ]])

    local matches = Searcher.get_matches("^.\\?")
    assert.same({
      { first = true, from = { 2, 0 }, to = { 2, 0 } },
      { first = false, from = { 3, 0 }, to = { 3, 0 } },
      { first = false, from = { 1, 0 }, to = { 1, 0 } },
    }, matches)
  end)

  it("handles ^l", function()
    set([[
      foobar
      line1
      line2
    ]])

    local matches = Searcher.get_matches("^l")
    assert.same({
      { first = true, from = { 2, 0 }, to = { 2, 0 } },
      { first = false, from = { 3, 0 }, to = { 3, 0 } },
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

    local matches = Searcher.get_matches("foo")
    assert.same({
      { first = true, from = { 1, 0 }, to = { 1, 2 } },
      { first = false, from = { 3, 0 }, to = { 3, 2 } },
    }, matches)
  end)
end)
