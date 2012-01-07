local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:NewContainerModule("ButtonContainer");
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
-- Function OnEnable
-----------------------------------------------------------------
function Module:OnEnable()

end


-----------------------------------------------------------------
-- Function OnDisable
-----------------------------------------------------------------
function Module:OnDisable()

end


-----------------------------------------------------------------
-- Function GetName
-----------------------------------------------------------------
function Module:GetName()

  return "Buttons";

end


-----------------------------------------------------------------
-- Function GetDescription
-----------------------------------------------------------------
function Module:GetDescription()

  return "A container that use buttons to display aura's";

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
      HorizontalSize = 16,
      VerticalSize = 2,
      SpaceX = 5,
      SpaceY = 15,
      Direction = "LEFTDOWN",
      DynamicSize = false,
      ButtonSizeX = 36,
      ButtonSizeY = 36,

      ShowDuration = true,
      DurationFont = "Friz Quadrata TT",
      DurationOutline = "OUTLINE",
      DurationMonochrome = false,
      DurationLayout = "ABBREVSPACE",
      DurationSize = 10,
      DurationPosX = 0,
      DurationPosY = -25,
      DurationColor = {1, 1, 1, 1},

      ShowCount = true,
      CountFont = "Friz Quadrata TT",
      CountOutline = "OUTLINE",
      CountMonochrome = false,
      CountSize = 10,
      CountPosX = 10,
      CountPosY = -6,
      CountColor = {1, 1, 1, 1},

      Clickable = true,
      ShowTooltip = true,
      TooltipShowPrefix = false,
      TooltipShowCaster = true,
      TooltipShowAuraId = false,
      TooltipShowClassification = false,

      ShowCooldown = false,
      CooldownDrawEdge = true,
      CooldownReverse = false,
      CooldownDisableOmniCC = true,
      
      MiniBarEnabled = false,
      MiniBarStyle = "HORIZONTAL",
      MiniBarDirection = "HIGHSHRINK",
      MiniBarTexture = "Blizzard",
      MiniBarColor = {1.0, 1.0, 1.0, 1.0},
      MiniBarLength = 36,
      MiniBarWidth = 8,
      MiniBarOffsetX = 0,
      MiniBarOffsetY = -25,
      
    },
    Colors = AuraFrames:GetDatabaseDefaultColors(),
    Warnings = {
      New = {
        Flash = false,
        FlashNumber = 3.0,
        FlashSpeed = 1.0,
      },
      Expire = {
        Flash = true,
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
  
  local FrameId = "AuraFramesButtonContainer_"..Config.Id;
  
  -- Reuse old containers if we can.
  if _G[FrameId] then
    Container.Frame = _G[FrameId];
  else
    Container.Frame = CreateFrame("Frame", FrameId, UIParent, "AuraFramesButtonContainerTemplate");
    Container.Frame:SetClampedToScreen(true);
  end
  
  Container.Frame:Show();

  Container.Id = Config.Id;
  Container.Config = Config;
  
  Container.AuraList = AuraFrames:NewAuraList(Container, Config.Filter.Groups, Config.Order, Config.Colors);
  
  Container.TooltipOptions = {};
  
  Container.Buttons = {};
  
  Container.ButtonPool = {};
  
  Container.MSQGroup = MSQ and MSQ:Group("AuraFrames", Config.Id) or null;
  
  Container.DurationFontObject = _G[FrameId.."_DurationFont"] or CreateFont(FrameId..Config.Id.."_DurationFont");
  Container.CountFontObject = _G[FrameId.."_CountFont"] or CreateFont(FrameId..Config.Id.."_CountFont");

  Container:Update();

  Container.Frame:SetScript("OnEvent", function() Container:Update(); end);
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");
  
  return Container;

end
