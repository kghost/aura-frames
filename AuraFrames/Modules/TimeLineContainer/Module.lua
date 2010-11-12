local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:NewContainerModule("TimeLineContainer");

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
Module.ButtonSizeX = 36;
Module.ButtonSizeY = 36;

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

  return "TimeLine";

end


-----------------------------------------------------------------
-- Function GetDescription
-----------------------------------------------------------------
function Module:GetDescription()

  return "A container that use a time line to display aura's";

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
      Size = 300,
      Style = "HORIZONTAL",
      Direction = "HIGH",

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

      ShowText = true,
      TextFont = "Friz Quadrata TT",
      TextOutline = "OUTLINE",
      TextMonochrome = false,
      TextSize = 10,
      TextPos = 0,
      TextColor = {1, 1, 1, 1},
      
      ShowTooltip = true,
      Clickable = true,
      TooltipShowPrefix = false,
      TooltipShowCaster = true,
      TooltipShowSpellId = false,
      TooltipShowClassification = false,
      ShowCooldown = false,
      CooldownDrawEdge = true,
      CooldownReverse = false,
      CooldownDisableOmniCC = true,
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
    },
    Order = AuraFrames:GetDatabaseDefaultsOrder(),
    Filter = AuraFrames:GetDatabaseDefaultsFilter(),
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
  
  local FrameId = "AuraFramesTimeLineContainer_"..Config.Id;
  
  -- Reuse old containers if we can.
  if _G[FrameId] then
    Container.Frame = _G[FrameId];
  else
    Container.Frame = CreateFrame("Frame", FrameId, UIParent, "AuraFramesButtonContainerTemplate");
  end
  
  Container.Frame:Show();

  Container.Id = Config.Id;
  Container.Config = Config;
  
  Container.Filter = AuraFrames:NewFilter(Config.Filter, function() Container:Update("FILTER"); end);
  
  Container.Order = AuraFrames:NewOrder(Config.Order, function() Container:Update("ORDER"); end);
  
  Container.TooltipOptions = {};
  
  Container.Buttons = {};
  
  Container.ButtonPool = {};
  
  Container.LBFGroup = AuraFrames:CreateButtonFacadeGroup(Config.Id);
  
  Container.DurationFontObject = _G[FrameId.."_DurationFont"] or CreateFont(FrameId.."_DurationFont");
  Container.CountFontObject = _G[FrameId.."_CountFont"] or CreateFont(FrameId.."_CountFont");
  Container.TextFontObject = _G[FrameId.."_TextFont"] or CreateFont(FrameId.."_TextFont");

  Container:Update();

  Container.Frame:SetScript("OnEvent", function() Container:Update(); end);
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");
  
  return Container;

end
