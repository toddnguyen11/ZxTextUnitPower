---@type ZxUIText
local ZxUIText = LibStub("AceAddon-3.0"):GetAddon("ZxUIText")

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
  return optionTable
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################
