local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate

local _MODULE_NAME = "PlayerHealth"
local _DECORATIVE_NAME = "Player Health"
local PlayerHealth = ZxSimpleUI:NewModule(_MODULE_NAME)
PlayerHealth.MODULE_NAME = _MODULE_NAME
PlayerHealth.bars = nil
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub, GetScreenWidth, GetScreenHeight = LibStub, GetScreenWidth, GetScreenHeight
local UIParent, CreateFrame, UnitHealth, UnitHealthMax = UIParent, CreateFrame, UnitHealth, UnitHealthMax
local unpack = unpack

-- "PRIVATE" variables
local _curDbProfile, _onUpdateHandler
local _timeSinceLastUpdate = 0
local _prevHealth = UnitHealthMax("PLAYER")

PlayerHealth._UPDATE_INTERVAL_SECONDS = 0.15
PlayerHealth._HealthBarFrame = nil

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
    positiony = 280,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None",
  }
}

function PlayerHealth:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  _curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(_curDbProfile)

  self:SetEnabledState(ZxSimpleUI:isModuleEnabled(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(
    _MODULE_NAME, self.bars:getOptionTable(_DECORATIVE_NAME), _DECORATIVE_NAME)
end

function PlayerHealth:OnEnable()
  self:createBar()
  self:refreshConfig()
end

function PlayerHealth:refreshConfig()
  if self:IsEnabled() then
    self.bars:refreshConfig()
  end
end

function PlayerHealth:createBar()
  local curUnitHealth = UnitHealth("Player")
  local maxUnitHealth = UnitHealthMax("Player")
  local healthPercent = curUnitHealth / maxUnitHealth

  self._HealthBarFrame = self.bars:createBar(healthPercent)

  self:_registerEvents()
  self._HealthBarFrame:SetScript("OnUpdate", _onUpdateHandler)
  self._HealthBarFrame:Show()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param elapsed number
function _onUpdateHandler(self, elapsed)
  _timeSinceLastUpdate = _timeSinceLastUpdate + elapsed
  if (_timeSinceLastUpdate > PlayerHealth._UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth("Player")
    if (curUnitHealth ~= _prevHealth) then
      PlayerHealth:_handleUnitHealthEvent(curUnitHealth)
      _prevHealth = curUnitHealth
      _timeSinceLastUpdate = 0
    end
  end
end

function PlayerHealth:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth("Player")
  local maxUnitHealth = UnitHealthMax("Player")
  local healthPercent = curUnitHealth / maxUnitHealth
  PlayerHealth._HealthBarFrame.Text:SetText(string.format("%.1f%%", healthPercent * 100.0))
  PlayerHealth._HealthBarFrame.statusBar:SetValue(healthPercent)
end

function PlayerHealth:_registerEvents()
  self._HealthBarFrame:RegisterEvent("UNIT_HEALTH")
end
