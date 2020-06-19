---Upvalues
local LibStub, ChatFrame1 = LibStub, ChatFrame1

local UIParent = UIParent
UIParent.DECORATIVE_NAME = "UIParent"

--- AddOn Declaration
local ADDON_NAME = "ZxStartingGold"
local ZxStartingGold = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")

--- All this below is needed!
ZxStartingGold.ADDON_NAME = ADDON_NAME
ZxStartingGold.DECORATIVE_NAME = "Zx Starting Gold"
ZxStartingGold.SLASH_COMMANDS = {"zxstartinggold", "zxgold"}
ZxStartingGold.moduleOptionsTable = {}
ZxStartingGold.moduleKeySorted = {}
ZxStartingGold.blizOptionTable = {}
ZxStartingGold.optionTables = {}
ZxStartingGold.prereqTables = {}
ZxStartingGold.frameList = {["UIParent"] = {frame = UIParent, name = "UIParent"}}
ZxStartingGold.db = nil
ZxStartingGold.DEFAULT_FRAME_LEVEL = 15 -- maximum number with 4 bits
ZxStartingGold.DEFAULT_ORDER_INDEX = 7
ZxStartingGold.HEADER_ORDER_INDEX = 1
local _defaults = {profile = {["modules"] = {["*"] = {["enabled"] = true}}}}
--- End

-- if 60 FPS, then 1 frame will be refreshed in 16.67 milliseconds.
local refreshEveryNFrame = 10
ZxStartingGold.UPDATE_INTERVAL_SECONDS = 16 * refreshEveryNFrame / 1000.0

function ZxStartingGold:OnInitialize()
  ---Must initialize db AFTER SavedVariables is loaded!
  local dbName = self.ADDON_NAME .. "_DB" -- defined in .toc file, in ## SavedVariables
  self.db = LibStub("AceDB-3.0"):New(dbName, _defaults, true)

  self:Print(ChatFrame1, "YO")
end

function ZxStartingGold:OnEnable()
  self.db.RegisterCallback(self, "OnProfileChanged", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "refreshConfig")
end

---Refresh the configuration for this AddOn as well as any modules
---that are added to this AddOn
function ZxStartingGold:refreshConfig()
  for k, curModule in ZxStartingGold:IterateModules() do
    if ZxStartingGold:getModuleEnabledState(k) and not curModule:IsEnabled() then
      ZxStartingGold:EnableModule(k)
    elseif not ZxStartingGold:getModuleEnabledState(k) and curModule:IsEnabled() then
      ZxStartingGold:DisableModule(k)
    end

    --- Refresh every module connected to this AddOn
    if type(curModule.refreshConfig) == "function" then curModule:refreshConfig() end
  end
end

---@param name string
---@param optTable table
---@param displayName string
function ZxStartingGold:registerModuleOptions(name, optTable, displayName)
  self.moduleOptionsTable[name] = optTable
  table.insert(self.moduleKeySorted, name)
end
