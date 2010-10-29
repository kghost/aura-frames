-----------------------------------------------------------------
--
--  File: WeaponEnchantments.lua
--
--  Author: Alex <Nexiuz> Elderson
--
--  Description:
--
--
-----------------------------------------------------------------


local LibAura = LibStub("LibAura-1.0");

local Major, Minor = "WeaponEnchantments-1.0", 0;
local Module = LibAura:NewModule("WeaponEnchantments-1.0", 0);

if not Module then return; end -- No upgrade needed.

-- Make sure that we dont have old unit/types if we upgrade.
LibAura:UnregisterModuleSource(Module, nil, nil);

-- Register the the provided sources.
LibAura:RegisterModuleSource(Module, "player", "WEAPON");


-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;


-----------------------------------------------------------------
-- Function Enable
-----------------------------------------------------------------
function Module:Enable()

  -- For the sake of ppl that wining about addon memory... We create the db table when we are getting enabled.

  self.db = {
    MainHand = {
      Id = "PlayerWEAPONMainHand",
      Active = false, -- Used internaly to see if its an active enchantment.
      Type = "WEAPON",
      Index = 16,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      ExpirationTime = 0,
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      SpellId = 0,
    },
    OffHand = {
      Id = "PlayerWEAPONOffHand",
      Active = false, -- Used internaly to see if its an active enchantment.
      Type = "WEAPON",
      Index = 17,
      Unit = "player",
      Classification = "None",
      CasterUnit = "player",
      CasterName = UnitName("player"),
      ExpirationTime = 0,
      IsStealable = false,
      IsCancelable = true,
      IsDispellable = false,
      SpellId = 0,
    },
  };
  
  return true;

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
  
  -- We only support Type "WEAPON".
  if Type ~= "WEAPON" then
    return;
  end
  
  self.ScanTooltip = self.ScanTooltip  or CreateFrame("GameTooltip", "LibAura-1.0_ScanTooltip", nil, "GameTooltipTemplate");
  self.ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
  
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
  
  -- We only support Type "WEAPON".
  if Type ~= "WEAPON" then
    return;
  end
  
  if self.db then
    for _, Aura in pairs(self.db) do

      if Aura.Active == true then
        LibAura:FireAuraOld(Aura);
        Aura.Active = false;
      end

    end
  end

  LibAura:UnregisterEvent("LIBAURA_UPDATE", self, self.Update);

end


-----------------------------------------------------------------
-- Function GetAuras
-----------------------------------------------------------------
function Module:GetAuras(Unit, Type)

  -- This function is rarely called. So we also not try to optimize it.

  -- We only support Unit "player".
  if Unit ~= "player" then
    return {};
  end
  
  -- We only support Type "WEAPON".
  if Type ~= "WEAPON" then
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
-- Function Update
-----------------------------------------------------------------
function Module:Update()

  local HasMainHandEnchant, MainHandExpiration, MainHandCharges, HasOffHandEnchant, OffHandExpiration, OffHandCharges = GetWeaponEnchantInfo();

  local CurrentTime;
  
  if MainHandExpiration then
    CurrentTime = GetTime();
    MainHandExpiration = ceil(CurrentTime + (MainHandExpiration / 1000));
  end

  if OffHandExpiration then
    CurrentTime = CurrentTime or GetTime();
    OffHandExpiration = ceil(CurrentTime + (OffHandExpiration / 1000));
  end

  self:ScanWeapon("MainHand", HasMainHandEnchant, MainHandExpiration or 0, MainHandCharges or 0);
  self:ScanWeapon("OffHand", HasOffHandEnchant, OffHandExpiration or 0, OffHandCharges or 0);

end



-----------------------------------------------------------------
-- Function GetWeaponEnchantName
-----------------------------------------------------------------
function Module:GetWeaponEnchantName(SlotId)

   self.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
   self.ScanTooltip:SetInventoryItem("player", SlotId)

   for i = 1, self.ScanTooltip:NumLines() do

      local TextObject = getglobal("LibAura-1.0_ScanTooltipTextLeft"..i);
      if TextObject then
        
        local Text = TextObject:GetText();
        
        local EnchantText = Text:match("^(.+) %(%d+ min%)$") or Text:match("^(.+) %(%d+ sec%)$") or Text:match("^(.+) %(%d+ hour%)$");

        if EnchantText then
           self.ScanTooltip:Hide()
           return EnchantText
        end
        
      end

   end

   self.ScanTooltip:Hide()
   
   return "";

end


-----------------------------------------------------------------
-- Function ScanWeapon
-----------------------------------------------------------------
function Module:ScanWeapon(Slot, HasEnchant, ExpirationTime, Charges)

  local Aura = self.db[Slot];

  if HasEnchant then
  
    local Name, Icon = self:GetWeaponEnchantName(Aura.Index), GetInventoryItemTexture("player", Aura.Index);
    
    -- We got some latency between querying the expire time and GetTime(). So we say if
    -- the difference is more then 3 seconds that we got a new expiration time.
    
    if Aura.Active ~= true or Aura.Name ~= Name or Aura.Icon ~= Icon or abs(Aura.ExpirationTime - ExpirationTime) > 3 then -- New enchantment
    
      if Aura.Active == true then
        -- If we had an active enchantment, then fire aura old event before updating the aura.
        LibAura:FireAuraOld(Aura);
      else
        Aura.Active = true;
      end
      
      Aura.Name = Name;
      Aura.Icon = Icon;
      Aura.ExpirationTime = ExpirationTime;
      Aura.Duration = ExpirationTime - GetTime();
      Aura.Count = Charges;
      
      LibAura:FireAuraNew(Aura);
      
    elseif Aura.Count ~= Charges then
    
      -- Sync time
      Aura.ExpirationTime = ExpirationTime;
      Aura.Duration = ExpirationTime - GetTime();
      
      Aura.Count = Charges;
      
      LibAura:FireAuraChanged(Aura);
    
    else
    
      -- Sync time
      Aura.ExpirationTime = ExpirationTime;
      Aura.Duration = ExpirationTime - GetTime();
    
    end
    
    
  else
  
    if Aura.Active == true then
      
      -- If we had an active enchantment then it is expired or canceled.
      -- Make it inactive and fire the aura old event.
      
      Aura.Active = false;
      LibAura:FireAuraOld(Aura);
      
    end
  
  end

end
