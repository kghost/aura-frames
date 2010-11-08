-----------------------------------------------------------------
--
--  File: UnitAuras.lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--
--
-----------------------------------------------------------------


--[[ Some notes about this library

Blizzard unit aura order:

  The Blizzard aura order is simple, the last aura a unit gains will be added to the
  end of the list. This order can be changed by a ui reload or a zone transfer. To
  make it as fast as posible, we dont scan the whole list but we compare the Blizzard
  list with the internal list by walking thru both lists at the same time.


Duplicated auras:

  We use the following as the uniq id for an aura: Unit+SpellId+ExpireTime, but that is
  not always uniq (most commen example is the proc from Trauma). We can extend the uniq
  id by using a follow up number or something, but overall we are not interested to see
  2 or more auras that are the same. So we are consolidating those buffs into 1 single
  aura.


Aura object pool:

  We use a pool for unused aura tables. The memory garbage is way bigger from this library
  then you would expect (600 KB in 2 minutes with an warlock at the training dummies with
  only player helpful buffs enabled). Because we are going to reuse aura tables, the
  interested parties should never use an aura table after the AuraOld() event. If an party
  still want to use an old aura after the AuraOld event, then they should make an copy of
  the aura table so we can reuse the aura table without having any references to it outside
  the lib.

  This pool doesnt need to contain all the unused aura tables, its only used for the mass
  to reduce the memory garbage. If there are aura tables that are released without added
  back to the pool then the garbage collector will deal with them in time.


Mouseover unit:

  The mouseover unit is different from all other units in that we do not receive an UNIT_AURA
  event when the mouse leaves a unit. To support mouseover just like all the other units we
  are checking the mouseover unit when we got a UNIT_AURA for mouseover every 0.2 seconds
  until the mouseover until is nil. When the mouseover unit is nil, we trigger an old event
  for all auras we had for the mouseover.


]]--


local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "UnitAuras-1.0", 0;
local Module = LibAura:NewModule(Major, Minor);

if not Module then return; end -- No upgrade needed.


-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;
local UnitAura, UnitName = UnitAura, UnitName;


-----------------------------------------------------------------
-- EventsToMonitor
-----------------------------------------------------------------
Module.EventsToMonitor = {
  focus         = {"UNIT_AURA", "PLAYER_FOCUS_CHANGED"},
  focustarget   = {"UNIT_AURA", "PLAYER_FOCUS_CHANGED", "UNIT_TARGET"},
  player        = {"UNIT_AURA"},
  pet           = {"UNIT_AURA", "UNIT_PET"},
  pettarget     = {"UNIT_AURA", "UNIT_PET", "UNIT_TARGET"},
  vehicle       = {"UNIT_AURA", "UNIT_ENTERED_VEHICLE"},
  vehicletarget = {"UNIT_AURA", "UNIT_ENTERED_VEHICLE", "UNIT_TARGET"},
  target        = {"UNIT_AURA", "PLAYER_TARGET_CHANGED"},
  targettarget  = {"UNIT_AURA", "PLAYER_TARGET_CHANGED", "UNIT_TARGET"},
  mouseover     = {"UNIT_AURA", "UPDATE_MOUSEOVER_UNIT"}
};

for i = 1, 4 do
  Module.EventsToMonitor["party"..i]           = {"UNIT_AURA", "PARTY_MEMBERS_CHANGED"};
  Module.EventsToMonitor["party"..i.."target"] = {"UNIT_AURA", "UNIT_TARGET", "PARTY_MEMBERS_CHANGED"};
  Module.EventsToMonitor["partypet"..i]        = {"UNIT_AURA", "UNIT_PET", "PARTY_MEMBERS_CHANGED"};
  Module.EventsToMonitor["arena"..i]           = {"UNIT_AURA", "ARENA_OPPONENT_UPDATE"};
  Module.EventsToMonitor["arena"..i.."target"] = {"UNIT_AURA", "ARENA_OPPONENT_UPDATE", "UNIT_TARGET"};
end

for i = 1, 40 do
  Module.EventsToMonitor["raid"..i]            = {"UNIT_AURA", "RAID_ROSTER_UPDATE"};
  Module.EventsToMonitor["raid"..i.."target"]  = {"UNIT_AURA", "RAID_ROSTER_UPDATE"};
  Module.EventsToMonitor["raidpet"..i]         = {"UNIT_AURA", "UNIT_PET", "RAID_ROSTER_UPDATE"};
end


local AuraPool =  {};

-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the test unit/types.
for Unit, _ in pairs(Module.EventsToMonitor) do

  LibAura:RegisterModuleSource(Module, Unit, "HELPFUL");
  LibAura:RegisterModuleSource(Module, Unit, "HARMFUL");

end


-- How fast we detect mouseout
local MouseoutScanPeriod = 0.2;
local TimeSinceLastMouseoutScan = 0.0;

-- Internal db used for storing auras.
Module.db = Module.db or {};


-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  if not Module.EventsToMonitor[Unit] then
    return;
  end
  
  if Type ~= "HELPFUL" and Type ~= "HARMFUL" then
    return;
  end
  
  if next(self.db) == nil then
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ScanAllUnits");
    self:RegisterEvent("ZONE_CHANGED", "ScanAllUnits");
  end
  
  if not self.db[Unit] then
  
    self.db[Unit] = {[Type] = {}};
    
    for _, Event in ipairs(Module.EventsToMonitor[Unit]) do
      self:RegisterEvent(Event, Event);
    end
    
    if Unit == "mouseover" then
      self:RegisterEvent("LIBAURA_UPDATE", "UPDATE_MOUSEOVER_UNIT");
    end
    
  elseif not self.db[Unit][Type] then

    self.db[Unit][Type] = {};

  end

  self:ScanUnit(Unit);

end

-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)

  if not self.db[Unit] then
    return;
  end
  
  if not self.db[Unit][Type] then
    return;
  end
  
  for _, Aura in ipairs(self.db[Unit][Type]) do
    LibAura:FireAuraOld(Aura);
  end
  
  self.db[Unit][Type] = nil;
  
  if next(self.db[Unit]) == nil then
  
    self.db[Unit] = nil;
    
    for _, Event in ipairs(Module.EventsToMonitor[Unit]) do
      self:UnregisterEvent(Event, Event);
    end
    
    if Unit == "mouseover" then
      self:UnregisterEvent("LIBAURA_UPDATE", "UPDATE_MOUSEOVER_UNIT");
    end
  
  end
  
  if next(self.db) == nil then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD", "ScanAllUnits");
    self:UnregisterEvent("ZONE_CHANGED", "ScanAllUnits");
  end

end

-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  if not self.db[Unit] then
    return {};
  end
  
  if not self.db[Unit][Type] then
    return {};
  end

  return self.db[Unit][Type];

end


-----------------------------------------------------------------
-- Event Handlers
-----------------------------------------------------------------
function Module:UNIT_AURA(Unit)
  Module:ScanUnitChanges(Unit);
end

function Module:PARTY_MEMBERS_CHANGED()
  for i = 1, 4 do
    Module:ScanUnit("party"..i);
    Module:ScanUnit("party"..i.."pet");
    Module:ScanUnit("party"..i.."target");
  end
end

function Module:PLAYER_FOCUS_CHANGED()
  Module:ScanUnit("focus");
  Module:ScanUnit("focustarget");
end

function Module:PLAYER_TARGET_CHANGED()
  Module:ScanUnit("target");
  Module:ScanUnit("targettarget");
end

function Module:RAID_ROSTER_UPDATE()
  for i = 1, 40 do
    Module:ScanUnit("raid"..i);
    Module:ScanUnit("raid"..i.."pet");
    Module:ScanUnit("raid"..i.."target");
  end
end

function Module:UNIT_ENTERED_VEHICLE(Unit)
  if Unit == "player" then
    Module:ScanUnit("vehicle");
  end
end

function Module:UNIT_PET(Unit)
  Module:ScanUnit(Unit.."pet");
end

function Module:UNIT_TARGET(Unit)
  Module:ScanUnit(Unit.."target");
end

function Module:UPDATE_MOUSEOVER_UNIT()
  Module:ScanUnit("mouseover");
end

function Module:PLAYER_ENTERING_WORLD()
  Module:ScanAllUnits();
end

function Module:ZONE_CHANGED()
  Module:ScanAllUnits();
end


-----------------------------------------------------------------
-- Function ScanUnit
-----------------------------------------------------------------
function Module:ScanUnit(Unit)

  if self.db[Unit] then
    for Type, _ in pairs(self.db[Unit]) do
      self:ScanUnitAuras(Unit, Type);
    end
  end

end


-----------------------------------------------------------------
-- Function ScanUnitChanges
-----------------------------------------------------------------
function Module:ScanUnitChanges(Unit)
  
  if self.db[Unit] then
    for Type, _ in pairs(self.db[Unit]) do
      self:ScanUnitAurasChanges(Unit, Type);
    end
  end

end


-----------------------------------------------------------------
-- Function ScanAllUnits
-----------------------------------------------------------------
function Module:ScanAllUnits()

  for Unit, _ in pairs(self.db) do
    for Type, _ in pairs(self.db[Unit]) do
      self:ScanUnitAuras(Unit, Type);
    end
  end

end


-----------------------------------------------------------------
-- Function ScanUnitAurasChanges
-----------------------------------------------------------------
function Module:ScanUnitAurasChanges(Unit, Type)

  --[[
  
    To make sure we scan the auras as quick as posible we will make the following assumptions:
    
    - Blizzard will put new auras always at the end of the list
    - The order of the list will not change
    - On reloads or on zone transfer the order can change
    
    We will have 2 lists, 1 of the new/current auras and 1 of the last scan. We will loop thro the
    blizz list and the last scan list at the same , while we are not at the end of last scan we
    can say that every buff in blizz that doesnt match last scan is a removed aura and we will find the
    blizz aura futher in the last scan. At the end of the last scan list, all auras in the blizz list are
    new.
  
  ]]--
  
  
  local Auras = self.db[Unit][Type];
  local i, j = 1, 1; -- i is the index of the blizz auras, j is the index of the last scan.

  while true do

    local Name, _, Icon, Count, Classification, Duration, ExpirationTime, CasterUnit, IsStealable, _, SpellId = UnitAura(Unit, i, Type);

    -- Break out of the while when we are at the end of the list.
    if not Name then break end;
    
    if i > #Auras then -- new aura
    
      local Id = Unit..Name..ExpirationTime;
      
      for u = j - 1, 1, -1 do
      
        if Auras[u] and Auras[u].Id == Id then
          Id = nil;
          break;
        end
      
      end
      
      if Id then
      
        -- Pop an aura table out the pool or create an new one.
        local Aura = tremove(AuraPool) or {};
        
        Aura.Type = Type;
        Aura.Index = i;
        Aura.Unit = Unit;
        Aura.Name = Name;
        Aura.Icon = Icon;
        Aura.Count = Count;
        Aura.Classification = Classification or "None";
        Aura.Duration = Duration or 0;
        Aura.ExpirationTime = ExpirationTime;
        Aura.CasterUnit = CasterUnit;
        Aura.CasterName = CasterUnit and UnitName(CasterUnit);
        Aura.IsStealable = IsStealable == 1 and true or false;
        Aura.IsCancelable = false;
        Aura.IsDispellable = false;
        Aura.SpellId = SpellId;
        Aura.Id = Id;
        
        tinsert(Auras, Aura);
        
        LibAura:FireAuraNew(Aura);
        
        j = i + 1;
        
      end
      
      i = i + 1;
    
    elseif Auras[j].Name ~= Name or Auras[j].CasterUnit ~= CasterUnit or Auras[j].ExpirationTime ~= ExpirationTime then -- removed aura
    
      Auras[j].Index = 0;
      
      LibAura:FireAuraOld(Auras[j]);
      
      -- Release the old aura table in the pool for later use.
      tinsert(AuraPool, tremove(Auras, j));
    
    else -- Same aura, but can be changed.
    
      Auras[j].Index = i;
      
      if (Auras[j].Count ~= Count) then
        
        Auras[j].Count = Count;
        
        LibAura:FireAuraChanged(Auras[j]);
        
      end
      
      i = i + 1;
      j = j + 1;
    
    end
    
  end
  
  -- Everything that is not checked in the last scan are old auras
  
  while true do
  
    -- We remove everytime the last aura in the list so lua dont have to shift the remaining auras in the list.

    if j >= #Auras + 1 then break end;
    
    local Aura = tremove(Auras);
    
    Aura.Index = 0;
    
    LibAura:FireAuraOld(Aura);
    
    -- Release the old aura table in the pool for later use.
    tinsert(AuraPool, Aura);
    
  end

end


-----------------------------------------------------------------
-- Function ScanUnitAuras
-----------------------------------------------------------------
function Module:ScanUnitAuras(Unit, Type)

  --[[

    Same functionality as Module:ScanUnitAurasChanges but this function will scan it on a slow way.
    This function will be called on zone transfer and other moments where the aura order can
    be changed.

    Also for debug, this function can be called to see if the Module:ScanPlayer found all
    the changes (this function shouldnt report any old/new auras after Module:ScanPlayer)

  ]]--
  
  local Auras = self.db[Unit][Type];
  local j;
  
  for j = 1, #Auras do
    Auras[j].Scanned = false;
  end

  local i = 1;

  while true do

    local Name, _, Icon, Count, Classification, Duration, ExpirationTime, CasterUnit, IsStealable, _, SpellId = UnitAura(Unit, i, Type);
    
    if not Name then break end;
    
    local Found = false;
    
    for j = 1, #Auras do
    
      if Auras[j].Name == Name and Auras[j].CasterUnit == CasterUnit and Auras[j].ExpirationTime == ExpirationTime then
        
        Found = true;
        Auras[j].Scanned = true;
        Auras[j].Index = i;
        
        if (Auras[j].Count ~= Count) then
          
          Auras[j].Count = Count;
          
          LibAura:FireAuraChanged(Auras[j]);
          
        end
        
        break;
        
      end
    
    end
    
    if Found == false then -- New aura

      local Id = Unit..Name..ExpirationTime;
      
      for j = 1, #Auras do
      
        if Auras[j] and Auras[j].Id == Id then
          Id = nil;
          break;
        end
      
      end

      if Id then

        -- Pop an aura table out the pool or create an new one.
        local Aura = tremove(AuraPool) or {};
        
        Aura.Type = Type;
        Aura.Index = i;
        Aura.Unit = Unit;
        Aura.Name = Name;
        Aura.Icon = Icon;
        Aura.Count = Count;
        Aura.Classification = Classification or "None";
        Aura.Duration = Duration or 0;
        Aura.ExpirationTime = ExpirationTime;
        Aura.CasterUnit = CasterUnit;
        Aura.CasterName = CasterUnit and UnitName(CasterUnit);
        Aura.IsStealable = IsStealable == 1 and true or false;
        Aura.IsCancelable = false;
        Aura.IsDispellable = false;
        Aura.SpellId = SpellId;
        Aura.Id = Id;
        Aura.Scanned = true;
        
        tinsert(Auras, Aura);
        
        LibAura:FireAuraNew(Aura);
        
      end
      
    end
    
    i = i + 1;
    
  end
  
  j = 1;
  
  while true do
  
    if j >= #Auras + 1 then break end;
  
    if Auras[j].Scanned == false then -- Old aura
    
      Auras[j].Index = 0;
      
      LibAura:FireAuraOld(Auras[j]);

      -- Release the old aura table in the pool for later use.
      tinsert(AuraPool, tremove(Auras, j));
      
    else
    
      j = j + 1;
    
    end
    
  end
  
end
