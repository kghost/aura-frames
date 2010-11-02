local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LBF = LibStub("LibButtonFacade", true);


-----------------------------------------------------------------
-- Local Function GetState
-----------------------------------------------------------------
local function GetState(info)

  -- Copied from ButtonFacade\Core.lua

  local LBFGroup, layer = info.arg[1], info.arg[2];
  local list = LBF:GetSkins();
  
  return list[LBFGroup.SkinID][layer].Hide;

end

-----------------------------------------------------------------
-- Function SkinCallback
-----------------------------------------------------------------
function AuraFrames:GetButtonFacadeContainerOptions(Container)

  if not LBF then
  
    return {
      
      BFInfo = {
        type = "description",
        name = "ButtonFacade provide the skinning of buttons.\n\nThe ButtonFacade addon is not found, please install ButtonFacade if you want to use custom button skinning.",
        fontSize = "medium",
        order = 1,
      },
    
    };
  
  end

  local SkinList, LBFGroup = LBF:ListSkins(), Container.LBFGroup;
  
  if not AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade then

    AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade = {SkinId = "Blizzard", Gloss = 0, Backdrop = false, Colors = {}};
    LBFGroup:ReSkin();

  end
  
  local db = AuraFrames.db.profile.Containers[Container.Id].Layout.ButtonFacade;
  
  
  local Options = {
    BFInfo = {
      type = "description",
      name = "ButtonFacade provide the skinning of buttons.\n",
      fontSize = "medium",
      order = 1,
    },
    BFSkin = {
      type = "select",
      name = "Skin",
      desc = "The ButtonFacade skin that this container will use.",
      values = SkinList,
      get = function() return LBFGroup.SkinID; end,
      set = function(_, Value) LBFGroup:Skin(Value, LBFGroup.Gloss, LBFGroup.Backdrop); end,
      order = 4,
    },
    BFGloss = {
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
          get = function() return LBFGroup:GetLayerColor("Gloss"); end,
          set = function(_, r, g, b, a) LBFGroup:SetLayerColor("Gloss", r, g, b, a); end,
          arg = {LBFGroup, "Gloss"},
          disabled = GetState,
          hasAlpha = false,
          order = 1,
        },
        Opacity = {
          type = "range",
          name = "Opacity",
          desc = "Set the intensity of the gloss.",
          min = 0,
          max = 1,
          step = 0.05,
          isPercent = true,
          get = function() return LBFGroup.Gloss or 0; end,
          set = function(_, Value) LBFGroup:Skin(LBFGroup.SkinID, Value, LBFGroup.Backdrop); end,
          arg = {LBFGroup, "Gloss"},
          disabled = GetState,
          order = 2,
        },
      },
    },
    BFBackdrop = {
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
          get = function() return LBFGroup:GetLayerColor("Backdrop"); end,
          set = function(_, r, g, b, a) LBFGroup:SetLayerColor("Backdrop", r, g, b, a); end,
          disabled = function() return not LBFGroup.Backdrop; end,
          hasAlpha = true,
          order = 1,
        },
        Enabled = {
          type = "toggle",
          name = "Enabled",
          desc = "Enable the backdrop.",
          get = function() return LBFGroup.Backdrop; end,
          set = function(_, Value) LBFGroup:Skin(LBFGroup.SkinID, LBFGroup.Gloss, Value and true or false); end,
          arg = {Container.LBFGroup, "Backdrop"},
          disabled = GetState,
          order = 2,
        },
      },
    },
  };
  
  return Options;

end
