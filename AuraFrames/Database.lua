local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- This version will be used to trigger database upgrades
AuraFrames.DatabaseVersion = 200;


--[[

  Database version history list:

  Version 200:
    First release. Any older database will be reseted (alpha and beta versions).
    
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
  self:RegisterChatCommand("affixdb", "DatabaseFix");

  -- Register database callbacks
  self.db.RegisterCallback(self, "OnProfileChanged", "DatabaseChanged");
  self.db.RegisterCallback(self, "OnProfileCopied", "DatabaseChanged");
  self.db.RegisterCallback(self, "OnProfileReset", "DatabaseChanged");

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
  
  if self.db.profile.DbVersion < 200 then
  
    self:DatabaseReset();
    self:Message("Aura Frames\n\nAn alpha/beta database was found, your database have been reseted. Thanks for testing Aura Frames and sorry for reseting your database.", nil, "Okay");
  
  end
  
  
  -- Loop thru the containers and update the defaults.
  for _, Container in pairs(self.db.profile.Containers) do

    -- Container upgrade code.

  end
  
  self.db.profile.DbVersion = AuraFrames.DbVersion;

end

