local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LibAura = LibStub("LibAura-1.0");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ShowIntroductionDialog
-----------------------------------------------------------------
function AuraFrames:ShowIntroductionDialog()

  local Window = AceGUI:Create("Window");
  Window:SetTitle("AuraFrames");
  Window:SetWidth(800);
  Window:SetHeight(600);
  Window:EnableResize(false);
  Window:SetLayout("Flow")
  
  local Container = AceGUI:Create("SimpleGroup");
  Container:SetRelativeWidth(1);
  Container:SetAutoAdjustHeight(false);
  Container:SetHeight(520);
  Window:AddChild(Container);
  
  --local ExampleImage = AceGUI:Create("Label");
  --ExampleImage:SetImage([[Interface\Addons\AuraFramesOptions\Textures\AuraFramesExample.tga]]);
  --Container:AddChild(ExampleImage);
  
  
  for i = 1, 80 do
  
  local Label = AceGUI:Create("Label");
  Label:SetFontObject(GameFontHighlight);
  Label:SetRelativeWidth(1);
  Label:SetText("Welcome to the introduction of AuraFrames.");
  Container:AddChild(Label);
  
  end
  
  local ButtonPrevious = AceGUI:Create("Button");
  ButtonPrevious:SetText("Next");
  ButtonPrevious:SetWidth(255);
  ButtonPrevious:SetDisabled(true);
  Window:AddChild(ButtonPrevious);
  
  local ButtonNext = AceGUI:Create("Button");
  ButtonNext:SetText("Next");
  ButtonNext:SetWidth(255);
  Window:AddChild(ButtonNext);
  
  local ButtonSkip = AceGUI:Create("Button")
  ButtonSkip:SetText("Skip Introduction")
  ButtonSkip:SetWidth(255)
  Window:AddChild(ButtonSkip)

end