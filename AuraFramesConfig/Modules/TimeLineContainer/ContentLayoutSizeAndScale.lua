local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("TimeLineContainer");
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
    Module:Update(ContainerId);
  end);
  Content:AddChild(Scale);
  Content:AddText("The scale will effect the whole container, including aura's and text.", GameFontHighlightSmall);
  
  Content:AddSpace(2);
  
  local SizeGroup = AceGUI:Create("SimpleGroup");
  SizeGroup:SetLayout("Flow");
  SizeGroup:SetRelativeWidth(1);
  AuraFramesConfig:EnhanceContainer(SizeGroup);
  Content:AddChild(SizeGroup);
  
  local Size = AceGUI:Create("Slider");
  Size:SetWidth(250);
  Size:SetValue(LayoutConfig.Size);
  Size:SetLabel("Size of the timeline");
  Size:SetSliderValues(50, 1000, 10);
  Size:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Size = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  SizeGroup:AddChild(Size);

  SizeGroup:AddText(" ", nil, 250);

  SizeGroup:AddText("The width of the bars including the aura icon.", GameFontHighlightSmall, 250);
  
  Content:AddSpace();

end
