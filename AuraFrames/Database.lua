local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- This version will be used to trigger database upgrades
AuraFrames.DatabaseVersion = 167;


--[[

  Database version history list:

  Version 153:
    db.profile.Containers[*].Filters renamed to db.profile.Containers[*].Filter

  Version 154:
    Implemented default options for filter and order. Database will be extended
    with the default options.

  Version 155:
    db.profile.Containers[*].Order will now be db.profile.Containers[*].Order.Rules.

  Version 157:
    Expert mode implemented for filter and order. When upgrading we are enabling
    directly the expert mode.
    
    db.profile.Containers[*].Filter.Expert = true
    db.profile.Containers[*].Order.Expert = true

  Version 158:
    Container id's implemented next to names. When upgrading take the current name
    as container id.
    
    db.profile.Containers[*].Id = db.profile.Containers[*].Name

  Version 159:
    EnableTestUnit is already for a long time not needed anymore. Cleaing up database.
    
    db.profile.EnableTestUnit = nil

  Version 160:
    db.profile.Containers[*].Layout.Colors[**] doesn't support alpha anymore. Change all
    alpha values to 1.0.

  Version 161:
    ContainerHandlers renamed to ContainerModules and also changed the internal container id's
    from the container name to the module name.
    
    db.profile.Containers[*].Type changed to module name.
  
  Version 162:
    DurationFormat: Different keys changed.
    
  Version 163:
    Fixing version 160 (colors is not located in layout).
  
  Version 164:
    Added text font settings for bar containers.
  
  Version 165:
    Added support for coloring the background of the texture and button in the bar container. Settings defaults.
  
  Version 166:
    Bar container can now hide the aura name, set default to show when upgrading.
    Bar texture can now stand still or move.
  
  Version 167:
    Bar container new: TextureBackgroundUseTexture, TextureBackgroundUseBarColor,
    TextureBackgroundOpacity and ButtonBackgroundOpacity.
  
]]--


-- The default database.
local DatabaseDefaults = {
  profile = {
    DbVersion = 0;
    Containers = {
      ["*"] = {
        Name = "",
        Type = "",
        Enabled = true,
        Sources = {},
      },
    },
    HideBlizzardAuraFrames = false,
  },
};


-----------------------------------------------------------------
-- Function DatabaseInitialize
-----------------------------------------------------------------
function AuraFrames:DatabaseInitialize()

  -- Init db.
  self.db = LibStub("AceDB-3.0"):New("AuraFramesDB", DatabaseDefaults);
  
  -- Enable dual spec.
  LibStub("LibDualSpec-1.0"):EnhanceDatabase(self.db, "AuraFrames");
  
  -- Set version if we don't have it.
  if self.db.profile.DbVersion == 0 then
    self.db.profile.DbVersion = AuraFrames.DatabaseVersion;
  end

  -- Check if we need a db upgrade.
  if self.db.profile.DbVersion < AuraFrames.DatabaseVersion then
    
     self:Print("Old database version found, going to automatically trying to upgrade.");
     self:DatabaseUpgrade();
  
  end

  -- Register db chat commands.
  self:RegisterChatCommand("afreset", "DatabaseReset");
  self:RegisterChatCommand("affixdb", "DatabaseUpgrade");

  -- Register database callbacks
  self.db.RegisterCallback(self, "OnProfileChanged", "DatabaseChanged");
  self.db.RegisterCallback(self, "OnProfileCopied", "DatabaseChanged");
  self.db.RegisterCallback(self, "OnProfileReset", "DatabaseChanged");

end


-----------------------------------------------------------------
-- Function DatabaseChanged
-----------------------------------------------------------------
function AuraFrames:DatabaseChanged()

  -- The database changed, destroy all current container
  -- instances and create the containers based on the
  -- new database.
  
  self:DeleteAllContainers();
  self:CreateAllContainers();
  
  self:CheckBlizzardAuraFrames();

end

-----------------------------------------------------------------
-- Function DatabaseReset
-----------------------------------------------------------------
function AuraFrames:DatabaseReset()

  self.db:ResetDB();
  self:Print("Database is reseted to the default settings");

end


-----------------------------------------------------------------
-- Function CopyDatabaseDefaults
-----------------------------------------------------------------
function AuraFrames:CopyDatabaseDefaults(Source, Destination)

  -- Shameless copied from AceDB and modified for our needs and style :)

  if type(Destination) ~= "table" then
    Destination = {};
  end

  if type(Source) == "table" then

    for Key, Value in pairs(Source) do

      if type(Destination[Key]) == "nil" then
      
        if type(Value) == "table" then
        
          Value = self:CopyDatabaseDefaults(Value, Destination[Key]);
          
        end
      
        Destination[Key] = Value;
      
      elseif type(Destination[Key]) == "table" then
      
        self:CopyDatabaseDefaults(Value, Destination[Key]);
      
      end

    end

  end

  return Destination;

end


-----------------------------------------------------------------
-- Function DatabaseUpgrade
-----------------------------------------------------------------
function AuraFrames:DatabaseUpgrade()

  -- See the "Database version history list" in the top of
  -- this file for more information.

  local OldVersion = self.db.profile.DbVersion;
  
  -- Loop thru the containers and update the defaults.
  for _, Container in pairs(self.db.profile.Containers) do

    -- Copy the container defaults into the new config.
    if self.ContainerModules[Container.Type] then
    
      if not self.ContainerModules[Container.Type]:IsEnabled() then
        self.ContainerModules[Container.Type]:Enable();
      end
      
      self:CopyDatabaseDefaults(self.ContainerModules[Container.Type]:GetDatabaseDefaults(), Container);
    
    end
    

    if self.db.profile.DbVersion < 153 then
    
      Container.Filter = Container.Filters;
      Container.Filters = nil
    
    end
    
    if self.db.profile.DbVersion < 154 then
    
      Container.Filter = AuraFrames:GetDatabaseDefaultsFilter();
      Container.Order = AuraFrames:GetDatabaseDefaultsOrder();
    
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
    
    if self.db.profile.DbVersion < 161 then
    
      if Container.Type == "Buttons" then
        
        Container.Type = "ButtonContainer";
      
      elseif Container.Type == "Bars" then
      
        Container.Type = "BarContainer";
      
      end
    
    end
    
    if self.db.profile.DbVersion < 162 then
    
      if Container.Layout.DurationLayout == "FORMAT" then
        
        Container.Layout.DurationLayout = "ABBREVSPACE";
        
      elseif Container.Layout.DurationLayout == "SEPCOLON" then
        
        Container.Layout.DurationLayout = "SEPCOL";
      
      elseif Container.Layout.DurationLayout == "SECONDS" then
        
        Container.Layout.DurationLayout = "NONE";
        
      else -- Default
        
        Container.Layout.DurationLayout = "ABBREVSPACE"; 
        
      end
    
      if Container.Type == "ButtonContainer" then
      
        Container.Layout.DurationOutline = "OUTLINE";
        Container.Layout.DurationMonochrome = false;
        Container.Layout.DurationSize = 11;
        Container.Layout.DurationPosX = 0;
        Container.Layout.DurationPosY = -25;
        Container.Layout.DurationColor = {1, 1, 1, 1};
        
        Container.Layout.CountOutline = "OUTLINE";
        Container.Layout.CountMonochrome = false;
        Container.Layout.CountSize = 12;
        Container.Layout.CountPosX = 10;
        Container.Layout.CountPosY = -6;
        Container.Layout.CountColor = {1, 1, 1, 1};
        
      end
    
    end
    
    if self.db.profile.DbVersion < 163 then
    
      if Container.Layout and Container.Colors then
        
        local Colors = Container.Colors;
        
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
    
    if self.db.profile.DbVersion < 164 then
    
      if Container.Type == "BarContainer" then
      
        Container.Layout.TextOutline = "OUTLINE";
        Container.Layout.TextMonochrome = false;
        Container.Layout.TextSize = 11;
        Container.Layout.TextColor = {1, 1, 1, 1};
        
      end
    
    end
    
    if self.db.profile.DbVersion < 165 then
    
      if Container.Type == "BarContainer" then
      
        Container.Layout.TextureBackgroundColor = {0, 0, 0, 0.8};
        Container.Layout.ButtonBackgroundColor = {0, 0, 0, 0.8};
        Container.Layout.ButtonBackgroundUseBar = true;
        
      end
    
    end
    
    if self.db.profile.DbVersion < 166 then
    
      if Container.Type == "BarContainer" then
      
        Container.Layout.ShowAuraName = true;
        Container.Layout.BarTextureMove = false;
        
      end
    
    end
    
    if self.db.profile.DbVersion < 167 then
    
      if Container.Type == "BarContainer" then
      
        Container.Layout.TextureBackgroundUseTexture = false;
        Container.Layout.TextureBackgroundUseBarColor = false;
        Container.Layout.TextureBackgroundOpacity = 1;
        Container.Layout.ButtonBackgroundOpacity = 1;
        
      end
    
    end
    
  end
  
  if self.db.profile.DbVersion < 159 then
  
    self.db.profile.EnableTestUnit = nil;
  
  end

  self.db.profile.DbVersion = AuraFrames.DbVersion;

end

