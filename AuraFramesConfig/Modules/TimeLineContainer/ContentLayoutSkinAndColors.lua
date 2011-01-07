local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("TimeLineContainer");
local AceGUI = LibStub("AceGUI-3.0");
local LBF = LibStub("LibButtonFacade", true);
local LSM = LibStub("LibSharedMedia-3.0");


-----------------------------------------------------------------
-- Local Function ColorContent
-----------------------------------------------------------------
local function ColorContent(Content, ContainerId)

  local ColorConfig = AuraFrames.db.profile.Containers[ContainerId].Colors;
  local ContainerInstance = AuraFrames.Containers[ContainerId];
  local ContainerType = AuraFrames.db.profile.Containers[ContainerId].Type;

  Content:PauseLayout();
  Content:ReleaseChildren();
  
  Content:SetLayout("List");

  local BorderGroup = AceGUI:Create("SimpleGroup");
  BorderGroup:SetLayout("Flow");
  BorderGroup:SetRelativeWidth(1);
  Content:AddChild(BorderGroup);
  
  local ColorDebuffNone = AceGUI:Create("ColorPicker");
  ColorDebuffNone:SetHasAlpha(false);
  ColorDebuffNone:SetColor(unpack(ColorConfig.Debuff.None));
  ColorDebuffNone:SetLabel("Unknown Debuff Type");
  ColorDebuffNone:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Debuff.None = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorDebuffNone);

  local ColorDebuffMagic = AceGUI:Create("ColorPicker");
  ColorDebuffMagic:SetHasAlpha(false);
  ColorDebuffMagic:SetColor(unpack(ColorConfig.Debuff.Magic));
  ColorDebuffMagic:SetLabel("Debuff Type Magic");
  ColorDebuffMagic:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Debuff.Magic = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorDebuffMagic);

  local ColorDebuffCurse = AceGUI:Create("ColorPicker");
  ColorDebuffCurse:SetHasAlpha(false);
  ColorDebuffCurse:SetColor(unpack(ColorConfig.Debuff.Curse));
  ColorDebuffCurse:SetLabel("Debuff Type Curse");
  ColorDebuffCurse:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Debuff.Curse = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorDebuffCurse);

  local ColorDebuffDisease = AceGUI:Create("ColorPicker");
  ColorDebuffDisease:SetHasAlpha(false);
  ColorDebuffDisease:SetColor(unpack(ColorConfig.Debuff.Disease));
  ColorDebuffDisease:SetLabel("Debuff Type Disease");
  ColorDebuffDisease:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Debuff.Disease = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorDebuffDisease);

  local ColorDebuffPoison = AceGUI:Create("ColorPicker");
  ColorDebuffPoison:SetHasAlpha(false);
  ColorDebuffPoison:SetColor(unpack(ColorConfig.Debuff.Poison));
  ColorDebuffPoison:SetLabel("Debuff Type Poison");
  ColorDebuffPoison:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Debuff.Poison = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorDebuffPoison);

  local ColorBuff = AceGUI:Create("ColorPicker");
  ColorBuff:SetHasAlpha(false);
  ColorBuff:SetColor(unpack(ColorConfig.Buff));
  ColorBuff:SetLabel("Buff");
  ColorBuff:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Buff = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorBuff);

  local ColorWeapon = AceGUI:Create("ColorPicker");
  ColorWeapon:SetHasAlpha(false);
  ColorWeapon:SetColor(unpack(ColorConfig.Weapon));
  ColorWeapon:SetLabel("Weapon");
  ColorWeapon:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Weapon = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorWeapon);

  local ColorOther = AceGUI:Create("ColorPicker");
  ColorOther:SetHasAlpha(false);
  ColorOther:SetColor(unpack(ColorConfig.Other));
  ColorOther:SetLabel("Other");
  ColorOther:SetCallback("OnValueChanged", function(_, _, ...)
    ColorConfig.Other = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BorderGroup:AddChild(ColorOther);
  
  Content:AddSpace();
  
  local ColorReset = AceGUI:Create("AuraFramesButton");
  ColorReset:SetText("Reset Border Colors");
  ColorReset:SetCallback("OnClick", function()
    AuraFrames.db.profile.Containers[ContainerId].Colors = AuraFrames:GetModule(ContainerType):GetDatabaseDefaults().Colors;
    ContainerInstance:Update("LAYOUT");
    ColorContent(Content, ContainerId);
  end);
  Content:AddChild(ColorReset);
  
  Content:ResumeLayout();
  Content:DoLayout();

end


-----------------------------------------------------------------
-- Function ContentLayoutSkinAndColors
-----------------------------------------------------------------
function Module:ContentLayoutSkinAndColors(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:SetLayout("List");

  Content:AddText("Skin and Colors\n", GameFontNormalLarge);
  
  Content:AddHeader("Background");
  
  local BackgroundGroup = AceGUI:Create("SimpleGroup");
  BackgroundGroup:SetRelativeWidth(1);
  AuraFramesConfig:EnhanceContainer(BackgroundGroup);
  BackgroundGroup:SetLayout("Flow");
  Content:AddChild(BackgroundGroup);
  
  local BackgroundTexture = AceGUI:Create("LSM30_Statusbar");
  BackgroundTexture:SetList(LSM:HashTable("statusbar"));
  BackgroundTexture:SetLabel("Texture");
  BackgroundTexture:SetValue(LayoutConfig.BackgroundTexture);
  BackgroundTexture:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BackgroundTexture = Value;
    ContainerInstance:Update("LAYOUT");
    BackgroundTexture:SetValue(Value);
  end);
  BackgroundGroup:AddChild(BackgroundTexture);
  
  local BackgroundTextureInsets = AceGUI:Create("Slider");
  BackgroundTextureInsets:SetWidth(150);
  BackgroundTextureInsets:SetValue(LayoutConfig.BackgroundTextureInsets);
  BackgroundTextureInsets:SetLabel("Background insets");
  BackgroundTextureInsets:SetSliderValues(0, 16, 1);
  BackgroundTextureInsets:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BackgroundTextureInsets = Value;
    ContainerInstance:Update("LAYOUT");
    Module:Update(ContainerId);
  end);
  BackgroundGroup:AddChild(BackgroundTextureInsets);
  
  local BackgroundTextureColor = AceGUI:Create("ColorPicker");
  BackgroundTextureColor:SetWidth(150);
  BackgroundTextureColor:SetHasAlpha(true);
  BackgroundTextureColor:SetColor(unpack(LayoutConfig.BackgroundTextureColor));
  BackgroundTextureColor:SetLabel("Texture color");
  BackgroundTextureColor:SetCallback("OnValueChanged", function(_, _, ...)
    LayoutConfig.BackgroundTextureColor = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BackgroundGroup:AddChild(BackgroundTextureColor);
  
  local BackgroundTextureRotate = AceGUI:Create("CheckBox");
  BackgroundTextureRotate:SetLabel("Rotate background texture");
  --BackgroundTextureRotate:SetDescription("");
  BackgroundTextureRotate:SetValue(LayoutConfig.BackgroundTextureRotate);
  BackgroundTextureRotate:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BackgroundTextureRotate = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  BackgroundGroup:AddChild(BackgroundTextureRotate);
  
  local BackgroundTextureFlipX = AceGUI:Create("CheckBox");
  BackgroundTextureFlipX:SetLabel("Flip horizontal");
  --BackgroundTextureFlipX:SetDescription("");
  BackgroundTextureFlipX:SetWidth(150);
  BackgroundTextureFlipX:SetValue(LayoutConfig.BackgroundTextureFlipX);
  BackgroundTextureFlipX:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BackgroundTextureFlipX = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  BackgroundGroup:AddChild(BackgroundTextureFlipX);
  
  local BackgroundTextureFlipY = AceGUI:Create("CheckBox");
  BackgroundTextureFlipY:SetLabel("Flip vertical");
  --BackgroundTextureFlipY:SetDescription("");
  BackgroundTextureFlipY:SetWidth(150);
  BackgroundTextureFlipY:SetValue(LayoutConfig.BackgroundTextureFlipY);
  BackgroundTextureFlipY:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BackgroundTextureFlipY = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  BackgroundGroup:AddChild(BackgroundTextureFlipY);
  
  BackgroundGroup:AddSpace();
  
  local BackgroundBorder = AceGUI:Create("LSM30_Border");
  BackgroundBorder:SetList(LSM:HashTable("border"));
  BackgroundBorder:SetLabel("Border");
  BackgroundBorder:SetValue(LayoutConfig.BackgroundBorder);
  BackgroundBorder:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BackgroundBorder = Value;
    ContainerInstance:Update("LAYOUT");
    BackgroundBorder:SetValue(Value);
  end);
  BackgroundGroup:AddChild(BackgroundBorder);
  
  local BackgroundBorderSize = AceGUI:Create("Slider");
  BackgroundBorderSize:SetWidth(150);
  BackgroundBorderSize:SetValue(LayoutConfig.BackgroundBorderSize);
  BackgroundBorderSize:SetLabel("Border size");
  BackgroundBorderSize:SetSliderValues(2, 24, 1);
  BackgroundBorderSize:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BackgroundBorderSize = Value;
    ContainerInstance:Update("LAYOUT");
    Module:Update(ContainerId);
  end);
  BackgroundGroup:AddChild(BackgroundBorderSize);
  
  local BackgroundBorderColor = AceGUI:Create("ColorPicker");
  BackgroundBorderColor:SetWidth(150);
  BackgroundBorderColor:SetHasAlpha(true);
  BackgroundBorderColor:SetColor(unpack(LayoutConfig.BackgroundBorderColor));
  BackgroundBorderColor:SetLabel("Border color");
  BackgroundBorderColor:SetCallback("OnValueChanged", function(_, _, ...)
    LayoutConfig.BackgroundBorderColor = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  BackgroundGroup:AddChild(BackgroundBorderColor);
  
  BackgroundGroup:AddSpace();
  
  local InactiveAlpha = AceGUI:Create("Slider");
  InactiveAlpha:SetWidth(200);
  InactiveAlpha:SetValue(LayoutConfig.InactiveAlpha);
  InactiveAlpha:SetLabel("Inactive transparency");
  InactiveAlpha:SetSliderValues(0, 1, 0.01);
  InactiveAlpha:SetIsPercent(true);
  InactiveAlpha:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.InactiveAlpha = Value;
    ContainerInstance:Update("LAYOUT");
    Module:Update(ContainerId);
  end);
  BackgroundGroup:AddChild(InactiveAlpha);
  
  Content:AddSpace();

  Content:AddHeader("ButtonFacade");
  
  if not LBF then
  
    Content:AddText("ButtonFacade is used for skinning the buttons.\n\nThe ButtonFacade addon is not found, please install or enable ButtonFacade addon if you want to use custom button skinning.");
  
  else

    Content:AddText("ButtonFacade is used for skinning the buttons.\n");
    
    local ContentButtonFacade = AceGUI:Create("SimpleGroup");
    ContentButtonFacade:SetRelativeWidth(1);
    Content:AddChild(ContentButtonFacade);
    AuraFramesConfig:EnhanceContainer(ContentButtonFacade);

    AuraFramesConfig:ContentButtonFacade(ContentButtonFacade, ContainerInstance.LBFGroup);
  
  end
  
  Content:AddSpace();
  
  Content:AddHeader("Button Border Colors");

  local ContentColors = AceGUI:Create("SimpleGroup");
  ContentColors:SetRelativeWidth(1);
  Content:AddChild(ContentColors);
  AuraFramesConfig:EnhanceContainer(ContentColors);
  
  ColorContent(ContentColors, ContainerId);
  
  Content:AddSpace();

end
