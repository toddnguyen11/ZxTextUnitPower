local ZxUIText = LibStub("AceAddon-3.0"):GetAddon("ZxUIText")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local CoreOptionsInterface = ZxUIText:NewModule("Options", nil)

-- PRIVATE functions and variables
---@param key string
local _curDbProfile, _openOptionFrame, _getSlashCommandsString
local _getOpenOptionTable, _getOptionTable, _addModuleOptionTables
local _OPEN_OPTION_APPNAME = "ZxUIText_OpenOption"

function CoreOptionsInterface:OnInitialize()
  _curDbProfile = ZxUIText.db.profile
  self:SetupOptions()
end

function CoreOptionsInterface:SetupOptions()
  ZxUIText.blizOptionTable = {}
  AceConfigRegistry:RegisterOptionsTable(_OPEN_OPTION_APPNAME, _getOpenOptionTable)
  AceConfigRegistry:RegisterOptionsTable(ZxUIText.ADDON_NAME, _getOptionTable)

  local frameRef = AceConfigDialog:AddToBlizOptions(_OPEN_OPTION_APPNAME,
                     ZxUIText.DECORATIVE_NAME)
  ZxUIText.blizOptionTable[ZxUIText.ADDON_NAME] = frameRef
  -- Register slash commands as well
  for _, command in pairs(ZxUIText.SLASH_COMMANDS) do
    ZxUIText:RegisterChatCommand(command, _openOptionFrame)
  end

  -- Set profile options
  ZxUIText:registerModuleOptions("Profiles", AceDBOptions:GetOptionsTable(ZxUIText.db),
    "Profiles")
end

-- ########################################
-- # "PRIVATE" functions
-- ########################################

local _openOptionTable = {}
local _frame = nil

---@return table
function _getOpenOptionTable()
  if next(_openOptionTable) == nil then
    _openOptionTable = {
      type = "group",
      args = {
        openoptions = {name = "Open Options", type = "execute", func = _openOptionFrame},
        descriptionParagraph = {
          name = _getSlashCommandsString(),
          type = "description",
          fontSize = "medium"
        }
      }
    }
  end

  return _openOptionTable
end

function _getSlashCommandsString()
  local s1 = "You can also open the options frame with one of these commands:\n"
  for _, command in pairs(ZxUIText.SLASH_COMMANDS) do s1 = s1 .. "    /" .. command .. "\n" end
  s1 = string.sub(s1, 0, string.len(s1) - 1)
  return s1
end

function _openOptionFrame(info, value, ...)
  if not _frame then
    _frame = AceGUI:Create("Frame")
    _frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    _frame:SetTitle(ZxUIText.DECORATIVE_NAME)
  end
  AceConfigDialog:Open(ZxUIText.ADDON_NAME, _frame)
end

local option = {}
function _getOptionTable()
  if next(option) == nil then
    option = {type = "group", args = {}}
    _addModuleOptionTables()
  end
  return option
end

function _addModuleOptionTables()
  local defaultOrderIndex = 7
  table.sort(ZxUIText.moduleKeySorted)
  for _, moduleAppName in pairs(ZxUIText.moduleKeySorted) do
    local optionTableOrFunc = ZxUIText.moduleOptionsTable[moduleAppName]
    if type(optionTableOrFunc) == "function" then
      option.args[moduleAppName] = optionTableOrFunc()
    else
      option.args[moduleAppName] = optionTableOrFunc
    end
    -- Make sure "Profiles" is the first option
    if moduleAppName == "Profiles" then
      option.args[moduleAppName]["order"] = 1
    else
      option.args[moduleAppName]["order"] = defaultOrderIndex
      defaultOrderIndex = defaultOrderIndex + 1
    end
  end
end
