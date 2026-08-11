local Util = require("flash.util")

---@class Flash.Pattern
---@field pattern string
---@field search string
---@field skip string
---@field trigger string
---@field mode Flash.Pattern.Mode
---@field case Flash.Pattern.Case
---@operator call:string Returns the input pattern
local M = {}
M.__index = M

---@alias Flash.Pattern.Mode "exact" | "fuzzy" | "search" | (fun(input:string):string,string?)
---@alias Flash.Pattern.Case "auto" | "smart" | "ignore" | "sensitive"

---@param pattern string
---@param mode Flash.Pattern.Mode
---@param trigger string
---@param case? Flash.Pattern.Case
function M.new(pattern, mode, trigger, case)
  local self = setmetatable({}, M)
  self.mode = mode
  self.trigger = trigger or ""
  self.case = case or "auto"
  self:set(pattern or "")
  return self
end

function M:__eq(other)
  return other and other.pattern == self.pattern and other.mode == self.mode and other.case == self.case
end

function M:clone()
  return M.new(self.pattern, self.mode, self.trigger, self.case)
end

function M:empty()
  return self.pattern == ""
end

---@param pattern string
---@return boolean updated
function M:set(pattern)
  if pattern ~= self.pattern then
    self.pattern = pattern
    if pattern == "" then
      self.search = ""
      self.skip = ""
    else
      pattern = self:stripped(pattern)
      local ignorecase = self:ignorecase(pattern)
      self.search, self.skip = M._get(pattern, self.mode, ignorecase)
      -- `\c` and `\C` apply to the whole pattern, no matter where they appear.
      -- Prefixing (instead of appending) keeps a `\c` or `\C` typed by the user
      -- in charge, since the last one in the pattern wins.
      if self.case ~= "auto" then
        local flag = ignorecase and "\\c" or "\\C"
        self.search = flag .. self.search
        self.skip = flag .. self.skip
      end
    end
    return false
  end
  return true
end

---@param char string
function M:extend(char)
  if char == Util.BS then
    return self.pattern:sub(1, -2)
  end
  return self.pattern .. char
end

---@return string the input pattern
function M:__call()
  return self.pattern
end

-- The pattern without its trailing trigger character.
---@param pattern? string defaults to the current pattern
---@return string
function M:stripped(pattern)
  pattern = pattern or self.pattern
  if self.trigger ~= "" and pattern:sub(-1) == self.trigger then
    return pattern:sub(1, -2)
  end
  return pattern
end

-- Whether the pattern contains an uppercase character, as `smartcase` sees it.
-- For regular searches, escaped characters don't count, so `\S` stays lowercase.
---@param pattern string
---@param mode Flash.Pattern.Mode
---@return boolean
function M.has_upper(pattern, mode)
  if mode == "search" then
    pattern = pattern:gsub("\\.", "")
  end
  -- `vim.fn.tolower` is multibyte aware, unlike `string.lower`
  return vim.fn.tolower(pattern) ~= pattern
end

-- Whether matching this pattern ignores case.
---@param pattern? string defaults to the current pattern
---@return boolean
function M:ignorecase(pattern)
  if self.case == "ignore" then
    return true
  elseif self.case == "sensitive" then
    return false
  elseif self.case == "smart" then
    return not M.has_upper(pattern or self:stripped(), self.mode)
  end
  -- `auto`: `smartcase` is resolved by Vim itself when the pattern is used
  return vim.go.ignorecase
end

---@param pattern string
---@param mode Flash.Pattern.Mode
---@param ignorecase? boolean
---@private
function M._get(pattern, mode, ignorecase)
  local skip ---@type string?
  if type(mode) == "function" then
    pattern, skip = mode(pattern)
  elseif mode == "exact" then
    pattern, skip = M._exact(pattern)
  elseif mode == "fuzzy" then
    pattern, skip = M._fuzzy(pattern, { ignorecase = ignorecase })
  end
  return pattern, skip or pattern
end

---@param pattern string
function M._exact(pattern)
  return "\\V" .. pattern:gsub("\\", "\\\\")
end

---@param opts? {ignorecase: boolean, whitespace:boolean}
function M._fuzzy(pattern, opts)
  opts = vim.tbl_deep_extend("force", {
    ignorecase = vim.go.ignorecase,
    whitespace = false,
  }, opts or {})

  local sep = opts.whitespace and ".\\{-}" or "\\[^\\ ]\\{-}"

  ---@param c string
  local chars = vim.tbl_map(function(c)
    return c == "\\" and "\\\\" or c
  end, vim.fn.split(pattern, "\\zs"))

  local ret = "\\V" .. table.concat(chars, sep) .. (opts.ignorecase and "\\c" or "\\C")
  return ret, ret .. sep
end

return M
