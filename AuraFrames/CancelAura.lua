local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

--[[

Sinds 4.0.1 Blizzard made CancelUnitBuff and CancelItemTempEnchantment
protected so normal addons without secure templates cant cancel auras
anymore. This script allows the user to cancel auras without using
secure templates. This is only working outside combat!

This script also handles the normal canceling of auras that are still
working like totem auras.

]]--


-- Create the secure button we use for canceling auras.
local CancelAuraButton = CreateFrame("Button", "AuraFramesButtonContainerActionButton", UIParent, "SecureActionButtonTemplate");
CancelAuraButton:Hide();
CancelAuraButton:SetFrameStrata("HIGH")
CancelAuraButton:RegisterForClicks("RightButtonUp");
CancelAuraButton:SetScript("OnLeave", function(self, ...) self:Hide(); RestoreHandlers(); FireHandler("OnLeave", ...); end);
CancelAuraButton:SetAttribute("type2", "cancelaura");
CancelAuraButton:HookScript("OnClick", function(self, ...) FireHandler("OnClick", ...); end);
CancelAuraButton:HookScript("OnMouseUp", function(self, ...) FireHandler("OnMouseUp", ...); end);


-----------------------------------------------------------------
-- Local Function FireHandler
-----------------------------------------------------------------
function FireHandler(Handler, ...)

  if not CancelAuraButton.Frame:HasScript(Handler) then
    return;
  end

  local Function = CancelAuraButton.Frame:GetScript(Handler);
  
  if Function then
    Function(CancelAuraButton.Frame, ...);
  end

end


-----------------------------------------------------------------
-- Local Function BackupHandlers
-----------------------------------------------------------------
function BackupHandlers()

  CancelAuraButton.FrameOnEnter = CancelAuraButton.Frame:GetScript("OnEnter");
  CancelAuraButton.FrameOnLeave = CancelAuraButton.Frame:GetScript("OnLeave");

  CancelAuraButton.Frame:SetScript("OnEnter", nil);
  CancelAuraButton.Frame:SetScript("OnLeave", nil);

end


-----------------------------------------------------------------
-- Local Function RestoreHandlers
-----------------------------------------------------------------
function RestoreHandlers()

  CancelAuraButton.Frame:SetScript("OnEnter", CancelAuraButton.FrameOnEnter);
  CancelAuraButton.Frame:SetScript("OnLeave", CancelAuraButton.FrameOnLeave);

  CancelAuraButton.FrameOnEnter = nil;
  CancelAuraButton.FrameOnLeave = nil;

end


-----------------------------------------------------------------
-- Function SetCancelAuraFrame
-----------------------------------------------------------------
function AuraFrames:SetCancelAuraFrame(Frame, Aura)

  -- Check if we can cancel the aura.
  if not (Aura.Type == "HELPFUL" and (Aura.Unit == "player" or Aura.Unit == "pet")) then
    return;
  end

  CancelAuraButton.Frame = Frame;
  
  BackupHandlers();
  
  CancelAuraButton:SetAllPoints(Frame);

  CancelAuraButton:SetAttribute("unit", Aura.Unit);
  CancelAuraButton:SetAttribute("index", Aura.Index);

  CancelAuraButton:Show();
  
  if CancelAuraButton:IsShown() == nil then
    -- We are maybe in combat and we couldnt show the button.
    -- We are directly restoring the old handlers and leave it.
    
    RestoreHandlers();
  
  end
  
end


-----------------------------------------------------------------
-- Function CancelAura
-----------------------------------------------------------------
function AuraFrames:CancelAura(Aura)

  if Aura.Type == "TOTEM" then

    DestroyTotem(Aura.Index);
  
  elseif Aura.Type == "WEAPON" then
  
    -- Not working at all it seems?
    -- http://www.wowinterface.com/forums/showthread.php?t=36117&highlight=sigg
    --CancelItemTempEnchantment((Aura.Index == 16 and 1) or 2);
  
  end

end



