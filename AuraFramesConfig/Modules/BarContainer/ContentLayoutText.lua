local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("BarContainer");
local AceGUI = LibStub("AceGUI-3.0");
local LSM = LibStub("LibSharedMedia-3.0");


-----------------------------------------------------------------
-- Function ContentLayoutText
-----------------------------------------------------------------
function Module:ContentLayoutText(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:ReleaseChildren();

  Content:SetLayout("List");

  Content:AddText("Text\n", GameFontNormalLarge);

  Content:AddHeader("Options");
  
  local DurationGroup = AceGUI:Create("SimpleGroup");
  DurationGroup:SetLayout("Flow");
  DurationGroup:SetRelativeWidth(1);
  Content:AddChild(DurationGroup);
  
  local ShowDuration = AceGUI:Create("CheckBox");
  ShowDuration:SetWidth(250);
  ShowDuration:SetLabel("Show duration");
  ShowDuration:SetDescription("Show the time left on an aura.");
  ShowDuration:SetValue(LayoutConfig.ShowDuration);
  ShowDuration:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowDuration = Value;
    ContainerInstance:Update("LAYOUT");
    Module:ContentLayoutText(Content, ContainerId)
  end);
  DurationGroup:AddChild(ShowDuration);
  
  local DurationLayout = AceGUI:Create("Dropdown");
  DurationLayout:SetWidth(150);
  DurationLayout:SetList({
    ABBREVSPACE   = "10 m",
    ABBREV        = "10m",
    SEPCOL        = "10:15",
    SEPDOT        = "10.15",
    NONE          = "615",
  });
  DurationLayout:SetLabel("Time layout");
  DurationLayout:SetDisabled(not LayoutConfig.ShowDuration);
  DurationLayout:SetValue(LayoutConfig.DurationLayout);
  DurationLayout:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.DurationLayout = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  DurationGroup:AddChild(DurationLayout);
  
  local ShowCount = AceGUI:Create("CheckBox");
  ShowCount:SetLabel("Show count");
  ShowCount:SetDescription("Show the number of stacks of an aura.");
  ShowCount:SetRelativeWidth(1);
  ShowCount:SetValue(LayoutConfig.ShowCount);
  ShowCount:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowCount = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(ShowCount);
  
  Content:AddHeader("Font");
  
  local TextGroup = AceGUI:Create("SimpleGroup");
  TextGroup:SetLayout("Flow");
  TextGroup:SetRelativeWidth(1);
  Content:AddChild(TextGroup);
  
  local DurationFont = AceGUI:Create("LSM30_Font");
  DurationFont:SetList(LSM:HashTable("font"));
  DurationFont:SetLabel("Font");
  DurationFont:SetValue(LayoutConfig.TextFont);
  DurationFont:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextFont = Value;
    ContainerInstance:Update("LAYOUT");
    DurationFont:SetValue(Value);
  end);
  TextGroup:AddChild(DurationFont);
  
  local DurationSize = AceGUI:Create("Slider");
  DurationSize:SetValue(LayoutConfig.TextSize);
  DurationSize:SetLabel("Font Size");
  DurationSize:SetSliderValues(6, 30, 0.1);
  DurationSize:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextSize = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  TextGroup:AddChild(DurationSize);
  
  local TextOptionsGroup = AceGUI:Create("SimpleGroup");
  TextOptionsGroup:SetLayout("Flow");
  TextOptionsGroup:SetRelativeWidth(1);
  Content:AddChild(TextOptionsGroup);
  
  local DurationOutline = AceGUI:Create("Dropdown");
  DurationOutline:SetWidth(150);
  DurationOutline:SetLabel("Outline");
  DurationOutline:SetList({
    NONE = "None",
    OUTLINE = "Outline",
    THICKOUTLINE = "Thick Outline",
  });
  DurationOutline:SetValue(LayoutConfig.TextOutline);
  DurationOutline:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextOutline = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  TextOptionsGroup:AddChild(DurationOutline);
  
  local DurationMonochrome = AceGUI:Create("CheckBox");
  DurationMonochrome:SetWidth(150);
  DurationMonochrome:SetLabel("Monochrome");
  DurationMonochrome:SetValue(LayoutConfig.TextMonochrome);
  DurationMonochrome:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextMonochrome = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  TextOptionsGroup:AddChild(DurationMonochrome);
  
  local DurationColor = AceGUI:Create("ColorPicker");
  DurationColor:SetWidth(150);
  DurationColor:SetLabel("Color");
  DurationColor:SetHasAlpha(true);
  DurationColor:SetColor(unpack(LayoutConfig.TextColor));
  DurationColor:SetCallback("OnValueChanged", function(_, _, ...)
    LayoutConfig.TextColor = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  TextOptionsGroup:AddChild(DurationColor);
  
  Content:AddSpace(2);
  
end
