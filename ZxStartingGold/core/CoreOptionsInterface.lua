local LibStub = LibStub

local ZxStartingGold = LibStub("AceAddon-3.0"):GetAddon("ZxStartingGold")
local Utils47 = ZxStartingGold.Utils47
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local CoreOptionsInterface = ZxStartingGold:NewModule("Options", nil)

-- PRIVATE functions and variables
---@param key string
local _curDbProfile, _openOptionFrame, _getSlashCommandsString
local _getOpenOptionTable, _getOptionTable, _addModuleOptionTables
local _getPrintFrameOptionTable
local _OPEN_OPTION_APPNAME = "ZxStartingGold_OpenOption"

function CoreOptionsInterface:OnInitialize()
  _curDbProfile = ZxStartingGold.db.profile
  self:SetupOptions()
end

function CoreOptionsInterface:SetupOptions()
  ZxStartingGold.blizOptionTable = {}
  AceConfigRegistry:RegisterOptionsTable(_OPEN_OPTION_APPNAME, _getOpenOptionTable)
  AceConfigRegistry:RegisterOptionsTable(ZxStartingGold.ADDON_NAME, _getOptionTable)

  local frameRef = AceConfigDialog:AddToBlizOptions(_OPEN_OPTION_APPNAME,
                     ZxStartingGold.DECORATIVE_NAME)
  ZxStartingGold.blizOptionTable[ZxStartingGold.ADDON_NAME] = frameRef
  -- Register slash commands as well
  for _, command in pairs(ZxStartingGold.SLASH_COMMANDS) do
    ZxStartingGold:RegisterChatCommand(command, _openOptionFrame)
  end

  -- Set profile options
  ZxStartingGold:registerModuleOptions("Profiles", AceDBOptions:GetOptionsTable(ZxStartingGold.db),
    "Profiles")
  -- Set Print Frames option
  ZxStartingGold:registerModuleOptions("PrintFrames", _getPrintFrameOptionTable(), "Print Frames")
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

---@return table
local _printFrameOptionTable = {}
function _getPrintFrameOptionTable()
  if next(_printFrameOptionTable) == nil then
    _printFrameOptionTable = {
      type = "group",
      name = "Print Frames",
      args = {
        printFrameVisibility = {
          name = "Print Frame Visibility",
          type = "execute",
          order = 1,
          func = function(info, ...)
            local sortedKeys = {}
            local t1 = {}
            local s1 = "FRAMES VISIBILITY\n"
            for k, v in ZxStartingGold:IterateModules() do
              table.insert(sortedKeys, k)
              t1[k] = v
            end
            table.sort(sortedKeys)

            for _, sortedKey in pairs(sortedKeys) do
              local curModule = t1[sortedKey]
              if curModule.mainFrame ~= nil then
                local s2 = (string.format("%s | %s", sortedKey,
                             Utils47:getIsShown(curModule.mainFrame)))
                print(s2)
                s1 = s1 .. s2 .. "\n"
              end
            end

            _printFrameOptionTable.args.descDisplay.name = s1
          end
        },
        descDisplay = {name = "", type = "description", fontSize = "medium", order = 2}
      }
    }
  end
  return _printFrameOptionTable
end

function _getSlashCommandsString()
  local s1 = "You can also open the options frame with one of these commands:\n"
  for _, command in pairs(ZxStartingGold.SLASH_COMMANDS) do s1 = s1 .. "    /" .. command .. "\n" end
  s1 = string.sub(s1, 0, string.len(s1) - 1)
  return s1
end

function _openOptionFrame(info, value, ...)
  if not _frame then
    _frame = AceGUI:Create("Frame")
    _frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    _frame:SetTitle(ZxStartingGold.DECORATIVE_NAME)
  end
  AceConfigDialog:Open(ZxStartingGold.ADDON_NAME, _frame)
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
  table.sort(ZxStartingGold.moduleKeySorted)
  for _, moduleAppName in pairs(ZxStartingGold.moduleKeySorted) do
    local optionTableOrFunc = ZxStartingGold.moduleOptionsTable[moduleAppName]
    if type(optionTableOrFunc) == "function" then
      option.args[moduleAppName] = optionTableOrFunc()
    else
      option.args[moduleAppName] = optionTableOrFunc
    end
    -- Make sure "Profiles" is the first option
    if moduleAppName == "Profiles" then
      option.args[moduleAppName]["order"] = 1
    elseif moduleAppName == "PrintFrames" then
      option.args[moduleAppName]["order"] = 2
    else
      option.args[moduleAppName]["order"] = defaultOrderIndex
      defaultOrderIndex = defaultOrderIndex + 1
    end
  end
end
