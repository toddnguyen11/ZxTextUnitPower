local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils = ZxSimpleUI.Utils

local _MODULE_NAME = "TargetName"
local _DECORATIVE_NAME = "Target Name"
local TargetName = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame, UnitName = UIParent, CreateFrame, UnitName
local UnitName, UnitHealth = UnitName, UnitHealth
local unpack = unpack

TargetName.MODULE_NAME = _MODULE_NAME
TargetName.bars = nil
TargetName._UPDATE_INTERVAL_SECONDS = 0.15

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
    border = "None",
  }
}

function TargetName:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(
    _MODULE_NAME, self:_getAppendedEnableOptionTable(), _DECORATIVE_NAME)

  self:__init__()
end

function TargetName:OnEnable()
  self:createBar()
  self:refreshConfig()
end

function TargetName:__init__()
  self._timeSinceLastUpdate = 0
  self._prevName = UnitName("TARGET")
  self._mainFrame = nil
end

function TargetName:createBar()
  local percentage = 1.0
  self._mainFrame = self.bars:createBar(percentage)
  self:_setFormattedName()

  self:_registerEvents()
  self._mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
  self._mainFrame:Hide()
end

function TargetName:refreshConfig()
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
function TargetName:_getAppendedEnableOptionTable()
  local options = self.bars:getOptionTable(_DECORATIVE_NAME)
  options.args["enableButton"] = {
      type = "toggle",
      name = "Enable",
      desc = "Enable / Disable Module `" .. _DECORATIVE_NAME .. "`",
      get = function(info) return ZxSimpleUI:getModuleEnabledState(_MODULE_NAME) end,
      set = function(info, val)
        ZxSimpleUI:setModuleEnabledState(_MODULE_NAME, val)
        self:refreshConfig()
      end,
      order = 1
  }
  return options
end

---@return string formattedName
function TargetName:_getFormattedName()
  local name = UnitName("TARGET") or ""
  return Utils:getInitials(name)
end

function TargetName:_registerEvents()
  self._mainFrame:RegisterEvent("UNIT_HEALTH")
  self._mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function TargetName:_onEventHandler(argsTable, event, unit, ...)
  if event == "UNIT_HEALTH" and string.upper(unit) == "TARGET" then
    self:_handleUnitHealthEvent()
  elseif event == "PLAYER_TARGET_CHANGED" then
    self:_handlePlayerTargetChanged()
  end
end

function TargetName:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth("TARGET")
  if curUnitHealth > 0 then
    self:_setFormattedName()
    self._mainFrame:Show()
  else
    self._mainFrame:Hide()
  end
end

function TargetName:_handlePlayerTargetChanged()
  local targetName = UnitName("TARGET")
  if targetName ~= nil and targetName ~= "" then
    self:_setFormattedName()
    self._mainFrame:Show()
  else
    self._mainFrame:Hide()
  end
end

function TargetName:_setFormattedName()
  self._mainFrame.mainText:SetText(self:_getFormattedName())
end
