local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LBF = LibStub("LibButtonFacade", true);


-----------------------------------------------------------------
-- Function CreateButtonFacadeGroup
-----------------------------------------------------------------
function AuraFrames:CreateButtonFacadeGroup(ContainerId)

  if not LBF then
    return nil;
  end

  local db;

  local Group = LBF:Group("AuraFrames", ContainerId);

  if rawget(AuraFrames.db.profile.Containers, ContainerId) and AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade then
  
    db = AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade;
    
  elseif AuraFrames.db.profile.ButtonFacade then
  
    db = AuraFrames.db.profile.ButtonFacade;
  
  end

  if db then
    Group:Skin(db.SkinId, db.Gloss, db.Backdrop, db.Colors);
  end
  
  return Group;

end


-----------------------------------------------------------------
-- Local Function SkinCallback
-----------------------------------------------------------------
local function SkinCallback(_, SkinId, Gloss, Backdrop, ContainerId, Button, Colors)

  local db;

  if not ContainerId then

    if not AuraFrames.db.profile.ButtonFacade then
      AuraFrames.db.profile.ButtonFacade = {};
    end
    
    db = AuraFrames.db.profile.ButtonFacade;

  elseif rawget(AuraFrames.db.profile.Containers, ContainerId) and AuraFrames.db.profile.Containers[ContainerId].Layout then
  
    if not AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade then
      AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade = {};
    end
    
    db = AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade;

  end
  
  if db then
    db.SkinId = SkinId;
    db.Gloss = Gloss;
    db.Backdrop = Backdrop;
    db.Colors = Colors;
  end

end

if LBF then
  LBF:RegisterSkinCallback("AuraFrames", SkinCallback);
end
