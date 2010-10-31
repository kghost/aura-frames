local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("BarContainer");
local LibAura = LibStub("LibAura-1.0");
local LSM = LibStub("LibSharedMedia-3.0");
local LBF = LibStub("LibButtonFacade");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;
local math_sin, math_cos, math_floor, math_ceil = math.sin, math.cos, math.floor, math.ceil;

local Prototype = Module.Prototype;


-- Pool that contains all the current unused bars sorted by type.
local BarPool = {};

-- Counters for each Bar type.
local BarCounter = 0;


-- Direction = {AnchorPoint, first X or Y, X Direction, Y Direction}
local DirectionMapping = {
  DOWN  = {"TOPLEFT",    -1},
  UP    = {"BOTTOMLEFT",  1},
};


local BarUpdatePeriod = 0.05;


-----------------------------------------------------------------
-- Local Function BarOnUpdate
-----------------------------------------------------------------
local function BarOnUpdate(Container, Bar, Elapsed)

  if Bar.Aura.ExpirationTime ~= 0 then
  
    local Config = Container.Config;
    
    local TimeLeft = max(Bar.Aura.ExpirationTime - GetTime(), 0);
    
    if Config.Layout.DurationLayout == "FORMAT" then
    
      Bar.Duration:SetFormattedText(SecondsToTimeAbbrev(TimeLeft));

    elseif Config.Layout.DurationLayout == "SEPCOLON" then
    
      local Days, Hours, Minutes, Seconds = math_floor(TimeLeft / 86400), math_floor(TimeLeft / 3600), math_floor(TimeLeft / 60), TimeLeft % 60;
      
      if Days ~= 0 then
        Bar.Duration:SetFormattedText("%d:%.2d:%.2d:%.2d", Days, Hours, Minutes, Seconds);
      elseif Hours ~= 0 then
        Bar.Duration:SetFormattedText("%d:%.2d:%.2d", Hours, Minutes, Seconds);
      else
        Bar.Duration:SetFormattedText("%d:%.2d", Minutes, Seconds);
      end

    elseif Config.Layout.DurationLayout == "SEPDOT" then

      local Days, Hours, Minutes, Seconds = math_floor(TimeLeft / 86400), math_floor(TimeLeft / 3600), math_floor(TimeLeft / 60), TimeLeft % 60;
      
      if Days ~= 0 then
        Bar.Duration:SetFormattedText("%d.%.2d.%.2d.%.2d", Days, Hours, Minutes, Seconds);
      elseif Hours ~= 0 then
        Bar.Duration:SetFormattedText("%d.%.2d.%.2d", Hours, Minutes, Seconds);
      else
        Bar.Duration:SetFormattedText("%d.%.2d", Minutes, Seconds);
      end

    elseif Config.Layout.DurationLayout == "SECONDS" then
    
      Bar.Duration:SetText(math_floor(TimeLeft));

    end
    
    if TimeLeft < Container.Config.Layout.BarMaxTime then
    
      if Container.Shrink then
        Bar.Texture:SetWidth((Container.WidthPerSecond * TimeLeft) + 1.0);
      else
        Bar.Texture:SetWidth(Container.BarWidth - (Container.WidthPerSecond * TimeLeft));
      end
    
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

  self.Frame:Hide();
  self.Frame:UnregisterAllEvents();
  self.Frame = nil;

  if self.ConfigFrame then
    self.ConfigFrame:Hide();
  end

end


-----------------------------------------------------------------
-- Function UpdateBar
-----------------------------------------------------------------
function Prototype:UpdateBar(Bar)

  local Aura = Bar.Aura;
  
  Bar:SetWidth(self.Config.Layout.BarWidth);
  Bar:SetHeight(Module.BarHeight);
  
  Bar.Text:ClearAllPoints();
  Bar.Duration:ClearAllPoints();
  
  if self.Config.Layout.Icon == "NONE" then
    
    Bar.Button.Icon:Hide();
    
    Bar.Text:SetPoint("LEFT", Bar, "LEFT", 5, 0);
    Bar.Duration:SetPoint("RIGHT", Bar, "RIGHT", -5, 0);
    
  elseif self.Config.Layout.Icon == "LEFT" then
  
    Bar.Button.Icon:ClearAllPoints();
    Bar.Button.Icon:SetPoint("TOPLEFT", Bar, "TOPLEFT", 0, 0);
    Bar.Button.Icon:Show();
  
    Bar.Text:SetPoint("LEFT", Bar, "LEFT", 5 + Module.BarHeight , 0);
    Bar.Duration:SetPoint("RIGHT", Bar, "RIGHT", -5, 0);
  
  elseif self.Config.Layout.Icon == "RIGHT" then
  
    Bar.Button.Icon:ClearAllPoints();
    Bar.Button.Icon:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", 0, 0);
    Bar.Button.Icon:Show();
  
    Bar.Text:SetPoint("LEFT", Bar, "LEFT", 5, 0);
    Bar.Duration:SetPoint("RIGHT", Bar, "RIGHT", -5 - Module.BarHeight, 0);

  end
  
  Bar.Texture:ClearAllPoints();
  Bar.Texture:SetHeight(Module.BarHeight);
  Bar.Spark:ClearAllPoints();
  
  if self.Config.Layout.BarDirection == "LEFTGROW" or self.Config.Layout.BarDirection == "LEFTSHRINK" then
  
    Bar.Texture:SetPoint("TOPLEFT", Bar, "TOPLEFT", self.Config.Layout.Icon == "LEFT" and Module.BarHeight or 0, 0);
    Bar.Spark:SetPoint("CENTER", Bar.Texture, "RIGHT", 0, 0);
    
  else

    Bar.Texture:SetPoint("TOPRIGHT", Bar, "TOPRIGHT", self.Config.Layout.Icon == "RIGHT" and -Module.BarHeight or 0, 0);
    Bar.Spark:SetPoint("CENTER", Bar.Texture, "LEFT", 0, 0);
  
  end
  
  Bar.Texture:SetTexture(LSM:Fetch("statusbar", self.Config.Layout.BarTexture));
  
  if self.Config.Layout.ShowDuration and Aura.ExpirationTime > 0 then
    
    Bar.Duration:Show();
  
  elseif Bar.Duration then

    Bar.Duration:Hide();
  
  end

  if self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    Bar.Text:SetText(Aura.Name.." ["..Aura.Count.."]");
  
  else
  
    Bar.Text:SetText(Aura.Name);
    
  end

  if self.Config.Layout.ShowTooltip then
  
    Bar:SetScript("OnEnter", function() AuraFrames:ShowTooltip(Aura, Bar, self.TooltipOptions); end);
    Bar:SetScript("OnLeave", function() AuraFrames:HideTooltip(); end);
  
  else
  
    Bar:SetScript("OnEnter", nil);
    Bar:SetScript("OnLeave", nil);
  
  end
  
  Bar.Background:SetWidth(self.Config.Layout.BarWidth);
  
  if self.Config.Layout.Clickable then
    
    Bar:EnableMouse(true);
    Bar:SetScript("OnMouseUp", BarOnMouseUp);
    
    Bar:HookScript("OnEnter", function() AuraFrames:SetCancelAuraFrame(Bar, Aura); end);
    
  else
    
    Bar:EnableMouse(false);
    Bar:SetScript("OnMouseUp", nil);
    
  end
  
  if Aura.ExpirationTime == 0 or (Aura.ExpirationTime ~= 0 and max(Aura.ExpirationTime - GetTime(), 0) > self.Config.Layout.BarMaxTime) then
    
    Bar.Texture:SetWidth(self.BarWidth);
    
  end
  
  BarOnUpdate(self, Bar, 0.0);

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
    
    if self.ConfigMode then
    
      if self.ConfigFrame then
        self.ConfigFrame.Text:SetText("Container "..self.Name.."\n"..self.Config.Layout.NumberOfBars);
      end
    
    else
      
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
-- Function ConfigMode
-----------------------------------------------------------------
function Prototype:SetConfigMode(Mode)

  self.ConfigMode = Mode;
  
  if Mode == true then
    
    if not self.ConfigFrame then
    
      self.ConfigFrame = CreateFrame("Frame", "AuraFramesContainerConfig_"..self.Name, self.Frame, "AuraFramesBarContainerConfigTemplate");
      self.ConfigFrame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 0, 0);
      self.ConfigFrame:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT", 0, 0);
      
      self.ConfigFrame.Text = _G["AuraFramesContainerConfig_"..self.Name.."_Text"];
      
    end
    
    self.ConfigFrame:Show();
    
    self:Update();
    
  elseif self.ConfigFrame then
    
    -- Make sure wow dont try to save the locations of the frames.
    self.Frame:SetUserPlaced(false);
    
    local RelativeTo;
    self.Config.Location.FramePoint, self.Config.Location.RelativeTo, self.Config.Location.RelativePoint, self.Config.Location.OffsetX, self.Config.Location.OffsetY = self.Frame:GetPoint();
    
    self.ConfigFrame:Hide();
    
    self:Update();
  
  end

end


-----------------------------------------------------------------
-- Function AuraNew
-----------------------------------------------------------------
function Prototype:AuraNew(Aura)

  if self.Filter and self.Filter.Test(Aura) == false then
    return;
  end
  
  -- Pop the last bar out the pool.
  local Bar = table.remove(BarPool);

  local BarId;
  
  if Bar == nil then -- No bars left in the pool
  
    BarCounter = BarCounter + 1;
  
    BarId = "AuraFramesBar"..BarCounter;
    Bar = CreateFrame("Frame", BarId, self.Frame, "AuraFramesBarTemplate");
    
    Bar.Text = _G[BarId.."Text"];
    Bar.Duration = _G[BarId.."Duration"];
    Bar.Background = _G[BarId.."Background"];
    Bar.Texture = _G[BarId.."Texture"];
    Bar.Spark = _G[BarId.."Spark"];
    
    Bar.Button = _G[BarId.."Button"];
    Bar.Button.Icon = _G[BarId.."ButtonIcon"];
    Bar.Button.Border = _G[BarId.."ButtonBorder"];
    
    local Container = self;  
    Bar:SetScript("OnUpdate", function(_, Elapsed)
      
       Bar.TimeSinceLastUpdate = Bar.TimeSinceLastUpdate + Elapsed;
       if Bar.TimeSinceLastUpdate > BarUpdatePeriod then
          BarOnUpdate(Container, Bar, Bar.TimeSinceLastUpdate);
          Bar.TimeSinceLastUpdate = 0.0;
       end
      
    end);
    
    --Module.LBFGroup:AddButton(Bar.Button, {Icon = Bar.Button.Icon, Border = Bar.Button.Border});
    
  else
  
    BarId = Bar:GetName();
  
  end
  
  Bar.TimeSinceLastUpdate = 0.0;
  
  Bar:SetParent(self.Frame);
  Bar.Button.Icon:SetTexture(Aura.Icon);
    
  Bar.Aura = Aura;
  
  self.Bars[Aura.Id] = Bar;
  self.Order:Add(Bar);
  
  self:UpdateBar(Bar);
  
  self:UpdateAnchors();
  
  --Module.LBFGroup:ReSkin();

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
  Bar:ClearAllPoints();
  Bar:SetParent(nil);

  -- Release the bar back in the pool for later use.
  table.insert(BarPool, Bar);
  
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
  
  if Bar.Count and self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    Bar.Text:SetText(Aura.Name.." ["..Aura.Count.."]");
    
  end
  
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

    if i > Max then

      self.Order[i]:Hide();
    
    else
      
      self.Order[i]:ClearAllPoints();
      
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