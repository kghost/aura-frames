local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:NewContainerModule("SecureButtonContainer");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
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


-- List of active weapon enchants if needed.
Module.WeaponEnchants = {};
setmetatable(Module.WeaponEnchants, {__mode = "v"}); -- Weak values.

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

  return "Secure Buttons";

end


-----------------------------------------------------------------
-- Function GetDescription
-----------------------------------------------------------------
function Module:GetDescription()

  return "A container that use secure buttons to display aura's";

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
      
      ButtonFacade = {
        Gloss = 0.8,
        SkinId = "Aura Frames",
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
        Flash = true,
        FlashNumber = 5.0,
        FlashSpeed = 1.0,
      },
    },
    Unit = "player",
    Filter = "HELPFUL",
    SubFilter = "",
    IncludeWeapons = false,
    Order = {
      Method = "NAME",
      Direction = "+",
      SeparateOwn = 0,
    },
  };
  
  return DatabaseDefaults;

end


-----------------------------------------------------------------
-- Function HookButton
-----------------------------------------------------------------
function Module:RegisterButton(Button)

  Button:GetParent().Container:RegisterButton(Button);

end


-----------------------------------------------------------------
-- Function CheckWeaponEnchants
-----------------------------------------------------------------
function Module:CheckWeaponEnchants()

  local Active = false;
  
  for _, Container in pairs(self.Containers) do
  
    if Container.Config.IncludeWeapons == true then
      Active = true;
      break;
    end
  
  end

  if Active == true then

    -- If we are already active, then we get a sync from LibAura, but that doesn't hurt anyway.
    LibStub("LibAura-1.0"):RegisterObjectSource(self, "player", "WEAPON");

  else

    LibStub("LibAura-1.0"):UnregisterObjectSource(self, "player", "WEAPON");

  end

end


-----------------------------------------------------------------
-- Function AuraNew
-----------------------------------------------------------------
function Module:AuraNew(Aura)

  if Aura.Type ~= "WEAPON" then
    return;
  end

  self.WeaponEnchants[Aura.Index] = Aura;
  
  for _, Container in pairs(self.Containers) do
  
    if Container.Config.IncludeWeapons == true then
      Container:Update("WEAPON");
    end
  
  end

end


-----------------------------------------------------------------
-- Function AuraChanged
-----------------------------------------------------------------
function Module:AuraChanged(Aura)

  -- We do nothing with changing aura's.

end


-----------------------------------------------------------------
-- Function AuraOld
-----------------------------------------------------------------
function Module:AuraOld(Aura)

  -- Bit tricky, we use a weak value table for keeping track of the aura's.
  -- Do nothing for now and see if we don't get any problems with this.

end


-----------------------------------------------------------------
-- Function New
-----------------------------------------------------------------
function Module:New(Config)

  local Container = {};
  setmetatable(Container, { __index = self.Prototype});
  
  self.Containers[Config.Id] = Container;
  
  local FrameId = "AuraFramesSecureButtonContainer_"..Config.Id;
  
  -- Reuse old containers if we can.
  if _G[FrameId] then
    Container.Frame = _G[FrameId];
  else
    Container.Frame = CreateFrame("Frame", FrameId, UIParent, "SecureAuraHeaderTemplate");
  end
  
  Container.Frame.Container = Container;
  
  Container.Frame:SetAttribute("template", "AuraFramesSecureButtonTemplate");
  Container.Frame:SetAttribute("weaponTemplate", "AuraFramesSecureButtonTemplate");
  
  Container.Id = Config.Id;
  Container.Config = Config;

  Container.TooltipOptions = {};
  
  Container.Buttons = {};
  
  Container.ButtonPool = {};
  
  Container.LBFGroup = AuraFrames:CreateButtonFacadeGroup(Config.Id);
  
  Container.DurationFontObject = _G[FrameId.."_DurationFont"] or CreateFont(FrameId..Config.Id.."_DurationFont");
  Container.CountFontObject = _G[FrameId.."_CountFont"] or CreateFont(FrameId..Config.Id.."_CountFont");

  Container:Update();
  
  Container.Frame:Show();

  Container.Frame:HookScript("OnEvent", function(_, Event, ...)
    
    if Event == "UNIT_AURA" and ... == Container.Config.Unit then
    
      for _, Button in ipairs(Container.Buttons) do
        if Button:IsShown() == 1 then
          Container:UpdateButtonDisplay(Button);
        end
      end
    
    elseif Event == "PLAYER_ENTERING_WORLD" or Event == "ZONE_CHANGED" then
      
      Container:Update();
      
    end
  
  end);
  
  Container.Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  Container.Frame:RegisterEvent("ZONE_CHANGED");
  
  for _, Button in ipairs(Container.Buttons) do
    if Button:IsShown() == 1 then
      Container:UpdateButtonDisplay(Button);
    end
  end
  
  return Container;

end
