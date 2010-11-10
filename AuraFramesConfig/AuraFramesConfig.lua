local AuraFramesConfig = LibStub("AceAddon-3.0"):NewAddon("AuraFramesConfig", "AceConsole-3.0");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-----------------------------------------------------------------
-- Function OnInitialize
-----------------------------------------------------------------
function AuraFramesConfig:OnInitialize()

  local CloseSpecialWindowsOld = CloseSpecialWindows;
  
  CloseSpecialWindows = function()
    local Result = CloseSpecialWindowsOld();
    
    if self:IsListEditorShown() == true then
      self:CloseListEditor()
      return true;
    end
    
    return AuraFramesConfig:Close() or Result;
  end

end

-----------------------------------------------------------------
-- Function OnEnable
-----------------------------------------------------------------
function AuraFramesConfig:OnEnable()

end


-----------------------------------------------------------------
-- Function OnDisable
-----------------------------------------------------------------
function AuraFramesConfig:OnDisable()

end
