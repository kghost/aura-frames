local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("BarContainer");
local MSQ = LibStub("Masque", true);
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
-- Local Function SetBarCoords
-----------------------------------------------------------------
local function SetBarCoords(Texture, FlipX, FlipY, Rotate, TexStart, TexEnd)

  local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = 0, 0, 0, 1, 1, 0, 1, 1;
  
  if FlipX == true then
  
    ULy, LLy = LLy, ULy; -- Flip upper left to lower left.
    URy, LRy = LRy, URy; -- Flip upper right to lower right.
  
  end
  
  if FlipY == true then
  
    ULx, URx = URx, ULx; -- Flip upper left to upper right.
    LLx, LRx = LRx, LLx; -- Flip lower left to lower right.
  
  end
  
  if Rotate == true then
  
    -- We rotate 90 degrees to the right.
    
    ULx, ULy, URx, URy, LRx, LRy, LLx, LLy = LLx, LLy, ULx, ULy, URx, URy, LRx, LRy;
    
  end
  
  if Rotate == true then
  
    Texture:SetTexCoord(
      ULx,
      ULy == 0 and TexStart or 1 - TexStart,
      LLx,
      LLy == 0 and TexStart or 1 - TexStart,
      URx,
      URy == 0 and 1 - TexEnd or TexEnd,
      LRx,
      LRy == 0 and 1 - TexEnd or TexEnd
    );
  
  else
  
    Texture:SetTexCoord(
      ULx == 0 and TexStart or 1 - TexStart,
      ULy,
      LLx == 0 and TexStart or 1 - TexStart,
      LLy,
      URx == 0 and 1 - TexEnd or TexEnd,
      URy,
      LRx == 0 and 1 - TexEnd or TexEnd,
      LRy
    );
  
  end

end


-----------------------------------------------------------------
-- Local Function BarOnUpdate
-----------------------------------------------------------------
local function BarOnUpdate(Container, Bar, Elapsed)

  local Config = Container.Config;
  
  local TexStart, TexEnd = 0, 1;
  
  if Bar.Aura.ExpirationTime ~= 0 then
    
    local TimeLeft = max(Bar.Aura.ExpirationTime - GetTime(), 0);
    
    if Container.Config.Layout.ShowDuration == true then
    
      local TimeLeftSeconds = math_ceil((TimeLeft + 0.5) * 10);
      
      if Bar.TimeLeftSeconds ~= TimeLeftSeconds then
    
        Bar.Duration:SetFormattedText(AuraFrames:FormatTimeLeft(Config.Layout.DurationLayout, TimeLeft, false));
      
        Bar.TimeLeftSeconds = TimeLeftSeconds;
      
      end
    
    end
    
    if TimeLeft < Bar.BarMaxTime then
    
      local Part = TimeLeft / Bar.BarMaxTime;
    
      if Container.Shrink then
        Bar.Bar:SetWidth((Bar.WidthPerSecond * TimeLeft) + 1.0);
      else
        Bar.Bar:SetWidth(Container.BarWidth - (Bar.WidthPerSecond * TimeLeft));
      end
      
      local Part = TimeLeft / Bar.BarMaxTime;
      local Left, Right;
      
      if Container.Config.Layout.BarDirection == "LEFTGROW" then
        
        TexStart, TexEnd = 0, 1 - Part;

      elseif Container.Config.Layout.BarDirection == "RIGHTGROW" then

        TexStart, TexEnd = 1 - Part, 0;

      elseif Container.Config.Layout.BarDirection == "LEFTSHRINK" then

        TexStart, TexEnd = 0, Part;

      else -- RIGHTSHRINK

        TexStart, TexEnd = Part, 0;

      end
      
      if Container.Config.Layout.BarTextureMove then
        TexStart, TexEnd = 1 - TexEnd, 1 - TexStart;
      end
      
    else
      
      if Container.Config.Layout.BarDirection == "LEFTGROW" or Container.Config.Layout.BarDirection == "RIGHTGROW" then
      
        Bar.Bar:SetWidth(1);
      
      else
      
        Bar.Bar:SetWidth(Container.BarWidth);
      
      end
      
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
      Bar.Bar:SetAlpha(Alpha);
    
    elseif Bar.NewFlashTime and Bar.Aura.Duration ~= 0 then
    
      local TimeFromStart = Bar.Aura.Duration - TimeLeft;
      
      if TimeFromStart < Bar.NewFlashTime then
      
        -- See the ExpireFlash. The only difference is that we start with
        -- Alpha(0.15) and that we are ending with Alpha(1.0).
      
        local Alpha = ((math_cos((((TimeFromStart % Config.Warnings.New.FlashSpeed) / Config.Warnings.New.FlashSpeed) * PI2) + PI) / 2 + 0.5) * 0.85) + 0.15;
      
        Bar.Button.Icon:SetAlpha(Alpha);
        Bar.Bar:SetAlpha(Alpha);
      
      else
        
        -- At the end of the new flash animation make sure that we end
        -- with SetAlpha(1.0) and that we stop the animation.
      
        Bar.NewFlashTime = nil;
        Bar.Button.Icon:SetAlpha(1.0);
        Bar.Bar:SetAlpha(1.0);
      
      end
    
    end
  
  else
  
    if Container.Config.Layout.BarDirection == "LEFTGROW" or Container.Config.Layout.BarDirection == "RIGHTGROW" then
    
      Bar.Bar:SetWidth(Container.BarWidth);
    
    else
    
      Bar.Bar:SetWidth(1);
    
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
  
  SetBarCoords(Bar.Bar.Texture, Container.Config.Layout.BarTextureFlipX, Container.Config.Layout.BarTextureFlipY, Container.Config.Layout.BarTextureRotate, TexStart, TexEnd);
  
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

  if self.MSQGroup then
    self.MSQGroup:Delete(true);
  end


end

-----------------------------------------------------------------
-- Function ReleasePool
-----------------------------------------------------------------
function Prototype:ReleasePool()

  -- Cleanup container bar pool
  while #self.BarPool > 0 do
  
    local Bar = tremove(self.BarPool);
  
    if MSQ then
      self.MSQGroup:RemoveButton(Bar.Button, true);
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

  if self.Config.Layout.ShowCount and Aura.Count > 1 then
  
    tinsert(Text, "["..Aura.Count.."]");
  
  end
  
  Bar.Text:SetText(tconcat(Text, " "));
  
  self:AuraEvent(Aura, "ColorChanged");
  
  if self.Config.Layout.Icon ~= "NONE" then
  
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
  
  Bar.BarMaxTime = self.Config.Layout.BarUseAuraTime and Aura.Duration or self.Config.Layout.BarMaxTime;
  
  -- 1 is the min.
  Bar.WidthPerSecond = (self.BarWidth - 1) / Bar.BarMaxTime;
  
  BarOnUpdate(self, Bar, 0.0);

end


-----------------------------------------------------------------
-- Function UpdateBar
-----------------------------------------------------------------
function Prototype:UpdateBar(Bar)

  local Container, Aura = self, Bar.Aura;
  
  Bar:SetWidth(self.Config.Layout.BarWidth);
  Bar:SetHeight(self.Config.Layout.BarHeight);
  
  Bar.Text:ClearAllPoints();
  Bar.Duration:ClearAllPoints();
  
  if self.Config.Layout.Icon == "NONE" then
    
    Bar.Button:Hide();
    
  elseif self.Config.Layout.Icon == "LEFT" then
  
    Bar.Button:ClearAllPoints();
    Bar.Button:SetPoint("TOPLEFT", Bar, "TOPLEFT", 0, 0);
    Bar.Button:Show();
  
  elseif self.Config.Layout.Icon == "RIGHT" then
  
    Bar.Button:ClearAllPoints();
    Bar.Button:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", 0, 0);
    Bar.Button:Show();

  end
  
  local Adjust = self.PositionMappings[self.Config.Layout.Icon][self.Config.Layout.TextPosition];
  Bar.Text:SetPoint(self.Config.Layout.TextPosition, Bar, self.Config.Layout.TextPosition, Adjust[1], Adjust[2]);
  Bar.Text:SetWidth(self.Config.Layout.BarWidth - ((self.Config.Layout.Icon == "NONE" and self.Config.Layout.BarHeight or 0) + (self.Config.Layout.ShowDuration and 60 or 0) + 20));
  Bar.Text:SetJustifyH(self.Config.Layout.TextPosition);
  
  Adjust = self.PositionMappings[self.Config.Layout.Icon][self.Config.Layout.DurationPosition];
  Bar.Duration:SetPoint(self.Config.Layout.DurationPosition, Bar, self.Config.Layout.DurationPosition, Adjust[1], Adjust[2]);
  
  Bar.Bar:ClearAllPoints();
  Bar.Bar:SetHeight(self.Config.Layout.BarHeight);
  Bar.Bar.Background:ClearAllPoints();
  Bar.Bar.Background:SetHeight(self.Config.Layout.BarHeight);
  Bar.Bar.Spark:ClearAllPoints();
  
  if self.Config.Layout.BarDirection == "LEFTGROW" or self.Config.Layout.BarDirection == "LEFTSHRINK" then
  
    Bar.Bar:SetPoint("TOPLEFT", Bar, "TOPLEFT", self.Config.Layout.Icon == "LEFT" and self.Config.Layout.BarHeight or 0, 0);
    Bar.Bar.Background:SetPoint("TOPLEFT", Bar, "TOPLEFT", self.Config.Layout.Icon == "LEFT" and self.Config.Layout.BarHeight or 0, 0);
    Bar.Bar.Background:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT", self.Config.Layout.Icon == "RIGHT" and -self.Config.Layout.BarHeight or 0, 0);
    Bar.Bar.Spark:SetPoint("CENTER", Bar.Bar, "RIGHT", 0, -2);
    
  else

    Bar.Bar:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", self.Config.Layout.Icon == "RIGHT" and -self.Config.Layout.BarHeight or 0, 0);
    Bar.Bar.Background:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", self.Config.Layout.Icon == "RIGHT" and -self.Config.Layout.BarHeight or 0, 0);
    Bar.Bar.Background:SetPoint("BOTTOMLEFT", Bar, "BOTTOMLEFT", self.Config.Layout.Icon == "LEFT" and self.Config.Layout.BarHeight or 0, 0);
    Bar.Bar.Spark:SetPoint("CENTER", Bar.Bar, "LEFT", 0, -2);
  
  end
  
  if self.Config.Layout.ShowSpark then
  
    Bar.Bar.Spark:Show();
    
    if not self.Config.Layout.SparkUseBarColor then
    
      Bar.Bar.Spark:SetVertexColor(unpack(self.Config.Layout.SparkColor));
    
    end
  
  else
  
    Bar.Bar.Spark:Hide();
  
  end
  
  Bar.Bar.Texture:SetTexture(LSM:Fetch("statusbar", self.Config.Layout.BarTexture));

  AuraFrames:SetBorder(Bar.Bar, LSM:Fetch("border", self.Config.Layout.BarBorder), self.Config.Layout.BarBorderSize);

  Bar.Bar.Texture:SetPoint("TOPLEFT", Bar.Bar, "TOPLEFT", self.Config.Layout.BarTextureInsets, -self.Config.Layout.BarTextureInsets);
  Bar.Bar.Texture:SetPoint("BOTTOMRIGHT", Bar.Bar, "BOTTOMRIGHT", -self.Config.Layout.BarTextureInsets, self.Config.Layout.BarTextureInsets);
  
  if self.Config.Layout.TextureBackgroundUseTexture == true then
    
    Bar.Bar.Background.Texture:SetTexture(LSM:Fetch("statusbar", self.Config.Layout.BarTexture));
    
    Bar.Bar.Background:SetBackdrop({
      edgeFile = LSM:Fetch("border", self.Config.Layout.BarBorder),
      edgeSize = self.Config.Layout.BarBorderSize,
    });
    
    Bar.Bar.Background.Texture:SetPoint("TOPLEFT", Bar.Bar.Background, "TOPLEFT", self.Config.Layout.BarTextureInsets, -self.Config.Layout.BarTextureInsets);
    Bar.Bar.Background.Texture:SetPoint("BOTTOMRIGHT", Bar.Bar.Background, "BOTTOMRIGHT", -self.Config.Layout.BarTextureInsets, self.Config.Layout.BarTextureInsets);
    
    SetBarCoords(Bar.Bar.Background.Texture, self.Config.Layout.BarTextureFlipX, self.Config.Layout.BarTextureFlipY, self.Config.Layout.BarTextureRotate, 0, 1);
    
  else
  
    Bar.Bar.Background.Texture:SetTexture(1.0, 1.0, 1.0, 1.0);

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
  
  Bar.Bar.Background:SetWidth(self.Config.Layout.BarWidth);
  
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

  self.PositionMappings = {
    NONE = {
      LEFT = {5, 0},
      RIGHT = {-5, 0},
      CENTER = {0, 0},
    },
    LEFT = {
      LEFT = {5 + self.Config.Layout.BarHeight, 0},
      RIGHT = {-5, 0},
      CENTER = {self.Config.Layout.BarHeight / 2, 0},
    },
    RIGHT = {
      LEFT = {5, 0},
      RIGHT = {-5 - self.Config.Layout.BarHeight, 0},
      CENTER = {-(self.Config.Layout.BarHeight / 2), 0},
    },
  };

  local Changed = select(1, ...) or "ALL";
  
  if Changed == "ALL" or Changed == "LAYOUT" then

    self.Frame:SetWidth(self.Config.Layout.BarWidth);
    self.Frame:SetHeight((self.Config.Layout.NumberOfBars * self.Config.Layout.BarHeight) + ((self.Config.Layout.NumberOfBars - 1) * self.Config.Layout.Space));
    
    self.Frame:SetScale(self.Config.Layout.Scale);
    
    if self.Unlocked ~= true then
    
      self.Frame:ClearAllPoints();
      self.Frame:SetPoint(self.Config.Location.FramePoint, self.Config.Location.RelativeTo, self.Config.Location.RelativePoint, self.Config.Location.OffsetX, self.Config.Location.OffsetY);
      
    end
    
    self.TooltipOptions = {
      ShowPrefix = self.Config.Layout.TooltipShowPrefix,
      ShowCaster = self.Config.Layout.TooltipShowCaster,
      ShowAuraId = self.Config.Layout.TooltipShowAuraId,
      ShowClassification = self.Config.Layout.TooltipShowClassification,
    }
    
    if self.Config.Layout.Icon == "NONE" then
    
      self.BarWidth = self.Config.Layout.BarWidth;
      
    else
    
      self.BarWidth = self.Config.Layout.BarWidth - self.Config.Layout.BarHeight;
    
    end
    
    if self.Config.Layout.BarDirection == "LEFTSHRINK" or self.Config.Layout.BarDirection == "RIGHTSHRINK" then
      self.Shrink = true;
    else
      self.Shrink = false;
    end
    
    AuraFrames:SetFontObjectProperties(
      self.FontObject,
      self.Config.Layout.TextFont,
      self.Config.Layout.TextSize,
      self.Config.Layout.TextOutline,
      self.Config.Layout.TextMonochrome,
      self.Config.Layout.TextColor
    );
    
    self.Direction = DirectionMapping[self.Config.Layout.Direction];
    
    for _, Bar in pairs(self.Bars) do
    
      Bar.Button:SetWidth(self.Config.Layout.BarHeight);
      Bar.Button:SetHeight(self.Config.Layout.BarHeight);
      
      Bar.Bar.Spark:SetWidth(self.Config.Layout.BarHeight);
      Bar.Bar.Spark:SetHeight(self.Config.Layout.BarHeight * 2.5);
      
    end
    
    if MSQ then
      self.MSQGroup:ReSkin();
    end
    
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
-- Function AuraEvent
-----------------------------------------------------------------
function Prototype:AuraEvent(Aura, Event, ...)

  local Bar = self.Bars[Aura];

  if Event == "ColorChanged" then
  
    Bar.Button.Border:SetVertexColor(unpack(Aura.Color));
    Bar.Bar.Texture:SetVertexColor(unpack(Aura.Color));
    AuraFrames:SetBorderColor(Bar.Bar, min(Aura.Color[1] * self.Config.Layout.BarBorderColorAdjust, 1), min(Aura.Color[2] * self.Config.Layout.BarBorderColorAdjust, 1), min(Aura.Color[3] * self.Config.Layout.BarBorderColorAdjust, 1), Aura.Color[4]);
    
    if self.Config.Layout.ShowSpark and self.Config.Layout.SparkUseBarColor then
    
      Bar.Bar.Spark:SetVertexColor(unpack(Aura.Color));
    
    end
    
    if self.Config.Layout.TextureBackgroundUseBarColor then
    
      Bar.Bar.Background.Texture:SetVertexColor(Aura.Color[1], Aura.Color[2], Aura.Color[3], self.Config.Layout.TextureBackgroundOpacity);
      Bar.Bar.Background:SetBackdropBorderColor(min(Aura.Color[1] * self.Config.Layout.BarBorderColorAdjust, 1), min(Aura.Color[2] * self.Config.Layout.BarBorderColorAdjust, 1), min(Aura.Color[3] * self.Config.Layout.BarBorderColorAdjust, 1), self.Config.Layout.TextureBackgroundOpacity);
    
    else
    
      Bar.Bar.Background.Texture:SetVertexColor(unpack(self.Config.Layout.TextureBackgroundColor));
      Bar.Bar.Background:SetBackdropBorderColor(min(self.Config.Layout.TextureBackgroundColor[1] * self.Config.Layout.BarBorderColorAdjust, 1), min(self.Config.Layout.TextureBackgroundColor[2] * self.Config.Layout.BarBorderColorAdjust, 1), min(self.Config.Layout.TextureBackgroundColor[3] * self.Config.Layout.BarBorderColorAdjust, 1), self.Config.Layout.TextureBackgroundColor[4]);
    
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
      
      Bar.Bar = _G[BarId.."Bar"];
      Bar.Bar.Texture = _G[BarId.."BarTexture"];
      Bar.Bar.Spark = _G[BarId.."BarSpark"];
      Bar.Bar.Background = _G[BarId.."BarBackground"];
      Bar.Bar.Background.Texture = _G[BarId.."BarBackgroundTexture"];
      
      Bar.Button = _G[BarId.."Button"];
      Bar.Button.Icon = _G[BarId.."ButtonIcon"];
      Bar.Button.Border = _G[BarId.."ButtonBorder"];
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
    
    Bar.Button:SetWidth(self.Config.Layout.BarHeight);
    Bar.Button:SetHeight(self.Config.Layout.BarHeight);
    
    Bar.Bar.Spark:SetWidth(self.Config.Layout.BarHeight);
    Bar.Bar.Spark:SetHeight(self.Config.Layout.BarHeight * 2.5);
  
    -- Set the font from this container.
    Bar.Text:SetFontObject(self.FontObject);
    Bar.Duration:SetFontObject(self.FontObject);
    
    if MSQ then
    
      -- We Don't have count text.
      self.MSQGroup:AddButton(Bar.Button, {Icon = Bar.Button.Icon, Border = Bar.Button.Border, Count = false, Duration = false, Cooldown = Bar.Button.Cooldown});
    
    else
    
      Bar.Button.Border:SetAllPoints(Bar.Button);
      Bar.Button.Cooldown:SetAllPoints(Bar.Button);
    
    end
    
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
  Bar.Bar:SetAlpha(1.0);
  Bar:SetScale(1.0);
  
  -- Reset popup animation trigger and restore the frame level.
  Bar.PopupTime = nil;
  Bar:SetFrameLevel(PopupFrameLevelNormal);
  
  -- See in what pool we need to drop.
  if #self.BarPool >= ContainerBarPoolSize then
  
    -- General pool.
  
    if MSQ then
      self.MSQGroup:RemoveButton(Bar.Button, true);
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

  if self.Config.Layout.ShowCount and Aura.Count > 1 then
  
    tinsert(Text, "["..Aura.Count.."]");
  
  end
  
  Bar.Text:SetText(tconcat(Text, " "));
  
  -- Start popup animation.
  Bar.PopupTime = 0.0;
  
  BarOnUpdate(self, Bar, 0.0);

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
    ((self.Direction[2] * ((Index - 1) * (self.Config.Layout.BarHeight + self.Config.Layout.Space))) + ((self.Config.Layout.BarHeight / 2) * self.Direction[2])) / Scale
  );

  Bar:Show();
  
end

