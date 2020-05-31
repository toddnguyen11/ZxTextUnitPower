local ZxUIText = LibStub("AceAddon-3.0"):GetAddon("ZxUIText")
local CoreOptions47 = ZxUIText["optionTables"]["CoreOptions47"]
local media = LibStub("LibSharedMedia-3.0")

local _MODULE_NAME = "ActionBarFont"
local _DECORATIVE_NAME = "Action Bar Font"
local ActionBarFont = ZxUIText:NewModule(_MODULE_NAME)
ActionBarFont.MODULE_NAME = _MODULE_NAME
ActionBarFont.DECORATIVE_NAME = _DECORATIVE_NAME
ActionBarFont.FACTORY_DEFAULT_FONT = "Arial Narrow"

ActionBarFont.MAX_CHATFRAMES = 10
ActionBarFont.KEY_SUFFIXES = {"", "EditBox", "EditBoxHeader"}

local _defaults = {
  profile = {
    enabledToggle = true,
    font = "Oxygen Bold",
    fontsize = 14,
    outline = true,
    thickoutline = false,
    monochrome = false
  }
}

function ActionBarFont:OnInitialize()
  self.db = ZxUIText.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile

  self:__init__()

  self:SetEnabledState(ZxUIText:getModuleEnabledState(_MODULE_NAME))
  ZxUIText:registerModuleOptions(self.MODULE_NAME, self:getOptionTable(), self.DECORATIVE_NAME)
end

function ActionBarFont:__init__()
  self.option = {}

  self._coreOptions47 = CoreOptions47:new(self)
  self._defaultStubs = {
    ActionButton = 12,
    MultiBarRightButton = 12,
    MultiBarLeftButton = 12,
    MultiBarBottomRightButton = 12,
    MultiBarBottomLeftButton = 12,
    BonusActionButton = 12,
    PetActionButton = 10,
    MultiCastActionButton = 12
  }
end

function ActionBarFont:OnEnable() self:handleOnEnable() end
function ActionBarFont:OnDisable() self:handleOnDisable() end

function ActionBarFont:handleOnEnable() self:refreshConfig() end
function ActionBarFont:handleOnDisable() self:_resetFactoryDefaultFonts() end

function ActionBarFont:refreshConfig()
  self:handleEnableToggle()
  if self:IsEnabled() then self:_refreshAll() end
end

function ActionBarFont:handleEnableToggle()
  ZxUIText:setModuleEnabledState(_MODULE_NAME, self._curDbProfile.enabledToggle)
end

function ActionBarFont:printGlobalChatFrameKeys()
  local sortedTable = {}
  for k, v in pairs(_G) do
    if k:find("%d+HotKey") then
      if type(v.GetFont) == "function" then
        local index = tonumber(k:match("%d+"))
        if sortedTable[index] == nil then sortedTable[index] = {} end
        table.insert(sortedTable[index], k)
      end
    end
  end

  for _, tableOfKeys in pairs(sortedTable) do
    table.sort(tableOfKeys)
    for _, globalKey in pairs(tableOfKeys) do
      --- Ref: https://wow.gamepedia.com/API_FontInstance_GetFont
      local fontName, fontHeight, fontFlags = _G[globalKey]:GetFont()
      fontName = fontName:gsub("\\", "/")
      fontName = fontName:match(".*/(%S+)")
      fontHeight = math.ceil(fontHeight)
      ZxUIText:Print(string.format("[%s] --> [%s, %s, %s]", globalKey, fontName,
                       tostring(fontHeight), fontFlags))
    end
  end
end

---@return string
function ActionBarFont:getFontFlags()
  local s = ""
  if self._curDbProfile.outline then s = s .. "OUTLINE, " end
  if self._curDbProfile.thickoutline then s = s .. "THICKOUTLINE, " end
  if self._curDbProfile.monochrome then s = s .. "MONOCHROME, " end
  if s ~= "" then s = string.sub(s, 0, (string.len(s) - 2)) end
  return s
end

---@return table
function ActionBarFont:getOptionTable()
  if next(self.option) == nil then
    self.option = {
      type = "group",
      name = self.DECORATIVE_NAME,
      --- "Parent" get/set
      get = function(info) return self._coreOptions47:getOption(info) end,
      set = function(info, value) self._coreOptions47:setOption(info, value) end,
      args = {
        header = {
          type = "header",
          name = self.DECORATIVE_NAME,
          order = ZxUIText.HEADER_ORDER_INDEX
        },
        enabledToggle = {
          type = "toggle",
          name = "Enable",
          desc = "Enable / Disable this module",
          order = ZxUIText.HEADER_ORDER_INDEX + 1
        },
        -- LSM30_ is LibSharedMedia's custom controls
        font = {
          name = "Action Bar Font",
          desc = "Action Bar Font",
          type = "select",
          dialogControl = "LSM30_Font",
          values = media:HashTable("font"),
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontsize = {
          name = "Action Bar Font Size",
          desc = "Action Bar Font Size",
          type = "range",
          min = 10,
          max = 36,
          step = 1,
          order = self._coreOptions47:incrementOrderIndex()
        },
        fontflags = {
          name = "Font Flags",
          type = "group",
          inline = true,
          order = self._coreOptions47:incrementOrderIndex(),
          args = {
            outline = {name = "Outline", type = "toggle", order = 1},
            thickoutline = {name = "Thick Outline", type = "toggle", order = 2},
            monochrome = {name = "Monochrome", type = "toggle", order = 3}
          }
        },
        printButton = {
          name = "Print Keys",
          desc = "Print the Hotkey keys in the _G global table",
          type = "execute",
          func = function(info) self:printGlobalChatFrameKeys() end
        }
      }
    }
  end
  return self.option
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function ActionBarFont:_refreshAll() self:_setHotkeyFont() end

function ActionBarFont:_setHotkeyFont()
  for stub, numButtons in pairs(self._defaultStubs) do
    for i = 1, numButtons do
      local localKey = stub .. i .. "HotKey"
      _G[localKey]:SetFont(media:Fetch("font", self._curDbProfile.font),
        self._curDbProfile.fontsize, self:getFontFlags())
    end
  end
end

function ActionBarFont:_resetFactoryDefaultFonts()
  for stub, numButtons in pairs(self._defaultStubs) do
    for i = 1, numButtons do
      local localKey = stub .. i .. "HotKey"
      _G[localKey]:SetFont(media:Fetch("font", self.FACTORY_DEFAULT_FONT),
        self._curDbProfile.fontsize, self:getFontFlags())
    end
  end
end
