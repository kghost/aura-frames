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
-- Function BuildConfigOptions
-----------------------------------------------------------------
function AuraFrames.OrderPrototype:BuildConfigOptions()


  local Options;
  local Config = self.Config;

  if Config.Expert then

    Options = {
      Description = {
        type = "description",
        name = "Ordering is used for sorting the aura's.\n\nExpert mode is enabled.\n\n",
        fontSize = "medium",
        order = 1,
      },
      OrderEditor = {
        type = "execute",
        name = "Open Order editor",
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
        name = "The expert mode allow you to even more customizations then the few default options above. But the export mode is also quite complex. The above selected option will be converted to the complex order rules, but when you turn off the expert mode you will lose the custom expert order rules!",
        fontSize = "medium",
        order = 5,
      },
      ExpertMode = {
        type = "toggle",
        name = "Expert Mode",
        get = function(_) return true; end,
        set = function(_, Value)
          Config.Expert = false;
          Config.Rules = {};
          AuraFrames:RefreshConfigDialog();
          self:ApplyChange();
        end,
        confirm = true,
        confirmText = "Are you sure you want to turn of expert mode? You will lose your custom order rules!",
        order = 6,
      },
    };

  else
  
    Options = {};
    local Order = 1;
    
    Options.Description = {
      type = "description",
      name = "Ordering is used for sorting the aura's.\n\nSelect one option that need to be used for ordering the aura's:\n\n",
      fontSize = "medium",
      order = Order,
    };
    Order = Order + 1;

    local CurrentOrder = Order;

    for Key, Definition in pairs(AuraFrames.OrderPredefined) do

      Options["Predefined"..Key] = {
        type = "toggle",
        width = "full",
        name = Definition.Description,
        get = function(Info) return Config.Predefined == Key; end,
        set = function(Info, Value)
          if Value == true then
            Config.Predefined = Key;
            AuraFrames:RefreshConfigDialog();
            self:ApplyChange();
          end
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
      name = "The expert mode allow you to even more customizations then the few default options above. But the export mode is also quite complex. The above rules will be converted to the complex Order rules, but when you turn off the expert mode you will lose the custom expert Orders!\n",
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

