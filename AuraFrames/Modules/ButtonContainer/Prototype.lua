local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("ButtonContainer");
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
local _G, PI = _G, PI;

local Prototype = Module.Prototype;

-- Pool that contains all the current unused buttons sorted by type.
local ButtonPool = {};

-- All containers have also there own (smaller) pool.
local ContainerButtonPoolSize = 5;

-- Counters for each butten type.
local ButtonCounter = 0;

-- Direction = {AnchorPoint, first X or Y, X Direction, Y Direction}
local DirectionMapping = {
  LEFTDOWN  = {"TOPRIGHT",    "y", -1, -1},
  LEFTUP    = {"BOTTOMRIGHT", "y", -1,  1},
  RIGHTDOWN = {"TOPLEFT",     "y",  1, -1},
  RIGHTUP   = {"BOTTOMLEFT",  "y",  1,  1},
  DOWNLEFT  = {"TOPRIGHT",    "x", -1, -1},
  DOWNRIGHT = {"TOPLEFT",     "x",  1, -1},
  UPLEFT    = {"BOTTOMRIGHT", "x", -1,  1},
  UPRIGHT   = {"BOTTOMLEFT",  "x",  1,  1},
};

local ButtonUpdatePeriod = 0.05;

local PI2 = PI + PI;


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
    
      for _, Button in pairs(Container.Buttons) do
      
        if Button.Cooldown:IsShown() == 1 then
        
          -- Trigger animation code.
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

  if Button.Aura.ExpirationTime ~= 0 then
  
    local Config = Container.Config;
    
    local TimeLeft = max(Button.Aura.ExpirationTime - GetTime(), 0);
    
    if Container.Config.Layout.ShowDuration == true then
    
      local TimeLeftSeconds = math_ceil(TimeLeft);
      
      if Button.TimeLeftSeconds ~= TimeLeftSeconds then
    
        Button.Duration:SetFormattedText(AuraFrames:FormatTimeLeft(Config.Layout.DurationLayout, TimeLeft));
        Button.TimeLeftSeconds = TimeLeftSeconds;
      
      end
    
    end
    
    if Button.ExpireFlashTime and TimeLeft < Button.ExpireFlashTime then
    
      local Alpha = ((math_cos((((Button.ExpireFlashTime - TimeLeft) % Config.Warnings.Expire.FlashSpeed) / Config.Warnings.Expire.FlashSpeed) * PI2) / 2 + 0.5) * 0.85) + 0.15;
      
      Button.Icon:SetAlpha(Alpha);
    
    elseif Button.NewFlashTime and Button.Aura.Duration ~= 0 then
    
      local TimeFromStart = Button.Aura.Duration - TimeLeft;
      
      if TimeFromStart < Button.NewFlashTime then
      
        local Alpha = ((math_cos((((TimeFromStart % Config.Warnings.New.FlashSpeed) / Config.Warnings.New.FlashSpeed) * PI2) + PI) / 2 + 0.5) * 0.85) + 0.15;
      
        Button.Icon:SetAlpha(Alpha);
      
      else
      
        Button.NewFlashTime = nil;
        Button.Icon:SetAlpha(1.0);
      
      end
    
    end
    
  end

end


-----------------------------------------------------------------
-- Local Function ButtonOnClick
-----------------------------------------------------------------
local function ButtonOnClick(Button)

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

    if Aura.Duration then
      Button.Cooldown:SetCooldown(Aura.ExpirationTime - Aura.Duration, Aura.ExpirationTime - CurrentTime);
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
  
  self:UpdateButtonDisplay(Button);

end

-----------------------------------------------------------------
-- Function Update
-----------------------------------------------------------------
function Prototype:Update(...)

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
    
    for _, Button in pairs(self.Buttons) do
      self:UpdateButton(Button);
    end
    
    -- We have buttons in the container pool that doesn't match the settings anymore. Release them into the general pool.
    self:ReleasePool();
  
    if Changed ~= "ALL" then
      self:UpdateAnchors();
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
  
  if Changed == "ALL" or Changed == "FILTER" then
  
    -- Delete all current auras.
    for _, Button in pairs(self.Buttons) do
      self:AuraOld(Button.Aura);
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

  if self.Buttons[Aura.Id] then
  
    AuraFrames:Print("Double aura trying to be added!!! Id: "..Aura.Id);
    return;
  
  end

  -- Pop the last button out the container pool.
  local Button = tremove(self.ButtonPool);
  local FromContainerPool = Button and true or false;
  
  if not Button then
  
    -- Try the general pool.
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
  
  self.Buttons[Aura.Id] = Button;
  self.Order:Add(Button);
  
  if FromContainerPool == true then

    -- We need only a display update.
    self:UpdateButtonDisplay(Button);

  else

    -- We need a full update.
    self:UpdateButton(Button);

  end

  -- UpdateAnchors will also make sure the button is showned.
  self:UpdateAnchors();

end


-----------------------------------------------------------------
-- Function AuraOld
-----------------------------------------------------------------
function Prototype:AuraOld(Aura)

  if not self.Buttons[Aura.Id] then
    return
  end
  
  local Button = self.Buttons[Aura.Id];
  
  -- Remove the button from the container list.
  self.Buttons[Aura.Id] = nil;
  
  -- Remove the button from the container order list.
  self.Order:Remove(Button);
  
  Button:Hide();
  
  -- The warning system can have changed the alpha. Set it back.
  Button.Icon:SetAlpha(1.0);
  
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
  
  self:UpdateAnchors();

end


-----------------------------------------------------------------
-- Function AuraChanged
-----------------------------------------------------------------
function Prototype:AuraChanged(Aura)

  if not self.Buttons[Aura.Id] then
    return
  end
  
  local Button = self.Buttons[Aura.Id];
  
  if Button.Count and self.Config.Layout.ShowCount and Aura.Count > 0 then
  
    Button.Count:SetText(Aura.Count);
    Button.Count:Show();
    
  elseif Button.Count then
    
    Button.Count:Hide();
    
  end
  
  self.Order:Update(Button);

  self:UpdateAnchors();

end


-----------------------------------------------------------------
-- Function UpdateAnchors
-----------------------------------------------------------------
function Prototype:UpdateAnchors()

  -- Maximune number of buttons to anchor.
  local Max = min(#self.Order, self.Config.Layout.HorizontalSize * self.Config.Layout.VerticalSize);

  local i, x, y;
  local Direction = DirectionMapping[self.Config.Layout.Direction];

  -- Anchor the buttons in the correct order.
  for i = 1, #self.Order do

    self.Order[i]:ClearAllPoints();
    
    if i > Max then

      self.Order[i]:Hide();
    
    else
      
      if Direction[2] == "y" then
        x, y = ((i - 1) % self.Config.Layout.HorizontalSize), math_floor((i - 1) / self.Config.Layout.HorizontalSize);
      else
        x, y = math_floor((i - 1) / self.Config.Layout.VerticalSize), ((i - 1) % self.Config.Layout.VerticalSize);
      end
      
      self.Order[i]:SetPoint(
        Direction[1],
        self.Frame,
        Direction[1],
        Direction[3] * (x * (Module.ButtonSizeX + (x and self.Config.Layout.SpaceX))),
        Direction[4] * (y * (Module.ButtonSizeY + (y and self.Config.Layout.SpaceY)))
      );
    
      self.Order[i]:Show();

    end
  
  end
  
end
