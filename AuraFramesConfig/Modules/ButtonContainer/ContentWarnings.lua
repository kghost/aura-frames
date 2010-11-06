local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentWarnings
-----------------------------------------------------------------
function Module:ContentWarnings(ContainerId)

  local WarningsConfig = AuraFrames.db.profile.Containers[ContainerId].Warnings;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  local Content = AuraFramesConfig.Content;

  Content:SetLayout("List");
  
  Content:AddText("Warnings\n", GameFontNormalLarge);
  
  Content:AddHeader("New Aura's");
  
  local GroupNewFlash = AceGUI:Create("InlineGroup");
  GroupNewFlash:SetTitle("Flash");
  GroupNewFlash:SetRelativeWidth(1);
  GroupNewFlash:SetLayout("Flow");
  Content:AddChild(GroupNewFlash);
  
  local CheckBoxNewFlash = AceGUI:Create("CheckBox");
  CheckBoxNewFlash:SetWidth(140);
  CheckBoxNewFlash:SetLabel("Enable Flash");
  CheckBoxNewFlash:SetValue(WarningsConfig.New.Flash);
  CheckBoxNewFlash:SetCallback("OnValueChanged", function(_, _, Value)
    WarningsConfig.New.Flash = Value;
    ContainerInstance:Update("WARNINGS");
  end);
  GroupNewFlash:AddChild(CheckBoxNewFlash);
  
  local SliderNewFlashNumber = AceGUI:Create("Slider");
  SliderNewFlashNumber:SetLabel("Number of flashes");
  SliderNewFlashNumber:SetSliderValues(1, 10, 1);
  SliderNewFlashNumber:SetValue(WarningsConfig.New.FlashNumber);
  SliderNewFlashNumber:SetCallback("OnValueChanged", function(_, _, Value)
    WarningsConfig.New.FlashNumber = Value;
    ContainerInstance:Update("WARNINGS");
  end);
  GroupNewFlash:AddChild(SliderNewFlashNumber);
  
  local SliderNewFlashSpeed = AceGUI:Create("Slider");
  SliderNewFlashSpeed:SetLabel("Speed in seconds");
  SliderNewFlashSpeed:SetSliderValues(0.5, 2.0, 0.1);
  SliderNewFlashSpeed:SetValue(WarningsConfig.New.FlashSpeed);
  SliderNewFlashSpeed:SetCallback("OnValueChanged", function(_, _, Value)
    WarningsConfig.New.FlashSpeed = Value;
    ContainerInstance:Update("WARNINGS");
  end);
  GroupNewFlash:AddChild(SliderNewFlashSpeed);
  
  Content:AddSpace(2);
  Content:AddHeader("Expiring Aura's");
  
  local GroupExpireFlash = AceGUI:Create("InlineGroup");
  GroupExpireFlash:SetTitle("Flash");
  GroupExpireFlash:SetRelativeWidth(1);
  GroupExpireFlash:SetLayout("Flow");
  Content:AddChild(GroupExpireFlash);
  
  local CheckBoxExpireFlash = AceGUI:Create("CheckBox");
  CheckBoxExpireFlash:SetWidth(140);
  CheckBoxExpireFlash:SetLabel("Enable Flash");
  CheckBoxExpireFlash:SetValue(WarningsConfig.Expire.Flash);
  CheckBoxExpireFlash:SetCallback("OnValueChanged", function(_, _, Value)
    WarningsConfig.Expire.Flash = Value;
    ContainerInstance:Update("WARNINGS");
  end);
  GroupExpireFlash:AddChild(CheckBoxExpireFlash);
  
  local SliderExpireFlashNumber = AceGUI:Create("Slider");
  SliderExpireFlashNumber:SetLabel("Number of flashes");
  SliderExpireFlashNumber:SetSliderValues(1, 10, 1);
  SliderExpireFlashNumber:SetValue(WarningsConfig.Expire.FlashNumber);
  SliderExpireFlashNumber:SetCallback("OnValueChanged", function(_, _, Value)
    WarningsConfig.Expire.FlashNumber = Value;
    ContainerInstance:Update("WARNINGS");
  end);
  GroupExpireFlash:AddChild(SliderExpireFlashNumber);
  
  local SliderExpireFlashSpeed = AceGUI:Create("Slider");
  SliderExpireFlashSpeed:SetLabel("Speed in seconds");
  SliderExpireFlashSpeed:SetSliderValues(0.5, 2.0, 0.1);
  SliderExpireFlashSpeed:SetValue(WarningsConfig.Expire.FlashSpeed);
  SliderExpireFlashSpeed:SetCallback("OnValueChanged", function(_, _, Value)
    WarningsConfig.Expire.FlashSpeed = Value;
    ContainerInstance:Update("WARNINGS");
  end);
  GroupExpireFlash:AddChild(SliderExpireFlashSpeed);

end
