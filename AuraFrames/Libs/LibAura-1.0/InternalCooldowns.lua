-----------------------------------------------------------------
--
--  File: InternalCooldowns.lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--
--
-----------------------------------------------------------------

-- Support for internal cooldowns is currently disabled
if true then return; end;


local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "InternalCooldowns-1.0", 0;
local Module = LibAura:NewModule(Major, Minor);

if not Module then return; end -- No upgrade needed.

-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the test unit/types.
LibAura:RegisterModuleSource(Module, "player", "INTERNALCOOLDOWNITEM");
LibAura:RegisterModuleSource(Module, "player", "INTERNALCOOLDOWNTALENT");

-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, UnitName, GetItemInfo, GetSpellInfo = GetTime, UnitName, GetItemInfo, GetSpellInfo;

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: LibStub

-- Internal db used for storing auras, spellbooks and spell history.
Module.db = Module.db or {};

-- Pool used for storing unused auras.
local AuraPool = {};


-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return;
  end
  
  -- We only support Type "INTERNALCOOLDOWNITEM" and "INTERNALCOOLDOWNTALENT".
  if Type ~= "INTERNALCOOLDOWNITEM" and Type ~= "INTERNALCOOLDOWNTALENT"  then
    return;
  end
  
  self.ICD = self.ICD or LibStub("LibInternalCooldowns-1.0", true);
  
  -- No LibInternalCooldowns. Return :(
  if not self.ICD then
    return;
  end
  
  -- Lib CallbackHandler (that is used by ICD) will prevent double registrations.
  -- So no checks for that.
  
  if Type == "INTERNALCOOLDOWNITEM" then

    self.db.Items = self.db.Items or {};
    
    self.ICD.RegisterCallback(self, "InternalCooldowns_Proc");
    
  elseif Type == "INTERNALCOOLDOWNTALENT" then

    self.db.Talents = self.db.Talents or {};
    
    self.ICD.RegisterCallback(self, "InternalCooldowns_TalentProc");

  end
  
  LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.ScanCooldowns);
  
end


-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return;
  end
  
  -- We only support Type "INTERNALCOOLDOWNITEM" and "INTERNALCOOLDOWNTALENT".
  if Type ~= "INTERNALCOOLDOWNITEM" and Type ~= "INTERNALCOOLDOWNTALENT"  then
    return;
  end
  
  if not self.ICD then
    return;
  end
  
  if Type == "INTERNALCOOLDOWNITEM" then

    self.ICD.UnregisterCallback(self, "InternalCooldowns_Proc");
    
    for _, Aura in ipairs(self.db.Items) do
    
      LibAura:FireAuraOld(Aura);
    
    end
    
    self.db.Items = nil;

  elseif Type == "INTERNALCOOLDOWNTALENT" then

    self.ICD.UnregisterCallback(self, "InternalCooldowns_TalentProc");
    
    for _, Aura in ipairs(self.db.Talents) do
    
      LibAura:FireAuraOld(Aura);
    
    end
    
    self.db.Talents = nil;

  end
  
  if next(self.db) == nil then
    
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.ScanCooldowns);
    
  end

end

-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  -- We only support Unit "player".
  if Unit ~= "player" then
    return {};
  end
  
  if Type == "INTERNALCOOLDOWNITEM" then

    return self.db.Items or {};
    
  elseif Type == "INTERNALCOOLDOWNTALENT" then

    return self.db.Talents or {};
    
  else
  
    return {};
    
  end

end


-----------------------------------------------------------------
-- Function ScanCooldowns
-----------------------------------------------------------------
function Module:ScanCooldowns()

  local CurrentTime = GetTime();
  
  for _, Auras in pairs(self.db) do
  
    local i = 1;
    
    while Auras[i] do
    
      if Auras[i].ExpirationTime <= CurrentTime then
      
        LibAura:FireAuraOld(Auras[i]);
        tinsert(AuraPool, tremove(Auras, i));
      
      else
      
        i = i + 1;
      
      end
      
    end
    
  end

end

-----------------------------------------------------------------
-- Function InternalCooldowns_Proc
-----------------------------------------------------------------
function Module:InternalCooldowns_Proc(_, ItemId, SpellId, Start, Duration)

  local Aura = tremove(AuraPool);
  
  if not Aura then
  
    Aura = {
      Index = 0,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      Count = 0,
    };
  
  end
  
  Aura.Type = "INTERNALCOOLDOWNITEM";
  Aura.SpellId = SpellId;
  Aura.Name, _, _, _, _, _, _, _, _,  Aura.Icon, _ = GetItemInfo(ItemId);
  Aura.ExpirationTime = Start + Duration;
  Aura.Duration = Duration;
  
  Aura.Id = "playerINTERNALCOOLDOWNITEM"..ItemId..Aura.ExpirationTime;
  
  LibAura:FireAuraNew(Aura);
  
  tinsert(self.db.Items, Aura);

end


-----------------------------------------------------------------
-- Function InternalCooldowns_TalentProc
-----------------------------------------------------------------
function Module:InternalCooldowns_TalentProc(_, SpellId, Start, Duration)

  local Aura = tremove(AuraPool);
  
  if not Aura then
  
    Aura = {
      Index = 0,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      Count = 0,
    };
  
  end
  
  Aura.Type = "INTERNALCOOLDOWNITEM";
  Aura.SpellId = SpellId;
  Aura.Name, _, Aura.Icon, _, _, _, _, _, _ = GetSpellInfo(SpellId);
  Aura.ExpirationTime = Start + Duration;
  Aura.Duration = Duration;
  
  Aura.Id = "playerINTERNALCOOLDOWNTALENT"..SpellId..Aura.ExpirationTime;
  
  LibAura:FireAuraNew(Aura);

  tinsert(self.db.Talents, Aura);

end

