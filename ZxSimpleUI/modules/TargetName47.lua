local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "TargetName47"
local _DECORATIVE_NAME = "Target Name"
local TargetName47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame, UnitName = UIParent, CreateFrame, UnitName
local UnitName, UnitHealth = UnitName, UnitHealth
local ToggleDropDownMenu, TargetFrameDropDown = ToggleDropDownMenu, TargetFrameDropDown
local unpack = unpack

TargetName47.MODULE_NAME = _MODULE_NAME
TargetName47.bars = nil

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 300,
    fontsize = 12,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 0.0, 1.0},
    border = "None"
  }
}

function TargetName47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getAppendedEnableOptionTable(),
                                   _DECORATIVE_NAME)

  self:__init__()
end

function TargetName47:OnEnable()
end

function TargetName47:__init__()
  self.unit = "target"

  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self._mainFrame = nil
end

function TargetName47:createBar()
  local percentage = 1.0
  self._mainFrame = self.bars:createBar(percentage)

  self:_setFormattedName()

  self:_registerEvents()
  self:_setScriptHandlers()

  self._mainFrame:Hide()
  return self._mainFrame
end

function TargetName47:refreshConfig()
  if self:IsEnabled() then
    self:_handlePlayerTargetChanged()
    self.bars:refreshConfig()
  elseif not self:IsEnabled() then
    self._mainFrame:Hide()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@return table
function TargetName47:_getAppendedEnableOptionTable()
  local options = self.bars:getOptionTable(_DECORATIVE_NAME)
  options.args["enableButton"] = {
    type = "toggle",
    name = "Enable",
    desc = "Enable / Disable Module `" .. _DECORATIVE_NAME .. "`",
    get = function(info)
      return ZxSimpleUI:getModuleEnabledState(_MODULE_NAME)
    end,
    set = function(info, val)
      ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, val)
      self:refreshConfig()
    end,
    order = 1
  }
  return options
end

---@return string formattedName
function TargetName47:_getFormattedName()
  local name = UnitName(self.unit) or ""
  return Utils47:getInitials(name)
end

function TargetName47:_registerEvents()
  self._mainFrame:RegisterEvent("UNIT_HEALTH")
  self._mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function TargetName47:_setScriptHandlers()
  self._mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
end

function TargetName47:_onEventHandler(argsTable, event, unit, ...)
  local isSameEvent = Utils47:stringEqualsIgnoreCase(event, "UNIT_HEALTH")
  local isSameUnit = Utils47:stringEqualsIgnoreCase(unit, self.unit)
  if isSameEvent and isSameUnit then
    self:_handleUnitHealthEvent()
  elseif Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  end
end

function TargetName47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  if curUnitHealth > 0 then self:_setFormattedName() end
end

function TargetName47:_handlePlayerTargetChanged()
  local curUnitName = UnitName(self.unit)
  if curUnitName ~= nil and curUnitName ~= "" then self:_setFormattedName() end
end

function TargetName47:_setFormattedName()
  self._mainFrame.mainText:SetText(self:_getFormattedName())
end
