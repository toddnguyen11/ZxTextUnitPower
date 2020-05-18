local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate

local _MODULE_NAME = "PlayerPower"
local _DECORATIVE_NAME = "Player Power"
local PlayerPower = ZxSimpleUI:NewModule(_MODULE_NAME)
PlayerPower.MODULE_NAME = _MODULE_NAME
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame, UnitPower, UnitPowerMax = UIParent, CreateFrame, UnitPower, UnitPowerMax
local UnitClass, UnitPowerType = UnitClass, UnitPowerType
local unpack = unpack

PlayerPower._UPDATE_INTERVAL_SECONDS = 0.15

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
    positiony = 250,
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


function PlayerPower:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:isModuleEnabled(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME,
    self.bars:getOptionTable(_DECORATIVE_NAME), _DECORATIVE_NAME)

  self:__init__()
end

function PlayerPower:OnEnable()
  self:_setUnitPowerType()
  self:_setDefaultColor()
  self:createBar()
  self:refreshConfig()
end

function PlayerPower:__init__()
  self._mainFrame = nil
  self._timeSinceLastUpdate = 0
  self._prevPowerValue = UnitPowerMax("PLAYER")
  self._playerClass = UnitClass("PLAYER")
  self._playerPower = 0
  self._playerPowerString = ""
end

function PlayerPower:refreshConfig()
  if self:IsEnabled() then
    self.bars:refreshConfig()
  end
end

function PlayerPower:createBar()
  local curUnitPower = UnitPower("PLAYER")
  local maxUnitPower = UnitPowerMax("PLAYER")
  local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)

  self._mainFrame = self.bars:createBar(powerPercent)

  self:_registerEvents()
  self._mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
  self._mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
  self._mainFrame:Show()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param argsTable table
---@param elapsed number
function PlayerPower:_onUpdateHandler(argsTable, elapsed)
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > self._UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower("PLAYER")
    if (curUnitPower ~= self._prevPowerValue) then
      PlayerPower:_setPowerValue(curUnitPower)
      self._prevPowerValue = curUnitPower
      self._timeSinceLastUpdate = 0
    end
  end
end

---@param argsTable table
---@param event string
---@param unit string
function PlayerPower:_onEventHandler(argsTable, event, unit)
  local upperEvent = string.upper(event)
  local upperUnit = string.upper(unit)
  if (upperEvent == "UNIT_DISPLAYPOWER" and upperUnit == "PLAYER") then
    PlayerPower:_handlePowerChanged()
  end
end

---@param curUnitPower number
function PlayerPower:_setPowerValue(curUnitPower)
  curUnitPower = curUnitPower or UnitPower("PLAYER")
  local maxUnitPower = UnitPowerMax("PLAYER")
  local powerPercent = ZxSimpleUI:calcPercentSafely(curUnitPower, maxUnitPower)
  self.bars:_setStatusBarValue(powerPercent)
end

function PlayerPower:_handlePowerChanged()
  self:_setUnitPowerType()
  self:_setDefaultColor()
  self:refreshConfig()
end

function PlayerPower:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self._mainFrame:RegisterEvent(powerEvent)
  end
  -- Register Druid's shapeshift form
  self._mainFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function PlayerPower:_setUnitPowerType()
  self._playerPower, self._playerPowerString = UnitPowerType("PLAYER")
end

function PlayerPower:_setDefaultColor()
  local powerTypeUpper = string.upper(self._playerPowerString)
  local colorTable = _powerEventColorTable["UNIT_" .. powerTypeUpper]
  _defaults.profile.color = colorTable
  self._curDbProfile.color = colorTable
end
