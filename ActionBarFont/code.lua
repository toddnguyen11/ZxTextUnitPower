-- This file is loaded from "ActionBarFont.toc"

-- This is a comment, you can replace it with the LUA code that you wish to make into an Addon!
local defaultStubs = {
	ActionButton=12, MultiBarRightButton=12,
	MultiBarLeftButton=12, MultiBarBottomRightButton=12,
	MultiBarBottomLeftButton=12, BonusActionButton=12, PetActionButton=10,
}
for stub,numButtons in pairs(defaultStubs) do
	for i=1,numButtons do
		_G[stub..i.."HotKey"]:SetFont("Interface\\AddOns\\ActionBarFont\\ptsans-bold.ttf", 16, "OUTLINE")
	end
end
