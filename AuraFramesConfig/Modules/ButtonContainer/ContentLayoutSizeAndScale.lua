local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentLayoutSizeAndScale
-----------------------------------------------------------------
function Module:ContentLayoutSizeAndScale(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:SetLayout("List");

  Content:AddText("Size and Scale\n", GameFontNormalLarge);
  
  Content:AddHeader("Size");
  Content:AddText("The scale will effect the whole container, including aura's, duration and count.");
  Content:AddSpace();
 
  local Scale = AceGUI:Create("Slider");
  Scale:SetWidth(500);
  Scale:SetValue(LayoutConfig.Scale);
  Scale:SetLabel("The scale of the container");
  Scale:SetSliderValues(0.5, 3, 0.01);
  Scale:SetIsPercent(true);
  Scale:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Scale = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(Scale);
  
  Content:AddSpace(2);
  Content:AddText("The number of aura columns and rows the container will display.");
  
  local SizeGroup = AceGUI:Create("SimpleGroup");
  SizeGroup:SetLayout("Flow");
  SizeGroup:SetRelativeWidth(1);
  Content:AddChild(SizeGroup);
  
  local HorizontalSize = AceGUI:Create("Slider");
  HorizontalSize:SetWidth(250);
  HorizontalSize:SetValue(LayoutConfig.HorizontalSize);
  HorizontalSize:SetLabel("Horizontal Size");
  HorizontalSize:SetSliderValues(1, 20, 1);
  HorizontalSize:SetIsPercent(false);
  HorizontalSize:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.HorizontalSize = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SizeGroup:AddChild(HorizontalSize);
  
  local VerticalSize = AceGUI:Create("Slider");
  VerticalSize:SetWidth(250);
  VerticalSize:SetValue(LayoutConfig.VerticalSize);
  VerticalSize:SetLabel("Vertical Size");
  VerticalSize:SetSliderValues(1, 20, 1);
  VerticalSize:SetIsPercent(false);
  VerticalSize:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.VerticalSize = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SizeGroup:AddChild(VerticalSize);
  
  Content:AddSpace(2);
  
  local DropdownDirection = AceGUI:Create("Dropdown");
  DropdownDirection:SetList({
    LEFTDOWN = "First left, then down",
    LEFTUP = "First left, then then up",
    RIGHTDOWN = "First right, then then down",
    RIGHTUP = "First right, then then up",
    DOWNLEFT = "First down, then then left",
    DOWNRIGHT = "First down, then then right",
    UPLEFT = "First up, then then left",
    UPRIGHT = "First up, then then right",
  });
  DropdownDirection:SetLabel("Grow direction of aura's");
  DropdownDirection:SetValue(LayoutConfig.Direction);
  DropdownDirection:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Direction = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(DropdownDirection);

  Content:AddSpace();
  Content:AddHeader("Spacing");
  
  Content:AddText("The space between the aura's horizontal and vertical.");
  
  Content:AddSpace();
  
  local SpacingGroup = AceGUI:Create("SimpleGroup");
  SpacingGroup:SetLayout("Flow");
  SpacingGroup:SetRelativeWidth(1);
  Content:AddChild(SpacingGroup);
  
  local HorizontalSpace = AceGUI:Create("Slider");
  HorizontalSpace:SetWidth(250);
  HorizontalSpace:SetValue(LayoutConfig.SpaceX);
  HorizontalSpace:SetLabel("Horizontal Space");
  HorizontalSpace:SetSliderValues(0, 50, 0.1);
  HorizontalSpace:SetIsPercent(false);
  HorizontalSpace:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.SpaceX = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SpacingGroup:AddChild(HorizontalSpace);
  
  local VerticalSpace = AceGUI:Create("Slider");
  VerticalSpace:SetWidth(250);
  VerticalSpace:SetValue(LayoutConfig.SpaceY);
  VerticalSpace:SetLabel("Vertical Space");
  VerticalSpace:SetSliderValues(0, 50, 0.1);
  VerticalSpace:SetIsPercent(false);
  VerticalSpace:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.SpaceY = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SpacingGroup:AddChild(VerticalSpace);


end
