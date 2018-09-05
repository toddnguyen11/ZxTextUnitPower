local powerRegistered = {
	"UNIT_MANA",
	"UNIT_RAGE",
	"UNIT_ENERGY",
	"UNIT_RUNIC_POWER"
}

local threshold = 35.0


local function createPlayerHealthWarning()
    local bgFrame = CreateFrame("Button", "ZxPlayerHealthFrame", ZxMasterFrame, "SecureActionButtonTemplate")
    local alreadyWarned = false

    -- don't really know why but we need to setattributes
    bgFrame:SetAttribute("unit", "player")
	bgFrame:SetAttribute("type1", "target")
    bgFrame:SetAttribute("*type1", "target")
    
    -- Register to watch for unit health
    bgFrame:RegisterEvent("UNIT_HEALTH")

    -- When health changes
    bgFrame:SetScript("OnEvent", function(self, event, unit)
        if (unit == "player") then
            local curHealth = UnitHealth("Player")
            local maxHealth = UnitHealthMax("Player")
            local percentHealth = curHealth / maxHealth * 100.0
            -- Round to 2 digits
            percentHealth = math.floor(percentHealth * 100.0 + 0.5)
            percentHealth = percentHealth / 100.0 

            if (percentHealth < threshold) then
                if (alreadyWarned == false) then
                    -- Print text in green
                    print("|cff008000  HP: " .. percentHealth .. "%" .. "|r")
                    alreadyWarned = true
                end
            else
                alreadyWarned = false
            end
        end
    end)
end


local function createPlayerPowerWarning()
    local bgFrame = CreateFrame("Button", "ZxPlayerHealthFrame", ZxMasterFrame, "SecureActionButtonTemplate")
    -- Only warn once
    local alreadyWarned = false

    -- don't really know why but we need to setattributes
    bgFrame:SetAttribute("unit", "player")
	bgFrame:SetAttribute("type1", "target")
    bgFrame:SetAttribute("*type1", "target")
    
    -- Register to watch for unit power
    for _, power in pairs(powerRegistered) do
        bgFrame:RegisterEvent(power)
    end
    -- For Druids
    bgFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

    bgFrame:SetScript("OnEvent", function(self, event, unit)
        curPlayerPower = UnitPower("Player")
        maxPlayerPower = UnitPowerMax("Player")
        percentPower = curPlayerPower / maxPlayerPower * 100.0
        -- Round to 2 decimal digits
        percentPower = math.floor(percentPower * 100.0 + 0.5)
        percentPower = percentPower / 100.0
        
        -- Mana Warning
        if (event == "UNIT_MANA") then
            if (percentPower < threshold) then
                if (alreadyWarned == false) then
                    print("|cff4747ff    Mana: " .. percentPower .. "%" .. "|r")
                    alreadyWarned = true  -- only warn once
                end
            else
                alreadyWarned = false
            end
        
        -- Rage Warning
        elseif (event == "UNIT_RAGE") then
            if (curPlayerPower >= 20) then
                if (alreadyWarned == false) then
                    print("|cffFF0000    Rage: " .. curPlayerPower .. "|r")
                    alreadyWarned = true
                end
            else
                alreadyWarned = false
            end
        
        -- Energy Warning
        elseif (event == "UNIT_ENERGY") then
            if (curPlayerPower < 40) then
                if (alreadyWarned == false) then
                    print("|cfFFFF00    Energy: " .. curPlayerPower .. "|r")
                    alreadyWarned = true
                end
            else
                alreadyWarned = false
            end
        
        -- Runic Warning
        elseif (event == "UNIT_RUNIC_POWER") then
            if (curPlayerPower >= 20) then
                if (alreadyWarned == false) then
                    print("|cff00D1FF    Runic: " .. curPlayerPower .. "|r")
                    alreadyWarned = true
                end
            else
                alreadyWarned = false
            end
        end
    end)
end

---------------------------------------------------------------
-- MAIN FUNCTIONS
---------------------------------------------------------------

local function init()
    ZxMasterFrame = CreateFrame("Frame", "ZxMasterFrame", UIParent)
    ZxMasterFrame:SetPoint("CENTER", 0, 0)

    createPlayerHealthWarning()
    createPlayerPowerWarning()
end

local events = CreateFrame("Frame");
events:RegisterEvent("PLAYER_LOGIN");
events:SetScript("OnEvent", function(self, event, addonName)
    if (event == "PLAYER_LOGIN") then
        init();
        self:UnregisterEvent("PLAYER_LOGIN");
    end
end)
