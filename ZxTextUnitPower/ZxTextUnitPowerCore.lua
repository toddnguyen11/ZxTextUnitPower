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

-- Wrapper function to color texture
local function drawTexture()
	r, g, b = getRgb();
	ZxMasterFrame.MainFrame.texture1:SetTexture(r, g, b, 0.6);
	ZxMasterFrame.MainFrame.texture1:SetAllPoints();
end

powerRegistered = {
	"UNIT_MANA",
	"UNIT_RAGE",
	"UNIT_ENERGY",
	"UNIT_RUNIC_POWER"
}

local function hasValue(value)
	for _, power in pairs(powerRegistered) do
		if (value == power) then
			return true;
		end
	end
	
	return false
end

local function createUnitDisplay()
	ZxMasterFrame.MainFrame.texture1 = ZxMasterFrame.MainFrame:CreateTexture(nil, "BACKGROUND")
	drawTexture()
	
	ZxMasterFrame.MainFrame.UnitPowerDisplay = ZxMasterFrame.MainFrame:CreateFontString(nil, "OVERLAY");
	ZxMasterFrame.MainFrame.UnitPowerDisplay:SetFont("Interface\\AddOns\\ActionBarFont\\ptsans-bold.ttf", 16, "OUTLINE");
	ZxMasterFrame.MainFrame.UnitPowerDisplay:SetAllPoints();
	ZxMasterFrame.MainFrame.UnitPowerDisplay:SetText(shortenNumber(UnitPower("Player")));

	for _, power in pairs(powerRegistered) do 
		registerForEvents(power)
	end

	registerForEvents("UPDATE_SHAPESHIFT_FORM");
	
	ZxMasterFrame.MainFrame:SetScript("OnEvent", function(self, event, unit)
		if (hasValue(event)) then
			ZxMasterFrame.MainFrame.UnitPowerDisplay:SetText(shortenNumber(UnitPower("Player")));
		else
			drawTexture()
		end
	end)
end


local function init()
	ZxMasterFrame = CreateFrame("Frame", "ZxMasterFrame", UIParent);
	
	ZxMasterFrame.MainFrame = CreateFrame("Frame", "MainFrame", ZxMasterFrame)
	ZxMasterFrame.MainFrame:SetSize(70,25)
	ZxMasterFrame.MainFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", -20, -15)
	ZxMasterFrame.MainFrame:SetMovable(true)
	ZxMasterFrame.MainFrame:EnableMouse(true)
	ZxMasterFrame.MainFrame:RegisterForDrag("LeftButton")
	ZxMasterFrame.MainFrame:SetScript("OnDragStart", ZxMasterFrame.MainFrame.StartMoving)
	ZxMasterFrame.MainFrame:SetScript("OnDragStop", ZxMasterFrame.MainFrame.StopMovingOrSizing)

	createUnitDisplay()
end


local events = CreateFrame("Frame");
events:RegisterEvent("PLAYER_LOGIN");
events:SetScript("OnEvent", function(self, event, addonName)
	if (event == "PLAYER_LOGIN") then
		init();
		self:UnregisterEvent("PLAYER_LOGIN");
	end
end)