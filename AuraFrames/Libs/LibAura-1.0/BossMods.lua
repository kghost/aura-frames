-----------------------------------------------------------------
--
--  File: BossMods.lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--
--
-----------------------------------------------------------------


local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "BossMods-1.0", 0;
local Module = LibAura:NewModule(Major, Minor);

if not Module then return; end -- No upgrade needed.

-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the unit/types.
LibAura:RegisterModuleSource(Module, "boss", "ALERT");


-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;


-- Internal db used for storing auras, spellbooks and spell history.
Module.db = Module.db or {};

-- Pool used for recycling aura's.
Module.Pool = {};
local PoolSize = 5;


-----------------------------------------------------------------
-- Function ActivateSource
-----------------------------------------------------------------
function Module:ActivateSource(Unit, Type)

  if DBM then
    
    self.db.DBM = {};
    self.Pool.DBM = {};
    
    LibAura:RegisterEvent("LIBAURA_UPDATE", self, self.DBM_Scan);
    
  end
  
  if DXE then
  
    self.db.DXE = {};
    self.Pool.DXE = {};
  
    -- Hook DXE functions.
    
    self.DXE_Alerts = DXE:GetModule("Alerts");
    
    -- Save old functions.
    self.DXE_Alerts.DropdownHooked    = self.DXE_Alerts.Dropdown;
    self.DXE_Alerts.CenterPopupHooked = self.DXE_Alerts.CenterPopup;
    self.DXE_Alerts.SimpleHooked      = self.DXE_Alerts.Simple;
  
    -- Set new functions.
    self.DXE_Alerts.Dropdown     = self.DXE_Dropdown;
    self.DXE_Alerts.CenterPopup  = self.DXE_CenterPopup;
    self.DXE_Alerts.Simple       = self.DXE_Simple;
  
  end
  
end


-----------------------------------------------------------------
-- Function DeactivateSource
-----------------------------------------------------------------
function Module:DeactivateSource(Unit, Type)
  
  if DBM then
  
    LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.DBM_Scan);

    for _, Aura in pairs(self.db.DBM) do
      LibAura:FireAuraOld(Aura);
    end

  end

  if self.DXE_Alerts then
  
    -- Unhook DXE functions.
    
    -- Restore old functions.
    self.DXE_Alerts.Dropdown    = self.DXE_Alerts.DropdownHooked;
    self.DXE_Alerts.CenterPopup = self.DXE_Alerts.CenterPopupHooked;
    self.DXE_Alerts.Simple      = self.DXE_Alerts.SimpleHooked;
  
    -- Remove old functions.
    self.DXE_Alerts.DropdownHooked    = nil;
    self.DXE_Alerts.CenterPopupHooked = nil;
    self.DXE_Alerts.SimpleHooked      = nil;
  
  end

  self.db = {};
  self.Pool = {};

end


-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  return {};

end


-----------------------------------------------------------------
-- Function DBM_Scan
-----------------------------------------------------------------
function Module:DBM_Scan()

  if not DBM then
    return;
  end
  
  local db, CurrentTime = self.db.DBM, GetTime();
  
  for _, Aura in pairs(db) do
  
    Aura.Old = true;
  
  end

  for Bar in DBM.Bars:GetBarIterator() do
  
    local Name, Icon = _G[Bar.frame:GetName().."BarName"]:GetText(), _G[Bar.frame:GetName().."BarIcon1"]:GetTexture();
    
    if not Bar.dummy and Name and Icon then
    
      local Id = Name..Icon;
    
      if not db[Id] then
        
        db[Id] = tremove(self.Pool.DBM) or {
          Type = "ALERT",
          Count = 0,
          Classification = "None",
          Unit = "boss",
          CasterUnit = "player",
          CasterName = UnitName("player"),
          IsStealable = false,
          IsCancelable = false,
          IsDispellable = false,
          Index = 0,
          SpellId = 0,
          ItemId = 0,
          Duration = Bar.totalTime,
          ExpirationTime = CurrentTime + Bar.timer,
        };
        
        db[Id].Name = Name;
        db[Id].Icon = Icon;
        db[Id].Id = "bossALERT_DBM"..Id;
        
        LibAura:FireAuraNew(db[Id]);
      
      else
      
        db[Id].Duration = Bar.totalTime;
        db[Id].ExpirationTime = CurrentTime + Bar.timer;
      
      end
      
      db[Id].Old = nil;
      
    end

  end
  
  for Key, Aura in pairs(db) do
  
    if Aura.Old == true then
    
      LibAura:FireAuraOld(Aura);
      
      if PoolSize > #self.Pool.DBM then
        tinsert(self.Pool.DBM, Aura);
      end
      
      db[Key] = nil;
    
    end
  
  end

end


-----------------------------------------------------------------
-- Function DXE_Dropdown
-----------------------------------------------------------------
function Module.DXE_Dropdown(...)

  local _, Id, Text, TotalTime, FlashTime, _, _, _, FlashScreen, Icon = ...;
  
  af:Print("Found: ", Text);

  return self.DXE_Alerts.Dropdown(...);

end


-----------------------------------------------------------------
-- Function DXE_CenterPopup
-----------------------------------------------------------------
function Module.DXE_CenterPopup(...)

  local _, Id, Text, TotalTime, FlashTime, _, _, _, FlashScreen, Icon = ...;
  
  af:Print("Found: ", Text);

  return self.DXE_Alerts.CenterPopup(...);

end


-----------------------------------------------------------------
-- Function DXE_Simple
-----------------------------------------------------------------
function Module.DXE_Simple(...)

  local _, Text, TotalTime, _, _, FlashScreen, Icon = ...;
  
  af:Print("Found: ", Text);

  return self.DXE_Alerts.Simple(...);

end
