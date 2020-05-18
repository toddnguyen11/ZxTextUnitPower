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
            }
            -- powerbarwidth = {
            --   name = "Power Bar Width",
            --   desc = "Power Bar Width Size",
            --   type = "range",
            --   min = CoreOptionsInterface._MIN_BAR_SIZE, max = CoreOptionsInterface._MAX_BAR_SIZE,
            --   step = 2,
            --   get = _getOption,
            --   set = _setOption,
            --   order = _incrementOrderIndex(),
            -- },
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

---@param infoTable table
function _getOption(infoTable)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  return ZxSimpleUI.db.profile[key]
end

---@param infoTable table
---@param value any
function _setOption(infoTable, value)
  -- Not sure how this gets the key... but it does
  local key = infoTable[#infoTable]
  ZxSimpleUI.db.profile[key] = value
  ZxSimpleUI:refreshConfig()
end

function _incrementOrderIndex()
  local i = _orderIndex
  _orderIndex = _orderIndex + 1
  return _orderIndex
end

function _handle_healthbar_positionx_center()
  local width = _curDbProfile.healthbar_width

  local centerXPos = math.floor(ZxSimpleUI.SCREEN_WIDTH / 2 - width / 2)
  _curDbProfile.healthbar_positionx = centerXPos
  ZxSimpleUI:refreshConfig()
end

function _handle_healthbar_positiony_center()
  local height = _curDbProfile.healthbar_height

  local centerYPos = math.floor(ZxSimpleUI.SCREEN_HEIGHT / 2 - height / 2)
  _curDbProfile.healthbar_positiony = centerYPos
  ZxSimpleUI:refreshConfig()
end
