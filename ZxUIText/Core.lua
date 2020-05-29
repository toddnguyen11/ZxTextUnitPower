--- Upvalues
local LibStub = LibStub

--- Includes
local ADDON_NAME = "ZxUIText"
local ZxUIText = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")
---LibSharedMedia registers
local media = LibStub("LibSharedMedia-3.0")
local fontsFilepath = "Interface\\AddOns\\ZxUIText\\fonts\\"
media:Register("font", "Open Sans", fontsFilepath .. "OpenSansRegular.ttf")
media:Register("font", "Open Sans Bold", fontsFilepath .. "OpenSansBold.ttf")
media:Register("font", "PT Sans", fontsFilepath .. "PTSansRegular.ttf")
media:Register("font", "PT Sans Bold", fontsFilepath .. "PTSansBold.ttf")
media:Register("font", "Roboto", fontsFilepath .. "RobotoRegular.ttf")
media:Register("font", "Roboto Bold", fontsFilepath .. "RobotoBold.ttf")

--- All this below is needed!
ZxUIText.ADDON_NAME = ADDON_NAME
ZxUIText.DECORATIVE_NAME = "Zx UI Text"
ZxUIText.SLASH_COMMANDS = {"zxuitext"}
ZxUIText.moduleOptionsTable = {}
ZxUIText.moduleKeySorted = {}
ZxUIText.blizOptionTable = {}
ZxUIText.optionTables = {}
ZxUIText.db = nil
ZxUIText.DEFAULT_FRAME_LEVEL = 15 -- maximum number with 4 bits
ZxUIText.DEFAULT_ORDER_INDEX = 7
ZxUIText.HEADER_ORDER_INDEX = 1
local _defaults = {profile = {modules = {["*"] = {enabled = true}}}}
--- End

function ZxUIText:OnInitialize()
  ---Must initialize db AFTER SavedVariables is loaded!
  local dbName = self.ADDON_NAME .. "_DB" -- defined in .toc file, in ## SavedVariables
  self.db = LibStub("AceDB-3.0"):New(dbName, _defaults, true)
end

function ZxUIText:OnEnable()
  self.db.RegisterCallback(self, "OnProfileChanged", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "refreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "refreshConfig")
end

---Refresh the configuration for this AddOn as well as any modules
---that are added to this AddOn
function ZxUIText:refreshConfig()
  for k, curModule in ZxUIText:IterateModules() do
    if ZxUIText:getModuleEnabledState(k) and not curModule:IsEnabled() then
      ZxUIText:EnableModule(k)
    elseif not ZxUIText:getModuleEnabledState(k) and curModule:IsEnabled() then
      ZxUIText:DisableModule(k)
    end

    --- Refresh every module connected to this AddOn
    if type(curModule.refreshConfig) == "function" then curModule:refreshConfig() end
  end
end

---@param name string
---@param optTable table
---@param displayName string
function ZxUIText:registerModuleOptions(name, optTable, displayName)
  self.moduleOptionsTable[name] = optTable
  table.insert(self.moduleKeySorted, name)
end

---@param module string
function ZxUIText:getModuleEnabledState(module)
  ---return statement
  return self.db.profile["modules"][module]["enabled"]
end

---@param module string
---@param isEnabled boolean
function ZxUIText:setModuleEnabledState(module, isEnabled)
  local oldEnabledValue = self.db.profile.modules[module].enabled
  self.db.profile["modules"][module]["enabled"] = isEnabled
  if oldEnabledValue ~= isEnabled then
    if isEnabled then
      self:EnableModule(module)
    else
      self:DisableModule(module)
    end
  end
end
