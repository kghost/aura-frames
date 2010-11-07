local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentTabDisplay
-----------------------------------------------------------------
function Module:ContentTabDisplay(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:SetLayout("List");

  Content:AddText("Display\n", GameFontNormalLarge);

  Content:AddHeader("Duration");
  
  local ShowDuration = AceGUI:Create("CheckBox");
  ShowDuration:SetLabel("Show duration");
  ShowDuration:SetValue(LayoutConfig.ShowDuration);
  ShowDuration:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowDuration = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(ShowDuration);
  
  local DurationLayout = AceGUI:Create("Dropdown");
  DurationLayout:SetList({
    FORMAT      = "10 m",
    SEPCOLON    = "10:15",
    SEPDOT      = "10.15",
    SECONDS     = "615",
  });
  DurationLayout:SetLabel("Duration layout");
  DurationLayout:SetValue(LayoutConfig.DurationLayout);
  DurationLayout:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.DurationLayout = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(DurationLayout);
  
  Content:AddSpace();
  Content:AddHeader("Count");
  
  local ShowCount = AceGUI:Create("CheckBox");
  ShowCount:SetLabel("Show count");
  ShowCount:SetValue(LayoutConfig.ShowCount);
  ShowCount:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowCount = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(ShowCount);
  
  Content:AddSpace();
  Content:AddHeader("Miscellaneous");
  
  local Clickable = AceGUI:Create("CheckBox");
  Clickable:SetLabel("Buttons are clickable");
  Clickable:SetValue(LayoutConfig.Clickable);
  Clickable:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Clickable = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(Clickable);
  

end
