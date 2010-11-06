local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");


-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;


-----------------------------------------------------------------
-- Function ShowTooltip
-----------------------------------------------------------------
function AuraFrames:ShowTooltip(Aura, Frame, Options)

  GameTooltip:SetOwner(Frame, "ANCHOR_BOTTOMLEFT");
  
  if Aura.Unit == "test" then
  
    GameTooltip:SetHyperlink("spell:"..Aura.SpellId);
  
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffff0000Test Aura|r");

  elseif Aura.Type == "WEAPON" then
  
    GameTooltip:SetInventoryItem(Aura.Unit, Aura.Index);
  
  elseif Aura.Type == "SPELLCOOLDOWN" or Aura.Type == "SPELLCOOLDOWNOLD" then
  
    GameTooltip:SetSpellBookItem(Aura.Index, BOOKTYPE_SPELL);
  
  elseif Aura.Type == "INTERNALCOOLDOWNITEM" or Aura.Type == "INTERNALCOOLDOWNITEMOLD" then
  
    GameTooltip:SetInventoryItem(Aura.Unit, Aura.Index);
  
  elseif Aura.Type == "INTERNALCOOLDOWNTALENT" or Aura.Type == "INTERNALCOOLDOWNTALENTOLD" then
  
    --GameTooltip:SetTalent(Aura.SpellId);
  
  elseif Aura.Type == "TOTEM" or Aura.Type == "TOTEMOLD" then
  
    GameTooltip:SetHyperlink("spell:"..Aura.SpellId);
  
  elseif Aura.Type == "HARMFUL" or Aura.Type == "HELPFUL" then
  
    GameTooltip:SetUnitAura(Aura.Unit, Aura.Index, Aura.Type);
  
  elseif Aura.Type == "HARMFULOLD" or Aura.Type == "HELPFULOLD" then
  
    GameTooltip:SetHyperlink("spell:"..Aura.SpellId);
  
  end
  
  if Options.ShowCaster == true or Options.ShowSpellId == true or Options.ShowClassification then
    GameTooltip:AddLine(" ")
  end
  
  if Options.ShowCaster == true and Aura.CasterUnit then
    
    if Options.ShowPrefix == true then
    
      if Aura.CasterName then
        local Color = RAID_CLASS_COLORS[Aura.CasterUnit and select(2, UnitClass(Aura.CasterUnit)) or "NONE"];
        if Color then
          GameTooltip:AddLine(format("Caster: |cff%02x%02x%02x%s|r", Color.r * 255, Color.g * 255, Color.b * 255, Aura.CasterName));
        else
          GameTooltip:AddLine("Caster: "..Aura.CasterName);
        end
      else
        GameTooltip:AddLine("Caster: "..Aura.CasterUnit);
      end
    
    else
    
      if Aura.CasterName then
        local Color = RAID_CLASS_COLORS[Aura.CasterUnit and select(2, UnitClass(Aura.CasterUnit)) or "NONE"];
        if Color then
          GameTooltip:AddLine(format("|cff%02x%02x%02x%s|r", Color.r * 255, Color.g * 255, Color.b * 255, Aura.CasterName));
        else
          GameTooltip:AddLine(Aura.CasterName);
        end
      else
        GameTooltip:AddLine(Aura.CasterUnit);
      end
    
    end
    
  end
  
  if Options.ShowSpellId == true and Aura.SpellId then
    
    if Options.ShowPrefix == true then
      GameTooltip:AddLine("Spell ID: |cffff0000"..Aura.SpellId.."|r");
    else
      GameTooltip:AddLine("|cffff0000"..Aura.SpellId.."|r");
    end
    
  end
  
  if Options.ShowClassification == true and Aura.Classification then
    
    if Options.ShowPrefix == true then
      GameTooltip:AddLine("Classification: |cffff8040"..Aura.Classification.."|r");
    else
      GameTooltip:AddLine("|cffff8040"..Aura.Classification.."|r");
    end
    
  end

  GameTooltip:Show();

end

-----------------------------------------------------------------
-- Function IsTooltipOwner
-----------------------------------------------------------------
function AuraFrames:IsTooltipOwner(Frame)

  return GameTooltip:GetOwner() == Frame;

end

-----------------------------------------------------------------
-- Function HideTooltip
-----------------------------------------------------------------
function AuraFrames:HideTooltip()

  GameTooltip:Hide();

end

