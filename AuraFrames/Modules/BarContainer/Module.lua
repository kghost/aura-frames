local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:NewContainerModule("BarContainer");
local LSM = LibStub("LibSharedMedia-3.0");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- Module settings
Module.MaxBars = 40;
Module.BarHeight = 24;


-- List that contains the function prototypes for container objects.
Module.Prototype = {};

local StatusBarTextures = {
  ["Aluminum"]    = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Aluminum.tga]],
  ["Armory"]      = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Armory.tga]],
  ["BantoBar"]    = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\BantoBar.tga]],
  ["DarkBottom"]  = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Darkbottom.tga]],
  ["Default"]     = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Default.tga]],
  ["Flat"]        = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Flat.tga]],
  ["Glaze"]       = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Glaze.tga]],
  ["Gloss"]       = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Gloss.tga]],
  ["Graphite"]    = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Graphite.tga]],
  ["Minimalist"]  = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Minimalist.tga]],
  ["Otravi"]      = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Otravi.tga]],
  ["Smooth"]      = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Smooth.tga]],
  ["Smooth v2"]   = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Smoothv2.tga]],
  ["Striped"]     = [[Interface\Addons\AuraFrames\Modules\BarContainer\Textures\Striped.tga]],
};

-----------------------------------------------------------------
-- Function OnInitialize
-----------------------------------------------------------------
function Module:OnInitialize()

  for Name, Texture in pairs(StatusBarTextures) do
  
    if not LSM:Fetch("statusbar", Name, true) then
      LSM:Register("statusbar", Name, Texture);
    end
  
  end

end

-----------------------------------------------------------------
-- Function GetName
-----------------------------------------------------------------
function Module:GetName()

  return "Bars";

end

-----------------------------------------------------------------
-- Function GetDescription
-----------------------------------------------------------------
function Module:GetDescription()

  return "A container that use bars to display aura's";

end

-----------------------------------------------------------------
-- Function GetConfigDefaults
-----------------------------------------------------------------
function Module:GetConfigDefaults()

  local ConfigDefaults = {
    Location= {
      OffsetX = 0,
      OffsetY = 0,
      FramePoint = "CENTER",
      RelativePoint = "CENTER",
    },
    Layout = {
      Scale = 1.0,
      NumberOfBars = 10,
      Space = 5,
      BarWidth = 250,
      BarMaxTime = 30,
      Direction = "DOWN",
      DynamicSize = false,
      ShowDuration = true,
      DurationLayout = "FORMAT",
      ShowCount = true,
      SortOrder = "Duration",
      ShowTooltip = true,
      Clickable = true,
      TooltipShowPrefix = false,
      TooltipShowCaster = true,
      TooltipShowSpellId = false,
      TooltipShowClassification = false,
      BarTexture = "Aluminum",
      BarDirection = "LEFTSHRINK",
      Icon = "LEFT",
    },
    Colors = {
      Debuff = {
        None        = {0.8, 0.0, 0.0, 1.0},
        Magic       = {0.2, 0.6, 1.0, 1.0},
        Curse       = {0.6, 0.0, 1.0, 1.0},
        Disease     = {0.6, 0.4, 0.0, 1.0},
        Poison      = {0.0, 0.6, 0.0, 1.0},
      },
      Buff          = {1.0, 1.0, 1.0, 1.0},
      Weapon        = {1.0, 1.0, 1.0, 1.0},
      Other         = {1.0, 1.0, 1.0, 1.0},
    },
    Order = AuraFrames:GetConfigDefaultsOrder(),
    Filter = AuraFrames:GetConfigDefaultsFilter(),
  };
  
  return ConfigDefaults;

end


-----------------------------------------------------------------
-- Function New
-----------------------------------------------------------------
function Module:New(Config)

  local Container = {};
  setmetatable(Container, { __index = self.Prototype});
  
  -- Reuse old containers if we can.
  if _G["AuraFramesBarContainer_"..Config.Name] then
    Container.Frame = _G["AuraFramesBarContainer_"..Config.Name];
  else
    Container.Frame = CreateFrame("Frame", "AuraFramesBarContainer_"..Config.Name, UIParent, "AuraFramesBarContainerTemplate");
  end
  
  Container.Frame:Show();

  Container.Name = Config.Name;
  Container.ConfigMode = false;
  Container.Config = Config;
  
  Container.Filter = AuraFrames:NewFilter(Config.Filter, function() Container:Update("FILTER"); end);
  
  Container.Order = AuraFrames:NewOrder(Config.Order, function() Container:Update("ORDER"); end);
  
  Container.TooltipOptions = {};
  
  Container.Bars = {};
  
  Container.LBFGroup = AuraFrames:CreateButtonFacadeGroup(Config.Id);
  
  Container:Update();
  
  Container.Frame:SetScript("OnEvent", function() Container:Update(); end);
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");

  return Container;

end
