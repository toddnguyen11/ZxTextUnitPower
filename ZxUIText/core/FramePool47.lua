-- Upvalues
local LibStub, CreateFrame = LibStub, CreateFrame

local ZxUIText = LibStub("AceAddon-3.0"):GetAddon("ZxUIText")
---@class FramePool47
local FramePool47 = {}
FramePool47.__index = FramePool47
ZxUIText.FramePool47 = FramePool47

---Ref: https://www.wowinterface.com/forums/showthread.php?t=28224
local _framePool = {}
local _count = 0

---@param frame table
function FramePool47:releaseFrame(frame)
  frame:SetParent(nil)
  frame:Hide()
  table.insert(_framePool, frame)
  _count = _count + 1
end

---@return table
function FramePool47:getFrame()
  local frame = table.remove(_framePool)
  if frame == nil then
    frame = CreateFrame("Frame", nil)
    frame:ClearAllPoints()
  else
    _count = _count - 1
  end
  return frame
end

function FramePool47:size() return _count end
