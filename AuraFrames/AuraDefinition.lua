local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import used global references into the local namespace.
local pairs, ipairs, loadstring, pcall, tostring, tinsert, sort = pairs, ipairs, loadstring, pcall, tostring, tinsert, sort;

--[[

The following types are supported atm:

  String
  Number
  Boolean
  SpellName
  SpellId
  
By default every attribute is defined as static unless there
is Dynamic = true is defined. If the filter contains one or
more attributes that are not static then the filter will be
checked every x time. (This is implemented in the AuraList
layer).

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
      ITEMCOOLDOWN = "Item Cooldown",
      TOTEM = "Totem",
      ALERT = "Boss Mod Alert",
    },
    Order = true,
    Filter = true,
    Weight = 2,
  },
  Name = { -- Used for build in filters
    Type = "String",
    Name = "Name",
    Order = false,
    Filter = false,
    Weight = 2,
  },
  SpellName = {
    Type = "SpellName",
    Name = "Spell name",
    Order = true,
    Filter = true,
    Code = "(Object.SpellId ~= 0 and Object.Name or \"\")",
    Weight = 2,
  },
  ItemName = {
    Type = "ItemName",
    Name = "Item name",
    Order = true,
    Filter = true,
    Code = "(Object.ItemId ~= 0 and Object.Name or \"\")",
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
    Dynamic = true,
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
  ItemId = {
    Type = "ItemId",
    Name = "Item Id",
    Order = true,
    Filter = true,
    Weight = 1,
  },
  CastByMe = {
    Type = "Boolean",
    Name = "Cast by me",
    Code = "(Object.CasterUnit == \"player\")",
    Order = true,
    Filter = true,
    Weight = 2,
  },
  IsStealable = {
    Type = "Boolean",
    Name = "Is stealable",
    Order = false,
    Filter = true,
    Weight = 1,
  },
  CastByParty = {
    Type = "Boolean",
    Name = "Cast by party",
    Code = "(Object.CasterUnit and UnitInParty(Object.CasterUnit) == 1)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  CastByRaid = {
    Type = "Boolean",
    Name = "Cast by raid",
    Code = "(Object.CasterUnit and UnitInRaid(Object.CasterUnit) ~= nil)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  CastByBgRaid = {
    Type = "Boolean",
    Name = "Cast by bg raid",
    Code = "(Object.CasterUnit and UnitInBattleground(Object.CasterUnit) ~= nil)",
    Order = true,
    Filter = true,
    Weight = 3,
  },
  CastByPlayer = {
    Type = "Boolean",
    Name = "Cast by a player",
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
  CastByHostile = {
    Type = "Boolean",
    Name = "Cast by hostile",
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
  CastByFriendly = {
    Type = "Boolean",
    Name = "Cast by friendly",
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

  local List = {};
  
  for Key, Definition in pairs(AuraFrames.AuraDefinition) do
  
    tinsert(List, {Key = Key, Definition = Definition});
  
  end
  
  sort(List, function(Item1, Item2)
  
    return Item1.Definition.Name < Item2.Definition.Name;
  
  end);

  self:Print("--------------------");
  
  for _, Item in ipairs(List) do
  
    local Key, Definition = Item.Key, Item.Definition;
  
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
     
      elseif Definition.Type == "ItemId" then
      
        self:Print("|cff00ffff"..Definition.Name.." |cffffffff= |cff00ff00|Hitem:"..tostring(Value).."|h"..tostring(Value).."|h|r");
      
      else
      
        self:Print("|cff00ffff"..Definition.Name.." |cffffffff= |cff00ff00"..tostring(Value).."|r");
      
      end
      
    end
    
  end

  self:Print("--------------------");

end
