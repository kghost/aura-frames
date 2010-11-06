local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentLayout
-----------------------------------------------------------------
function Module:ContentLayout()

  AuraFramesConfig.Content:SetLayout("Fill");

  self.Tab = AceGUI:Create("TabGroup");
  self.Tab:SetRelativeWidth(1);
  self.Tab:SetTabs({
    {
      value = "SizeScale",
      text = "Size and Scale",
    },
    {
      value = "Display",
      text = "Display",
    },
    {
      value = "Colors",
      text = "Colors",
    },
    {
      value = "Tooltip",
      text = "Tooltip",
    },
    {
      value = "ButtonFacade",
      text = "ButtonFacade",
    },
  });
  AuraFramesConfig:EnhanceContainer(self.Tab);
  AuraFramesConfig.Content:AddChild(self.Tab);

  self:ContentTabButtonFacade();

end

