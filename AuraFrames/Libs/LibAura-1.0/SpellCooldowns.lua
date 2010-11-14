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

-- Register the test unit/types.
LibAura:RegisterModuleSource(Module, "player", "SPELLCOOLDOWN");
LibAura:RegisterModuleSource(Module, "pet", "SPELLCOOLDOWN");


-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, GetSpellBookItemInfo, UnitName, GetSpellInfo, GetSpellCooldown = GetTime, GetSpellBookItemInfo, UnitName, GetSpellInfo, GetSpellCooldown;

-- Internal db used for storing auras, spellbooks and spell history.
Module.db = Module.db or {};

-- Number of spells to keep in the history list.
local SpellMaxHistory = 5;

-- The minimum duration of a spell cooldown
local SpellMinimumCooldown = 2;

-- Mapping type for booktypes.
local BookType = {
  player  = BOOKTYPE_SPELL,
  pet     = BOOKTYPE_PET,
};

-- Update spell book throttle.
local SpellBookLastScan = nil;
local SpellBookScanThrottle = 1.0;

-- Update cooldowns throttle.
local UpdateCooldownsLastScan = nil;
UpdateCooldownsScanThrottle = 0.2;


-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  -- We only support Unit "player" and "pet".
  if Unit ~= "player" and Unit ~= "pet" then
    return;
  end
  
  -- We only support Type "SPELLCOOLDOWN".
  if Type ~= "SPELLCOOLDOWN" then
    return;
  end
  
  if next(self.db) == nil then
  
    LibAura:RegisterEvent("SPELLS_CHANGED", self, self.TriggerUpdateAllSpellBooks);
    LibAura:RegisterEvent("PLAYER_ENTERING_WORLD", self, self.TriggerUpdateAllSpellBooks);
    LibAura:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self, self.SpellCasted);
    LibAura:RegisterEvent("SPELL_UPDATE_USABLE", self, self.TriggerUpdateCooldowns);
    LibAura:RegisterEvent("UNIT_SPELLCAST_FAILED", self, self.SpellCastFailed);
    LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.ScanAllSpellCooldowns);
    LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.Update);
  
  end
  
  if self.db[Unit] then
    return;
  end
  
  -- Setup the db for the unit.
  self.db[Unit] = {
    Book = {},
    History = {},
    Auras = {},
  };
  
  -- Fill unit spellbook.
  self:UpdateSpellBook(Unit);
  
end


-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)

  if not self.db[Unit] then
    return;
  end
  
  -- We only support Type "SPELLCOOLDOWN".
  if Type ~= "SPELLCOOLDOWN" then
    return;
  end
  
  for _, Aura in ipairs(self.db[Unit].Auras) do
    LibAura:FireAuraOld(Aura);
    Aura.Active = false;
  end
  
  self.db[Unit] = nil;
  
  if next(self.db) == nil then
  
    LibAura:UnregisterEvent("SPELLS_CHANGED", self, self.TriggerUpdateAllSpellBooks);
    LibAura:UnregisterEvent("PLAYER_ENTERING_WORLD", self, self.TriggerUpdateAllSpellBooks);
    LibAura:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self, self.SpellCasted);
    LibAura:UnregisterEvent("SPELL_UPDATE_USABLE", self, self.TriggerUpdateCooldowns);
    LibAura:UnregisterEvent("UNIT_SPELLCAST_FAILED", self, self.SpellCastFailed);
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.ScanAllSpellCooldowns);
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.Update);

  end

end


-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  -- We only support Unit "player" and "pet".
  if Unit ~= "player" and Unit ~= "pet" then
    return {};
  end
  
  -- We only support Type "SPELLCOOLDOWN".
  if Type ~= "SPELLCOOLDOWN" then
    return {};
  end
  
  return self.db[Unit].Auras;

end

-----------------------------------------------------------------
-- Function TriggerUpdateAllSpellBooks
-----------------------------------------------------------------
function Module:TriggerUpdateAllSpellBooks()

  -- We reset the throttle here.
  SpellBookLastScan = 0;

end


-----------------------------------------------------------------
-- Function TriggerUpdateCooldowns
-----------------------------------------------------------------
function Module:TriggerUpdateCooldowns()

  -- We don't reset the throttle here, only activate it if it isnt active.
  UpdateCooldownsLastScan = UpdateCooldownsLastScan or 0;

end


-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Module:Update(Elapsed)

  if SpellBookLastScan ~= nil then
  
    SpellBookLastScan = SpellBookLastScan + Elapsed;
    
    if SpellBookLastScan > SpellBookScanThrottle then
      
      SpellBookLastScan = nil;
      self:UpdateAllSpellBooks();
    
    end
  
  end
  
  if UpdateCooldownsLastScan ~= nil then
  
    UpdateCooldownsLastScan = UpdateCooldownsLastScan + Elapsed;
    
    if UpdateCooldownsLastScan > UpdateCooldownsScanThrottle then
    
      UpdateCooldownsLastScan = nil;
      self:ScanAllSpellBooksForCooldowns();
    
    end
  
  end

end


-----------------------------------------------------------------
-- Function UpdateAllSpellBooks
-----------------------------------------------------------------
function Module:UpdateAllSpellBooks()

  for Unit, _ in pairs(self.db) do
    self:UpdateSpellBook(Unit);
  end

end


-----------------------------------------------------------------
-- Function UpdateSpellBook
-----------------------------------------------------------------
function Module:UpdateSpellBook(Unit)

  for _, Aura in pairs(self.db[Unit].Book) do
    Aura.Old = true;
  end

  local i = 1
  while true do

    local _, SpellId = GetSpellBookItemInfo(i, BookType[Unit]);

    if not SpellId then
      break;
    end

    if not self.db[Unit].Book[SpellId] then
      self.db[Unit].Book[SpellId] = {
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
      };
    end

    local Aura = self.db[Unit].Book[SpellId];

    Aura.Index = i;
    Aura.Name, _, Aura.Icon = GetSpellInfo(SpellId);
    Aura.SpellId = SpellId;
    Aura.Id = Unit.."SPELLCOOLDOWN"..SpellId;
    Aura.Old = nil;
    
    if Aura.Active == false then
    
      local Start, Duration, Active = GetSpellCooldown(Aura.SpellId);
      
      if Active == 1 and Start > 0 and Duration > SpellMinimumCooldown then

        Aura.Duration = Duration;
        Aura.ExpirationTime = Start + Duration;
        Aura.Active = true;
        
        LibAura:FireAuraNew(Aura);
        
        tinsert(self.db[Unit].Auras, Aura);
      
      end
    
    end
    
    i = i + 1
  end
  
  for SpellId, Aura in pairs(self.db[Unit].Book) do
    if Aura.Old == true then
      Aura.Old = nil;
      self.db[Unit].Book[SpellId] = nil;
      if Aura.Active == true then
        LibAura:FireAuraOld(Aura);
        Aura.Active = false;
      end
    end
  end

end


-----------------------------------------------------------------
-- Function ScanAllSpellBooksForCooldowns
-----------------------------------------------------------------
function Module:ScanAllSpellBooksForCooldowns()
  
  for _, UnitDb in pairs(self.db) do
  
    for SpellId, Aura in pairs(UnitDb.Book) do
    
      if Aura.Active ~= true then
      
        local Start, Duration, Active = GetSpellCooldown(SpellId);
        
        if Active == 1 and Start > 0 and Duration > SpellMinimumCooldown then
        
          Aura.Duration = Duration;
          Aura.ExpirationTime = Start + Duration;
          Aura.Active = true;
          LibAura:FireAuraNew(Aura);
          tinsert(UnitDb.Auras, Aura);
          
        end
      
      end
    
    end
    
  end
  
end


-----------------------------------------------------------------
-- Function ScanAllSpellCooldowns
-----------------------------------------------------------------
function Module:ScanAllSpellCooldowns()
  
  local CurrentTime = GetTime();
  
  for Unit, UnitDb in pairs(self.db) do
  
    for i = #UnitDb.Auras, 1, -1 do
    
      local Start, Duration, Active = GetSpellCooldown(UnitDb.Auras[i].SpellId);
      local UnderMin = Start + Duration < CurrentTime + 1.5;
      
      if (Active ~= 1 or Duration == 0) or (UnderMin == true and UnitDb.Auras[i].ExpirationTime < CurrentTime) then
      
        -- if the cooldown it not active or when we have lesser then
        -- "UnderMin" left and we are passed the last ExpirationTime
        -- then deactive it.
      
        if UnitDb.Auras[i].Active == true then
          LibAura:FireAuraOld(UnitDb.Auras[i]);
          UnitDb.Auras[i].Active = false;
        end
        
        tremove(UnitDb.Auras, i);
      
      elseif UnderMin == false then
      
        -- We update only the cooldown when a minimum of "UnderMin"
        -- is still left. This to prevent the gcd to bump the spell cd.
      
        UnitDb.Auras[i].ExpirationTime = Start + Duration;
      
      end
      
    end
    
    Module:ScanSpellCooldowns(Unit);
    
  end

end


-----------------------------------------------------------------
-- Function ScanSpellCooldowns
-----------------------------------------------------------------
function Module:ScanSpellCooldowns(Unit)

  local i = 1;

  while true do
  
    if i > #self.db[Unit].History then
      break;
    end
    
    local Start, Duration, Active = GetSpellCooldown(self.db[Unit].History[i]);
    
    if Active == 1 and Start > 0 and Duration > SpellMinimumCooldown then
    
      local Aura = self.db[Unit].Book[self.db[Unit].History[i]];

      tremove(self.db[Unit].History, i);
      
      -- We can have an nil aura (profession cooldown that are not in the spell books).
      
      if Aura then
      
        Aura.Duration = Duration;
        Aura.ExpirationTime = Start + Duration;
        
        if Aura.Active == false then
        
          Aura.Active = true;
          LibAura:FireAuraNew(Aura);
          tinsert(self.db[Unit].Auras, Aura);
          
        end
      
      end
      
    else
    
      i = i + 1;
    
    end
    
  end

end


-----------------------------------------------------------------
-- Function SpellCasted
-----------------------------------------------------------------
function Module:SpellCasted(Unit, _, _, _, SpellId)

  if not self.db[Unit] then
    return;
  end
  
  tinsert(self.db[Unit].History, SpellId);

  if #self.db[Unit].History > SpellMaxHistory then
    tremove(self.db[Unit].History, 1);
  end

end

-----------------------------------------------------------------
-- Function SpellCastFailed
-----------------------------------------------------------------
function Module:SpellCastFailed(Unit, _, _, _, SpellId)

  if not self.db[Unit] then
    return;
  end
  
  if self.db[Unit].Book[SpellId] and self.db[Unit].Book[SpellId].Active == true then
  
    LibAura:FireAuraChanged(self.db[Unit].Book[SpellId]);
  
  end

end
