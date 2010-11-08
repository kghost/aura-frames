local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:NewModule("ButtonContainer");

-----------------------------------------------------------------
-- Function OnInitialize
-----------------------------------------------------------------
function Module:OnInitialize()


end


-----------------------------------------------------------------
-- Function OnEnable
-----------------------------------------------------------------
function Module:OnEnable()

end


-----------------------------------------------------------------
-- Function OnDisable
-----------------------------------------------------------------
function Module:OnDisable()

end


-----------------------------------------------------------------
-- Function GetTree
-----------------------------------------------------------------
function Module:GetTree(ContainerId)

  if AuraFrames.db.profile.Containers[ContainerId].Enabled ~= true then
    return nil;
  end

  local Tree = {
    {
      value = "Sources",
      text = "Sources",
      execute = function() AuraFramesConfig:ContentSources(ContainerId); end,
    },
    {
      value = "Layout",
      text = "Layout",
      execute = function() Module:ContentLayout(ContainerId); end,
    },
    {
      value = "Warnings",
      text = "Warnings",
      execute = function() Module:ContentWarnings(ContainerId); end,
    },
    {
      value = "Order",
      text = "Order",
      execute = function() AuraFramesConfig:ContentOrder(ContainerId); end,
    },
    {
      value = "Filter",
      text = "Filter",
      execute = function() AuraFramesConfig:ContentFilter(ContainerId); end,
    },
  };
  
  return Tree;

end
