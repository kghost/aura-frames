local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:NewContainerModule("BarContainer");
local MSQ = LibStub("Masque", true);

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, CreateFrame, CreateFont = GetTime, CreateFrame, CreateFont;
local _G = _G;

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: UIParent

-- Module settings
Module.MaxBars = 50;

-- List that contains the function prototypes for container objects.
Module.Prototype = {};

-- List of all active containers that are based on this module.
Module.Containers = {};

-----------------------------------------------------------------
-- Function OnInitialize
-----------------------------------------------------------------
function Module:OnInitialize()

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
-- Function GetDatabaseDefaults
-----------------------------------------------------------------
function Module:GetDatabaseDefaults()

  local DatabaseDefaults = {
    Location= {
      OffsetX = 0,
      OffsetY = 0,
      FramePoint = "CENTER",
      RelativePoint = "CENTER",
    },
    Layout = {
    
      Scale = 1.0,
      NumberOfBars = 10,
      Space = 0,
      BarWidth = 250,
      BarMaxTime = 30,
      BarUseAuraTime = false,
      Direction = "DOWN",
      DynamicSize = false,
      Icon = "LEFT",
      BarHeight = 36,

      ShowDuration = true,
      DurationLayout = "ABBREVSPACE",
      DurationPosition = "RIGHT",

      ShowCount = true,
      ShowAuraName = true,

      TextFont = "Friz Quadrata TT",
      TextOutline = "OUTLINE",
      TextMonochrome = false,
      TextSize = 11,
      TextColor = {1, 1, 1, 1},
      TextPosition = "LEFT",

      TextureBackgroundColor = {0.3, 0.3, 0.3, 0.8},
      TextureBackgroundUseTexture = true,
      TextureBackgroundUseBarColor = false,
      TextureBackgroundOpacity = 0.5,

      Clickable = true,
      ShowTooltip = true,
      TooltipShowPrefix = false,
      TooltipShowCaster = true,
      TooltipShowAuraId = false,
      TooltipShowClassification = false,

      BarTexture = "Blizzard",
      BarTextureInsets = 2,
      BarTextureFlipX = false,
      BarTextureFlipY = false,
      BarTextureRotate = false,
      BarTextureMove = false,
      BarDirection = "LEFTSHRINK",
      BarBorder = "Blizzard Tooltip",
      BarBorderSize = 8,
      BarBorderColorAdjust = 0.4,
      
      ShowSpark = true,
      SparkUseBarColor = false,
      SparkColor = {1.0, 1.0, 1.0, 1.0},

      ShowCooldown = false,
      CooldownDrawEdge = true,
      CooldownReverse = false,
      CooldownDisableOmniCC = true,
      
    },
    Colors = AuraFrames:GetDatabaseDefaultColors(),
    Warnings = {
      New = {
        Flash = false,
        FlashNumber = 3.0,
        FlashSpeed = 1.0,
      },
      Expire = {
        Flash = false,
        FlashNumber = 5.0,
        FlashSpeed = 1.0,
      },
      Changing = {
        Popup = false,
        PopupTime = 0.5,
        PopupScale = 3.0,
      },
    },
    Order = AuraFrames:GetDatabaseDefaultOrder(),
    Filter = AuraFrames:GetDatabaseDefaultFilter(),
  };
  
  return DatabaseDefaults;

end


-----------------------------------------------------------------
-- Function New
-----------------------------------------------------------------
function Module:New(Config)

  local Container = {};
  setmetatable(Container, { __index = self.Prototype});
  
  self.Containers[Config.Id] = Container;
  
  local FrameId = "AuraFramesBarContainer_"..Config.Name;
  
  -- Reuse old containers if we can.
  if _G[FrameId] then
    Container.Frame = _G[FrameId];
  else
    Container.Frame = CreateFrame("Frame", FrameId, UIParent, "AuraFramesBarContainerTemplate");
    Container.Frame:SetClampedToScreen(true);
  end
  
  Container.Frame:Show();

  Container.Id = Config.Id;
  Container.Config = Config;
  
  Container.AuraList = AuraFrames:NewAuraList(Container, Config.Filter.Groups, Config.Order, Config.Colors);
  
  Container.TooltipOptions = {};
  
  Container.Bars = {};
  
  Container.BarPool = {};
  
  Container.MSQGroup = MSQ and MSQ:Group("AuraFrames", Config.Id) or null;
  
  Container.FontObject = _G[FrameId.."_Font"] or CreateFont(FrameId.."_Font");
  
  Container:Update();
  
  Container.Frame:SetScript("OnEvent", function() Container:Update(); end);
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");

  return Container;

end
