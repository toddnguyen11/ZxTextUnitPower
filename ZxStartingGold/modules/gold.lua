local ZxStartingGold = LibStub("AceAddon-3.0"):GetAddon("ZxStartingGold")

---@class GoldOptions
local GoldOptions = {}

function GoldOptions:__init__()
  self.options = {}
  self.MODULE_NAME = "GoldOptions"
  self.DECORATIVE_NAME = "Gold Options"
end

function GoldOptions:new(...)
  local newInstance = setmetatable({}, self)
  newInstance:__init__(...)
  return newInstance
end

function GoldOptions:registerModuleOptionsTable()
  ZxStartingGold:registerModuleOptions(self.MODULE_NAME, self:getOptionTable(),
    self.DECORATIVE_NAME)
end

function GoldOptions:getOptionTable()
  if next(self.options) == nil then
    options = {}
  end
  return self.options
end

-- ########################################################
-- # Main Execute!
-- ########################################################
local goldOptions = GoldOptions:new()
goldOptions:registerModuleOptionsTable()
