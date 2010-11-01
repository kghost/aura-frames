local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");

local WizardWindow = nil;
local WizardContainer = nil;
local ContainerName = "";
local ContainerTypeControls = {};
local ContainerType = "";

-----------------------------------------------------------------
-- Local Function CreateContainerConfig
-----------------------------------------------------------------
local function CreateContainerConfig()

  WizardWindow.IgnoreClose = true;
  WizardWindow:Hide();

  if strlen(ContainerName) == 0 then
    AuraFrames:MessagePopup("Please provide a container name, this is required!", function() WizardWindow:Show(); WizardWindow.IgnoreClose = false; end);
    return
  end
  
  local Found = false;
  
  for _, Container in pairs(AuraFrames.db.profile.Containers) do
  
    if ContainerName == Container.Name then
      Found = true;
      break;
    end
  
  end
  
  if Found == true then
    AuraFrames:MessagePopup("The container name you provided is already used. Please provide an unique name!", function() WizardWindow:Show(); WizardWindow.IgnoreClose = false; end);
    return
  end

  if strlen(ContainerType) == 0 then
    AuraFrames:MessagePopup("Please select a container type, this is required!", function() WizardWindow:Show(); WizardWindow.IgnoreClose = false; end);
    return
  end
  
  ContainerId = AuraFrames:CreateNewContainer(ContainerName, ContainerType);

  if not ContainerId then
    AuraFrames:MessagePopup("Failed to create the container! Please contact the addon author!", function() LibStub("AceConfigDialog-3.0"):Open("AuraFrames"); end);
    return;
  end
  
  LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
  AuraFrames:RefreshConfigDialog("Containers", "Container_"..ContainerId);

end

-----------------------------------------------------------------
-- Local Function CreateWizardWindow
-----------------------------------------------------------------
local function CreateWizardWindow()

  WizardWindow = AceGUI:Create("Window");
  WizardWindow:Hide();
  WizardWindow:SetTitle("Aura Frames - Create Container");
  WizardWindow:SetWidth(500);
  WizardWindow:SetHeight(400);
  WizardWindow:EnableResize(false);
  WizardWindow:SetCallback("OnClose", function()
    if WizardWindow.IgnoreClose ~= true then
      LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
    end
  end);
  WizardWindow:SetLayout("Flow");
  
  WizardContainer = AceGUI:Create("ScrollFrame");
  WizardContainer:SetRelativeWidth(1);
  WizardContainer:SetAutoAdjustHeight(false);
  WizardContainer:SetHeight(320);
  WizardWindow:AddChild(WizardContainer);
  
  local ButtonCancel = AceGUI:Create("Button");
  ButtonCancel:SetText("Cancel");
  ButtonCancel:SetWidth(232);
  ButtonCancel:SetCallback("OnClick", function()
    WizardWindow:Hide();
    LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
  end);
  WizardWindow:AddChild(ButtonCancel);
  
  local ButtonCreate = AceGUI:Create("Button");
  ButtonCreate:SetText("Create");
  ButtonCreate:SetWidth(232);
  ButtonCreate:SetCallback("OnClick", function()
    CreateContainerConfig();
  end);
  WizardWindow:AddChild(ButtonCreate);

end


-----------------------------------------------------------------
-- Function RefreshCreateContainerWizard
-----------------------------------------------------------------
function AuraFrames:RefreshCreateContainerWizard()

  WizardContainer:PauseLayout();
  WizardContainer:ReleaseChildren();
  
  WizardWindow.IgnoreClose = false;
  
  ContainerName = "";
  ContainerTypeControls = {};
  ContainerType = "";

  local HeaderName = AceGUI:Create("Heading");
  HeaderName:SetRelativeWidth(1);
  HeaderName:SetText("Container Name");
  WizardContainer:AddChild(HeaderName);
  
  local LabelNameInfo = AceGUI:Create("Label");
  LabelNameInfo:SetFontObject(GameFontNormal);
  LabelNameInfo:SetRelativeWidth(1);
  LabelNameInfo:SetText("Every container must have is own unique name. This name is used to identity the container.\n");
  WizardContainer:AddChild(LabelNameInfo);
  
  local LabelIdInfo = AceGUI:Create("Label");
  LabelIdInfo:SetText("Container id: ");
  
  local NameValue = AceGUI:Create("EditBox");
  NameValue:DisableButton(true);
  NameValue:SetText("");
  NameValue:SetLabel("Name");
  NameValue:SetWidth(150);
  NameValue:SetCallback("OnTextChanged", function(_, _, Text)
    ContainerName = Text;
    LabelIdInfo:SetText("Container id: "..AuraFrames:GenerateContainerId(Text));
  end);
  WizardContainer:AddChild(NameValue);
  WizardContainer:AddChild(LabelIdInfo);
  
  local LabelSpace = AceGUI:Create("Label");
  LabelSpace:SetRelativeWidth(1);
  LabelSpace:SetText("\n");
  WizardContainer:AddChild(LabelSpace);

  local HeaderType = AceGUI:Create("Heading");
  HeaderType:SetRelativeWidth(1);
  HeaderType:SetText("Container Type");
  WizardContainer:AddChild(HeaderType);
  
  local LabelTypeInfo = AceGUI:Create("Label");
  LabelTypeInfo:SetFontObject(GameFontNormal);
  LabelTypeInfo:SetRelativeWidth(1);
  LabelTypeInfo:SetText("There are different types of containers. Every type have his own way of displaying aura's. You must select an type for this container, this can not be changed after the container is created. Select a container type:\n");
  WizardContainer:AddChild(LabelTypeInfo);
  
  for Type, Handler in pairs(AuraFrames.ContainerHandlers) do
  
    local TypeControl = AceGUI:Create("CheckBox");
    TypeControl.ContainerType = Type;
    TypeControl:SetType("radio");
    TypeControl:SetValue(false);
    TypeControl:SetRelativeWidth(1);
    TypeControl:SetLabel(Handler:GetName());
    TypeControl:SetDescription(Handler:GetDescription() .. "\n");
    TypeControl:SetCallback("OnValueChanged", function(_, _, Value)
      if Value == false then
        TypeControl:SetValue(true);
        return;
      end
      ContainerType = Type;
      for _, Control in ipairs(ContainerTypeControls) do
        if Type ~= Control.ContainerType then
          Control:SetValue(false);
        end
      end
    end);
    WizardContainer:AddChild(TypeControl);
    
    table.insert(ContainerTypeControls, TypeControl);

  end

  WizardContainer:ResumeLayout();
  WizardContainer:DoLayout();

end


-----------------------------------------------------------------
-- Function ShowCreateContainerWizard
-----------------------------------------------------------------
function AuraFrames:ShowCreateContainerWizard()

  if not WizardWindow then
    CreateWizardWindow();
  end
  
  self:RefreshCreateContainerWizard();

  WizardWindow:Show();

end
