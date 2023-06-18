local Search = require("flash.search")
local State = require("flash.state")
local assert = require("luassert")

describe("search", function()
  local function set(text, pos)
    local lines = vim.split(vim.trim(text), "\n")
    lines = vim.tbl_map(function(line)
      return vim.trim(line)
    end, lines)
    vim.api.nvim_buf_set_lines(1, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, pos or { 1, 0 })
  end

  before_each(function()
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.api.nvim_buf_set_lines(1, 0, -1, false, {})
    set([[
      foo foo
      bar
      barfoo
    ]])
  end)

  local state = State.new({ pattern = "foo" })
  local search = Search.new(1000, state)

  local matches = {
    { win = 1000, pos = { 1, 0 }, end_pos = { 1, 2 } },
    { win = 1000, pos = { 1, 4 }, end_pos = { 1, 6 } },
    { win = 1000, pos = { 3, 3 }, end_pos = { 3, 5 } },
  }

  it("sets matches", function()
    assert.same(matches, search:get())
  end)

  it("finds backward from after end", function()
    assert.same(
      matches[3],
      search:find({
        forward = false,
        pos = { 4, 6 },
        wrap = false,
      })
    )
  end)

  it("handles count = 0", function()
    assert.same(
      matches[2],
      search:find({
        pos = { 1, 4 },
        count = 0,
      })
    )
    assert.is_nil(search:find({
      pos = { 2, 7 },
      count = 0,
    }))
  end)

  it("returns forward matches", function()
    assert.same(
      { matches[3] },
      search:get({
        from = { 2, 6 },
      })
    )
  end)

  it("returns forward matches", function()
    assert.same(
      { matches[3] },
      search:get({
        from = { 3, 3 },
      })
    )
  end)

  it("returns backward matches", function()
    assert.same(
      { matches[1] },
      search:get({
        to = { 1, 3 },
      })
    )
  end)

  it("returns backward matches at pos", function()
    assert.same(
      { matches[1] },
      search:get({
        to = { 1, 0 },
      })
    )
  end)

  it("finds matcher", function()
    assert.same({ win = 1000, pos = { 1, 4 }, end_pos = { 1, 6 } }, search:find())
    assert.same({ win = 1000, pos = { 3, 3 }, end_pos = { 3, 5 } }, search:find({ count = 2 }))
    assert.same(
      { win = 1000, pos = { 3, 3 }, end_pos = { 3, 5 } },
      search:find({ forward = false })
    )
    assert.same(
      { win = 1000, pos = { 1, 4 }, end_pos = { 1, 6 } },
      search:find({
        forward = false,
        pos = { 2, 7 },
      })
    )
    assert.same(
      { win = 1000, pos = { 1, 4 }, end_pos = { 1, 6 } },
      search:find({
        forward = false,
        pos = { 3, 2 },
      })
    )
  end)

  it("finds forward skipping match at current position", function()
    assert.same(
      matches[2],
      search:find({
        forward = true,
        pos = { 1, 0 },
        wrap = false,
      })
    )
  end)

  it("finds backward skipping match at current position", function()
    assert.same(
      matches[2],
      search:find({
        forward = false,
        pos = { 3, 3 },
        wrap = true,
      })
    )
  end)

  it("finds forward from a non-match position", function()
    assert.same(
      matches[2],
      search:find({
        forward = true,
        pos = { 1, 3 },
        wrap = false,
      })
    )
  end)

  it("finds backward from a non-match position", function()
    assert.same(
      matches[2],
      search:find({
        forward = false,
        pos = { 3, 2 },
        wrap = true,
      })
    )
  end)

  it("returns nil when wrapping is disabled and no match is found forward", function()
    assert.is_nil(search:find({
      forward = true,
      pos = { 4, 0 },
      wrap = false,
    }))
  end)

  it("returns nil when wrapping is disabled and no match is found backward", function()
    assert.is_nil(search:find({
      forward = false,
      pos = { 1, 0 },
      wrap = false,
    }))
  end)
end)
