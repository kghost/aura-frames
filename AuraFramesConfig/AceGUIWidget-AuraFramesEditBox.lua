local AceGUI = LibStub and LibStub("AceGUI-3.0", true);

local Type, Version = "AuraFramesEditBox", 1;
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs = select, pairs;

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent;

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GameFontHighlightSmall

-----------------------------------------------------------------
-- Local Function AuraFramesEditBox_OnAcquire
-----------------------------------------------------------------
local function AuraFramesEditBox_OnAcquire(self)

  if self.EditBoxOnAcquire then
    self:EditBoxOnAcquire();
  end

end


-----------------------------------------------------------------
-- Local Function AuraFramesEditBox_OnRelease
-----------------------------------------------------------------
local function AuraFramesEditBox_OnRelease(self)

  if self.EditBoxOnRelease then
    self:EditBoxOnRelease();
  end
  
  self.frame:SetScript("OnShow", nil);

end


-----------------------------------------------------------------
-- Local Function AuraFramesEditBox_ClearFocus
-----------------------------------------------------------------
local function AuraFramesEditBox_ClearFocus(self)

  self.editbox:ClearFocus();

end


-----------------------------------------------------------------
-- Local Function AuraFramesEditBox_SetFocus
-----------------------------------------------------------------
local function AuraFramesEditBox_SetFocus(self)

  self.editbox:SetFocus();
  
  self.frame:SetScript("OnShow", function()
    self.editbox:SetFocus();
  end);
  
end


-----------------------------------------------------------------
-- Function Constructor
-----------------------------------------------------------------
local function Constructor()

  local EditBox = AceGUI:Create("EditBox");
  
  EditBox.EditBoxOnAcquire = EditBox.OnAcquire;
  EditBox.EditBoxOnRelease = EditBox.OnRelease;
  
  EditBox.OnAcquire = AuraFramesEditBox_OnAcquire;
  EditBox.OnRelease = AuraFramesEditBox_OnRelease;
  EditBox.type = Type;
  EditBox.Focus = false;
  
  if not EditBox.ClearFocus then
    EditBox.ClearFocus = AuraFramesEditBox_ClearFocus;
  end
  
  EditBox.editbox:SetScript("OnEditFocusGained", function()
    AceGUI:SetFocus(EditBox);
  end);
  
  if not EditBox.SetFocus then
    EditBox.SetFocus = AuraFramesEditBox_SetFocus;
  end
  
  return EditBox;

end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
