local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("TimeLineContainer");
local LBF = LibStub("LibButtonFacade", true);
local LSM = LibStub("LibSharedMedia-3.0");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, wipe, type, unpack = select, pairs, ipairs, next, wipe, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, CreateFrame, IsModifierKeyDown = GetTime, CreateFrame, IsModifierKeyDown;
local math_sin, math_cos, math_floor, math_ceil, math_pow = math.sin, math.cos, math.floor, math.ceil, math.pow;
local min, max = min, max;
local _G, PI = _G, PI;

local Prototype = Module.Prototype;

-- Pool that contains all the current unused buttons sorted by type.
local ButtonPool = {};

-- All containers have also there own (smaller) pool.
local ContainerButtonPoolSize = 5;

-- Counters for each butten type.
local ButtonCounter = 0;

-- Direction = Style = {Direction = {AnchorPoint, X Direction, Y Direction, Button Offset X, Button Offset Y}}
local DirectionMapping = {
  HORIZONTAL = {
    HIGH  = {"RIGHT" , -1,  0, 0, 1},
    LOW   = {"LEFT"  ,  1,  0, 0, 1},
  },
  VERTICAL = {
    HIGH  = {"TOP"   ,  0, -1, 1, 0},
    LOW   = {"BOTTOM",  0,  1, 1, 0},
  },
};

-- How fast a button will get updated.
local ButtonUpdatePeriod = 0.01; -- Max 100 times a second.

-- Pre calculate pi * 2 (used for flashing buttons).
local PI2 = PI + PI;

-- Pre calculate pi / 2 (used for popup buttons).
local PI_2 = PI / 2;

-- Frame levels used for poping up buttons.
local PopupFrameLevel = 9;
local PopupFrameLevelNormal = 4;


-----------------------------------------------------------------
-- Local Function ButtonOnUpdate
-----------------------------------------------------------------
local function ButtonOnUpdate(Container, Button, Elapsed)

  local Config = Container.Config;

  local TimeLeft = Button.Aura.ExpirationTime ~= 0 and max(Button.Aura.ExpirationTime - GetTime(), 0) or 0;

  if Button.Aura.ExpirationTime ~= 0 then
    
    if Config.Layout.ShowDuration == true then
    
      -- We don't have to update the duration every frame. We round up
      -- the seconds and compare if it's different from the last update.
    
      local TimeLeftSeconds = math_ceil((TimeLeft + 0.5) * 10);
      
      if Button.TimeLeftSeconds ~= TimeLeftSeconds then
    
        Button.Duration:SetFormattedText(AuraFrames:FormatTimeLeft(Config.Layout.DurationLayout, TimeLeft, false));
        Button.TimeLeftSeconds = TimeLeftSeconds;
      
      end
    
    end
    
    if Button.ExpireFlashTime and TimeLeft < Button.ExpireFlashTime then
      
      -- We need to flash for an aura that is expiring. Let's have some
      -- geek match involved to make the flash look nice.
      --
      -- We are starting with Alpha(1.0) and going in a sinus down and up
      -- and ending in a down. We don't go totally transpirant and the min
      -- is Alpha(0.15);
    
      local Alpha = ((math_cos((((Button.ExpireFlashTime - TimeLeft) % Config.Warnings.Expire.FlashSpeed) / Config.Warnings.Expire.FlashSpeed) * PI2) / 2 + 0.5) * 0.85) + 0.15;
      
      Button.Icon:SetAlpha(Alpha);
    
    elseif Button.NewFlashTime and Button.Aura.Duration ~= 0 then
    
      local TimeFromStart = Button.Aura.Duration - TimeLeft;
      
      if TimeFromStart < Button.NewFlashTime then
      
        -- See the ExpireFlash. The only difference is that we start with
        -- Alpha(0.15) and that we are ending with Alpha(1.0).
      
        local Alpha = ((math_cos((((TimeFromStart % Config.Warnings.New.FlashSpeed) / Config.Warnings.New.FlashSpeed) * PI2) + PI) / 2 + 0.5) * 0.85) + 0.15;
      
        Button.Icon:SetAlpha(Alpha);
      
      else
        
        -- At the end of the new flash animation make sure that we end
        -- with SetAlpha(1.0) and that we stop the animation.
      
        Button.NewFlashTime = nil;
        Button.Icon:SetAlpha(1.0);
      
      end
    
    end
    
    Button:Show();
    
  else
  
    -- Hide aura's without an ExpirationTime.
    Button:Hide();
    return;
  
  end
  
  if Button.PopupTime ~= nil and Config.Warnings.Changing.Popup == true then
  
    if Button.PopupTime == 0 then
    
      Button:SetFrameLevel(PopupFrameLevel);
    
    end
  
    Button.PopupTime = Button.PopupTime + Elapsed;
  
    if Button.PopupTime > Config.Warnings.Changing.PopupTime then
    
      Button.PopupTime = nil;
      Button:SetScale(Container.ButtonScale);
      Button:SetFrameLevel(PopupFrameLevelNormal);
    
    else
    
      local Scale = 1 + (((math_sin(-PI_2 + ((Button.PopupTime / Config.Warnings.Changing.PopupTime) * PI2)) + 1) / 2) * (Config.Warnings.Changing.PopupScale - 1));
      
      Button:SetScale(Container.ButtonScale * Scale);
    
    end
  
  end
  
  if TimeLeft < 0.3 then
    
    -- Part is going from 0 to 1.
    local Part = (0.3 - TimeLeft) * (1 / 0.3);
  
    Button:SetScale(Container.ButtonScale * (1 + (Part * 2)));
    Button.Icon:SetAlpha(1 - Part);
    
  end  
  
  local Scale = Button:GetScale();
  
  Button:ClearAllPoints();
  
  local Offset;
  
  if Button.Aura.ExpirationTime == 0 or Config.Layout.MaxTime < TimeLeft then
    Offset = Container.ButtonIndent / Scale;
  else
    Offset = (((Container.StepPerSecond * (Config.Layout.MaxTime - TimeLeft)) * Container:CalcPos(TimeLeft)) + Container.ButtonIndent) / Scale;
  end
  
  -- Set the position.
  Button:SetPoint(
    "CENTER",
    Container.Frame,
    Container.Direction[1],
    (Container.Direction[2] * Offset) + (Config.Layout.ButtonOffset * Container.Direction[4] / Scale),
    (Container.Direction[3] * Offset) + (Config.Layout.ButtonOffset * Container.Direction[5] / Scale)
  );

end


-----------------------------------------------------------------
-- Local Function ButtonOnClick
-----------------------------------------------------------------
local function ButtonOnClick(Button)

  -- When a key modifier is pressed, dump the aura to the
  -- chat window, otherwise just try to cancel the aura.

  if IsModifierKeyDown() == 1 then
  
    AuraFrames:DumpAura(Button.Aura);

  else
  
    AuraFrames:CancelAura(Button.Aura);

  end

end


-----------------------------------------------------------------
-- Function Delete
-----------------------------------------------------------------
function Prototype:Delete()

  self.AuraList:Delete();
  
  Module.Containers[self.Config.Id] = nil;

  self.Frame:Hide();
  self.Frame:UnregisterAllEvents();
  self.Frame = nil;

  -- Release the container pool into the general pool.
  self:ReleasePool();

  if self.LBFGroup then
    self.LBFGroup:Delete(true);
  end

end


-----------------------------------------------------------------
-- Function ReleasePool
-----------------------------------------------------------------
function Prototype:ReleasePool()

  -- Cleanup container button pool
  while #self.ButtonPool > 0 do
  
    local Button = tremove(self.ButtonPool);
    
    if LBF then
      self.LBFGroup:RemoveButton(Button, true);
    end
  
    Button:ClearAllPoints();
    Button:SetParent(nil);
    
    -- Release the button in the general pool.
    tinsert(ButtonPool, Button);
  
  end
  
end

-----------------------------------------------------------------
-- Function CalcPos
-----------------------------------------------------------------
function Prototype:CalcPos(TimeLeft)

  -- We make here the calculations for nice time lines.
  -- This function will always return between 0 and 1.
  -- So that the caller can do CalcPos() * width for
  -- example.

  if self.Config.Layout.TimeFlow == "POW" then

    local Pos = math_pow(self.Config.Layout.MaxTime - TimeLeft, self.Config.Layout.TimeCompression) / math_pow(self.Config.Layout.MaxTime, self.Config.Layout.TimeCompression);

    return Pos > 1 and 1 or Pos;
  
  end

  -- No compression
  return 1;

end


-----------------------------------------------------------------
-- Function UpdateButtonDisplay
-----------------------------------------------------------------
function Prototype:UpdateButtonDisplay(Button)

  -- Only update settings that can be changed between
  -- different aura's. We can assume we are still having
  -- the same container. If not then the function
  -- UpdateButton will have taken care of that for us.

  local Aura = Button.Aura;

  if Button.Duration ~= nil and self.Config.Layout.ShowDuration == true and Aura.ExpirationTime > 0 then
    
    Button.Duration:Show();
  
  elseif Button.Duration then
  
    Button.Duration:Hide();
  
  end

  if Button.Count ~= nil and self.Config.Layout.ShowCount and Aura.Count > 1 then
  
    Button.Count:SetText(Aura.Count);
    Button.Count:Show();
    
  elseif Button.Count then
    
    Button.Count:Hide();
    
  end
  
  self:AuraEvent(Aura, "ColorChanged");
  
  ButtonOnUpdate(self, Button, 0.0);

end


-----------------------------------------------------------------
-- Function UpdateButton
-----------------------------------------------------------------
function Prototype:UpdateButton(Button)

  -- Update settings that can be changed between 
  -- different containers. After that call function
  -- UpdateButtonDisplay to update the things that
  -- can be changed between aura's.

  local Container, Aura = self, Button.Aura;

  if Button.Duration ~= nil and self.Config.Layout.ShowDuration == true then
    
    Button.Duration:ClearAllPoints();
    Button.Duration:SetPoint("CENTER", Button, "CENTER", self.Config.Layout.DurationPosX, self.Config.Layout.DurationPosY);
  
  end

  if self.Config.Layout.ShowCount then
  
    Button.Count:ClearAllPoints();
    Button.Count:SetPoint("CENTER", Button, "CENTER", self.Config.Layout.CountPosX, self.Config.Layout.CountPosY);
    
  end
  
  if self.Config.Layout.ShowTooltip then
  
    Button:SetScript("OnEnter", function(Button) AuraFrames:ShowTooltip(Button.Aura, Button, Container.TooltipOptions); end);
    Button:SetScript("OnLeave", function() AuraFrames:HideTooltip(); end);
  
  else
  
    Button:SetScript("OnEnter", nil);
    Button:SetScript("OnLeave", nil);
  
  end
  
  if self.Config.Layout.Clickable then
    
    Button:EnableMouse(true);
    Button:RegisterForClicks("RightButtonUp");
    Button:SetScript("OnClick", ButtonOnClick);
    
    Button:HookScript("OnEnter", function(Button) AuraFrames:SetCancelAuraFrame(Button, Button.Aura); end);
    
  else
    
    Button:EnableMouse(false);
    Button:SetScript("OnClick", nil);
    
  end
  
  Button:SetScale(self.ButtonScale);
  
  self:UpdateButtonDisplay(Button);

end


-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Prototype:Update(...)

  -- Update the whole container. This function is called
  -- on login and when settings are changed for the
  -- container. To optimize it a little bit, the caller
  -- can indicate what changed. The following is supported:
  -- ALL, LAYOUT or WARNINGS.

  local Changed = select(1, ...) or "ALL";

  if Changed == "ALL" or Changed == "LAYOUT" then

    self.Frame:SetScale(self.Config.Layout.Scale);
    
    if self.Unlocked ~= true then
    
      if self.Config.Layout.Style == "HORIZONTAL" then
      
        self.Frame:SetWidth(self.Config.Layout.Length);
        self.Frame:SetHeight(self.Config.Layout.Width);
      
      else
      
        self.Frame:SetWidth(self.Config.Layout.Width);
        self.Frame:SetHeight(self.Config.Layout.Length);
      
      end
    
      self.Frame:ClearAllPoints();
      self.Frame:SetPoint(self.Config.Location.FramePoint, self.Config.Location.RelativeTo, self.Config.Location.RelativePoint, self.Config.Location.OffsetX, self.Config.Location.OffsetY);
    
    end
    
    self.FrameTexture:SetTexture(LSM:Fetch("statusbar", self.Config.Layout.BackgroundTexture));
    self.FrameTexture:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", self.Config.Layout.BackgroundTextureInsets, -self.Config.Layout.BackgroundTextureInsets);
    self.FrameTexture:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT", -self.Config.Layout.BackgroundTextureInsets, self.Config.Layout.BackgroundTextureInsets);
    self.FrameTexture:SetVertexColor(unpack(self.Config.Layout.BackgroundTextureColor));
    
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = 0, 0, 0, 1, 1, 0, 1, 1;
    
    if self.Config.Layout.BackgroundTextureFlipX == true then
    
      ULy, LLy = LLy, ULy; -- Flip upper left to lower left.
      URy, LRy = LRy, URy; -- Flip upper right to lower right.
    
    end
    
    if self.Config.Layout.BackgroundTextureFlipY == true then
    
      ULx, URx = URx, ULx; -- Flip upper left to upper right.
      LLx, LRx = LRx, LLx; -- Flip lower left to lower right.
    
    end
    
    if self.Config.Layout.BackgroundTextureRotate == true then
    
      -- We rotate 90 degrees to the right.
      
      ULx, ULy, URx, URy, LRx, LRy, LLx, LLy = LLx, LLy, ULx, ULy, URx, URy, LRx, LRy;
      
    end
    
    if self.Config.Layout.Style ~= "HORIZONTAL" then
    
      -- We rotate 90 degrees to the right if we are vertical.
      
      ULx, ULy, URx, URy, LRx, LRy, LLx, LLy = LLx, LLy, ULx, ULy, URx, URy, LRx, LRy;
      
    end
    
    self.FrameTexture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
    
    self.Frame:SetBackdrop({
      edgeFile = LSM:Fetch("border", self.Config.Layout.BackgroundBorder), 
      edgeSize = self.Config.Layout.BackgroundBorderSize, 
    });
    self.Frame:SetBackdropBorderColor(unpack(self.Config.Layout.BackgroundBorderColor));
    
    self.TooltipOptions = {
      ShowPrefix = self.Config.Layout.TooltipShowPrefix,
      ShowCaster = self.Config.Layout.TooltipShowCaster,
      ShowAuraId = self.Config.Layout.TooltipShowAuraId,
      ShowClassification = self.Config.Layout.TooltipShowClassification,
    };
    
    AuraFrames:SetFontObjectProperties(
      self.DurationFontObject,
      self.Config.Layout.DurationFont,
      self.Config.Layout.DurationSize,
      self.Config.Layout.DurationOutline,
      self.Config.Layout.DurationMonochrome,
      self.Config.Layout.DurationColor
    );
    
    AuraFrames:SetFontObjectProperties(
      self.CountFontObject,
      self.Config.Layout.CountFont,
      self.Config.Layout.CountSize,
      self.Config.Layout.CountOutline,
      self.Config.Layout.CountMonochrome,
      self.Config.Layout.CountColor
    );
    
    AuraFrames:SetFontObjectProperties(
      self.TextFontObject,
      self.Config.Layout.TextFont,
      self.Config.Layout.TextSize,
      self.Config.Layout.TextOutline,
      self.Config.Layout.TextMonochrome,
      self.Config.Layout.TextColor
    );
    
    self.Direction = DirectionMapping[self.Config.Layout.Style][self.Config.Layout.Direction];
    self.ButtonIndent = self.Config.Layout.ButtonIndent == true and (36 * self.Config.Layout.ButtonScale) / 2 or 0;
    self.StepPerSecond = ((self.Config.Layout.Length - (self.ButtonIndent * 2)) / self.Config.Layout.MaxTime);
    
    self.ButtonScale = self.Config.Layout.ButtonScale;
    
    for _, Button in pairs(self.Buttons) do
      self:UpdateButton(Button);
    end
    
    -- We have buttons in the container pool that doesn't match the settings anymore. Release them into the general pool.
    self:ReleasePool();
    
    for _, Label in ipairs(self.TextLabels) do
      Label:Hide();
    end
    
    wipe(self.TextLabels);
    
    if self.Config.Layout.ShowText == true then
    
      local FrameId = self.Frame:GetName();
      
      if self.Config.Layout.TextLabelsAuto == true then
        
        wipe(self.Config.Layout.TextLabels);
        
        local Time, Index = 1, 1;
        local Offset, Width;
      
        while Time <= self.Config.Layout.MaxTime do
          
          local NewOffset = self.ButtonIndent + (((self.Config.Layout.MaxTime - Time) * self.StepPerSecond) * self:CalcPos(Time));
          
          if not Offset or Offset - Width - self.Config.Layout.TextLabelAutoSpace > NewOffset then
          
            local Label = _G[FrameId.."_Label"..Index] or self.Frame:CreateFontString(FrameId.."_Label"..Index, "ARTWORK");
            
            Label:ClearAllPoints();
            
            Offset = NewOffset;
            
            Label:SetPoint("CENTER", self.Frame, self.Direction[1], (Offset * self.Direction[2]) + (self.Config.Layout.TextOffset * self.Direction[4]), (Offset * self.Direction[3]) + (self.Config.Layout.TextOffset * self.Direction[5]));
            
            Label:SetFontObject(self.TextFontObject);
            Label:SetFormattedText(AuraFrames:FormatTimeLeft(self.Config.Layout.TextLayout, Time, false));
            Label:Show();
          
            Width = self.Config.Layout.Style == "HORIZONTAL" and Label:GetStringWidth() or Label:GetStringHeight() ;
            tinsert(self.TextLabels, Label);

            tinsert(self.Config.Layout.TextLabels, Time);

            Index = Index + 1;
          
          end
          
          if Time == 1 then
            Time = 5;
          elseif Time < 30 then
            Time = Time + 5;
          elseif Time < 120 then
            Time = Time + 10;
          elseif Time < 300 then
            Time = Time + 30;
          elseif Time < 600 then -- 10 min
            Time = Time + 60;
          elseif Time < 1200 then -- 20 min
            Time = Time + 120;
          else
            Time = Time + 300;
          end
          
        end
      
      else
      
        for Index, Time in ipairs(self.Config.Layout.TextLabels) do

          if self.Config.Layout.MaxTime >= Time and Time >= 0 then

            local Label = _G[FrameId.."_Label"..Index] or self.Frame:CreateFontString(FrameId.."_Label"..Index, "ARTWORK");
            
            Label:ClearAllPoints();
            
            local Offset = self.ButtonIndent + (((self.Config.Layout.MaxTime - Time) * self.StepPerSecond) * self:CalcPos(Time));
            
            Label:SetPoint("CENTER", self.Frame, self.Direction[1], (Offset * self.Direction[2]) + (self.Config.Layout.TextOffset * self.Direction[4]), (Offset * self.Direction[3]) + (self.Config.Layout.TextOffset * self.Direction[5]));
            
            Label:SetFontObject(self.TextFontObject);
            Label:SetFormattedText(AuraFrames:FormatTimeLeft(self.Config.Layout.TextLayout, Time, false));
            Label:Show();
            
            tinsert(self.TextLabels, Label);
          
          end
          
        end
      
      end
    
    end
    
    if next(self.Buttons) == nil then
      self.Frame:SetAlpha(self.Config.Layout.InactiveAlpha);
    else
      self.Frame:SetAlpha(1.0);
    end
    
  end

  if Changed == "ALL" or Changed == "WARNINGS" then

    if self.Config.Warnings.New.Flash == true then
      self.NewFlashTime = self.Config.Warnings.New.FlashSpeed * (self.Config.Warnings.New.FlashNumber + 0.5);
    else
      self.NewFlashTime = nil;
    end
    
    if self.Config.Warnings.Expire.Flash == true then
      self.ExpireFlashTime = self.Config.Warnings.Expire.FlashSpeed * (self.Config.Warnings.Expire.FlashNumber + 0.5);
    else
      self.ExpireFlashTime = nil;
    end
    
  end

end


-----------------------------------------------------------------
-- Function AuraEvent
-----------------------------------------------------------------
function Prototype:AuraEvent(Aura, Event, ...)

  local Button = self.Buttons[Aura];

  if Event == "ColorChanged" and Button.Border ~= nil then

    if LBF then
      LBF:SetNormalVertexColor(Button, unpack(Aura.Color));
    end
    
    Button.Border:SetVertexColor(unpack(Aura.Color));
  
  end

end


-----------------------------------------------------------------
-- Function AuraNew
-----------------------------------------------------------------
function Prototype:AuraNew(Aura)

  -- Pop the last button out the container pool.
  local Button = tremove(self.ButtonPool);
  local FromContainerPool = Button and true or false;
  
  if not Button then
  
    -- We didn't had a button in the container pool.
    -- Trying the general pool.
    Button = tremove(ButtonPool);
    
    if not Button then
      -- No buttons in any pool. Let's make a new button.
    
      ButtonCounter = ButtonCounter + 1;
    
      local ButtonId = "AuraFramesTimeLineButton"..ButtonCounter;

      Button = CreateFrame("Button", ButtonId, self.Frame, "AuraFramesTimeLineTemplate");
      
      Button.Duration = _G[ButtonId.."Duration"];
      Button.Icon = _G[ButtonId.."Icon"];
      Button.Count = _G[ButtonId.."Count"];
      Button.Border = _G[ButtonId.."Border"];
    
    else
    
      Button:SetParent(self.Frame);
    
    end
  
    -- We got a general pool button or a new button.
    -- Prepare it so it match a container pool button.
    
    local Container = self;  
    Button:SetScript("OnUpdate", function(Button, Elapsed)
      
       Button.TimeSinceLastUpdate = Button.TimeSinceLastUpdate + Elapsed;
       if Button.TimeSinceLastUpdate > ButtonUpdatePeriod then
          ButtonOnUpdate(Container, Button, Button.TimeSinceLastUpdate);
          Button.TimeSinceLastUpdate = 0.0;
       end
      
    end);
    
    if LBF then
      -- Don't skin the count text, we will take care of that.
      self.LBFGroup:AddButton(Button, {Icon = Button.Icon, Border = Button.Border, Count = false});
    end
    
    -- Set the font from this container.
    Button.Duration:SetFontObject(self.DurationFontObject);
    Button.Count:SetFontObject(self.CountFontObject);
    
  end
  
  Button.NewFlashTime = self.NewFlashTime;
  Button.ExpireFlashTime = self.ExpireFlashTime;
  
  Button.TimeSinceLastUpdate = 0.0;
  Button.TimeLeftSeconds = 0;
  
  Button.Aura = Aura;
  Button.Icon:SetTexture(Aura.Icon);
  
  if next(self.Buttons) == nil then
    self.Frame:SetAlpha(1.0);
  end
  
  self.Buttons[Aura] = Button;
  
  if FromContainerPool == true then

    -- We need only a display update.
    self:UpdateButtonDisplay(Button);

  else

    -- We need a full update.
    self:UpdateButton(Button);

  end
  
end

-----------------------------------------------------------------
-- Function AuraOld
-----------------------------------------------------------------
function Prototype:AuraOld(Aura)

  if not self.Buttons[Aura] then
    return
  end
  
  local Button = self.Buttons[Aura];
  
  -- Remove the button from the container list.
  self.Buttons[Aura] = nil;
  
  Button:Hide();
  
  if AuraFrames:IsTooltipOwner(Button) == true then
    AuraFrames:HideTooltip();
  end
  
  -- The warning system can have changed the alpha and scale. Set it back.
  Button.Icon:SetAlpha(1.0);
  Button:SetScale(self.ButtonScale);
  
  -- Reset popup animation trigger and restore the frame level.
  Button.PopupTime = nil;
  Button:SetFrameLevel(PopupFrameLevelNormal);
  
  -- See in what pool we need to drop.
  if #self.ButtonPool >= ContainerButtonPoolSize then
  
    -- General pool.
  
    if LBF then
      self.LBFGroup:RemoveButton(Button, true);
    end

    Button:ClearAllPoints();
    Button:SetParent(nil);
    
    Button:SetScript("OnUpdate", nil);
    
    -- Release the button back in the general pool for later use.
    tinsert(ButtonPool, Button);
  
  else
  
    -- Release the button back in the container pool for later use.
    tinsert(self.ButtonPool, Button);
  
  end
  
  if next(self.Buttons) == nil then
    self.Frame:SetAlpha(self.Config.Layout.InactiveAlpha);
  end
  
end

-----------------------------------------------------------------
-- Function AuraChanged
-----------------------------------------------------------------
function Prototype:AuraChanged(Aura)

  if not self.Buttons[Aura] then
    return
  end
  
  local Button = self.Buttons[Aura];
  
  if Button.Count and self.Config.Layout.ShowCount and Aura.Count > 1 then
  
    Button.Count:SetText(Aura.Count);
    Button.Count:Show();
    
  elseif Button.Count then
    
    Button.Count:Hide();
    
  end
  
  -- Start popup animation.
  Button.PopupTime = 0.0;
  
end

