local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LBF = LibStub("LibButtonFacade");


-----------------------------------------------------------------
-- Function SkinCallback
-----------------------------------------------------------------
function AuraFrames:GetButtonFacadeContainerOptions(Container)

  local SkinList = LBF:ListSkins();
  
  local Options = {
    BFInfo = {
      type = "description",
      name = "ButtonFacade provide the skinning of buttons.",
      fontSize = "medium",
      order = 1,
    },
    BFUseDefault = {
      type = "toggle",
      name = "Use default settings",
      desc = "Use the default ButtonFacade settings that are set for the whole addon.",
      get = function() return AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade and true or false; end,
      set = function(_, Value)
        if Value == true then
          AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade = nil;
        else
          AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade = {SkinId = "Blizzard", Gloss = 0, Backdrop = false, Colors = {}};
        end
      end,
      order = 2,
    },
  }
  
  if AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade then
  
    local db = AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade;
  
    Options.BFSep = {
      type = "description",
      name = "\n",
      order = 3,
    };
    Options.BFSkin = {
      type = "select",
      name = "Skin",
      desc = "The ButtonFacade skin that this container will use.",
      values = SkinList,
      get = function() return db.SkinId; end,
      set = function(_, Value) db.SkinId = Value; Container:Update("LAYOUT"); end,
      order = 4,
    };
    Options.BFGloss = {
      type = "group",
      inline = true,
      name = "Gloss Settings",
      order = 5,
      args = {
        Color = {
          type = "color",
          name = "Color",
          desc = "Set the color of the gloss texture.",
          width = "full",
          get = function() return end,
          set = function() end,
          hasAlpha = false,
          order = 1,
        },
        Opacity = {
          type = "range",
          name = "Opacity",
          desc = "Set the intensity of the gloss.",
          min = 0,
          max = 100,
          step = 1,
          isPercent = true,
          get = function() end,
          set = function() end,
          order = 2,
        },
      },
    };
    Options.BFBackdrop = {
      type = "group",
      inline = true,
      name = "Backdrop Settings",
      order = 6,
      args = {
        Color = {
          type = "color",
          name = "Color",
          desc = "Set the backdrop color.",
          width = "full",
          get = function() end,
          set = function() end,
          hasAlpha = true,
          order = 1,
        },
        Enabled = {
          type = "toggle",
          name = "Enabled",
          desc = "Enable the backdrop.",
          get = function() end,
          set = function() end,
          order = 2,
        },
      },
    };

  end
  
  return Options;

end
