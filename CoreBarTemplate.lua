local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local unpack, next = unpack, next
local _curDbProfile
local _orderIndex = 1

--- "PRIVATE" function declarations
local _incrementOrderIndex, _handlePositionXCenter, _handlePositionYCenter

local CoreBarTemplate = {}
CoreBarTemplate.__index = CoreBarTemplate
ZxSimpleUI.CoreBarTemplate = CoreBarTemplate

function CoreBarTemplate:new(curDbProfile)
  local newInstance = setmetatable({}, CoreBarTemplate)
  newInstance:__init__(curDbProfile)
  return newInstance
end

function CoreBarTemplate:__init__(curDbProfile)
  _curDbProfile = curDbProfile
  self.defaults = {
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
      border = "None"
    }
  }
  self.frameBackdropTable = {
    bgFile = "Interface\\DialogFrame\\UI-Tooltip-Background",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  }
  self.options = {}
  self.mainFrame = nil
end

---@param percentValue number
---@return table
---Return a reference to the mainFrame
function CoreBarTemplate:createBar(percentValue)
  self.mainFrame = CreateFrame("Frame", nil, UIParent)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)
  self.mainFrame:SetBackdropColor(1, 0, 0, 1)
  self.mainFrame:SetPoint(
    "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    _curDbProfile.positionx,
    _curDbProfile.positiony
  )

  self.mainFrame.bgFrame = self.mainFrame:CreateTexture(nil, "BACKGROUND")
  self.mainFrame.bgFrame:SetTexture(0, 0, 0, 0.8)
  self.mainFrame.bgFrame:SetAllPoints()

  self.mainFrame.statusBar = CreateFrame("StatusBar", nil, self.mainFrame)
  self.mainFrame.statusBar:ClearAllPoints()
  self.mainFrame.statusBar:SetPoint("CENTER", self.mainFrame, "CENTER")
  self.mainFrame.statusBar:SetStatusBarTexture(media:Fetch("statusbar", _curDbProfile.texture))
  self.mainFrame.statusBar:GetStatusBarTexture():SetHorizTile(false)
  self.mainFrame.statusBar:GetStatusBarTexture():SetVertTile(false)
  self.mainFrame.statusBar:SetStatusBarColor(unpack(_curDbProfile.color))
  self.mainFrame.statusBar:SetMinMaxValues(0, 1)
  self.mainFrame.statusBar:SetValue(percentValue)
  self:_setFrameWidthHeight()

  self.mainFrame.Text = self.mainFrame.statusBar:CreateFontString(nil, "OVERLAY")
  self.mainFrame.Text:SetFont(
      media:Fetch("font", _curDbProfile.font),
      _curDbProfile.fontsize, "OUTLINE")
  self.mainFrame.Text:SetTextColor(unpack(_curDbProfile.fontcolor))
  self.mainFrame.Text:SetPoint("CENTER", self.mainFrame.statusBar, "CENTER", 0, 0)
  self.mainFrame.Text:SetText(string.format("%.1f%%", percentValue * 100.0))

  self.mainFrame:Show()
  return self.mainFrame
end

---@return table
function CoreBarTemplate:getOptionTable(decorativeName)
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = decorativeName,
      get = function (infoTable) return self:_getOption(infoTable) end,
      set = function(infoTable, value) self:_setOption(infoTable, value) end,
      args = {
        header = {
          type = "header",
          name = decorativeName,
          order = _incrementOrderIndex()
        },
        width = {
          name = "Bar Width",
          desc = "Bar Width Size",
          type = "range",
          min = 0, max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          get = function (infoTable) return self:_getOption(infoTable) end,
          set = function(infoTable, value) self:_setOption(infoTable, value) end,
          order = _incrementOrderIndex(),
        },
        height = {
          name = "Bar Height",
          desc = "Bar Height Size",
          type = "range",
          min = 0, max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          get = function (infoTable) return self:_getOption(infoTable) end,
          set = function(infoTable, value) self:_setOption(infoTable, value) end,
          order = _incrementOrderIndex(),
        },
        positionx = {
          name = "Bar X",
          desc = "Bar X Position",
          type = "range",
          min = 0, max = ZxSimpleUI.SCREEN_WIDTH,
          step = 1,
          get = function (infoTable) return self:_getOption(infoTable) end,
          set = function(infoTable, value) self:_setOption(infoTable, value) end,
          order = _incrementOrderIndex()
        },
        positionx_center = {
          name = "Center Bar X",
          desc = "Center Bar X Position",
          type = "execute",
          func = _handlePositionXCenter,
          order = _incrementOrderIndex()
        },
        positiony = {
          name = "Bar Y",
          desc = "Bar Y Position",
          type = "range",
          min = 0, max = ZxSimpleUI.SCREEN_HEIGHT,
          step = 1,
          get = function (infoTable) return self:_getOption(infoTable) end,
          set = function(infoTable, value) self:_setOption(infoTable, value) end,
          order = _incrementOrderIndex()
        },
        positiony_center = {
          name = "Center Bar Y",
          desc = "Center Bar Y Position",
          type = "execute",
          func = _handlePositionYCenter,
          order = _incrementOrderIndex()
        },
        fontsize = {
          name = "Bar Font Size",
          desc = "Bar Font Size",
          type = "range",
          min = 10, max = 36,
          step = 1,
          get = function (infoTable) return self:_getOption(infoTable) end,
          set = function(infoTable, value) self:_setOption(infoTable, value) end,
          order = _incrementOrderIndex(),
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Bar Font",
          desc = "Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = _incrementOrderIndex()
        },
        fontcolor = {
          name = "Bar Font Color",
          desc = "Bar Font Color",
          type = "color",
          get = function (infoTable) return self:_getOptionColor(infoTable) end,
          set = function(infoTable, value) self:_setOptionColor(infoTable, value) end,
          hasAlpha = false,
          order = _incrementOrderIndex()
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = _incrementOrderIndex()
        },
        border = {
          name = "Bar Border",
          desc = "Bar Border",
          type = "select",
          dialogControl = "LSM30_Border",
          values = media:HashTable("border"),
          order = _incrementOrderIndex()
        },
        color = {
          name = "Bar Color",
          desc = "Bar Color",
          type = "color",
          get = function (infoTable) return self:_getOptionColor(infoTable) end,
          set = function(infoTable, value) self:_setOptionColor(infoTable, value) end,
          hasAlpha = true,
          order = _incrementOrderIndex()
        }
      }
    }
  end
  return self.options
end

function CoreBarTemplate:refreshConfig()
  self:_setFrameWidthHeight()
  self:_refreshBarFrame()
  self:_refreshStatusBar()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param infoTable table
function CoreBarTemplate:_getOption(infoTable)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  return _curDbProfile[key]
end

---@param infoTable table
---@param value any
function CoreBarTemplate:_setOption(infoTable, value)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  _curDbProfile[key] = value
  self:refreshConfig()
end

---@param infoTable table
function CoreBarTemplate:_getOptionColor(infoTable)
  return unpack(self:_getOption(infoTable))
end

---@param infoTable table
function CoreBarTemplate:_setOptionColor(infoTable, ...)
  self:_setOption(infoTable, {...})
end

function _incrementOrderIndex()
  local i = _orderIndex
  _orderIndex = _orderIndex + 1
  return i
end

function _handlePositionXCenter()
  local width = _curDbProfile.width

  local centerXPos = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2 - width / 2)
  _curDbProfile.positionx = centerXPos
  CoreBarTemplate:refreshConfig()
end

function _handlePositionYCenter()
  local height = _curDbProfile.height

  local centerYPos = math.floor(ZxSimpleUI.SCREEN_HEIGHT / 2 - height / 2)
  _curDbProfile.positiony = centerYPos
  CoreBarTemplate:refreshConfig()
end

function CoreBarTemplate:_setFrameWidthHeight()
  self.mainFrame:SetWidth(_curDbProfile.width)
  self.mainFrame:SetHeight(_curDbProfile.height)
  self.mainFrame.bgFrame:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.bgFrame:SetHeight(self.mainFrame:GetHeight())
  self.mainFrame.statusBar:SetWidth(self.mainFrame:GetWidth())
  self.mainFrame.statusBar:SetHeight(self.mainFrame:GetHeight())
end

function CoreBarTemplate:_refreshBarFrame()
  self.mainFrame:SetPoint(
    "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    _curDbProfile.positionx,
    _curDbProfile.positiony
  )
  self.mainFrame.Text:SetFont(
    media:Fetch("font", _curDbProfile.font),
    _curDbProfile.fontsize, "OUTLINE"
  )
  self.frameBackdropTable.edgeFile = media:Fetch("border", _curDbProfile.border)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)
  self.mainFrame.Text:SetTextColor(unpack(_curDbProfile.fontcolor))
end

function CoreBarTemplate:_refreshPowerBarFrame()
  self.mainFrame:SetPoint(
    "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    _curDbProfile.positionx,
    _curDbProfile.positiony
  )
  self.mainFrame.Text:SetFont(
    media:Fetch("font", _curDbProfile.font),
    _curDbProfile.fontsize, "OUTLINE"
  )
  self.frameBackdropTable.edgeFile = media:Fetch("border", _curDbProfile.border)
  self.mainFrame:SetBackdrop(self.frameBackdropTable)
  self.mainFrame.Text:SetTextColor(unpack(_curDbProfile.fontcolor))
end

function CoreBarTemplate:_refreshStatusBar()
  self.mainFrame.statusBar:SetStatusBarTexture(media:Fetch("statusbar", _curDbProfile.texture))
  self.mainFrame.statusBar:SetStatusBarColor(unpack(_curDbProfile.color))
end
