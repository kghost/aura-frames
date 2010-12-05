-----------------------------------------------------------------
--
--  File: ItemCooldowns.lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--
--
-----------------------------------------------------------------


local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "ItemCooldowns-1.0", 0;
local Module = LibAura:NewModule(Major, Minor);

if not Module then return; end -- No upgrade needed.

-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the unit/types.
LibAura:RegisterModuleSource(Module, "player", "ITEMCOOLDOWN");


-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetInventoryItemID, GetContainerNumSlots, GetContainerItemID = GetInventoryItemID, GetContainerNumSlots, GetContainerItemID;
local UnitName, GetItemInfo, GetTime, GetItemCooldown = UnitName, GetItemInfo, GetTime, GetItemCooldown;

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: NUM_BAG_SLOTS

-- Internal db used for storing auras, spellbooks and spell history.
Module.db = Module.db or {};


-- The minimum duration of a item cooldown
local ItemMinimumCooldown = 2;

-- Update cooldowns throttle.
local UpdateCooldownsLastScan = 0;
local UpdateCooldownsScanThrottle = 0.2;

-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return;
  end
  
  -- We only support Type "ITEMCOOLDOWN".
  if Type ~= "ITEMCOOLDOWN" then
    return;
  end
  
  self.db = {};
  
  -- Fill db.
  self:UpdateDb();
  
  -- First scan.
  self:CooldownUpdate();
  
  LibAura:RegisterEvent("BAG_UPDATE_COOLDOWN", self, self.CooldownUpdate);
  LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.Update);
  
end


-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)
  
  -- We only support Unit "player".
  if Unit ~= "player" then
    return;
  end
  
  -- We only support Type "ITEMCOOLDOWN".
  if Type ~= "ITEMCOOLDOWN" then
    return;
  end
  
  for _, Aura in pairs(self.db) do
    LibAura:FireAuraOld(Aura);
  end

  LibAura:UnregisterEvent("BAG_UPDATE_COOLDOWN", self, self.CooldownUpdate);
  LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.Update);

end


-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return {};
  end
  
  -- We only support Type "ITEMCOOLDOWN".
  if Type ~= "ITEMCOOLDOWN" then
    return {};
  end
  
  local Auras = {};
  
  for _, Aura in pairs(self.db) do
  
    if Aura.Active == true then
      tinsert(Auras, Aura);
    end
  
  end
  
  return Auras;

end


-----------------------------------------------------------------
-- Function UpdateDb
-----------------------------------------------------------------
function Module:UpdateDb()

  -- Scan equiped items.
  for i = 1, 17 do
    
    local ItemId = GetInventoryItemID("player", i);
    
    if ItemId then
      
      -- ItemId is nil for non equiped slots.
      self:UpdateDbItem(ItemId);
      
    end
    
  end
  
  -- Scan bag.
  for ContainerId = 0, NUM_BAG_SLOTS do
  
    for i = 1, GetContainerNumSlots(ContainerId) do
    
      local ItemId = GetContainerItemID(ContainerId, i)
    
      if ItemId then
        
        -- ItemId is nil for empty slots.
        self:UpdateDbItem(ItemId);
        
      end
    
    end
  
  end
  

end


-----------------------------------------------------------------
-- Function UpdateDbItem
-----------------------------------------------------------------
function Module:UpdateDbItem(ItemId)

  if self.db[ItemId] then
    return;
  end
  
  self.db[ItemId] = {
    Type = "ITEMCOOLDOWN",
    Count = 0,
    Classification = "None",
    Unit = "player",
    CasterUnit = "player",
    CasterName = UnitName("player"),
    Duration = 0,
    ExpirationTime = 0,
    IsStealable = false,
    IsCancelable = false,
    IsDispellable = false,
    Active = false,
    Index = ItemId,
    AuraId = "playerITEMCOOLDOWN"..ItemId,
    SpellId = 0,
    ItemId = ItemId,
    Active = false,
  };
  
  local _; -- Keep _ in the local namespace.
  
  self.db[ItemId].Name, _, _, _, _, _, _, _, _, self.db[ItemId].Icon = GetItemInfo(ItemId);
  
end

-----------------------------------------------------------------
-- Function CooldownUpdate
-----------------------------------------------------------------
function Module:CooldownUpdate()

  local CurrentTime = GetTime();

  for ItemId, Aura in pairs(self.db) do
  
    local Start, Duration, Active = GetItemCooldown(ItemId);
    
    if Active == 1 and Start > 0 then
    
      local UnderMin = Start + Duration < CurrentTime + 1.5;
      
      if UnderMin == false then
      
        -- We update only the cooldown when a minimum of "UnderMin"
        -- is still left. This to prevent the gcd to bump the item cd.
      
        Aura.Duration = Duration;
        Aura.ExpirationTime = Start + Duration;
      
      end
    
      if Duration > ItemMinimumCooldown then
    
        if Aura.Active == false then
        
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


-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Module:Update(Elapsed)

  UpdateCooldownsLastScan = UpdateCooldownsLastScan + Elapsed;
  
  if UpdateCooldownsLastScan > UpdateCooldownsScanThrottle then
  
    UpdateCooldownsLastScan = 0;
    
  else
  
    return;
  
  end

  local CurrentTime = GetTime();
  
  for ItemId, Aura in pairs(self.db) do
  
    if Aura.Active == true and Aura.ExpirationTime < CurrentTime then
    
      Aura.Active = false;
      LibAura:FireAuraOld(Aura);
    
    end
  
  end

end

