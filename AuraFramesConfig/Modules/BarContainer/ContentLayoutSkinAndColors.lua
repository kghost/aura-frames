local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("BarContainer");
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
  
  local ColorReset = AceGUI:Create("Button");
  ColorReset:SetText("Reset Border Colors");
  ColorReset:SetCallback("OnClick", function()
    AuraFrames.db.profile.Containers[ContainerId].Colors = AuraFrames:GetModule(ContainerType):GetConfigDefaults().Colors;
    ContainerInstance:Update("LAYOUT");
    ColorContent(Content, ContainerId);
  end);
  Content:AddChild(ColorReset);
  
  Content:ResumeLayout();
  Content:DoLayout();

end


-----------------------------------------------------------------
-- Local Function BackgroundContent
-----------------------------------------------------------------
local function BackgroundContent(Content, ContainerId)

  local LayoutConfig = AuraFrames.db.profile.Containers[ContainerId].Layout;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:PauseLayout();
  Content:ReleaseChildren();
  
  Content:SetLayout("List");
  
  local BackgroundGroup = AceGUI:Create("SimpleGroup");
  BackgroundGroup:SetLayout("Flow");
  BackgroundGroup:SetRelativeWidth(1);
  Content:AddChild(BackgroundGroup);
  
  local UseTexture = AceGUI:Create("CheckBox");
  UseTexture:SetRelativeWidth(1);
  UseTexture:SetLabel("Use as background the bar texture");
  UseTexture:SetDescription("You can change the color and opacity of an texture when using this.");
  UseTexture:SetValue(LayoutConfig.TextureBackgroundUseTexture);
  UseTexture:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextureBackgroundUseTexture = Value;
    ContainerInstance:Update("LAYOUT");
    BackgroundContent(Content, ContainerId);
  end);
  BackgroundGroup:AddChild(UseTexture);
  
  local UseBarColor = AceGUI:Create("CheckBox");
  UseBarColor:SetWidth(300);
  UseBarColor:SetLabel("Use the color from the bar");
  UseBarColor:SetDescription("The color of the main bar will also be used as background, you can still change the opacity of the background.");
  UseBarColor:SetValue(LayoutConfig.TextureBackgroundUseBarColor);
  UseBarColor:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.TextureBackgroundUseBarColor = Value;
    BackgroundContent(Content, ContainerId);
    ContainerInstance:Update("LAYOUT");
  end);
  BackgroundGroup:AddChild(UseBarColor);
  
  if LayoutConfig.TextureBackgroundUseBarColor == true then
  
    local TextureBackgroundOpacity = AceGUI:Create("Slider");
    TextureBackgroundOpacity:SetValue(LayoutConfig.TextureBackgroundOpacity);
    TextureBackgroundOpacity:SetLabel("The opacity of the texture");
    TextureBackgroundOpacity:SetSliderValues(0, 1, 0.01);
    TextureBackgroundOpacity:SetIsPercent(true);
    TextureBackgroundOpacity:SetCallback("OnValueChanged", function(_, _, Value)
      LayoutConfig.TextureBackgroundOpacity = Value;
      ContainerInstance:Update("LAYOUT");
    end);
    BackgroundGroup:AddChild(TextureBackgroundOpacity);
    
  else
    
    local ColorBarBackground = AceGUI:Create("ColorPicker");
    ColorBarBackground:SetHasAlpha(true);
    ColorBarBackground:SetColor(unpack(LayoutConfig.TextureBackgroundColor));
    ColorBarBackground:SetLabel("Bar Background");
    ColorBarBackground:SetCallback("OnValueChanged", function(_, _, ...)
      LayoutConfig.TextureBackgroundColor = {...};
      ContainerInstance:Update("LAYOUT");
    end);
    BackgroundGroup:AddChild(ColorBarBackground);
  
  end
  
  local ColorUseSame = AceGUI:Create("CheckBox");
  ColorUseSame:SetWidth(300);
  ColorUseSame:SetLabel("Use the same color for button as bar");
  ColorUseSame:SetDescription("This will use the background color from the normal background.");
  ColorUseSame:SetValue(LayoutConfig.ButtonBackgroundUseBar);
  ColorUseSame:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ButtonBackgroundUseBar = Value;
    ContainerInstance:Update("LAYOUT");
    BackgroundContent(Content, ContainerId)
  end);
  BackgroundGroup:AddChild(ColorUseSame);

  if LayoutConfig.TextureBackgroundUseBarColor == true and LayoutConfig.ButtonBackgroundUseBar == true then
  
    local ButtonBackgroundOpacity = AceGUI:Create("Slider");
    ButtonBackgroundOpacity:SetValue(LayoutConfig.ButtonBackgroundOpacity);
    ButtonBackgroundOpacity:SetLabel("The opacity of the texture");
    ButtonBackgroundOpacity:SetSliderValues(0, 1, 0.01);
    ButtonBackgroundOpacity:SetIsPercent(true);
    ButtonBackgroundOpacity:SetCallback("OnValueChanged", function(_, _, Value)
      LayoutConfig.ButtonBackgroundOpacity = Value;
      ContainerInstance:Update("LAYOUT");
    end);
    BackgroundGroup:AddChild(ButtonBackgroundOpacity);
  
  elseif LayoutConfig.ButtonBackgroundUseBar == false then

    local ColorButtonBackground = AceGUI:Create("ColorPicker");
    ColorButtonBackground:SetHasAlpha(true);
    ColorButtonBackground:SetDisabled(LayoutConfig.ButtonBackgroundUseBar);
    ColorButtonBackground:SetColor(unpack(LayoutConfig.ButtonBackgroundColor));
    ColorButtonBackground:SetLabel("Button Background");
    ColorButtonBackground:SetCallback("OnValueChanged", function(_, _, ...)
      LayoutConfig.ButtonBackgroundColor = {...};
      ContainerInstance:Update("LAYOUT");
    end);
    BackgroundGroup:AddChild(ColorButtonBackground);
    
  end
  
  Content:AddSpace();
  
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
  
  Content:AddHeader("Bar texture");
  
  local BarTexture = AceGUI:Create("LSM30_Statusbar");
  BarTexture:SetList(LSM:HashTable("statusbar"));
  BarTexture:SetLabel("Bar Texture");
  BarTexture:SetValue(LayoutConfig.BarTexture);
  BarTexture:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTexture = Value;
    ContainerInstance:Update("LAYOUT");
    BarTexture:SetValue(Value);
  end);
  Content:AddChild(BarTexture);
  
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
  
  Content:AddHeader("Border and Bar Colors");

  local ContentColors = AceGUI:Create("SimpleGroup");
  ContentColors:SetRelativeWidth(1);
  Content:AddChild(ContentColors);
  AuraFramesConfig:EnhanceContainer(ContentColors);
  
  ColorContent(ContentColors, ContainerId);
  
  Content:AddSpace();
  
  Content:AddHeader("Background Texture and Colors");
  
  local ContentBackground = AceGUI:Create("SimpleGroup");
  ContentBackground:SetRelativeWidth(1);
  Content:AddChild(ContentBackground);
  AuraFramesConfig:EnhanceContainer(ContentBackground);
  
  BackgroundContent(ContentBackground, ContainerId);

end
