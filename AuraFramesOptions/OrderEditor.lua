local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");

local IconEnabled  = "Interface\\RAIDFRAME\\ReadyCheck-Ready";
local IconDisabled = "Interface\\SpellShadow\\Spell-Shadow-Unacceptable";
local IconDelete   = "Interface\\RAIDFRAME\\ReadyCheck-NotReady";
local IconUp       = "Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageUp-Up";
local IconDown     = "Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageDown-Up";

local CurrentOrder = nil;
local OrderWindow = nil;
local OrderContainer = nil;

-----------------------------------------------------------------
-- Local Function CreateRules
-----------------------------------------------------------------
local function CreateRules(Order)

  local Rules = Order.Config.Rules or {};

  local Subjects = {};
  
  for Subject, Definition in pairs(AuraFrames.AuraDefinition) do
    if Definition.Order == true then
      Subjects[Subject] = AuraFrames.AuraDefinition[Subject].Name;
    end
  end

  for Index, Rule in ipairs(Rules) do
  
    local Container = AceGUI:Create("SimpleGroup");
    Container:SetRelativeWidth(1);
    Container:SetLayout("Flow");
    OrderContainer:AddChild(Container);

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
      Order:ApplyChange();
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
      Order:RefreshEditor();
    end);
    Container:AddChild(Subject);
    
    if Rule.Subject and Subjects[Rule.Subject] then
    
      if #AuraFrames.OrderTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type] == 1 then
        Rule.Operator = AuraFrames.OrderTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type][1];
      end
      
      local Operators = {};
    
      for _, Key in pairs(AuraFrames.OrderTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type]) do
        Operators[Key] = AuraFrames.OrderOperatorDescriptions[Key];
      end
      
      if AuraFrames.AuraDefinition[Rule.Subject].List then
        for _, Key in pairs(AuraFrames.OrderTypeOperators["List"]) do
          Operators[Key] = AuraFrames.OrderOperatorDescriptions[Key];
        end
      end
    
      local Operator = AceGUI:Create("Dropdown");
      Operator:SetList(Operators);
      if Rule.Operator then
        Operator:SetValue(Rule.Operator);
      end
      Operator:SetLabel("Sort");
      Operator:SetWidth(150);
      Operator:SetCallback("OnValueChanged", function(_, _, Value)
        Rule.Operator = Value;
        
        if not Rule.Args then
          Rule.Args = {};
        end
        
        if (Value == "ListAsc" or Value == "ListDesc") and not Rule.Args.List then
          Rule.Args.List = {};
        end
        
        Order:RefreshEditor();
        Order:ApplyChange();
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
      
      if (ValueType == "String" or ValueType == "SpellName") and (Operator == "First" or Operator == "Last") then
      
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
            Order:ApplyChange();
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
              Order:ApplyChange();
            end);
            Value:SetCallback("OnTextChanged", function(_, _, Text)
              Rule.Args[ValueType] = Text;
              Order:ApplyChange();
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
        
      elseif (ValueType == "Number" or ValueType == "SpellId") and (Operator == "First" or Operator == "Last") then
      
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
          
          Order:ApplyChange();
          
        end);
        Container:AddChild(Value);
        
      elseif ValueType == "Boolean" and (Operator == "First" or Operator == "Last") then
      
        local Value = AceGUI:Create("Dropdown");
        Value:SetList({["true"] = "True", ["false"] = "False"});
        if Rule.Args[ValueType] then
          Value:SetValue(Rule.Args[ValueType]);
        end
        Value:SetLabel("Value");
        Value:SetWidth(150);
        Value:SetCallback("OnValueChanged", function(_, _, Value)
          Rule.Args[ValueType] = Value;
          Order:ApplyChange();
        end);
        Container:AddChild(Value);
        
      elseif (Operator == "ListAsc" or Operator == "ListDesc") then
      
        local Value = AceGUI:Create("Button");
        Value:SetText("Edit list");
        Value:SetWidth(150);
        Value:SetCallback("OnClick", function()
          if not Rule.Args.List then
            Rule.Args.List = {};
          end
          AuraFrames:ShowListEditor(Rule.Args.List, AuraFrames.AuraDefinition[Rule.Subject].List or "None", function() OrderWindow:Show(); Order:ApplyChange(); end, false, false, true);
          OrderWindow:Hide();
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
    ButtonDelete:SetDisabled(false);
    ButtonDelete:SetImage(IconDelete);
    ButtonDelete:SetImageSize(24, 24);
    ButtonDelete:SetWidth(26);
    ButtonDelete:SetCallback("OnClick", function()
      table.remove(Rules, Index);
      Order:RefreshEditor();
      Order:ApplyChange();
    end);
    Container:AddChild(ButtonDelete);
    
    local ButtonUp = AceGUI:Create("Icon");
    ButtonUp:SetDisabled(Index == 1);
    ButtonUp:SetImage(IconUp);
    ButtonUp:SetImageSize(24, 24);
    ButtonUp:SetWidth(26);
    ButtonUp:SetCallback("OnClick", function()
      table.insert(Rules, Index - 1, table.remove(Rules, Index));
      Order:RefreshEditor();
      Order:ApplyChange();
    end);
    Container:AddChild(ButtonUp);
    
    local ButtonDown = AceGUI:Create("Icon");
    ButtonDown:SetDisabled(Index == #Rules);
    ButtonDown:SetImage(IconDown);
    ButtonDown:SetImageSize(24, 24);
    ButtonDown:SetWidth(26);
    ButtonDown:SetCallback("OnClick", function()
      table.insert(Rules, Index, table.remove(Rules, Index + 1));
      Order:RefreshEditor();
      Order:ApplyChange();
    end);
    Container:AddChild(ButtonDown);

  end
end


-----------------------------------------------------------------
-- Local Function CreateOrderWindow
-----------------------------------------------------------------
local function CreateOrderWindow()

  OrderWindow = AceGUI:Create("Window");
  OrderWindow:Hide();
  OrderWindow:SetTitle("Aura Frames - Order Editor");
  OrderWindow:SetWidth(620);
  OrderWindow:SetHeight(500);
  OrderWindow:EnableResize(false);
  OrderWindow:SetCallback("OnClose", function()
    if AuraFrames:IsListEditorShown() ~= 1 then
      LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
    end
  end);
  OrderWindow:SetLayout("Flow");
  
  OrderContainer = AceGUI:Create("ScrollFrame");
  OrderContainer:SetRelativeWidth(1);
  OrderContainer:SetAutoAdjustHeight(false);
  OrderContainer:SetHeight(420);
  OrderWindow:AddChild(OrderContainer);
  
  local ButtonNewRule = AceGUI:Create("Button");
  ButtonNewRule:SetText("New Rule");
  ButtonNewRule:SetWidth(200);
  ButtonNewRule:SetCallback("OnClick", function()
    if not CurrentOrder.Config.Rules then
      CurrentOrder.Config.Rules = {};
    end
    table.insert(CurrentOrder.Config.Rules, {{}});
    CurrentOrder:RefreshEditor();
  end);
  OrderWindow:AddChild(ButtonNewRule);
  
  local ButtonDone = AceGUI:Create("Button");
  ButtonDone:SetText("Close Order Editor");
  ButtonDone:SetWidth(200);
  ButtonDone:SetCallback("OnClick", function()
    OrderWindow:Hide();
  end);
  OrderWindow:AddChild(ButtonDone);

end


-----------------------------------------------------------------
-- Function OrderEditorRefreshOptions
-----------------------------------------------------------------
function AuraFrames.OrderPrototype:RefreshEditor()

  OrderContainer:PauseLayout();
  OrderContainer:ReleaseChildren();

  CreateRules(self);

  OrderContainer:ResumeLayout();
  OrderContainer:DoLayout();

end


-----------------------------------------------------------------
-- Function ShowEditor
-----------------------------------------------------------------
function AuraFrames.OrderPrototype:ShowEditor()
  
  CurrentOrder = self;
  
  if ListWindow then
    ListWindow:Hide();
  end

  if not OrderWindow then
    CreateOrderWindow();
  end
  
  self:RefreshEditor();
  
  OrderWindow:Show();

end

