--------------------------------------------
-- MAIN FUNCTIONS
--------------------------------------------

local function enableFrameMovements(frameName)
	frameName:RegisterForDrag("LeftButton");
	frameName:SetScript("OnDragStart", frameName.StartMoving);
	frameName:SetScript("OnDragStop", frameName.StopMovingOrSizing);
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0);
	return (math.floor(num * mult + 0.5) / mult)
end

local function shortenNumber(number)
	local strNumber = nil

	if number < 1000 then
		strNumber = string.format("%d", number);
	elseif number < 1000000 then
		strNumber = string.format("%0.2fk", round(number/1000, 2))
	else
		strNumber = string.format("%0.2fm", round(number/1000000, 2))
	end

	return strNumber
end

local function divideMoney(moneyAmount)
	local gold, silver, copper = nil;
	if (moneyAmount > 0) then
		gold = floor(moneyAmount / 10000);
		silver = floor(mod(moneyAmount / 100, 100));
		copper = floor(mod(moneyAmount, 100));
	else
		gold = ceil(moneyAmount / 10000);
		silver = ceil(mod(moneyAmount / 100, 100));
		copper = ceil(mod(moneyAmount, 100));
	end

	return gold, silver, copper
end

local function GetCurrentMoney()
	currentMoney = GetMoney();
	diffMoney = currentMoney - startingMoney;
	g2, s2, c2 = divideMoney(currentMoney);
	g3, s3, c3 = divideMoney(currentMoney - startingMoney);

	temp =  string.format("NOW  : |cffFFD700%s G, |cffC0C0C0%02dS, |cffb87333%02dC|r",
	shortenNumber(g2), s2, c2);
	temp2 = string.format("DIFF: %s G, %dS, %dC", shortenNumber(g3), s3, c3);
	return temp, temp2
end

local function init_Backup()
	local frame = CreateFrame("Frame", UIParent);
	frame:SetSize(200, 50);
	frame:SetPoint("TOPLEFT", 0, -15);
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:RegisterForDrag("LeftButton")
	enableFrameMovements(frame)

	frame.bgTexture = frame:CreateTexture(nil, "BACKGROUND");
	frame.bgTexture:SetTexture(0, 0, 0, 0.5);
	frame.bgTexture:SetAllPoints();

	frame.text = frame:CreateFontString(nil, "OVERLAY");
	frame.text:SetFont("Interface\\AddOns\\ZxStartingGold\\consola.ttf", 14);
	frame.text:SetPoint("TOP", frame, "TOP")

	startingMoney = GetMoney();
	g, s, c = divideMoney(startingMoney);
	temp = string.format("START: |cffFFD700%s G, |cffC0C0C0%02dS, |cffb87333%02dC|r", shortenNumber(g), s, c);
	frame.text:SetText(temp)

	frame.text2 = frame:CreateFontString(nil, "OVERLAY");
	frame.text2:SetFont("Interface\\AddOns\\ZxStartingGold\\consola.ttf", 14);
	frame.text2:SetPoint("TOP", frame.text, "BOTTOM");

	frame.text3 = frame:CreateFontString(nil, "OVERLAY");
	frame.text3:SetFont("Interface\\AddOns\\ZxStartingGold\\consola.ttf", 14);
	frame.text3:SetPoint("TOP", frame.text2, "BOTTOM");
	frame.text3:SetTextColor(255, 215, 0, 1.0)

	temp, temp2 = GetCurrentMoney()
	frame.text2:SetText(temp);
	frame.text3:SetText(temp2);

	frame:RegisterEvent("PLAYER_MONEY");
	frame:SetScript("OnEvent", GetCurrentMoney);

	--g2, s2, c2 = divideMoney(GetMoney());
	--frame.text2:SetText("Testing");
end

local function init()
	startingMoney = GetMoney();
end

local events = CreateFrame("Frame");
events:RegisterEvent("PLAYER_LOGIN");
events:SetScript("OnEvent", function(self, event, addonName)
	if (event == "PLAYER_LOGIN") then
		init();
		self:UnregisterEvent("PLAYER_LOGIN");
	end
end)

---------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------
local function StartingMoneyStr()
	g, s, c = divideMoney(startingMoney);
	temp = string.format("START: |cffFFD700%s G, |cffC0C0C0%02dS, |cffb87333%02dC|r", shortenNumber(g), s, c);
	return temp
end

local function GetCurrentMoney2()
	currentMoney = GetMoney();
	diffMoney = currentMoney - startingMoney;
	g2, s2, c2 = divideMoney(currentMoney);
	g3, s3, c3 = divideMoney(currentMoney - startingMoney);

	temp =  string.format("NOW  : |cffFFD700%s G, |cffC0C0C0%02dS, |cffb87333%02dC|r",
	shortenNumber(g2), s2, c2);
	temp2 = string.format("DIFF: %s G, %dS, %dC", shortenNumber(g3), s3, c3);
	return temp, temp2
end

function ZxGoldCommands(command)
	if (command == "test") then
		print("Hello world!"..command)
		return
	end

	local startingMoney = GetMoney()
	temp, temp2 = GetCurrentMoney2()
	print(StartingMoneyStr())
	print(temp)
	print(temp2)
end

SLASH_ZXGOLD1 = "/zxgold"
SlashCmdList["ZXGOLD"] = ZxGoldCommands

SLASH_RELOADUI1 = "/rl"
SlashCmdList["RELOADUI"] = function(command)
	ReloadUI()
end
