local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local Module = AuraFramesConfig:GetModule("SecureButtonContainer");
local AceGUI = LibStub("AceGUI-3.0");

-----------------------------------------------------------------
-- Function ContentOrder
-----------------------------------------------------------------
function Module:ContentOrder(ContainerId)

  local OrderConfig = AuraFrames.db.profile.Containers[ContainerId].Order;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  local Content = AuraFramesConfig.Content;

  Content:ReleaseChildren();

  Content:SetLayout("List");
  
  Content:AddText("Order\n", GameFontNormalLarge);
  
  Content:AddText("\nOrdering is used for sorting the aura's.\n\nThe Secure Button container is using Blizzards build in buffing/debuffing framework which is very limited:\n");
  
  local DropdownMethod = AceGUI:Create("Dropdown");
  DropdownMethod:SetList({
    INDEX = "Index",
    NAME = "Name",
    TIME = "Time",
  });
  DropdownMethod:SetLabel("Sort on");
  DropdownMethod:SetValue(OrderConfig.Method);
  DropdownMethod:SetCallback("OnValueChanged", function(_, _, Value)
    OrderConfig.Method = Value;
    ContainerInstance:Update("ORDER");
  end);
  Content:AddChild(DropdownMethod);
  
  Content:AddSpace();
  
  local CheckBoxReverse = AceGUI:Create("CheckBox");
  CheckBoxReverse:SetLabel("Reverse order");
  CheckBoxReverse:SetValue(OrderConfig.Direction == "-");
  CheckBoxReverse:SetCallback("OnValueChanged", function(_, _, Value)
    OrderConfig.Direction = Value and "-" or "+";
    ContainerInstance:Update("ORDER");
  end);
  Content:AddChild(CheckBoxReverse);
  
  Content:AddSpace(2);
  
  Content:AddText("Your own aura's can be placed before or after the other aura's.\n");
  
  local DropdownSeparateOwn = AceGUI:Create("Dropdown");
  DropdownSeparateOwn:SetList({
    [0]  = "No",
    [1]  = "Before",
    [-1] = "After",
  });
  DropdownSeparateOwn:SetLabel("Separate own aura's");
  DropdownSeparateOwn:SetValue(OrderConfig.SeparateOwn);
  DropdownSeparateOwn:SetCallback("OnValueChanged", function(_, _, Value)
    OrderConfig.SeparateOwn = Value;
    ContainerInstance:Update("ORDER");
  end);
  Content:AddChild(DropdownSeparateOwn);
  
end

