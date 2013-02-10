local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");

local SupportedVisibilityOptions = {
  {"InCombat", "In Combat"},
  {"OutOfCombat", "Out Of Combat"},
  {"PrimaryTalents", "Primary Talents"},
  {"SecondaryTalents", "Secondary Talents"},
  {"Mounted", "Mounted"},
  {"Vehicle", "Vehicle"},
  {"Solo", "Solo"},
  {"InInstance", "In Instance"},
  {"NotInInstance", "Not in Instance"},
  {"InParty", "In Party"},
  {"InRaid", "In Raid"},
  {"InBattleground", "In Battleground"},
  {"InArena", "In Arena"},
  {"FocusEqualsTarget", "Focus equals Target"},
  {"InPetBattle", "In Pet Battle"},
};

local IconNotSet = "Interface\\Addons\\AuraFramesConfig\\Icons\\Checkbox";
local IconEnabled  = "Interface\\Addons\\AuraFramesConfig\\Icons\\Checkbox-Enabled";
local IconDisabled = "Interface\\Addons\\AuraFramesConfig\\Icons\\Checkbox-Disabled";

-----------------------------------------------------------------
-- Function ContentVisibilityRefresh
-----------------------------------------------------------------
function AuraFramesConfig:ContentVisibilityRefresh(Content, ContainerId)

  local VisibilityConfig = AuraFrames.db.profile.Containers[ContainerId].Visibility;
  local ContainerInstance = AuraFrames.Containers[ContainerId];


  Content:PauseLayout();
  Content:ReleaseChildren();
  
  Content:SetLayout("List");

  Content:AddText("Visibility\n", GameFontNormalLarge);

  local CheckBoxAlwaysVisible = AceGUI:Create("CheckBox");
  CheckBoxAlwaysVisible:SetWidth(300);
  CheckBoxAlwaysVisible:SetLabel("Container is always visible");
  CheckBoxAlwaysVisible:SetValue(VisibilityConfig.AlwaysVisible);
  CheckBoxAlwaysVisible:SetCallback("OnValueChanged", function(_, _, Value)
    VisibilityConfig.AlwaysVisible = Value;
    AuraFrames:CheckVisibility(ContainerInstance);
    AuraFramesConfig:ContentVisibilityRefresh(Content, ContainerId);
  end);
  Content:AddChild(CheckBoxAlwaysVisible);
  
  Content:AddSpace();

  local GroupOpacity = AceGUI:Create("InlineGroup");
  GroupOpacity:SetTitle("Opacity");
  GroupOpacity:SetRelativeWidth(1);
  GroupOpacity:SetLayout("Flow");
  self:EnhanceContainer(GroupOpacity);
  Content:AddChild(GroupOpacity);
  
  local SliderOpacityVisible = AceGUI:Create("Slider");
  SliderOpacityVisible:SetIsPercent(true);
  SliderOpacityVisible:SetWidth(430);
  SliderOpacityVisible:SetLabel("Opacity when visible");
  SliderOpacityVisible:SetSliderValues(0, 1, 0.01);
  SliderOpacityVisible:SetValue(VisibilityConfig.OpacityVisible);
  SliderOpacityVisible:SetCallback("OnValueChanged", function(_, _, Value)
    VisibilityConfig.OpacityVisible = Value;
    AuraFrames:CheckVisibility(ContainerInstance);
  end);
  GroupOpacity:AddChild(SliderOpacityVisible);
  
  local SliderOpacityNotVisible = AceGUI:Create("Slider");
  SliderOpacityNotVisible:SetIsPercent(true);
  SliderOpacityNotVisible:SetDisabled(VisibilityConfig.AlwaysVisible);
  SliderOpacityNotVisible:SetWidth(430);
  SliderOpacityNotVisible:SetLabel("Opacity when not visible");
  SliderOpacityNotVisible:SetSliderValues(0, 1, 0.01);
  SliderOpacityNotVisible:SetValue(VisibilityConfig.OpacityNotVisible);
  SliderOpacityNotVisible:SetCallback("OnValueChanged", function(_, _, Value)
    VisibilityConfig.OpacityNotVisible = Value;
    AuraFrames:CheckVisibility(ContainerInstance);
  end);
  GroupOpacity:AddChild(SliderOpacityNotVisible);
  
  GroupOpacity:AddText("\nNote: On circle shaped buttons, any opacity other than 0% or 100% may result in undesired effects.", nil, 500);
  GroupOpacity:AddText("\nNote: If the opacity is 0% then the container will be hidden and the mouse will not have any effect (no tooltips).", nil, 500);
  
  Content:AddSpace();

  local GroupVisibility = AceGUI:Create("InlineGroup");
  GroupVisibility:SetTitle("Visibility");
  GroupVisibility:SetRelativeWidth(1);
  GroupVisibility:SetLayout("Flow");
  Content:AddChild(GroupVisibility);
  
  for _, Option in ipairs(SupportedVisibilityOptions) do
  
    local Status = AceGUI:Create("InteractiveLabel");
    Status:SetDisabled(VisibilityConfig.AlwaysVisible or (Option[1] == "InPetBattle" and AuraFrames.db.profile.HideInPetBattle == true));
    if VisibilityConfig.VisibleWhen[Option[1]] == true then
      Status:SetImage(IconEnabled);
    elseif VisibilityConfig.VisibleWhenNot[Option[1]] == true then
      Status:SetImage(IconDisabled);
    else
      Status:SetImage(IconNotSet);
    end
    Status:SetImageSize(24, 24);
    Status:SetWidth(230);
    Status:SetText(Option[2]);
    Status:SetHighlight("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight");
    Status:SetHighlightTexCoord(0, 1, 0.23, 0.77);
    Status:SetCallback("OnClick", function()
      if VisibilityConfig.VisibleWhen[Option[1]] == true then
        VisibilityConfig.VisibleWhen[Option[1]] = nil;
        VisibilityConfig.VisibleWhenNot[Option[1]] = true
        Status:SetImage(IconDisabled);
      elseif VisibilityConfig.VisibleWhenNot[Option[1]] == true then
        VisibilityConfig.VisibleWhen[Option[1]] = nil;
        VisibilityConfig.VisibleWhenNot[Option[1]] = nil
        Status:SetImage(IconNotSet);
      else
        VisibilityConfig.VisibleWhen[Option[1]] = true;
        VisibilityConfig.VisibleWhenNot[Option[1]] = nil
        Status:SetImage(IconEnabled);
      end
      AuraFrames:CheckVisibility(ContainerInstance);
    end);
    GroupVisibility:AddChild(Status);

  end
  
  Content:AddSpace();

  local ExplainNotSet = AceGUI:Create("InteractiveLabel");
  ExplainNotSet:SetImage(IconNotSet);
  ExplainNotSet:SetImageSize(24, 24);
  ExplainNotSet:SetWidth(400);
  ExplainNotSet:SetText("Ignore the condition");
  Content:AddChild(ExplainNotSet);

  local ExplainEnabled = AceGUI:Create("InteractiveLabel");
  ExplainEnabled:SetImage(IconEnabled);
  ExplainEnabled:SetImageSize(24, 24);
  ExplainEnabled:SetWidth(400);
  ExplainEnabled:SetText("One or more of these conditions must be met");
  Content:AddChild(ExplainEnabled);

  local ExplainDisabled = AceGUI:Create("InteractiveLabel");
  ExplainDisabled:SetImage(IconDisabled);
  ExplainDisabled:SetImageSize(24, 24);
  ExplainDisabled:SetWidth(400);
  ExplainDisabled:SetText("None of these conditions must be met");
  Content:AddChild(ExplainDisabled);

  Content:AddSpace();

  if AuraFrames.db.profile.HideInPetBattle == true then

    Content:AddText("The condition \"In Pet Battle\" is disabled because of the global setting that containers are always hiden in pet battles.\n");
    Content:AddSpace();

  end

  local GroupFade = AceGUI:Create("InlineGroup");
  GroupFade:SetTitle("Fading");
  GroupFade:SetRelativeWidth(1);
  GroupFade:SetLayout("Flow");
  Content:AddChild(GroupFade);
  
  local CheckBoxFadeInEnabled = AceGUI:Create("CheckBox");
  CheckBoxFadeInEnabled:SetDisabled(VisibilityConfig.AlwaysVisible);
  CheckBoxFadeInEnabled:SetWidth(140);
  CheckBoxFadeInEnabled:SetLabel("Enable Fade In");
  CheckBoxFadeInEnabled:SetValue(VisibilityConfig.FadeIn);
  CheckBoxFadeInEnabled:SetCallback("OnValueChanged", function(_, _, Value)
    VisibilityConfig.FadeIn = Value;
    AuraFrames:CheckVisibility(ContainerInstance);
    AuraFramesConfig:ContentVisibilityRefresh(Content, ContainerId);
  end);
  GroupFade:AddChild(CheckBoxFadeInEnabled);
  
  local SliderFadeInTime = AceGUI:Create("Slider");
  SliderFadeInTime:SetDisabled(VisibilityConfig.AlwaysVisible or not VisibilityConfig.FadeIn);
  SliderFadeInTime:SetWidth(300);
  SliderFadeInTime:SetLabel("Fade in time");
  SliderFadeInTime:SetSliderValues(0.1, 10, 0.1);
  SliderFadeInTime:SetValue(VisibilityConfig.FadeInTime);
  SliderFadeInTime:SetCallback("OnValueChanged", function(_, _, Value)
    VisibilityConfig.FadeInTime = Value;
    AuraFrames:CheckVisibility(ContainerInstance);
  end);
  GroupFade:AddChild(SliderFadeInTime);
  
  local CheckBoxFadeOutEnabled = AceGUI:Create("CheckBox");
  CheckBoxFadeOutEnabled:SetDisabled(VisibilityConfig.AlwaysVisible);
  CheckBoxFadeOutEnabled:SetWidth(140);
  CheckBoxFadeOutEnabled:SetLabel("Enable Fade Out");
  CheckBoxFadeOutEnabled:SetValue(VisibilityConfig.FadeOut);
  CheckBoxFadeOutEnabled:SetCallback("OnValueChanged", function(_, _, Value)
    VisibilityConfig.FadeOut = Value;
    AuraFrames:CheckVisibility(ContainerInstance);
    AuraFramesConfig:ContentVisibilityRefresh(Content, ContainerId);
  end);
  GroupFade:AddChild(CheckBoxFadeOutEnabled);
  
  local SliderFadeOutTime = AceGUI:Create("Slider");
  SliderFadeOutTime:SetDisabled(VisibilityConfig.AlwaysVisible or not VisibilityConfig.FadeOut);
  SliderFadeOutTime:SetWidth(300);
  SliderFadeOutTime:SetLabel("Fade out time");
  SliderFadeOutTime:SetSliderValues(0.1, 10, 0.1);
  SliderFadeOutTime:SetValue(VisibilityConfig.FadeOutTime);
  SliderFadeOutTime:SetCallback("OnValueChanged", function(_, _, Value)
    VisibilityConfig.FadeOutTime = Value;
    AuraFrames:CheckVisibility(ContainerInstance);
  end);
  GroupFade:AddChild(SliderFadeOutTime);
  
  Content:ResumeLayout();
  Content:DoLayout();
  
end


-----------------------------------------------------------------
-- Function ContentVisibility
-----------------------------------------------------------------
function AuraFramesConfig:ContentVisibility(ContainerId)

  self.Content:SetLayout("Fill");
  
  local Content = AceGUI:Create("ScrollFrame");
  Content:SetLayout("List");
  self:EnhanceContainer(Content);
  self.Content:AddChild(Content);
  
  self:ContentVisibilityRefresh(Content, ContainerId);

end