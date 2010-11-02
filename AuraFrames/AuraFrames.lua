local AuraFrames = LibStub("AceAddon-3.0"):NewAddon("AuraFrames", "AceConsole-3.0");
local LibAura = LibStub("LibAura-1.0");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- This version will be used to trigger database upgrades
AuraFrames.DbVersion = 159;

-- Expose the addon to the global namespace for debugging.
_G["AuraFrames"] = AuraFrames;
_G["af"] = AuraFrames;

AuraFrames.ContainerHandlers = {};
AuraFrames.Containers = {};
AuraFrames.ConfigMode = false;

local ConfigDefaults = {
  profile = {
    DbVersion = 0,
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

local BlizzardOptions = {
  name = "Aura Frames",
  handler = AuraFrames,
  type = "group",
  args = {
    LaunchConfiguration = {
      type = "execute",
      name = "Launch Configuration",
      func = function()
        InterfaceOptionsFrame:Hide();
        HideUIPanel(GameMenuFrame);
        GameTooltip:Hide();
        AuraFrames:OpenConfigDialog()
      end,
    },
  },
};

-----------------------------------------------------------------
-- Function OnInitialize
-----------------------------------------------------------------
function AuraFrames:OnInitialize()

  self.db = LibStub("AceDB-3.0"):New("AuraFramesDB", ConfigDefaults);
  
  if self.db.profile.DbVersion == 0 then
    self.db.profile.DbVersion = AuraFrames.DbVersion;
  end
  
  if self.db.profile.DbVersion < AuraFrames.DbVersion then
    self:Print("Old database version found, going to automatically trying to upgrade. Cross your fingers and hope for no errors :) Have fun with the new version!");
    self:UpgradeDb();
  end
  
  if self.db.profile.HideBlizzardAuraFrames then
    self:DisableBlizzardAuraFrames();
  end
  
  self:RegisterChatCommand("af", "OpenConfigDialog");
  self:RegisterChatCommand("afreset", "ResetConfig");
  self:RegisterChatCommand("affixdb", "UpgradeDb");
  
  LibStub("AceConfig-3.0"):RegisterOptionsTable("AuraFramesBliz", function() return BlizzardOptions; end);
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AuraFramesBliz", "Aura Frames");

end


-----------------------------------------------------------------
-- Function OnEnable
-----------------------------------------------------------------
function AuraFrames:OnEnable()

  self:CreateAllContainers();

end


-----------------------------------------------------------------
-- Function OnDisable
-----------------------------------------------------------------
function AuraFrames:OnDisable()

  self:DeleteAllContainers();

end


-----------------------------------------------------------------
-- Function UpdateContainer
-----------------------------------------------------------------
function AuraFrames:UpdateContainer(Id)

  self.Containers[Id]:Update();

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
-- Function HideBlizzardAuraFrames
-----------------------------------------------------------------
function AuraFrames:DisableBlizzardAuraFrames()

  -- Hide the default Blizz buff frame
  BuffFrame:Hide();
  TemporaryEnchantFrame:Hide();

  -- The default buff frame is still working, lets destroy it so it doesnt eat any cpu cycles anymore
  
  -- Disable the events to the default buff frame
  BuffFrame:UnregisterAllEvents(); 
  TemporaryEnchantFrame:UnregisterAllEvents();
  ConsolidatedBuffs:UnregisterAllEvents();
  
  -- Remove the OnUpdate call (shouldn't be called anyway because the frame is hidden, but just to make sure)
  BuffFrame:SetScript("OnUpdate", nil); 
  TemporaryEnchantFrame:SetScript("OnUpdate", nil);
  ConsolidatedBuffs:SetScript("OnUpdate", nil);
  
  -- Make sure the buff frames are not shown.
  BuffFrame:Hide();
  TemporaryEnchantFrame:Hide();
  ConsolidatedBuffs:Hide();
  
end

