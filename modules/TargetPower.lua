-- Target appears when
-- 1. Selected
-- 2. Being attacked
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate

local _MODULE_NAME = "TargetPower"
local _DECORATIVE_NAME = "Target Power"
local TargetPower = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame, UnitPower, UnitPowerMax = UIParent, CreateFrame, UnitPower, UnitPowerMax
local UnitHealth, UnitPowerType = UnitHealth, UnitPowerType
local unpack = unpack

TargetPower.MODULE_NAME = _MODULE_NAME
TargetPower.bars = nil
TargetPower._UPDATE_INTERVAL_SECONDS = 0.15

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 250,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 1.0, 1.0},
    border = "None",
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

function TargetPower:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:isModuleEnabled(_MODULE_NAME))
  local optionsTable = self.bars:getOptionTable(_DECORATIVE_NAME)
  optionsTable = self:_addShowOption(optionsTable)
  optionsTable.args.color = nil
  ZxSimpleUI:registerModuleOptions(
    _MODULE_NAME, optionsTable, _DECORATIVE_NAME)

  self:__init__()
end

function TargetPower:OnEnable()
  self:_setUnitPowerType()
  self:createBar()
  self:refreshConfig()
end

function TargetPower:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetPower = UnitPowerMax("Target")
  self._mainFrame = nil
end

function TargetPower:createBar()
  local targetUnitPower = UnitPower("Target")
  local targetUnitMaxPower = UnitPowerMax("Target")
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitPower, targetUnitMaxPower)
  self._mainFrame = self.bars:createBar(percentage)

  self:_registerEvents()
  self._mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
  self._mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
  self._mainFrame:Hide()
end

function TargetPower:refreshConfig()
  if self:IsEnabled() and self._mainFrame:IsVisible() then
    self.bars:refreshConfig()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetPower:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self._mainFrame:RegisterEvent(powerEvent)
  end
  self._mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function TargetPower:_onEventHandler(argsTable, event, unit)
  if event == "PLAYER_TARGET_CHANGED" then
    self:_handlePlayerTargetChanged()
  elseif _powerEventColorTable[event] ~= nil then
    self:_handleUnitPowerEvent()
  end
end

function TargetPower:_handlePlayerTargetChanged()
  local currentHealth = UnitHealth("Target")
  if currentHealth > 0 then
    self:_setColorThenShow()
  else
    self._mainFrame:Hide()
  end
end

function TargetPower:_onUpdateHandler(argsTable, elapsed)
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > self._UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower("Target")
    if (curUnitPower ~= self._prevTargetPower) then
      self:_handleUnitPowerEvent(curUnitPower)
      self._prevTargetPower = curUnitPower
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetPower:_handleUnitPowerEvent(curUnitPower)
  local currentHealth = UnitHealth("Target")
  if currentHealth <= 0 then
    self._mainFrame:Hide()
  else
    curUnitPower = curUnitPower or UnitPower("Target")
    local maxUnitPower = UnitPowerMax("Target")
    local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
    self.bars:_setStatusBarValue(powerPercent)
  end
end

function TargetPower:_addShowOption(optionsTable)
  optionsTable.args["show"] = {
    type = "execute",
    name = "Show Bar",
    desc = "Show/Hide the Target Power",
    func = function()
      if self._mainFrame:IsVisible() then
        self._mainFrame:Hide()
      else
        self:_setColorThenShow()
        self.bars:_setStatusBarValue(0.8)
      end
    end
  }
  return optionsTable
end

function TargetPower:_setUnitPowerType()
  self._targetPowerType, self._targetPowerTypeString = UnitPowerType("Target")
end

function TargetPower:_setColorThenShow()
  self:_setUnitPowerType()
  local upperType = string.upper(self._targetPowerTypeString)
  self._mainFrame.statusBar:SetStatusBarColor(
    unpack(_powerEventColorTable["UNIT_" .. upperType]))
  self._mainFrame:Show()
end
