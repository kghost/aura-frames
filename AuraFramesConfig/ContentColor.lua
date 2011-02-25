local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");

-----------------------------------------------------------------
-- Function ColorContent
-----------------------------------------------------------------
function AuraFramesConfig:ContentColor(Content, ContainerId)

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
  
  local OptionGroup = AceGUI:Create("SimpleGroup");
  OptionGroup:SetLayout("Flow");
  OptionGroup:SetRelativeWidth(1);
  Content:AddChild(OptionGroup);
  
  local ColorReset = AceGUI:Create("Button");
  ColorReset:SetText("Reset Border Colors");
  ColorReset:SetCallback("OnClick", function()
    AuraFrames.db.profile.Containers[ContainerId].Colors = AuraFrames:GetModule(ContainerType):GetDatabaseDefaults().Colors;
    ContainerInstance:Update("LAYOUT");
    AuraFramesConfig:ContentColor(Content, ContainerId);
  end);
  OptionGroup:AddChild(ColorReset);
  
  
  --[[
  local ExpertMode = AceGUI:Create("CheckBox");
  ExpertMode:SetLabel("Expert mode");
  ExpertMode:SetValue(LayoutConfig.Clickable);
  ExpertMode:SetCallback("OnValueChanged", function(_, _, Value)
    LayoutConfig.Clickable = Value;
    ContainerInstance:Update("LAYOUT");
    Module:ContentLayoutGeneral(Content, ContainerId);
  end);
  OptionGroup:AddChild(ExpertMode);
  ]]--
  
  
  Content:ResumeLayout();
  Content:DoLayout();

end
