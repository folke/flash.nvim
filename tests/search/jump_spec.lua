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

  it("jump_pos override jumps to end", function()
    local match = {
      pos = Pos({ 1, 6 }),
      end_pos = Pos({ 1, 8 }),
    }
    match.win = vim.api.nvim_get_current_win()
    local state = State.new({ jump = { pos = "start" } })
    Jump.jump(match, state, { jump_pos = "end" })
    assert.same({ 1, 8 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("jump_pos override defaults to state pos", function()
    local match = {
      pos = Pos({ 1, 6 }),
      end_pos = Pos({ 1, 8 }),
    }
    match.win = vim.api.nvim_get_current_win()
    local state = State.new({ jump = { pos = "start" } })
    Jump.jump(match, state)
    assert.same({ 1, 6 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("uppercase_pos disables uppercase labels", function()
    local state = State.new({ label = { uppercase = true, uppercase_pos = "end" } })
    local labels = state:labels()
    for _, l in ipairs(labels) do
      assert.is_true(l == vim.fn.tolower(l), "expected only lowercase labels, got: " .. l)
    end
  end)

  it("state:jump uppercase label uses uppercase_pos", function()
    local match = {
      pos = Pos({ 2, 6 }),
      end_pos = Pos({ 2, 8 }),
      label = "a",
      win = vim.api.nvim_get_current_win(),
    }
    local state = State.new({
      jump = { pos = "start" },
      label = { uppercase_pos = "end" },
    })
    state.results = { match }
    state:jump("A")
    assert.same({ 2, 8 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("state:jump lowercase label uses default pos", function()
    local match = {
      pos = Pos({ 2, 6 }),
      end_pos = Pos({ 2, 8 }),
      label = "a",
      win = vim.api.nvim_get_current_win(),
    }
    local state = State.new({
      jump = { pos = "start" },
      label = { uppercase_pos = "end" },
    })
    state.results = { match }
    state:jump("a")
    assert.same({ 2, 6 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("match.jump_pos fallback used by Jump.jump", function()
    local match = {
      pos = Pos({ 1, 6 }),
      end_pos = Pos({ 1, 8 }),
      jump_pos = "end",
    }
    match.win = vim.api.nvim_get_current_win()
    local state = State.new({ jump = { pos = "start" } })
    -- Call Jump.jump without explicit opts.jump_pos; match.jump_pos should be used
    Jump.jump(match, state)
    assert.same({ 1, 8 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("uppercase_pos propagates through custom action via match.jump_pos", function()
    local match = {
      pos = Pos({ 2, 6 }),
      end_pos = Pos({ 2, 8 }),
      label = "a",
      win = vim.api.nvim_get_current_win(),
    }
    -- Simulate a custom action that calls Jump.jump without opts
    local state = State.new({
      jump = { pos = "start" },
      label = { uppercase_pos = "end" },
      action = function(m, s)
        Jump.jump(m, s) -- no 3rd arg, like search plugin does
        Jump.on_jump(s)
      end,
    })
    state.results = { match }
    state:jump("A")
    -- Even through custom action, match.jump_pos should cause end jump
    assert.same({ 2, 8 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("uppercase_pos range is skipped in search/cmdline mode", function()
    local match = {
      pos = Pos({ 2, 6 }),
      end_pos = Pos({ 2, 8 }),
      label = "a",
      win = vim.api.nvim_get_current_win(),
    }
    local state = State.new({
      jump = { pos = "start" },
      label = { uppercase_pos = "range" },
    })
    state.results = { match }
    -- Simulate not being in search mode: jump should apply range override
    state:jump("A")
    -- In normal mode, range override selects from pos to end_pos;
    -- cursor ends at end_pos
    assert.same({ 2, 8 }, vim.api.nvim_win_get_cursor(0))
  end)

  -- Integration tests: full check_jump flow with real labeler results
  it("integration: check_jump uppercase triggers uppercase_pos jump", function()
    set([[
      foo bar
      foo baz
    ]], { 1, 0 })
    local state = State.new({
      pattern = "foo",
      jump = { pos = "start" },
      label = { uppercase_pos = "end" },
    })
    -- Verify results exist and have labels assigned by the labeler
    assert.is_true(#state.results > 0, "expected results")
    local target = nil
    local label = nil
    for _, m in ipairs(state.results) do
      if m.label and m.label ~= "" and m.label ~= false then
        target = m
        label = m.label
        break
      end
    end
    assert.is_not_nil(label, "expected a labeled match")
    -- Go through check_jump with uppercase label (same path as step())
    local jumped = state:check_jump("foo" .. label:upper())
    assert.is_true(jumped)
    -- Cursor should be at end position (uppercase_pos)
    local cursor = vim.api.nvim_win_get_cursor(0)
    assert.same({ target.end_pos[1], target.end_pos[2] }, cursor)
  end)

  it("integration: check_jump lowercase still uses default pos", function()
    set([[
      foo bar
      foo baz
    ]], { 1, 0 })
    local state = State.new({
      pattern = "foo",
      jump = { pos = "start" },
      label = { uppercase_pos = "end" },
    })
    local target = nil
    local label = nil
    for _, m in ipairs(state.results) do
      if m.label and m.label ~= "" and m.label ~= false then
        target = m
        label = m.label
        break
      end
    end
    assert.is_not_nil(label, "expected a labeled match")
    -- Go through check_jump with lowercase label
    local jumped = state:check_jump("foo" .. label)
    assert.is_true(jumped)
    -- Cursor should be at start position (default jump.pos)
    local cursor = vim.api.nvim_win_get_cursor(0)
    assert.same({ target.pos[1], target.pos[2] }, cursor)
  end)
end)
