local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("BarContainer");
local AceGUI = LibStub("AceGUI-3.0");
local LSM = LibStub("LibSharedMedia-3.0");


-----------------------------------------------------------------
-- Function ContentLayoutSizeAndScale
-----------------------------------------------------------------
function Module:ContentLayoutSizeAndScale(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:SetLayout("List");

  Content:AddText("Size and Scale\n", GameFontNormalLarge);
  
  Content:AddHeader("Size");
  Content:AddText("The scale will effect the whole container, including aura's and text.");
  Content:AddSpace();
 
  local Scale = AceGUI:Create("Slider");
  Scale:SetWidth(500);
  Scale:SetValue(LayoutConfig.Scale);
  Scale:SetLabel("The scale of the container");
  Scale:SetSliderValues(0.5, 2, 0.01);
  Scale:SetIsPercent(true);
  Scale:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Scale = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(Scale);
  
  Content:AddSpace(2);
  Content:AddText("The number of bars the container will display.");
  
  local NumberOfBars = AceGUI:Create("Slider");
  NumberOfBars:SetValue(LayoutConfig.NumberOfBars);
  NumberOfBars:SetLabel("Horizontal Size");
  NumberOfBars:SetSliderValues(1, 20, 1);
  NumberOfBars:SetIsPercent(false);
  NumberOfBars:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.NumberOfBars = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(NumberOfBars);
  
  Content:AddSpace(2);
  
  local SizeGroup = AceGUI:Create("SimpleGroup");
  SizeGroup:SetLayout("Flow");
  SizeGroup:SetRelativeWidth(1);
  Content:AddChild(SizeGroup);
  
  local DropdownDirection = AceGUI:Create("Dropdown");
  DropdownDirection:SetList({
    DOWN = "Down",
    UP   = "Up",
  });
  DropdownDirection:SetLabel("Grow direction of aura's");
  DropdownDirection:SetValue(LayoutConfig.Direction);
  DropdownDirection:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Direction = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SizeGroup:AddChild(DropdownDirection);

  local DropdownBarDirection = AceGUI:Create("Dropdown");
  DropdownBarDirection:SetList({
    LEFTGROW = "Left, grow",
    RIGHTGROW = "Right, grow",
    LEFTSHRINK = "Left, shrink",
    RIGHTSHRINK = "Right, shrink",
  });
  DropdownBarDirection:SetLabel("Grow direction of aura's");
  DropdownBarDirection:SetValue(LayoutConfig.BarDirection);
  DropdownBarDirection:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarDirection = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SizeGroup:AddChild(DropdownBarDirection);
  
  local BarWidth = AceGUI:Create("EditBox");
  BarWidth:SetText(tostring(LayoutConfig.BarWidth));
  BarWidth:SetLabel("Width of the bars");
  BarWidth:SetCallback("OnEnterPressed", function(_, _, Value)
    LayoutConfig.BarWidth = tonumber(Value);
    ContainerInstance:Update("LAYOUT");
  end);
  SizeGroup:AddChild(BarWidth);
  
  local BarTexture = AceGUI:Create("LSM30_Font");
  BarTexture:SetList(LSM:HashTable("statusbar"));
  BarTexture:SetLabel("Bar Texture");
  BarTexture:SetValue(LayoutConfig.BarTexture);
  BarTexture:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTexture = Value;
    ContainerInstance:Update("LAYOUT");
    BarTexture:SetValue(Value);
  end);
  SizeGroup:AddChild(BarTexture);

  Content:AddSpace();
  Content:AddHeader("Spacing");
  
  Content:AddText("The space between the bars.");
  
  Content:AddSpace();
  
  local SpacingGroup = AceGUI:Create("SimpleGroup");
  SpacingGroup:SetLayout("Flow");
  SpacingGroup:SetRelativeWidth(1);
  Content:AddChild(SpacingGroup);
  
  local Space = AceGUI:Create("Slider");
  Space:SetValue(LayoutConfig.Space);
  Space:SetLabel("Space between bar");
  Space:SetSliderValues(0, 50, 0.1);
  Space:SetIsPercent(false);
  Space:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Space = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SpacingGroup:AddChild(Space);
  
  local BarMaxTime = AceGUI:Create("EditBox");
  BarMaxTime:SetText(tostring(LayoutConfig.BarMaxTime));
  BarMaxTime:SetLabel("Max Time");
  BarMaxTime:SetCallback("OnEnterPressed", function(_, _, Value)
    LayoutConfig.BarMaxTime = tonumber(Value);
    ContainerInstance:Update("LAYOUT");
  end);
  SpacingGroup:AddChild(BarMaxTime);


end
