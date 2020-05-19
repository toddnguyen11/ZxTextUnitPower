-- Target appears when
-- 1. Selected
-- 2. Being attacked
local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")
local CoreBarTemplate = ZxSimpleUI.CoreBarTemplate

local _MODULE_NAME = "TargetHealth"
local _DECORATIVE_NAME = "Target Health"
local TargetHealth = ZxSimpleUI:NewModule(_MODULE_NAME)
local media = LibStub("LibSharedMedia-3.0")

--- upvalues to prevent warnings
local LibStub = LibStub
local UIParent, CreateFrame, UnitHealth, UnitHealthMax = UIParent, CreateFrame, UnitHealth, UnitHealthMax
local UnitName, MAX_COMBO_POINTS, GetComboPoints = UnitName, MAX_COMBO_POINTS, GetComboPoints
local ToggleDropDownMenu, TargetFrameDropDown = ToggleDropDownMenu, TargetFrameDropDown
local unpack = unpack

TargetHealth.MODULE_NAME = _MODULE_NAME
TargetHealth.bars = nil
TargetHealth._UPDATE_INTERVAL_SECONDS = 0.15

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
    border = "None",
  }
}

function TargetHealth:OnInitialize()
  self.db = ZxSimpleUI.db:RegisterNamespace(_MODULE_NAME, _defaults)
  self._curDbProfile = self.db.profile
  self.bars = CoreBarTemplate:new(self._curDbProfile)
  self.bars.defaults = _defaults

  self:SetEnabledState(ZxSimpleUI:getModuleEnabledState(_MODULE_NAME))
  local optionsTable = self.bars:getOptionTable(_DECORATIVE_NAME)
  optionsTable = self:_addShowOption(optionsTable)
  ZxSimpleUI:registerModuleOptions(
    _MODULE_NAME, optionsTable, _DECORATIVE_NAME)

  self:__init__()
end

function TargetHealth:OnEnable()
  self:createBar()
  self:refreshConfig()
end

function TargetHealth:__init__()
  self._timeSinceLastUpdate = 0
  self._prevTargetHealth = UnitHealthMax("TARGET")
  self._mainFrame = nil
  self._comboPointsTable = {}
  self._allComboPointsHidden = true

  self._MEDIUM_COMBO_POINTS = 3
  self._yellowColor = {1.0, 1.0, 0.0, 1.0}
  self._orangeColor = {1.0, 0.65, 0.0, 1.0}
  self._redColor = {1.0, 0.0, 0.0, 1.0}
end

function TargetHealth:createBar()
  local targetUnitHealth = UnitHealth("TARGET")
  local targetUnitMaxHealth = UnitHealthMax("TARGET")
  local percentage = ZxSimpleUI:calcPercentSafely(targetUnitHealth, targetUnitMaxHealth)

  self._mainFrame = self.bars:createBar(percentage)
  -- Set this so Blizzard's internal engine can find `unit`
  self._mainFrame.unit = "Target"
  self:_createComboPointDisplay()

  self:_registerEvents()
  self._mainFrame:SetScript("OnUpdate", function(argsTable, elapsed)
    self:_onUpdateHandler(argsTable, elapsed)
  end)
  self._mainFrame:SetScript("OnEvent", function(argsTable, event, unit)
    self:_onEventHandler(argsTable, event, unit)
  end)
  self._mainFrame:SetScript("OnClick", function(argsTable, buttonType, isButtonDown)
    self:_onClickHandler(argsTable, buttonType, isButtonDown)
  end)

  ZxSimpleUI:enableTooltip(self._mainFrame)
  self._mainFrame:Hide()
end

function TargetHealth:refreshConfig()
  if self:IsEnabled() and self._mainFrame:IsVisible() then
    self.bars:refreshConfig()
  end
end

-- ####################################
-- # PRIVATE FUNCTIONS
-- ####################################

function TargetHealth:_registerEvents()
  self._mainFrame:RegisterEvent("UNIT_HEALTH")
  self._mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  self._mainFrame:RegisterEvent("UNIT_COMBO_POINTS")
end

function TargetHealth:_onEventHandler(argsTable, event, unit)
  if event == "PLAYER_TARGET_CHANGED" then
    self:_handlePlayerTargetChanged()
  elseif event == "UNIT_HEALTH" and string.upper(unit) == "TARGET" then
    self:_handleUnitHealthEvent()
  elseif event == "UNIT_COMBO_POINTS" then
    self:_handleComboPoints()
  end
end

function TargetHealth:_handlePlayerTargetChanged()
  local targetName = UnitName("TARGET")
  if targetName ~= nil and targetName ~= "" then
    self:_handleComboPoints()
    self:_setHealthValue()
    self._mainFrame:Show()
  else
    self._mainFrame:Hide()
  end
end

function TargetHealth:_onUpdateHandler(argsTable, elapsed)
  if not self._mainFrame:IsVisible() then return end
  self._timeSinceLastUpdate = self._timeSinceLastUpdate + elapsed
  if (self._timeSinceLastUpdate > self._UPDATE_INTERVAL_SECONDS) then
    local curUnitHealth = UnitHealth("TARGET")
    if (curUnitHealth ~= self._prevTargetHealth) then
      self:_handleUnitHealthEvent(curUnitHealth)
      self._prevTargetHealth = curUnitHealth
      self._timeSinceLastUpdate = 0
    end
  end
end

function TargetHealth:_onClickHandler(argsTable, buttonType, isButtonDown)
  if buttonType == "RightButton" then
    ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
  end
end

function TargetHealth:_handleUnitHealthEvent(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth("TARGET")
  if (curUnitHealth > 0) then
    self:_setHealthValue(curUnitHealth)
  else
    self._mainFrame.mainText:SetText("Dead")
    self._mainFrame.statusBar:SetValue(0)
  end
end

function TargetHealth:_handleComboPoints()
  local comboPoints = GetComboPoints("PLAYER", "TARGET")
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

function TargetHealth:_addShowOption(optionsTable)
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

function TargetHealth:_setHealthValue(curUnitHealth)
  curUnitHealth = curUnitHealth or UnitHealth("TARGET")
  if curUnitHealth > 0 then
    local maxUnitHealth = UnitHealthMax("TARGET")
    local healthPercent = ZxSimpleUI:calcPercentSafely(curUnitHealth, maxUnitHealth)
    self.bars:_setStatusBarValue(healthPercent)
  end
end

function TargetHealth:_createComboPointDisplay()
  local horizGap = 15
  local totalNumberOfGaps = horizGap * (MAX_COMBO_POINTS - 1)
  local comboWidth = (self._mainFrame:GetWidth() - totalNumberOfGaps) / MAX_COMBO_POINTS
  local comboHeight = 8

  local comboFrame = CreateFrame("Frame", nil, self._mainFrame)
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

function TargetHealth:_hideAllComboPoints()
  for i = 1, MAX_COMBO_POINTS do
    self._comboPointsTable[i]:Hide()
  end
end

---@param comboPoints integer
---@param currentTexture table
function TargetHealth:_setComboPointsColor(comboPoints, currentTexture)
  if comboPoints >= MAX_COMBO_POINTS then
    currentTexture:SetVertexColor(unpack(self._redColor))
  elseif comboPoints >= self._MEDIUM_COMBO_POINTS then
    currentTexture:SetVertexColor(unpack(self._orangeColor))
  else
    currentTexture:SetVertexColor(unpack(self._yellowColor))
  end
end
