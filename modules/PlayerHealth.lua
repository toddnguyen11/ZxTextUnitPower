local ZxSimpleUI = LibStub("AceAddon-3.0"):GetAddon("ZxSimpleUI")

local _MODULE_NAME = "PlayerHealth"
local _DECORATIVE_NAME = "Player Health"
local PlayerHealth = ZxSimpleUI:NewModule(_MODULE_NAME)
local SharedMedia = LibStub("LibSharedMedia-3.0")

-- "PRIVATE" variables
local _getOption, _setOption
PlayerHealth._HealthBarFrame = nil

local _defaults = {
  profile = {
    healthbarwidth = 100
  }
}

function PlayerHealth:OnInitialize()
  self.db = ZxSimpleUI.db
  self:CreateSimpleGroup()
end

function PlayerHealth:OnEnable()
  self:refreshConfig()
end

function PlayerHealth:refreshConfig()
  if self:IsEnabled() then
    self._HealthBarFrame:SetWidth(self.db.profile.healthbarwidth)
    self._HealthBarFrame:SetHeight(self.db.profile.healthbarheight)
  end
end

function PlayerHealth:CreateSimpleGroup()
  self._HealthBarFrame = CreateFrame("Frame", nil, UIParent)
  self._HealthBarFrame:SetPoint("CENTER", nil, nil, 0, 0)
  self._HealthBarFrame:SetBackdrop(ZxSimpleUI.frameBackdropTable)
  self._HealthBarFrame:SetBackdropColor(1, 0, 0, 1)

  self._HealthBarFrame.StatusBar = CreateFrame("StatusBar", nil, self._HealthBarFrame)
  self._HealthBarFrame.StatusBar:SetPoint("LEFT", self._HealthBarFrame, "LEFT")
  self._HealthBarFrame.StatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  self._HealthBarFrame.StatusBar:SetStatusBarColor(1, 0, 0, 1)
  self._HealthBarFrame.StatusBar:SetWidth(self._HealthBarFrame:GetWidth())
  self._HealthBarFrame.StatusBar:SetHeight(self._HealthBarFrame:GetHeight())

  self._HealthBarFrame.Text = self._HealthBarFrame:CreateFontString(nil, "OVERLAY")
  self._HealthBarFrame.Text:SetFont("Interface\\AddOns\\ZxSimpleUI\\fonts\\PTSansBold.ttf", 16, "OUTLINE")
  self._HealthBarFrame.Text:SetTextColor(0.0, 0.0, 0.0, 1.0)
  self._HealthBarFrame.Text:SetText("HELLO THERE")
  self._HealthBarFrame.Text:SetPoint("LEFT", self._HealthBarFrame, "LEFT", 0, 0)

  self._HealthBarFrame:Show()
  ZxSimpleUI:Print(self._HealthBarFrame:GetWidth())
end
