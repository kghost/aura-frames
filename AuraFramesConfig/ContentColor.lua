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
  
  if true then

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
    
    local ExpertMode = AceGUI:Create("CheckBox");
    ExpertMode:SetLabel("Expert mode");
    ExpertMode:SetValue(false);
    ExpertMode:SetCallback("OnValueChanged", function(_, _, Value)

    end);
    OptionGroup:AddChild(ExpertMode);
  
  else
  
    local ExpertGroup = AceGUI:Create("SimpleGroup");
    ExpertGroup:SetLayout("Flow");
    ExpertGroup:SetRelativeWidth(1);
    Content:AddChild(ExpertGroup);
    
    local RuleList = AceGUI:Create("MultiSelect");
    RuleList:SetWidth(350);
    RuleList:SetHeight(200);
    RuleList:SetLabel("Rules");
    RuleList:SetMultiSelect(false);
    RuleList:AddItem("test1");
    RuleList:AddItem("test3");
    RuleList:AddItem("test2");
    ExpertGroup:AddChild(RuleList);
    
    local ExpertOptionGroup = AceGUI:Create("SimpleGroup");
    ExpertOptionGroup:SetLayout("List");
    ExpertOptionGroup:SetWidth(150);
    ExpertOptionGroup:SetHeight(200);
    ExpertGroup:AddChild(ExpertOptionGroup);
    AuraFramesConfig:EnhanceContainer(ExpertOptionGroup);
    ExpertOptionGroup:AddSpace();
    
    local ButtonMoveUp = AceGUI:Create("Button");
    ButtonMoveUp:SetDisabled(true);
    ButtonMoveUp:SetWidth(150);
    ButtonMoveUp:SetText("Move up");
    ExpertOptionGroup:AddChild(ButtonMoveUp);
    
    local ButtonMoveDown = AceGUI:Create("Button");
    ButtonMoveDown:SetDisabled(true);
    ButtonMoveDown:SetWidth(150);
    ButtonMoveDown:SetText("Move down");
    ExpertOptionGroup:AddChild(ButtonMoveDown);
  
    local ButtonDelete = AceGUI:Create("Button");
    ButtonDelete:SetDisabled(true);
    ButtonDelete:SetWidth(150);
    ButtonDelete:SetText("Delete");
    ExpertOptionGroup:AddChild(ButtonDelete);
    
    local ButtonEdit = AceGUI:Create("Button");
    ButtonEdit:SetDisabled(true);
    ButtonEdit:SetWidth(150);
    ButtonEdit:SetText("Edit");
    ExpertOptionGroup:AddChild(ButtonEdit);
    
    local ButtonNew = AceGUI:Create("Button");
    ButtonNew:SetWidth(150);
    ButtonNew:SetText("New");
    ExpertOptionGroup:AddChild(ButtonNew);
    
    ExpertOptionGroup:AddSpace(3);
    
    local DefaultColor = AceGUI:Create("ColorPicker");
    DefaultColor:SetHasAlpha(false);
--    DefaultColor:SetColor(unpack(ColorConfig.Other));
    DefaultColor:SetLabel("Default color");
    ExpertOptionGroup:AddChild(DefaultColor);
    
    RuleList:SetCallback("OnLabelClick", function(_, Value)
    
      local Disabled = #RuleList:GetSelected() == 0;
    
      ButtonMoveUp:SetDisabled(Disabled);
      ButtonMoveDown:SetDisabled(Disabled);
      ButtonDelete:SetDisabled(Disabled);
      ButtonEdit:SetDisabled(Disabled);
    
    end);

    local OptionGroup = AceGUI:Create("SimpleGroup");
    OptionGroup:SetLayout("Flow");
    OptionGroup:SetRelativeWidth(1);
    Content:AddChild(OptionGroup);
    
    local ColorReset = AceGUI:Create("Button");
    ColorReset:SetText("Reset Colors Rules");
    ColorReset:SetCallback("OnClick", function()
      AuraFrames.db.profile.Containers[ContainerId].Colors = AuraFrames:GetModule(ContainerType):GetDatabaseDefaults().Colors;
      ContainerInstance:Update("LAYOUT");
      AuraFramesConfig:ContentColor(Content, ContainerId);
    end);
    OptionGroup:AddChild(ColorReset);
    
    local ExpertMode = AceGUI:Create("CheckBox");
    ExpertMode:SetLabel("Expert mode");
    ExpertMode:SetValue(true);
    ExpertMode:SetCallback("OnValueChanged", function(_, _, Value)

    end);
    OptionGroup:AddChild(ExpertMode);
    
  end
  
  Content:ResumeLayout();
  Content:DoLayout();

end
