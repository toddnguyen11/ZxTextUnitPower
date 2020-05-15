local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local AceConfig = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")
---LibSharedMedia
local media = LibStub("LibSharedMedia-3.0")

local CoreOptionsInterface = ZxSimpleUI:NewModule("Options", nil)
CoreOptionsInterface._MIN_BAR_SIZE = 10
CoreOptionsInterface._MAX_BAR_SIZE = math.floor(GetScreenWidth() / 2)
CoreOptionsInterface._APP_NAME = "ZxSimpleUI"
CoreOptionsInterface._STEP = 2

-- PRIVATE functions and variables
---@param key string
local _getOption, _setOption, _applySettings

function CoreOptionsInterface:OnInitialize()
  self:SetupOptions()
end

function CoreOptionsInterface:SetupOptions()
  local optionsTable = self:_getOptionsTable()
  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(self._APP_NAME, optionsTable)
  local frameRef = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
    self._APP_NAME, "Zx Simple UI", nil, "general")
end

-- ########################################
-- # "PRIVATE" functions
-- ########################################

---@return table
function CoreOptionsInterface:_getOptionsTable()
  if not self._optionsTable then
    self._optionsTable = {
      type = "group",
      args = {
        general = {
          type = "group",
          name = "", -- this is required!
          args = {
            healthbarwidth = {
              name = "Health Bar Width",
              desc = "Health Bar Width Size",
              type = "range",
              min = self._MIN_BAR_SIZE, max = self._MAX_BAR_SIZE,
              step = self._STEP,
              get = _getOption,
              set = _setOption,
              order = 0,
            },
            healthbarheight = {
              name = "Health Bar Height",
              desc = "Health Bar Height Size",
              type = "range",
              min = self._MIN_BAR_SIZE, max = self._MAX_BAR_SIZE,
              step = self._STEP,
              get = _getOption,
              set = _setOption,
              order = 1,
            },
            powerbarwidth = {
              name = "Power Bar Width",
              desc = "Power Bar Width Size",
              type = "range",
              min = self._MIN_BAR_SIZE, max = self._MAX_BAR_SIZE,
              step = self._STEP,
              get = _getOption,
              set = _setOption,
              order = 2,
            }
          }
        }
      }
    }
  end

  return self._optionsTable
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
