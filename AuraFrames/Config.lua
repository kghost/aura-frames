local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;


-- The option table used for creating the config launch button.
local BlizzardOptions = {
  name = "Aura Frames",
  handler = AuraFrames,
  type = "group",
  args = {
    LaunchConfiguration = {
      type = "execute",
      name = "Launch Configuration",
      func = function()
        InterfaceOptionsFrame:Hide();
        HideUIPanel(GameMenuFrame);
        GameTooltip:Hide();
        AuraFrames:OpenConfigDialog()
      end,
    },
  },
};


-- By default we are not in config mode.
AuraFrames.ConfigMode = false;


-----------------------------------------------------------------
-- Function RegisterBlizzardOptions
-----------------------------------------------------------------
function AuraFrames:RegisterBlizzardOptions()
  
  LibStub("AceConfig-3.0"):RegisterOptionsTable("AuraFramesBliz", function() return BlizzardOptions; end);
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AuraFramesBliz", "Aura Frames");
  
end


-----------------------------------------------------------------
-- Function LoadOptionAddon
-----------------------------------------------------------------
function AuraFrames:LoadOptionAddon()

  if IsAddOnLoaded("AuraFramesOptions") == 1 then
    return;
  end
  
  local Loaded, Reason = LoadAddOn("AuraFramesOptions");
  
  if not Loaded then
  
    self:Message("Failed to load the AuraFramesOptions addon because: "..getglobal("ADDON_"..Reason));
    return;
  
  end
  
  self.AuraFramesOptions = LibStub("AceAddon-3.0"):GetAddon("AuraFramesOptions");
  
end


-----------------------------------------------------------------
-- Function OpenConfigDialog
-----------------------------------------------------------------
function AuraFrames:OpenConfigDialog()
  
  if not self.InitializeConfig then
  
    local Loaded, Reason = LoadAddOn("AuraFramesOptions");
    
    if not Loaded then
    
      self:Print("Failed to load the AuraFramesOptions because: "..getglobal("ADDON_"..Reason));
      return;
    
    end
    
    self:InitializeConfig();
  
  end
  
  LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
  
end


-----------------------------------------------------------------
-- Function ResetConfig
-----------------------------------------------------------------
function AuraFrames:ResetConfig()

  self.db:ResetDB();
  self:Print("Database is reseted to the default settings");

end


-----------------------------------------------------------------
-- Function CopyConfigDefaults
-----------------------------------------------------------------
function AuraFrames:CopyConfigDefaults(Source, Destination)

  -- Shameless copied from AceDB and modified for our needs and style :)

  if type(Destination) ~= "table" then
    Destination = {};
  end

  if type(Source) == "table" then

    for Key, Value in pairs(Source) do

      if type(Destination[Key]) == "nil" then
      
        if type(Value) == "table" then
        
          -- try to index the key first so that the metatable creates the defaults, if set, and use that table
          Value = self:CopyConfigDefaults(Value, Destination[Key]);
          
        end
      
        Destination[Key] = Value;
      
      elseif type(Destination[k]) == "table" then
      
        self:CopyConfigDefaults(Value, Destination[Key]);
      
      end

    end

  end

  return Destination

end


-----------------------------------------------------------------
-- Function UpgradeDb
-----------------------------------------------------------------
function AuraFrames:UpgradeDb()

  if self.db.profile.DbVersion < 154 then
    self:Print("> No support for converting the filters. Filters are resetted and you need to reconfigure it.");
  end

  -- Loop thru the containers and update the defaults.
  for _, Container in pairs(self.db.profile.Containers) do

    -- Copy the container defaults into the new config.
    self:CopyConfigDefaults(self.ContainerHandlers[Container.Type]:GetConfigDefaults(), Container);

    if self.db.profile.DbVersion < 153 then
    
      Container.Filter = Container.Filters;
      Container.Filters = nil
    
    end
    
    if self.db.profile.DbVersion < 154 then
    
      Container.Filter = AuraFrames:GetConfigDefaultsFilter();
      Container.Order = AuraFrames:GetConfigDefaultsOrder();
    
    end
    
    if self.db.profile.DbVersion < 155 then
    
      Container.Order = {Rules = Container.Order};
    
    end
    
    if self.db.profile.DbVersion < 157 then
    
      Container.Filter.Expert = true;
      Container.Order.Expert = true;
    
    end
    
    if self.db.profile.DbVersion < 158 then
    
      Container.Id = Container.Name;
    
    end
    
    if self.db.profile.DbVersion < 160 then
    
      if Container.Layout and Container.Layout.Colors then
        
        local Colors = Container.Layout.Colors;
        
        Colors.Debuff.None[4] = 1.0;
        Colors.Debuff.Magic[4] = 1.0;
        Colors.Debuff.Curse[4] = 1.0;
        Colors.Debuff.Disease[4] = 1.0;
        Colors.Debuff.Poison[4] = 1.0;
        
        Colors.Buff[4] = 1.0;
        Colors.Weapon[4] = 1.0;
        Colors.Other[4] = 1.0;
      
      end
    
    end
    
  end
  
  if self.db.profile.DbVersion < 159 then
  
    self.db.profile.EnableTestUnit = nil;
  
  end

  self.db.profile.DbVersion = AuraFrames.DbVersion;

end

