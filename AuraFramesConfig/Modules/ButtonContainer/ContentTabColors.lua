local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local Module = AuraFramesConfig:GetModule("ButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentTabColors
-----------------------------------------------------------------
function Module:ContentTabColors(Content, ContainerId)

  -- We are calling our self for a refresh.
  Content:ReleaseChildren();

  local ColorConfig = AuraFrames.db.profile.Containers[ContainerId].Colors;
  local ContainerInstance = AuraFrames.Containers[ContainerId];
  local ContainerType = AuraFrames.db.profile.Containers[ContainerId].Type;

  Content:SetLayout("List");

  Content:AddText("Colors\n", GameFontNormalLarge);
  
  Content:AddHeader("Border");
  
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
    Container:Update("LAYOUT");
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
  ColorReset:SetText("Reset Colors");
  ColorReset:SetCallback("OnClick", function()
    AuraFrames.db.profile.Containers[ContainerId].Colors = AuraFrames:GetModule(ContainerType):GetConfigDefaults().Colors;
    ContainerInstance:Update("LAYOUT");
    Module:ContentTabColors(Content, ContainerId);
  end);
  Content:AddChild(ColorReset);

end
