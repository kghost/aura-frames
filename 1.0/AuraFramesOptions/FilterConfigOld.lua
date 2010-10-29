local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-----------------------------------------------------------------
-- Function ApplyChange
-----------------------------------------------------------------
function AuraFrames.FilterPrototype:ApplyChange()

  self:Build();
  
  if self.NotifyFunc then
    self.NotifyFunc();
  end
  

end


-----------------------------------------------------------------
-- Function BuildConfigDialogEditList
-----------------------------------------------------------------
function AuraFrames.FilterPrototype:BuildConfigDialogEditList()

  local Filter = self;

  local Options = {};
  
  local Rule = self.EditListRule;
  
  if not Rule.Args.List then
    Rule.Args.List = {};
  end
  
  -- Sort the list before displaying it.
  sort(Rule.Args.List);
  
  local ValueOrder = 1;
  
  if AuraFrames.AuraDefinition[Rule.Subject].List then

    Options["Input"] = {
      type = "select",
      name = "Value",
      get = function(Info) return Filter.EditListInput; end,
      set = function(Info, Value) Filter.EditListInput = Value; end,
      values = AuraFrames.AuraDefinition[Rule.Subject].List,
      order = ValueOrder,
    };
    ValueOrder = ValueOrder + 1;

  else
  
    Options["Input"] = {
      type = "input",
      name = "Value",
      get = function(Info) return Filter.EditListInput; end,
      set = function(Info, Value) Filter.EditListInput = Value; end,
      order = ValueOrder,
    };
    ValueOrder = ValueOrder + 1;
    
  end
  
  Options["Add"] = {
    type = "execute",
    name = "Add",
    func = function(Info)
      if Filter.EditListInput and Filter.EditListInput ~= "" then
        tinsert(Rule.Args.List, Filter.EditListInput);
      end
      Filter.EditListInput = "";
      self:ApplyChange();
      AuraFrames:RefreshConfigDialog();
    end,
    order = ValueOrder,
  };
  ValueOrder = ValueOrder + 1;
  
  Options["FirstSep"] = {
    type = "description",
    name = " ",
    order = ValueOrder,
  };
  ValueOrder = ValueOrder + 1;
  
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
      get = function(Info) return ListId; end,
      set = function() end,
      order = ValueOrder,
      dialogControl = "TextLabel",
      width = "double",
    };
    ValueOrder = ValueOrder + 1;
  

    Options["ValueDelete"..Id] = {
      type = "execute",
      name = "",
      func = function(Info)
        tremove(Rule.Args.List, Id);
        self:ApplyChange();
        AuraFrames:RefreshConfigDialog();
      end,
      image = "Interface\\RAIDFRAME\\ReadyCheck-NotReady",
      imageWidth = 32,
      imageHeight = 32,
      width = "half",
      order = ValueOrder,
    };
    ValueOrder = ValueOrder + 1;
  
  end

  Options["LastSep"] = {
    type = "description",
    name = " ",
    order = ValueOrder,
  };
  ValueOrder = ValueOrder + 1;

  Options["Done"] = {
    type = "execute",
    name = "Done",
    func = function(Info)
      Filter.EditListRule = nil;
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
function AuraFrames.FilterPrototype:BuildConfigOptions()

  return {
    Description = {
      type = "description",
      name = "Filters are used for fine tuning the amount and what kind of aura's are displayed inside a container. The filters consists of a set of group of rules that can filter on almost anything.",
      order = 1,
    },
    FilterEditor = {
      type = "execute",
      name = "Open filter editor",
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
function AuraFrames.FilterPrototype:BuildConfigOptionsOld()

  if self.EditListRule then
    return self:BuildConfigDialogEditList();
  end

  local Subjects = {};
  
  for Subject, Definition in pairs(AuraFrames.AuraDefinition) do
    if Definition.Filter == true then
      Subjects[Subject] = AuraFrames.AuraDefinition[Subject].Name;
    end
  end
  
  local Options = {};
  
  local GroupOrder = 1;
  
  for GroupId, Group in ipairs(self.Config.Groups) do
  
    if GroupOrder ~= 1 then
      Options["Or"..GroupId] = {
        type = "description",
        name = "Or",
        order = GroupOrder,
      };
      GroupOrder = GroupOrder + 1;
    end

    Options["Group"..GroupId] = {
      type = "group",
      inline = true,
      name = " ",
      args = {},
      order = GroupOrder,
    };
    GroupOrder = GroupOrder + 1;
    
    local RuleOrder = 1;
    
    for RuleId, Rule in ipairs(Group) do
    
      if RuleOrder ~= 1 then
        Options["Group"..GroupId].args["And"..RuleId] = {
          type = "description",
          name = "And",
          order = RuleOrder,
        };
        RuleOrder = RuleOrder + 1;
      end
      
      Options["Group"..GroupId].args["RuleDisabled"..RuleId] = {
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

      Options["Group"..GroupId].args["RuleSubject"..RuleId] = {
        type = "select",
        name = "Subject",
        get = function(Info) return Rule.Subject or nil; end,
        set = function(Info, Value) Rule.Subject = Value; self:ApplyChange(); AuraFrames:RefreshConfigDialog(); end,
        values = Subjects,
        order = RuleOrder,
      };
      RuleOrder = RuleOrder + 1;
      
      if Rule.Subject then
      
        if #AuraFrames.FilterTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type] == 1 then
          Rule.Operator = AuraFrames.FilterTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type][1];
        end
        
        local Values = {};
      
        for _, Key in pairs(AuraFrames.FilterTypeOperators[AuraFrames.AuraDefinition[Rule.Subject].Type]) do
          Values[Key] = AuraFrames.FilterOperatorDescriptions[Key];
        end
        
        Options["Group"..GroupId].args["RuleOperator"..RuleId] = {
          type = "select",
          name = "Operator",
          get = function(Info) return Rule.Operator or nil; end,
          set = function(Info, Value) Rule.Operator = Value; self:ApplyChange(); AuraFrames:RefreshConfigDialog(); end,
          values = Values,
          order = RuleOrder,
        };
        RuleOrder = RuleOrder + 1;
      
      else
      
        Options["Group"..GroupId].args["RuleOperator"..RuleId] = {
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
        
        if (ValueType == "String" or ValueType == "SpellName") and (Operator == "Equal" or Operator == "NotEqual") then
        
          if AuraFrames.AuraDefinition[Rule.Subject].List then
        
            Options["Group"..GroupId].args["RuleValue"..RuleId] = {
              type = "select",
              name = "Value",
              get = function(Info) return Rule.Args[ValueType]; end,
              set = function(Info, Value) Rule.Args[ValueType] = Value; self:ApplyChange(); end,
              values = AuraFrames.AuraDefinition[Rule.Subject].List,
              order = RuleOrder,
            };
            RuleOrder = RuleOrder + 1;
        
          else

            Options["Group"..GroupId].args["RuleValue"..RuleId] = {
              type = "input",
              name = "Value",
              get = function(Info) return Rule.Args[ValueType]; end,
              set = function(Info, Value) Rule.Args[ValueType] = Value; self:ApplyChange(); end,
              order = RuleOrder,
            };
            RuleOrder = RuleOrder + 1;
            
          end
          
        
        elseif (ValueType == "Number" or ValueType == "SpellId") and (Operator == "Equal" or Operator == "NotEqual" or Operator == "Greater" or Operator == "GreaterOrEqual" or Operator == "Lesser" or Operator == "LesserOrEqual") then
        
          Options["Group"..GroupId].args["RuleValue"..RuleId] = {
            type = "input",
            name = "Value",
            get = function(Info) return Rule.Args[ValueType] and tostring(Rule.Args[ValueType]); end,
            set = function(Info, Value) Rule.Args[ValueType] = tonumber(Value); self:ApplyChange(); end,
            order = RuleOrder,
            pattern = "^%d+.?%d*$",
            usage = "Only a number is allowed",
          };
          RuleOrder = RuleOrder + 1;
        
        elseif ValueType == "Boolean" and (Operator == "Equal" or Operator == "NotEqual") then
        
          Options["Group"..GroupId].args["RuleValue"..RuleId] = {
            type = "select",
            name = "Value",
            get = function(Info) return Rule.Args.boolean or nil; end,
            set = function(Info, Value) Rule.Args.boolean = Value; self:ApplyChange(); end,
            values = {
              ["true"] = "True",
              ["false"] = "False",
            },
            order = RuleOrder,
          };
          RuleOrder = RuleOrder + 1;
          
        elseif (Operator == "InList" or Operator == "NotInList") then
        
          local Filter = self;
          
          Options["Group"..GroupId].args["RuleValue"..RuleId] = {
            type = "execute",
            name = "Edit list",
            func = function(Info)
              Filter.EditListRule = Rule;
              AuraFrames:RefreshConfigDialog();
            end,
            order = RuleOrder,
          };
          RuleOrder = RuleOrder + 1;
        
        else
        
          Options["Group"..GroupId].args["RuleValue"..RuleId] = {
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
      
        Options["Group"..GroupId].args["RuleValue"..RuleId] = {
          type = "input",
          name = "",
          get = function(Info) return ""; end,
          set = function() end,
          order = RuleOrder,
          dialogControl = "TextLabel",
        };
        RuleOrder = RuleOrder + 1;

      end
      
      Options["Group"..GroupId].args["RuleDelete"..RuleId] = {
        type = "execute",
        name = "",
        func = function(Info)
          table.remove(Group, RuleId);
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
      
--[[
      
      if RuleId ~= 1 then

        Options["Group"..GroupId].args["RuleUp"..RuleId] = {
          type = "execute",
          name = "",
          func = function(Info)
            table.insert(Group, RuleId - 1, table.remove(Group, RuleId));
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
      
      if RuleId ~= #Group then

        Options["Group"..GroupId].args["RuleDown"..RuleId] = {
          type = "execute",
          name = "",
          func = function(Info)
            table.insert(Group, RuleId, table.remove(Group, RuleId + 1));
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

]]--

    end
    
    Options["Group"..GroupId].args.Spacer = {
      type = "description",
      name = " ",
      order = RuleOrder,
    };
    RuleOrder = RuleOrder + 1;
    
    Options["Group"..GroupId].args.AddRule = {
      type = "execute",
      name = "Add rule",
      func = function(Info)
        table.insert(self.Config.Groups[GroupId], {});
        self:ApplyChange();
        AuraFrames:RefreshConfigDialog();
      end,
      order = RuleOrder,
    };
    RuleOrder = RuleOrder + 1;
   
    Options["Group"..GroupId].args.DeleteGroup = {
      type = "execute",
      name = "Delete group",
      func = function(Info)
        table.remove(self.Config.Groups, GroupId);
        self:ApplyChange();
        AuraFrames:RefreshConfigDialog();
      end,
      order = RuleOrder,
    };
    RuleOrder = RuleOrder + 1;
    
    Options["Group"..GroupId].args.DisableGroup = {
      type = "execute",
      name = ((Group.Disabled == true) and "Enable group") or "Disable group",
      func = function(Info)
        if Group.Disabled and Group.Disabled == true then
          Group.Disabled = nil;
        else
          Group.Disabled = true;
        end
        self:ApplyChange();
        AuraFrames:RefreshConfigDialog();
      end,
      order = RuleOrder,
    };
    RuleOrder = RuleOrder + 1;
    
    if GroupId ~= 1 then
    
      Options["Group"..GroupId].args.UpGroup = {
        type = "execute",
        name = "Up",
        func = function(Info)
          table.insert(self.Config.Groups, GroupId - 1, table.remove(self.Config.Groups, GroupId));
          self:ApplyChange();
          AuraFrames:RefreshConfigDialog();
        end,
        width = "half",
        order = RuleOrder,
      };
      RuleOrder = RuleOrder + 1;
      
    end
    
    if GroupId ~= #self.Config.Groups then
    
      Options["Group"..GroupId].args.DownGroup = {
        type = "execute",
        name = "Down",
        func = function(Info)
          table.insert(self.Config.Groups, GroupId, table.remove(self.Config.Groups, GroupId + 1));
          self:ApplyChange();
          AuraFrames:RefreshConfigDialog();
        end,
        width = "half",
        order = RuleOrder,
      };
      RuleOrder = RuleOrder + 1;
      
    end
    
  end
  
  Options.AddGroup = {
    type = "execute",
    name = "Add group",
    order = GroupOrder;
    func = function(Info)
      table.insert(self.Config.Groups, {{}});
      self:ApplyChange();
      AuraFrames:RefreshConfigDialog();
    end,
  };
  GroupOrder = GroupOrder + 1;
  
  return Options;

end
