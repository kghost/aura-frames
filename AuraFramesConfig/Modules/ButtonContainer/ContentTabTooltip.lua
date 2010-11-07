local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentTabTooltip
-----------------------------------------------------------------
function Module:ContentTabTooltip(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:SetLayout("List");

  Content:AddText("Tooltip\n", GameFontNormalLarge);
  
  Content:AddText("The container must be clickable for this functionality.");
  
  Content:AddSpace();
  
  local ShowTooltip = AceGUI:Create("CheckBox");
  ShowTooltip:SetLabel("Show Tooltip");
  ShowTooltip:SetValue(LayoutConfig.ShowTooltip);
  ShowTooltip:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowTooltip = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(ShowTooltip);
  
  local TooltipShowPrefix = AceGUI:Create("CheckBox");
  TooltipShowPrefix:SetLabel("Show Prefix");
  TooltipShowPrefix:SetValue(LayoutConfig.TooltipShowPrefix);
  TooltipShowPrefix:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TooltipShowPrefix = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(TooltipShowPrefix);
  
  local TooltipShowCaster = AceGUI:Create("CheckBox");
  TooltipShowCaster:SetLabel("Show Caster");
  TooltipShowCaster:SetValue(LayoutConfig.TooltipShowCaster);
  TooltipShowCaster:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TooltipShowCaster = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(TooltipShowCaster);
  
  local TooltipShowSpellId = AceGUI:Create("CheckBox");
  TooltipShowSpellId:SetLabel("Show SpellId");
  TooltipShowSpellId:SetValue(LayoutConfig.TooltipShowSpellId);
  TooltipShowSpellId:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TooltipShowSpellId = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(TooltipShowSpellId);
  
  local TooltipShowClassification = AceGUI:Create("CheckBox");
  TooltipShowClassification:SetLabel("Show Classification");
  TooltipShowClassification:SetValue(LayoutConfig.TooltipShowClassification);
  TooltipShowClassification:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TooltipShowClassification = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(TooltipShowClassification);
  
end
