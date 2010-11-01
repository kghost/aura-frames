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


-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;


-- Internal db used for storing auras, spellbooks and spell history.
Module.db = Module.db or {};

-- Number of spells to keep in the history list.
local SpellMaxHistory = 3;

-- Mapping type for booktypes.
local BookType = {
  player  = BOOKTYPE_SPELL,
  pet     = BOOKTYPE_PET,
};


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
  
    LibAura:RegisterEvent("SPELLS_CHANGED", self, self.UpdateAllSpellBooks);
    LibAura:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self, self.SpellCasted);
    LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.ScanAllSpellCooldowns);
  
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
  end
  
  self.db[Unit] = nil;
  
  if next(self.db) == nil then
  
    LibAura:UnregisterEvent("SPELLS_CHANGED", self, self.UpdateAllSpellBooks);
    LibAura:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", self, self.SpellCasted);
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.ScanAllSpellCooldowns);

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
      do break end
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
      };
    end

    local Aura = self.db[Unit].Book[SpellId];

    Aura.Index = i;
    Aura.Name, _, Aura.Icon = GetSpellInfo(SpellId);
    Aura.SpellId = SpellId;
    Aura.Id = Unit.."SPELLCOOLDOWN"..Aura.Name;
    Aura.Old = nil;
    
    i = i + 1
  end

  for SpellId, Aura in pairs(self.db[Unit].Book) do
    if Aura.Old == true then
      Aura.Old = nil;
      self.db[Unit].Book[SpellId] = nil;
    end
  end

end


-----------------------------------------------------------------
-- Function ScanAllSpellCooldowns
-----------------------------------------------------------------
function Module:ScanAllSpellCooldowns()

  local CurrentTime = GetTime();
  
  for _, db in pairs(self.db) do
  
    local i = 1;
    
    while db.Auras[i] do
    
      local Start, Duration, Active = GetSpellCooldown(db.Auras[i].SpellId);
      
      db.Auras[i].ExpirationTime = Start + Duration;
    
      if Active ~= 1 or db.Auras[i].ExpirationTime <= CurrentTime then
      
        LibAura:FireAuraOld(db.Auras[i]);
        tremove(db.Auras, i);
      
      else
      
        i = i + 1;
      
      end
      
    end
    
  end

  for Unit, _ in pairs(self.db) do
    Module:ScanSpellCooldowns(Unit);
  end

end


-----------------------------------------------------------------
-- Function ScanSpellCooldowns
-----------------------------------------------------------------
function Module:ScanSpellCooldowns(Unit)

  i = 1;

  while true do
  
    if i > #self.db[Unit].History then
      break;
    end
    
    local Start, Duration, Active = GetSpellCooldown(self.db[Unit].History[i]);
    
    if Active == 1 and Start > 0 and Duration > 3 then
    
    
      local Aura = self.db[Unit].Book[self.db[Unit].History[i]];

      tremove(self.db[Unit].History, i);
      
      -- We can have an nil aura (profession cooldown that are not in the spell books).
      
      if Aura then
      
        Aura.Duration = Duration;
        Aura.ExpirationTime = Start + Duration;
        
        LibAura:FireAuraNew(Aura);
        
        tinsert(self.db[Unit].Auras, Aura);
      
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
