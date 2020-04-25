ZxSimpleUI = LibStub("AceAddon-3.0"):NewAddon("ZxSimpleUI", "AceConsole-3.0", "AceEvent-3.0")
AceConfig = LibStub("AceConfig-3.0")
AceGUI = LibStub("AceGUI-3.0")

--- "Private" functions
local _DrawGroup1, _DrawGroup2, _SelectGroup

-- Process options
local optionsTable = {
  name = "ZxSimpleUI",
  handler = ZxSimpleUI,
  type = 'group',
  args = {
    msg = {
      -- textual input
      type = 'input',
      name = 'My Message',
      desc = 'The message for this addon',
      set = 'SetMyMessage',
      get = 'GetMyMessage'
    },
  },
}

function ZxSimpleUI:OnInitialize()
  ---Must initialize db AFTER SavedVariables is loaded!
  self.db = LibStub("AceDB-3.0"):New("ZxSimpleUI_DB")

  -- Restore saved settings
  self:Print(ChatFrame1, "YO")
  self._myMessageVar = ""

  -- Do NOT change the `options` table!
  -- options.args.profile = LibStub("AceDBOpions-3.0"):GetOptionsTable(self.db)

  self:RegisterChatCommand("zxsimpleui/slash", "ProcessSlashCommands")
  AceConfig:RegisterOptionsTable("ZxSimpleUI", optionsTable, {"myslash", "myslashtwo"})

  self:RegisterEvent("UNIT_HEALTH", "UnitHealthHandler")

  -- self:CreateSimpleFrame()
  self:CreateTabbedFrame()
end

function ZxSimpleUI:ProcessSlashCommands(input)
  self:Print(input)
end

function ZxSimpleUI:GetMyMessage(info)
  return self._myMessageVar
end

function ZxSimpleUI:SetMyMessage(info, input)
  self._myMessageVar = input
end

function ZxSimpleUI:UnitHealthHandler(eventName, unit, ...)
  self:Print(UnitHealth("Player"))
end

function ZxSimpleUI:CreateSimpleFrame()
  local textStore = ""

  local frame = AceGUI:Create("Frame")
  frame:SetTitle("Example Frame")
  frame:SetStatusText("AceGUI-3.0 Example Container Frame")
  frame:SetCallback("OnClose", function(widget)
    -- Always releas your frames once your UI doesn't need them anymore!
    AceGUI:Release(widget)
  end)
  frame:SetLayout("Flow")

  local editbox = AceGUI:Create("EditBox")
  editbox.label:SetFont(editbox.label:GetFont(), 14)
  editbox:SetLabel("Insert text:")
  -- Always set width!
  editbox:SetWidth(200)
  editbox:SetCallback("OnEnterPressed", function(widget, event, text)
    textStore = text
  end)
  frame:AddChild(editbox)

  local button = AceGUI:Create("Button")
  button:SetText("Click Me!")
  -- Always set width!
  button:SetWidth(200)
  button:SetCallback("OnClick", function()
    print(textStore)
  end)
  frame:AddChild(button)
end


function ZxSimpleUI:CreateTabbedFrame()
  local frame = AceGUI:Create("Frame")
  frame:SetTitle("Example Tabbed Frame")
  frame:SetStatusText("AceGUI-3.0 Example Container Frame")
  frame:SetCallback("OnClose", function(widget)
    AceGUI:Release(widget)
  end)
  -- Fill Layout - the TabGroup widget will fill the whole frame
  frame:SetLayout("Fill")

  -- Create Tab group
  local tab = AceGUI:Create("TabGroup")
  tab:SetLayout("Flow")
  tab:SetTabs({
    {text="Tab 1", value="tab1"},
    {text="Tab 2", value="tab2"}
  })
  tab:SetCallback("OnGroupSelected", _SelectGroup)
  -- Set initial tab (this will fire the `OnGroupSelected` callback)
  tab:SelectTab("tab1")

  frame:AddChild(tab)
end

-- #######################
-- |  Private functions  |
-- #######################

---Draw widgets for tab 1
function _DrawGroup1(container)
  local desc = AceGUI:Create("Label")
  desc:SetText("This is Tab 1")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  local button = AceGUI:Create("Button")
  button:SetText("Tab 1 Button")
  button:SetWidth(200)
  container:AddChild(button)
end

---Draw widgets for tab 2
function _DrawGroup2(container)
  local desc = AceGUI:Create("Label")
  desc:SetText("This is Tab 2")
  desc:SetFullWidth(true)
  container:AddChild(desc)

  local button = AceGUI:Create("Button")
  button:SetText("Tab 2 Button")
  button:SetWidth(200)
  container:AddChild(button)
end

---Callback function for `OnGroupSelected`.
function _SelectGroup(container, event, group)
  container:ReleaseChildren()
  if group == "tab1" then
    _DrawGroup1(container)
  elseif group == "tab2" then
    _DrawGroup2(container)
  end
end
