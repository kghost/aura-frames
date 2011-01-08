local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");


-----------------------------------------------------------------
-- Function ContentGeneral
-----------------------------------------------------------------
function AuraFramesConfig:ContentGeneral()

  self.Content:SetLayout("List");
  
  self.Content:AddText("General\n", GameFontNormalLarge);

  self.Content:AddHeader("Version Information");
  
  local VersionGroup = AceGUI:Create("SimpleGroup");
  VersionGroup:SetRelativeWidth(1);
  VersionGroup:SetLayout("Flow");
  self:EnhanceContainer(VersionGroup)
  self.Content:AddChild(VersionGroup);

  VersionGroup:AddText("You are running the following version of Aura Frames:");
  VersionGroup:AddSpace();
  
  VersionGroup:AddText("Version", nil, 100);
  VersionGroup:AddText(": |cffff0000"..AuraFrames.Version.String.."|r", nil, 450);
  
  VersionGroup:AddText("Revision", nil, 100);
  VersionGroup:AddText(": "..AuraFrames.Version.Revision, nil, 450);
  
  VersionGroup:AddText("Date", nil, 100);
  VersionGroup:AddText(": "..AuraFrames.Version.Date, nil, 450);
  

  self.Content:AddSpace(2);
  
  self.Content:AddHeader("Support");

  self.Content:AddText("When reporting a problem, please include the version information found on top of this page. Support can be found on the following places:\n\n")
  
  local SupportGroup = AceGUI:Create("SimpleGroup");
  SupportGroup:SetRelativeWidth(1);
  SupportGroup:SetLayout("Flow");
  self:EnhanceContainer(SupportGroup)
  self.Content:AddChild(SupportGroup);
  
  SupportGroup:AddText("Forum: ", nil, 60);

  local ForumTextBox = AceGUI:Create("AuraFramesEditBox");
  ForumTextBox:SetWidth(450);
  ForumTextBox:SetText("http://forums.curseforge.com/showthread.php?t=1886");
  ForumTextBox:DisableButton(true);
  ForumTextBox:SetCallback("OnTextChanged", function()
    ForumTextBox:SetText("http://forums.curseforge.com/showthread.php?t=1886");
    ForumTextBox.editbox:HighlightText(0, ForumTextBox.editbox:GetNumLetters());
  end);
  ForumTextBox.editbox:HookScript("OnMouseUp", function()
    ForumTextBox.editbox:HighlightText(0, ForumTextBox.editbox:GetNumLetters());
  end);
  SupportGroup:AddChild(ForumTextBox);
  
  
  SupportGroup:AddText("");
  SupportGroup:AddText("Tickets:", nil, 60);
  
  local TicketsTextBox = AceGUI:Create("AuraFramesEditBox");
  TicketsTextBox:SetWidth(450);
  TicketsTextBox:SetText("http://wow.curseforge.com/addons/aura-frames/tickets/");
  TicketsTextBox:DisableButton(true);
  TicketsTextBox:SetCallback("OnTextChanged", function()
    TicketsTextBox:SetText("http://wow.curseforge.com/addons/aura-frames/tickets/");
    TicketsTextBox.editbox:HighlightText(0, TicketsTextBox.editbox:GetNumLetters());
  end);
  TicketsTextBox.editbox:HookScript("OnMouseUp", function()
    TicketsTextBox.editbox:HighlightText(0, TicketsTextBox.editbox:GetNumLetters());
  end);
  SupportGroup:AddChild(TicketsTextBox);
  
  SupportGroup:AddText(" ", nil, 65);
  SupportGroup:AddText("Click on an URL to select it and press then CTRL+C to copy the text to the clipboard.", GameFontHighlightSmall, 450);

  self.Content:AddSpace(2);
  
  self.Content:AddHeader("Credits");

  self.Content:AddText("This addon is developed and mainted by |cff9382C9Nexiuz|r (|cff0070DDBeautiuz|r) @ Bloodhoof EU.\n\nThe two most important addons that helped me and inspired me are SatrinaBuffFrame and LibBuffet.\n\nSpecial thanks goes to |cff9382C9Ripsomeone|r @ Bloodhoof EU for testing and helping me giving the addon his current form.");

  self.Content:AddSpace();


end
