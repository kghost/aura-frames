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

  if AuraFrames.db.profile.HideInPetBattle == true then

    Content:AddText("The condition \"In Pet Battle\" is disabled because of the global setting that containers are always hiden in pet battles.\n");
    Content:AddSpace();

  end

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
  
  local GroupVisibleWhen = AceGUI:Create("InlineGroup");
  GroupVisibleWhen:SetTitle("Visible When (one of the following conditions is met)");
  GroupVisibleWhen:SetRelativeWidth(1);
  GroupVisibleWhen:SetLayout("Flow");
  Content:AddChild(GroupVisibleWhen);
  
  for _, Option in ipairs(SupportedVisibilityOptions) do
  
    local CheckBoxOption = AceGUI:Create("CheckBox");
    CheckBoxOption:SetDisabled(VisibilityConfig.AlwaysVisible or (Option[1] == "InPetBattle" and AuraFrames.db.profile.HideInPetBattle == true));
    CheckBoxOption:SetWidth(230);
    CheckBoxOption:SetLabel(Option[2]);
    CheckBoxOption:SetValue(VisibilityConfig.VisibleWhen[Option[1]] == true);
    CheckBoxOption:SetCallback("OnValueChanged", function(_, _, Value)
      VisibilityConfig.VisibleWhen[Option[1]] = Value == true and true or nil;
      AuraFrames:CheckVisibility(ContainerInstance);
    end);
    GroupVisibleWhen:AddChild(CheckBoxOption);
  
  end
  
  Content:AddSpace();

  local GroupVisibleWhenNot = AceGUI:Create("InlineGroup");
  GroupVisibleWhenNot:SetTitle("Visible When Not (one of the following conditions is met)");
  GroupVisibleWhenNot:SetRelativeWidth(1);
  GroupVisibleWhenNot:SetLayout("Flow");
  Content:AddChild(GroupVisibleWhenNot);
  
  for _, Option in ipairs(SupportedVisibilityOptions) do
  
    local CheckBoxOption = AceGUI:Create("CheckBox");
    CheckBoxOption:SetDisabled(VisibilityConfig.AlwaysVisible or (Option[1] == "InPetBattle" and AuraFrames.db.profile.HideInPetBattle == true));
    CheckBoxOption:SetWidth(230);
    CheckBoxOption:SetLabel(Option[2]);
    CheckBoxOption:SetValue(VisibilityConfig.VisibleWhenNot[Option[1]] == true);
    CheckBoxOption:SetCallback("OnValueChanged", function(_, _, Value)
      VisibilityConfig.VisibleWhenNot[Option[1]] = Value == true and true or nil;
      AuraFrames:CheckVisibility(ContainerInstance);
    end);
    GroupVisibleWhenNot:AddChild(CheckBoxOption);
  
  end
  
  Content:AddSpace();
  
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