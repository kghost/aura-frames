local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("BarContainer");
local LSM = LibStub("LibSharedMedia-3.0");

local Prototype = Module.Prototype;

-----------------------------------------------------------------
-- Function GetConfigOptions
-----------------------------------------------------------------
function Prototype:GetConfigOptions()

  local Container, Config = self, self.Config;

  local Options = {
    Layout = {
      type = "group",
      name = "Layout",
      order = 1,
      args = {
        SizeHeader = {
          type = "header",
          name = "Size",
          order = 1,
        },
        Scale = {
          type = "range",
          name = "Scale",
          min = 0.5,
          max = 2.0,
          step = 0.1,
          isPercent = true,
          get = function(Info) return Config.Layout.Scale; end,
          set = function(Info, Value) Config.Layout.Scale = Value; Container:Update("LAYOUT"); end,
          order = 2,
        },
        NumberOfBars = {
          type = "select",
          name = "Number of bars",
          desc = "The number of aura bars the container will display",
          values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40},
          get = function(Info) return Config.Layout.NumberOfBars; end,
          set = function(Info, Value) Config.Layout.NumberOfBars = Value; Container:Update("LAYOUT"); end,
          order = 3,
        },
        Direction = {
          type = "select",
          name = "Container grow direction",
          desc = "The direction the bars will grow to in the container",
          values = {
            DOWN = "Down",
            UP = "Up",
          },
          get = function(Info) return Config.Layout.Direction; end,
          set = function(Info, Value) Config.Layout.Direction = Value; Container:Update("LAYOUT"); end,
          order = 4,
        },
        BarDirection = {
          type = "select",
          name = "Bar grow direction",
          desc = "The direction the bars will grow to",
          values = {
            LEFTGROW = "Left, grow",
            RIGHTGROW = "Right, grow",
            LEFTSHRINK = "Left, shrink",
            RIGHTSHRINK = "Right, shrink",
          },
          get = function(Info) return Config.Layout.BarDirection; end,
          set = function(Info, Value) Config.Layout.BarDirection = Value; Container:Update("LAYOUT"); end,
          order = 5,
        },
        BarWidth = {
          type = "input",
          name = "Width of the bars",
          get = function(Info) return tostring(Config.Layout.BarWidth); end,
          set = function(Info, Value) Config.Layout.BarWidth = tonumber(Value); Container:Update("LAYOUT"); end,
          order = 6,
          pattern = "^%d+.?%d*$",
          usage = "Only a number is allowed",
        },
        BarTexture = {
          type = "select",
          name = "Bar texture",
          dialogControl = "LSM30_Statusbar",
          values = LSM:HashTable("statusbar"),
          get = function(Info) return Config.Layout.BarTexture; end,
          set = function(Info, Value) Config.Layout.BarTexture = Value; Container:Update("LAYOUT"); end,
          order = 7,
        },
        SpaceAndTimingHeader = {
          type = "header",
          name = "Spacing and time",
          order = 8,
        },
        Space = {
          type = "range",
          name = "Space between the bars",
          min = 0.0,
          max = 30.0,
          step = 0.1,
          get = function(Info) return Config.Layout.Space; end,
          set = function(Info, Value) Config.Layout.Space = Value; Container:Update("LAYOUT"); end,
          order = 9,
        },
        BarMaxTime = {
          type = "input",
          name = "Max time",
          desc = "What is the max time needed to show a full bar.",
          get = function(Info) return tostring(Config.Layout.BarMaxTime); end,
          set = function(Info, Value) Config.Layout.BarMaxTime = tonumber(Value); Container:Update("LAYOUT"); end,
          order = 10,
          pattern = "^%d+.?%d*$",
          usage = "Only a number is allowed",
        },
        IconHeader = {
          type = "header",
          name = "Icon",
          order = 11,
        },
        Icon = {
          type = "select",
          name = "Icon",
          values = {
            NONE = "None",
            LEFT = "Left",
            RIGHT = "Right",
          },
          get = function(Info) return Config.Layout.Icon; end,
          set = function(Info, Value) Config.Layout.Icon = Value; Container:Update("LAYOUT"); end,
          order = 12,
        },
        OptionsHeader = {
          type = "header",
          name = "Options",
          order = 13,
        },
        ShowDuration = {
          type = "toggle",
          name = "Show duration",
          desc = "Show the duration of aura's",
          get = function(Info) return Config.Layout.ShowDuration; end,
          set = function(Info, Value) Config.Layout.ShowDuration = Value; Container:Update("LAYOUT"); end,
          order = 14,
        },
        DurationLayout = {
          type = "select",
          name = "Duration layout",
          desc = "How the duration is being displayed",
          values = {
            FORMAT      = "10 m",
            SEPCOLON    = "10:15",
            SEPDOT      = "10.15",
            SECONDS     = "615",
          },
          get = function(Info) return Config.Layout.DurationLayout; end,
          set = function(Info, Value) Config.Layout.DurationLayout = Value; Container:Update("LAYOUT"); end,
          order = 15,
        },
        ShowCount = {
          type = "toggle",
          name = "Show count",
          desc = "Show the number of applications of an aura",
          get = function(Info) return Config.Layout.ShowCount; end,
          set = function(Info, Value) Config.Layout.ShowCount = Value; Container:Update("LAYOUT"); end,
          order = 16,
        },
        ShowTooltip = {
          type = "toggle",
          name = "Show Tooltip",
          desc = "Show the tooltip with aura information when mouse over the button. The container must be clickable for this functionality.",
          get = function(Info) return Config.Layout.ShowTooltip; end,
          set = function(Info, Value) Config.Layout.ShowTooltip = Value; Container:Update("LAYOUT"); end,
          order = 17,
        },
        Clickable = {
          type = "toggle",
          name = "Clickable",
          desc = "Should the buttons reponde on a mouse clicks",
          get = function(Info) return Config.Layout.Clickable; end,
          set = function(Info, Value) Config.Layout.Clickable = Value; Container:Update("LAYOUT"); end,
          order = 18,
        },
        ColorsHeader = {
          type = "header",
          name = "Border Colors",
          order = 19,
        },
        ColorDebuffNone = {
          type = "color",
          name = "Unknown Debuff Type",
          get = function(Info) return unpack(Config.Colors.Debuff.None); end,
          set = function(Info, ...) Config.Colors.Debuff.None = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 20,
        },
        ColorDebuffMagic = {
          type = "color",
          name = "Debuff Type Magic",
          get = function(Info) return unpack(Config.Colors.Debuff.Magic); end,
          set = function(Info, ...) Config.Colors.Debuff.Magic = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 21,
        },
        ColorDebuffCurse = {
          type = "color",
          name = "Debuff Type Curse",
          get = function(Info) return unpack(Config.Colors.Debuff.Curse); end,
          set = function(Info, ...) Config.Colors.Debuff.Curse = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 22,
        },
        ColorDebuffDisease = {
          type = "color",
          name = "Debuff Type Disease",
          get = function(Info) return unpack(Config.Colors.Debuff.Disease); end,
          set = function(Info, ...) Config.Colors.Debuff.Disease = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 23,
        },
        ColorDebuffPoison = {
          type = "color",
          name = "Debuff Type Poison",
          get = function(Info) return unpack(Config.Colors.Debuff.Poison); end,
          set = function(Info, ...) Config.Colors.Debuff.Poison = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 24,
        },
        ColorBuff = {
          type = "color",
          name = "Buff",
          get = function(Info) return unpack(Config.Colors.Buff); end,
          set = function(Info, ...) Config.Colors.Buff = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 25,
        },
        ColorWeapon = {
          type = "color",
          name = "Weapon",
          get = function(Info) return unpack(Config.Colors.Weapon); end,
          set = function(Info, ...) Config.Colors.Weapon = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 26,
        },
        ColorOther = {
          type = "color",
          name = "Other",
          get = function(Info) return unpack(Config.Colors.Other); end,
          set = function(Info, ...) Config.Colors.Other = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = false,
          order = 27,
        },
        ResetColors = {
          type = "execute",
          name = "Reset colors",
          func = function(Info)
            Config.Colors = Module:GetConfigDefaults().Colors;
            Container:Update("LAYOUT");
            AuraFrames:RefreshConfigDialog();
           end,
          order = 28,
        },
        TooltipHeader = {
          type = "header",
          name = "Tooltip",
          order = 29,
        },
        TooltipShowPrefix = {
          type = "toggle",
          name = "Show prefix",
          desc = "Prefix extra info in the tooltip",
          get = function(Info) return Config.Layout.TooltipShowPrefix; end,
          set = function(Info, Value) Config.Layout.TooltipShowPrefix = Value; Container:Update("LAYOUT"); end,
          order = 30,
        },
        TooltipShowCaster = {
          type = "toggle",
          name = "Show Caster",
          desc = "Show the caster in the tooltip",
          get = function(Info) return Config.Layout.TooltipShowCaster; end,
          set = function(Info, Value) Config.Layout.TooltipShowCaster = Value; Container:Update("LAYOUT"); end,
          order = 31,
        },
        TooltipShowSpellId = {
          type = "toggle",
          name = "Show SpellId",
          desc = "Show the spell id in the tooltip",
          get = function(Info) return Config.Layout.TooltipShowSpellId; end,
          set = function(Info, Value) Config.Layout.TooltipShowSpellId = Value; Container:Update("LAYOUT"); end,
          order = 32,
        },
        TooltipShowClassification = {
          type = "toggle",
          name = "Show Classification",
          desc = "Show the aura classification the tooltip (magic, curse, poison or none)",
          get = function(Info) return Config.Layout.TooltipShowClassification; end,
          set = function(Info, Value) Config.Layout.TooltipShowClassification = Value; Container:Update("LAYOUT"); end,
          order = 33,
        },
      },
    },
    Filter = {
      type = "group",
      name = "Filter",
      order = 3,
      args = Container.Filter:BuildConfigOptions();
    },
    Order = {
      type = "group",
      name = "Order",
      order = 4,
      args = Container.Order:BuildConfigOptions();
    },
  };
  
  return Options;

end
