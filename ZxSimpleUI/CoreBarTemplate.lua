---References:
---https://wowwiki.fandom.com/wiki/SecureActionButtonTemplate
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame = UIParent, CreateFrame
local unpack, next = unpack, next

local CoreBarTemplate = {}
CoreBarTemplate.__index = CoreBarTemplate
ZxSimpleUI.CoreBarTemplate = CoreBarTemplate

function CoreBarTemplate:new(curDbProfile)
  local newInstance = setmetatable({}, CoreBarTemplate)
  newInstance:__init__(curDbProfile)
  return newInstance
end

function CoreBarTemplate:__init__(curDbProfile)
  -- Start order index at 10 so other modules can easily put options in front
  self._orderIndex = 10
  self._curDbProfile = curDbProfile
  self._mainFrame = nil

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
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  }
  self.options = {}
end

---@param percentValue number 0 to 1
---@return table
function CoreBarTemplate:createBar(percentValue)
  -- self._mainFrame = CreateFrame("Frame", nil, UIParent)
  self._mainFrame = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate")
  self._mainFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL)
  self._mainFrame:SetBackdrop(self.frameBackdropTable)
  self._mainFrame:SetBackdropColor(1, 0, 0, 1)
  self._mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self._curDbProfile.positionx,
                           self._curDbProfile.positiony)

  self:_setMouseClicks()

  self._mainFrame.bgFrame = self._mainFrame:CreateTexture(nil, "BACKGROUND")
  self._mainFrame.bgFrame:SetTexture(0, 0, 0, 0.8)
  self._mainFrame.bgFrame:SetAllPoints()

  self._mainFrame.statusBar = CreateFrame("StatusBar", nil, self._mainFrame)
  self._mainFrame.statusBar:ClearAllPoints()
  self._mainFrame.statusBar:SetPoint("CENTER", self._mainFrame, "CENTER")
  self._mainFrame.statusBar:SetStatusBarTexture(
    media:Fetch("statusbar", self._curDbProfile.texture), "BORDER")
  self._mainFrame.statusBar:GetStatusBarTexture():SetHorizTile(false)
  self._mainFrame.statusBar:GetStatusBarTexture():SetVertTile(false)
  self._mainFrame.statusBar:SetStatusBarColor(unpack(self._curDbProfile.color))
  self._mainFrame.statusBar:SetMinMaxValues(0, 1)
  self._mainFrame.statusBar:SetValue(percentValue)
  self:_setFrameWidthHeight()

  self._mainFrame.mainText = self._mainFrame.statusBar:CreateFontString(nil, "BORDER")
  self._mainFrame.mainText:SetFont(media:Fetch("font", self._curDbProfile.font),
                                   self._curDbProfile.fontsize, "OUTLINE")
  self._mainFrame.mainText:SetTextColor(unpack(self._curDbProfile.fontcolor))
  self._mainFrame.mainText:SetPoint("CENTER", self._mainFrame.statusBar, "CENTER", 0, 0)
  self._mainFrame.mainText:SetText(string.format("%.1f%%", percentValue * 100.0))

  self._mainFrame:Show()
  return self._mainFrame
end

---@return table
function CoreBarTemplate:getOptionTable(decorativeName)
  if next(self.options) == nil then
    self.options = {
      type = "group",
      name = decorativeName,
      get = function(infoTable)
        return self:_getOption(infoTable)
      end,
      set = function(infoTable, value)
        self:_setOption(infoTable, value)
      end,
      args = {
        header = {type = "header", name = decorativeName, order = self:incrementOrderIndex()},
        width = {
          name = "Bar Width",
          desc = "Bar Width Size",
          type = "range",
          min = 0,
          max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:incrementOrderIndex()
        },
        height = {
          name = "Bar Height",
          desc = "Bar Height Size",
          type = "range",
          min = 0,
          max = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2),
          step = 2,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:incrementOrderIndex()
        },
        positionx = {
          name = "Bar X",
          desc = "Bar X Position",
          type = "range",
          min = 0,
          max = ZxSimpleUI.SCREEN_WIDTH,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:incrementOrderIndex()
        },
        positionx_center = {
          name = "Center Bar X",
          desc = "Center Bar X Position",
          type = "execute",
          func = function(...)
            self:handlePositionXCenter()
          end,
          order = self:incrementOrderIndex()
        },
        positiony = {
          name = "Bar Y",
          desc = "Bar Y Position",
          type = "range",
          min = 0,
          max = ZxSimpleUI.SCREEN_HEIGHT,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:incrementOrderIndex()
        },
        positiony_center = {
          name = "Center Bar Y",
          desc = "Center Bar Y Position",
          type = "execute",
          func = function(...)
            self:handlePositionYCenter()
          end,
          order = self:incrementOrderIndex()
        },
        fontsize = {
          name = "Bar Font Size",
          desc = "Bar Font Size",
          type = "range",
          min = 10,
          max = 36,
          step = 1,
          get = function(infoTable)
            return self:_getOption(infoTable)
          end,
          set = function(infoTable, value)
            self:_setOption(infoTable, value)
          end,
          order = self:incrementOrderIndex()
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Bar Font",
          desc = "Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self:incrementOrderIndex()
        },
        fontcolor = {
          name = "Bar Font Color",
          desc = "Bar Font Color",
          type = "color",
          get = function(infoTable)
            return self:_getOptionColor(infoTable)
          end,
          set = function(infoTable, r, g, b, a)
            self:_setOptionColor(infoTable, r, g, b, a)
          end,
          hasAlpha = false,
          order = self:incrementOrderIndex()
        },
        texture = {
          name = "Bar Texture",
          desc = "Bar Texture",
          type = "select",
          dialogControl = "LSM30_Statusbar",
          values = media:HashTable("statusbar"),
          order = self:incrementOrderIndex()
        },
        border = {
          name = "Bar Border",
          desc = "Bar Border",
          type = "select",
          dialogControl = "LSM30_Border",
          values = media:HashTable("border"),
          order = self:incrementOrderIndex()
        },
        color = {
          name = "Bar Color",
          desc = "Bar Color",
          type = "color",
          get = function(infoTable)
            return self:_getOptionColor(infoTable)
          end,
          set = function(infoTable, r, g, b, a)
            self:_setOptionColor(infoTable, r, g, b, a)
          end,
          hasAlpha = true,
          order = self:incrementOrderIndex()
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

function CoreBarTemplate:incrementOrderIndex()
  local i = self._orderIndex
  self._orderIndex = self._orderIndex + 1
  return i
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param infoTable table
function CoreBarTemplate:_getOption(infoTable)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  return self._curDbProfile[key]
end

---@param infoTable table
---@param value any
function CoreBarTemplate:_setOption(infoTable, value)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  self._curDbProfile[key] = value
  self:refreshConfig()
end

---@param infoTable table
function CoreBarTemplate:_getOptionColor(infoTable)
  return unpack(self:_getOption(infoTable))
end

---@param infoTable table
function CoreBarTemplate:_setOptionColor(infoTable, r, g, b, a)
  self:_setOption(infoTable, {r, g, b, a})
end

function CoreBarTemplate:handlePositionXCenter()
  local width = self._curDbProfile.width

  local centerXPos = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2 - width / 2)
  self._curDbProfile.positionx = centerXPos
  self:refreshConfig()
end

function CoreBarTemplate:handlePositionYCenter()
  local height = self._curDbProfile.height

  local centerYPos = math.floor(ZxSimpleUI.SCREEN_HEIGHT / 2 - height / 2)
  self._curDbProfile.positiony = centerYPos
  self:refreshConfig()
end

function CoreBarTemplate:_setFrameWidthHeight()
  self._mainFrame:SetWidth(self._curDbProfile.width)
  self._mainFrame:SetHeight(self._curDbProfile.height)
  self._mainFrame.bgFrame:SetWidth(self._mainFrame:GetWidth())
  self._mainFrame.bgFrame:SetHeight(self._mainFrame:GetHeight())
  self._mainFrame.statusBar:SetWidth(self._mainFrame:GetWidth())
  self._mainFrame.statusBar:SetHeight(self._mainFrame:GetHeight())
end

function CoreBarTemplate:_refreshBarFrame()
  self._mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self._curDbProfile.positionx,
                           self._curDbProfile.positiony)
  self._mainFrame:SetBackdrop(self.frameBackdropTable)

  self.frameBackdropTable.edgeFile = media:Fetch("border", self._curDbProfile.border)

  self._mainFrame.mainText:SetFont(media:Fetch("font", self._curDbProfile.font),
                                   self._curDbProfile.fontsize, "OUTLINE")
  self._mainFrame.mainText:SetTextColor(unpack(self._curDbProfile.fontcolor))
end

function CoreBarTemplate:_refreshStatusBar()
  self._mainFrame.statusBar:SetStatusBarTexture(
    media:Fetch("statusbar", self._curDbProfile.texture), "BORDER")
  self._mainFrame.statusBar:SetStatusBarColor(unpack(self._curDbProfile.color))
end

---@param percentValue number from 0.0 to 1.0
function CoreBarTemplate:_setStatusBarValue(percentValue)
  self._mainFrame.mainText:SetText(string.format("%.1f%%", percentValue * 100.0))
  self._mainFrame.statusBar:SetValue(percentValue)
end

---@param strInput string
function CoreBarTemplate:_setTextOnly(strInput)
  self._mainFrame.mainText:SetText(strInput)
end

function CoreBarTemplate:_setMouseClicks()
  self._mainFrame:RegisterForClicks("AnyUp")
  -- Set left click
  self._mainFrame:SetAttribute("*type1", "target")
  -- Set right click
  self._mainFrame:SetAttribute("*type2", "menu")
end
