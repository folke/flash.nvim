local Config = require("flash.config")
local assert = require("luassert")

describe("config", function()
  before_each(function()
    Config.setup()
  end)

  it("processes modes", function()
    Config.setup({ modes = { foo = { bar = true } } })
    assert.is_true(Config.modes.foo.bar)
    assert.is_true(Config.get({ mode = "foo" }).bar)
  end)

  it("processes modes recursively", function()
    Config.setup({
      modes = {
        foo = { mode = "bar" },
        bar = { field = true, mode = "foo" },
      },
    })
    assert.is_true(Config.get({ mode = "foo" }).field)
    assert.is_true(Config.get({ mode = "bar" }).field)
  end)

  it("processes modes recursively in correct order", function()
    Config.setup({
      modes = {
        a = { mode = "b", v = "a" },
        b = { mode = "c", v = "b" },
        c = { v = "c" },
      },
    })
    assert.same("d", Config.get({ mode = "a", v = "d" }).v)
    assert.same("a", Config.get({ mode = "a" }).v)
    assert.same("b", Config.get({ mode = "b" }).v)
  end)
end)
