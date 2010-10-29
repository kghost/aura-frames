local LibGUI = LibStub("LibGUI-1.0");

local Prototype = LibGUI:NewWidgetPrototype("Button", 0);

if not Prototype then return; end;


-----------------------------------------------------------------
-- Function Constructor
-----------------------------------------------------------------
function Prototype:Constructor()

  local Name = "LibGUIButton"..LibGUI:GetNewWidgetId(self);

  self.Frame = CreateFrame("Button", Name, UIParent, "UIPanelButtonTemplate2");
  self.Frame:EnableMouse(true);
  
  local Left = _G[Name .. "Left"];
  local Right = _G[Name .. "Right"];
  local Middle = _G[Name .. "Middle"];
  
  Left:SetPoint("TOP", self.Frame, "TOP", 0, 0);
  Left:SetPoint("BOTTOM", self.Frame, "BOTTOM", 0, 0);
  
  Right:SetPoint("TOP", self.Frame, "TOP", 0, 0);
  Right:SetPoint("BOTTOM", self.Frame, "BOTTOM", 0, 0);
  
  Middle:SetPoint("TOP", self.Frame, "TOP", 0, 0);
  Middle:SetPoint("BOTTOM", self.Frame, "BOTTOM", 0, 0);

  self.Text = self.Frame:GetFontString();
  self.Text:ClearAllPoints();
  self.Text:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 15, -1);
  self.Text:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT", -15, 1);
  self.Text:SetJustifyV("MIDDLE");

  local Button = self;

  self.Frame:SetScript("OnClick", function(...)
    Button:Fire("OnClick", ...);
    LibGUI:ClearFocus();
  end);
  self.Frame:SetScript("OnEnter", function()
    Button:Fire("OnEnter");
  end);
  self.Frame:SetScript("OnLeave", function()
    Button:Fire("OnLeave");
  end);

end


-----------------------------------------------------------------
-- Function OnAcquire
-----------------------------------------------------------------
function Prototype:OnAcquire()

end


-----------------------------------------------------------------
-- Function OnRelease
-----------------------------------------------------------------
function Prototype:OnRelease()

  self:SetDisabled(false);

end


-----------------------------------------------------------------
-- Function SetText
-----------------------------------------------------------------
function Prototype:SetText()

  self.Text:SetText(text or "");

end


-----------------------------------------------------------------
-- Function SetDisabled
-----------------------------------------------------------------
function Prototype:SetDisabled(Disabled)

  self.Disabled = Disabled;
  if disabled then
    self.Frame:Disable();
  else
    self.Frame:Enable();
  end

end
