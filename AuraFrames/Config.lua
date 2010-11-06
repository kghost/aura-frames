local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;


-- By default we are not in config mode.
AuraFrames.ConfigMode = false;


-----------------------------------------------------------------
-- Function RegisterBlizzardOptions
-----------------------------------------------------------------
function AuraFrames:RegisterBlizzardOptions()

  local Panel = CreateFrame("Frame");
  Panel.name = "Aura Frames";
  
  local Label = Panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  Label:SetPoint("TOPLEFT", Panel, "TOPLEFT", 10, -15);
  Label:SetPoint("BOTTOMRIGHT", Panel, "TOPRIGHT", 10, -45);
  Label:SetJustifyH("LEFT");
  Label:SetJustifyV("TOP");
  Label:SetText("Aura Frames");

  local Button = CreateFrame("Button", "AuraFramesLaunchConfig", Panel, "UIPanelButtonTemplate2");
  Button:SetWidth(300);
  Button:SetHeight(24);
  Button:ClearAllPoints();
  Button:SetPoint("TOPLEFT", Label, "BOTTOMLEFT", 0, -10);
  
  local Text = Button:GetFontString();
  Text:ClearAllPoints();
  Text:SetPoint("TOPLEFT", 15, -1);
  Text:SetPoint("BOTTOMRIGHT", -15, 1);
  Text:SetJustifyV("MIDDLE");
  Text:SetText("Launch Aura Frame Configuration");
  
  Button:EnableMouse(true);
  Button:SetScript("OnClick", function()
    InterfaceOptionsFrame:Hide();
    HideUIPanel(GameMenuFrame);
    AuraFrames:OpenConfigDialog(); 
  end);

  InterfaceOptions_AddCategory(Panel);

end


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


--[[

  if not self.AuraFramesConfig then
  
    local Loaded, Reason = LoadAddOn("AuraFramesConfig");
    
    if not Loaded then
    
      self:Message("Failed to load the AuraFramesConfig addon because: ".._G["ADDON_"..Reason]);
      return;
    
    end
    
    self.AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
  
  end
  
  self.AuraFramesConfig:Show();
  
]]--

end


-----------------------------------------------------------------
-- Function Test
-----------------------------------------------------------------
function AuraFrames:Test()

  if not self.AuraFramesConfig then
  
    local Loaded, Reason = LoadAddOn("AuraFramesConfig");
    
    if not Loaded then
    
      self:Message("Failed to load the AuraFramesConfig addon because: ".._G["ADDON_"..Reason]);
      return;
    
    end
    
    self.AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
  
  end
  
  self.AuraFramesConfig:Show();

end
