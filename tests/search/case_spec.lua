local Config = require("flash.config")
local Search = require("flash.search")
local State = require("flash.state")
local assert = require("luassert")

describe("case", function()
  ---@param opts? Flash.State.Config
  local function get_search(opts)
    local state = State.new(opts)
    local win = vim.api.nvim_get_current_win()
    return Search.new(win, state)
  end

  ---@param search Flash.Search
  local function lines(search)
    return vim.tbl_map(function(m)
      return m.pos[1]
    end, search:get())
  end

  before_each(function()
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.api.nvim_buf_set_lines(1, 0, -1, false, { "foo", "Foo", "FOO" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end)

  it("defaults to auto", function()
    local search = get_search({ pattern = "foo" })
    assert.same("auto", search.state.pattern.case)
    assert.same("\\Vfoo", search.state.pattern.search)
    assert.same({ 1, 2, 3 }, lines(search))
  end)

  it("auto respects smartcase", function()
    local search = get_search({ pattern = "Foo" })
    assert.same("\\VFoo", search.state.pattern.search)
    assert.same({ 2 }, lines(search))
  end)

  it("auto follows ignorecase being off", function()
    vim.opt.ignorecase = false
    local search = get_search({ pattern = "foo" })
    assert.same("\\Vfoo", search.state.pattern.search)
    assert.same({ 1 }, lines(search))
  end)

  describe("smart", function()
    it("ignores case for a lowercase pattern", function()
      local search = get_search({ pattern = "foo", search = { case = "smart" } })
      assert.same("\\c\\Vfoo", search.state.pattern.search)
      assert.same({ 1, 2, 3 }, lines(search))
    end)

    it("matches case for an uppercase pattern", function()
      local search = get_search({ pattern = "Foo", search = { case = "smart" } })
      assert.same("\\C\\VFoo", search.state.pattern.search)
      assert.same({ 2 }, lines(search))
    end)

    it("works without ignorecase and smartcase", function()
      vim.opt.ignorecase = false
      vim.opt.smartcase = false
      assert.same({ 1, 2, 3 }, lines(get_search({ pattern = "foo", search = { case = "smart" } })))
      assert.same({ 2 }, lines(get_search({ pattern = "Foo", search = { case = "smart" } })))
    end)

    it("ignores escaped characters for regular searches", function()
      -- `\S` is not an uppercase character, `S` is
      local search = get_search({ pattern = "fo\\S", search = { mode = "search", case = "smart" } })
      assert.same("\\cfo\\S", search.state.pattern.search)
      local sensitive = get_search({ pattern = "foS", search = { mode = "search", case = "smart" } })
      assert.same("\\CfoS", sensitive.state.pattern.search)
    end)

    it("detects multibyte uppercase", function()
      local search = get_search({ pattern = "Ünïcode", search = { case = "smart" } })
      assert.same("\\C\\VÜnïcode", search.state.pattern.search)
    end)
  end)

  it("sensitive ignores ignorecase", function()
    local search = get_search({ pattern = "foo", search = { case = "sensitive" } })
    assert.same("\\C\\Vfoo", search.state.pattern.search)
    assert.is_false(search.state.pattern:ignorecase())
    assert.same({ 1 }, lines(search))
  end)

  it("ignore ignores ignorecase being off", function()
    vim.opt.ignorecase = false
    local search = get_search({ pattern = "foo", search = { case = "ignore" } })
    assert.same("\\c\\Vfoo", search.state.pattern.search)
    assert.is_true(search.state.pattern:ignorecase())
    assert.same({ 1, 2, 3 }, lines(search))
  end)

  it("ignore overrules smartcase", function()
    local search = get_search({ pattern = "Foo", search = { case = "ignore" } })
    assert.same({ 1, 2, 3 }, lines(search))
  end)

  it("lets an explicit flag in the pattern win", function()
    -- `\c` typed by the user comes after our `\C`, and the last one wins
    local search = get_search({
      pattern = "foo\\c",
      search = { mode = "search", case = "sensitive" },
    })
    assert.same("\\Cfoo\\c", search.state.pattern.search)
    assert.same({ 1, 2, 3 }, lines(search))
  end)

  describe("per mode", function()
    after_each(function()
      require("flash").setup()
    end)

    it("can be configured for a single mode", function()
      require("flash").setup({ modes = { char = { search = { case = "sensitive" } } } })
      assert.same("sensitive", Config.get("char").search.case)
      assert.same("auto", Config.get().search.case)
      assert.same("auto", Config.get("search").search.case)
    end)

    ---@param case Flash.Pattern.Case
    local function delete_to_a(case)
      require("flash").setup({ modes = { char = { search = { case = case } } } })
      local char = require("flash.plugins.char")
      if char.state then
        char.state:hide()
      end
      vim.api.nvim_buf_set_lines(1, 0, -1, false, { "xAbc abc" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd("norm dfa")
      return vim.api.nvim_buf_get_lines(1, 0, -1, false)[1]
    end

    -- `df` is inclusive, so the target character is deleted as well
    it("makes ftFT follow ignorecase with auto", function()
      assert.same("bc abc", delete_to_a("auto"))
    end)

    it("makes ftFT case sensitive with sensitive", function()
      assert.same("bc", delete_to_a("sensitive"))
    end)
  end)
end)
