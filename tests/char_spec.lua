local Char = require("flash.plugins.char")
local assert = require("luassert")
require("flash").setup()

describe("char", function()
  local function set(text, pos)
    local lines = vim.split(vim.trim(text), "\n")
    lines = vim.tbl_map(function(line)
      return vim.trim(line)
    end, lines)
    vim.api.nvim_buf_set_lines(1, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, pos or { 1, 0 })
  end

  before_each(function()
    set("abc_xyz", { 1, 3 })
    local state = require("flash.plugins.char").state
    if state then
      state:hide()
    end
  end)

  local function get()
    return table.concat(vim.api.nvim_buf_get_lines(1, 0, -1, false), "\n")
  end

  --- tests for deletes with ftFT motions
  --- test always runs on input "abc_xyz"
  --- with cursor at position { 1, 3 }
  local tests = {
    -- f
    { motion = "dfx", result = "abcyz" },
    { motion = "dfz", result = "abc" },
    { motion = "df_", result = "abc_xyz" },
    { motion = "dfa", result = "abc_xyz" },
    -- t
    { motion = "dtx", result = "abcxyz" },
    { motion = "dtz", result = "abcz" },
    { motion = "dt_", result = "abc_xyz" },
    { motion = "dta", result = "abc_xyz" },
    -- F
    { motion = "dFa", result = "_xyz" },
    { motion = "dFc", result = "ab_xyz" },
    { motion = "dF_", result = "abc_xyz" },
    { motion = "dFx", result = "abc_xyz" },
    -- T
    { motion = "dTa", result = "a_xyz" },
    { motion = "dTc", result = "abc_xyz" },
    { motion = "dT_", result = "abc_xyz" },
    { motion = "dTx", result = "abc_xyz" },
  }

  for _, test in ipairs(tests) do
    it("works with " .. test.motion, function()
      vim.cmd("norm! " .. test.motion)
      assert.same(test.result, get())
    end)
  end
  for _, test in ipairs(tests) do
    it("works with " .. test.motion .. " (flash)", function()
      -- vim.api.nvim_feedkeys(test.motion, "mtx", false)
      vim.cmd("norm " .. test.motion)
      assert.same(test.result, get())
    end)
  end

  local input = "abcd1abcd2abcd"
  for _, motion in ipairs({ "f", "t", "F", "T" }) do
    for col = 0, #input - 1 do
      for count = -1, 3 do
        count = count == -1 and "" or count
        for _, char in ipairs({ "a", "b", "c", "d" }) do
          local cmd = count .. "d" .. motion .. char
          local pos = { 1, col }
          it("works with " .. cmd .. " at " .. col, function()
            set(input, pos)
            vim.cmd("norm! " .. cmd)
            local ret = get()
            set(input, pos)
            if Char.state then
              Char.state:hide()
            end
            vim.cmd("norm " .. cmd)
            assert.same(ret, get())
          end)
        end
      end
    end
  end
end)
