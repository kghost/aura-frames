local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:NewModule("ButtonContainer", AuraFrames.ContainerPrototype);

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

-- Register this module as a container handler.
AuraFrames.ContainerHandlers["Buttons"] = Module;

-- List that contains the function prototypes for container objects.
Module.Prototype = {};


-----------------------------------------------------------------
-- Function OnInitialize
-----------------------------------------------------------------
function Module:OnInitialize()


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
      DurationLayout = "FORMAT",
      ShowCount = true,
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
      Buff          = {1.0, 1.0, 1.0, 0.0},
      Weapon        = {1.0, 1.0, 1.0, 0.0},
      Other         = {1.0, 1.0, 1.0, 0.0},
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
  if _G["AuraFramesContainer_"..Config.Name] then
    Container.Frame = _G["AuraFramesContainer_"..Config.Name];
  else
    Container.Frame = CreateFrame("Frame", "AuraFramesContainer_"..Config.Name, UIParent, "AuraFramesButtonContainerTemplate");
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
  
  Container:Update();
  
  Container.Frame:SetScript("OnEvent", function() Container:Update(); end);
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");
  
  Container:SetConfigMode(AuraFrames.ConfigMode);
  
  return Container;

end
