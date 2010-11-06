local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentGeneral
-----------------------------------------------------------------
function AuraFramesConfig:ContentGeneral()

  self.Content:SetLayout("List");
  
  self.Content:AddText("General Settings\n", GameFontNormalLarge);

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
  self.Content:AddHeader("Credits");

  self.Content:AddText("This addon is developed and mainted by Nexiuz (Beautiuz) @ Bloodhoof EU.\n\nSome code are based on other addons, the two most imported addons that helped me and inspired me are SatrinaBuffFrame and LibBuffet.\n\nSpecial thanks goes to Ripsomeone @ Bloodhoof EU for testing and helping me giving the addon his current form.");

end
