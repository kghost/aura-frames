local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");

local SelectedTabs = {};

-----------------------------------------------------------------
-- Function ContentLayout
-----------------------------------------------------------------
function Module:ContentLayout(ContainerId)

  AuraFramesConfig.Content:SetLayout("Fill");

  local Tab = AceGUI:Create("TabGroup");
  Tab:SetRelativeWidth(1);
  Tab:SetTabs({
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
  Tab:SetCallback("OnGroupSelected", function(_, _, Value)

    Module.Layout:PauseLayout();
    Module.Layout:ReleaseChildren();
    
    SelectedTabs[ContainerId] = Value;

    if Value == "SizeScale" then
    
      self:ContentTabSizeScale(self.Layout, ContainerId);
    
    elseif Value == "Display" then
    
      self:ContentTabDisplay(self.Layout, ContainerId);

    elseif Value == "Colors" then
    
      self:ContentTabColors(self.Layout, ContainerId);

    elseif Value == "Tooltip" then
    
      self:ContentTabTooltip(self.Layout, ContainerId);

    elseif Value == "ButtonFacade" then
    
      self:ContentTabButtonFacade(self.Layout, ContainerId);
    
    end

    Module.Layout:ResumeLayout();
    Module.Layout:DoLayout();

  end);
  AuraFramesConfig.Content:AddChild(Tab);
  
  Tab:SetLayout("Fill");
  
  self.Layout = AceGUI:Create("ScrollFrame");
  self.Layout:SetLayout("List");
  AuraFramesConfig:EnhanceContainer(self.Layout);
  Tab:AddChild(self.Layout);
  
  -- Select last tab otherwise if first tab.
  Tab:SelectTab(SelectedTabs[ContainerId] or "SizeScale");

end

