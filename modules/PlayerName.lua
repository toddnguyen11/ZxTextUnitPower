local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils = ZxSimpleUI.Utils

local _MODULE_NAME = "PlayerName"
local _DECORATIVE_NAME = "Player Name"
local PlayerName = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame, UnitName = UIParent, CreateFrame, UnitName
local ToggleDropDownMenu, PlayerFrameDropDown = ToggleDropDownMenu, PlayerFrameDropDown
local RegisterUnitWatch = RegisterUnitWatch
local unpack = unpack

PlayerName.MODULE_NAME = _MODULE_NAME
PlayerName.bars = nil
PlayerName._UPDATE_INTERVAL_SECONDS = 0.15
PlayerName.unit = "player"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
    positiony = 300,
    fontsize = 12,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 0.0, 0.0, 1.0},
    border = "None"
  }
}

function PlayerName:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getAppendedEnableOptionTable(),
                                   _DECORATIVE_NAME)

  self:__init__()
end

function PlayerName:OnEnable()
  self:createBar()
  self:refreshConfig()
end

function PlayerName:__init__()
  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self._mainFrame = nil
end

function PlayerName:createBar()
  local percentage = 1.0

  self._mainFrame = self.bars:createBar(percentage)
  -- Set this so Blizzard's internal engine can find `unit`
  self._mainFrame.unit = self.unit
  self._mainFrame:SetAttribute("unit", self._mainFrame.unit)
  -- Handle right click
  self._mainFrame.menu = function(...)
    print(...)
    ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
  end

  self.bars:_setTextOnly(self:_getFormattedName())
  -- Ref: https://wowwiki.fandom.com/wiki/SecureStateDriver
  -- Register left clicks and right clicks as well
  -- Do NOT use SetScript("OnClick", func) !
  RegisterUnitWatch(self._mainFrame, ZxSimpleUI:getUnitWatchState(self._mainFrame.unit))
  self._mainFrame:Show()
end

function PlayerName:refreshConfig()
  if self:IsEnabled() then
    self.bars:refreshConfig()
    self._mainFrame:Show()
  else
    self._mainFrame:Hide()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@return table
function PlayerName:_getAppendedEnableOptionTable()
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
function PlayerName:_getFormattedName()
  local name = UnitName(self.unit)
  return Utils:getInitials(name)
end
