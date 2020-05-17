local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local _MODULE_NAME = "PlayerHealth"
local _DECORATIVE_NAME = "Player Health"
local PlayerHealth = ZxSimpleUI:NewModule(_MODULE_NAME)
PlayerHealth.MODULE_NAME = _MODULE_NAME
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub, GetScreenWidth, GetScreenHeight = LibStub, GetScreenWidth, GetScreenHeight
local UIParent, CreateFrame, UnitHealth, UnitHealthMax = UIParent, CreateFrame, UnitHealth, UnitHealthMax
local unpack = unpack

-- "PRIVATE" variables
local _getOption, _setOption, _getOptionColor, _setOptionColor
local _curDbProfile
local _handle_positionx_center, _handle_positiony_center, _handle_unit_health_event
local _get_health_percent
local _incrementOrderIndex
local _orderIndex = 1
PlayerHealth._SCREEN_WIDTH = math.floor(GetScreenWidth())
PlayerHealth._SCREEN_HEIGHT = math.floor(GetScreenHeight())

PlayerHealth._HealthBarFrame = nil

local _defaults = {
  profile = {
    width = 200,
    height = 200,
    positionx = 1,
    positiony = 1,
    fontsize = 14,
    font = "Friz Quadrata TT",
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0}
  }
}

local _frameBackdropTable = {
  bgFile = "Interface\\DialogFrame\\UI-Tooltip-Background",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

function PlayerHealth:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  _curDbProfile = self.db.profile
  self:CreateBar()

  self:SetEnabledState(ZxSimpleUI:isModuleEnabled(_MODULE_NAME))
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, self:_getOptionTable(), _DECORATIVE_NAME)
end

function PlayerHealth:OnEnable()
  self:refreshConfig()
end

function PlayerHealth:refreshConfig()
  if self:IsEnabled() then
    self:_setFrameWidthHeight()
    self:_refreshHealthBarFrame()
    self:_refreshStatusBar()
  end
end

function PlayerHealth:CreateBar()
  self._HealthBarFrame = CreateFrame("Frame", nil, UIParent)
  self._HealthBarFrame:SetBackdrop(_frameBackdropTable)
  self._HealthBarFrame:SetBackdropColor(1, 0, 0, 1)
  self._HealthBarFrame:SetPoint(
    "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    _curDbProfile.positionx,
    _curDbProfile.positiony
  )

  self._HealthBarFrame.bgFrame = self._HealthBarFrame:CreateTexture(nil, "BACKGROUND")
  self._HealthBarFrame.bgFrame:SetTexture(0, 0, 0, 0.8)
  self._HealthBarFrame.bgFrame:SetAllPoints()

  self._HealthBarFrame.StatusBar = CreateFrame("StatusBar", nil, self._HealthBarFrame)
  self._HealthBarFrame.StatusBar:ClearAllPoints()
  self._HealthBarFrame.StatusBar:SetPoint("CENTER", self._HealthBarFrame, "CENTER")
  self._HealthBarFrame.StatusBar:SetStatusBarTexture(media:Fetch("statusbar", _curDbProfile.texture))
  self._HealthBarFrame.StatusBar:GetStatusBarTexture():SetHorizTile(false)
  self._HealthBarFrame.StatusBar:GetStatusBarTexture():SetVertTile(false)
  self._HealthBarFrame.StatusBar:SetStatusBarColor(unpack(_curDbProfile.color))
  self._HealthBarFrame.StatusBar:SetMinMaxValues(0, 1)
  self:_setFrameWidthHeight()

  self._HealthBarFrame.Text = self._HealthBarFrame.StatusBar:CreateFontString(nil, "OVERLAY")
  self._HealthBarFrame.Text:SetFont(
      media:Fetch("font", _curDbProfile.font),
      _curDbProfile.fontsize, "OUTLINE")
  self._HealthBarFrame.Text:SetTextColor(1.0, 1.0, 1.0, 1.0)
  self._HealthBarFrame.Text:SetPoint("CENTER", self._HealthBarFrame.StatusBar, "CENTER", 0, 0)
  self._HealthBarFrame.Text:SetText(string.format("%.1f%%", _get_health_percent() * 100.0))

  self._HealthBarFrame:RegisterEvent("UNIT_HEALTH")
  self._HealthBarFrame:SetScript("OnEvent", _handle_unit_health_event)
  self._HealthBarFrame:Show()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

local options = nil

---@return table
function PlayerHealth:_getOptionTable()
  if not options then
    options = {
      type = "group",
      name = _DECORATIVE_NAME,
      get = _getOption,
      set = _setOption,
      args = {
        width = {
          name = "Health Bar Width",
          desc = "Health Bar Width Size",
          type = "range",
          min = 0, max = math.floor(self._SCREEN_WIDTH / 2),
          step = 2,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex(),
        },
        height = {
          name = "Health Bar Height",
          desc = "Health Bar Height Size",
          type = "range",
          min = 0, max = math.floor(self._SCREEN_WIDTH / 2),
          step = 2,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex(),
        },
        positionx = {
          name = "Health Bar X",
          desc = "Health Bar X Position",
          type = "range",
          min = 0, max = self._SCREEN_WIDTH,
          step = 1,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex()
        },
        positionx_center = {
          name = "Center Health Bar X",
          desc = "Center Health Bar X Position",
          type = "execute",
          func = _handle_positionx_center,
          order = _incrementOrderIndex()
        },
        positiony = {
          name = "Health Bar Y",
          desc = "Health Bar Y Position",
          type = "range",
          min = 0, max = self._SCREEN_HEIGHT,
          step = 1,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex()
        },
        positiony_center = {
          name = "Center Health Bar Y",
          desc = "Center Health Bar Y Position",
          type = "execute",
          func = _handle_positiony_center,
          order = _incrementOrderIndex()
        },
        fontsize = {
          name = "Health Bar Font Size",
          desc = "Health Bar Font Size",
          type = "range",
          min = 10, max = 36,
          step = 1,
          get = _getOption,
          set = _setOption,
          order = _incrementOrderIndex(),
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Health Bar Font",
          desc = "Health Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = _incrementOrderIndex()
        },
        texture = {
          name = "Health Bar Texture",
          desc = "Health Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = _incrementOrderIndex()
        },
        border = {
          name = "Health Bar Border",
          desc = "Health Bar Border",
          type = "select",
          dialogControl = "LSM30_Border",
          values = media:HashTable("border"),
          order = _incrementOrderIndex()
        },
        color = {
          name = "Health Bar Color",
          desc = "Health Bar Color",
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
  PlayerHealth:refreshConfig()
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

  local centerXPos = math.floor(PlayerHealth._SCREEN_WIDTH / 2 - width / 2)
  _curDbProfile.positionx = centerXPos
  PlayerHealth:refreshConfig()
end

function _handle_positiony_center()
  local height = _curDbProfile.height

  local centerYPos = math.floor(PlayerHealth._SCREEN_HEIGHT / 2 - height / 2)
  _curDbProfile.positiony = centerYPos
  PlayerHealth:refreshConfig()
end

function _handle_unit_health_event(self, event, unit)
  if (unit == "player") then
    local healthPercent = _get_health_percent()
    PlayerHealth._HealthBarFrame.Text:SetText(string.format("%.1f%%", healthPercent * 100.0))
    PlayerHealth._HealthBarFrame.StatusBar:SetValue(healthPercent)
  end
end

---@return number
function _get_health_percent()
  local curUnitHealth = UnitHealth("Player")
  local maxUnitHealth = UnitHealthMax("Player")
  return curUnitHealth / maxUnitHealth
end

function PlayerHealth:_setFrameWidthHeight()
  self._HealthBarFrame:SetWidth(_curDbProfile.width)
  self._HealthBarFrame:SetHeight(_curDbProfile.height)
  self._HealthBarFrame.bgFrame:SetWidth(self._HealthBarFrame:GetWidth())
  self._HealthBarFrame.bgFrame:SetHeight(self._HealthBarFrame:GetHeight())
  self._HealthBarFrame.StatusBar:SetWidth(self._HealthBarFrame:GetWidth())
  self._HealthBarFrame.StatusBar:SetHeight(self._HealthBarFrame:GetHeight())
end

function PlayerHealth:_refreshHealthBarFrame()
  self._HealthBarFrame:SetPoint(
    "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    _curDbProfile.positionx,
    _curDbProfile.positiony
  )
  self._HealthBarFrame.Text:SetFont(
    media:Fetch("font", _curDbProfile.font),
    _curDbProfile.fontsize, "OUTLINE"
  )
  _frameBackdropTable.edgeFile = media:Fetch("border", _curDbProfile.border)
  self._HealthBarFrame:SetBackdrop(_frameBackdropTable)
end

function PlayerHealth:_refreshStatusBar()
  self._HealthBarFrame.StatusBar:SetStatusBarTexture(media:Fetch("statusbar", _curDbProfile.texture))
  self._HealthBarFrame.StatusBar:SetStatusBarColor(unpack(_curDbProfile.color))
end
