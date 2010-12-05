-----------------------------------------------------------------
--
--  File: Totems.lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--
--
--  Todo:
--
--
--
-----------------------------------------------------------------


local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "Totems-1.0", 0;
local Module = LibAura:NewModule(Major, Minor);

if not Module then return; end -- No upgrade needed.

-- Import used global references into the local namespace.
local pairs, ipairs, tinsert = pairs, ipairs, tinsert;
local UnitName, GetMultiCastTotemSpells, GetSpellInfo, GetTotemInfo = UnitName, GetMultiCastTotemSpells, GetSpellInfo, GetTotemInfo;


-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the test unit/types.
LibAura:RegisterModuleSource(Module, "player", "TOTEM");

-- Cache of all posible totems separated by totem type. The totems are
-- indexed by SpellId.
Module.TotemSpells = {{}, {}, {}, {}};


-----------------------------------------------------------------
-- Function Enable
-----------------------------------------------------------------
function Module:Enable()

  -- For the sake of ppl that wining about addon memory... We create the db table when we are getting enabled.

  -- Internal db used for storing auras.
  self.db = {
    [1] = {
      Id = "PlayerTOTEM1",
      Active = false, -- Used internaly to see if its an active totem.
      Type = "TOTEM",
      Index = 1,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      Count = 0,
      ItemId = 0,
    },
    [2] = {
      Id = "PlayerTOTEM2",
      Active = false, -- Used internaly to see if its an active totem.
      Type = "TOTEM",
      Index = 2,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      Count = 0,
      ItemId = 0,
    },
    [3] = {
      Id = "PlayerTOTEM3",
      Active = false, -- Used internaly to see if its an active totem.
      Type = "TOTEM",
      Index = 3,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      Count = 0,
      ItemId = 0,
    },
    [4] = {
      Id = "PlayerTOTEM4",
      Active = false, -- Used internaly to see if its an active totem.
      Type = "TOTEM",
      Index = 4,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      Count = 0,
      ItemId = 0,
    },
  };

end



-----------------------------------------------------------------
-- Function Disable
-----------------------------------------------------------------
function Module:Disable()

  self.db = nil;

end


-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return;
  end
  
  -- We only support Type "TOTEM".
  if Type ~= "TOTEM" then
    return;
  end
  
  LibAura:RegisterEvent("PLAYER_TOTEM_UPDATE", self, self.Update);
  LibAura:RegisterEvent("SPELLS_CHANGED", self, self.Update);
  
  self:UpdateTotemSpells();
  
  self:Update();
  
end

-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return;
  end
  
  -- We only support Type "TOTEM".
  if Type ~= "TOTEM" then
    return;
  end
  
  for _, Aura in ipairs(self.db) do
  
    if Aura.Active == true then
      LibAura:FireAuraOld(Aura);
      Aura.Active = false;
    end
  
  end
  
  LibAura:UnregisterEvent("PLAYER_TOTEM_UPDATE", self, self.Update);
  LibAura:UnregisterEvent("SPELLS_CHANGED", self, self.Update);

end

-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return {};
  end
  
  -- We only support Type "TOTEM".
  if Type ~= "TOTEM" then
    return {};
  end
  
  local Auras = {};
  
  for _, Aura in ipairs(self.db) do
  
    if Aura.Active == true then
      tinsert(Auras, Aura);
    end
  
  end

  return Auras;

end


-----------------------------------------------------------------
-- Function UpdateTotemSpells
-----------------------------------------------------------------
function Module:UpdateTotemSpells()

  for i = 1, 4 do
  
    local Spells = {GetMultiCastTotemSpells(i)};
    
    for _, SpellId in ipairs(Spells) do
      
      local Name, _, Icon = GetSpellInfo(SpellId);
      
      self.TotemSpells[i][SpellId] = {Name = Name, Match = "^" .. Name, Icon = Icon};
      
    end
    
  end

end

-----------------------------------------------------------------
-- Function GetTotemId
-----------------------------------------------------------------
function Module:GetTotemId(Name, Slot)

  for SpellId, Info in pairs(self.TotemSpells[Slot]) do
  
    if Name:match(Info.Match) then
    
      return SpellId;
    
    end
  
  end
  
  return nil;

end

-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Module:Update()
  
  for i = 1, 4 do
  
    local Aura = self.db[i];
  
    local _, TotemName, StartTime, Duration = GetTotemInfo(i);
    
    if TotemName and TotemName ~= "" then
    
      if self.db[i].Active ~= true or Aura.TotemName ~= TotemName or Aura.ExpirationTime ~= (StartTime + Duration) then
      
        if Aura.Active == true then
          -- If we had an active totem, then fire aura old event before updating the aura.
          LibAura:FireAuraOld(Aura);
          Aura.Active = false;
        end
        
        local SpellId = self:GetTotemId(TotemName, i);
        
        if SpellId then
        
          Aura.TotemName = TotemName;
          Aura.ExpirationTime = StartTime + Duration;
          Aura.Duration = Duration;
          Aura.SpellId = self:GetTotemId(TotemName, i);
          Aura.Name = self.TotemSpells[i][Aura.SpellId].Name;
          Aura.Icon = self.TotemSpells[i][Aura.SpellId].Icon;
          Aura.Active = true;
          
          LibAura:FireAuraNew(Aura);
          
        end
        
      end
    
    elseif Aura.Active == true then
    
      Aura.Active = false;
      LibAura:FireAuraOld(Aura);
    
    end
  
  end

end


