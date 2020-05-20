local media = LibStub("LibSharedMedia-3.0")
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local PlayerHealth47 = ZxSimpleUI:GetModule("PlayerHealth47")
local PlayerPower47 = ZxSimpleUI:GetModule("PlayerPower47")
local PlayerName47 = ZxSimpleUI:GetModule("PlayerName47")

-- Upvalues
local ToggleDropDownMenu, PlayerFrameDropDown = ToggleDropDownMenu, PlayerFrameDropDown
local RegisterUnitWatch = RegisterUnitWatch

local _MODULE_NAME = "Player47"
local _DECORATIVE_NAME = "Player"
local Player47 = ZxSimpleUI:NewModule(_MODULE_NAME)
Player47.unit = "player"

function Player47:OnInitialize()
  self:__init__()
end

function Player47:OnEnable()
  self:_createBars()
  self:_setRegisterForWatch()
end

function Player47:__init__()
  self._barLists = {}
end

function Player47:refreshConfig()
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function Player47:_createBars()
  self._barLists["PlayerHealth47"] = PlayerHealth47:createBar()
  self._barLists["PlayerPower47"] = PlayerPower47:createBar()
  self._barLists["PlayerName47"] = PlayerName47:createBar()
end

function Player47:_setRegisterForWatch()
  for _, playerFrame in pairs(self._barLists) do
    -- Set this so Blizzard's internal engine can find `unit`
    -- Also help RegisterUnitWatch
    playerFrame.unit = self.unit
    playerFrame:SetAttribute("unit", playerFrame.unit)
    -- Handle right click
    playerFrame.menu = function()
      ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
    end

    ZxSimpleUI:enableTooltip(playerFrame)
    RegisterUnitWatch(playerFrame, ZxSimpleUI:getUnitWatchState(playerFrame.unit))
  end
end
