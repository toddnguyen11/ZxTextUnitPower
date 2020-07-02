local ZxUIText = LibStub("AceAddon-3.0"):GetAddon("ZxUIText")
local FramePool47 = ZxUIText.FramePool47

---@class CoreFactory47
local CoreFactory47 = {}
CoreFactory47.__index = CoreFactory47
ZxUIText.CoreFactory47 = CoreFactory47

CoreFactory47._frameEnableToggleList = {}
CoreFactory47._prevDisabledOptionsList = {}

---@param curModule table
---Explicitly call OnEnable() and OnDisable() depending on the module's IsEnabled()
---This function is exactly like refreshConfig(), except it is called only during initialization.
function CoreFactory47:initModuleEnableState(curModule)
  if type(curModule.handleEnableToggle) == "function" then curModule:handleEnableToggle() end
  if curModule:IsEnabled() then
    curModule:OnEnable()
  else
    curModule:OnDisable()
  end
  curModule:refreshConfig()
end

---@param optionInstance table Instance of an option object, such as BarTemplateEnableOptions or
-- Aura47Options
---@param curModule table The current module, such as PlayerHealth47 or TargetDebuffs47
---@return table
function CoreFactory47:registerAndReturnOptionTable(optionInstance, curModule)
  optionInstance:registerModuleOptionsTable()
  local optionTable = optionInstance.options
  self:disableEnabledToggleInCombat(curModule.MODULE_NAME, optionTable["args"])
  return optionTable
end

---@param appName string
---@param optionTableInput table
function CoreFactory47:disableEnabledToggleInCombat(appName, optionTableInput)
  local frameEnabledToggle = FramePool47:getFrame()
  frameEnabledToggle:RegisterEvent("PLAYER_REGEN_DISABLED")
  frameEnabledToggle:RegisterEvent("PLAYER_REGEN_ENABLED")
  frameEnabledToggle:SetScript("OnEvent", function(curFrame, event, arg1, arg2, ...)
    if event == "PLAYER_REGEN_DISABLED" then
      self:_handleInCombat(appName, optionTableInput)
    elseif event == "PLAYER_REGEN_ENABLED" then
      self:_handleOutOfCombat(appName, optionTableInput)
    end
  end)
  self._frameEnableToggleList[appName] = frameEnabledToggle
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

---@param appName string
---@param optionTableInput table
function CoreFactory47:_handleInCombat(appName, optionTableInput)
  self._prevDisabledOptionsList[appName] = {}
  if optionTableInput ~= nil then
    for key, val in pairs(optionTableInput) do
      self._prevDisabledOptionsList[appName][key] = val["disabled"]
      val["disabled"] = true
    end
  end
end

---@appName string
---@param optionTableInput table
function CoreFactory47:_handleOutOfCombat(appName, optionTableInput)
  if optionTableInput ~= nil then
    for key, val in pairs(optionTableInput) do
      val["disabled"] = self._prevDisabledOptionsList[appName][key]
    end
  end
  -- Clean up!
  self._prevDisabledOptionsList[appName] = {}
end
