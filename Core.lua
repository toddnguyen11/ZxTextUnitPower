local ZxSimpleUI = LibStub("AceAddon-3.0"):NewAddon("ZxSimpleUI", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")
---LibSharedMedia
local media = LibStub("LibSharedMedia-3.0")

--- "CONSTANTS"
ZxSimpleUI.ADDON_NAME = "ZxSimpleUI"
ZxSimpleUI.DECORATIVE_NAME = "Zx Simple UI"

--- "PRIVATE" variables
local _defaults = {
  profile = {
    modules = { ["*"] = true }
  }
}

ZxSimpleUI.moduleOptionsTable = {}
ZxSimpleUI.optionFrameTable = {}

ZxSimpleUI.frameBackdropTable = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

function ZxSimpleUI:OnInitialize()
  ---Must initialize db AFTER SavedVariables is loaded!
  local dbName = self.ADDON_NAME .. "_DB"
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

function ZxSimpleUI:isModuleEnabled(module)
  return self.db.profile.modules[module]
end

function ZxSimpleUI:refreshConfig()
  for k,v in ZxSimpleUI:IterateModules() do
    if ZxSimpleUI:isModuleEnabled(k) and not v:IsEnabled() then
      ZxSimpleUI:EnableModule(k)
    elseif not ZxSimpleUI:isModuleEnabled(k) and v:IsEnabled() then
      ZxSimpleUI:DisableModule(k)
    end

    if type(v.refreshConfig) == "function" then
      v:refreshConfig()
    end
  end
end

---@param name string
---@param optTable table
---@param displayName string
function ZxSimpleUI:registerModuleOptions(name, optTable, displayName)
  self.moduleOptionsTable[name] = optTable
  self.optionFrameTable[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
    self.ADDON_NAME, displayName or name, self.DECORATIVE_NAME, name
  )
end
