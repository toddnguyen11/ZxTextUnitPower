local ZxUIText = LibStub("AceAddon-3.0"):GetAddon("ZxUIText")
---@class Utils47
local Utils47 = {}
Utils47.__index = Utils47
ZxUIText.Utils47 = Utils47

--- References:
--- Layers: https://wowwiki.fandom.com/wiki/XML/Layer
Utils47.LayerLevel = {"BACKGROUND", "BORDER", "ARTWORK", "OVERLAY", "HIGHLIGHT"}
Utils47.UnitClassificationElitesTable = {
  ["worldboss"] = "WB",
  ["rareelite"] = "RE",
  ["elite"] = "E",
  ["rare"] = "R"
}
Utils47.englishClass = {
  "NONE", "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE",
  "WARLOCK", "DRUID"
}

---@param tableInput table
---Add a debugPrint() function to the global `table` class
table.debugPrint = function(tableInput)
  local sorted = {}
  for k, _ in pairs(tableInput) do table.insert(sorted, k) end
  table.sort(sorted)

  for _, sortedKey in ipairs(sorted) do
    local value = tableInput[sortedKey]
    print(string.format("Key: %s | Value: %s", tostring(sortedKey), tostring(value)))
  end
end

---@return table
---Ref: http://lua-users.org/wiki/CopyTable
table.deepCopy = function(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[table.deepCopy(orig_key)] = table.deepCopy(orig_value)
    end
    setmetatable(copy, table.deepCopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

---@param strInput string
---@param sep string
---@return table
function Utils47:splitString(strInput, sep)
  -- Any whitespace by default
  sep = sep or "%s"
  local pattern = "([^" .. sep .. "]+)"
  local t1 = {}
  for str1 in string.gmatch(strInput, pattern) do table.insert(t1, str1) end
  return t1
end

---@param str1 string
---@param str2 string
---@return boolean
function Utils47:stringEqualsIgnoreCase(str1, str2)
  if str1 == nil or str2 == nil then return false end
  return string.upper(str1) == string.upper(str2)
end

---@param name string
---@return string
function Utils47:getInitialsExceptLastWord(name)
  if name == "" then return name end
  local tableSeparated = self:splitString(name)
  local str1 = ""
  for i = 1, (#tableSeparated - 1) do str1 = str1 .. tableSeparated[i]:sub(1, 1) .. ". " end
  str1 = str1 .. tableSeparated[#tableSeparated]
  return str1
end

---@param name string
---@return string
function Utils47:getInitialsExceptFirstWord(name)
  if name == "" then return name end
  local tableSeparated = self:splitString(name)
  local str1 = tableSeparated[1] .. " "
  for i = 2, (#tableSeparated) do str1 = str1 .. tableSeparated[i]:sub(1, 1) .. ". " end
  -- Delete the last excess space character
  str1 = str1:sub(1, string.len(str1) - 1)
  return str1
end

---@param list table
---Create a set from a list. The resulting set can be used like so:
---`if elem in Set then do_something() end`
function Utils47:Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

---@param list table
---@param key string
---@return table
function Utils47:setContains(list, key) return list[key] ~= nil end

---@param unitClassification string
---@return boolean
function Utils47:isNormalEnemy(unitClassification)
  return self.UnitClassificationElitesTable[unitClassification] == nil
end

---@param input number
---@return integer
function Utils47:round(input)
  local num = input + 0.5
  return math.floor(num)
end

---@param initTable table
---@param inputTable table
---Replace all key/value pairs in `initTable` with key/value pairs in `inputTable`
function Utils47:replaceTableValue(initTable, inputTable)
  for k, v in pairs(inputTable) do initTable[k] = v end
end

---@param numberInput number
function Utils47:floorToEven(numberInput)
  local num = math.floor(numberInput)
  if num % 2 == 1 then num = num + 1 end
  return num
end

---@param frame table
---@return string
function Utils47:getIsShown(frame)
  local s1 = ""
  if frame:IsShown() or frame:IsVisible() then
    s1 = "Shown!"
  else
    s1 = "Hidden ;("
  end
  return s1
end
