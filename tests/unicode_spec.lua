local State = require("flash.state")
local assert = require("luassert")

describe("unicode", function()
  local labels = "😅😀🏇🐎🐴🐵🐒"

  it("splits labels", function()
    local state = State.new({ labels = labels })
    assert.same({ "😅", "😀", "🏇", "🐎", "🐴", "🐵", "🐒" }, state:labels())
  end)
end)
