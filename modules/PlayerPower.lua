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

-- "PRIVATE" variables
local _curDbProfile
local _onUpdateHandler, _onEventHandler
local _timeSinceLastUpdate = 0
local _prevPowerValue = UnitPowerMax("PLAYER")
local _playerClass = UnitClass("PLAYER")
local _playerPower, _playerPowerString

PlayerPower._UPDATE_INTERVAL_SECONDS = 0.15
PlayerPower._PowerBarFrame = nil

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

function PlayerPower:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  _curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(_curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:isModuleEnabled(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME,
    self.bars:getOptionTable(_DECORATIVE_NAME), _DECORATIVE_NAME)
end

function PlayerPower:OnEnable()
  self:_setUnitPowerType()
  self:_setDefaultColor()
  self:createBar()
  self:refreshConfig()
end

function PlayerPower:refreshConfig()
  if self:IsEnabled() then
    self.bars:refreshConfig()
  end
end

function PlayerPower:createBar()
  local curUnitPower = UnitPower("PLAYER")
  local maxUnitPower = UnitPowerMax("PLAYER")
  local powerPercent = curUnitPower / maxUnitPower

  self._PowerBarFrame = self.bars:createBar(powerPercent)

  self:_registerEvents()
  self._PowerBarFrame:SetScript("OnUpdate", _onUpdateHandler)
  self._PowerBarFrame:SetScript("OnEvent", _onEventHandler)
  self._PowerBarFrame:Show()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param self any
---@param elapsed number
function _onUpdateHandler(self, elapsed)
  _timeSinceLastUpdate = _timeSinceLastUpdate + elapsed
  if (_timeSinceLastUpdate > PlayerPower._UPDATE_INTERVAL_SECONDS) then
    local curUnitPower = UnitPower("PLAYER")
    if (curUnitPower ~= _prevPowerValue) then
      PlayerPower:_setPowerValue(curUnitPower)
      _prevPowerValue = curUnitPower
      _timeSinceLastUpdate = 0
    end
  end
end

function _onEventHandler(self, event, unit)
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
  local powerPercent = curUnitPower / maxUnitPower
  self._PowerBarFrame.text:SetText(string.format("%.1f%%", powerPercent * 100.0))
  self._PowerBarFrame.statusBar:SetValue(powerPercent)
end

function PlayerPower:_handlePowerChanged()
  self:_setUnitPowerType()
  self:_setDefaultColor()
  self:refreshConfig()
end

function PlayerPower:_registerEvents()
  for powerEvent, _ in pairs(_powerEventColorTable) do
    self._PowerBarFrame:RegisterEvent(powerEvent)
  end
  -- Register Druid's shapeshift form
  self._PowerBarFrame:RegisterEvent("UNIT_DISPLAYPOWER")
end

function PlayerPower:_setUnitPowerType()
  _playerPower, _playerPowerString = UnitPowerType("PLAYER")
end

function PlayerPower:_setDefaultColor()
  local powerTypeUpper = string.upper(_playerPowerString)
  local colorTable = _powerEventColorTable["UNIT_" .. powerTypeUpper]
  _defaults.profile.color = colorTable
  _curDbProfile.color = colorTable
end
