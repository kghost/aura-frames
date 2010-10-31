local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");


-- By default we are not in config mode.
AuraFrames.ConfigMode = false;

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
-- Function GenerateContainerId
-----------------------------------------------------------------
function AuraFrames:GenerateContainerId(Name)

  local Id = "";
  
  for Part in string.gmatch(Name, "%w+") do
    Id = Id..Part;
  end

  if type(rawget(self.db.profile.Containers, Id)) ~= "nil" then

    Id = Id.."_";
    local i = 2;

    while type(rawget(self.db.profile.Containers, Id..i)) ~= "nil" do
      i = i + 1;
    end

    Id = Id..i;

  end
  
  return Id;

end


-----------------------------------------------------------------
-- Function CreateContainerConfig
-----------------------------------------------------------------
function AuraFrames:CreateNewContainer(Name, Type)

  local Id = self:GenerateContainerId(Name);
  
  if type(self.ContainerHandlers[Type]) == "nil" then
    return nil;
  end
  
  -- Create the default config.
  self.db.profile.Containers[Id].Id = Id;
  self.db.profile.Containers[Id].Name = Name;
  self.db.profile.Containers[Id].Type = Type;
  
  -- Copy the container defaults into the new config.
  CopyConfigDefaults(self.ContainerHandlers[Type]:GetConfigDefaults(), self.db.profile.Containers[Id]);
  
  -- Create the container.
  self.Containers[Id] = self.ContainerHandlers[Type]:New(self.db.profile.Containers[Id]);
  
  -- If we are in ConfigMode, then directly set the correct mode for the container.
  if AuraFrames.ConfigMode then
    self.Containers[Id]:SetConfigMode(true);
  end
  
  return Id;

end
