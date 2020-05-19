local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate

local _MODULE_NAME = "PlayerHealth"
local _DECORATIVE_NAME = "Player Health"
local PlayerHealth = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitName, RegisterUnitWatch = UnitName, RegisterUnitWatch
local ToggleDropDownMenu, PlayerFrameDropDown = ToggleDropDownMenu, PlayerFrameDropDown
local unpack = unpack

PlayerHealth.MODULE_NAME = _MODULE_NAME
PlayerHealth.bars = nil
PlayerHealth._UPDATE_INTERVAL_SECONDS = 0.15
PlayerHealth.unit = "player"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
    positiony = 270,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None"
  }
}

function PlayerHealth:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self.bars:getOptionTable(_DECORATIVE_NAME),
                                   _DECORATIVE_NAME)

  self:__init__()
end

function PlayerHealth:OnEnable()
  self:createBar()
  self:refreshConfig()
end

function PlayerHealth:__init__()
  self._timeSinceLastUpdate = 0
  self._prevHealth = UnitHealthMax(self.unit)
  self._mainFrame = nil
end

function PlayerHealth:refreshConfig()
  if self:IsEnabled() then self.bars:refreshConfig() end
end

function PlayerHealth:createBar()
  local curUnitHealth = UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)

  self._mainFrame = self.bars:createBar(percentage)
  -- Set this so Blizzard's internal engine can find `unit`
  -- Also help RegisterUnitWatch
  self._mainFrame.unit = self.unit
  self._mainFrame:SetAttribute("unit", self._mainFrame.unit)
  -- Handle right click
  self._mainFrame.menu = function()
    ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
  end

  self:_registerEvents()
  self._mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)

  ZxSimpleUI:enableTooltip(self._mainFrame)
  -- Ref: https://wowwiki.fandom.com/wiki/SecureStateDriver
  -- Register left clicks and right clicks as well
  -- Do NOT use SetScript("OnClick", func) !
  RegisterUnitWatch(self._mainFrame, ZxSimpleUI:getUnitWatchState(self._mainFrame.unit))
  self._mainFrame:Show()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param argsTable table
---@param elapsed number
function PlayerHealth:_onUpdateHandler(argsTable, elapsed)
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > self._UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth(self.unit)
    if (curUnitHealth ~= self._prevHealth) then
      self:_handleUnitHealthEvent(curUnitHealth)
      self._prevHealth = curUnitHealth
      self._timeSinceLastUpdate = 0
    end
  end
end

function PlayerHealth:_onClickHandler(argsTable, buttonType, isButtonDown)
  if buttonType == "RightButton" then
    ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
  elseif buttonType == "LeftButton" then
  end
end

function PlayerHealth:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self.bars:_setStatusBarValue(healthPercent)
end

function PlayerHealth:_registerEvents()
  self._mainFrame:RegisterEvent("UNIT_HEALTH")
end
