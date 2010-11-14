local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:NewModule("BarContainer");

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
-- Function Update
-----------------------------------------------------------------
function Module:Update(ContainerId)

  local Container = AuraFrames.Containers[ContainerId];
  local Config = AuraFrames.db.profile.Containers[ContainerId];

  if Container.Unlocked == true and Container.UnlockFrame then
  
    Container.UnlockText:SetText("Container "..Config.Name.."\n"..Container.Config.Layout.NumberOfBars);
    Container.UnlockTextFrame:SetScale(1 / Config.Layout.Scale);
  
  end

end

-----------------------------------------------------------------
-- Function UnlockContainer
-----------------------------------------------------------------
function Module:UnlockContainer(ContainerId, Unlock)

  local Container = AuraFrames.Containers[ContainerId];
  
  if not Container then
    return;
  end

  Container.Unlocked = Unlock;
  
  if Unlock == true then
    
    if not Container.UnlockFrame then
    
      Container.UnlockFrame = CreateFrame("Frame", nil, Container.Frame);
      Container.UnlockFrame:SetAllPoints(Container.Frame);
      Container.UnlockFrame:EnableMouse(true);
      Container.UnlockFrame:SetFrameStrata("TOOLTIP");
      Container.UnlockFrame:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving(); end);
      Container.UnlockFrame:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing(); end);
      
      Container.UnlockBackground = Container.UnlockFrame:CreateTexture();
      Container.UnlockBackground:SetTexture(0.5, 0.8, 1.0, 0.8);
      Container.UnlockBackground:SetAllPoints(Container.UnlockFrame);
      
      Container.UnlockTextFrame = CreateFrame("Frame", nil, Container.UnlockFrame);
      Container.UnlockTextFrame:SetAllPoints(Container.UnlockFrame);
      
      Container.UnlockText = Container.UnlockTextFrame:CreateFontString();
      Container.UnlockText:SetFontObject(ChatFontNormal);
      Container.UnlockText:SetPoint("CENTER", Container.UnlockTextFrame, "CENTER");
      
    end
    
    Container.UnlockFrame:Show();
    
    self:Update(ContainerId);
    
  elseif Container.UnlockFrame then
    
    -- Make sure wow dont try to save the locations of the frame.
    Container.Frame:SetUserPlaced(false);
    
    Container.Config.Location.FramePoint, Container.Config.Location.RelativeTo, Container.Config.Location.RelativePoint, Container.Config.Location.OffsetX, Container.Config.Location.OffsetY = Container.Frame:GetPoint();
    
    if type(Container.Config.Location.RelativeTo) == "table" then
      Container.Config.Location.RelativeTo = Container.Config.Location.RelativeTo:GetID();
    end
    
    Container.UnlockFrame:Hide();
  
  end
  
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
