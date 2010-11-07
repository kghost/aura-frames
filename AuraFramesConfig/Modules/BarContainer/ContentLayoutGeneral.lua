local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("BarContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentLayoutGeneral
-----------------------------------------------------------------
function Module:ContentLayoutGeneral(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:ReleaseChildren();
  
  Content:SetLayout("List");

  Content:AddText("General\n", GameFontNormalLarge);

  Content:AddHeader("Mouse");
  
  local Clickable = AceGUI:Create("CheckBox");
  Clickable:SetLabel("Container receive mouse events");
  Clickable:SetDescription("When the container receive mouse events, you can not click thru it. Receiving mouse events is needed for tooltip and canceling aura's when right clicking them.");
  Clickable:SetRelativeWidth(1);
  Clickable:SetValue(LayoutConfig.Clickable);
  Clickable:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Clickable = Value;
    ContainerInstance:Update("LAYOUT");
    Module:ContentLayoutGeneral(Content, ContainerId);
  end);
  Content:AddChild(Clickable);

  Content:AddSpace();

  Content:AddHeader("Tooltip");
  
  if LayoutConfig.Clickable ~= true then
  
    Content:AddText("The container must receive mouse events for this functionality.");
  
  else
  
    local ShowTooltip = AceGUI:Create("CheckBox");
    ShowTooltip:SetLabel("Enable Tooltip");
    ShowTooltip:SetDescription("Show aura information in a tooltip when mouse over the aura.");
    ShowTooltip:SetRelativeWidth(1);
    ShowTooltip:SetValue(LayoutConfig.ShowTooltip);
    ShowTooltip:SetCallback("OnValueChanged", function(_, _, Value)
      LayoutConfig.ShowTooltip = Value;
      ContainerInstance:Update("LAYOUT");
      Module:ContentLayoutGeneral(Content, ContainerId);
    end);
    Content:AddChild(ShowTooltip);
    
    Content:AddSpace();
    
    local ContentTooltip = AceGUI:Create("SimpleGroup");
    ContentTooltip:SetRelativeWidth(1);
    ContentTooltip:SetLayout("Flow");
    Content:AddChild(ContentTooltip);
    
    local TooltipShowPrefix = AceGUI:Create("CheckBox");
    TooltipShowPrefix:SetDisabled(not LayoutConfig.ShowTooltip);
    TooltipShowPrefix:SetWidth(260);
    TooltipShowPrefix:SetLabel("Show Prefix");
    TooltipShowPrefix:SetDescription("Put before the extra information the type of information");
    TooltipShowPrefix:SetValue(LayoutConfig.TooltipShowPrefix);
    TooltipShowPrefix:SetCallback("OnValueChanged", function(_, _, Value)
      LayoutConfig.TooltipShowPrefix = Value;
      ContainerInstance:Update("LAYOUT");
    end);
    ContentTooltip:AddChild(TooltipShowPrefix);
    
    local TooltipShowCaster = AceGUI:Create("CheckBox");
    TooltipShowCaster:SetDisabled(not LayoutConfig.ShowTooltip);
    TooltipShowCaster:SetWidth(260);
    TooltipShowCaster:SetLabel("Show Caster");
    TooltipShowCaster:SetDescription("Show who have casted the aura");
    TooltipShowCaster:SetValue(LayoutConfig.TooltipShowCaster);
    TooltipShowCaster:SetCallback("OnValueChanged", function(_, _, Value)
      LayoutConfig.TooltipShowCaster = Value;
      ContainerInstance:Update("LAYOUT");
    end);
    ContentTooltip:AddChild(TooltipShowCaster);
    
    local TooltipShowSpellId = AceGUI:Create("CheckBox");
    TooltipShowSpellId:SetDisabled(not LayoutConfig.ShowTooltip);
    TooltipShowSpellId:SetWidth(260);
    TooltipShowSpellId:SetLabel("Show SpellId");
    TooltipShowSpellId:SetDescription("Show the internal ID of the casted spell");
    TooltipShowSpellId:SetValue(LayoutConfig.TooltipShowSpellId);
    TooltipShowSpellId:SetCallback("OnValueChanged", function(_, _, Value)
      LayoutConfig.TooltipShowSpellId = Value;
      ContainerInstance:Update("LAYOUT");
    end);
    ContentTooltip:AddChild(TooltipShowSpellId);
    
    local TooltipShowClassification = AceGUI:Create("CheckBox");
    TooltipShowClassification:SetDisabled(not LayoutConfig.ShowTooltip);
    TooltipShowClassification:SetWidth(260);
    TooltipShowClassification:SetLabel("Show Classification");
    TooltipShowClassification:SetDescription("Show the aura classification the tooltip (magic, curse, poison or none)");
    TooltipShowClassification:SetValue(LayoutConfig.TooltipShowClassification);
    TooltipShowClassification:SetCallback("OnValueChanged", function(_, _, Value)
      LayoutConfig.TooltipShowClassification = Value;
      ContainerInstance:Update("LAYOUT");
    end);
    ContentTooltip:AddChild(TooltipShowClassification);
  
  end
  
  Content:AddSpace();

  Content:AddHeader("Aura Icon");
  
  Content:AddText("The aura icon can be displayed at any side or not at all.");
  
  local Icon = AceGUI:Create("Dropdown");
  Icon:SetList({
    NONE = "None",
    LEFT = "Left",
    RIGHT = "Right",
  });
  Icon:SetLabel("Icon");
  Icon:SetValue(LayoutConfig.Icon);
  Icon:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Icon = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  Content:AddChild(Icon);
  
  
end