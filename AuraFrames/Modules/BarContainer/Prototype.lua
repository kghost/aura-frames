local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("BarContainer");
local LibAura = LibStub("LibAura-1.0");
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


local BarUpdatePeriod = 0.05;


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

  if Bar.Aura.ExpirationTime ~= 0 then
  
    local Config = Container.Config;
    
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
        Left, Right = Right, Left;
      end
      
      Bar.Texture:SetTexCoord(Left, Right, 0, 1);
      
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

  -- Remove our self from LibAura.
  LibAura:UnregisterObjectSource(self, nil, nil);
  
  Module.Containers[self.Config.Id] = nil;

  self.Frame:Hide();
  self.Frame:UnregisterAllEvents();
  self.Frame = nil;
  
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
  Bar.Spark:ClearAllPoints();
  
  if self.Config.Layout.BarDirection == "LEFTGROW" or self.Config.Layout.BarDirection == "LEFTSHRINK" then
  
    Bar.Texture:SetPoint("TOPLEFT", Bar, "TOPLEFT", self.Config.Layout.Icon == "LEFT" and Module.BarHeight or 0, 0);
    Bar.Texture.Background:SetPoint("TOPLEFT", Bar, "TOPLEFT", self.Config.Layout.Icon == "LEFT" and Module.BarHeight or 0, 0);
    Bar.Spark:SetPoint("CENTER", Bar.Texture, "RIGHT", 0, 0);
    
  else

    Bar.Texture:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", self.Config.Layout.Icon == "RIGHT" and -Module.BarHeight or 0, 0);
    Bar.Texture.Background:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", self.Config.Layout.Icon == "RIGHT" and -Module.BarHeight or 0, 0);
    Bar.Spark:SetPoint("CENTER", Bar.Texture, "LEFT", 0, 0);
  
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
    
    for _, Bar in pairs(self.Bars) do
      self:UpdateBar(Bar);
    end
    
    -- We have bars in the container pool that doesn't match the settings anymore. Release them into the general pool.
    self:ReleasePool();
    
    if Changed ~= "ALL" then
      self:UpdateAnchors();
    end

  end
  
  if Changed == "ALL" or Changed == "FILTER" then

    -- Delete all current auras.
    for _, Bar in pairs(self.Bars) do
      self:AuraOld(Bar.Aura);
    end
    
    -- Resync all auras
    LibAura:ObjectSync(self, nil, nil);

  end
  
  if Changed == "ALL" or Changed == "ORDER" then
  
    self:UpdateAnchors();
  
  end

end


-----------------------------------------------------------------
-- Function AuraNew
-----------------------------------------------------------------
function Prototype:AuraNew(Aura)

  if self.Filter and self.Filter.Test(Aura) == false then
    return;
  end
  
  if self.Bars[Aura.Id] then
  
    AuraFrames:Print("Double aura trying to be added!!! Id: "..Aura.Id);
    return;
  
  end
  
  -- Pop the last button out the container pool.
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
  
  Bar.TimeSinceLastUpdate = 0.0;
  Bar.TimeLeftSeconds = 0;
  
  Bar.Button.Icon:SetTexture(Aura.Icon);
    
  Bar.Aura = Aura;
  
  self.Bars[Aura.Id] = Bar;
  self.Order:Add(Bar);
  
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
  
  self:UpdateAnchors();

end


-----------------------------------------------------------------
-- Function AuraOld
-----------------------------------------------------------------
function Prototype:AuraOld(Aura)

  if not self.Bars[Aura.Id] then
    return
  end
  
  local Bar = self.Bars[Aura.Id];
  
  -- Remove the bar from the container list.
  self.Bars[Aura.Id] = nil;
  
  -- Remove the bar from the container order list.
  self.Order:Remove(Bar);
  
  Bar:Hide();
  
  if AuraFrames:IsTooltipOwner(Bar) == true then
    AuraFrames:HideTooltip();
  end
  
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
  
  self:UpdateAnchors();

end


-----------------------------------------------------------------
-- Function AuraChanged
-----------------------------------------------------------------
function Prototype:AuraChanged(Aura)

  if not self.Bars[Aura.Id] then
    return
  end
  
  local Bar = self.Bars[Aura.Id];
  
  local Text = {};
  
  if self.Config.Layout.ShowAuraName then
    tinsert(Text, Aura.Name);
  end

  if self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    tinsert(Text, "["..Aura.Count.."]");
  
  end
  
  Bar.Text:SetText(tconcat(Text, " "));
  
  self.Order:Update(Bar);

  self:UpdateAnchors();

end


-----------------------------------------------------------------
-- Function UpdateAnchors
-----------------------------------------------------------------
function Prototype:UpdateAnchors()

  -- Maximune number of bars to anchor.
  local Max = min(#self.Order, self.Config.Layout.NumberOfBars);

  local i, x, y;
  local Direction = DirectionMapping[self.Config.Layout.Direction];

  -- Anchor the bars in the correct order.
  for i = 1, #self.Order do
  
    self.Order[i]:ClearAllPoints();

    if i > Max then

      self.Order[i]:Hide();

    else
      
      self.Order[i]:SetPoint(
        Direction[1],
        self.Frame,
        Direction[1],
        0,
        Direction[2] * ((i - 1) * (Module.BarHeight + self.Config.Layout.Space))
      );

      self.Order[i]:Show();
    
    end
  
  end
  
end