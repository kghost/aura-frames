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

  self.Pool = self.Pool or AuraFrames:NewPool(0, nil);

end


-----------------------------------------------------------------
-- Function OnDisable
-----------------------------------------------------------------
function Module:OnDisable()

  self.Pool:Flush();

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
      Size = 400,
      Style = "HORIZONTAL",
      Direction = "HIGH",
      MaxTime = 30,
      TimeCompression = 0.3,

      ShowDuration = true,
      DurationFont = "Friz Quadrata TT",
      DurationOutline = "OUTLINE",
      DurationMonochrome = false,
      DurationLayout = "ABBREVSPACE",
      DurationSize = 12,
      DurationPosX = 0,
      DurationPosY = -8.5,
      DurationColor = {1, 1, 1, 1},

      ShowCount = false,
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
      TextLayout = "ABBREVSPACE",
      TextSize = 10,
      TextPos = 0,
      TextColor = {1, 1, 1, 1},
      TextLabels = {1, 5, 10, 15, 20, 30},
      
      Clickable = true,
      ShowTooltip = true,
      TooltipShowPrefix = false,
      TooltipShowCaster = true,
      TooltipShowSpellId = false,
      TooltipShowClassification = false,

      BackgroundTexture = "Blizzard",
      BackgroundTextureColor = {0, 0.32, 0.82, 0.8},
      BackgroundTextureInsets = 2,
      
      BackgroundBorder = "Blizzard Tooltip",
      BackgroundBorderColor = {0, 0.1, 0.57, 0.8},
      BackgroundBorderSize = 8,
      
      ButtonFacade = {
        Gloss = 0.8,
        SkinId = "Aura Frames Default",
        Backdrop = false,
        Colors = {},
      },
    
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
    Container.Frame = CreateFrame("Frame", FrameId, UIParent, "AuraFramesTimeLineContainerTemplate");
  end
  
  Container.Frame:Show();

  Container.Id = Config.Id;
  Container.Config = Config;  
  
  Container.AuraList = AuraFrames:NewAuraList(Container, Config.Filter, nil);
  
  Container.TooltipOptions = {};
  
  Container.Buttons = {};
  
  Container.ButtonPool = {};
  Container.Pool = AuraFrames:NewPool(5, self.Pool);
  
  Container.LBFGroup = AuraFrames:CreateButtonFacadeGroup(Config.Id);
  
  Container.DurationFontObject = _G[FrameId.."_DurationFont"] or CreateFont(FrameId.."_DurationFont");
  Container.CountFontObject = _G[FrameId.."_CountFont"] or CreateFont(FrameId.."_CountFont");
  Container.TextFontObject = _G[FrameId.."_TextFont"] or CreateFont(FrameId.."_TextFont");

  Container.TextLabels = {};

  Container:Update();

  Container.Frame:SetScript("OnEvent", function() Container:Update(); end);
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");
  
  return Container;

end
