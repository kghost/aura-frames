local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");

local CopySettingsSelection = {};
local CopySettingsFrom = "";


-----------------------------------------------------------------
-- Function DeepCopy
-----------------------------------------------------------------
function DeepCopy(object)

  local lookup_table = {}

  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end

  return _copy(object)

end


-----------------------------------------------------------------
-- Local Function SetContainerEnabled
-----------------------------------------------------------------
function SetContainerEnabled(Id, Enabled)
  
  if not AuraFrames.db.profile.Containers[Id] or AuraFrames.db.profile.Containers[Id].Enabled == Enabled then
    return;
  end
  
  AuraFrames.db.profile.Containers[Id].Enabled = Enabled;
  
  if Enabled == true then
  
    AuraFrames:CreateContainer(Id);
  
  else
  
    AuraFrames:DeleteContainer(Id);
  
  end
  
end


-----------------------------------------------------------------
-- Function CopyContainerConfig
-----------------------------------------------------------------
function CopyContainerConfig(Id)

  if not AuraFrames.db.profile.Containers[Id] or not AuraFrames.db.profile.Containers[CopySettingsFrom] then
    AuraFrames:Message("Not a valid destination or source container");
    return false;
  end

  for Key, Value in pairs(AuraFrames.db.profile.Containers[CopySettingsFrom]) do
    if type(Value) == "table" and CopySettingsSelection[Key] and CopySettingsSelection[Key] == true then
      AuraFrames.db.profile.Containers[Id][Key] = DeepCopy(Value);
    end
  end
  
  AuraFrames:DeleteContainer(Id);
  AuraFrames:CreateContainer(Id);
  
  return true;

end


-----------------------------------------------------------------
-- Function ContentContainerNoModule
-----------------------------------------------------------------
function AuraFramesConfig:ContentContainerNoModule(ContainerId)

  local ContainerConfig = AuraFrames.db.profile.Containers[ContainerId];
  
  self.Content:SetLayout("List");
  
  self.Content:AddText("Container "..ContainerConfig.Name.."\n", GameFontNormalLarge);
  
  self.Content:AddText("The container "..ContainerConfig.Name.." can not be configured at this time. The container type is "..ContainerConfig.Type.." but no module could be found for that type!\n\n");

  local ButtonDelete = AceGUI:Create("Button");
  ButtonDelete:SetText("Delete container");
  ButtonDelete:SetCallback("OnClick", function()
  
    AuraFramesConfig:Hide();
    
    AuraFrames:Confirm("Are you sure you want to delete the container?", function(Result)
      if Result == true then
        
        -- Delete container instance if it exists.
        AuraFrames:DeleteContainer(ContainerId);
        
        -- Delete configuration.
        AuraFrames.db.profile.Containers[ContainerId] = nil;
        
        -- Refesh configuration tree.
        AuraFramesConfig:RefreshTree();
        
        -- Select "Containers" page.
        AuraFramesConfig:SelectByPath("Containers");
      
      end
      
      AuraFramesConfig:Show();
      
    end);
    
  end);
  self.Content:AddChild(ButtonDelete);

end


-----------------------------------------------------------------
-- Function ContentContainerRefresh
-----------------------------------------------------------------
function AuraFramesConfig:ContentContainerRefresh(Content, ContainerId)

  Content:PauseLayout();
  Content:ReleaseChildren();

  Content:SetLayout("List");
  
  wipe(CopySettingsSelection);
  CopySettingsFrom = "";

  local ContainerConfig = AuraFrames.db.profile.Containers[ContainerId];

  Content:AddText("Container "..ContainerConfig.Name.."\n", GameFontNormalLarge);
  
  Content:AddText("Every container can be enabled or disabled. Disabled containers don't take any resources.\n");
  
  local CheckBoxEnabled = AceGUI:Create("CheckBox");
  CheckBoxEnabled:SetLabel("Container Enabled");
  CheckBoxEnabled:SetValue(ContainerConfig.Enabled);
  CheckBoxEnabled:SetCallback("OnValueChanged", function(_, _, Value)
    SetContainerEnabled(ContainerId, Value);
    AuraFramesConfig:ContentContainerRefresh(Content, ContainerId);
  end);
  Content:AddChild(CheckBoxEnabled);
  
  Content:AddSpace();
  
  if ContainerConfig.Enabled == true then
  
    local SettingsToCopy = {};
    
    for Key, Value in pairs(ContainerConfig) do
      if type(Value) == "table" then
        SettingsToCopy[Key] = Key;
      end
    end
    
    local CopyFrom = {};
    
    for Key, Value in pairs(AuraFrames.db.profile.Containers) do
      if Key ~= ContainerId and Value.Type == ContainerConfig.Type then
        CopyFrom[Key] = Key;
      end
    end
  
    Content:AddHeader("Copy Settings");
    Content:AddText("You can only copy settings from the same type of container.\n");
    
    if next(CopyFrom) == nil then
    
      Content:AddText("There are no other containers of the same type available for copying settings from");
    
    else
    
      local GroupCopyWhat = AceGUI:Create("InlineGroup");
      GroupCopyWhat:SetTitle("Copy the following settings");
      GroupCopyWhat:SetRelativeWidth(1);
      GroupCopyWhat:SetLayout("Flow");
      Content:AddChild(GroupCopyWhat);
      
      for Key, Value in pairs(SettingsToCopy) do
      
        local CheckBoxWhat = AceGUI:Create("CheckBox");
        CheckBoxWhat:SetLabel(Value);
        CheckBoxWhat:SetValue(false);
        CheckBoxWhat:SetWidth(175);
        CheckBoxWhat:SetCallback("OnValueChanged", function(_, _, Value)
          CopySettingsSelection[Key] = Value
        end);
        GroupCopyWhat:AddChild(CheckBoxWhat);
      
      end
      
      local GroupCopyOptions = AceGUI:Create("SimpleGroup");
      GroupCopyOptions:SetRelativeWidth(1);
      GroupCopyOptions:SetLayout("Flow");
      Content:AddChild(GroupCopyOptions);
      
      local SelectCopyFrom = AceGUI:Create("Dropdown");
      SelectCopyFrom:SetList(CopyFrom);
      SelectCopyFrom:SetLabel("Copy from container");
      SelectCopyFrom:SetValue("");
      SelectCopyFrom:SetCallback("OnValueChanged", function(_, _, Value)
        CopySettingsFrom = Value;
      end);
      GroupCopyOptions:AddChild(SelectCopyFrom);
      
      local ButtonCopy = AceGUI:Create("Button");
      ButtonCopy:SetText("Copy settings");
      ButtonCopy:SetCallback("OnClick", function()
      
        if CopyContainerConfig(ContainerId) == true then
          AuraFramesConfig:ContentContainerRefresh(Content, ContainerId);
        end
      
      end);
      GroupCopyOptions:AddChild(ButtonCopy);
      
    end
    
    Content:AddSpace();
    
    Content:AddHeader("Move containers");
    Content:AddText("Containers can only be moved when they are unlocked. Unlock/lock the containers by using the button below:\n\n");
    
    local ButtonMove = AceGUI:Create("Button");
    ButtonMove:SetText(AuraFramesConfig.ContainersUnlocked and "Lock containers" or "Unlock containers");
    ButtonMove:SetCallback("OnClick", function()
      AuraFramesConfig:UnlockContainers(not AuraFramesConfig.ContainersUnlocked);
    end);
    Content:AddChild(ButtonMove);
  
  end
  
  Content:AddSpace();
  Content:AddHeader("Miscellaneous");
  Content:AddText("");
  
  local ButtonDelete = AceGUI:Create("Button");
  ButtonDelete:SetText("Delete container");
  ButtonDelete:SetCallback("OnClick", function()
  
    AuraFramesConfig:Close();
    
    AuraFrames:Confirm("Are you sure you want to delete the container?", function(Result)
      if Result == true then
        
        -- Delete container instance if it exists.
        AuraFrames:DeleteContainer(ContainerId);
        
        -- Delete configuration.
        AuraFrames.db.profile.Containers[ContainerId] = nil;
        
        -- Refesh configuration tree.
        AuraFramesConfig:RefreshTree();
        
        -- Select "Containers" page.
        AuraFramesConfig:SelectByPath("Containers");
        
      end
      
      AuraFramesConfig:Show();
      
    end);
    
  end);
  Content:AddChild(ButtonDelete);

  Content:ResumeLayout();
  Content:DoLayout();

end


-----------------------------------------------------------------
-- Function ContentContainer
-----------------------------------------------------------------
function AuraFramesConfig:ContentContainer(ContainerId)

  self.Content:SetLayout("Fill");
  
  local Content = AceGUI:Create("ScrollFrame");
  Content:SetLayout("List");
  self:EnhanceContainer(Content);
  self.Content:AddChild(Content);
  
  self:ContentContainerRefresh(Content, ContainerId);

end
