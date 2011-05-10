local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

local PlayerClass = select(2, UnitClass("player"));

-----------------------------------------------------------------
-- Function SetSpellCooldownList
-----------------------------------------------------------------
function AuraFrames:SetSpellCooldownList()

  LibStub("LibAura-1.0"):GetModule("SpellCooldowns-1.0"):SetAdditionalSpellCooldownList(self.db.global.SpellCooldowns[PlayerClass] or {});

end