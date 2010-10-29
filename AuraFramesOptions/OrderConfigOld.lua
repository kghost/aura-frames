local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-----------------------------------------------------------------
-- Function ApplyChange
-----------------------------------------------------------------
function AuraFrames.OrderPrototype:ApplyChange()

  self:Build();
  
  if self.NotifyFunc then
    self.NotifyFunc();
  end
  

end

-----------------------------------------------------------------
-- Function BuildConfigDialogEditList
-----------------------------------------------------------------
function AuraFrames.OrderPrototype:BuildConfigDialogEditList()

  local Options = {};
  
  local Rule = self.EditListRule;
  
  if not Rule.Args.List then
    Rule.Args.List = {};
  end
  
  for Id, _ in pairs(AuraFrames.AuraDefinition[Rule.Subject].List) do
  
    if not tContains(Rule.Args.List, Id) then
      tinsert(Rule.Args.List, Id);
    end
  
  end
  
  for i = #Rule.Args.List, 1, -1 do

    if not AuraFrames.AuraDefinition[Rule.Subject].List[Rule.Args.List[i]] then
      tremove(Rule.Args.List, i);
    end

  end
  
  local ValueOrder = 1;
  
  for Id, ListId in ipairs(Rule.Args.List) do
  
    if Id ~= 1 then
      Options["Sep"..Id] = {
        type = "description",
        name = " ",
        order = ValueOrder,
      };
      ValueOrder = ValueOrder + 1;
    end
  
    Options["Value"..Id] = {
      type = "input",
      name = "",
      get = function(Info) return AuraFrames.AuraDefinition[Rule.Subject].List[ListId]; end,
      set = function() end,
      order = ValueOrder,
      dialogControl = "TextLabel",
      width = "double",
    };
    ValueOrder = ValueOrder + 1;
  
    if Id ~= 1 then

      Options["ValueUp"..Id] = {
        type = "execute",
        name = "",
        func = function(Info)
          local Temp = Rule.Args.List[Id - 1];
          Rule.Args.List[Id - 1] = Rule.Args.List[Id];
          Rule.Args.List[Id] = Temp;
          self:ApplyChange();
          AuraFrames:RefreshConfigDialog();
        end,
        image = "Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageUp-Up",
        imageWidth = 32,
        imageHeight = 32,
        width = "half",
        order = ValueOrder,
      };
      ValueOrder = ValueOrder + 1;

    end
    
    if Id ~= #Rule.Args.List then

      Options["ValueDown"..Id] = {
        type = "execute",
        name = "",
        func = function(Info)
          local Temp = Rule.Args.List[Id + 1];
          Rule.Args.List[Id + 1] = Rule.Args.List[Id];
          Rule.Args.List[Id] = Temp;
          self:ApplyChange();
          AuraFrames:RefreshConfigDialog();
        end,
        image = "Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageDown-Up",
        imageWidth = 32,
        imageHeight = 32,
        width = "half",
        order = ValueOrder,
      };
      ValueOrder = ValueOrder + 1;
    
    end
  
  end

  Options["LastSep"] = {
    type = "description",
    name = " ",
    order = ValueOrder,
  };
  ValueOrder = ValueOrder + 1;

  
  local Order = self;
  
  Options["Done"] = {
    type = "execute",
    name = "Done",
    func = function(Info)
      Order.EditListRule = nil;
      AuraFrames:RefreshConfigDialog();
    end,
    order = ValueOrder,
  };
  ValueOrder = ValueOrder + 1;
  
  return Options;

end

-----------------------------------------------------------------
-- Function BuildConfigOptions
-----------------------------------------------------------------
function AuraFrames.OrderPrototype:BuildConfigOptions()

  return {
    Description = {
      type = "description",
      name = "Ordering is used for sorting the aura's",
      order = 1,
    },
    OrderEditor = {
      type = "execute",
      name = "Open order editor",
      func = function()
        LibStub("AceConfigDialog-3.0"):Close("AuraFrames");
        -- AceConfigDialog is forgetting to close the game tooltip :(
        GameTooltip:Hide();
        self:ShowEditor();
      end,
      order = 2,
    },
  };

end


-----------------------------------------------------------------
-- Function BuildConfigOptionsOld
-----------------------------------------------------------------
function AuraFrames.OrderPrototype:BuildConfigOptionsOld()

  if self.EditListRule then
    return self:BuildConfigDialogEditList();
  end

  local Subjects = {};
  
  for Subject, Definition in pairs(AuraFrames.AuraDefinition) do
    if Definition.Sort == true then
      Subjects[Subject] = AuraFrames.AuraDefinition[Subject].Name;
    end
  end
  
  local Options = {};
  
  local RuleOrder = 1;
  
  for RuleId, Rule in ipairs(self.Config) do
  
    if RuleOrder ~= 1 then
      Options["Sep"..RuleId] = {
        type = "description",
        name = " ",
        order = RuleOrder,
      };
      RuleOrder = RuleOrder + 1;
    end
    
    Options["RuleDisabled"..RuleId] = {
      type = "execute",
      name = "",
      func = function(Info)
        if Rule.Disabled and Rule.Disabled == true then
          Rule.Disabled = nil;
        else
          Rule.Disabled = true;
        end
        self:ApplyChange();
        AuraFrames:RefreshConfigDialog();
      end,
      image = ((Rule.Disabled == true) and "Interface\\SpellShadow\\Spell-Shadow-Unacceptable") or "Interface\\RAIDFRAME\\ReadyCheck-Ready",
      imageWidth = 32,
      imageHeight = 32,
      width = "half",
      order = RuleOrder,
    };
    RuleOrder = RuleOrder + 1;

    Options["RuleSubject"..RuleId] = {
      type = "select",
      name = "Subject",
      get = function(Info) return Rule.Subject or nil; end,
      set = function(Info, Value) Rule.Subject = Value; self:ApplyChange(); AuraFrames:RefreshConfigDialog(); end,
      values = Subjects,
      order = RuleOrder,
    };
    RuleOrder = RuleOrder + 1;
    
    if Rule.Subject then
    
      if #AuraFrames.OrderTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type] == 1 then
        Rule.Operator = AuraFrames.OrderTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type][1];
      end
      
      local Values = {};
    
      for _, Key in pairs(AuraFrames.OrderTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type]) do
        Values[Key] = AuraFrames.OrderOperatorDescriptions[Key];
      end
      
      if AuraFrames.AuraDefinition[Rule.Subject].List then
        for _, Key in pairs(AuraFrames.OrderTypeOperators["List"]) do
          Values[Key] = AuraFrames.OrderOperatorDescriptions[Key];
        end
      end
      
      Options["RuleOperator"..RuleId] = {
        type = "select",
        name = "Sort",
        get = function(Info) return Rule.Operator or nil; end,
        set = function(Info, Value) Rule.Operator = Value; self:ApplyChange(); AuraFrames:RefreshConfigDialog(); end,
        values = Values,
        order = RuleOrder,
      };
      RuleOrder = RuleOrder + 1;
      
    else
    
      Options["RuleOperator"..RuleId] = {
        type = "input",
        name = "",
        get = function(Info) return ""; end,
        set = function() end,
        order = RuleOrder,
        dialogControl = "TextLabel",
      };
      RuleOrder = RuleOrder + 1;
    
    end
    
    if Rule.Operator then
      
      if not Rule.Args then
        Rule.Args = {};
      end

      local ValueType = AuraFrames.AuraDefinition[Rule.Subject].Type;
      local Operator = Rule.Operator;
      
      if ValueType == "String" and (Operator == "First" or Operator == "Last") then
      
        if AuraFrames.AuraDefinition[Rule.Subject].List then
      
          Options["RuleValue"..RuleId] = {
            type = "select",
            name = "Value",
            get = function(Info) return Rule.Args.String; end,
            set = function(Info, Value) Rule.Args.String = Value; self:ApplyChange(); end,
            values = AuraFrames.AuraDefinition[Rule.Subject].List,
            order = RuleOrder,
          };
          RuleOrder = RuleOrder + 1;
      
        else

          Options["RuleValue"..RuleId] = {
            type = "input",
            name = "Value",
            get = function(Info) return Rule.Args.String; end,
            set = function(Info, Value) Rule.Args.String = Value; self:ApplyChange(); end,
            order = RuleOrder,
          };
          RuleOrder = RuleOrder + 1;
          
        end
      
      elseif ValueType == "Number" and (Operator == "First" or Operator == "Last") then
      
        Options["RuleValue"..RuleId] = {
          type = "input",
          name = "Value",
          get = function(Info) return Rule.Args.Number and tostring(Rule.Args.Number); end,
          set = function(Info, Value) Rule.Args.Number = tonumber(Value); self:ApplyChange(); end,
          order = RuleOrder,
          pattern = "^%d+.?%d*$",
          usage = "Only a number is allowed",
        };
        RuleOrder = RuleOrder + 1;
      
      elseif ValueType == "Boolean" and (Operator == "First" or Operator == "Last") then
      
        Options["RuleValue"..RuleId] = {
          type = "select",
          name = "Value",
          get = function(Info) return Rule.Args.Boolean or nil; end,
          set = function(Info, Value) Rule.Args.Boolean = Value; self:ApplyChange(); end,
          values = {
            ["true"] = "True",
            ["false"] = "False",
          },
          order = RuleOrder,
        };
        RuleOrder = RuleOrder + 1;
      
      elseif Operator == "ListAsc" or Operator == "ListDesc" then
        
        local Order = self;
        
        Options["RuleValue"..RuleId] = {
          type = "execute",
          name = "Edit list",
          func = function(Info)
            Order.EditListRule = Rule;
            AuraFrames:RefreshConfigDialog();
          end,
          order = RuleOrder,
        };
        RuleOrder = RuleOrder + 1;
        
      else
      
        Options["RuleValue"..RuleId] = {
          type = "input",
          name = "",
          get = function(Info) return ""; end,
          set = function() end,
          order = RuleOrder,
          dialogControl = "TextLabel",
        };
        RuleOrder = RuleOrder + 1;
      
      end
    
    else
    
      Options["RuleValue"..RuleId] = {
        type = "input",
        name = "",
        get = function(Info) return ""; end,
        set = function() end,
        order = RuleOrder,
        dialogControl = "TextLabel",
      };
      RuleOrder = RuleOrder + 1;
      
    end
    
    Options["RuleDelete"..RuleId] = {
      type = "execute",
      name = "",
      func = function(Info)
        table.remove(self.Config, RuleId);
        self:ApplyChange();
        AuraFrames:RefreshConfigDialog();
      end,
      image = "Interface\\RAIDFRAME\\ReadyCheck-NotReady",
      imageWidth = 32,
      imageHeight = 32,
      width = "half",
      order = RuleOrder,
    };
    RuleOrder = RuleOrder + 1;
    
    if RuleId ~= 1 then

      Options["RuleUp"..RuleId] = {
        type = "execute",
        name = "",
        func = function(Info)
          table.insert(self.Config, RuleId - 1, table.remove(self.Config, RuleId));
          self:ApplyChange();
          AuraFrames:RefreshConfigDialog();
        end,
        image = "Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageUp-Up",
        imageWidth = 32,
        imageHeight = 32,
        width = "half",
        order = RuleOrder,
      };
      RuleOrder = RuleOrder + 1;

    end
    
    if RuleId ~= #self.Config then

      Options["RuleDown"..RuleId] = {
        type = "execute",
        name = "",
        func = function(Info)
          table.insert(self.Config, RuleId, table.remove(self.Config, RuleId + 1));
          self:ApplyChange();
          AuraFrames:RefreshConfigDialog();
        end,
        image = "Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageDown-Up",
        imageWidth = 32,
        imageHeight = 32,
        width = "half",
        order = RuleOrder,
      };
      RuleOrder = RuleOrder + 1;
    
    end

  end

  Options.LastSep = {
    type = "description",
    name = " ",
    order = RuleOrder,
  };
  RuleOrder = RuleOrder + 1;


  Options.AddRule = {
    type = "execute",
    name = "Add rule",
    order = RuleOrder;
    func = function(Info)
      table.insert(self.Config, {{}});
      self:ApplyChange();
      AuraFrames:RefreshConfigDialog();
    end,
  };
  RuleOrder = RuleOrder + 1;
  
  return Options;
  

end
