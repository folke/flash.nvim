local Jump = require("flash.jump")
local Pos = require("flash.search.pos")
local State = require("flash.state")
local assert = require("luassert")

describe("jump", function()
  local function set(text, pos)
    local lines = vim.split(vim.trim(text), "\n")
    lines = vim.tbl_map(function(line)
      return vim.trim(line)
    end, lines)
    if vim.fn.mode() == "v" then
      vim.cmd("normal! v")
    end
    vim.api.nvim_buf_set_lines(1, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, pos or { 1, 0 })
  end

  ---@param match Flash.Match
  ---@param opts? Flash.State.Config
  local function jump(match, opts)
    match.win = vim.api.nvim_get_current_win()
    local state = State.new(opts)
    Jump.jump(match, state)
  end

  before_each(function()
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    set([[
      line1 foo
      line2 foo
      line3 foo
    ]])
  end)

  it("jumps to start", function()
    local match = {
      pos = Pos({ 1, 6 }),
      end_pos = Pos({ 1, 8 }),
    }
    jump(match)
    assert.same({ 1, 6 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("selects to start", function()
    assert.same({ 1, 0 }, vim.api.nvim_win_get_cursor(0))
    local match = {
      pos = Pos({ 1, 6 }),
      end_pos = Pos({ 1, 8 }),
    }

    assert.same("n", vim.fn.mode())
    vim.cmd("normal! v")
    jump(match, { jump = { pos = "start", inclusive = false } })
    assert.same("v", vim.fn.mode())
    vim.cmd("normal! v")

    assert.same({ 1, 6 }, vim.api.nvim_win_get_cursor(0))
    assert.same({ 1, 0 }, vim.api.nvim_buf_get_mark(0, "<"))
    assert.same({ 1, 6 }, vim.api.nvim_buf_get_mark(0, ">"))
  end)

  -- it("yanks to start", function()
  --   assert.same({ 1, 0 }, vim.api.nvim_win_get_cursor(0))
  --   local match = {
  --     pos = Pos({ 1, 6 }),
  --     end_pos = Pos({ 1, 8 }),
  --   }
  --
  --   assert.same("n", vim.fn.mode())
  --   -- vim.cmd("normal! y")
  --   vim.api.nvim_feedkeys("y", "n", false)
  --   assert.same("no", vim.fn.mode(true))
  --   jump(match, { jump = { pos = "start", inclusive = false } })
  --   assert.same("n", vim.fn.mode())
  --
  --   vim.print(vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
  --
  --   assert.same({ 1, 6 }, vim.api.nvim_win_get_cursor(0))
  --   assert.same({ 1, 0 }, vim.api.nvim_buf_get_mark(0, "["))
  --   assert.same({ 1, 6 }, vim.api.nvim_buf_get_mark(0, "]"))
  -- end)
end)
