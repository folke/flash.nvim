---@class Flash.Pattern
---@field pattern string
---@field search string
---@field skip string
---@field mode Flash.Pattern.Mode
local M = {}
M.__index = M

---@alias Flash.Pattern.Mode "exact" | "fuzzy" | "search"

---@param pattern string
---@param mode Flash.Pattern.Mode
function M.new(pattern, mode)
  local self = setmetatable({}, M)
  self.mode = mode
  self:set(pattern)
  return self
end

---@return boolean updated
function M:set(pattern)
  if pattern ~= self.pattern then
    self.pattern = pattern
    if pattern == "" then
      self.search = ""
      self.skip = ""
    else
      self.search, self.skip = M.get(pattern, self.mode)
    end
    return false
  end
  return true
end

---@param pattern string
---@param mode Flash.Pattern.Mode
function M.get(pattern, mode)
  local skip
  if mode == "exact" then
    pattern = "\\V" .. pattern:gsub("\\", "\\\\")
  elseif mode == "fuzzy" then
    pattern, skip = M.fuzzy(pattern)
  end
  return pattern, skip or pattern
end

---@param opts? {ignorecase: boolean, whitespace:boolean}
function M.fuzzy(pattern, opts)
  opts = vim.tbl_deep_extend("force", {
    ignorecase = vim.go.ignorecase,
    whitespace = false,
  }, opts or {})

  local sep = opts.whitespace and ".\\{-}" or "\\[^\\ ]\\{-}"

  local chars = vim.tbl_map(function(c)
    return c == "\\" and "\\\\" or c
  end, vim.split(pattern, ""))

  local ret = "\\V" .. table.concat(chars, sep) .. (opts.ignorecase and "\\c" or "\\C")
  return ret, ret .. sep
end

return M
