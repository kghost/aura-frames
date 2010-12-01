local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("TimeLineContainer");
local LBF = LibStub("LibButtonFacade", true);
local LSM = LibStub("LibSharedMedia-3.0");

local Prototype = Module.ButtonPrototype;

local Counter = 0;


-- Frame levels used for poping up buttons.
local PopupFrameLevel = 9;
local PopupFrameLevelNormal = 4;

-----------------------------------------------------------------
-- Function NewButton
-----------------------------------------------------------------
function Module:NewButton()

  Counter = Counter + 1;

  local ButtonId = "AuraFramesTimeLineButton"..Counter;

  local Button = CreateFrame("Button", ButtonId, self.Frame, "AuraFramesTimeLineTemplate");
  
  setmetatable(Button, { __index = Prototype});
  
  Button.Duration = _G[ButtonId.."Duration"];
  Button.Icon = _G[ButtonId.."Icon"];
  Button.Count = _G[ButtonId.."Count"];
  Button.Border = _G[ButtonId.."Border"];
  
  return Button;

end

-----------------------------------------------------------------
-- Function Release
-----------------------------------------------------------------
function Prototype:Release()

  self:Hide();
  
  -- We can't remove the button from LBF because we don't know
  -- the group we are in. Ow, I love LBF so much... NOT

end


-----------------------------------------------------------------
-- Function Attach
-----------------------------------------------------------------
function Prototype:Attach(Container)

  if self.Container == Container then
    return;
  end

  if self.Container then
    self:Dettach();
  end
  
  self.Container = Container;

end


-----------------------------------------------------------------
-- Function Dettach
-----------------------------------------------------------------
function Prototype:Dettach()

end


-----------------------------------------------------------------
-- Function EnterPool
-----------------------------------------------------------------
function Prototype:EnterPool(Pool)

  self:Hide();
  
  if AuraFrames:IsTooltipOwner(self) == true then
    AuraFrames:HideTooltip();
  end
  
  -- The warning system can have changed the alpha and scale. Set it back.
  self.Icon:SetAlpha(1.0);
  self:SetScale(1.0);

  -- Reset popup animation trigger and restore the frame level.
  self.PopupTime = nil;
  self:SetFrameLevel(PopupFrameLevelNormal);
  
  if Pool == Module.Pool then
    -- We are entering the general pool.
    -- Do some more work.
    
    self:ClearAllPoints();
    self:SetParent(nil);
    
    self:SetScript("OnUpdate", nil);
  
  end
  
end