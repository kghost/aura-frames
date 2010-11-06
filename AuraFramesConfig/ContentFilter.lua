local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");

local IconEnabled  = "Interface\\RAIDFRAME\\ReadyCheck-Ready";
local IconDisabled = "Interface\\SpellShadow\\Spell-Shadow-Unacceptable";
local IconDelete   = "Interface\\RAIDFRAME\\ReadyCheck-NotReady"

local FilterPredefinedConfig = {
  CastedByMe = {
    Name = "Casted by me",
    Description = "Aura's that you have casted by you.",
    Order = 1,
  },
  NotCastedByMe = {
    Name = "Not casted by me",
    Description = "Aura's that you have been not casted by you.",
    Order = 2,
  },
  CastedBySameClass = {
    Name = "Casted by someone of the same class I am",
    Description = "Aura's that are casted by the class "..format("|cff%02x%02x%02x%s|r", RAID_CLASS_COLORS[select(2, UnitClass("player")) or "NONE"].r * 255, RAID_CLASS_COLORS[select(2, UnitClass("player")) or "NONE"].g * 255, RAID_CLASS_COLORS[select(2, UnitClass("player")) or "NONE"].b * 255, select(1, UnitClass("player"))),
    Order = 3,
  },
  HarmfulOnFriendlyAndHelpfulOnHostile = {
    Name = "Buffs on |cfff36a6ahostile|r and debuffs on |cff6af36afriendly|r targets",
    Order = 4,
  },
};


-----------------------------------------------------------------
-- Local Function ApplyChange
-----------------------------------------------------------------
local function ApplyChange(ContainerId)

  local ContainerInstance = AuraFrames.Containers[ContainerId];

  ContainerInstance.Filter:Build();
  
  if ContainerInstance.Filter.NotifyFunc then
    ContainerInstance.Filter.NotifyFunc();
  end
  

end


-----------------------------------------------------------------
-- Local Function CreateRules
-----------------------------------------------------------------
local function CreateRules(Content, ContentRules, ContainerId, Rules)

  local FilterConfig = AuraFrames.db.profile.Containers[ContainerId].Filter;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  local Subjects = {};
  
  for Subject, Definition in pairs(AuraFrames.AuraDefinition) do
    if Definition.Filter == true then
      Subjects[Subject] = AuraFrames.AuraDefinition[Subject].Name;
    end
  end

  for Index, Rule in ipairs(Rules) do
  
    if Index ~= 1 then
    
      local Label = AceGUI:Create("Label");
      Label:SetFontObject(GameFontNormalSmall);
      Label:SetRelativeWidth(1);
      Label:SetText("And");
      ContentRules:AddChild(Label);
    
    end
  
    local Container = AceGUI:Create("SimpleGroup");
    Container:SetRelativeWidth(1);
    Container:SetLayout("Flow");
    ContentRules:AddChild(Container);

    local Enabled = AceGUI:Create("Icon");
    Enabled:SetImage(((Rule.Disabled == true) and IconDisabled) or IconEnabled);
    Enabled:SetImageSize(24, 24);
    Enabled:SetWidth(26);
    Enabled:SetCallback("OnClick", function()
      if Rule.Disabled then
        Rule.Disabled = nil;
      else
        Rule.Disabled = true;
      end
      Enabled:SetImage(((Rule.Disabled == true) and IconDisabled) or IconEnabled);
      ApplyChange(ContainerId);
    end);
    Container:AddChild(Enabled);
    
    local Subject = AceGUI:Create("Dropdown");
    Subject:SetList(Subjects);
    if Rule.Subject and Subjects[Rule.Subject] then
      Subject:SetValue(Rule.Subject);
    end
    Subject:SetLabel("Subject");
    Subject:SetWidth(150);
    Subject:SetCallback("OnValueChanged", function(_, _, Value)
      Rule.Subject = Value;
      AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
    end);
    Container:AddChild(Subject);
    
    if Rule.Subject and Subjects[Rule.Subject] then
    
      if #AuraFrames.FilterTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type] == 1 then
        Rule.Operator = AuraFrames.FilterTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type][1];
      end
      
      local Operators = {};
    
      for _, Key in pairs(AuraFrames.FilterTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type]) do
        Operators[Key] = AuraFrames.FilterOperatorDescriptions[Key];
      end
    
      local Operator = AceGUI:Create("Dropdown");
      Operator:SetList(Operators);
      if Rule.Operator then
        Operator:SetValue(Rule.Operator);
      end
      Operator:SetLabel("Operator");
      Operator:SetWidth(150);
      Operator:SetCallback("OnValueChanged", function(_, _, Value)
        Rule.Operator = Value;
        
        if not Rule.Args then
          Rule.Args = {};
        end
        
        if (Value == "InList" or Value == "NotInList") and not Rule.Args.List then
          Rule.Args.List = {};
        end
        
        AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
        ApplyChange(ContainerId);
      end);
      Container:AddChild(Operator);
    
    else
    
      local Label = AceGUI:Create("Label");
      Label:SetWidth(150);
      Label:SetText("");
      Container:AddChild(Label);
    
    end
    
    if Rule.Subject and Subjects[Rule.Subject] and Rule.Operator then
      
      if not Rule.Args then
        Rule.Args = {};
      end
      
      local ValueType = AuraFrames.AuraDefinition[Rule.Subject].Type;
      local Operator = Rule.Operator;
      
      if (ValueType == "String" or ValueType == "SpellName") and (Operator == "Equal" or Operator == "NotEqual") then
      
        if AuraFrames.AuraDefinition[Rule.Subject].List then
        
          local Value = AceGUI:Create("Dropdown");
          Value:SetList(AuraFrames.AuraDefinition[Rule.Subject].List);
          if Rule.Args[ValueType] then
            Value:SetValue(Rule.Args[ValueType]);
          end
          Value:SetLabel("Value");
          Value:SetWidth(150);
          Value:SetCallback("OnValueChanged", function(_, _, Value)
            Rule.Args[ValueType] = Value;
            ApplyChange(ContainerId);
          end);
          Container:AddChild(Value);
          
        else

          if ValueType == "SpellName" then

            local Value = AceGUI:Create("Spell_EditBox");
            Value:SetText(Rule.Args[ValueType] or "");
            Value:SetWidth(150);
            Value:SetLabel("Value");
            Value:SetCallback("OnEnterPressed", function(_, _, Text)
              Rule.Args[ValueType] = Text;
              ApplyChange(ContainerId);
            end);
            Value:SetCallback("OnTextChanged", function(_, _, Text)
              Rule.Args[ValueType] = Text;
              ApplyChange(ContainerId);
            end);
            Container:AddChild(Value);

          else
          
            local Value = AceGUI:Create("EditBox");
            Value:DisableButton(true);
            Value:SetText(Rule.Args[ValueType] or "");
            Value:SetLabel("Value");
            Value:SetWidth(150);
            Value:SetCallback("OnTextChanged", function(_, _, Text)
              Rule.Args[ValueType] = Text;
              ApplyChange(ContainerId);
            end);
            Container:AddChild(Value);
          
          end
          
        end
        
      elseif (ValueType == "Number" or ValueType == "SpellId") and (Operator == "Equal" or Operator == "NotEqual" or Operator == "Greater" or Operator == "GreaterOrEqual" or Operator == "Lesser" or Operator == "LesserOrEqual") then
      
        local Value = AceGUI:Create("EditBox");
        Value:DisableButton(true);
        if Rule.Args[ValueType] then
          Value:SetText(tostring(Rule.Args[ValueType]));
        end
        Value:SetLabel("Value");
        Value:SetWidth(150);
        Value:SetCallback("OnTextChanged", function(_, _, Text)
        
          if Text ~= "" and Text ~= tostring(tonumber(Text)) then
            Value:SetText(tostring(Rule.Args[ValueType]));
          else
            Rule.Args[ValueType] = Text;
          end
          
          ApplyChange(ContainerId);
          
        end);
        Container:AddChild(Value);
        
      elseif ValueType == "Boolean" and (Operator == "Equal" or Operator == "NotEqual") then
      
        local Value = AceGUI:Create("Dropdown");
        Value:SetList({["true"] = "True", ["false"] = "False"});
        if Rule.Args[ValueType] then
          Value:SetValue(Rule.Args[ValueType]);
        end
        Value:SetLabel("Value");
        Value:SetWidth(150);
        Value:SetCallback("OnValueChanged", function(_, _, Value)
          Rule.Args[ValueType] = Value;
          ApplyChange(ContainerId);
        end);
        Container:AddChild(Value);
        
      elseif (Operator == "InList" or Operator == "NotInList") then
      
        local Value = AceGUI:Create("Button");
        Value:SetText("Edit list");
        Value:SetWidth(150);
        Value:SetCallback("OnClick", function()
          if not Rule.Args.List then
            Rule.Args.List = {};
          end
          AuraFramesConfig:ShowListEditor(Rule.Args.List, AuraFrames.AuraDefinition[Rule.Subject].List or ValueType, function() AuraFramesConfig:Show(); ApplyChange(ContainerId); end, true, true, false);
          AuraFramesConfig:Close();
        end);
        Container:AddChild(Value);
        
      else
      
        local Label = AceGUI:Create("Label");
        Label:SetWidth(150);
        Label:SetText("");
        Container:AddChild(Label);
      
      end
      
    else
    
      local Label = AceGUI:Create("Label");
      Label:SetWidth(150);
      Label:SetText("");
      Container:AddChild(Label);

    end
    
    local ButtonDelete = AceGUI:Create("Icon");
    ButtonDelete:SetImage(IconDelete);
    ButtonDelete:SetImageSize(24, 24);
    ButtonDelete:SetWidth(26);
    ButtonDelete:SetCallback("OnClick", function()
      table.remove(Rules, Index);
      AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
      ApplyChange(ContainerId);
    end);
    Container:AddChild(ButtonDelete);

  end
end


-----------------------------------------------------------------
-- Function ContentFilterRefresh
-----------------------------------------------------------------
function AuraFramesConfig:ContentFilterRefresh(Content, ContainerId)

  local FilterConfig = AuraFrames.db.profile.Containers[ContainerId].Filter;
  local ContainerInstance = AuraFrames.Containers[ContainerId];
  
  Content:PauseLayout();
  Content:ReleaseChildren();
  
  Content:SetLayout("List");
  
  Content:AddText("Filter\n", GameFontNormalLarge);
  
  if FilterConfig.Expert == true then
  
    Content:AddHeader("Rules");
  
    for Index, Group in ipairs(FilterConfig.Groups or {}) do

      local ContentGroup = AceGUI:Create("InlineGroup");
      ContentGroup:SetRelativeWidth(1);
      if Index ~= 1 then
        ContentGroup:SetTitle("Or");
      else
        ContentGroup:SetTitle("");
      end
      ContentGroup:SetLayout("List")
      Content:AddChild(ContentGroup);
      
      local ContentRules = AceGUI:Create("SimpleGroup");
      ContentRules:SetRelativeWidth(1);
      ContentRules:SetLayout("Flow");
      ContentGroup:AddChild(ContentRules);
      
      CreateRules(Content, ContentRules, ContainerId, Group);
      
      local ContentButtons = AceGUI:Create("SimpleGroup");
      ContentButtons:SetRelativeWidth(1);
      ContentButtons:SetLayout("Flow");
      ContentGroup:AddChild(ContentButtons);
      
      local ButtonNewRule = AceGUI:Create("Button");
      ButtonNewRule:SetText("New Rule");
      ButtonNewRule:SetWidth(150);
      ButtonNewRule:SetCallback("OnClick", function()
        table.insert(Group, {});
        AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
      end);
      ContentButtons:AddChild(ButtonNewRule);
      
      local ButtonDeleteGroup = AceGUI:Create("Button");
      ButtonDeleteGroup:SetText("Delete Group");
      ButtonDeleteGroup:SetWidth(150);
      ButtonDeleteGroup:SetCallback("OnClick", function()
        table.remove(FilterConfig.Groups, Index);
        AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
        ApplyChange(ContainerId);
      end);
      ContentButtons:AddChild(ButtonDeleteGroup);
      
    end
    
    Content:AddSpace();
    
    local ButtonNewGroup = AceGUI:Create("Button");
    ButtonNewGroup:SetText("New Group");
    ButtonNewGroup:SetCallback("OnClick", function()
      if not FilterConfig.Groups then
        FilterConfig.Groups = {};
      end
      table.insert(FilterConfig.Groups, {{}});
      AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
    end);
    Content:AddChild(ButtonNewGroup);
    
    Content:AddSpace();
    
    Content:AddHeader("Expert mode");
    Content:AddText("Expert mode is enabled, when you turn off the expert mode you will lose the custom expert filters!");
    Content:AddSpace();
      
    local CheckBoxExpert = AceGUI:Create("CheckBox");
    CheckBoxExpert:SetValue(true);
    CheckBoxExpert:SetRelativeWidth(1);
    CheckBoxExpert:SetLabel("Expert Mode");
    CheckBoxExpert:SetCallback("OnValueChanged", function(_, _, Value)
      FilterConfig.Expert = false;
      FilterConfig.Groups = {};
      AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
      ApplyChange(ContainerId);
    end);
    Content:AddChild(CheckBoxExpert);
  
  else
  
    Content:AddText("Filters are used for fine tuning what kind of aura's are displayed inside a container.\n\nOnly show aura's that are matching at least one of the following selected criteria, if nothing is selected then there will be no filtering:\n\n");
  
    local List = {};
  
    for Key, Definition in pairs(AuraFrames.FilterPredefined) do

      local CheckBoxPredefined = AceGUI:Create("CheckBox");
      CheckBoxPredefined.Order = FilterPredefinedConfig[Key].Order
      CheckBoxPredefined:SetValue(FilterConfig.Predefined and FilterConfig.Predefined[Key] or false);
      CheckBoxPredefined:SetRelativeWidth(1);
      CheckBoxPredefined:SetLabel(FilterPredefinedConfig[Key].Name);
      CheckBoxPredefined:SetDescription(FilterPredefinedConfig[Key].Description or "");
      CheckBoxPredefined:SetCallback("OnValueChanged", function(_, _, Value)

        if Value == true then
          if not FilterConfig.Predefined then
            FilterConfig.Predefined = {};
          end
          FilterConfig.Predefined[Key] = true;
        else
          if FilterConfig.Predefined then
            FilterConfig.Predefined[Key] = nil;
          end
        end
        ApplyChange(ContainerId);

      end);
      
      table.insert(List, CheckBoxPredefined);
      
    end
    
    sort(List, function(v1, v2) return v1.Order < v2.Order; end);
    
    for _, Control in ipairs(List) do
      Content:AddChild(Control);
    end
    
    Content:AddSpace();
    
    Content:AddHeader("Expert mode");
    Content:AddText("The expert mode allow you to even more customizations then the few default rules above. But the export mode is also quite complex. The above rules will be converted to the complex filter rules, but when you turn off the expert mode you will lose the custom expert filters!\n");
      
    local CheckBoxExpert = AceGUI:Create("CheckBox");
    CheckBoxExpert:SetValue(false);
    CheckBoxExpert:SetRelativeWidth(1);
    CheckBoxExpert:SetLabel("Expert Mode");
    CheckBoxExpert:SetCallback("OnValueChanged", function(_, _, Value)
      FilterConfig.Expert = true;
      FilterConfig.Predefined = nil;
      if not FilterConfig.Groups or #FilterConfig.Groups == 0 then
        FilterConfig.Groups = {{{}}};
      end
      AuraFramesConfig:ContentFilterRefresh(Content, ContainerId);
      ApplyChange(ContainerId);
    end);
    Content:AddChild(CheckBoxExpert);
  
  end
  
  
  Content:ResumeLayout();
  Content:DoLayout();

end

-----------------------------------------------------------------
-- Function ContentFilter
-----------------------------------------------------------------
function AuraFramesConfig:ContentFilter(ContainerId)

  self.Content:SetLayout("Fill");
  
  local Content = AceGUI:Create("ScrollFrame");
  Content:SetLayout("List");
  self:EnhanceContainer(Content);
  self.Content:AddChild(Content);
  
  self:ContentFilterRefresh(Content, ContainerId);

end
