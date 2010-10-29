-----------------------------------------------------------------
--
--  File: TestUnit.Lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--    Implement a test unit which will have mulitple buffs and
--    debuffs that are refreshed and have stacks.
--
--    The test unit can be used for testing mode for example.
--
-----------------------------------------------------------------

local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "TestUnit-1.0", 0;
local Module = LibAura:NewModule(Major, Minor);

if not Module then return; end -- No upgrade needed.

-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the test unit/types.
LibAura:RegisterModuleSource(Module, "test", "HELPFUL");
LibAura:RegisterModuleSource(Module, "test", "HARMFUL");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- Internal db used for storing auras.
Module.db = Module.db or {};


-----------------------------------------------------------------
-- Function Enable
-----------------------------------------------------------------
function Module:Enable()

  -- For the sake of ppl that wining about addon memory... We create the test data table when we are getting enabled.
  
  -- [SpellId] = {Type, Classification, Duration, MaxStacks}
  self.TestData = self.TestData or {};
  self.TestData["HELPFUL"] = Module.TestData["HELPFUL"] or {};
  self.TestData["HARMFUL"] = Module.TestData["HARMFUL"] or {};

  self.TestData["HELPFUL"][28176] = {"Magic", 1800, 0}; -- Fel Armor
  self.TestData["HELPFUL"][21562] = {"Magic", 1800, 0}; -- Power Word: Fortitude
  self.TestData["HELPFUL"][ 1706] = {"None", 15, 0}; -- Levitate
  self.TestData["HELPFUL"][65007] = {"None", 10, 5}; -- Eye of the Broodmother

  self.TestData["HARMFUL"][ 7386] = {"None", 3, 5}; -- Sunder Armor
  self.TestData["HARMFUL"][  172] = {"Magic", 18, 0}; -- Corruption
  self.TestData["HARMFUL"][69127] = {"None", 0, 0}; -- Chill of the Throne
  self.TestData["HARMFUL"][59879] = {"Disease", 15, 0}; -- Blood Plague
  self.TestData["HARMFUL"][ 1978] = {"Poison", 15, 0}; -- Serpent Sting
  self.TestData["HARMFUL"][94009] = {"None", 15, 0}; -- Rend
  
  -- And no, no Module:Disabled. We even don't want to clean this up.
  
end

-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  -- We only support Unit "test".
  if Unit ~= "test" then
    return;
  end
  
  -- If we don't have test date for Type or if we are already active for Type then return.
  if not Module.TestData[Type] or self.db[Type] then
    return;
  end
  
  if next(self.db) == nil then
    LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.Update);
  end
  
  self.db[Type] = {};
  
  local CurrentTime = GetTime();
  
  for SpellId, Options in pairs(Module.TestData[Type]) do
  
    local Aura = {
      Index = 0,
      Type = Type,
      Unit = "test",
      SpellId = SpellId,
      Classification = Options[1],
      CasterUnit = "player";
      CasterName = UnitName("player");
      IsStealable = false,
      IsCancelable = false,
      IsDispellable = false,
      Duration = Options[3],
      ExpirationTime = (Options[2] ~= 0 and CurrentTime + Options[2]) or 0,
      Count = (Options[3] ~= 0 and 1) or 0;
    };
    
    Aura.Name, _, Aura.Icon = GetSpellInfo(SpellId);
    Aura.Id = Aura.Unit..Aura.Name..Aura.ExpirationTime;
    
    table.insert(self.db[Type], Aura);
    
    LibAura:FireAuraNew(Aura);
  
  end

end

-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)

  -- We only support Unit "test".
  if Unit ~= "test" then
    return;
  end
  
      
  if not self.db[Type] then
    return;
  end
  
  for _, Aura in ipairs(self.db[Type]) do

    LibAura:FireAuraOld(Aura);
  
  end
  
  self.db[Type] = nil;
  
  if next(self.db) == nil then
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.Update);
  end

end

-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  -- We only support Unit "test".
  if Unit ~= "test" then
    return {};
  end

  return self.db[Type] or {};

end


-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Module:Update()

  local CurrentTime = GetTime();
  
  for Type, _ in pairs(self.db) do
  
    for _, Aura in pairs(self.db[Type]) do
    
      if Aura.ExpirationTime ~= 0 and Aura.ExpirationTime <= CurrentTime then
        
        LibAura:FireAuraOld(Aura);
        
        Aura.ExpirationTime = CurrentTime + Module.TestData[Type][Aura.SpellId][2];
        
        if Module.TestData[Type][Aura.SpellId][3] ~= 0 then
        
          if Aura.Count == Module.TestData[Type][Aura.SpellId][3] then
            Aura.Count = 1;
          else
            Aura.Count = Aura.Count + 1;
          end
        
        end
        
        LibAura:FireAuraNew(Aura);
        
      end
    end
  
  end
  
end

