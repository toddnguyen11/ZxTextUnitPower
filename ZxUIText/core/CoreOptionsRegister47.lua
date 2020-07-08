local ZxUIText = LibStub("AceAddon-3.0"):GetAddon("ZxUIText")
---@type ZxUIText
local MainAddon = ZxUIText

local Utils47 = MainAddon.Utils47
local FramePool47 = MainAddon.FramePool47

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

---@class CoreOptionsRegister47
local CoreOptionsRegister47 = MainAddon:NewModule("Options", nil)

-- PRIVATE functions and variables
---@param key string
local _OPEN_OPTION_APPNAME = MainAddon.ADDON_NAME .. "_OpenOption"

function CoreOptionsRegister47:OnInitialize()
  self._openOptionTable = {}
  self._options = {}
  self._printFrameOptionTable = {}
  self._isFrameClosed = true
  self:SetupOptions()
end

function CoreOptionsRegister47:SetupOptions()
  MainAddon.blizOptionTable = {}
  AceConfigRegistry:RegisterOptionsTable(_OPEN_OPTION_APPNAME,
    function(...) return self:_getOpenOptionTable() end)
  AceConfigRegistry:RegisterOptionsTable(MainAddon.ADDON_NAME,
    function(...) return self:_getOptionTable() end)

  local frameRef = AceConfigDialog:AddToBlizOptions(_OPEN_OPTION_APPNAME,
                     MainAddon.DECORATIVE_NAME)
  MainAddon.blizOptionTable[MainAddon.ADDON_NAME] = frameRef
  -- Register slash commands as well
  for _, command in pairs(MainAddon.SLASH_COMMANDS) do
    MainAddon:RegisterChatCommand(command, function(...) self:_openOptionFrame() end)
  end

  -- Set profile options
  local profileTable = AceDBOptions:GetOptionsTable(MainAddon.db)
  profileTable.args.reset["disabled"] = false
  local moduleName = "Profiles"
  MainAddon:registerModuleOptions(moduleName, profileTable, moduleName)

  -- Set Print Frames option
  moduleName = "PrintFrames"
  local printFrameTable = self:_getPrintFrameOptionTable()
  MainAddon:registerModuleOptions(moduleName, printFrameTable, "Print Frames")

  -- Disable all modules when combat starts
  -- Resume its previous disabled-state when combat ends
  local disableInCombat = self.DisableInCombat:new()
  disableInCombat:disableOptions()
end

-- ########################################
-- # "PRIVATE" functions
-- ########################################

---@return table
function CoreOptionsRegister47:_getOpenOptionTable()
  if next(self._openOptionTable) == nil then
    self._openOptionTable = {
      type = "group",
      args = {
        openoptions = {
          name = "Open Options",
          type = "execute",
          func = function(curFrame, ...) self:_openOptionFrame() end
        },
        descriptionParagraph = {
          name = self:_getSlashCommandsString(),
          type = "description",
          fontSize = "medium"
        }
      }
    }
  end

  return self._openOptionTable
end

---@return table
function CoreOptionsRegister47:_getPrintFrameOptionTable()
  if next(self._printFrameOptionTable) == nil then
    self._printFrameOptionTable = {
      type = "group",
      name = "Print Frames",
      args = {
        descDisplay = {name = "", type = "description", fontSize = "medium", order = 2},
        printFrameVisibility = {
          name = "Print Frame Visibility",
          type = "execute",
          order = 1,
          func = function(info, ...)
            local sortedKeys = {}
            local t1 = {}
            local s1 = "FRAMES VISIBILITY\n"
            for k, v in MainAddon:IterateModules() do
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

            self._printFrameOptionTable.args.descDisplay.name = s1
          end
        }
      }
    }
  end

  return self._printFrameOptionTable
end

function CoreOptionsRegister47:_getSlashCommandsString()
  local s1 = "You can also open the options frame with one of these commands:\n"
  for _, command in pairs(MainAddon.SLASH_COMMANDS) do s1 = s1 .. "    /" .. command .. "\n" end
  s1 = string.sub(s1, 0, string.len(s1) - 1)
  return s1
end

function CoreOptionsRegister47:_openOptionFrame(info, value, ...)
  local frame = nil
  if self._isFrameClosed then
    self._isFrameClosed = false
    frame = AceGUI:Create("Frame")
    frame:SetCallback("OnClose", function(widget)
      self._isFrameClosed = true
      AceGUI:Release(widget)
    end)
    frame:SetTitle(MainAddon.DECORATIVE_NAME)
    AceConfigDialog:Open(MainAddon.ADDON_NAME, frame)
  end
end

function CoreOptionsRegister47:_getOptionTable()
  if next(self._options) == nil then
    self._options = {type = "group", args = {}}
    self:_addModuleOptionTables()
  end

  return self._options
end

function CoreOptionsRegister47:_addModuleOptionTables()
  local defaultOrderIndex = 7
  table.sort(MainAddon.moduleKeySorted)
  for _, moduleAppName in pairs(MainAddon.moduleKeySorted) do
    local optionTableOrFunc = MainAddon.moduleOptionsTable[moduleAppName]
    if type(optionTableOrFunc) == "function" then
      self._options.args[moduleAppName] = optionTableOrFunc()
    else
      self._options.args[moduleAppName] = optionTableOrFunc
    end

    if moduleAppName == "Profiles" then
      -- Make sure "Profiles" is the first option
      self._options.args[moduleAppName]["order"] = 1
    elseif moduleAppName == "PrintFrames" then
      -- Make sure "PrintFrames" is the second option
      self._options.args[moduleAppName]["order"] = 2
    else
      self._options.args[moduleAppName]["order"] = defaultOrderIndex
      defaultOrderIndex = defaultOrderIndex + 1
    end
  end
end

---@class DisableInCombat
CoreOptionsRegister47.DisableInCombat = {}
CoreOptionsRegister47.DisableInCombat.__index = CoreOptionsRegister47.DisableInCombat

---@return DisableInCombat
function CoreOptionsRegister47.DisableInCombat:new()
  ---@type DisableInCombat
  local newInstance = setmetatable({}, self)
  newInstance._prevDisableOptions = {}
  return newInstance
end

function CoreOptionsRegister47.DisableInCombat:disableOptions()
  local frame = FramePool47:getFrame()
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:SetScript("OnEvent", function(curFrame, event, arg1, arg2, ...)
    if event == "PLAYER_REGEN_DISABLED" then
      self:_disableInCombat()
    elseif event == "PLAYER_REGEN_ENABLED" then
      self:_enableOutOfCombat()
    end
  end)
end

function CoreOptionsRegister47.DisableInCombat:_disableInCombat()
  for key, val in pairs(MainAddon.moduleOptionsTable) do
    if key:find("Profile") then
      val["args"]["reset"]["disabled"] = true
    else
      self._prevDisableOptions[key] = {}
      for argkey, argval in pairs(val.args) do
        self._prevDisableOptions[key][argkey] = argval["disabled"]
        argval["disabled"] = true
      end
    end
  end
end

function CoreOptionsRegister47.DisableInCombat:_enableOutOfCombat()
  for key, val in pairs(MainAddon.moduleOptionsTable) do
    if key:find("Profile") then
      val["args"]["reset"]["disabled"] = nil
    else
      for argkey, argval in pairs(val.args) do
        argval["disabled"] = self._prevDisableOptions[key][argkey]
      end
    end
  end
end
