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
		local localKey = stub .. i .. "HotKey"
		local font = CreateFont(localKey)
		
		-- Create a font object
		font:SetFont("Fonts\\ARIALN.ttf", 15, "OUTLINE, THICKOUTLINE")
		-- _G[stub..i.."HotKey"]:SetFont(fontPath.."arialbd.ttf", 14, "THICKOUTLINE")
		_G[localKey]:SetFontObject(font);
	end
end
