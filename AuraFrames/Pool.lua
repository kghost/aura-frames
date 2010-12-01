local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import used global references into the local namespace.
local tinsert, tremove = tinsert, tremove;
local setmetatable, tonumber = setmetatable, tonumber;

AuraFrames.PoolPrototype = {};

-----------------------------------------------------------------
-- Function NewPool
-----------------------------------------------------------------
function AuraFrames:NewPool(Size, Parent)

  local Pool = {};
  
  setmetatable(Pool, { __index = AuraFrames.PoolPrototype});
  
  Pool.Size = tonumber(Size) or 0;
  Pool.Parent = Parent;
  
  return Pool;

end


-----------------------------------------------------------------
-- Function SetParent
-----------------------------------------------------------------
function AuraFrames.PoolPrototype:SetParent(Parent)

  self.Parent = Parent;

end


-----------------------------------------------------------------
-- Function SetSize
-----------------------------------------------------------------
function AuraFrames.PoolPrototype:SetSize(Size)

  self.Size = tonumber(Size) or 0;
  
  if self.Size ~= 0 and #self >= self.Size then
  
    while #self >= self.Size do
    
      local Item = tremove(self);
    
      if self.Parent then
      
        self.Parent:Put(Item);
      
      elseif Item.Release then
      
        Item:Release();
      
      end
    
    end
  
  end

end


-----------------------------------------------------------------
-- Function Get
-----------------------------------------------------------------
function AuraFrames.PoolPrototype:Get()

  local Item, Pool = tremove(self), self;

  if not Item and self.Parent then
    
    Item, Pool = self.Parent:Get();
  
  elseif Item.LeavePool then
  
    Item:LeavePool(self);
  
  end
  
  return Item, Pool;

end

-----------------------------------------------------------------
-- Function Put
-----------------------------------------------------------------
function AuraFrames.PoolPrototype:Put(Item)

  if self.Size ~= 0 and #self >= self.Size then
  
    if self.Parent then
    
      self.Parent(Put);
    
    elseif Item.Release then
    
      Item:Release();
    
    end
  
  else
  
    tinsert(self, Item);
    
    if Item.EnterPool then
      Item:EnterPool(self);
    end
    
  end

end

-----------------------------------------------------------------
-- Function Flush
-----------------------------------------------------------------
function AuraFrames.PoolPrototype:Flush()

  while #self do
  
    local Item = tremove(self);
  
    if self.Parent then
    
      self.Parent:Put(Item);
    
    elseif Item.Release then
    
      Item:Release();
    
    end
  
  end

end
