local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("ButtonContainer");
local LBF = LibStub("LibButtonFacade", true);
local LSM = LibStub("LibSharedMedia-3.0");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, CreateFrame, IsModifierKeyDown = GetTime, CreateFrame, IsModifierKeyDown;
local math_sin, math_cos, math_floor, math_ceil = math.sin, math.cos, math.floor, math.ceil;
local min, max = min, max;
local _G, PI = _G, PI;

local Prototype = Module.Prototype;

-- Pool that contains all the current unused buttons sorted by type.
local ButtonPool = {};

-- All containers have also there own (smaller) pool.
local ContainerButtonPoolSize = 5;

-- Counters for each butten type.
local ButtonCounter = 0;

-- Direction = {AnchorPoint, first Horizontal or Vertical, X Direction, Y Direction}
local DirectionMapping = {
  LEFTDOWN  = {"TOPRIGHT",    "V", -1, -1},
  LEFTUP    = {"BOTTOMRIGHT", "V", -1,  1},
  RIGHTDOWN = {"TOPLEFT",     "V",  1, -1},
  RIGHTUP   = {"BOTTOMLEFT",  "V",  1,  1},
  DOWNLEFT  = {"TOPRIGHT",    "H", -1, -1},
  DOWNRIGHT = {"TOPLEFT",     "H",  1, -1},
  UPLEFT    = {"BOTTOMRIGHT", "H", -1,  1},
  UPRIGHT   = {"BOTTOMLEFT",  "H",  1,  1},
};

-- How fast a button will get updated.
local ButtonUpdatePeriod = 0.05;

-- Pre calculate pi * 2 (used for flashing buttons).
local PI2 = PI + PI;

-- Pre calculate pi / 2 (used for popup buttons).
local PI_2 = PI / 2;

-- Frame levels used for poping up buttons.
local PopupFrameLevel = 9;
local PopupFrameLevelNormal = 4;

-----------------------------------------------------------------
-- Cooldown Fix
-----------------------------------------------------------------
local CooldownFrame = CreateFrame("Frame");
CooldownFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
CooldownFrame:SetScript("OnEvent", function(self, event)

  -- When we are in a loadding screen, all cooldown
  -- animations will be created and started but due
  -- a bug in wow the animations will not be showned.
  -- The first 10 seconds after the PLAYER_ENTERING_WORLD
  -- we hide/show the cooldown which will trigger the 
  -- internal animation at some point.

  local TimePast = 0;

  self:SetScript("OnUpdate", function(self, Elapsed)

    TimePast = TimePast + Elapsed;
    
    if TimePast > 10 then
    
      -- Disable our self after the first 10 seconds.
      self:SetScript("OnUpdate", nil);
      
    end
    
    for _, Container in pairs(Module.Containers) do
    
      for _, Button in pairs(Container.Buttons) do
      
        if Button.Cooldown:IsShown() == 1 then
        
          -- Try trigger animation code.
          Button.Cooldown:Hide();
          Button.Cooldown:Show();
        
        end
      
      end
    
    end
    
  end);

end);


-----------------------------------------------------------------
-- Local Function ButtonOnUpdate
-----------------------------------------------------------------
local function ButtonOnUpdate(Container, Button, Elapsed)

  local Config = Container.Config;

  if Button.Aura.ExpirationTime ~= 0 then
    
    local TimeLeft = max(Button.Aura.ExpirationTime - GetTime(), 0);
    
    if Config.Layout.ShowDuration == true then
    
      -- We don't have to update the duration every frame. We round up
      -- the seconds and compare if it's different from the last update.
    
      local TimeLeftSeconds = math_ceil(TimeLeft + 0.5);
      
      if Button.TimeLeftSeconds ~= TimeLeftSeconds then
    
        Button.Duration:SetFormattedText(AuraFrames:FormatTimeLeft(Config.Layout.DurationLayout, TimeLeft, true));
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
    
  end
  
  if Button.PopupTime ~= nil and Config.Warnings.Changing.Popup == true then
  
    if Button.PopupTime == 0 then
    
      Button:SetFrameLevel(PopupFrameLevel);
    
    end
  
    Button.PopupTime = Button.PopupTime + Elapsed;
  
    if Button.PopupTime > Config.Warnings.Changing.PopupTime then
    
      Button.PopupTime = nil;
      Button:SetScale(1.0);
      Container:AuraAnchor(Button.Aura, Button.OrderPos);
      Button:SetFrameLevel(PopupFrameLevelNormal);
    
    else
    
      local Scale = 1 + (((math_sin(-PI_2 + ((Button.PopupTime / Config.Warnings.Changing.PopupTime) * PI2)) + 1) / 2) * (Config.Warnings.Changing.PopupScale - 1));
      
      Button:SetScale(Scale);
      Container:AuraAnchor(Button.Aura, Button.OrderPos);
    
    end
  
  end

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

  if Button.Count ~= nil and self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    Button.Count:SetText(Aura.Count);
    Button.Count:Show();
    
  elseif Button.Count then
    
    Button.Count:Hide();
    
  end
  
  if Button.Border ~= nil then
  
    local Color;
    
    if Aura.Type == "HARMFUL" then
    
      Color = self.Config.Colors.Debuff[Aura.Classification];

    elseif Aura.Type == "HELPFUL" then

      Color = self.Config.Colors["Buff"];

    elseif Aura.Type == "WEAPON" then

      Color = self.Config.Colors["Weapon"];

    else

      Color = self.Config.Colors["Other"];

    end
    
    if LBF then
      LBF:SetNormalVertexColor(Button, unpack(Color));
    end
    
    Button.Border:SetVertexColor(unpack(Color));
  
  end

  if self.Config.Layout.ShowCooldown == true and Aura.ExpirationTime > 0 then
    
    local CurrentTime = GetTime();

    if Aura.Duration > 0 then
      Button.Cooldown:SetCooldown(Aura.ExpirationTime - Aura.Duration, Aura.Duration);
    else
      Button.Cooldown:SetCooldown(CurrentTime, Aura.ExpirationTime - CurrentTime);
    end
    
    Button.Cooldown:Show();
  
  else
  
    Button.Cooldown:Hide();
  
  end
  
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
  
  -- Set cooldown options
  Button.Cooldown:SetDrawEdge(self.Config.Layout.CooldownDrawEdge);
  Button.Cooldown:SetReverse(self.Config.Layout.CooldownReverse);
  Button.Cooldown.noCooldownCount = self.Config.Layout.CooldownDisableOmniCC;
  
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

    self.Frame:SetWidth((self.Config.Layout.HorizontalSize * Module.ButtonSizeX) + ((self.Config.Layout.HorizontalSize - 1) * self.Config.Layout.SpaceX));
    self.Frame:SetHeight((self.Config.Layout.VerticalSize * Module.ButtonSizeY) + ((self.Config.Layout.VerticalSize - 1) * self.Config.Layout.SpaceY));
    
    self.Frame:SetScale(self.Config.Layout.Scale);
    
    if self.Unlocked ~= true then
    
      self.Frame:ClearAllPoints();
      self.Frame:SetPoint(self.Config.Location.FramePoint, self.Config.Location.RelativeTo, self.Config.Location.RelativePoint, self.Config.Location.OffsetX, self.Config.Location.OffsetY);
    
    end
  
    self.TooltipOptions = {
      ShowPrefix = self.Config.Layout.TooltipShowPrefix,
      ShowCaster = self.Config.Layout.TooltipShowCaster,
      ShowSpellId = self.Config.Layout.TooltipShowSpellId,
      ShowClassification = self.Config.Layout.TooltipShowClassification,
    };
    
    local Flags = {};

    if self.Config.Layout.DurationOutline and self.Config.Layout.DurationOutline ~= "NONE" then
      tinsert(Flags, self.Config.Layout.DurationOutline);
    end

    if self.Config.Layout.DurationMonochrome == true then
      tinsert(Flags, "MONOCHROME");
    end

    self.DurationFontObject:SetFont(LSM:Fetch("font", self.Config.Layout.DurationFont), self.Config.Layout.DurationSize, tconcat(Flags, ","));
    self.DurationFontObject:SetTextColor(unpack(self.Config.Layout.DurationColor));
    
    Flags = {};

    if self.Config.Layout.CountOutline and self.Config.Layout.CountOutline ~= "NONE" then
      tinsert(Flags, self.Config.Layout.CountOutline);
    end

    if self.Config.Layout.CountMonochrome == true then
      tinsert(Flags, "MONOCHROME");
    end
    
    self.CountFontObject:SetFont(LSM:Fetch("font", self.Config.Layout.CountFont), self.Config.Layout.CountSize, tconcat(Flags, ","));
    self.CountFontObject:SetTextColor(unpack(self.Config.Layout.CountColor));
    
    self.MaxButtons = self.Config.Layout.HorizontalSize * self.Config.Layout.VerticalSize;
    self.Direction = DirectionMapping[self.Config.Layout.Direction];
    
    for _, Button in pairs(self.Buttons) do
      self:UpdateButton(Button);
    end
    
    -- Anchor all buttons.
    self.AuraList:AnchorAllAuras();
    
    -- We have buttons in the container pool that doesn't match the settings anymore. Release them into the general pool.
    self:ReleasePool();
    
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
    
      local ButtonId = "AuraFramesButton"..ButtonCounter;

      Button = CreateFrame("Button", ButtonId, self.Frame, "AuraFramesButtonTemplate");
      
      Button.Duration = _G[ButtonId.."Duration"];
      Button.Icon = _G[ButtonId.."Icon"];
      Button.Count = _G[ButtonId.."Count"];
      Button.Border = _G[ButtonId.."Border"];
      Button.Cooldown = _G[ButtonId.."Cooldown"];
    
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
      self.LBFGroup:AddButton(Button, {Icon = Button.Icon, Border = Button.Border, Count = false, Cooldown = Button.Cooldown});
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
  Button:SetScale(1.0);
  
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

end


-----------------------------------------------------------------
-- Function AuraChanged
-----------------------------------------------------------------
function Prototype:AuraChanged(Aura)

  if not self.Buttons[Aura] then
    return
  end
  
  local Button = self.Buttons[Aura];
  
  if Button.Count and self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    Button.Count:SetText(Aura.Count);
    Button.Count:Show();
    
  elseif Button.Count then
    
    Button.Count:Hide();
    
  end
  
  -- Start popup animation.
  Button.PopupTime = 0.0;
  
end


-----------------------------------------------------------------
-- Function AuraAnchor
-----------------------------------------------------------------
function Prototype:AuraAnchor(Aura, Index)

  local Button = self.Buttons[Aura];

  -- Save the order position.
  Button.OrderPos = Index;

  -- Hide button if the index is greater then the maximum number of buttons to anchor
  if Index > self.MaxButtons then
  
    Button:Hide();
    return;
    
  end
  
  local x, y;
  
  -- Calculate the x and y of the button.
  if self.Direction[2] == "V" then
    x, y = ((Index - 1) % self.Config.Layout.HorizontalSize), math_floor((Index - 1) / self.Config.Layout.HorizontalSize);
  else
    x, y = math_floor((Index - 1) / self.Config.Layout.VerticalSize), ((Index - 1) % self.Config.Layout.VerticalSize);
  end
  
  local Scale = Button:GetScale();
  
  Button:ClearAllPoints();
  
  -- Set the position.
  Button:SetPoint(
    "CENTER",
    self.Frame,
    self.Direction[1],
    (self.Direction[3] * ((x * (Module.ButtonSizeX + (x and self.Config.Layout.SpaceX))) + (Module.ButtonSizeX / 2))) / Scale,
    (self.Direction[4] * ((y * (Module.ButtonSizeY + (y and self.Config.Layout.SpaceY))) + (Module.ButtonSizeY / 2))) / Scale
  );

  -- Make sure the button is showned.
  Button:Show();

end

