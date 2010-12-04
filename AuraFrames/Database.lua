local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- This version will be used to trigger database upgrades
AuraFrames.DatabaseVersion = 205;


--[[

  Database version history list:

  Version 200:
    First release. Any older database will be reseted (alpha and beta versions).
  
  Version 201:
    Added warning changing.
    Added warnings to bar containers.
  
  Version 202:
    Add BarUseAuraTime for bar containers
   
  Version 203:
    Added BackgroundBorderSize to timeline container
  
  Version 204:
    Added time labels to timeline container
  
  Version 205:
    Added InactiveAlpha to timeline container
  
   
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
    HideBlizzardAuraFrames = true,
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
  
  -- Initialize profile.
  self:DatabaseProfileInitialize();

  -- Register db chat commands.
  self:RegisterChatCommand("afreset", "DatabaseReset");
  self:RegisterChatCommand("affixdb", "DatabaseFix");

  -- Register database callbacks
  self.db.RegisterCallback(self, "OnProfileChanged", "DatabaseChanged");
  self.db.RegisterCallback(self, "OnProfileCopied", "DatabaseChanged");
  self.db.RegisterCallback(self, "OnProfileReset", "DatabaseChanged");

end


-----------------------------------------------------------------
-- Function DatabaseProfileInitialize
-----------------------------------------------------------------
function AuraFrames:DatabaseProfileInitialize()

  if self.db.profile.DbVersion == 0 then
  
    self.db.profile.DbVersion = AuraFrames.DatabaseVersion;
  
    -- Make sure we are having an empty profile.
    
    if next(self.db.profile.Containers) == nil then

      local Id, Container;
      
      Id = self:CreateNewContainerConfig("Player Buffs", "ButtonContainer");
      
      Container = self.db.profile.Containers[Id];
      Container.Location.FramePoint = "TOPRIGHT";
      Container.Location.RelativePoint = "TOPRIGHT";
      Container.Location.OffsetY = -7.5;
      Container.Location.OffsetX = -183.5;
      Container.Sources.player = {
        HELPFUL = true,
        WEAPON = true,
      };
      
      
      Id = self:CreateNewContainerConfig("Player Debuffs", "ButtonContainer");

      Container = self.db.profile.Containers[Id];
      Container.Location.FramePoint = "TOPRIGHT";
      Container.Location.RelativePoint = "TOPRIGHT";
      Container.Location.OffsetY = -106.5;
      Container.Location.OffsetX = -183.5;
      Container.Sources.player = {
        HARMFUL = true,
      };
    
    end

  end


  -- Check if we need a db upgrade.
  if self.db.profile.DbVersion < AuraFrames.DatabaseVersion then
    
     self:Print("Old database version found, upgrading it automatically.");
     self:DatabaseUpgrade();
  
  end

end


-----------------------------------------------------------------
-- Function DatabaseFix
-----------------------------------------------------------------
function AuraFrames:DatabaseFix()

  self:Print("Trying to fix the database");

  -- Force run the upgrade code.
  self:DatabaseUpgrade();
  
  -- Notify of the db changes.
  self:DatabaseChanged();

end


-----------------------------------------------------------------
-- Function DatabaseChanged
-----------------------------------------------------------------
function AuraFrames:DatabaseChanged()

  -- The database changed, destroy all current container
  -- instances and create the containers based on the
  -- new database.
  
  self:DeleteAllContainers();
  
  -- Check new profile.
  self:DatabaseProfileInitialize();
  
  self:CreateAllContainers();
  
  self:CheckBlizzardAuraFrames();

end


-----------------------------------------------------------------
-- Function DatabaseReset
-----------------------------------------------------------------
function AuraFrames:DatabaseReset()

  self.db:ResetDB();
  
  -- With a db reset we lose LibDualSpec. But LibDualSpec don't
  -- let us register the db again. So lets do some hacking.
  
  -- Reset the registry state for our db.
  LibStub("LibDualSpec-1.0").registry[self.db] = nil;
  
  -- Register our self with LibDualSpec.
  LibStub("LibDualSpec-1.0"):EnhanceDatabase(self.db, "AuraFrames");
  
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
  
  -- General upgrade code.
  
  
  -- Loop thru the containers and update the defaults.
  for _, Container in pairs(self.db.profile.Containers) do

    self:DatabaseContainerUpgrade(Container);

  end
  
  self.db.profile.DbVersion = AuraFrames.DatabaseVersion;
  
end


-----------------------------------------------------------------
-- Function DatabaseContainerUpgrade
-----------------------------------------------------------------
function AuraFrames:DatabaseContainerUpgrade(Container)

  local OldVersion = self.db.profile.DbVersion;

  if OldVersion < 201 then
  
    if Container.Type == "ButtonContainer" then
  
      Container.Warnings.Changing = {
        Popup = false,
        PopupTime = 0.5,
        PopupScale = 3.0,
      };
    
    elseif Container.Type == "BarContainer" then
    
      Container.Warnings = {
        New = {
          Flash = false,
          FlashNumber = 3.0,
          FlashSpeed = 1.0,
        },
        Expire = {
          Flash = false,
          FlashNumber = 5.0,
          FlashSpeed = 1.0,
        },
        Changing = {
          Popup = false,
          PopupTime = 0.5,
          PopupScale = 3.0,
        },
      };
    
    end
  
  end

  if OldVersion < 202 then
  
    if Container.Type == "BarContainer" then
    
      Container.Layout.BarUseAuraTime = false;
    
    end
  
  end
  
  if OldVersion < 203 then
  
    if Container.Type == "TimeLineContainer" then
    
      Container.Layout.BackgroundTextureInsets = 2;
      Container.Layout.BackgroundBorderSize = 8;
    
    end
  
  end
  
  if OldVersion < 204 then
  
    if Container.Type == "TimeLineContainer" then
    
      Container.Layout.TextLabels = {1, 10, 20, 30};
    
    end
  
  end
  
  if OldVersion < 205 then
  
    if Container.Type == "TimeLineContainer" then
    
      Container.Layout.InactiveAlpha = 1.0;
    
    end
  
  end

end


