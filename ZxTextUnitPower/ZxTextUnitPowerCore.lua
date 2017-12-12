local function shortenNumber(number)
	local strNumber = nil

	if number < 1000 then
		strNumber = string.format("%d", number)
	elseif number < 1000000 then
		strNumber = string.format("%.1fK", number/1000)
	else
		strNumber = string.format("%.1fM", number/1000000)
	end

	return strNumber
end


local function getRgb()
	-- Get color
	local powerType, powerToken, altR, altG, altB = UnitPowerType("Player")
	local info = PowerBarColor[powerToken]

	if info then
		r, g, b = info.r, info.g, info.b
	else
		if not altR then
			-- couldn't find a power token entry. default to mana
			info = PowerBarColor[powerType] or PowerBarColor["MANA"]
			r, g, b = info.r, info.g, info.b
		else
			r, g, b = altR, altG, altB
		end
	end

	return r, g, b
end

-- Wrapper function to register for multipke power types
local function registerForEvents(unitInput)
	ZxMasterFrame.MainFrame:RegisterEvent(unitInput)
end


function createUnitDisplay()
	ZxMasterFrame.MainFrame.UnitPowerDisplay = ZxMasterFrame.MainFrame:CreateFontString(nil, "OVERLAY");
	ZxMasterFrame.MainFrame.UnitPowerDisplay:SetFont("Interface\\AddOns\\ActionBarFont\\ptsans-bold.ttf", 16, "OUTLINE");
	ZxMasterFrame.MainFrame.UnitPowerDisplay:SetAllPoints();

	registerForEvents("ADDON_LOADED");
	registerForEvents("UNIT_MANA");
	registerForEvents("UNIT_RAGE");
	registerForEvents("UNIT_ENERGY");
	registerForEvents("UNIT_RUNIC_POWER");
	
	ZxMasterFrame.MainFrame:SetScript("OnEvent", function(self, event, unit)
		ZxMasterFrame.MainFrame.UnitPowerDisplay:SetText(shortenNumber(UnitPower("Player")))
	end);
end


local function init(_, _, name)
	if (name ~= "ZxTextUnitFrame") then return; end

	r, g, b = getRgb()

	ZxMasterFrame = CreateFrame("Frame", "ZxMasterFrame", UIParent)
	
	ZxMasterFrame.MainFrame = CreateFrame("Frame", "MainFrame", ZxMasterFrame)
	ZxMasterFrame.MainFrame:SetSize(50,25)
	ZxMasterFrame.MainFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", -20, -20)
	ZxMasterFrame.MainFrame:SetMovable(true)
	ZxMasterFrame.MainFrame:EnableMouse(true)
	ZxMasterFrame.MainFrame:RegisterForDrag("LeftButton")
	ZxMasterFrame.MainFrame:SetScript("OnDragStart", ZxMasterFrame.MainFrame.StartMoving)
	ZxMasterFrame.MainFrame:SetScript("OnDragStop", ZxMasterFrame.MainFrame.StopMovingOrSizing)

	ZxMasterFrame.MainFrame.texture1 = ZxMasterFrame.MainFrame:CreateTexture(nil, "BACKGROUND")
	ZxMasterFrame.MainFrame.texture1:SetTexture(r, g, b, 0.5)
	ZxMasterFrame.MainFrame.texture1:SetAllPoints()

	createUnitDisplay()
end


local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", init);