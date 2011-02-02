local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LibAura = LibStub("LibAura-1.0");

-- Import used global references into the local namespace.
local pairs, ipairs, wipe, setmetatable = pairs, ipairs, wipe, setmetatable;
local CreateFrame = CreateFrame;

--[[


  Container.AuraList = AuraFrames:NewAuraList(Container, Container.Config.Filter, Container.Config.Order);

  Container functions:

    AuraNew(Aura);
    AuraOld(Aura);
    AuraChanged(Aura);
    AuraAnchor(Aura, Index); -- Only when there is an Order config.

]]--


AuraFrames.AuraListPrototype = {};

local AuraListCheckingThrottle = 0.3;

-----------------------------------------------------------------
-- Function AddSource
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:AddSource(Unit, Type)

  LibAura:RegisterObjectSource(self, Unit, Type);

end


-----------------------------------------------------------------
-- Function RemoveSource
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:RemoveSource(Unit, Type)

  LibAura:UnregisterObjectSource(self, Unit, Type);

end


-----------------------------------------------------------------
-- Function ResyncSources
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:ResyncSources()

  for Aura, Status in pairs(self.Auras) do

    if Status == true then
      self.Container:AuraOld(Aura);
    end

  end
  
  wipe(self.Auras);
  
  if self.Order then
    self.Order:Reset();
  end
  
  self.NotStatic = self.Filter.NotStatic or false;
  
  if self.NotStatic == true then
    
    self.CheckingFrame:Show();
    
  else
    
    self.CheckingFrame:Hide();
    
  end

  LibAura:ObjectSync(self, nil, nil);

end


-----------------------------------------------------------------
-- Function AnchorAllAuras
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:AnchorAllAuras()

  for Index, Aura in ipairs(self.Order) do

    self.Container:AuraAnchor(Aura, Index)  
  
  end

end


-----------------------------------------------------------------
-- Function Delete
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:Delete()

  -- Remove all aura's.
  self:RemoveSource(nil, nil);

end


-----------------------------------------------------------------
-- Function AuraNew
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:AuraNew(Aura)

  -- Don't process duplicated aura's.
  if self.Auras[Aura] then
    return;
  end

  if self.Filter.Test(Aura) == false then
  
    if self.NotStatic == true then
      self.Auras[Aura] = false;
    end
  
    return;
  end

  self.Auras[Aura] = true;

  self.Container:AuraNew(Aura);
  
  if self.Order then
    self.Order:Add(Aura);
  end

end


-----------------------------------------------------------------
-- Function AuraChanged
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:AuraChanged(Aura)

  if not self.Auras[Aura] then
    return;
  end
  
  if self:AuraCheck(Aura) == false then
  
    -- No aura changes, just fire a AuraChanged.
  
    self.Container:AuraChanged(Aura);

    if self.Order then
      self.Order:Update(Aura);
    end
    
  elseif self.Auras[Aura] == false and self.NotStatic ~= true then

    -- Remove the aura if he didn't pass the filter and we are not
    -- checking realtime.

    self.Auras[Aura] = nil;
  
  end

end


-----------------------------------------------------------------
-- Function AuraOld
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:AuraOld(Aura)

  if not self.Auras[Aura] then
    return;
  end

  self.Container:AuraOld(Aura);

  if self.Order then
    self.Order:Remove(Aura);
  end

  self.Auras[Aura] = nil;

end


-----------------------------------------------------------------
-- Function AuraCheck
-----------------------------------------------------------------
function AuraFrames.AuraListPrototype:AuraCheck(Aura)

  if self.Filter.Test(Aura) == self.Auras[Aura] then
    return false;
  end
  
  self.Auras[Aura] = not self.Auras[Aura];
  
  if self.Auras[Aura] == false then
    
    self.Container:AuraOld(Aura);

    if self.Order then
      self.Order:Remove(Aura);
    end
  
  else
  
    self.Container:AuraNew(Aura);
    
    if self.Order then
      self.Order:Add(Aura);
    end
  
  end
  
  return true;

end


-----------------------------------------------------------------
-- Function NewAuraList
-----------------------------------------------------------------
function AuraFrames:NewAuraList(Container, FilterConfig, OrderConfig)

  local AuraList = {};
  setmetatable(AuraList, { __index = self.AuraListPrototype});
  
  AuraList.Auras = {};
  
  AuraList.Container = Container;
  
  AuraList.NotStatic = false;
  
  AuraList.CheckingFrame = CreateFrame("Frame");
  AuraList.CheckingFrame.LastScan = 0;
  AuraList.CheckingFrame:Hide();
  AuraList.CheckingFrame:SetScript("OnUpdate", function(CheckingFrame, Elapsed)
  
    CheckingFrame.LastScan = CheckingFrame.LastScan + Elapsed;
    
    if CheckingFrame.LastScan > AuraListCheckingThrottle then
    
      CheckingFrame.LastScan = 0;

      for Aura, _ in pairs(AuraList.Auras) do
        AuraList:AuraCheck(Aura);
      end
    
    end
  
  end);

  AuraList.Filter = self:NewFilter(FilterConfig, function() AuraList:ResyncSources(); end);
  
  if OrderConfig then
    AuraList.Order = self:NewOrder(OrderConfig, function(Aura, Index) Container:AuraAnchor(Aura, Index); end);
  end
  
  self.NotStatic = self.Filter.NotStatic or false;

  return AuraList;

end

