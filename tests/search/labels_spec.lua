local Labeler = require("flash.labeler")
local Search = require("flash.search")
local State = require("flash.state")
local assert = require("luassert")

describe("labeler", function()
  local function set(text, pos)
    local lines = vim.split(vim.trim(text), "\n")
    lines = vim.tbl_map(function(line)
      return vim.trim(line)
    end, lines)
    vim.api.nvim_buf_set_lines(1, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, pos or { 1, 0 })
  end

  local function search(pattern)
    local state = State.new({ pattern = pattern, search = {
      mode = "search",
    } })
    return Labeler.new(state)
  end

  before_each(function()
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
  end)

  it("skips labels", function()
    set([[
      foo foo
      bar
      barfoo
    ]])
    local labels = search("bar"):skip(1000, { "a", "b", "c", "f" })
    assert.same({ "a", "b", "c" }, labels)
  end)
  it("skips all labels for an empty pattern", function()
    set([[
       test pattern
     ]])
    local labels = search(""):skip(1000, { "a", "b", "c", "t" })
    assert.same({}, labels)
  end)

  it("skips all labels for an invalid pattern", function()
    set([[
       invalid pattern
     ]])
    local labels = search("[i"):skip(1000, { "a", "b", "i", "v" })
    assert.same({}, labels)
  end)

  it("skips all labels when pattern ends with unescaped backslash", function()
    set([[
       pattern with backslash\
     ]])
    local labels = search("backslash\\"):skip(1000, { "a", "b", "s", "\\" })
    assert.same({}, labels)
  end)

  it("skips label that matches pattern", function()
    set([[
       pattern withc
     ]])
    local labels = search("with"):skip(1000, { "a", "b", "c", "p", "w" })
    assert.same({ "a", "b", "p", "w" }, labels)
  end)

  it("considers ignorecase when skipping labels", function()
    set([[
       pattern withC
     ]])
    vim.opt.ignorecase = true
    local labels = search("with"):skip(1000, { "a", "b", "C", "p", "w" })
    assert.same({ "a", "b", "p", "w" }, labels)
  end)

  it("considers ignorecase3 when skipping labels", function()
    set([[
       pattern withC
     ]])
    vim.opt.ignorecase = true
    local labels = search("with"):skip(1000, { "a", "b", "c", "p", "w" })
    assert.same({ "a", "b", "p", "w" }, labels)
  end)

  it("considers ignorecase2 when skipping labels", function()
    set([[
       pattern withc
     ]])
    vim.opt.ignorecase = true
    local labels = search("with"):skip(1000, { "a", "b", "C", "p", "w" })
    assert.same({ "a", "b", "p", "w" }, labels)
  end)

  it("skips all labels when pattern is an incomplete regex", function()
    set([[
       pattern with incomplete regex (
     ]])
    local labels = search("regex \\("):skip(1000, { "a", "b", "i", "r", "(" })
    assert.same({}, labels)
  end)
end)
