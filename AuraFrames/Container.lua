local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LibAura = LibStub("LibAura-1.0");

-----------------------------------------------------------------
-- Function UpdateContainer
-----------------------------------------------------------------
function AuraFrames:UpdateContainer(Id)

  self.Containers[Id]:Update();

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
-- Function CreateContainer
-----------------------------------------------------------------
function AuraFrames:CreateContainer(Id)

  -- We cant overwrite an container so lets delete it first then. This should never happen btw!
  if self.Containers[Id] then
    self:DeleteContainer(Id);
  end
  
  if self.db.profile.Containers[Id].Enabled ~= true then
    return;
  end

  self.Containers[Id] = self.ContainerHandlers[self.db.profile.Containers[Id].Type]:New(self.db.profile.Containers[Id]);
  self.Containers[Id].Id = Id;
  
  for Unit, _ in pairs(self.db.profile.Containers[Id].Sources) do
  
    for Type, _ in pairs(self.db.profile.Containers[Id].Sources[Unit]) do
  
      if self.db.profile.Containers[Id].Sources[Unit][Type] == true then

        LibAura:RegisterObjectSource(self.Containers[Id], Unit, Type);

      end

    end

  end

end


-----------------------------------------------------------------
-- Function CreateNewContainer
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
  self:CopyConfigDefaults(self.ContainerHandlers[Type]:GetConfigDefaults(), self.db.profile.Containers[Id]);
  
  -- Create the container.
  self.Containers[Id] = self.ContainerHandlers[Type]:New(self.db.profile.Containers[Id]);
  
  self.Containers[Id].Id = Id;
  
  -- If we are in ConfigMode, then directly set the correct mode for the container.
  if AuraFrames.ConfigMode then
    self.Containers[Id]:SetConfigMode(true);
  end
  
  return Id;

end



-----------------------------------------------------------------
-- Function DeleteContainer
-----------------------------------------------------------------
function AuraFrames:DeleteContainer(Id)

  if not self.Containers[Id] then
    return;
  end

  self.Containers[Id]:Delete();
  self.Containers[Id] = nil;

end


-----------------------------------------------------------------
-- Function CreateAllContainers
-----------------------------------------------------------------
function AuraFrames:CreateAllContainers()

  for Id, _ in pairs(self.db.profile.Containers) do
  
    self:CreateContainer(Id);
    
  end

end


-----------------------------------------------------------------
-- Function DeleteAllContainers
-----------------------------------------------------------------
function AuraFrames:DeleteAllContainers()

  for Id, _ in pairs(self.Containers) do
  
    self:DeleteContainer(Id);
  
  end

end


-----------------------------------------------------------------
-- Function TestBug
-----------------------------------------------------------------
function AuraFrames:TestBug()

  for Id, Container in pairs(self.Containers) do
  
    if Container.Config.Type == "Buttons" then
    
      self:Print("Container: "..Container.Id);
      
      for Index, Object in pairs(Container.Order) do
      
        if type(Object) == "table" then
      
          self:Print("  "..Index.." = "..((Object.Aura and Object.Aura.Name) or "not an aura").." ("..((Object.IsShown and Object:IsShown()) and "Shown" or "Hidden")..")");
          
        else
        
          self:Print("  "..Index.." = "..type(Object));
        
        end
      
      end
    
    end
  
  end

end
