local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils47 = ZxSimpleUI.Utils47

--- upvalues to prevent warnings
local LibStub = LibStub
local UnitName = UnitName

local _MODULE_NAME = "PlayerName47"
local _DECORATIVE_NAME = "Player Name"
local PlayerName47 = ZxSimpleUI:NewModule(_MODULE_NAME)

PlayerName47.MODULE_NAME = _MODULE_NAME
PlayerName47.bars = nil
PlayerName47.unit = "player"

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

function PlayerName47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getAppendedEnableOptionTable(),
                                   _DECORATIVE_NAME)

  self:__init__()
end

function PlayerName47:OnEnable()
end

function PlayerName47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevName = UnitName(self.unit)
  self._mainFrame = nil
end

---@return table
function PlayerName47:createBar()
  local percentage = 1.0
  self._mainFrame = self.bars:createBar(percentage)
  self.bars:_setTextOnly(self:_getFormattedName())
  self._mainFrame:Show()
  return self._mainFrame
end

function PlayerName47:refreshConfig()
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
function PlayerName47:_getAppendedEnableOptionTable()
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
function PlayerName47:_getFormattedName()
  local name = UnitName(self.unit)
  return Utils47:getInitials(name)
end
