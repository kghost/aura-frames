local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");

local IconEnabled  = "Interface\\RAIDFRAME\\ReadyCheck-Ready";
local IconDisabled = "Interface\\SpellShadow\\Spell-Shadow-Unacceptable";
local IconDelete   = "Interface\\RAIDFRAME\\ReadyCheck-NotReady";

local CurrentFilter = nil;
local FilterWindow = nil;
local FilterContainer = nil;

-----------------------------------------------------------------
-- Local Function CreateRules
-----------------------------------------------------------------
local function CreateRules(Filter, Parent, Rules)

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
      Parent:AddChild(Label);
    
    end
  
    local Container = AceGUI:Create("SimpleGroup");
    Container:SetRelativeWidth(1);
    Container:SetLayout("Flow");
    Parent:AddChild(Container);

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
      Filter:ApplyChange();
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
      Filter:RefreshEditor();
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
        
        Filter:RefreshEditor();
        Filter:ApplyChange();
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
            Filter:ApplyChange();
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
              Filter:ApplyChange();
            end);
            Value:SetCallback("OnTextChanged", function(_, _, Text)
              Rule.Args[ValueType] = Text;
              Filter:ApplyChange();
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
              Filter:ApplyChange();
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
          
          Filter:ApplyChange();
          
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
          Filter:ApplyChange();
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
          FilterWindow:Hide();
          AuraFrames:ShowListEditor(Rule.Args.List, AuraFrames.AuraDefinition[Rule.Subject].List or ValueType, function() FilterWindow:Show(); Filter:ApplyChange(); end, true, true, false);
          
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
      Filter:RefreshEditor();
      Filter:ApplyChange();
    end);
    Container:AddChild(ButtonDelete);

  end
end


-----------------------------------------------------------------
-- Local Function CreateGroups
-----------------------------------------------------------------
local function CreateGroups(Filter)

  for Index, Group in ipairs(Filter.Config.Groups or {}) do

    local Container = AceGUI:Create("InlineGroup");
    Container:SetRelativeWidth(1);
    if Index ~= 1 then
      Container:SetTitle("Or");
    else
      Container:SetTitle("");
    end
    Container:SetLayout("List")
    FilterContainer:AddChild(Container);
    
    local ContainerRules = AceGUI:Create("SimpleGroup");
    ContainerRules:SetRelativeWidth(1);
    ContainerRules:SetLayout("Flow");
    Container:AddChild(ContainerRules);
    
    CreateRules(Filter, ContainerRules, Group);
    
    local ContainerButtons = AceGUI:Create("SimpleGroup");
    ContainerButtons:SetRelativeWidth(1);
    ContainerButtons:SetLayout("Flow");
    Container:AddChild(ContainerButtons);
    
    local ButtonNewRule = AceGUI:Create("Button");
    ButtonNewRule:SetText("New Rule");
    ButtonNewRule:SetWidth(150);
    ButtonNewRule:SetCallback("OnClick", function()
      table.insert(Group, {});
      Filter:RefreshEditor();
    end);
    ContainerButtons:AddChild(ButtonNewRule);
    
    local ButtonDeleteGroup = AceGUI:Create("Button");
    ButtonDeleteGroup:SetText("Delete Group");
    ButtonDeleteGroup:SetWidth(150);
    ButtonDeleteGroup:SetCallback("OnClick", function()
      table.remove(Filter.Config.Groups, Index);
      Filter:RefreshEditor();
      Filter:ApplyChange();
    end);
    ContainerButtons:AddChild(ButtonDeleteGroup);
    
  end

end

-----------------------------------------------------------------
-- Local Function CreateFilterWindow
-----------------------------------------------------------------
local function CreateFilterWindow()

  FilterWindow = AceGUI:Create("Window");
  FilterWindow:Hide();
  FilterWindow:SetTitle("Aura Frames - Filter Editor");
  FilterWindow:SetWidth(600);
  FilterWindow:SetHeight(500);
  FilterWindow:EnableResize(false);
  FilterWindow:SetCallback("OnClose", function()
    --LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
  end);
  FilterWindow:SetLayout("Flow");
  
  FilterContainer = AceGUI:Create("ScrollFrame");
  FilterContainer:SetRelativeWidth(1);
  FilterContainer:SetAutoAdjustHeight(false);
  FilterContainer:SetHeight(420);
  FilterWindow:AddChild(FilterContainer);
  
  local ButtonNewGroup = AceGUI:Create("Button");
  ButtonNewGroup:SetText("New Group");
  ButtonNewGroup:SetWidth(200);
  ButtonNewGroup:SetCallback("OnClick", function()
    if not CurrentFilter.Config.Groups then
      CurrentFilter.Config.Groups = {};
    end
    table.insert(CurrentFilter.Config.Groups, {{}});
    CurrentFilter:RefreshEditor();
  end);
  FilterWindow:AddChild(ButtonNewGroup);
  
  local ButtonDone = AceGUI:Create("Button");
  ButtonDone:SetText("Close Filter Editor");
  ButtonDone:SetWidth(200);
  ButtonDone:SetCallback("OnClick", function()
    FilterWindow:Hide();
    LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
  end);
  FilterWindow:AddChild(ButtonDone);

end


-----------------------------------------------------------------
-- Function FilterEditorRefreshOptions
-----------------------------------------------------------------
function AuraFrames.FilterPrototype:RefreshEditor()

  FilterContainer:PauseLayout();
  FilterContainer:ReleaseChildren();

  CreateGroups(self);

  FilterContainer:ResumeLayout();
  FilterContainer:DoLayout();

end


-----------------------------------------------------------------
-- Function ShowEditor
-----------------------------------------------------------------
function AuraFrames.FilterPrototype:ShowEditor()
  
  CurrentFilter = self;
  
  if ListWindow then
    ListWindow:Hide();
  end

  if not FilterWindow then
    CreateFilterWindow();
  end
  
  self:RefreshEditor();
  
  FilterWindow:Show();

end

