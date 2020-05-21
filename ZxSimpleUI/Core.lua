local ZxSimpleUI = LibStub("AceAddon-3.0"):NewAddon("ZxSimpleUI", "AceConsole-3.0",
                                                    "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")

---LibSharedMedia registers
local media = LibStub("LibSharedMedia-3.0")
media:Register("font", "PT Sans Bold", "Interface\\AddOns\\ZxSimpleUI\\fonts\\PTSansBold.ttf")

--- "PRIVATE" variables
local _defaults = {
  profile = {
    modules = {
      ["*"] = {enabled = true}
      -- PlayerName = {enabled = false}
    }
  }
}

--- "CONSTANTS"
ZxSimpleUI.ADDON_NAME = "ZxSimpleUI"
ZxSimpleUI.DECORATIVE_NAME = "Zx Simple UI"
ZxSimpleUI.SCREEN_WIDTH = math.floor(GetScreenWidth())
ZxSimpleUI.SCREEN_HEIGHT = math.floor(GetScreenHeight())
ZxSimpleUI.DEFAULT_FRAME_LEVEL = 15 -- maximum number with 4 bits
-- if 60 FPS, then 1 frame will be refreshed in 16.67 milliseconds.
local refreshEveryNFrame = 10
ZxSimpleUI.UPDATE_INTERVAL_SECONDS = 16 * refreshEveryNFrame / 1000.0

ZxSimpleUI.moduleOptionsTable = {}
ZxSimpleUI.optionFrameTable = {}
ZxSimpleUI.db = nil

function ZxSimpleUI:OnInitialize()
  ---Must initialize db AFTER SavedVariables is loaded!
  local dbName = self.ADDON_NAME .. "_DB" -- defined in .toc file, in ## SavedVariables
  self.db = LibStub("AceDB-3.0"):New(dbName, _defaults, true)

  self:Print(ChatFrame1, "YO")
  -- self:CreateFrame()
end

function ZxSimpleUI:OnEnable()
  self.db.RegisterCallback(self, "OnProfileChanged", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "refreshConfig")
end

-- function ZxSimpleUI:CreateFrame()
--   local frame = AceGUI:Create("Frame")
--   frame:SetTitle("Example Frame")
--   -- frame:SetStatusText("AceGUI-3.0 Example Container Frame")
--   frame:SetCallback("OnClose", function(widget)
--     -- Always release your frames once your UI doesn't need them anymore!
--     AceGUI:Release(widget)
--   end)
--   frame:SetLayout("Flow")

--   local healthbar = AceGUI:Create("Label")
--   healthbar:SetWidth(200)
--   healthbar:SetText(UnitHealthMax("PLAYER"))
--   frame:AddChild(healthbar)
-- end

---Refresh the configuration for this AddOn as well as any modules
---that are added to this AddOn
function ZxSimpleUI:refreshConfig()
  for k, curModule in ZxSimpleUI:IterateModules() do
    if ZxSimpleUI:getModuleEnabledState(k) and not curModule:IsEnabled() then
      ZxSimpleUI:EnableModule(k)
    elseif not ZxSimpleUI:getModuleEnabledState(k) and curModule:IsEnabled() then
      ZxSimpleUI:DisableModule(k)
    end

    --- Refresh every module connected to this AddOn
    if type(curModule.refreshConfig) == "function" then curModule:refreshConfig() end
  end
end

---@param name string
---@param optTable table
---@param displayName string
function ZxSimpleUI:registerModuleOptions(name, optTable, displayName)
  self.moduleOptionsTable[name] = optTable
  self.optionFrameTable[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
                                  self.ADDON_NAME, displayName or name, self.DECORATIVE_NAME,
                                  name)
end

---@param currentValue number
---@param maxValue number
---@return number
function ZxSimpleUI:calcPercentSafely(currentValue, maxValue)
  if (maxValue == 0.0) then return 0.0 end
  return currentValue / maxValue
end

---@param module string
function ZxSimpleUI:getModuleEnabledState(module)
  return self.db.profile.modules[module].enabled
end

---@param module string
---@param isEnabled boolean
function ZxSimpleUI:setModuleEnabledState(module, isEnabled)
  local oldEnabledValue = self.db.profile.modules[module].enabled
  self.db.profile.modules[module].enabled = isEnabled
  if oldEnabledValue ~= isEnabled then
    if isEnabled then
      self:EnableModule(module)
    else
      self:DisableModule(module)
    end
  end
end

---@param currentFrame table
function ZxSimpleUI:enableTooltip(currentFrame)
  currentFrame:SetScript("OnEnter", UnitFrame_OnEnter)
  currentFrame:SetScript("OnLeave", UnitFrame_OnLeave)
end

---@param unit string
---@return boolean
---Ref: https://wowwiki.fandom.com/wiki/SecureStateDriver
function ZxSimpleUI:getUnitWatchState(unit)
  return string.lower(unit) == "pet"
end
