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
  
  local BarGroup = AceGUI:Create("SimpleGroup");
  BarGroup:SetRelativeWidth(1);
  AuraFramesConfig:EnhanceContainer(BarGroup);
  BarGroup:SetLayout("Flow");
  Content:AddChild(BarGroup);
  
  local BarTexture = AceGUI:Create("LSM30_Statusbar");
  BarTexture:SetList(LSM:HashTable("statusbar"));
  BarTexture:SetLabel("Bar Texture");
  BarTexture:SetValue(LayoutConfig.BarTexture);
  BarTexture:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTexture = Value;
    ContainerInstance:Update("LAYOUT");
    BarTexture:SetValue(Value);
  end);
  BarGroup:AddChild(BarTexture);
  
  local BarTextureInsets = AceGUI:Create("Slider");
  BarTextureInsets:SetWidth(150);
  BarTextureInsets:SetValue(LayoutConfig.BarTextureInsets);
  BarTextureInsets:SetLabel("Background insets");
  BarTextureInsets:SetSliderValues(0, 16, 1);
  BarTextureInsets:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTextureInsets = Value;
    ContainerInstance:Update("LAYOUT");
    Module:Update(ContainerId);
  end);
  BarGroup:AddChild(BarTextureInsets);
  
  local BarTextureMove = AceGUI:Create("CheckBox");
  BarTextureMove:SetWidth(150);
  BarTextureMove:SetLabel("Bar texture moving");
  BarTextureMove:SetDescription("Is the bar texture moving or standing still.");
  BarTextureMove:SetValue(LayoutConfig.BarTextureMove);
  BarTextureMove:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTextureMove = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  BarGroup:AddChild(BarTextureMove);
  
  local BarTextureRotate = AceGUI:Create("CheckBox");
  BarTextureRotate:SetLabel("Rotate bar texture");
  --BarTextureRotate:SetDescription("");
  BarTextureRotate:SetValue(LayoutConfig.BarTextureRotate);
  BarTextureRotate:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTextureRotate = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  BarGroup:AddChild(BarTextureRotate);
  
  local BarTextureFlipX = AceGUI:Create("CheckBox");
  BarTextureFlipX:SetLabel("Flip horizontal");
  --BarTextureFlipX:SetDescription("");
  BarTextureFlipX:SetWidth(150);
  BarTextureFlipX:SetValue(LayoutConfig.BarTextureFlipX);
  BarTextureFlipX:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTextureFlipX = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  BarGroup:AddChild(BarTextureFlipX);
  
  local BarTextureFlipY = AceGUI:Create("CheckBox");
  BarTextureFlipY:SetLabel("Flip vertical");
  --BarTextureFlipY:SetDescription("");
  BarTextureFlipY:SetWidth(150);
  BarTextureFlipY:SetValue(LayoutConfig.BarTextureFlipY);
  BarTextureFlipY:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarTextureFlipY = Value;
    ContainerInstance:Update("LAYOUT");
  end);
  BarGroup:AddChild(BarTextureFlipY);
  
  BarGroup:AddSpace();
  
  local BarBorder = AceGUI:Create("LSM30_Border");
  BarBorder:SetList(LSM:HashTable("border"));
  BarBorder:SetLabel("Border");
  BarBorder:SetValue(LayoutConfig.BarBorder);
  BarBorder:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarBorder = Value;
    ContainerInstance:Update("LAYOUT");
    BarBorder:SetValue(Value);
  end);
  BarGroup:AddChild(BarBorder);
  
  local BarBorderSize = AceGUI:Create("Slider");
  BarBorderSize:SetWidth(150);
  BarBorderSize:SetValue(LayoutConfig.BarBorderSize);
  BarBorderSize:SetLabel("Border size");
  BarBorderSize:SetSliderValues(2, 24, 1);
  BarBorderSize:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarBorderSize = Value;
    ContainerInstance:Update("LAYOUT");
    Module:Update(ContainerId);
  end);
  BarGroup:AddChild(BarBorderSize);
  
  local BarBorderColorAdjust = AceGUI:Create("Slider");
  BarBorderColorAdjust:SetWidth(150);
  BarBorderColorAdjust:SetIsPercent(true);
  BarBorderColorAdjust:SetValue(LayoutConfig.BarBorderColorAdjust);
  BarBorderColorAdjust:SetLabel("Border dark adjust");
  BarBorderColorAdjust:SetSliderValues(0, 2, 0.01);
  BarBorderColorAdjust:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.BarBorderColorAdjust = Value;
    ContainerInstance:Update("LAYOUT");
    Module:Update(ContainerId);
  end);
  BarGroup:AddChild(BarBorderColorAdjust);
  
  Content:AddSpace();

  Content:AddHeader("Spark");
  
  
  local SparkUseBarColor, SparkColor;
  
  local ShowSpark = AceGUI:Create("CheckBox");
  ShowSpark:SetRelativeWidth(1);
  ShowSpark:SetLabel("Enable Spark");
  ShowSpark:SetDescription("Show a spark at the moving side of the bar.");
  ShowSpark:SetValue(LayoutConfig.ShowSpark);
  ShowSpark:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.ShowSpark = Value;
    ContainerInstance:Update("LAYOUT");
    
    SparkUseBarColor:SetDisabled(not LayoutConfig.ShowSpark);
    SparkColor:SetDisabled(not LayoutConfig.ShowSpark or LayoutConfig.SparkUseBarColor);
    
  end);
  Content:AddChild(ShowSpark);
  
  local SparkGroup = AceGUI:Create("SimpleGroup");
  SparkGroup:SetRelativeWidth(1);
  SparkGroup:SetLayout("Flow");
  Content:AddChild(SparkGroup);
  
  SparkUseBarColor = AceGUI:Create("CheckBox");
  SparkUseBarColor:SetLabel("Use bar color");
  SparkUseBarColor:SetDisabled(not LayoutConfig.ShowSpark);
  SparkUseBarColor:SetDescription("Use the bar color for the spark.");
  SparkUseBarColor:SetValue(LayoutConfig.SparkUseBarColor);
  SparkUseBarColor:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.SparkUseBarColor = Value;
    ContainerInstance:Update("LAYOUT");
    
    SparkColor:SetDisabled(not LayoutConfig.ShowSpark or LayoutConfig.SparkUseBarColor);
    
  end);
  SparkGroup:AddChild(SparkUseBarColor);

  SparkColor = AceGUI:Create("ColorPicker");
  SparkColor:SetHasAlpha(true);
  SparkColor:SetDisabled(not LayoutConfig.ShowSpark or LayoutConfig.SparkUseBarColor);
  SparkColor:SetColor(unpack(LayoutConfig.SparkColor));
  SparkColor:SetLabel("Spark color");
  SparkColor:SetCallback("OnValueChanged", function(_, _, ...)
    LayoutConfig.SparkColor = {...};
    ContainerInstance:Update("LAYOUT");
  end);
  SparkGroup:AddChild(SparkColor);

  
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
