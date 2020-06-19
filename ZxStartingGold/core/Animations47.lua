local ZxStartingGold = LibStub("AceAddon-3.0"):GetAddon("ZxStartingGold")
local Animations47 = {}
Animations47.__index = Animations47
ZxStartingGold.Animations47 = Animations47

---@param animationDurationSeconds number
---@param defaultHeight integer
---@param curFrame table
function Animations47:animateHeight(curFrame, defaultHeight, animationDurationSeconds)
  local maxHeightDelta = defaultHeight * 1.5
  local totalElapsedTime = 0
  curFrame:SetScript("OnUpdate", function(curFrame, elapsedTime)
    totalElapsedTime = totalElapsedTime + elapsedTime
    local difftime = animationDurationSeconds - totalElapsedTime
    if difftime >= 0 then
      local height = defaultHeight + (maxHeightDelta * difftime)
      curFrame:SetHeight(height)
    else
      curFrame:SetScript("OnUpdate", nil)
    end
  end)
end
