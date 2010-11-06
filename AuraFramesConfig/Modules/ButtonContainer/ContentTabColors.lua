local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentTabColors
-----------------------------------------------------------------
function Module:ContentTabColors(Content, ContainerId)

  local OrderConfig = AuraFrames.db.profile.Containers[ContainerId].Order;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:SetLayout("List");

  Content:AddText("Colors\n", GameFontNormalLarge);

end
