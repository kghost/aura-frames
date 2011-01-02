-----------------------------------------------------------------
--
--  File: SpellCooldowns.lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--
--
-----------------------------------------------------------------


local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "SpellCooldowns-1.0", 0;
local Module = LibAura:NewModule(Major, Minor);

if not Module then return; end -- No upgrade needed.

-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the unit/types.
LibAura:RegisterModuleSource(Module, "player", "SPELLCOOLDOWN");
LibAura:RegisterModuleSource(Module, "pet", "SPELLCOOLDOWN");


-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort, tContains = tinsert, tremove, table.concat, sort, tContains;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, GetSpellBookItemInfo, UnitName, GetSpellInfo, GetSpellCooldown = GetTime, GetSpellBookItemInfo, UnitName, GetSpellInfo, GetSpellCooldown;
local abs = abs;

-- Internal db used for storing auras, spellbooks and spell history.
Module.db = Module.db or {};
Module.History = Module.History or {};

-- Number of spells to keep in the history list.
local SpellMaxHistory = 5;

-- The minimum duration of a spell cooldown
local SpellMinimumCooldown = 2;

-- The max difference between cooldowns for grouping.
local GroupDurationRange = 0.1;

-- Mapping type for booktypes.
local BookType = {
  player  = BOOKTYPE_SPELL,
  pet     = BOOKTYPE_PET,
};

-- Update spell book throttle.
local SpellBooksLastScan = nil;
local SpellBooksScanThrottle = 1.0;


-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  if next(self.db) == nil then
  
    LibAura:RegisterEvent("SPELLS_CHANGED", self, self.TriggerUpdateSpellBooks);
    LibAura:RegisterEvent("PLAYER_ENTERING_WORLD", self, self.TriggerUpdateSpellBooks);
    LibAura:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self, self.SpellCasted);
    LibAura:RegisterEvent("UNIT_SPELLCAST_FAILED", self, self.SpellCastFailed);
    LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.ScanAllSpellCooldowns);
    LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.Update);
  
  end
  
  if self.db[Unit] then
    return;
  end
  
  -- Setup the db for the unit.
  self.db[Unit] = {};
  self.History[Unit] = {};
  
  -- Fill unit spellbook.
  self:UpdateSpellBook(Unit);
  
end


-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)
  
  for _, Aura in ipairs(self.db[Unit]) do
    if Aura.Active == true then
      LibAura:FireAuraOld(Aura);
    end
  end
  
  self.db[Unit] = nil;
  self.History[Unit] = nil;
  
  if next(self.db) == nil then
  
    LibAura:UnregisterEvent("SPELLS_CHANGED", self, self.TriggerUpdateSpellBooks);
    LibAura:UnregisterEvent("PLAYER_ENTERING_WORLD", self, self.TriggerUpdateSpellBooks);
    LibAura:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self, self.SpellCasted);
    LibAura:UnregisterEvent("UNIT_SPELLCAST_FAILED", self, self.SpellCastFailed);
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.ScanAllSpellCooldowns);
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.Update);

  end

end


-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)
  
  -- This function is rarely called. So we also not try to optimize it.
  
  local Auras = {};
  
  for _, Aura in pairs(self.db[Unit]) do
  
    if Aura.Active == true and not Aura.RefSpellId then
      tinsert(Auras, Aura);
    end
  
  end
  
  return Auras;

end


-----------------------------------------------------------------
-- Function TriggerUpdateSpellBooks
-----------------------------------------------------------------
function Module:TriggerUpdateSpellBooks()

  -- We reset the throttle here.
  SpellBooksLastScan = 0;

end


-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Module:Update(Elapsed)

  if SpellBooksLastScan ~= nil then
  
    SpellBooksLastScan = SpellBooksLastScan + Elapsed;
    
    if SpellBooksLastScan > SpellBooksScanThrottle then
      
      SpellBooksLastScan = nil;

      for Unit, _ in pairs(self.db) do
        self:UpdateSpellBook(Unit);
      end
    
    end
  
  end
  
end


-----------------------------------------------------------------
-- Function UpdateSpellBook
-----------------------------------------------------------------
function Module:UpdateSpellBook(Unit)

  for _, Aura in pairs(self.db[Unit]) do
    Aura.Old = true;
  end

  local i = 1;
  
  while true do

    local _, SpellId = GetSpellBookItemInfo(i, BookType[Unit]);

    if not SpellId then
      break;
    end

    if not self.db[Unit][SpellId] then
    
      self.db[Unit][SpellId] = {
        Type = "SPELLCOOLDOWN",
        Count = 0,
        Classification = "None",
        Unit = Unit,
        CasterUnit = Unit,
        CasterName = UnitName(Unit),
        Duration = 0,
        ExpirationTime = 0,
        IsStealable = false,
        IsCancelable = false,
        IsDispellable = false,
        Active = false,
        Id = Unit.."SPELLCOOLDOWN"..SpellId,
        SpellId = SpellId,
        ItemId = 0,
      };
      
    end

    local Aura = self.db[Unit][SpellId];

    Aura.Index = i;
    Aura.Name, _, Aura.Icon = GetSpellInfo(SpellId);
    Aura.Old = nil;
    
    i = i + 1
    
  end
  
  for SpellId, Aura in pairs(self.db[Unit]) do
  
    if Aura.Old == true then
    
      if Aura.Active == true and not Aura.RefSpellId then
        LibAura:FireAuraOld(Aura);
      end

      self.db[Unit][SpellId] = nil;
    
    end
    
  end

end


-----------------------------------------------------------------
-- Function ScanAllSpellCooldowns
-----------------------------------------------------------------
function Module:ScanAllSpellCooldowns()
  
  local CurrentTime = GetTime();
  
  for Unit, _ in pairs(self.db) do
  
    local NewCooldowns = {};
  
    for SpellId, Aura in pairs(self.db[Unit]) do
    
      local Start, Duration, Active = GetSpellCooldown(SpellId);
      
      if Aura.Active == true then
        
        local UnderMin = Start + Duration < CurrentTime + 1.5;
        
        if (Active ~= 1 or Duration == 0) or (UnderMin == true and Aura.ExpirationTime < CurrentTime) then
        
          -- if the cooldown it not active or when we have lesser then
          -- "UnderMin" left and we are passed the last ExpirationTime
          -- then deactive it.
        
          if not Aura.RefSpellId then
            LibAura:FireAuraOld(Aura);
          end
          
          Aura.RefSpellId = nil;
          Aura.Active = false;
        
        elseif UnderMin == false then
        
          -- We update only the cooldown when a minimum of "UnderMin"
          -- is still left. This to prevent the gcd to bump the spell cd.
        
          Aura.ExpirationTime = Start + Duration;
        
        end
      
      else
      
        if Active == 1 and Start > 0 and Duration > SpellMinimumCooldown then
        
          Aura.Duration = Duration;
          Aura.ExpirationTime = Start + Duration;
          Aura.Active = true;
          
          tinsert(NewCooldowns, SpellId);
          
        end
      
      end
    
    end
    
    if #NewCooldowns == 0 then
      return;
    end
    
    local Groups = {};
    
    for _, SpellId in ipairs(NewCooldowns) do
    
      local Aura, HistoryIndex = self.db[Unit][SpellId], SpellMaxHistory + 1;
      
      -- Check if the new cooldown is located in the history.
      for Index, HistorySpellId in ipairs(self.History[Unit]) do
        
        if HistorySpellId == SpellId then
          HistoryIndex = Index;
          break;
        end
      
      end
      
      local GroupMatch = false;
      
      for _, Group in ipairs(Groups) do
        
        if abs(Group.Duration - Aura.Duration) < GroupDurationRange then -- Accept a small difference
        
          GroupMatch = true;
        
          tinsert(Group.SpellIds, SpellId);
          
          if Group.PrimaryIndex > HistoryIndex then
            Group.PrimaryIndex = HistoryIndex;
            Group.Primary = SpellId;
          end
          
          break;
          
        end
      
      end
      

      if GroupMatch == false then
      
        tinsert(Groups, {
          Duration = Aura.Duration,
          SpellIds = {SpellId},
          Primary = SpellId,
          PrimaryIndex = HistoryIndex,
        });
        
      end

    end
    
    
    
    for _, Group in ipairs(Groups) do
    
      for _, SpellId in ipairs(Group.SpellIds) do
      
        local Aura = self.db[Unit][SpellId];
        
        if SpellId == Group.Primary then
        
          LibAura:FireAuraNew(Aura);
        
        else
        
          Aura.RefSpellId = Group.Primary;
        
        end
      
      end
    
    end

  end
  
end


-----------------------------------------------------------------
-- Function SpellCasted
-----------------------------------------------------------------
function Module:SpellCasted(Unit, _, _, _, SpellId)

  if not self.History[Unit] then
    return;
  end
  
  tinsert(self.History[Unit], 1, SpellId);
  
  if #self.History[Unit] > SpellMaxHistory then
    tremove(self.History[Unit]);
  end

end


-----------------------------------------------------------------
-- Function SpellCastFailed
-----------------------------------------------------------------
function Module:SpellCastFailed(Unit, _, _, _, SpellId)

  if not self.db[Unit] or not self.db[Unit][SpellId] then
    return;
  end
  
  if self.db[Unit][SpellId].Active == true then
  
    if self.db[Unit][SpellId].RefSpellId then
    
      LibAura:FireAuraChanged(self.db[Unit][self.db[Unit][SpellId].RefSpellId]);
    
    else
  
      LibAura:FireAuraChanged(self.db[Unit][SpellId]);
    
    end
  
  end
  
end

