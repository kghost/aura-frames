local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

local AnimationObjects = {};
local Animators = {};


-- Pre calculate pi * 2 (used for flashing buttons).
local PI2 = PI + PI;

-- Pre calculate pi / 2 (used for popup buttons).
local PI_2 = PI / 2;


-----------------------------------------------------------------
-- Local Function Flash
-----------------------------------------------------------------
function Animators:Flash(Elapsed, Properties)

  local Alpha = ((math_cos((((Button.ExpireFlashTime - TimeLeft) % Config.Warnings.Expire.FlashSpeed) / Config.Warnings.Expire.FlashSpeed) * PI2) / 2 + 0.5) * 0.85) + 0.15;
  
  return nil, Alpha;

end


-----------------------------------------------------------------
-- Local Function AnimationStep
-----------------------------------------------------------------
local function AnimationStep(Elapsed)

  for Object, Animations in pairs(AnimationObjects) do

    local Scale, Alpha = 1.0, 1.0;

    for Type, Properties in pairs(Animations) do
    
      local ScaleAdjustment, AlphaAdjustment = Animators[Type](Animators, Elapsed, Properties);
      
      if ScaleAdjustment then
        Scale = Scale * ScaleAdjustment;
      end
      
      if AlphaAdjustment then
        Alpha = Alpha * AlphaAdjustment;
      end
      
      if not ScaleAdjustment and not AlphaAdjustment then
      
        -- Remove the animation if its run out.
        Animations[Type] = nil;
      
      end
    
    end
    
    Object._Animation.ScaleObject:SetScale(Scale);

    for _, Value in ipairs(Object._Animation.AlphaObjects) do
      Value:SetAlpha(Alpha);
    end
    
    if #Animations == 0 then
    
      -- No running animations left, remove the object from the list.
      AnimationObjects[Object] = nil;
    
    end
  
  end
  
end


-----------------------------------------------------------------
-- Function AnimationInitObject
-----------------------------------------------------------------
function AuraFrames:AnimationInitObject(Object, ScaleObject, AlphaObjects)

  Object._Animation = {
  
    ScaleObject = ScaleObject,
    AlphaObjects = AlphaObjects,
    
    Running = {},
    
  };

end


-----------------------------------------------------------------
-- Function AnimationStart
-----------------------------------------------------------------
function AuraFrames:AnimationStart(Object, Type, Properties)

  if not Animators[Type] then
    return;
  end

  Object._Animation.Running[Type] = Properties;
  
  AnimationObjects[Object] = Object._Animation.Running;

end

-----------------------------------------------------------------
-- Function AnimationStop
-----------------------------------------------------------------
function AuraFrames:AnimationStop(Object, Type)

  if not AnimationObjects[Object] then
    return;
  end
  
  AnimationObjects[Object][Type] = nil;

end

-----------------------------------------------------------------
-- Function AnimationStopAll
-----------------------------------------------------------------
function AuraFrames:AnimationStopAll(Object)

  if not AnimationObjects[Object] then
    return;
  end

  wipe(AnimationObjects[Object]);

end
