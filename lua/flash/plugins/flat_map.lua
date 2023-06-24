local Search = require("flash.search")
local Matcher = require("flash.search.matcher")

-- Takes Search matches and runs a flat_map over it to get ranges
return function(mapper)
  ---@class Flash.FlatMap: Flash.Matcher
  ---@field search Flash.Search
  local R = {}

  function R.new(win, state)
    local self = setmetatable(Matcher.new(win), { __index = R })
    self.search = Search.new(win, state)
    return self
  end

  function R:get(opts)
    self.matches = {}
    for _, m in ipairs(self.search:get(opts)) do
      vim.list_extend(self.matches, mapper(self.win, m.pos, m.end_pos))
    end
    return self.matches
  end

  function R:labels(labels)
    return self.search:labels(labels)
  end

  return setmetatable(R, {
    __call = function(_, win, state)
      return R.new(win, state)
    end,
    __index = Matcher,
  })
end
