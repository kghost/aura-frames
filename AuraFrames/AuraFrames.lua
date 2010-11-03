local AuraFrames = LibStub("AceAddon-3.0"):NewAddon("AuraFrames", "AceConsole-3.0");

-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;

-- This version will be used to trigger database upgrades
AuraFrames.DbVersion = 160;

-- Expose the addon to the global namespace for debugging.
_G["AuraFrames"] = AuraFrames;
_G["af"] = AuraFrames;

AuraFrames.ContainerHandlers = {};
AuraFrames.Containers = {};


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
  
  self:RegisterBlizzardOptions();

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


-----------------------------------------------------------------
-- Function Confirm
-----------------------------------------------------------------
function AuraFrames:Confirm(Message, Func)
  
  if not StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"] then

    StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"] = {
      button1 = "Accept",
      button2 = "Cancel",
      timeout = 0,
      whileDead = 1,
      hideOnEscape = 1,
    };
    
  end
  
  local Popup = StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"];
  Popup.text = Message;

  if Func then
    Popup.OnAccept = function()
      Func(true);
    end
  else
    Popup.OnAccept = nil;
  end
  
  if Func then
    Popup.OnCancel = function()
      Func(false);
    end
  else
    Popup.OnCancel = nil;
  end

  StaticPopup_Show("AURAFRAMESCONFIG_CONFIRM_DIALOG");

end


-----------------------------------------------------------------
-- Function Message
-----------------------------------------------------------------
function AuraFrames:Message(Message, Func)

  if not StaticPopupDialogs["AURAFRAMESCONFIG_MESSAGE_DIALOG"] then

    StaticPopupDialogs["AURAFRAMESCONFIG_MESSAGE_DIALOG"] = {
      button1 = "Okay",
      timeout = 0,
      whileDead = 1,
      hideOnEscape = 1,
    };

  end

  local Popup = StaticPopupDialogs["AURAFRAMESCONFIG_MESSAGE_DIALOG"];
  Popup.text = Message;
  Popup.button1 = "Okay";

  if Func then
    Popup.OnAccept = function()
      Func(true);
    end
  else
    Popup.OnAccept = nil;
  end

  StaticPopup_Show("AURAFRAMESCONFIG_MESSAGE_DIALOG");

end
