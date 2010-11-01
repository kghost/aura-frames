local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFrames:GetModule("ButtonContainer");

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
        HorizontalSize = {
          type = "select",
          name = "Rows",
          desc = "The number of aura rows the container will display",
          values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
          get = function(Info) return Config.Layout.HorizontalSize; end,
          set = function(Info, Value) Config.Layout.HorizontalSize = Value; Container:Update("LAYOUT"); end,
          order = 3,
        },
        VerticalSize = {
          type = "select",
          name = "Columns",
          desc = "The number of aura columns the container will display",
          values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
          get = function(Info) return Config.Layout.VerticalSize; end,
          set = function(Info, Value) Config.Layout.VerticalSize = Value; Container:Update("LAYOUT"); end,
          order = 4,
        },
        Direction = {
          type = "select",
          name = "Grow direction",
          desc = "The direction the auras will align to",
          values = {
            LEFTDOWN = "First left, then down",
            LEFTUP = "First left, then then up",
            RIGHTDOWN = "First right, then then down",
            RIGHTUP = "First right, then then up",
            DOWNLEFT = "First down, then then left",
            DOWNRIGHT = "First down, then then right",
            UPLEFT = "First up, then then left",
            UPRIGHT = "First up, then then right",
          },
          get = function(Info) return Config.Layout.Direction; end,
          set = function(Info, Value) Config.Layout.Direction = Value; Container:Update("LAYOUT"); end,
          order = 5,
        },
--[[ TODO: Implement DynamicSize
        DynamicSize = {
          type = "toggle",
          name = "Dynamic size",
          desc = "Let the container resize based on the number of aura's",
          get = function(Info) return Config.Layout.DynamicSize; end,
          set = function(Info, Value) Config.Layout.DynamicSize = Value; Container:Update("LAYOUT"); end,
          order = 6,
        },
]]--
        SpacingHeader = {
          type = "header",
          name = "Spacing",
          order = 7,
        },
        SpaceX = {
          type = "range",
          name = "Horizontal Space",
          min = 0.0,
          max = 30.0,
          step = 0.1,
          get = function(Info) return Config.Layout.SpaceX; end,
          set = function(Info, Value) Config.Layout.SpaceX = Value; Container:Update("LAYOUT"); end,
          order = 8,
        },
        SpaceY = {
          type = "range",
          name = "Vertical Space",
          min = 0.0,
          max = 30.0,
          step = 0.1,
          get = function(Info) return Config.Layout.SpaceY; end,
          set = function(Info, Value) Config.Layout.SpaceY = Value; Container:Update("LAYOUT"); end,
          order = 9,
        },
        OptionsHeader = {
          type = "header",
          name = "Options",
          order = 10,
        },
        ShowDuration = {
          type = "toggle",
          name = "Show duration",
          desc = "Show the duration of aura's",
          get = function(Info) return Config.Layout.ShowDuration; end,
          set = function(Info, Value) Config.Layout.ShowDuration = Value; Container:Update("LAYOUT"); end,
          order = 11,
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
          order = 12,
        },
        ShowCount = {
          type = "toggle",
          name = "Show count",
          desc = "Show the number of applications of an aura",
          get = function(Info) return Config.Layout.ShowCount; end,
          set = function(Info, Value) Config.Layout.ShowCount = Value; Container:Update("LAYOUT"); end,
          order = 13,
        },
        ShowTooltip = {
          type = "toggle",
          name = "Show Tooltip",
          desc = "Show the tooltip with aura information when mouse over the button. The container must be clickable for this functionality.",
          get = function(Info) return Config.Layout.ShowTooltip; end,
          set = function(Info, Value) Config.Layout.ShowTooltip = Value; Container:Update("LAYOUT"); end,
          order = 14,
        },
        Clickable = {
          type = "toggle",
          name = "Clickable",
          desc = "Should the buttons reponde on a mouse clicks",
          get = function(Info) return Config.Layout.Clickable; end,
          set = function(Info, Value) Config.Layout.Clickable = Value; Container:Update("LAYOUT"); end,
          order = 15,
        },
        ColorsHeader = {
          type = "header",
          name = "Colors",
          order = 16,
        },
        ColorDebuffNone = {
          type = "color",
          name = "Unknown Debuff Type",
          get = function(Info) return unpack(Config.Colors.Debuff.None); end,
          set = function(Info, ...) Config.Colors.Debuff.None = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 17,
        },
        ColorDebuffMagic = {
          type = "color",
          name = "Debuff Type Magic",
          get = function(Info) return unpack(Config.Colors.Debuff.Magic); end,
          set = function(Info, ...) Config.Colors.Debuff.Magic = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 18,
        },
        ColorDebuffCurse = {
          type = "color",
          name = "Debuff Type Curse",
          get = function(Info) return unpack(Config.Colors.Debuff.Curse); end,
          set = function(Info, ...) Config.Colors.Debuff.Curse = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 19,
        },
        ColorDebuffDisease = {
          type = "color",
          name = "Debuff Type Disease",
          get = function(Info) return unpack(Config.Colors.Debuff.Disease); end,
          set = function(Info, ...) Config.Colors.Debuff.Disease = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 20,
        },
        ColorDebuffPoison = {
          type = "color",
          name = "Debuff Type Poison",
          get = function(Info) return unpack(Config.Colors.Debuff.Poison); end,
          set = function(Info, ...) Config.Colors.Debuff.Poison = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 21,
        },
        ColorBuff = {
          type = "color",
          name = "Buff",
          get = function(Info) return unpack(Config.Colors.Buff); end,
          set = function(Info, ...) Config.Colors.Buff = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 22,
        },
        ColorWeapon = {
          type = "color",
          name = "Weapon",
          get = function(Info) return unpack(Config.Colors.Weapon); end,
          set = function(Info, ...) Config.Colors.Weapon = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 23,
        },
        ColorOther = {
          type = "color",
          name = "Other",
          get = function(Info) return unpack(Config.Colors.Other); end,
          set = function(Info, ...) Config.Colors.Other = {...}; Container:Update("LAYOUT"); end,
          hasAlpha = true,
          order = 24,
        },
        ResetColors = {
          type = "execute",
          name = "Reset colors",
          func = function(Info)
            Config.Colors = Module:GetConfigDefaults().Colors;
            Container:Update("LAYOUT");
            AuraFrames:RefreshConfigDialog();
           end,
          order = 25,
        },
        TooltipHeader = {
          type = "header",
          name = "Tooltip",
          order = 26,
        },
        TooltipShowPrefix = {
          type = "toggle",
          name = "Show prefix",
          desc = "Prefix extra info in the tooltip",
          get = function(Info) return Config.Layout.TooltipShowPrefix; end,
          set = function(Info, Value) Config.Layout.TooltipShowPrefix = Value; Container:Update("LAYOUT"); end,
          order = 27,
        },
        TooltipShowCaster = {
          type = "toggle",
          name = "Show Caster",
          desc = "Show the caster in the tooltip",
          get = function(Info) return Config.Layout.TooltipShowCaster; end,
          set = function(Info, Value) Config.Layout.TooltipShowCaster = Value; Container:Update("LAYOUT"); end,
          order = 28,
        },
        TooltipShowSpellId = {
          type = "toggle",
          name = "Show SpellId",
          desc = "Show the spell id in the tooltip",
          get = function(Info) return Config.Layout.TooltipShowSpellId; end,
          set = function(Info, Value) Config.Layout.TooltipShowSpellId = Value; Container:Update("LAYOUT"); end,
          order = 29,
        },
        TooltipShowClassification = {
          type = "toggle",
          name = "Show Classification",
          desc = "Show the aura classification the tooltip (magic, curse, poison or none)",
          get = function(Info) return Config.Layout.TooltipShowClassification; end,
          set = function(Info, Value) Config.Layout.TooltipShowClassification = Value; Container:Update("LAYOUT"); end,
          order = 30,
        },
        ButtonFacadeHeader = {
          type = "header",
          name = "ButtonFacade",
          order = 31,
        },
      },
    },
    Warnings = {
      type = "group",
      name = "Warnings",
      order = 2,
      args = {
        NewHeader = {
          type = "header",
          name = "New Aura's",
          order = 1,
        },
        NewFlash = {
          type = "group",
          name = "Flash",
          inline = true,
          order = 3,
          args = {
            Enable = {
              type = "toggle",
              name = "Enable Flash",
              get = function(Info) return Config.Warnings.New.Flash; end,
              set = function(Info, Value) Config.Warnings.New.Flash = Value; Container:Update("WARNINGS"); end,
              order = 1,
            },
            Number = {
              type = "range",
              name = "Number",
              desc = "Number of flashes",
              min = 1,
              max = 10,
              step = 1,
              get = function(Info) return Config.Warnings.New.FlashNumber; end,
              set = function(Info, Value) Config.Warnings.New.FlashNumber = Value; Container:Update("WARNINGS"); end,
              order = 2,
            },
            Speed = {
              type = "range",
              name = "Speed",
              desc = "Speed in seconds",
              min = 0.5,
              max = 2.0,
              step = 0.1,
              get = function(Info) return Config.Warnings.New.FlashSpeed; end,
              set = function(Info, Value) Config.Warnings.New.FlashSpeed = Value; Container:Update("WARNINGS"); end,
              order = 3,
            },
          },
        },
        ExpireHeader = {
          type = "header",
          name = "Expiring Aura's",
          order = 4,
        },
        ExpireFlash = {
          type = "group",
          name = "Flash",
          inline = true,
          order = 6,
          args = {
            Enable = {
              type = "toggle",
              name = "Enable Flash",
              get = function(Info) return Config.Warnings.Expire.Flash; end,
              set = function(Info, Value) Config.Warnings.Expire.Flash = Value; Container:Update("WARNINGS"); end,
              order = 1,
            },
            Number = {
              type = "range",
              name = "Time",
              desc = "Number of flashes",
              min = 1,
              max = 10,
              step = 1,
              get = function(Info) return Config.Warnings.Expire.FlashNumber; end,
              set = function(Info, Value) Config.Warnings.Expire.FlashNumber = Value; Container:Update("WARNINGS"); end,
              order = 2,
            },
            Speed = {
              type = "range",
              name = "Speed",
              desc = "Speed in seconds",
              min = 0.5,
              max = 2.0,
              step = 0.1,
              get = function(Info) return Config.Warnings.Expire.FlashSpeed; end,
              set = function(Info, Value) Config.Warnings.Expire.FlashSpeed = Value; Container:Update("WARNINGS"); end,
              order = 3,
            },
          },
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
  
--[[
  -- Intergrate ButtonFacade options.
  for Index, Option in pairs(AuraFrames:GetButtonFacadeContainerOptions(self)) do
    
    Options.Layout.args[Index] = Option;
    Options.Layout.args[Index].order = Options.Layout.args[Index].order + 100;
  
  end
]]--
  
  return Options;

end
