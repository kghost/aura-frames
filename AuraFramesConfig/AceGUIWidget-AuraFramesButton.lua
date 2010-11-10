local AceGUI = LibStub and LibStub("AceGUI-3.0", true);

local Type, Version = "AuraFramesButton", 1;
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs = select, pairs;

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent;

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GameFontHighlightSmall

-----------------------------------------------------------------
-- Local Function AuraFramesButton_OnAcquire
-----------------------------------------------------------------
local function AuraFramesButton_OnAcquire(self)

  if self.ButtonOnAcquire then
    self:ButtonOnAcquire();
  end

end


-----------------------------------------------------------------
-- Local Function AuraFramesButton_OnRelease
-----------------------------------------------------------------
local function AuraFramesButton_OnRelease(self)

  if self.ButtonOnRelease then
    self:ButtonOnRelease();
  end
  
  self.frame:SetScript("OnShow", nil);

end


-----------------------------------------------------------------
-- Function Constructor
-----------------------------------------------------------------
local function Constructor()

  local Button = AceGUI:Create("Button");
  
  Button.ButtonOnAcquire = Button.OnAcquire;
  Button.ButtonOnRelease = Button.OnRelease;
  
  Button.OnAcquire = AuraFramesButton_OnAcquire;
  Button.OnRelease = AuraFramesButton_OnRelease;
  Button.type = Type;

  -- Fix the onclick of the ace button:
  
  Button.frame:SetScript("OnClick", function(frame, ...)
    PlaySound("igMainMenuOption");
    AceGUI:ClearFocus();
    frame.obj:Fire("OnClick", ...);
  end);

  return Button;

end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
