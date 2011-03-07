local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local LBF = LibStub("LibButtonFacade", true);
local AceGUI = LibStub("AceGUI-3.0");

-----------------------------------------------------------------
-- Function ContentLayoutColors
-----------------------------------------------------------------
function Module:ContentLayoutColors(Content, ContainerId)

  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:SetLayout("List");

  Content:AddText("Colors\n", GameFontNormalLarge);

  local ContentColors = AceGUI:Create("SimpleGroup");
  ContentColors:SetRelativeWidth(1);
  Content:AddChild(ContentColors);
  AuraFramesConfig:EnhanceContainer(ContentColors);
  
  AuraFramesConfig:ContentColors(ContentColors, ContainerId);

end