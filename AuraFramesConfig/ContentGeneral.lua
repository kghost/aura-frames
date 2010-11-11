local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentGeneral
-----------------------------------------------------------------
function AuraFramesConfig:ContentGeneral()

  self.Content:SetLayout("List");
  
  self.Content:AddText("General Settings\n", GameFontNormalLarge);

  self.Content:AddHeader("Blizzard Buff Frames");

  self.Content:AddText("Disable and hide the default frames that are used by Blizzard to display buff/debuff aura's. When you enable the Blizzard frames again you need to reload/relog to show them!\n");

  local HideBlizzard = AceGUI:Create("CheckBox");
  HideBlizzard:SetLabel("Hide Blizzard aura frames");
  HideBlizzard:SetValue(AuraFrames.db.profile.HideBlizzardAuraFrames);
  HideBlizzard:SetCallback("OnValueChanged", function(_, _, Value)
    AuraFrames.db.profile.HideBlizzardAuraFrames = Value;
    if Value == true then
      AuraFrames:CheckBlizzardAuraFrames();
    end
  end);
  self.Content:AddChild(HideBlizzard);

  self.Content:AddSpace();
  self.Content:AddHeader("Version Information");
  
  local VersionGroup = AceGUI:Create("SimpleGroup");
  VersionGroup:SetRelativeWidth(1);
  VersionGroup:SetLayout("Flow");
  self:EnhanceContainer(VersionGroup)
  self.Content:AddChild(VersionGroup);

  VersionGroup:AddText("You are running the following version of Aura Frames:");
  VersionGroup:AddSpace();
  
  VersionGroup:AddText("Version", nil, 100);
  VersionGroup:AddText(": |cffff0000"..AuraFrames.Version.String.."|r", nil, 450);
  
  VersionGroup:AddText("Revision", nil, 100);
  VersionGroup:AddText(": "..AuraFrames.Version.Revision, nil, 450);
  
  VersionGroup:AddText("Date", nil, 100);
  VersionGroup:AddText(": "..AuraFrames.Version.Date, nil, 450);
  
  self.Content:AddSpace();
  self.Content:AddHeader("Credits");

  self.Content:AddText("This addon is developed and mainted by |cff9382C9Nexiuz|r (|cff0070DDBeautiuz|r) @ Bloodhoof EU.\n\nThe two most important addons that helped me and inspired me are SatrinaBuffFrame and LibBuffet.\n\nSpecial thanks goes to |cff9382C9Ripsomeone|r @ Bloodhoof EU for testing and helping me giving the addon his current form.");

end
