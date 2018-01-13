local powerRegistered = {
	"UNIT_MANA",
	"UNIT_RAGE",
	"UNIT_ENERGY",
	"UNIT_RUNIC_POWER"
}

----------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------

local function enableFrameMovement(frameInput)
	frameInput:SetMovable(true);
	frameInput:EnableMouse(true);
	frameInput:RegisterForDrag("LeftButton");
	frameInput:SetScript("OnDragStart", frameInput.StartMoving);
	frameInput:SetScript("OnDragStop", frameInput.StopMovingOrSizing);
end


local function createBlackBgFrame(frameName, width, height, alphaLevel)
	local bgFrame = CreateFrame("Frame", frameName, ZxMasterFrame)
	bgFrame.texture1 = bgFrame:CreateTexture(nil, "BACKGROUND")
	bgFrame.texture1:SetTexture(0, 0, 0, alphaLevel)
	bgFrame.texture1:SetAllPoints()
	enableFrameMovement(bgFrame)
	bgFrame:SetSize(width, height)
	
	return bgFrame
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


local function getRgb(unitToDisplay)
	-- Get color
	local powerType, powerToken, altR, altG, altB = UnitPowerType(unitToDisplay)
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


-- Wrapper function to color texture
local function drawBarTexture(frameInput, unitToDisplay)
	local r, g, b, powerToken = getRgb(unitToDisplay);
	if (powerToken == "MANA") then
		frameInput:SetStatusBarColor(r, g, b, 0.5);
	else
		frameInput:SetStatusBarColor(r, g, b, 0.7);
	end 
end


local function writePowerValue(frameInput, unitToDisplay)
	local _, value = UnitPowerType(unitToDisplay);
	if (value == "UNIT_MANA" or value == "MANA") then
		local curPower = UnitPower(unitToDisplay);
		local maxPower = UnitPowerMax(unitToDisplay);
		local perPower = (curPower / maxPower) * 100;
		percentage = string.format("%.1f %%", perPower);
		frameInput:SetText(percentage);
	else
		frameInput:SetText(UnitPower(unitToDisplay));
	end
end


local function setMinMaxStatusBar(frameInput, unitToDisplay)
	frameInput:SetMinMaxValues(0, UnitPowerMax(unitToDisplay))
	frameInput:SetValue(UnitPower(unitToDisplay))
end


local function hasValue(value)
	for _, power in pairs(powerRegistered) do
		if (value == power) then
			return true;
		end
	end
	
	return false
end


local function reverseBar(healthBar, currentHp)
	backgroundFrame = healthBar:GetParent();
	healthBar:SetMinMaxValues(0, currentHp);
	healthBar:ClearAllPoints();
	healthBar:SetPoint("BOTTOMRIGHT");		
	local tempWidth = backgroundFrame:GetWidth();
	local tempLocation = tempWidth - (tempWidth * currentHp / 100.0)
	healthBar:SetPoint("TOPLEFT", backgroundFrame, "TOPLEFT", tempLocation, 0);
end


local function createComboPointDisplay(frameInput)
	-- Create combo point display
	frameInput.comboPointBg = CreateFrame("Frame", nil, ZxCreateTargetHpFrame);
	frameInput.comboPointBg.texture1 = createBlackBgFrame(frameInput.comboPointBg, math.floor(frameInput:GetWidth() / 2),
		frameInput:GetHeight(), 0.5);
	frameInput.comboPointBg:SetPoint("BOTTOM", ZxCreateTargetHpFrame, "TOP", 0, 0);
	
	frameInput.comboPointBg.comboText = frameInput.comboPointBg:CreateFontString(nil, "OVERLAY");
	frameInput.comboPointBg.comboText:SetFont("Interface\\AddOns\\ZxTextUnitPower\\PTSansBold.ttf", 16, "OUTLINE");
	frameInput.comboPointBg.comboText:SetTextColor(1.0, 1.0, 0.0, 1.0);
	frameInput.comboPointBg.comboText:SetAllPoints();
	frameInput.comboPointBg:Hide() -- hide the combo display initially

	return frameInput.comboPointBg
end

-- Show current combo points on Target
local function showComboText(comboTextDisplay)
	local parent = comboTextDisplay:GetParent();
	local comboPointsDisplay = 	{
			"1",
			"2",
			"3",
			"4",
			"5 !!"
	}
	
	local comboPoints = GetComboPoints("Player", "Target");
			
	-- Only display if there IS a combo point
	if (comboPoints == 0) then
		parent:Hide();
	else
		comboTextDisplay:SetText(comboPointsDisplay[comboPoints]);
		parent:Show();
	end
end

-- Get PercentHP of target
local function getPercentHp()
	local roundTo = 10.0 * 100.0;
	local curHp = UnitHealth("Target");
	local maxHp = UnitHealthMax("Target");
	local percentHp = nil;
	-- Save some calculation cycles
	if (maxHp == 0) then
		return maxHp;
	else
		percentHp = curHp / maxHp; -- for more accurate comparisons
		if (cur ~= 1.0) then
			percentHp = math.floor(percentHp * roundTo + 0.5) / roundTo;
		end
	end

	percentHp = percentHp * 100.0;
	return percentHp;
end


local function threatCheck()
	local _, _, scaledPercent =  UnitDetailedThreatSituation("Player", "Target");
	if scaledPercent == nil then
		scaledPercent = 0
	end
	
	return scaledPercent
end

----------------------------------------------------------------
-- MAIN FUNCTIONS
----------------------------------------------------------------

local function createPlayerPowerDisplay()
	local bgFrame = createBlackBgFrame("ZxPlayerPowerFrame", 75, 20, 0.8)
	bgFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", -20, -15)

	bgFrame.CurHealthBar = CreateFrame("StatusBar", nil, ZxPlayerPowerFrame)
	bgFrame.CurHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	bgFrame.CurHealthBar:GetStatusBarTexture():SetHorizTile(false)
	bgFrame.CurHealthBar:SetAllPoints()
	setMinMaxStatusBar(bgFrame.CurHealthBar, "Player")
	drawBarTexture(bgFrame.CurHealthBar, "Player")

	bgFrame.PowerText = bgFrame:CreateFontString(nil, "OVERLAY")
	bgFrame.PowerText:SetFont("Interface\\AddOns\\ZxTextUnitPower\\PTSansBold.ttf", 16, "OUTLINE")
	bgFrame.PowerText:SetAllPoints()
	writePowerValue(bgFrame.PowerText, "Player")

	for _, power in pairs(powerRegistered) do
		bgFrame:RegisterEvent(power)
	end
	bgFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

	bgFrame:SetScript("OnEvent", function(self, event, unit)
		setMinMaxStatusBar(bgFrame.CurHealthBar, "Player")
		writePowerValue(bgFrame.PowerText, "Player")
		drawBarTexture(bgFrame.CurHealthBar, "Player")
	end)
end


local function createTargetHp()
	local bgFrame = createBlackBgFrame("ZxTargetHpFrame", 125, 20, 0.8)
	bgFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 100, 10);
	bgFrame:Hide() -- Hide TargetHP initially

	-- Create green texture for health bars
	bgFrame.curHealthBar = CreateFrame("StatusBar", nil, ZxTargetHpFrame);
	--bgFrame.curHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	bgFrame.curHealthBar:SetStatusBarTexture("Interface\\AddOns\\ZxTextUnitPower\\textures\\ZxBantoBar.tga")
	bgFrame.curHealthBar:GetStatusBarTexture():SetHorizTile(false);
	bgFrame.curHealthBar:SetStatusBarColor(0, 1, 0, 0.5);

	-- Create health bar text
	bgFrame.textHealth = bgFrame:CreateFontString(nil, "OVERLAY");
	bgFrame.textHealth:SetFont("Interface\\AddOns\\ZxTextUnitPower\\PTSansBold.ttf", 16, "OUTLINE");
	bgFrame.textHealth:SetTextColor(1.0, 1.0, 1.0, 1.0);
	bgFrame.textHealth:SetAllPoints();

	-- Create combo point display
	bgFrame.comboPointBg = createComboPointDisplay(bgFrame)
	
	bgFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	bgFrame:RegisterEvent("UNIT_HEALTH");
	bgFrame:RegisterEvent("UNIT_COMBO_POINTS");

	bgFrame:SetScript("OnEvent", function(self, event, unit)
		tempHp = getPercentHp()
		if (event == "PLAYER_TARGET_CHANGED") then
			-- If no target selected, then hide the frames
			if (tempHp == 0) then
				bgFrame:Hide()
				return
			else
				showComboText(bgFrame.comboPointBg.comboText)
				bgFrame:Show()
			end
		end

		if (event == "UNIT_COMBO_POINTS") then
			showComboText(bgFrame.comboPointBg.comboText)
		end

		if (bgFrame:IsVisible()) then
			bgFrame.curHealthBar:SetMinMaxValues(0, UnitHealthMax("Target"))
			bgFrame.curHealthBar:SetAllPoints()
			bgFrame.curHealthBar:SetValue(UnitHealth("Target"))
			bgFrame.textHealth:SetText(string.format("%0.1f%%", tempHp))
		end
	end)
end


local function createTargetPower()
	local bgFrame = createBlackBgFrame("ZxTargetPowerFrame", 125, 20, 0.8)
	bgFrame:SetPoint("TOP", ZxTargetHpFrame, "BOTTOM", 0, -2);
	bgFrame:Hide()

	-- Create colored texture for power bars
	bgFrame.curPowerBar = CreateFrame("StatusBar", nil, ZxTargetPowerFrame);
	bgFrame.curPowerBar:SetStatusBarTexture("Interface\\AddOns\\ZxTextUnitPower\\textures\\ZxBantoBar.tga");
	bgFrame.curPowerBar:GetStatusBarTexture():SetHorizTile(false);

	-- Create power bar text
	bgFrame.textPower = bgFrame:CreateFontString(nil, "OVERLAY");
	bgFrame.textPower:SetFont("Interface\\AddOns\\ZxTextUnitPower\\PTSansBold.ttf", 16, "OUTLINE");
	bgFrame.textPower:SetTextColor(1.0, 1.0, 1.0, 1.0);
	bgFrame.textPower:SetAllPoints();

	for _, power in pairs(powerRegistered) do 
		bgFrame:RegisterEvent(power)
	end
	bgFrame:RegisterEvent("PLAYER_TARGET_CHANGED");

	bgFrame:SetScript("OnEvent", function(self, event, unit)
		r, g, b, powerToken = getRgb("Target");

		if (event == "PLAYER_TARGET_CHANGED") then						
			-- If no target selected, then hide the frames
			if (UnitHealthMax("Target") == 0 or UnitHealth("Target") == 0) then
				bgFrame:Hide()
				return
			else
				bgFrame:Show();
			end
		end
		
		if (bgFrame:IsVisible()) then
			bgFrame.curPowerBar:SetMinMaxValues(0, UnitPowerMax("Target"));
			bgFrame.curPowerBar:SetAllPoints();
			bgFrame.curPowerBar:SetValue(UnitPower("Target"));
				
			if (UnitPowerMax("Target") ~= 0) then
				tempPower = UnitPower("Target") / UnitPowerMax("Target") * 100;
				bgFrame.textPower:SetText(string.format("%0.1f%%", tempPower))
				if (powerToken == "MANA") then
					bgFrame.curPowerBar:SetStatusBarColor(r, g, b, 0.5);
				else
					bgFrame.curPowerBar:SetStatusBarColor(r, g, b, 0.7);
				end
			else
				bgFrame.textPower:SetText("N/A");
				bgFrame.curPowerBar:SetStatusBarColor(0, 1, 0, 0.2);
			end
		end
	end)
end


local function createThreatDisplay()
	local bgFrame = createBlackBgFrame("ZxThreatFrame", 75, 20, 0.8)
	bgFrame:SetPoint("BOTTOM", ZxTargetHpFrame, "TOP", 0, 5)
	bgFrame:Hide()

	-- Create actual texture of threat
	bgFrame.StatusBarThreat = CreateFrame("StatusBar", nil, ZxThreatFrame)
	bgFrame.StatusBarThreat:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	bgFrame.StatusBarThreat:GetStatusBarTexture():SetHorizTile(false);
	bgFrame.StatusBarThreat:SetMinMaxValues(0, 100);
	bgFrame.StatusBarThreat:SetAllPoints();

	-- Create text
	bgFrame.ThreatText = bgFrame:CreateFontString(nil, "OVERLAY")
	bgFrame.ThreatText:SetFont("Interface\\AddOns\\ZxTextUnitPower\\PTSansBold.ttf", 16, "OUTLINE");
	bgFrame.ThreatText:SetTextColor(1.0, 1.0, 1.0, 1.0);
	bgFrame.ThreatText:SetAllPoints();

	-- Initially hide
	bgFrame:Hide();
	bgFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	bgFrame:RegisterEvent("UNIT_HEALTH");

	bgFrame:SetScript("OnEvent", function(self, event, unit)
		if (event == "PLAYER_TARGET_CHANGED") then
			if (UnitHealthMax("Target") == 0 or UnitHealth("Target") == 0) then
				bgFrame:Hide()
			else
				bgFrame:Show();
			end
		end

		if (bgFrame:IsVisible()) then
			local threatAmt = threatCheck()
			if threatAmt < 100 then
				bgFrame.StatusBarThreat:SetStatusBarColor(0.9, 0.8, 0.7, 0.8)
			else
				bgFrame.StatusBarThreat:SetStatusBarColor(1.0, 0.0, 0.0, 0.6)
			end
			
			bgFrame.StatusBarThreat:SetValue(threatAmt)
			bgFrame.ThreatText:SetText(string.format("%0.1f%%", threatAmt))
		end
	end)
end


local function init()
	ZxMasterFrame = CreateFrame("Frame", "ZxMasterFrame", UIParent)
	ZxMasterFrame:SetPoint("CENTER", 0, 0)
	
	createPlayerPowerDisplay()
	createTargetHp()
	createTargetPower()
	createThreatDisplay()
end

local events = CreateFrame("Frame");
events:RegisterEvent("PLAYER_LOGIN");
events:SetScript("OnEvent", function(self, event, addonName)
	if (event == "PLAYER_LOGIN") then
		init();
		self:UnregisterEvent("PLAYER_LOGIN");
	end
end)