local ZxStartingGold = LibStub("AceAddon-3.0"):GetAddon("ZxStartingGold")
local CoreFactory47 = {}
CoreFactory47.__index = CoreFactory47
ZxStartingGold.CoreFactory47 = CoreFactory47

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
