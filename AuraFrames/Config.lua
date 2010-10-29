local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");


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
local function CopyConfigDefaults(src, dest) -- Shameless copied from AceDB and modified for our needs :)
  if type(dest) ~= "table" then dest = {} end
  if type(src) == "table" then
    for k,v in pairs(src) do
      if type(dest[k]) == "nil" then
        if type(v) == "table" then
          -- try to index the key first so that the metatable creates the defaults, if set, and use that table
          v = CopyConfigDefaults(v, dest[k]);
        end
        dest[k] = v
      elseif type(dest[k]) == "table" then
        CopyConfigDefaults(v, dest[k]);
      end
    end
  end
  return dest
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
    CopyConfigDefaults(self.ContainerHandlers[Container.Type]:GetConfigDefaults(), Container);

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
    
  end


  self.db.profile.DbVersion = AuraFrames.DbVersion;

end


-----------------------------------------------------------------
-- Function CreateContainerConfig
-----------------------------------------------------------------
function AuraFrames:CreateNewContainer(Name, Type)

  if type(rawget(self.db.profile.Containers, Name)) ~= "nil" then
    return false;
  end
  
  if type(self.ContainerHandlers[Type]) == "nil" then
    return false;
  end
  
  -- Create the default config.
  self.db.profile.Containers[Name].Name = Name;
  self.db.profile.Containers[Name].Type = Type;
  
  -- Copy the container defaults into the new config.
  CopyConfigDefaults(self.ContainerHandlers[Type]:GetConfigDefaults(), self.db.profile.Containers[Name]);
  
  -- Create the container.
  self.Containers[Name] = self.ContainerHandlers[Type]:New(self.db.profile.Containers[Name]);
  
  -- If we are in ConfigMode, then directly set the correct mode for the container.
  if AuraFrames.ConfigMode then
    self.Containers[Name]:SetConfigMode(true);
  end
  
  return true;

end
