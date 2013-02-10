local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentGeneralSettings
-----------------------------------------------------------------
function AuraFramesConfig:ContentGeneralSettings()

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
  
  self.Content:AddSpace(2);
  
  self.Content:AddHeader("Boss Mods");

  self.Content:AddText("Aura Frames can use different Boss Mods to display aura's. When using Aura Frames for showing Boss Mods information, then there is not always the need anymore to have the Boss Mods displaying there own bars.\n\nHiding Boss Mods Bars will only work when there is an active container that is using the Boss Mods source! At this moment, Deadly Boss Mods and Deus Vox Encounters are supported\n");

  local HideBossModsBars = AceGUI:Create("CheckBox");
  HideBossModsBars:SetLabel("Hide Boss Mods Bars");
  HideBossModsBars:SetValue(AuraFrames.db.profile.HideBossModsBars);
  HideBossModsBars:SetCallback("OnValueChanged", function(_, _, Value)
    AuraFrames.db.profile.HideBossModsBars = Value;
    LibStub("LibAura-1.0"):GetModule("BossMods-1.0"):SetBossModBarsVisibility(not Value);
  end);
  self.Content:AddChild(HideBossModsBars);

  self.Content:AddSpace(2);
  
  self.Content:AddHeader("Pet Battles");

  self.Content:AddText("Aura Frames can hide all aura containers automaticly upon entering pet battles. This will overrule the In Pet Battle option of the visibility options for containers.\n");

  local HideInPetBattle = AceGUI:Create("CheckBox");
  HideInPetBattle:SetLabel("Hide in pet battle");
  HideInPetBattle:SetValue(AuraFrames.db.profile.HideInPetBattle);
  HideInPetBattle:SetCallback("OnValueChanged", function(_, _, Value)
    AuraFrames.db.profile.HideInPetBattle = Value;
    for _, Container in pairs(AuraFrames.Containers) do
      AuraFrames:CheckVisibility(Container);
    end
  end);
  self.Content:AddChild(HideInPetBattle);

end
