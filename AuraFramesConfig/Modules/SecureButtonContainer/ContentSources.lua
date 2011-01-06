local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("SecureButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");

-----------------------------------------------------------------
-- Function ContentSources
-----------------------------------------------------------------
function Module:ContentSources(ContainerId)

  local Config = AuraFrames.db.profile.Containers[ContainerId];
  local ContainerInstance = AuraFrames.Containers[ContainerId];
  
  local Content = AuraFramesConfig.Content;
  
  Content:ReleaseChildren();

  Content:SetLayout("List");
  
  Content:AddText("Sources\n", GameFontNormalLarge);
  
  Content:AddText("\nThe Secure Button container is using Blizzards build in buffing/debuffing framework which is very limited:\n\n");
  
  local DropdownUnit = AceGUI:Create("Dropdown");
  DropdownUnit:SetList({
    player        = "Player",
    target        = "Target",
    targettarget  = "Target's Target",
    focus         = "Focus",
    focustarget   = "Focus Target",
    pet           = "Pet",
    pettarget     = "Pet Target",
    vehicle       = "Vehicle",
    vehicletarget = "Vehicle Target",
  });
  DropdownUnit:SetLabel("Unit to monitor");
  DropdownUnit:SetValue(Config.Unit);
  DropdownUnit:SetCallback("OnValueChanged", function(_, _, Value)
    Config.Unit = Value;
    ContainerInstance:Update("ALL");
  end);
  Content:AddChild(DropdownUnit);
  
  Content:AddSpace();
  
  local DropdownFilter = AceGUI:Create("Dropdown");
  DropdownFilter:SetList({
    HELPFUL = "Buffs",
    HARMFUL = "Debuffs",
  });
  DropdownFilter:SetLabel("Type to monitor");
  DropdownFilter:SetValue(Config.Filter);
  DropdownFilter:SetCallback("OnValueChanged", function(_, _, Value)
    Config.Filter = Value;
    ContainerInstance:Update("ALL");
  end);
  Content:AddChild(DropdownFilter);
  
  Content:AddSpace();
  
  local CheckBoxIncludeWeapons = AceGUI:Create("CheckBox");
  CheckBoxIncludeWeapons:SetWidth(400);
  CheckBoxIncludeWeapons:SetLabel("Include Weapons Enchantments");
  CheckBoxIncludeWeapons:SetValue(Config.IncludeWeapons);
  CheckBoxIncludeWeapons:SetCallback("OnValueChanged", function(_, _, Value)
    Config.IncludeWeapons = Value;
    ContainerInstance:Update("ALL");
  end);
  Content:AddChild(CheckBoxIncludeWeapons);
  
end

