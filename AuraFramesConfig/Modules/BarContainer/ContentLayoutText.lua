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
  
  local OptionGroup = AceGUI:Create("SimpleGroup");
  OptionGroup:SetLayout("Flow");
  OptionGroup:SetRelativeWidth(1);
  Content:AddChild(OptionGroup);
  
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
  OptionGroup:AddChild(ShowDuration);
  
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
  OptionGroup:AddChild(DurationLayout);
  
  local ShowAuraName = AceGUI:Create("CheckBox");
  ShowAuraName:SetWidth(250);
  ShowAuraName:SetLabel("Show aura name");
  ShowAuraName:SetDescription("Show the spell or item name.");
  ShowAuraName:SetValue(LayoutConfig.ShowAuraName);
  ShowAuraName:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowAuraName = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  OptionGroup:AddChild(ShowAuraName);
  
  local ShowCount = AceGUI:Create("CheckBox");
  ShowCount:SetWidth(250);
  ShowCount:SetDisabled(not LayoutConfig.ShowAuraName);
  ShowCount:SetLabel("Show count");
  ShowCount:SetDescription("Show the number of stacks of an aura.");
  ShowCount:SetValue(LayoutConfig.ShowCount);
  ShowCount:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowCount = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  OptionGroup:AddChild(ShowCount);
  
  Content:AddSpace();
  
  Content:AddHeader("Font");
  
  Content:AddText("Change the font and size settings that are used for the aura name, stacks and duration.\n");
  
  local TextGroup = AceGUI:Create("SimpleGroup");
  TextGroup:SetLayout("Flow");
  TextGroup:SetRelativeWidth(1);
  Content:AddChild(TextGroup);
  
  local TextFont = AceGUI:Create("LSM30_Font");
  TextFont:SetWidth(200);
  TextFont:SetList(LSM:HashTable("font"));
  TextFont:SetLabel("Font");
  TextFont:SetValue(LayoutConfig.TextFont);
  TextFont:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextFont = Value;
    ContainerInstance:Update("LAYOUT");
    TextFont:SetValue(Value);
  end);
  TextGroup:AddChild(TextFont);
  
  local Space1 = AceGUI:Create("Label");
  Space1:SetWidth(50);
  Space1:SetText(" ");
  TextGroup:AddChild(Space1);
  
  local TextSize = AceGUI:Create("Slider");
  TextSize:SetWidth(200);
  TextSize:SetValue(LayoutConfig.TextSize);
  TextSize:SetLabel("Font Size");
  TextSize:SetSliderValues(6, 30, 0.1);
  TextSize:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextSize = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  TextGroup:AddChild(TextSize);
  
  local TextOutline = AceGUI:Create("Dropdown");
  TextOutline:SetWidth(200);
  TextOutline:SetLabel("Outline");
  TextOutline:SetList({
    NONE = "None",
    OUTLINE = "Outline",
    THICKOUTLINE = "Thick Outline",
  });
  TextOutline:SetValue(LayoutConfig.TextOutline);
  TextOutline:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextOutline = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  TextGroup:AddChild(TextOutline);
  
  local Space1 = AceGUI:Create("Label");
  Space1:SetWidth(50);
  Space1:SetText(" ");
  TextGroup:AddChild(Space1);
  
  local TextMonochrome = AceGUI:Create("CheckBox");
  TextMonochrome:SetWidth(150);
  TextMonochrome:SetLabel("Monochrome");
  TextMonochrome:SetValue(LayoutConfig.TextMonochrome);
  TextMonochrome:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextMonochrome = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  TextGroup:AddChild(TextMonochrome);
  
  local TextColor = AceGUI:Create("ColorPicker");
  TextColor:SetWidth(150);
  TextColor:SetLabel("Color");
  TextColor:SetHasAlpha(true);
  TextColor:SetColor(unpack(LayoutConfig.TextColor));
  TextColor:SetCallback("OnValueChanged", function(_, _, ...)
    LayoutConfig.TextColor = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  TextGroup:AddChild(TextColor);
  
  Content:AddSpace(2);
  
end
