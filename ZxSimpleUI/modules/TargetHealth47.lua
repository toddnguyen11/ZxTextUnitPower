-- Target appears when
-- 1. Selected
-- 2. Being attacked
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate
local Utils47 = ZxSimpleUI.Utils47

local _MODULE_NAME = "TargetHealth47"
local _DECORATIVE_NAME = "Target Health"
local TargetHealth47 = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local CreateFrame, UnitHealth, UnitHealthMax = CreateFrame, UnitHealth, UnitHealthMax
local UnitName, MAX_COMBO_POINTS, GetComboPoints = UnitName, MAX_COMBO_POINTS, GetComboPoints
local unpack = unpack

TargetHealth47.MODULE_NAME = _MODULE_NAME
TargetHealth47.bars = nil
TargetHealth47.unit = "target"

local _defaults = {
  profile = {
    width = 200,
    height = 26,
    positionx = 700,
    positiony = 270,
    fontsize = 14,
    font = "Friz Quadrata TT",
    fontcolor = {1.0, 1.0, 1.0},
    texture = "Blizzard",
    color = {0.0, 1.0, 0.0, 1.0},
    border = "None"
  }
}

function TargetHealth47:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  local optionsTable = self.bars:getOptionTable(_DECORATIVE_NAME)
  optionsTable = self:_addShowOption(optionsTable)
  ZxSimpleUI:registerModuleOptions(_MODULE_NAME, optionsTable, _DECORATIVE_NAME)

  self:__init__()
end

function TargetHealth47:OnEnable()
end

function TargetHealth47:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetHealth47 = UnitHealthMax(self.unit)
  self._mainFrame = nil
  self._comboPointsTable = {}
  self._allComboPointsHidden = true

  self._MEDIUM_COMBO_POINTS = 3
  self._yellowColor = {1.0, 1.0, 0.0, 1.0}
  self._orangeColor = {1.0, 0.65, 0.0, 1.0}
  self._redColor = {1.0, 0.0, 0.0, 1.0}
end

function TargetHealth47:createBar()
  local targetUnitHealth = UnitHealth(self.unit)
  local targetUnitMaxHealth = UnitHealthMax(self.unit)
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitHealth, targetUnitMaxHealth)

  self._mainFrame = self.bars:createBar(percentage)
  self:_createComboPointDisplay()

  self:_registerEvents()
  self:_setScriptHandlers()

  self._mainFrame:Hide()
  return self._mainFrame
end

function TargetHealth47:refreshConfig()
  if self:IsEnabled() and self._mainFrame:IsVisible() then self.bars:refreshConfig() end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetHealth47:_registerEvents()
  self._mainFrame:RegisterEvent("UNIT_HEALTH")
  self._mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  self._mainFrame:RegisterEvent("UNIT_COMBO_POINTS")
end

function TargetHealth47:_setScriptHandlers()
  self._mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
  self._mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
end

function TargetHealth47:_onEventHandler(argsTable, event, unit)
  if Utils47:stringEqualsIgnoreCase(event, "PLAYER_TARGET_CHANGED") then
    self:_handlePlayerTargetChanged()
  elseif Utils47:stringEqualsIgnoreCase(event, "UNIT_HEALTH") and
    Utils47:stringEqualsIgnoreCase(unit, self.unit) then
    self:_handleUnitHealthEvent()
  elseif Utils47:stringEqualsIgnoreCase(event, "UNIT_COMBO_POINTS") then
    self:_handleComboPoints()
  end
end

function TargetHealth47:_handlePlayerTargetChanged()
  local targetName = UnitName(self.unit)
  if targetName ~= nil and targetName ~= "" then
    self:_handleComboPoints()
    self:_setHealthValue()
  end
end

function TargetHealth47:_onUpdateHandler(argsTable, elapsed)
  if not self._mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > ZxSimpleUI.UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth(self.unit)
    if (curUnitHealth ~= self._prevTargetHealth47) then
      self:_handleUnitHealthEvent(curUnitHealth)
      self._prevTargetHealth47 = curUnitHealth
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetHealth47:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  self:_setHealthValue(curUnitHealth)
end

function TargetHealth47:_handleComboPoints()
  local comboPoints = GetComboPoints("PLAYER", self.unit)
  if not self._allComboPointsHidden and comboPoints == 0 then
    self:_hideAllComboPoints()
    self._allComboPointsHidden = true
  else
    for i = 1, comboPoints do
      local currentTexture = self._comboPointsTable[i]
      self:_setComboPointsColor(comboPoints, currentTexture)
      currentTexture:Show()
      self._allComboPointsHidden = false
    end
  end
end

function TargetHealth47:_addShowOption(optionsTable)
  optionsTable.args["show"] = {
    type = "execute",
    name = "Show Bar",
    desc = "Show/Hide the Target Health",
    func = function()
      if self._mainFrame:IsVisible() then
        self._mainFrame:Hide()
      else
        self._mainFrame:Show()
        self.bars:_setStatusBarValue(0.8)
      end
    end
  }
  return optionsTable
end

function TargetHealth47:_setHealthValue(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth(self.unit)
  local maxUnitHealth = UnitHealthMax(self.unit)
  local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
  self.bars:_setStatusBarValue(healthPercent)
end

function TargetHealth47:_createComboPointDisplay()
  local horizGap = 15
  local totalNumberOfGaps = horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._mainFrame:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS
  local comboHeight = 8

  local comboFrame = CreateFrame("Frame", nil, self._mainFrame)
  comboFrame:SetFrameLevel(ZxSimpleUI.DEFAULT_FRAME_LEVEL + 2)
  comboFrame:SetWidth(self._mainFrame:GetWidth())
  comboFrame:SetHeight(comboHeight)
  comboFrame:SetPoint("BOTTOMLEFT", self._mainFrame, "TOPLEFT", 0, 0)

  -- Create all MAX_COMBO_POINTS frames
  for i = 1, MAX_COMBO_POINTS do
    local parentFrame, anchorDirection = nil, nil
    local xoffset, yoffset = 0, 0
    if i == 1 then
      parentFrame = comboFrame
      anchorDirection = "BOTTOMLEFT"
      xoffset = 0
      yoffset = 0
    else
      parentFrame = self._comboPointsTable[i - 1]
      anchorDirection = "BOTTOMRIGHT"
      xoffset = horizGap
      yoffset = 0
    end
    local comboTexture = comboFrame:CreateTexture(nil, "OVERLAY")
    comboTexture:ClearAllPoints()
    comboTexture:SetWidth(comboWidth)
    comboTexture:SetHeight(comboHeight)
    comboTexture:SetPoint("BOTTOMLEFT", parentFrame, anchorDirection, xoffset, yoffset)
    comboTexture:SetTexture(media:Fetch("statusbar", self._curDbProfile.texture))
    comboTexture:SetVertexColor(unpack(self._yellowColor))
    comboTexture:Hide()
    self._comboPointsTable[i] = comboTexture
  end

  self._mainFrame.comboFrame = comboFrame
end

function TargetHealth47:_hideAllComboPoints()
  for i = 1, MAX_COMBO_POINTS do self._comboPointsTable[i]:Hide() end
end

---@param comboPoints integer
---@param currentTexture table
function TargetHealth47:_setComboPointsColor(comboPoints, currentTexture)
  if comboPoints >= MAX_COMBO_POINTS then
    currentTexture:SetVertexColor(unpack(self._redColor))
  elseif comboPoints >= self._MEDIUM_COMBO_POINTS then
    currentTexture:SetVertexColor(unpack(self._orangeColor))
  else
    currentTexture:SetVertexColor(unpack(self._yellowColor))
  end
end
