local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LBF = LibStub("LibButtonFacade");


-----------------------------------------------------------------
-- Function CreateButtonFacadeGroup
-----------------------------------------------------------------
function AuraFrames:CreateButtonFacadeGroup(ContainerId)

  local db;

  local Group = LBF:Group("AuraFrames", ContainerId);
  
--[[
  
  if AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade then
  
    db = AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade;
    
  elseif AuraFrames.db.profile.ButtonFacade then
  
    db = AuraFrames.db.profile.ButtonFacade;
  
  end

  if db then
    Group:SetSkin(db.SkinId, db.Gloss, db.Backdrop, db.Colors);
  end
  
]]--
  
  return Group;

end


-----------------------------------------------------------------
-- Local Function SkinCallback
-----------------------------------------------------------------
local function SkinCallback(_, SkinId, Gloss, Backdrop, ContainerId, Button, Colors)

  local db;

  if not Group then

    if not AuraFrames.db.profile.ButtonFacade then
      AuraFrames.db.profile.ButtonFacade = {};
    end
    
    db = AuraFrames.db.profile.ButtonFacade;

  elseif AuraFrames.db.profile.Containers[ContainerId] then

    if not AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade then
      AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade = {};
    end
    
    db = AuraFrames.db.profile.Containers[ContainerId].Layout.ButtonFacade;

  end
  
  db.SkinId = SkinId;
  db.Gloss = Gloss;
  db.Backdrop = Backdrop;
  db.Colors = Colors;

end


LBF:RegisterSkinCallback("AuraFrames", SkinCallback);
