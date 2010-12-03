local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import used global references into the local namespace.
local pairs, loadstring, pcall, tostring = pairs, loadstring, pcall, tostring;

--[[

The following types are supported atm:

  String
  Number
  Boolean
  SpellName
  SpellId
  
By default every attribute is defined as static unless there
is NotStatic = true is defined. If the filter contains one or
more attributes that are not static then the filter will be
checked every x time. (This is implemented in the AuraList
leyer).

]]--


-----------------------------------------------------------------
-- AuraDefinition list
-----------------------------------------------------------------
AuraFrames.AuraDefinition = {
  Type = {
    Type = "String",
    Name = "Aura type",
    List = {
      HARMFUL = "Harmful",
      HELPFUL = "Helpful",
      WEAPON = "Weapon enchantment",
      SPELLCOOLDOWN = "Spell Cooldown",
      TOTEM = "Totem",
    },
    Order = true,
    Filter = true,
    Weight = 2,
  },
  Name = {
    Type = "SpellName",
    Name = "Spell name",
    Order = true,
    Filter = true,
    Weight = 2,
  },
  Icon = {
    Type = "String",
    Name = "Spell icon",
    Order = false,
    Filter = false,
    Weight = 2,
  },
  Count = {
    Type = "Number",
    Name = "Aura stacks",
    Order = true,
    Filter = true,
    Weight = 1,
  },
  Classification = {
    Type = "String",
    Name = "Aura classification",
    List = {
      Magic = "Magic",
      Disease = "Disease",
      Poison = "Poison",
      Curse = "Curse",
      None = "None",
    },
    Order = true,
    Filter = true,
    Weight = 2,
  },
  Duration = {
    Type = "Number",
    Name = "Original duration",
    Order = true,
    Filter = true,
    Weight = 1,
  },
  Remaining = {
    Type = "Number",
    Name = "Time remaining",
    Code = "((Object.ExpirationTime == 0 and 0) or (Object.ExpirationTime - GetTime()))",
    Order = true,
    Filter = true,
    NotStatic = true,
    Weight = 3,
  },
  ExpirationTime = {
    Type = "Number",
    Name = "Expiration time",
    Order = true,
    Filter = true,
    Weight = 1,
  },
  IsAura = {
    Type = "Boolean",
    Name = "Is Aura",
    Code = "(Object.ExpirationTime == 0)",
    Order = true,
    Filter = true,
    Weight = 1,
  },
  CasterUnit = {
    Type = "String",
    Name = "Caster unit",
    Order = false,
    Filter = false,
    Weight = 2,
  },
  CasterName = {
    Type = "String",
    Name = "Caster name",
    Order = true,
    Filter = true,
    Weight = 2,
  },
  CasterClass = {
    Type = "String",
    Name = "Caster class",
    List = {
      WARRIOR     = "Warrior",
      DEATHKNIGHT = "Death Knight",
      PALADIN     = "Paladin",
      PRIEST      = "Priest",
      SHAMAN      = "Shaman",
      DRUID       = "Druid",
      ROGUE       = "Rogue",
      MAGE        = "Mage",
      WARLOCK     = "Warlock",
      HUNTER      = "Hunter",
      NONE        = "Unknown",
    },
    Code = "(Object.CasterUnit and select(2, UnitClass(Object.CasterUnit)) or \"NONE\")",
    Order = true,
    Filter = true,
    Weight = 2,
  },
  SpellId = {
    Type = "SpellId",
    Name = "Spell Id",
    Order = true,
    Filter = true,
    Weight = 1,
  },
  CastedByMe = {
    Type = "Boolean",
    Name = "Casted by me",
    Code = "(Object.CasterUnit == \"player\")",
    Order = true,
    Filter = true,
    Weight = 2,
  },
  IsStealable = {
    Type = "Boolean",
    Name = "Is stealable",
    Order = false,
    Filter = false,
    Weight = 1,
  },
  CastedByParty = {
    Type = "Boolean",
    Name = "Casted by party",
    Code = "(Object.CasterUnit and UnitInParty(Object.CasterUnit) == 1)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  CastedByRaid = {
    Type = "Boolean",
    Name = "Casted by raid",
    Code = "(Object.CasterUnit and UnitInRaid(Object.CasterUnit) ~= nil)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  CastedByBgRaid = {
    Type = "Boolean",
    Name = "Casted by bg raid",
    Code = "(Object.CasterUnit and UnitInBattleground(Object.CasterUnit) ~= nil)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  CastedByPlayer = {
    Type = "Boolean",
    Name = "Casted by a player",
    Code = "(Object.CasterUnit and UnitIsPlayer(Object.CasterUnit) == 1)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  TargetIsHostile = {
    Type = "Boolean",
    Name = "Unit Is hostile",
    Code = "(Object.Unit and UnitIsEnemy(\"player\", Object.Unit) == 1)",
    Order = false,
    Filter = true,
    Weight = 3,
  },
  CastedByHostile = {
    Type = "Boolean",
    Name = "Casted by hostile",
    Code = "(Object.CasterUnit and UnitIsEnemy(\"player\", Object.CasterUnit) == 1)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  TargetIsFriendly = {
    Type = "Boolean",
    Name = "Unit Is friendly",
    Code = "(Object.Unit and UnitIsFriend(\"player\", Object.Unit) == 1)",
    Order = false,
    Filter = true,
    Weight = 3,
  },
  CastedByFriendly = {
    Type = "Boolean",
    Name = "Casted by friendly",
    Code = "(Object.CasterUnit and UnitIsFriend(\"player\", Object.CasterUnit) == 1)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
};


-----------------------------------------------------------------
-- Function DumpAura
-----------------------------------------------------------------
function AuraFrames:DumpAura(Aura)

  self:Print("--------------------");

  for Key, Definition in pairs(AuraFrames.AuraDefinition) do
  
    local Value;
    local Error = false;
  
    if Definition.Code then
    
      local Function, ErrorMessage = loadstring("return function(Object) return "..Definition.Code.."; end;");
    
      if Function then
      
        local Condition = Function();
        local Status;
        Status, Value = pcall(Condition, Aura);
      
        if Status ~= true then
          Value = "Failed to execute the condition code! Error Message: "..Value;
          Error = true;
        end
      
      else
      
        Value = "Failed to load the condition code! Error Message: "..ErrorMessage;
        Error = true;
      
      end
    
    else
    
      Value = Aura[Key];
    
    end
    
    if Error == false and Definition.List then
    
      if not Definition.List[Value] then
        Error = true;
        Value = tostring(Value).." (failed to lookup in the list)";
      else
        Value = Definition.List[Value];
      end
    
    end
    
    
    
    if Error == true then
      self:Print("|cff00ffff"..Definition.Name.." |cffffffff- |cffff0000Error |cffffffff= |cffff0000"..tostring(Value).."|r");
    else
    
      if Definition.Type == "SpellId" then
        self:Print("|cff00ffff"..Definition.Name.." |cffffffff= |cff00ff00|Hspell:"..tostring(Value).."|h"..tostring(Value).."|h|r");
      else
        self:Print("|cff00ffff"..Definition.Name.." |cffffffff= |cff00ff00"..tostring(Value).."|r");
      end
      
    end
    
  end

  self:Print("--------------------");

end
