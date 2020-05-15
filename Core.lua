local ZxSimpleUI = LibStub("AceAddon-3.0"):NewAddon("ZxSimpleUI", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")
---LibSharedMedia
local media = LibStub("LibSharedMedia-3.0")

--- "PRIVATE" variables
local _HealthBarFrame
local _defaults = {
  profile = {
    modules = { ["*"] = true },
    healthbarwidth = 100,
    powerbarwidth = 100,
  }
}

function ZxSimpleUI:OnInitialize()
  ---Must initialize db AFTER SavedVariables is loaded!
  self.db = LibStub("AceDB-3.0"):New("ZxSimpleUI_DB", _defaults, true)
  self:Print(ChatFrame1, "YO")
  self:CreateSimpleGroup()
  -- self:CreateFrame()
end

-- function ZxSimpleUI:CreateFrame()
--   local frame = AceGUI:Create("Frame")
--   frame:SetTitle("Example Frame")
--   -- frame:SetStatusText("AceGUI-3.0 Example Container Frame")
--   frame:SetCallback("OnClose", function(widget)
--     -- Always release your frames once your UI doesn't need them anymore!
--     AceGUI:Release(widget)
--   end)
--   frame:SetLayout("Flow")

--   local healthbar = AceGUI:Create("Label")
--   healthbar:SetWidth(200)
--   healthbar:SetText(UnitHealthMax("PLAYER"))
--   frame:AddChild(healthbar)
-- end

local _FrameBackdropTable = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

function ZxSimpleUI:CreateSimpleGroup()
  _HealthBarFrame = CreateFrame("Frame", nil, UIParent)
  _HealthBarFrame:SetPoint("CENTER", nil, nil, 0, 0)
  _HealthBarFrame:SetBackdrop(_FrameBackdropTable)
  _HealthBarFrame:SetBackdropColor(1, 0, 0, 1)
  _HealthBarFrame:SetWidth(200)
  _HealthBarFrame:SetHeight(200)

  _HealthBarFrame.StatusBar = CreateFrame("StatusBar", nil, _HealthBarFrame)
  _HealthBarFrame.StatusBar:SetPoint("LEFT", _HealthBarFrame, "LEFT")
  _HealthBarFrame.StatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  _HealthBarFrame.StatusBar:SetStatusBarColor(1, 0, 0, 1)
  _HealthBarFrame.StatusBar:SetWidth(_HealthBarFrame:GetWidth())
  _HealthBarFrame.StatusBar:SetHeight(_HealthBarFrame:GetHeight())

  _HealthBarFrame.Text = _HealthBarFrame:CreateFontString(nil, "OVERLAY")
  _HealthBarFrame.Text:SetFont("Interface\\AddOns\\ZxSimpleUI\\fonts\\PTSansBold.ttf", 16, "OUTLINE")
  _HealthBarFrame.Text:SetTextColor(0.0, 0.0, 0.0, 1.0)
  _HealthBarFrame.Text:SetText("HELLO THERE")
  _HealthBarFrame.Text:SetPoint("LEFT", _HealthBarFrame, "LEFT", 0, 0)

  _HealthBarFrame:Show()
  print(_HealthBarFrame:GetWidth())
end

function ZxSimpleUI:isModuleEnabled(module)
  return self.db.profile.modules[module]
end
