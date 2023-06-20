local Matcher = require("flash.search.matcher")
local assert = require("luassert")

describe("search", function()
  local matcher = Matcher.new(1000)
  local matches = {
    { win = 1000, pos = { 1, 0 }, end_pos = { 1, 2 } },
    { win = 1000, pos = { 1, 7 }, end_pos = { 1, 9 } },
    { win = 1000, pos = { 3, 4 }, end_pos = { 3, 6 } },
  }
  matcher:set(matches)

  it("sets matches", function()
    assert.same(matches, matcher:get())
  end)

  it("finds backward from after end", function()
    assert.same(
      matches[3],
      matcher:find({
        forward = false,
        pos = { 4, 6 },
        wrap = false,
      })
    )
  end)

  it("handles count = 0", function()
    assert.same(
      matches[2],
      matcher:find({
        pos = { 1, 7 },
        count = 0,
      })
    )
    assert.is_nil(matcher:find({
      pos = { 2, 7 },
      count = 0,
    }))
  end)

  it("returns forward matches", function()
    assert.same(
      { matches[3] },
      matcher:get({
        from = { 2, 6 },
      })
    )
  end)

  it("returns forward matches", function()
    assert.same(
      { matches[3] },
      matcher:get({
        from = { 3, 4 },
      })
    )
  end)

  it("returns backward matches", function()
    assert.same(
      { matches[1] },
      matcher:get({
        to = { 1, 6 },
      })
    )
  end)

  it("returns backward matches", function()
    assert.same(
      { matches[1] },
      matcher:get({
        to = { 1, 0 },
      })
    )
  end)

  it("finds matcher", function()
    assert.same({ win = 1000, pos = { 1, 7 }, end_pos = { 1, 9 } }, matcher:find())
    assert.same({ win = 1000, pos = { 3, 4 }, end_pos = { 3, 6 } }, matcher:find({ count = 2 }))
    assert.same(
      { win = 1000, pos = { 3, 4 }, end_pos = { 3, 6 } },
      matcher:find({ forward = false })
    )
    assert.same(
      { win = 1000, pos = { 1, 7 }, end_pos = { 1, 9 } },
      matcher:find({
        forward = false,
        pos = { 2, 7 },
      })
    )
    assert.same(
      { win = 1000, pos = { 1, 7 }, end_pos = { 1, 9 } },
      matcher:find({
        forward = false,
        pos = { 3, 4 },
      })
    )
  end)

  it("sorts matches", function()
    local m = Matcher.new(1000)
    local mm = {
      { pos = { 3, 4 }, end_pos = { 3, 6 } },
      { pos = { 1, 0 }, end_pos = { 1, 2 } },
      { pos = { 1, 7 }, end_pos = { 1, 9 } },
    }
    m:set(mm)
    assert.same({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 2 } },
      { win = 1000, pos = { 1, 7 }, end_pos = { 1, 9 } },
      { win = 1000, pos = { 3, 4 }, end_pos = { 3, 6 } },
    }, m:get())
  end)
  it("finds forward skipping match at current position", function()
    assert.same(
      matches[2],
      matcher:find({
        forward = true,
        pos = { 1, 0 },
        wrap = false,
      })
    )
  end)

  it("finds backward skipping match at current position", function()
    assert.same(
      matches[2],
      matcher:find({
        forward = false,
        pos = { 3, 4 },
        wrap = true,
      })
    )
  end)

  it("finds forward from a non-match position", function()
    assert.same(
      matches[2],
      matcher:find({
        forward = true,
        pos = { 1, 3 },
        wrap = false,
      })
    )
  end)

  it("finds backward from a non-match position", function()
    assert.same(
      matches[2],
      matcher:find({
        forward = false,
        pos = { 3, 2 },
        wrap = true,
      })
    )
  end)

  it("returns nil when wrapping is disabled and no match is found forward", function()
    assert.is_nil(matcher:find({
      forward = true,
      pos = { 4, 0 },
      wrap = false,
    }))
  end)

  it("returns nil when wrapping is disabled and no match is found backward", function()
    assert.is_nil(matcher:find({
      forward = false,
      pos = { 0, 0 },
      wrap = false,
    }))
  end)

  it("can handle multiple matches on the same pos", function()
    local mm = Matcher.new(1000)
    mm:set({
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 1 } },
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 2 } },
      { win = 1000, pos = { 1, 0 }, end_pos = { 1, 3 } },
    })
    -- assert.same()
  end)
end)
