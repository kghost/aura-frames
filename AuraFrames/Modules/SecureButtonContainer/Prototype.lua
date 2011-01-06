local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("SecureButtonContainer");
local LBF = LibStub("LibButtonFacade", true);
local LSM = LibStub("LibSharedMedia-3.0");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, CreateFrame, IsModifierKeyDown = GetTime, CreateFrame, IsModifierKeyDown;
local math_sin, math_cos, math_floor, math_ceil = math.sin, math.cos, math.floor, math.ceil;
local min, max = min, max;
local UnitAura, UnitName = UnitAura, UnitName;
local _G, PI = _G, PI;

local Prototype = Module.Prototype;

-- Direction = {Point, xOffset, yOffset, wrapXOffset, wrapYOffset, maxWraps, wrapAfter}
local DirectionMapping = {
  LEFTDOWN  = {"TOPRIGHT",    -1,  0,  0, -1, "VerticalSize", "HorizontalSize"},
  LEFTUP    = {"BOTTOMRIGHT", -1,  0,  0,  1, "VerticalSize", "HorizontalSize"},
  RIGHTDOWN = {"TOPLEFT",      1,  0,  0, -1, "VerticalSize", "HorizontalSize"},
  RIGHTUP   = {"BOTTOMLEFT",   1,  0,  0,  1, "VerticalSize", "HorizontalSize"},
  DOWNLEFT  = {"TOPRIGHT",     0, -1, -1,  0, "HorizontalSize", "VerticalSize"},
  DOWNRIGHT = {"TOPLEFT",      0, -1,  1,  0, "HorizontalSize", "VerticalSize"},
  UPLEFT    = {"BOTTOMRIGHT",  0,  1, -1,  0, "HorizontalSize", "VerticalSize"},
  UPRIGHT   = {"BOTTOMLEFT",   0,  1,  1,  0, "HorizontalSize", "VerticalSize"},
};

-- How fast a button will get updated.
local ButtonUpdatePeriod = 0.05;

-- Pre calculate pi * 2 (used for flashing buttons).
local PI2 = PI + PI;


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
    
      for _, Button in ipairs(Container.Buttons) do
      
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

  local SlotId = Button:GetAttribute("target-slot");
  
  local Count, Duration, ExpirationTime;

  if SlotId then
  
    if not Module.WeaponEnchants[SlotId] then
      return;
    end
    
    local Enchant = Module.WeaponEnchants[SlotId];
    
    Count, Duration, ExpirationTime = Enchant.Count, Enchant.Duration, Enchant.ExpirationTime;
  
  else
    
    local _, Name;
    
    Name, _, _, Count, _, Duration, ExpirationTime = UnitAura(Container.Config.Unit, Button:GetID(), Container.Config.Filter);
    
    if not Name then
      return;
    end
  
  end

  if Button.Count ~= nil and Config.Layout.ShowCount and Count > 0 then
  
    Button.Count:SetText(Count);
    Button.Count:Show();
    
  elseif Button.Count then
    
    Button.Count:Hide();
    
  end

  if ExpirationTime ~= 0 then
    
    local TimeLeft = max(ExpirationTime - GetTime(), 0);
    
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
    
    elseif Button.NewFlashTime and Duration ~= 0 then
    
      local TimeFromStart = Duration - TimeLeft;
      
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
    
    else
    
      Button.Icon:SetAlpha(1.0);
    
    end
    
  else
    
    Button.Icon:SetAlpha(1.0);
    
  end
  
end


-----------------------------------------------------------------
-- Function Delete
-----------------------------------------------------------------
function Prototype:Delete()
  
  Module.Containers[self.Config.Id] = nil;

  self.Frame:Hide();
  self.Frame:UnregisterAllEvents();
  self.Frame = nil;

  if self.LBFGroup then
    self.LBFGroup:Delete(true);
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
  
  local SlotId = Button:GetAttribute("target-slot");
  
  local Type, Count, Duration, ExpirationTime, Icon, Classification;

  if SlotId then
  
    if not Module.WeaponEnchants[SlotId] then
      return;
    end
    
    local Enchant = Module.WeaponEnchants[SlotId];
    
    Type, Count, Duration, ExpirationTime, Icon, Classification = "WEAPON", Enchant.Count, Enchant.Duration, Enchant.ExpirationTime, Enchant.Icon, Enchant.Classification;
  
  else
    
    local _, Name;
    
    Name, _, Icon, Count, Classification, Duration, ExpirationTime = UnitAura(self.Config.Unit, Button:GetID(), self.Config.Filter);
    Type = self.Config.Filter;
    
    if not Name then
      return;
    end
    
    Classification = Classification or "None";
  
  end
  
  Button.Icon:SetTexture(Icon);

  if Button.Duration ~= nil and self.Config.Layout.ShowDuration == true and ExpirationTime > 0 then
    
    Button.Duration:Show();
  
  elseif Button.Duration then
  
    Button.Duration:Hide();
  
  end
  
  if Button.Border ~= nil then
  
    local Color;
    
    if Type == "HARMFUL" then
    
      Color = self.Config.Colors.Debuff[Classification];

    elseif Type == "HELPFUL" then

      Color = self.Config.Colors["Buff"];

    elseif Type == "WEAPON" then

      Color = self.Config.Colors["Weapon"];

    else

      Color = self.Config.Colors["Other"];

    end
    
    if LBF then
      LBF:SetNormalVertexColor(Button, unpack(Color));
    end
    
    Button.Border:SetVertexColor(unpack(Color));
  
  end

  if self.Config.Layout.ShowCooldown == true and ExpirationTime > 0 then
    
    local CurrentTime = GetTime();

    if Duration > 0 then
      Button.Cooldown:SetCooldown(ExpirationTime - Duration, Duration);
    else
      Button.Cooldown:SetCooldown(CurrentTime, ExpirationTime - CurrentTime);
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

  local Container = self;

  if Button.Duration ~= nil and self.Config.Layout.ShowDuration == true then
    
    Button.Duration:ClearAllPoints();
    Button.Duration:SetPoint("CENTER", Button, "CENTER", self.Config.Layout.DurationPosX, self.Config.Layout.DurationPosY);
  
  end

  if self.Config.Layout.ShowCount then
  
    Button.Count:ClearAllPoints();
    Button.Count:SetPoint("CENTER", Button, "CENTER", self.Config.Layout.CountPosX, self.Config.Layout.CountPosY);
    
  end
  
  if self.Config.Layout.ShowTooltip then
  
    Button:SetScript("OnEnter", function(Button) AuraFrames:ShowTooltip(Container:GetAuraObject(Button), Button, Container.TooltipOptions); end);
    Button:SetScript("OnLeave", function() AuraFrames:HideTooltip(); end);
  
  else
  
    Button:SetScript("OnEnter", nil);
    Button:SetScript("OnLeave", nil);
  
  end
  
  if self.Config.Layout.Clickable then
    
    Button:EnableMouse(true);
    Button:RegisterForClicks("RightButtonUp");
    
  else
    
    Button:EnableMouse(false);
    
  end
  
  -- Set cooldown options
  Button.Cooldown:SetDrawEdge(self.Config.Layout.CooldownDrawEdge);
  Button.Cooldown:SetReverse(self.Config.Layout.CooldownReverse);
  Button.Cooldown.noCooldownCount = self.Config.Layout.CooldownDisableOmniCC;
  
  if Button:IsShown() then
    self:UpdateButtonDisplay(Button);
  end

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

  if Changed == "ALL" then
  
    self.Frame:SetAttribute("unit", self.Config.Unit);
    self.Frame:SetAttribute("filter", self.Config.Filter);
    
    Module:CheckWeaponEnchants();
    self.Frame:SetAttribute("includeWeapons", self.Config.IncludeWeapons == true and 1 or nil);
    
  end

  if Changed == "ALL" or Changed == "LAYOUT" then

    local Width = (self.Config.Layout.HorizontalSize * Module.ButtonSizeX) + ((self.Config.Layout.HorizontalSize - 1) * self.Config.Layout.SpaceX);
    local Height = (self.Config.Layout.VerticalSize * Module.ButtonSizeY) + ((self.Config.Layout.VerticalSize - 1) * self.Config.Layout.SpaceY)

    self.Frame:SetAttribute("minWidth", Width);
    self.Frame:SetAttribute("minHeight", Height);
  
    self.Frame:SetWidth(Width);
    self.Frame:SetHeight(Height);
    
    self.Frame:SetScale(self.Config.Layout.Scale);
    
    local Map = DirectionMapping[self.Config.Layout.Direction];

    self.Frame:SetAttribute("point", Map[1]);
    self.Frame:SetAttribute("xOffset", Map[2] * (Module.ButtonSizeX + self.Config.Layout.SpaceX));
    self.Frame:SetAttribute("yOffset", Map[3] * (Module.ButtonSizeY + self.Config.Layout.SpaceY));
    self.Frame:SetAttribute("wrapXOffset", Map[4] * (Module.ButtonSizeX + self.Config.Layout.SpaceX));
    self.Frame:SetAttribute("wrapYOffset", Map[5] * (Module.ButtonSizeY + self.Config.Layout.SpaceY));
    self.Frame:SetAttribute("maxWraps", self.Config.Layout[Map[6]]);
    self.Frame:SetAttribute("wrapAfter", self.Config.Layout[Map[7]]);
    
    if self.Unlocked ~= true then
    
      self.Frame:ClearAllPoints();
      self.Frame:SetPoint(self.Config.Location.FramePoint, self.Config.Location.RelativeTo, self.Config.Location.RelativePoint, self.Config.Location.OffsetX, self.Config.Location.OffsetY);
    
    end
    
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
  
  if Changed == "ALL" or Changed == "ORDER" then
  
    self.Frame:SetAttribute("sortMethod", self.Config.Order.Method);
    self.Frame:SetAttribute("sortDirection", self.Config.Order.Direction);
    self.Frame:SetAttribute("separateOwn", self.Config.Order.SeparateOwn);
  
  end
  
  if Changed == "ALL" or Changed == "LAYOUT" or Changed == "ORDER" or Changed == "WEAPON" then
  
      for _, Button in ipairs(self.Buttons) do
    
      self:UpdateButton(Button);
    
    end
  
  end

end


-----------------------------------------------------------------
-- Function RegisterButton
-----------------------------------------------------------------
function Prototype:RegisterButton(Button)

  local ButtonId = Button:GetName();
  
  Button.Duration = _G[ButtonId.."Duration"];
  Button.Icon = _G[ButtonId.."Icon"];
  Button.Count = _G[ButtonId.."Count"];
  Button.Border = _G[ButtonId.."Border"];
  Button.Cooldown = _G[ButtonId.."Cooldown"];

  tinsert(self.Buttons, Button);

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
  
  Button.NewFlashTime = self.NewFlashTime;
  Button.ExpireFlashTime = self.ExpireFlashTime;
  
  Button.TimeSinceLastUpdate = 0.0;
  Button.TimeLeftSeconds = 0;
  
  self:UpdateButton(Button);

end

-----------------------------------------------------------------
-- Function GetAuraObject
-----------------------------------------------------------------
function Prototype:GetAuraObject(Button)

  local SlotId = Button:GetAttribute("target-slot");

  if SlotId then
  
    if not Module.WeaponEnchants[SlotId] then
      return {};
    end
    
   return Module.WeaponEnchants[SlotId];
  
  else
    
    local Unit, Index, Type = self.Config.Unit, Button:GetID(), self.Config.Filter;
    local Name, _, Icon, Count, Classification, Duration, ExpirationTime, CasterUnit, IsStealable, _, SpellId = UnitAura(Unit, Index, Type);
    
    if not Name then
      return {};
    end
    
    return {
      Type = Type,
      Index = Index,
      Name = Name,
      Icon = Icon,
      Count = Count,
      Classification = Classification or "None",
      Duration = Duration or 0,
      ExpirationTime = ExpirationTime,
      Unit = Unit,
      CasterUnit = CasterUnit,
      CasterName = CasterUnit and UnitName(CasterUnit),
      IsStealable = IsStealable == 1 and true or false,
      IsCancelable = false,
      IsDispellable = false,
      SpellId = SpellId,
      ItemId = 0,
    };
  
  end

end
