local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentOrderRefresh
-----------------------------------------------------------------
function AuraFramesConfig:ContentOrderRefresh(Content, ContainerId)

  local OrderConfig = AuraFrames.db.profile.Containers[ContainerId].Order;
  local ContainerInstance = AuraFrames.Containers[ContainerId];
  
  Content:PauseLayout();
  Content:ReleaseChildren();
  
  Content:SetLayout("List");
  
  Content:AddText("Order\n", GameFontNormalLarge);
  
  
  
  Content:ResumeLayout();
  Content:DoLayout();

end


-----------------------------------------------------------------
-- Function ContentOrder
-----------------------------------------------------------------
function AuraFramesConfig:ContentOrder(ContainerId)

  self.Content:SetLayout("Fill");
  
  local Content = AceGUI:Create("ScrollFrame");
  Content:SetLayout("List");
  self:EnhanceContainer(Content);
  self.Content:AddChild(Content);
  
  self:ContentOrderRefresh(Content, ContainerId);

end

