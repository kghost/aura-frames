local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:NewContainerModule("ButtonContainer");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- Module settings
Module.MaxButtons = 120;
Module.ButtonSizeX = 36;
Module.ButtonSizeY = 36;

-- List that contains the function prototypes for container objects.
Module.Prototype = {};


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
      HorizontalSize = 16,
      VerticalSize = 2,
      SpaceX = 5,
      SpaceY = 15,
      Direction = "LEFTDOWN",
      DynamicSize = false,
      ShowDuration = true,
      DurationOutline = "OUTLINE",
      DurationMonochrome = false,
      DurationLayout = "ABBREVSPACE",
      DurationSize = 10,
      DurationPosX = 0,
      DurationPosY = -25,
      DurationColor = {1, 1, 1, 1},
      ShowCount = true,
      CountOutline = "OUTLINE",
      CountMonochrome = false,
      CountSize = 10,
      CountPosX = 10,
      CountPosY = -6,
      CountColor = {1, 1, 1, 1},
      SortOrder = "Duration",
      ShowTooltip = true,
      Clickable = true,
      TooltipShowPrefix = false,
      TooltipShowCaster = true,
      TooltipShowSpellId = false,
      TooltipShowClassification = false,
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
  if _G["AuraFramesContainer_"..Config.Id] then
    Container.Frame = _G["AuraFramesContainer_"..Config.Id];
  else
    Container.Frame = CreateFrame("Frame", "AuraFramesContainer_"..Config.Id, UIParent, "AuraFramesButtonContainerTemplate");
  end
  
  Container.Frame:Show();

  Container.Name = Config.Name;
  Container.ConfigMode = false;
  Container.Config = Config;
  
  Container.Filter = AuraFrames:NewFilter(Config.Filter, function() Container:Update("FILTER"); end);
  
  Container.Order = AuraFrames:NewOrder(Config.Order, function() Container:Update("ORDER"); end);
  
  Container.TooltipOptions = {};
  
  Container.Buttons = {};
  
  Container.LBFGroup = AuraFrames:CreateButtonFacadeGroup(Config.Id);
  
  Container.DurationFontObject = _G["AuraFramesContainer_"..Config.Id.."_DurationFont"] or CreateFont("AuraFramesContainer_"..Config.Id.."_DurationFont");
  Container.CountFontObject = _G["AuraFramesContainer_"..Config.Id.."_CountFont"] or CreateFont("AuraFramesContainer_"..Config.Id.."_CountFont");
  
  Container:Update("ALL");
  
  Container.Frame:SetScript("OnEvent", function() Container:Update(); end);
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");
  
  return Container;

end
