-- This file is loaded from "ActionBarFont.toc"

-- This is a comment, you can replace it with the LUA code that you wish to make into an Addon!

local fontPath = "Interface\\AddOns\\ActionBarFont\\fonts\\"

local defaultStubs = {
	ActionButton=12, MultiBarRightButton=12,
	MultiBarLeftButton=12, MultiBarBottomRightButton=12,
	MultiBarBottomLeftButton=12, BonusActionButton=12, PetActionButton=10,
}
for stub,numButtons in pairs(defaultStubs) do
	for i=1,numButtons do
		_G[stub..i.."HotKey"]:SetFont(fontPath.."ROBOTOBOLD.ttf", 15, "OUTLINE")
		_G[stub..i.."HotKey"]:SetTextColor(1.0, 1.0, 1.0, 1.0)
	end
end

--GameTooltipTextLeft1:SetFont(fontPath.."OpenSansRegular.ttf", 15)
--GameTooltipTextRight1:SetFont(fontPath.."Roboto-Regular.ttf", 16)

GameTooltipTextLeft1:SetFont("Fonts\\FRIZQT__.ttf", 15)

for _, font in pairs({
	GameTooltipText
}) do
	--font:SetFont(fontPath.."OpenSansRegular.ttf", 13)
	font:SetFont("Fonts\\FRIZQT__.ttf", 13)
end

-- Target Frame
TargetFrameTextureFrameName:SetFont("Fonts\\FRIZQT__.ttf", 10, "OUTLINE")