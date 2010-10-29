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
-- Function BuildConfigOptions
-----------------------------------------------------------------
function AuraFrames.FilterPrototype:BuildConfigOptions()

  local Options;
  local Config = self.Config;

  if Config.Expert then

    Options = {
      Description = {
        type = "description",
        name = "Filters are used for fine tuning what kind of aura's are displayed inside a container.\n\nExpert mode is enabled.\n\n",
        fontSize = "medium",
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
      Space = {
        type = "description",
        name = " ",
        order = 3,
      },
      Sep = {
        type = "header",
        name = "",
        order = 4,
      },
      DescriptionExpert = {
        type = "description",
        name = "The expert mode allow you to even more customizations then the few default rules above. But the export mode is also quite complex. The above rules will be converted to the complex filter rules, but when you turn off the expert mode you will lose the custom expert filters!",
        fontSize = "medium",
        order = 5,
      },
      ExpertMode = {
        type = "toggle",
        name = "Expert Mode",
        get = function(_) return true; end,
        set = function(_, Value)
          Config.Expert = false;
          Config.Groups = {};
          AuraFrames:RefreshConfigDialog();
          self:ApplyChange();
        end,
        confirm = true,
        confirmText = "Are you sure you want to turn of expert mode? You will lose your custom filters!",
        order = 6,
      },
    };

  else
  
    Options = {};
    local Order = 1;
    
    Options.Description = {
      type = "description",
      name = "Filters are used for fine tuning what kind of aura's are displayed inside a container.\n\nOnly show aura's that are matching at least one of the following selected criteria, if nothing is selected then there will be no filtering:\n\n",
      fontSize = "medium",
      order = Order,
    };
    Order = Order + 1;

    local CurrentOrder = Order;

    for Key, Definition in pairs(AuraFrames.FilterPredefined) do

      Options["Predefined"..Key] = {
        type = "toggle",
        width = "full",
        name = Definition.Description,
        get = function(Info) return Config.Predefined and Config.Predefined[Key] or false; end,
        set = function(Info, Value)
          if Value == true then
            if not Config.Predefined then
              Config.Predefined = {};
            end
            Config.Predefined[Key] = true;
          else
            if Config.Predefined then
              Config.Predefined[Key] = nil;
            end
          end
          self:ApplyChange();
        end,
        order = CurrentOrder + Definition.Order - 1,
      };
      Order = Order + 1;
      
    end

    Options.Space = {
      type = "description",
      name = " ",
      order = Order,
    };
    Order = Order + 1;
    
    Options.Sep = {
      type = "header",
      name = "",
      order = Order,
    };
    Order = Order + 1;
    
    Options.DescriptionExpert = {
      type = "description",
      name = "The expert mode allow you to even more customizations then the few default rules above. But the export mode is also quite complex. The above rules will be converted to the complex filter rules, but when you turn off the expert mode you will lose the custom expert filters!\n",
      fontSize = "medium",
      order = Order,
    };
    Order = Order + 1;
    
    Options.ExpertMode = {
      type = "toggle",
      name = "Expert Mode",
      get = function(_) return false; end,
      set = function(_, Value)
        Config.Expert = true;
        Config.Predefined = nil;
        AuraFrames:RefreshConfigDialog();
        self:ApplyChange();
      end,
      order = Order,
    };
    Order = Order + 1;
    
  end

  return Options;

end

