local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local LBF = LibStub("LibButtonFacade", true);
local AceGUI = LibStub("AceGUI-3.0");



-----------------------------------------------------------------
-- Function ContentTabButtonFacade
-----------------------------------------------------------------
function Module:ContentTabButtonFacade()

  self.Tab:SetLayout("List");
  
  if not LBF then
  
    self.Tab:AddText("\nButtonFacade is used for skinning the buttons.\n\nThe ButtonFacade addon is not found, please install or enable ButtonFacade addon if you want to use custom button skinning.");
  
    return;
  
  end

  local SkinList = LBF:ListSkins();
  
  self.Tab:AddText("\nButtonFacade is used for skinning the buttons.\n");
  
  local Skin = AceGUI:Create("Dropdown");
  Skin:SetList(SkinList);
  Skin:SetLabel("ButtonFacade Skin");
  self.Tab:AddChild(Skin);
  
  self.Tab:AddSpace();

  local GlossGroup = AceGUI:Create("InlineGroup");
  GlossGroup:SetRelativeWidth(1);
  GlossGroup:SetTitle("Gloss Settings");
  self.Tab:AddChild(GlossGroup);
  
  local GlossColor = AceGUI:Create("ColorPicker");
  GlossColor:SetLabel("Gloss texture color");
  GlossColor:SetHasAlpha(false);
  GlossGroup:AddChild(GlossColor);

  local GlossOpacity = AceGUI:Create("Slider");
  GlossOpacity:SetLabel("Intensity of the gloss");
  GlossOpacity:SetSliderValues(0, 1, 0.05);
  GlossOpacity:SetIsPercent(true);
  GlossGroup:AddChild(GlossOpacity);

  self.Tab:AddSpace();

  local BackdropGroup = AceGUI:Create("InlineGroup");
  BackdropGroup:SetRelativeWidth(1);
  BackdropGroup:SetTitle("Backdrop Settings");
  self.Tab:AddChild(BackdropGroup);
  
  local BackdropColor = AceGUI:Create("ColorPicker");
  BackdropColor:SetLabel("Backdrop color");
  BackdropColor:SetHasAlpha(false);
  BackdropGroup:AddChild(BackdropColor);

  local BackdropEnabled = AceGUI:Create("CheckBox");
  BackdropEnabled:SetLabel("Enable the backdrop");
  BackdropEnabled:SetValue(true);
  BackdropGroup:AddChild(BackdropEnabled);

end
