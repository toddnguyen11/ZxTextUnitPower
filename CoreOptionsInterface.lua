local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local AceConfig = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")
---LibSharedMedia
local media = LibStub("LibSharedMedia-3.0")

local CoreOptionsInterface = ZxSimpleUI:NewModule("Options", nil)
CoreOptionsInterface._MIN_BAR_SIZE = 10
CoreOptionsInterface._MAX_BAR_SIZE = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2)

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
  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(
    ZxSimpleUI.ADDON_NAME, _getOptionsTable)
  ZxSimpleUI.optionFrameTable[ZxSimpleUI.ADDON_NAME] =
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
      ZxSimpleUI.ADDON_NAME, ZxSimpleUI.DECORATIVE_NAME, nil, "general"
    )

  -- Set profile options
  ZxSimpleUI:registerModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(
    ZxSimpleUI.db), "Profiles")
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
          args = {
            openPlayerHealth = {
              name = "Player Health",
              type = "execute",
              func = function()
                InterfaceOptionsFrame_OpenToCategory(ZxSimpleUI.optionFrameTable.PlayerHealth)
              end
            },
            openPlayerPower = {
              name = "Player Power",
              type = "execute",
              func = function()
                InterfaceOptionsFrame_OpenToCategory(ZxSimpleUI.optionFrameTable.PlayerPower)
              end
            },
            openTargetHealth = {
              name = "Target Health",
              type = "execute",
              func = function()
                InterfaceOptionsFrame_OpenToCategory(ZxSimpleUI.optionFrameTable.TargetHealth)
              end
            },
            openTargetPower = {
              name = "Target Power",
              type = "execute",
              func = function()
                InterfaceOptionsFrame_OpenToCategory(ZxSimpleUI.optionFrameTable.TargetPower)
              end
            }
          }
        }
      }
    }

    for k,v in pairs(ZxSimpleUI.moduleOptionsTable) do
      options.args[k] = (type(v) == "function") and v() or v
    end
  end

  return options
end
