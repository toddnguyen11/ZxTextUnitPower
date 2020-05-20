-- Target appears when
-- 1. Selected
-- 2. Being attacked
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "TargetPower47"
local _DECORATIVE_NAME = "Target Power"
local TargetPower47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitName = UnitName
local UnitHealth, UnitPowerType = UnitHealth, UnitPowerType
local ToggleDropDownMenu, TargetFrameDropDown = ToggleDropDownMenu, TargetFrameDropDown
local unpack = unpack

TargetPower47.MODULE_NAME = _MODULE_NAME
TargetPower47.bars = nil
TargetPower47.unit = "target"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 240,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 1.0, 1.0},
    border = "None"
  }
}

local _powerEventColorTable = {}
_powerEventColorTable["UNIT_MANA"] = {0.0, 0.0, 1.0, 1.0}
_powerEventColorTable["UNIT_RAGE"] = {1.0, 0.0, 0.0, 1.0}
_powerEventColorTable["UNIT_ENERGY"] = {1.0, 1.0, 0.0, 1.0}
_powerEventColorTable["UNIT_RUNIC_POWER"] = {0.0, 1.0, 1.0, 1.0}

local _unitPowerTypeTable = {}
_unitPowerTypeTable["MANA"] = 0
_unitPowerTypeTable["RAGE"] = 1
_unitPowerTypeTable["FOCUS"] = 2
_unitPowerTypeTable["ENERGY"] = 3
_unitPowerTypeTable["COMBOPOINTS"] = 4
_unitPowerTypeTable["RUNES"] = 5
_unitPowerTypeTable["RUNICPOWER"] = 6

function TargetPower47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  local optionsTable = self.bars:getOptionTable(_DECORATIVE_NAME)
  optionsTable = self:_addShowOption(optionsTable)
  optionsTable.args.color = nil
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, optionsTable, _DECORATIVE_NAME)

  self:__init__()
end

function TargetPower47:OnEnable()
end

function TargetPower47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetPower47 = UnitPowerMax(self.unit)
  self._mainFrame = nil
  self._powerType, self._powerTypeString = nil, nil
end

function TargetPower47:createBar()
  self:_setUnitPowerType()
  local targetUnitPower = UnitPower(self.unit)
  local targetUnitMaxPower = UnitPowerMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitPower, targetUnitMaxPower)
  self._mainFrame = self.bars:createBar(percentage)

  self:_registerEvents()
  self:_setScriptHandlers()

  self._mainFrame:Hide()
  return self._mainFrame
end

function TargetPower47:refreshConfig()
  if self:IsEnabled() and self._mainFrame:IsVisible() then self.bars:refreshConfig() end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetPower47:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self._mainFrame:RegisterEvent(powerEvent)
  end
  self._mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  self._mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function TargetPower47:_setScriptHandlers()
  self._mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
  self._mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
end

function TargetPower47:_onEventHandler(argsTable, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(unit, self.unit) then
    if Utils47:stringEqualsIgnoreCase(event, "UNIT_DISPLAYPOWER") then
      self:_handlePowerChanged()
    elseif _powerEventColorTable[event] ~= nil then
      self:_handleUnitPowerEvent()
    end
  end
end

function TargetPower47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then self:_setColor() end
end

function TargetPower47:_handlePowerChanged()
  self:_setUnitPowerType()
  self:refreshConfig()
  self:_setColor()
end

function TargetPower47:_handleUnitPowerEvent(curUnitPower)
  local currentHealth = UnitHealth(self.unit)
  if currentHealth > 0 then
    curUnitPower = curUnitPower or UnitPower(self.unit)
    local maxUnitPower = UnitPowerMax(self.unit)
    local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
    self.bars:_setStatusBarValue(powerPercent)
  end
end

function TargetPower47:_onUpdateHandler(argsTable, elapsed)
  if not self._mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower(self.unit)
    if (curUnitPower ~= self._prevTargetPower47) then
      self:_handleUnitPowerEvent(curUnitPower)
      self._prevTargetPower47 = curUnitPower
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetPower47:_addShowOption(optionsTable)
  optionsTable.args["show"] = {
    type = "execute",
    name = "Show Bar",
    desc = "Show/Hide the Target Power",
    func = function()
      if self._mainFrame:IsVisible() then
        self._mainFrame:Hide()
      else
        self:_setColor()
        self.bars:_setStatusBarValue(0.8)
      end
    end
  }
  return optionsTable
end

function TargetPower47:_setUnitPowerType()
  self._powerType, self._powerTypeString = UnitPowerType(self.unit)
end

function TargetPower47:_setColor()
  self:_setUnitPowerType()
  local upperType = string.upper(self._powerTypeString)
  local colorTable = _powerEventColorTable["UNIT_" .. upperType]
  self._mainFrame.statusBar:SetStatusBarColor(unpack(colorTable))
end
