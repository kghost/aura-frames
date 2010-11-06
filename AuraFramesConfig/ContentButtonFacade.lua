local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LBF = LibStub("LibButtonFacade", true);
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Local Function GetState
-----------------------------------------------------------------
local function GetState(LBFGroup, Layer)

  local List = LBF:GetSkins();
  
  return List[LBFGroup.SkinID][Layer].Hide;

end


-----------------------------------------------------------------
-- Function ContentButtonFacade
-----------------------------------------------------------------
function AuraFramesConfig:ContentButtonFacade(Content, LBFGroup)

  if not LBF then
    return;
  end

  Content:PauseLayout();
  Content:ReleaseChildren();
  
  Content:SetLayout("List");
  
  local SkinList = LBF:ListSkins();
  
  local Skin = AceGUI:Create("Dropdown");
  Skin:SetList(SkinList);
  Skin:SetValue(LBFGroup.SkinID);
  Skin:SetLabel("ButtonFacade Skin");
  Skin:SetCallback("OnValueChanged", function(_, _, Value)
    LBFGroup:Skin(Value, LBFGroup.Gloss, LBFGroup.Backdrop);
    AuraFramesConfig:ContentButtonFacade(Content, LBFGroup);
  end);
  Content:AddChild(Skin);
  
  Content:AddSpace();

  local GlossGroup = AceGUI:Create("InlineGroup");
  GlossGroup:SetRelativeWidth(1);
  GlossGroup:SetTitle("Gloss Settings");
  Content:AddChild(GlossGroup);
  
  local GlossColor = AceGUI:Create("ColorPicker");
  GlossColor:SetDisabled(GetState(LBFGroup, "Gloss"));
  GlossColor:SetHasAlpha(false);
  GlossColor:SetColor(LBFGroup:GetLayerColor("Gloss"));
  GlossColor:SetLabel("Gloss texture color");
  GlossColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
    LBFGroup:SetLayerColor("Gloss", r, g, b, a);
  end);
  GlossGroup:AddChild(GlossColor);

  local GlossOpacity = AceGUI:Create("Slider");
  GlossOpacity:SetDisabled(GetState(LBFGroup, "Gloss"));
  GlossOpacity:SetValue(LBFGroup.Gloss or 0);
  GlossOpacity:SetLabel("Intensity of the gloss");
  GlossOpacity:SetSliderValues(0, 1, 0.05);
  GlossOpacity:SetIsPercent(true);
  GlossOpacity:SetCallback("OnValueChanged", function(_, _, Value)
    LBFGroup:Skin(LBFGroup.SkinID, Value, LBFGroup.Backdrop);
  end);
  GlossGroup:AddChild(GlossOpacity);

  Content:AddSpace();

  local BackdropGroup = AceGUI:Create("InlineGroup");
  BackdropGroup:SetRelativeWidth(1);
  BackdropGroup:SetTitle("Backdrop Settings");
  Content:AddChild(BackdropGroup);
  
  local BackdropColor = AceGUI:Create("ColorPicker");
  BackdropColor:SetDisabled(GetState(LBFGroup, "Backdrop") or not LBFGroup.Backdrop);
  BackdropColor:SetHasAlpha(true);
  BackdropColor:SetColor(LBFGroup:GetLayerColor("Backdrop"));
  BackdropColor:SetLabel("Backdrop color");
  BackdropColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
    LBFGroup:SetLayerColor("Backdrop", r, g, b, a);
  end);
  BackdropGroup:AddChild(BackdropColor);

  local BackdropEnabled = AceGUI:Create("CheckBox");
  BackdropEnabled:SetDisabled(GetState(LBFGroup, "Backdrop"));
  BackdropEnabled:SetLabel("Enable the backdrop");
  BackdropEnabled:SetValue(LBFGroup.Backdrop);
  BackdropEnabled:SetCallback("OnValueChanged", function(_, _,Value)
    LBFGroup:Skin(LBFGroup.SkinID, LBFGroup.Gloss, Value and true or false);
    AuraFramesConfig:ContentButtonFacade(Content, LBFGroup);
  end);
  BackdropGroup:AddChild(BackdropEnabled);
  
  Content:ResumeLayout();
  Content:DoLayout();

end
