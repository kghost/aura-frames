local AceGUI = LibStub("AceGUI-3.0")

--------------------------
-- Edit box			 --
--------------------------
--[[
  Events :
    OnTextChanged
    OnEnterPressed

]]
do
  local Type = "TextLabel"
  local Version = 1

  local function OnAcquire(self)
  end
  
  local function OnRelease(self)
    self.frame:ClearAllPoints()
    self.frame:Hide()
  end

  local function SetText(self, Text)
    self.TextLabel:SetText(Text);
  end
  
  local function SetLabel(self, Text)
  end
  
  local function SetWidth(self, Width)
    self.frame:SetWidth(Width)
  end
  
  local function Constructor()

    local self = {}
    
    local Number  = AceGUI:GetNextWidgetNum(Type)
    local Frame = CreateFrame("Frame", nil, UIParent)
    
    local TextLabel = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    self.TextLabel = TextLabel;
    
    TextLabel:SetPoint("LEFT", Frame, "LEFT", 0, 0);
    
    self.type = Type
    self.num = Number
    
    self.OnRelease = OnRelease
    self.OnAcquire = OnAcquire

    self.SetText = SetText
    self.SetWidth = SetWidth
    self.SetLabel = SetLabel
    
    self.frame = Frame
    Frame.obj = self
    
    self.alignoffset = 30
    
    Frame:SetHeight(60)
    Frame:SetWidth(200)

    AceGUI:RegisterAsWidget(self)
    return self
  end
  
  AceGUI:RegisterWidgetType(Type, Constructor, Version)
end
