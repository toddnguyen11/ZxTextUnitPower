-- Target appears when
-- 1. Selected
-- 2. Being attacked
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate

local _MODULE_NAME = "TargetHealth"
local _DECORATIVE_NAME = "Target Health"
local TargetHealth = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub, GetScreenWidth, GetScreenHeight = LibStub, GetScreenWidth, GetScreenHeight
local UIParent, CreateFrame, UnitHealth, UnitHealthMax = UIParent, CreateFrame, UnitHealth, UnitHealthMax
local unpack = unpack

TargetHealth.MODULE_NAME = _MODULE_NAME
TargetHealth.bars = nil
TargetHealth._UPDATE_INTERVAL_SECONDS = 0.15

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 280,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None",
  }
}

function TargetHealth:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:isModuleEnabled(_MODULE_NAME))
  local optionsTable = self.bars:getOptionTable(_DECORATIVE_NAME)
  optionsTable = self:_addShowOption(optionsTable)
  ZxSimpleUI:registerModuleOptions(
    _MODULE_NAME, optionsTable, _DECORATIVE_NAME)

  self:__init__()
end

function TargetHealth:OnEnable()
  self:createBar()
  self:refreshConfig()
end

function TargetHealth:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetHealth = UnitHealthMax("Target")
  self._mainFrame = nil
end

function TargetHealth:createBar()
  local targetUnitHealth = UnitHealth("Target")
  local targetUnitMaxHealth = UnitHealthMax("Target")
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitHealth, targetUnitMaxHealth)
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

function TargetHealth:refreshConfig()
  if self:IsEnabled() and self._mainFrame:IsVisible() then
    self.bars:refreshConfig()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetHealth:_registerEvents()
  self._mainFrame:RegisterEvent("UNIT_HEALTH")
  self._mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function TargetHealth:_onEventHandler(argsTable, event, unit)
  if event == "UNIT_HEALTH" then
    self:_handleUnitHealthEvent()
  elseif event == "PLAYER_TARGET_CHANGED" then
    self:_handlePlayerTargetChanged()
  end
end

function TargetHealth:_handlePlayerTargetChanged()
  local targetHealth = UnitHealth("Target")
  if targetHealth > 0 then
    self._mainFrame:Show()
  else
    self._mainFrame:Hide()
  end
end

function TargetHealth:_onUpdateHandler(argsTable, elapsed)
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > self._UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth("Target")
    if (curUnitHealth ~= self._prevTargetHealth) then
      self:_handleUnitHealthEvent(curUnitHealth)
      self._prevTargetHealth = curUnitHealth
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetHealth:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth("Target")
  if (curUnitHealth == 0) then
    self._mainFrame:Hide()
  else
    local maxUnitHealth = UnitHealthMax("Target")
    local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
    self.bars:_setStatusBarValue(healthPercent)
  end
end

function TargetHealth:_addShowOption(optionsTable)
  optionsTable.args["show"] = {
    type = "execute",
    name = "Show Bar",
    desc = "Show/Hide the Target Health",
    func = function()
      if self._mainFrame:IsVisible() then
        self._mainFrame:Hide()
      else
        self._mainFrame:Show()
        self.bars:_setStatusBarValue(0.8)
      end
    end
  }
  return optionsTable
end
