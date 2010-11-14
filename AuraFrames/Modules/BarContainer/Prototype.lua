local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("BarContainer");
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
local _G = _G;

local Prototype = Module.Prototype;

-- Pool that contains all the current unused bars sorted by type.
local BarPool = {};

-- All containers have also there own (smaller) pool.
local ContainerBarPoolSize = 5;

-- Counters for each Bar type.
local BarCounter = 0;

-- Direction = {AnchorPoint, first X or Y, X Direction, Y Direction}
local DirectionMapping = {
  DOWN  = {"TOPLEFT",    -1},
  UP    = {"BOTTOMLEFT",  1},
};


PositionMappings = {
  NONE = {
    LEFT = {5, 0},
    RIGHT = {-5, 0},
    CENTER = {0, 0},
  },
  LEFT = {
    LEFT = {5 + Module.BarHeight, 0},
    RIGHT = {-5, 0},
    CENTER = {Module.BarHeight / 2, 0},
  },
  RIGHT = {
    LEFT = {5, 0},
    RIGHT = {-5 - Module.BarHeight, 0},
    CENTER = {-(Module.BarHeight / 2), 0},
  },
};

-- How fast a bar will get updated.
local BarUpdatePeriod = 0.05;

-- Pre calculate pi * 2 (used for flashing bars).
local PI2 = PI + PI;

-- Pre calculate pi / 2 (used for popup bars).
local PI_2 = PI / 2;

-- Frame levels used for poping up bars.
local PopupFrameLevel = 9;
local PopupFrameLevelNormal = 4;


-----------------------------------------------------------------
-- Cooldown Fix
-----------------------------------------------------------------
local CooldownFrame = CreateFrame("Frame");
CooldownFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
CooldownFrame:SetScript("OnEvent", function(self, event)

  local TimePast = 0;

  self:SetScript("OnUpdate", function(self, Elapsed)

    TimePast = TimePast + Elapsed;
    
    if TimePast > 10 then
      self:SetScript("OnUpdate", nil);
    end
    
    for _, Container in pairs(Module.Containers) do
    
      for _, Bar in pairs(Container.Bars) do
      
        if Bar.Button.Cooldown:IsShown() == 1 then
        
          -- Trigger animation code.
          Bar.Button.Cooldown:Hide();
          Bar.Button.Cooldown:Show();
        
        end
      
      end
    
    end
    
  end);

end);


-----------------------------------------------------------------
-- Local Function BarOnUpdate
-----------------------------------------------------------------
local function BarOnUpdate(Container, Bar, Elapsed)

  local Config = Container.Config;
  
  if Bar.Aura.ExpirationTime ~= 0 then
    
    local TimeLeft = max(Bar.Aura.ExpirationTime - GetTime(), 0);
    
    if Container.Config.Layout.ShowDuration == true then
    
      local TimeLeftSeconds = math_ceil(TimeLeft);
      
      if Bar.TimeLeftSeconds ~= TimeLeftSeconds then
    
        Bar.Duration:SetFormattedText(AuraFrames:FormatTimeLeft(Config.Layout.DurationLayout, TimeLeft, false));
      
        Bar.TimeLeftSeconds = TimeLeftSeconds;
      
      end
    
    end
    
    if TimeLeft < Container.Config.Layout.BarMaxTime then
    
      local Part = TimeLeft / Container.Config.Layout.BarMaxTime;
    
      if Container.Shrink then
        Bar.Texture:SetWidth((Container.WidthPerSecond * TimeLeft) + 1.0);
      else
        Bar.Texture:SetWidth(Container.BarWidth - (Container.WidthPerSecond * TimeLeft));
      end
      
      local Part = TimeLeft / Container.Config.Layout.BarMaxTime;
      local Left, Right;
      
      if Container.Config.Layout.BarDirection == "LEFTGROW" then

        Left, Right = 0, 1 - Part; -- k

      elseif Container.Config.Layout.BarDirection == "RIGHTGROW" then

        Left, Right = 1 - Part, 0;

      elseif Container.Config.Layout.BarDirection == "LEFTSHRINK" then

        Left, Right = 0, Part; -- k

      else -- RIGHTSHRINK

        Left, Right = Part, 0;

      end
      
      if Container.Config.Layout.BarTextureMove then
        Left, Right = 1 - Right, 1 - Left;
      end
      
      Bar.Texture:SetTexCoord(Left, Right, 0, 1);
      
    end
    
    if Bar.ExpireFlashTime and TimeLeft < Bar.ExpireFlashTime then
      
      -- We need to flash for an aura that is expiring. Let's have some
      -- geek match involved to make the flash look nice.
      --
      -- We are starting with Alpha(1.0) and going in a sinus down and up
      -- and ending in a down. We don't go totally transpirant and the min
      -- is Alpha(0.15);
    
      local Alpha = ((math_cos((((Bar.ExpireFlashTime - TimeLeft) % Config.Warnings.Expire.FlashSpeed) / Config.Warnings.Expire.FlashSpeed) * PI2) / 2 + 0.5) * 0.85) + 0.15;
      
      Bar.Button.Icon:SetAlpha(Alpha);
      Bar.Texture:SetAlpha(Alpha);
    
    elseif Bar.NewFlashTime and Bar.Aura.Duration ~= 0 then
    
      local TimeFromStart = Bar.Aura.Duration - TimeLeft;
      
      if TimeFromStart < Bar.NewFlashTime then
      
        -- See the ExpireFlash. The only difference is that we start with
        -- Alpha(0.15) and that we are ending with Alpha(1.0).
      
        local Alpha = ((math_cos((((TimeFromStart % Config.Warnings.New.FlashSpeed) / Config.Warnings.New.FlashSpeed) * PI2) + PI) / 2 + 0.5) * 0.85) + 0.15;
      
        Bar.Button.Icon:SetAlpha(Alpha);
        Bar.Texture:SetAlpha(Alpha);
      
      else
        
        -- At the end of the new flash animation make sure that we end
        -- with SetAlpha(1.0) and that we stop the animation.
      
        Bar.NewFlashTime = nil;
        Bar.Button.Icon:SetAlpha(1.0);
        Bar.Texture:SetAlpha(1.0);
      
      end
    
    end
  
  end
  
  if Bar.PopupTime ~= nil and Config.Warnings.Changing.Popup == true then
  
    if Bar.PopupTime == 0 then
    
      Bar:SetFrameLevel(PopupFrameLevel);
    
    end
  
    Bar.PopupTime = Bar.PopupTime + Elapsed;
  
    if Bar.PopupTime > Config.Warnings.Changing.PopupTime then
    
      Bar.PopupTime = nil;
      Bar:SetScale(1.0);
      Container:AuraAnchor(Bar.Aura, Bar.OrderPos);
      Bar:SetFrameLevel(PopupFrameLevelNormal);
    
    else
    
      local Scale = 1 + (((math_sin(-PI_2 + ((Bar.PopupTime / Config.Warnings.Changing.PopupTime) * PI2)) + 1) / 2) * (Config.Warnings.Changing.PopupScale - 1));
      
      Bar:SetScale(Scale);
      Container:AuraAnchor(Bar.Aura, Bar.OrderPos);
    
    end
  
  end

end


-----------------------------------------------------------------
-- Local Function BarOnMouseUp
-----------------------------------------------------------------
local function BarOnMouseUp(Bar, Button)

  if Button ~= "RightButton" then
    return;
  end

  if IsModifierKeyDown() == 1 then
  
    AuraFrames:DumpAura(Bar.Aura);

  else
  
    AuraFrames:CancelAura(Bar.Aura);

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

  -- Cleanup container bar pool
  while #self.BarPool > 0 do
  
    local Bar = tremove(self.BarPool);
  
    if LBF then
      self.LBFGroup:RemoveButton(Bar.Button, true);
    end
    
    Bar:ClearAllPoints();
    Bar:SetParent(nil);
    
    -- Release the bar in the general pool.
    tinsert(BarPool, Bar);
  
  end

end


-----------------------------------------------------------------
-- Function UpdateBarDisplay
-----------------------------------------------------------------
function Prototype:UpdateBarDisplay(Bar)

  local Aura = Bar.Aura;

  if self.Config.Layout.ShowDuration and Aura.ExpirationTime > 0 then
    
    Bar.Duration:Show();
  
  elseif Bar.Duration then

    Bar.Duration:Hide();
  
  end
  
  local Text = {};
  
  if self.Config.Layout.ShowAuraName then
    tinsert(Text, Aura.Name);
  end

  if self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    tinsert(Text, "["..Aura.Count.."]");
  
  end
  
  Bar.Text:SetText(tconcat(Text, " "));
  
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
    LBF:SetNormalVertexColor(Bar.Button, unpack(Color));
  end
  
  Bar.Button.Border:SetVertexColor(unpack(Color));
  Bar.Texture:SetVertexColor(unpack(Color));
  
  if self.Config.Layout.TextureBackgroundUseBarColor then
  
    Bar.Texture.Background:SetVertexColor(Color[1], Color[2], Color[3], self.Config.Layout.TextureBackgroundOpacity);
  
  else
  
    Bar.Texture.Background:SetVertexColor(unpack(self.Config.Layout.TextureBackgroundColor));
  
  end
  
  if self.Config.Layout.Icon ~= "NONE" then
  
    if self.Config.Layout.ButtonBackgroundUseBar == true then
    
      if self.Config.Layout.TextureBackgroundUseBarColor then
      
        Bar.Button.Background:SetVertexColor(Color[1], Color[2], Color[3], self.Config.Layout.ButtonBackgroundOpacity);
      
      else
      
        Bar.Button.Background:SetVertexColor(unpack(self.Config.Layout.TextureBackgroundColor));
      
      end
    
    else
    
      Bar.Button.Background:SetVertexColor(unpack(self.Config.Layout.ButtonBackgroundColor));
    
    end
    
    if self.Config.Layout.ShowCooldown == true and Aura.ExpirationTime > 0 then
      
      local CurrentTime = GetTime();

      if Aura.Duration > 0 then
        Bar.Button.Cooldown:SetCooldown(Aura.ExpirationTime - Aura.Duration, Aura.Duration);
      else
        Bar.Button.Cooldown:SetCooldown(CurrentTime, Aura.ExpirationTime - CurrentTime);
      end
      
      Bar.Button.Cooldown:Show();
    
    else
    
      Bar.Button.Cooldown:Hide();
    
    end
    
  end
  
  if Aura.ExpirationTime == 0 or (Aura.ExpirationTime ~= 0 and max(Aura.ExpirationTime - GetTime(), 0) > self.Config.Layout.BarMaxTime) then
    
    Bar.Texture:SetWidth(self.BarWidth);
    Bar.Texture:SetTexCoord(0, 1, 0, 1);
    
  end

  BarOnUpdate(self, Bar, 0.0);

end


-----------------------------------------------------------------
-- Function UpdateBar
-----------------------------------------------------------------
function Prototype:UpdateBar(Bar)

  local Container, Aura = self, Bar.Aura;
  
  Bar:SetWidth(self.Config.Layout.BarWidth);
  Bar:SetHeight(Module.BarHeight);
  
  Bar.Text:ClearAllPoints();
  Bar.Duration:ClearAllPoints();
  
  if self.Config.Layout.Icon == "NONE" then
    
    Bar.Button:Hide();
    Bar.Button.Background:Hide();
    
  elseif self.Config.Layout.Icon == "LEFT" then
  
    Bar.Button:ClearAllPoints();
    Bar.Button:SetPoint("TOPLEFT", Bar, "TOPLEFT", 0, 0);
    Bar.Button:Show();
    Bar.Button.Background:Show();
  
  elseif self.Config.Layout.Icon == "RIGHT" then
  
    Bar.Button:ClearAllPoints();
    Bar.Button:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", 0, 0);
    Bar.Button:Show();
    Bar.Button.Background:Show();

  end
  
  local Adjust = PositionMappings[self.Config.Layout.Icon][self.Config.Layout.TextPosition];
  Bar.Text:SetPoint(self.Config.Layout.TextPosition, Bar, self.Config.Layout.TextPosition, Adjust[1], Adjust[2]);

  Adjust = PositionMappings[self.Config.Layout.Icon][self.Config.Layout.DurationPosition];
  Bar.Duration:SetPoint(self.Config.Layout.DurationPosition, Bar, self.Config.Layout.DurationPosition, Adjust[1], Adjust[2]);
  
  Bar.Texture:ClearAllPoints();
  Bar.Texture:SetHeight(Module.BarHeight);
  Bar.Texture.Background:ClearAllPoints();
  Bar.Texture.Background:SetHeight(Module.BarHeight);
  Bar.Spark:ClearAllPoints();
  
  if self.Config.Layout.BarDirection == "LEFTGROW" or self.Config.Layout.BarDirection == "LEFTSHRINK" then
  
    Bar.Texture:SetPoint("TOPLEFT", Bar, "TOPLEFT", self.Config.Layout.Icon == "LEFT" and Module.BarHeight or 0, 0);
    Bar.Texture.Background:SetPoint("TOPLEFT", Bar, "TOPLEFT", self.Config.Layout.Icon == "LEFT" and Module.BarHeight or 0, 0);
    Bar.Texture.Background:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT", self.Config.Layout.Icon == "RIGHT" and -Module.BarHeight or 0, 0);
    Bar.Spark:SetPoint("CENTER", Bar.Texture, "RIGHT", 0, -2);
    
  else

    Bar.Texture:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", self.Config.Layout.Icon == "RIGHT" and -Module.BarHeight or 0, 0);
    Bar.Texture.Background:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", self.Config.Layout.Icon == "RIGHT" and -Module.BarHeight or 0, 0);
    Bar.Texture.Background:SetPoint("BOTTOMLEFT", Bar, "BOTTOMLEFT", self.Config.Layout.Icon == "LEFT" and Module.BarHeight or 0, 0);
    Bar.Spark:SetPoint("CENTER", Bar.Texture, "LEFT", 0, -2);
  
  end
  
  Bar.Texture:SetTexture(LSM:Fetch("statusbar", self.Config.Layout.BarTexture));
  
  if self.Config.Layout.TextureBackgroundUseTexture == true then
    Bar.Texture.Background:SetTexture(LSM:Fetch("statusbar", self.Config.Layout.BarTexture));
  else
    Bar.Texture.Background:SetTexture(1, 1, 1, 1);
  end
  
  if self.Config.Layout.ShowTooltip then
  
    Bar:SetScript("OnEnter", function() AuraFrames:ShowTooltip(Bar.Aura, Bar, self.TooltipOptions); end);
    Bar:SetScript("OnLeave", function() AuraFrames:HideTooltip(); end);
  
    Bar.Button:SetScript("OnEnter", function() AuraFrames:ShowTooltip(Bar.Aura, Bar, self.TooltipOptions); end);
    Bar.Button:SetScript("OnLeave", function() AuraFrames:HideTooltip(); end);
  
  else
  
    Bar:SetScript("OnEnter", nil);
    Bar:SetScript("OnLeave", nil);

    Bar.Button:SetScript("OnEnter", nil);
    Bar.Button:SetScript("OnLeave", nil);
  
  end
  
  Bar.Texture.Background:SetWidth(self.Config.Layout.BarWidth);
  
  if self.Config.Layout.Clickable then
    
    Bar:EnableMouse(true);
    Bar:SetScript("OnMouseUp", BarOnMouseUp);
    Bar:HookScript("OnEnter", function() AuraFrames:SetCancelAuraFrame(Bar, Bar.Aura); end);

    Bar.Button:EnableMouse(true);
    Bar.Button:RegisterForClicks("RightButtonUp");
    Bar.Button:SetScript("OnClick", function(_, Button) BarOnMouseUp(Bar, Button) end);
    Bar.Button:HookScript("OnEnter", function() AuraFrames:SetCancelAuraFrame(Bar.Button, Bar.Aura); end);

  else
    
    Bar:EnableMouse(false);
    Bar:SetScript("OnMouseUp", nil);
    
    Bar.Button:EnableMouse(false);
    Bar.Button:SetScript("OnClick", nil);
    
  end
  
  -- Set cooldown options
  Bar.Button.Cooldown:SetDrawEdge(self.Config.Layout.CooldownDrawEdge);
  Bar.Button.Cooldown:SetReverse(self.Config.Layout.CooldownReverse);
  Bar.Button.Cooldown.noCooldownCount = self.Config.Layout.CooldownDisableOmniCC;
  
  self:UpdateBarDisplay(Bar);

end


-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Prototype:Update(...)

  local Changed = select(1, ...) or "ALL";
  
  if Changed == "ALL" or Changed == "LAYOUT" then

    self.Frame:SetWidth(self.Config.Layout.BarWidth);
    self.Frame:SetHeight((self.Config.Layout.NumberOfBars * Module.BarHeight) + ((self.Config.Layout.NumberOfBars - 1) * self.Config.Layout.Space));
    
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
    }
    
    if self.Config.Layout.Icon == "NONE" then
    
      self.BarWidth = self.Config.Layout.BarWidth;
      
    else
    
      self.BarWidth = self.Config.Layout.BarWidth - Module.BarHeight;
    
    end
    
    if self.Config.Layout.BarDirection == "LEFTSHRINK" or self.Config.Layout.BarDirection == "RIGHTSHRINK" then
      self.Shrink = true;
    else
      self.Shrink = false;
    end
  
    -- 1.0 is the min.
    self.WidthPerSecond = (self.BarWidth - 1) / self.Config.Layout.BarMaxTime;
    
    local Flags = {};

    if self.Config.Layout.TextOutline and self.Config.Layout.TextOutline ~= "NONE" then
      tinsert(Flags, self.Config.Layout.TextOutline);
    end

    if self.Config.Layout.TextMonochrome == true then
      tinsert(Flags, "MONOCHROME");
    end

    self.FontObject:SetFont(LSM:Fetch("font", self.Config.Layout.TextFont), self.Config.Layout.TextSize, tconcat(Flags, ","));
    self.FontObject:SetTextColor(unpack(self.Config.Layout.TextColor));
    
    self.Direction = DirectionMapping[self.Config.Layout.Direction];
    
    for _, Bar in pairs(self.Bars) do
      self:UpdateBar(Bar);
    end
    
    -- Anchor all bars.
    self.AuraList:AnchorAllAuras();

    -- We have bars in the container pool that doesn't match the settings anymore. Release them into the general pool.
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
  
  -- Pop the last bar out the container pool.
  local Bar = tremove(self.BarPool);
  local FromContainerPool = Bar and true or false;
  
  if not Bar then
  
    -- Try the general pool.
    Bar = tremove(BarPool);
    
    if not Bar then
      -- No bars in any pool. Let's make a new bar.
  
      BarCounter = BarCounter + 1;
    
      local BarId = "AuraFramesBar"..BarCounter;
      Bar = CreateFrame("Frame", BarId, self.Frame, "AuraFramesBarTemplate");
      
      Bar.Text = _G[BarId.."Text"];
      Bar.Duration = _G[BarId.."Duration"];
      Bar.Texture = _G[BarId.."Texture"];
      Bar.Texture.Background = _G[BarId.."TextureBackground"];
      Bar.Spark = _G[BarId.."Spark"];
      
      Bar.Button = _G[BarId.."Button"];
      Bar.Button.Icon = _G[BarId.."ButtonIcon"];
      Bar.Button.Border = _G[BarId.."ButtonBorder"];
      Bar.Button.Background = _G[BarId.."ButtonBackground"];
      Bar.Button.Cooldown = _G[BarId.."ButtonCooldown"];
  
    else
    
      Bar:SetParent(self.Frame);
    
    end
  
    -- We got a general pool bar or a new bar.
    -- Prepare it so it match a container pool bar.

    local Container = self;  
    Bar:SetScript("OnUpdate", function(Bar, Elapsed)
      
       Bar.TimeSinceLastUpdate = Bar.TimeSinceLastUpdate + Elapsed;
       if Bar.TimeSinceLastUpdate > BarUpdatePeriod then
          BarOnUpdate(Container, Bar, Bar.TimeSinceLastUpdate);
          Bar.TimeSinceLastUpdate = 0.0;
       end
      
    end);
  
    if LBF then
      -- We Don't have count text.
      self.LBFGroup:AddButton(Bar.Button, {Icon = Bar.Button.Icon, Border = Bar.Button.Border, Count = false, Cooldown = Bar.Button.Cooldown});
    end
  
    -- Set the font from this container.
    Bar.Text:SetFontObject(self.FontObject);
    Bar.Duration:SetFontObject(self.FontObject);
    
    -- Set cooldown options
    Bar.Button.Cooldown:SetDrawEdge(self.Config.Layout.CooldownDrawEdge);
    Bar.Button.Cooldown:SetReverse(self.Config.Layout.CooldownReverse);
  
  end
  
  Bar.NewFlashTime = self.NewFlashTime;
  Bar.ExpireFlashTime = self.ExpireFlashTime;
  
  Bar.TimeSinceLastUpdate = 0.0;
  Bar.TimeLeftSeconds = 0;
  
  Bar.Button.Icon:SetTexture(Aura.Icon);
    
  Bar.Aura = Aura;
  
  self.Bars[Aura] = Bar;
  
  if self.Config.Layout.ShowCooldown == true and Aura.ExpirationTime > 0 then
    
    local CurrentTime = GetTime();
    
    if Aura.Duration then
      Bar.Button.Cooldown:SetCooldown(Aura.ExpirationTime - Aura.Duration, Aura.ExpirationTime - CurrentTime);
    else
      Bar.Button.Cooldown:SetCooldown(CurrentTime, Aura.ExpirationTime - CurrentTime);
    end
    
    Bar.Button.Cooldown:Show();
  
  else
  
    Bar.Button.Cooldown:Hide();
  
  end
  
  if FromContainerPool == true then
  
    -- We need only a display update.
    self:UpdateBarDisplay(Bar);
  
  else
  
    -- We need a full update.
    self:UpdateBar(Bar);
  
  end

end


-----------------------------------------------------------------
-- Function AuraOld
-----------------------------------------------------------------
function Prototype:AuraOld(Aura)

  if not self.Bars[Aura] then
    return
  end
  
  local Bar = self.Bars[Aura];
  
  -- Remove the bar from the container list.
  self.Bars[Aura] = nil;
  
  Bar:Hide();
  
  if AuraFrames:IsTooltipOwner(Bar) == true then
    AuraFrames:HideTooltip();
  end
  
  -- The warning system can have changed the alpha and scale. Set it back.
  Bar.Button.Icon:SetAlpha(1.0);
  Bar.Texture:SetAlpha(1.0);
  Bar:SetScale(1.0);
  
  -- Reset popup animation trigger and restore the frame level.
  Bar.PopupTime = nil;
  Bar:SetFrameLevel(PopupFrameLevelNormal);
  
  -- See in what pool we need to drop.
  if #self.BarPool >= ContainerBarPoolSize then
  
    -- General pool.
  
    if LBF then
      self.LBFGroup:RemoveButton(Bar.Button, true);
    end
  
    Bar:ClearAllPoints();
    Bar:SetParent(nil);
    
    Bar:SetScript("OnUpdate", nil);

    -- Release the bar back in the general pool for later use.
    tinsert(BarPool, Bar);
  
  else
  
    -- Release the bar back in the container pool for later use.
    tinsert(self.BarPool, Bar);
    
  end

end


-----------------------------------------------------------------
-- Function AuraChanged
-----------------------------------------------------------------
function Prototype:AuraChanged(Aura)

  if not self.Bars[Aura] then
    return
  end
  
  local Bar = self.Bars[Aura];
  
  local Text = {};
  
  if self.Config.Layout.ShowAuraName then
    tinsert(Text, Aura.Name);
  end

  if self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    tinsert(Text, "["..Aura.Count.."]");
  
  end
  
  Bar.Text:SetText(tconcat(Text, " "));
  
  -- Start popup animation.
  Bar.PopupTime = 0.0;

end


-----------------------------------------------------------------
-- Function AuraAnchor
-----------------------------------------------------------------
function Prototype:AuraAnchor(Aura, Index)

  local Bar = self.Bars[Aura];

  -- Save the order position.
  Bar.OrderPos = Index;

  -- Hide bar if the index is greater then the maximum number of bars to anchor
  if Index > self.Config.Layout.NumberOfBars then
  
    Bar:Hide();
    return;
    
  end
  
  local Scale = Bar:GetScale();
  
  Bar:ClearAllPoints();
  
  Bar:SetPoint(
    "CENTER",
    self.Frame,
    self.Direction[1],
    (Bar:GetWidth() / 2) / Scale,
    ((self.Direction[2] * ((Index - 1) * (Module.BarHeight + self.Config.Layout.Space))) + ((Module.BarHeight / 2) * self.Direction[2])) / Scale
  );

  Bar:Show();
  
end

