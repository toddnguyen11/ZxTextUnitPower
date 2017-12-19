local function enableFrameMovement(frameInput)
	frameInput:SetMovable(true);
	frameInput:EnableMouse(true);
	frameInput:RegisterForDrag("LeftButton");
	frameInput:SetScript("OnDragStart", frameInput.StartMoving);
	frameInput:SetScript("OnDragStop", frameInput.StopMovingOrSizing);
end

local function createBlackBg(frame, alphaLevel)
	frame.texture1 = frame:CreateTexture(nil, "BACKGROUND");
	frame.texture1:SetTexture(0, 0, 0, alphaLevel);
	frame.texture1:SetAllPoints();
	
	return frame.texture1;
end

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

	return r, g, b, powerToken
end

-- Wrapper function to register for multipke power types
local function registerForEvents(unitInput)
	ZxMasterFrame.MainFrame:RegisterEvent(unitInput)
end

-- Wrapper function to color texture
local function drawTexture()
	r, g, b, powerToken = getRgb();
	if (powerToken == "MANA") then
		ZxMasterFrame.MainFrame.texture1:SetTexture(r, g, b, 0.5);
	else
		ZxMasterFrame.MainFrame.texture1:SetTexture(r, g, b, 0.7);
	end 

	ZxMasterFrame.MainFrame.texture1:SetAllPoints();
end

powerRegistered = {
	"UNIT_MANA",
	"UNIT_RAGE",
	"UNIT_ENERGY",
	"UNIT_RUNIC_POWER"
}

local function writePowerValue(value)
	if (value == "UNIT_MANA" or value == "MANA") then
		percentage = string.format("%.1f %%", UnitPower("Player")/UnitPowerMax("Player") * 100);
		ZxMasterFrame.MainFrame.UnitPowerDisplay:SetText(percentage);
	else
		ZxMasterFrame.MainFrame.UnitPowerDisplay:SetText(shortenNumber(UnitPower("Player")));
	end
end

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
	ZxMasterFrame.MainFrame.UnitPowerDisplay:SetFont("Interface\\AddOns\\ZxTextUnitPower\\PTSansBold.ttf", 16, "OUTLINE");
	ZxMasterFrame.MainFrame.UnitPowerDisplay:SetAllPoints();
	_, unitPType = UnitPowerType("Player")
	writePowerValue(unitPType)

	for _, power in pairs(powerRegistered) do 
		registerForEvents(power)
	end

	registerForEvents("UPDATE_SHAPESHIFT_FORM");
	
	ZxMasterFrame.MainFrame:SetScript("OnEvent", function(self, event, unit)
		if (hasValue(event)) then
			writePowerValue(event);
		else
			drawTexture()
		end
	end)
end

local function createTargetHp()
	local frame1 = CreateFrame("Frame", "ZxTargetHealth", ZxMasterFrame);
	enableFrameMovement(frame1);
	
	frame1.texture1 = createBlackBg(frame1, 0.8);
	frame1:SetWidth(75);
	frame1:SetHeight(20);
	frame1:SetPoint("LEFT", PlayerFrame, "RIGHT", 40, 0);
	
	frame1.targetHp = CreateFrame("StatusBar", nil, ZxTargetHealth);
	frame1.targetHp:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	frame1.targetHp:GetStatusBarTexture():SetHorizTile(false);
	frame1.targetHp:SetAllPoints();
	frame1.targetHp:SetStatusBarColor(0, 1, 0, 0.5);
	
	frame1.hpText = frame1:CreateFontString(nil, "OVERLAY");
	frame1.hpText:SetFont("Interface\\AddOns\\ZxTextUnitPower\\PTSansBold.ttf", 16, "OUTLINE");
	frame1.hpText:SetText(1.0, 1.0, 1.0, 1.0);
	frame1.hpText:SetAllPoints();
	
	frame1:Hide(); -- No target selected initially
	
	frame1.targetHp:RegisterEvent("PLAYER_TARGET_CHANGED");
	frame1.targetHp:RegisterEvent("UNIT_HEALTH");
	frame1.targetHp:SetScript("OnEvent", function(self, event, unit)
		if (event == "PLAYER_TARGET_CHANGED") then
			local curHp = UnitHealth("Target");
			local maxHp = UnitHealthMax("Target");
			local percentHp = curHp / maxHp * 100;
			-- If no target selected, then hide the frames
			if (maxHp == 0) then
				frame1:Hide();
				return;
			-- If target is selected, show frames
			else
				frame1.targetHp:SetMinMaxValues(0, 100);
				frame1.targetHp:SetValue(percentHp);
				frame1.hpText:SetText(string.format("%.1f%%", percentHp));
				frame1:Show();
			end
			
		elseif (event == "UNIT_HEALTH") then
			local curHp = UnitHealth("Target");
			local maxHp = UnitHealthMax("Target");
			local percentHp = curHp / maxHp * 100;
			frame1.targetHp:SetValue(percentHp);
			frame1.hpText:SetText(string.format("%.1f%%", percentHp));
		end
	end)
end

local function init()
	ZxMasterFrame = CreateFrame("Frame", "ZxMasterFrame", UIParent);
	ZxMasterFrame:SetPoint("CENTER", 0, 0);
	
	ZxMasterFrame.MainFrame = CreateFrame("Frame", "MainFrame", ZxMasterFrame)
	ZxMasterFrame.MainFrame:SetSize(75,20)
	ZxMasterFrame.MainFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", -20, -15)
	enableFrameMovement(ZxMasterFrame.MainFrame);
	
	createUnitDisplay()
	
	createTargetHp();
end


local events = CreateFrame("Frame");
events:RegisterEvent("PLAYER_LOGIN");
events:SetScript("OnEvent", function(self, event, addonName)
	if (event == "PLAYER_LOGIN") then
		init();
		self:UnregisterEvent("PLAYER_LOGIN");
	end
end)