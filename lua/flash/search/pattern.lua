local Util = require("flash.util")

---@class Flash.Pattern
---@field pattern string
---@field search string
---@field skip string
---@field mode Flash.Pattern.Mode
---@operator call:string Returns the input pattern
local M = {}
M.__index = M

---@alias Flash.Pattern.Mode "exact" | "fuzzy" | "search" | (fun(input:string):string,string?)

---@param pattern string
---@param mode Flash.Pattern.Mode
function M.new(pattern, mode)
  local self = setmetatable({}, M)
  self.mode = mode
  self:set(pattern or "")
  return self
end

function M:__eq(other)
  return other and other.pattern == self.pattern and other.mode == self.mode
end

function M:clone()
  return M.new(self.pattern, self.mode)
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
      self.search, self.skip = M._get(pattern, self.mode)
    end
    return false
  end
  return true
end

---@param char string
function M:append(char)
  if char == Util.BS then
    self:set(self.pattern:sub(1, -2))
  else
    self:set(self.pattern .. char)
  end
end

---@return string the input pattern
function M:__call()
  return self.pattern
end

---@param pattern string
---@param mode Flash.Pattern.Mode
---@private
function M._get(pattern, mode)
  local skip ---@type string?
  if type(mode) == "function" then
    pattern, skip = mode(pattern)
  elseif mode == "exact" then
    pattern, skip = M._exact(pattern)
  elseif mode == "fuzzy" then
    pattern, skip = M._fuzzy(pattern)
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
  end, vim.split(pattern, ""))

  local ret = "\\V" .. table.concat(chars, sep) .. (opts.ignorecase and "\\c" or "\\C")
  return ret, ret .. sep
end

return M
