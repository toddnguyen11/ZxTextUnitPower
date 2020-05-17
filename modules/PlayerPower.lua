local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local _MODULE_NAME = "PlayerPower"
local _DECORATIVE_NAME = "Player Power"
local PlayerPower = ZxSimpleUI:NewModule(_MODULE_NAME)
PlayerPower.MODULE_NAME = _MODULE_NAME
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub, GetScreenWidth, GetScreenHeight = LibStub, GetScreenWidth, GetScreenHeight
local UIParent, CreateFrame, UnitPower, UnitPowerMax = UIParent, CreateFrame, UnitPower, UnitPowerMax
local UnitClass = UnitClass
local unpack = unpack

-- "PRIVATE" variables
local _getOption, _setOption, _getOptionColor, _setOptionColor
local _curDbProfile
local _handle_positionx_center, _handle_positiony_center, _handle_unit_power_event
local _get_power_percent
local _incrementOrderIndex
local _orderIndex = 1
local _prevPowerValue = UnitPowerMax("PLAYER")
local _playerClass = UnitClass("PLAYER")

PlayerPower._SCREEN_WIDTH = math.floor(GetScreenWidth())
PlayerPower._SCREEN_HEIGHT = math.floor(GetScreenHeight())
PlayerPower._PowerBarFrame = nil

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 400,
    positiony = 250,
    fontsize = 14,
    font = "Friz Quadrata TT",
    texture = "Blizzard",
    color = {0.0, 0.0, 1.0, 1.0},
    border = "None"
  }
}

local _powerEventTable = {}
table.insert(_powerEventTable, "UNIT_MANA")
table.insert(_powerEventTable, "UNIT_RAGE")
table.insert(_powerEventTable, "UNIT_ENERGY")
table.insert(_powerEventTable, "UNIT_RUNIC_POWER")

local _frameBackdropTable = {
  bgFile = "Interface\\DialogFrame\\UI-Tooltip-Background",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

function PlayerPower:OnInitialize()
  self:_setDefaultColor()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  _curDbProfile = self.db.profile
  self:_setDefaultColor()
  self:CreateBar()

  self:SetEnabledState(ZxSimpleUI:isModuleEnabled(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getOptionTable(), _DECORATIVE_NAME)
end

function PlayerPower:OnEnable()
  self:refreshConfig()
end

function PlayerPower:refreshConfig()
  if self:IsEnabled() then
    self:_setFrameWidthHeight()
    self:_refreshPowerBarFrame()
    self:_refreshStatusBar()
  end
end

function PlayerPower:CreateBar()
  self._PowerBarFrame = CreateFrame("Frame", nil, UIParent)
  self._PowerBarFrame:SetBackdrop(_frameBackdropTable)
  self._PowerBarFrame:SetBackdropColor(1, 0, 0, 1)
  self._PowerBarFrame:SetPoint(
    "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    _curDbProfile.positionx,
    _curDbProfile.positiony
  )

  self._PowerBarFrame.bgFrame = self._PowerBarFrame:CreateTexture(nil, "BACKGROUND")
  self._PowerBarFrame.bgFrame:SetTexture(0, 0, 0, 0.8)
  self._PowerBarFrame.bgFrame:SetAllPoints()

  self._PowerBarFrame.StatusBar = CreateFrame("StatusBar", nil, self._PowerBarFrame)
  self._PowerBarFrame.StatusBar:ClearAllPoints()
  self._PowerBarFrame.StatusBar:SetPoint("CENTER", self._PowerBarFrame, "CENTER")
  self._PowerBarFrame.StatusBar:SetStatusBarTexture(media:Fetch("statusbar", _curDbProfile.texture))
  self._PowerBarFrame.StatusBar:GetStatusBarTexture():SetHorizTile(false)
  self._PowerBarFrame.StatusBar:GetStatusBarTexture():SetVertTile(false)
  self._PowerBarFrame.StatusBar:SetStatusBarColor(unpack(_curDbProfile.color))
  self._PowerBarFrame.StatusBar:SetMinMaxValues(0, 1)
  self:_setFrameWidthHeight()

  self._PowerBarFrame.Text = self._PowerBarFrame.StatusBar:CreateFontString(nil, "OVERLAY")
  self._PowerBarFrame.Text:SetFont(
      media:Fetch("font", _curDbProfile.font),
      _curDbProfile.fontsize, "OUTLINE")
  self._PowerBarFrame.Text:SetTextColor(1.0, 1.0, 1.0, 1.0)
  self._PowerBarFrame.Text:SetPoint("CENTER", self._PowerBarFrame.StatusBar, "CENTER", 0, 0)
  self._PowerBarFrame.Text:SetText(string.format("%.1f%%", _get_power_percent() * 100.0))

  self:_registerEvents()
  self._PowerBarFrame:SetScript("OnUpdate", _handle_unit_power_event)
  self._PowerBarFrame:Show()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

local options = nil

---@return table
function PlayerPower:_getOptionTable()
  if not options then
    options = {
      type = "group",
      name = _DECORATIVE_NAME,
      get = _getOption,
      set = _setOption,
      args = {
        width = {
          name = "Power Bar Width",
          desc = "Power Bar Width Size",
          type = "range",
          min = 0, max = math.floor(self._SCREEN_WIDTH / 2),
          step = 2,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex(),
        },
        height = {
          name = "Power Bar Height",
          desc = "Power Bar Height Size",
          type = "range",
          min = 0, max = math.floor(self._SCREEN_WIDTH / 2),
          step = 2,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex(),
        },
        positionx = {
          name = "Power Bar X",
          desc = "Power Bar X Position",
          type = "range",
          min = 0, max = self._SCREEN_WIDTH,
          step = 1,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex()
        },
        positionx_center = {
          name = "Center Power Bar X",
          desc = "Center Power Bar X Position",
          type = "execute",
          func = _handle_positionx_center,
          order = _incrementOrderIndex()
        },
        positiony = {
          name = "Power Bar Y",
          desc = "Power Bar Y Position",
          type = "range",
          min = 0, max = self._SCREEN_HEIGHT,
          step = 1,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex()
        },
        positiony_center = {
          name = "Center Power Bar Y",
          desc = "Center Power Bar Y Position",
          type = "execute",
          func = _handle_positiony_center,
          order = _incrementOrderIndex()
        },
        fontsize = {
          name = "Power Bar Font Size",
          desc = "Power Bar Font Size",
          type = "range",
          min = 10, max = 36,
          step = 1,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex(),
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Power Bar Font",
          desc = "Power Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = _incrementOrderIndex()
        },
        texture = {
          name = "Power Bar Texture",
          desc = "Power Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = _incrementOrderIndex()
        },
        border = {
          name = "Power Bar Border",
          desc = "Power Bar Border",
          type = "select",
          dialogControl = "LSM30_Border",
          values = media:HashTable("border"),
          order = _incrementOrderIndex()
        },
        color = {
          name = "Power Bar Color",
          desc = "Power Bar Color",
          type = "color",
          get = _getOptionColor,
          set = _setOptionColor,
          hasAlpha = true
        }
      }
    }
  end
  return options
end

---@param infoTable table
function _getOption(infoTable)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  return _curDbProfile[key]
end

---@param infoTable table
---@param value any
function _setOption(infoTable, value)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  _curDbProfile[key] = value
  PlayerPower:refreshConfig()
end

---@param infoTable table
function _getOptionColor(infoTable)
  return unpack(_getOption(infoTable))
end

---@param infoTable table
function _setOptionColor(infoTable, ...)
  _setOption(infoTable, {...})
end

function _incrementOrderIndex()
  local i = _orderIndex
  _orderIndex = _orderIndex + 1
  return i
end

function _handle_positionx_center()
  local width = _curDbProfile.width

  local centerXPos = math.floor(PlayerPower._SCREEN_WIDTH / 2 - width / 2)
  _curDbProfile.positionx = centerXPos
  PlayerPower:refreshConfig()
end

function _handle_positiony_center()
  local height = _curDbProfile.height

  local centerYPos = math.floor(PlayerPower._SCREEN_HEIGHT / 2 - height / 2)
  _curDbProfile.positiony = centerYPos
  PlayerPower:refreshConfig()
end

function _handle_unit_power_event(self, event, unit)
  local curUnitPower = UnitPower("Player")
  if (curUnitPower ~= _prevPowerValue) then
    _prevPowerValue = curUnitPower
    local maxUnitPower = UnitPowerMax("Player")
    local PowerPercent = curUnitPower / maxUnitPower
    PlayerPower._PowerBarFrame.Text:SetText(string.format("%.1f%%", PowerPercent * 100.0))
    PlayerPower._PowerBarFrame.StatusBar:SetValue(PowerPercent)
  end
end

---@return number
function _get_power_percent()
  local curUnitPower = UnitPower("Player")
  local maxUnitPower = UnitPowerMax("Player")
  return curUnitPower / maxUnitPower
end

function PlayerPower:_setFrameWidthHeight()
  self._PowerBarFrame:SetWidth(_curDbProfile.width)
  self._PowerBarFrame:SetHeight(_curDbProfile.height)
  self._PowerBarFrame.bgFrame:SetWidth(self._PowerBarFrame:GetWidth())
  self._PowerBarFrame.bgFrame:SetHeight(self._PowerBarFrame:GetHeight())
  self._PowerBarFrame.StatusBar:SetWidth(self._PowerBarFrame:GetWidth())
  self._PowerBarFrame.StatusBar:SetHeight(self._PowerBarFrame:GetHeight())
end

function PlayerPower:_refreshPowerBarFrame()
  self._PowerBarFrame:SetPoint(
    "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    _curDbProfile.positionx,
    _curDbProfile.positiony
  )
  self._PowerBarFrame.Text:SetFont(
    media:Fetch("font", _curDbProfile.font),
    _curDbProfile.fontsize, "OUTLINE"
  )
  _frameBackdropTable.edgeFile = media:Fetch("border", _curDbProfile.border)
  self._PowerBarFrame:SetBackdrop(_frameBackdropTable)
end

function PlayerPower:_refreshStatusBar()
  self._PowerBarFrame.StatusBar:SetStatusBarTexture(media:Fetch("statusbar", _curDbProfile.texture))
  self._PowerBarFrame.StatusBar:SetStatusBarColor(unpack(_curDbProfile.color))
end

function PlayerPower:_registerEvents()
  for _, powerEvent in ipairs(_powerEventTable) do
    self._PowerBarFrame:RegisterEvent(powerEvent)
  end
end

function PlayerPower:_setDefaultColor()
  local classUpper = string.upper(_playerClass)
  if classUpper == "ROGUE" then
    _defaults.profile.color = {1, 1, 0, 1}
  elseif classUpper == "WARRIOR" then
    _defaults.profile.color = {1, 0, 0, 1}
  end
end
