local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local AceConfig = LibStub("AceConfig-3.0")

local CoreOptionsInterface = ZxSimpleUI:NewModule("Options", nil)

-- PRIVATE functions and variables
---@param key string
local _curDbProfile
local _getOptionsTable, _getOption, _setOption, _applySettings
local _handle_healthbar_positionx_center, _handle_healthbar_positiony_center
local _incrementOrderIndex
local _orderIndex = 1

function CoreOptionsInterface:OnInitialize()
  _curDbProfile = ZxSimpleUI.db.profile
  self:SetupOptions()
end

function CoreOptionsInterface:SetupOptions()
  ZxSimpleUI.optionFrameTable = {}
  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ZxSimpleUI.ADDON_NAME, _getOptionsTable)

  local frameRef = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ZxSimpleUI.ADDON_NAME,
                                                                   ZxSimpleUI.DECORATIVE_NAME,
                                                                   nil, "general")
  ZxSimpleUI.optionFrameTable[ZxSimpleUI.ADDON_NAME] = frameRef

  -- Set profile options
  ZxSimpleUI:registerModuleOptions("Profiles",
                                   LibStub("AceDBOptions-3.0"):GetOptionsTable(ZxSimpleUI.db),
                                   "Profiles")
end

-- ########################################
-- # "PRIVATE" functions
-- ########################################

local options = nil

---@return table
function _getOptionsTable()
  if not options then
    options = {
      type = "group",
      args = {
        general = {
          type = "group",
          name = "", -- this is required!
          args = {}
        }
      }
    }

    local frameLevel = 7
    for moduleKey, val in pairs(ZxSimpleUI.optionFrameTable) do
      if moduleKey ~= ZxSimpleUI.ADDON_NAME then
        options.args.general.args[moduleKey] = {
          type = "execute",
          name = val.name,
          func = function()
            InterfaceOptionsFrame_OpenToCategory(val)
          end,
          order = frameLevel
        }
        if moduleKey == "Profiles" then
          options.args.general.args[moduleKey]["order"] = frameLevel - 2
        end
      end
    end

    for k, v in pairs(ZxSimpleUI.moduleOptionsTable) do
      options.args[k] = (type(v) == "function") and v() or v
    end
  end

  return options
end
