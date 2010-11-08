local AuraFrames = LibStub("AceAddon-3.0"):NewAddon("AuraFrames", "AceConsole-3.0");

-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime, StaticPopupDialogs, StaticPopup_Show = GetTime, StaticPopupDialogs, StaticPopup_Show;

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: BuffFrame, TemporaryEnchantFrame, ConsolidatedBuffs

local BuffFrame, TemporaryEnchantFrame, ConsolidatedBuffs = BuffFrame, TemporaryEnchantFrame, ConsolidatedBuffs;

-- Expose the addon to the global namespace for debugging.
_G["AuraFrames"] = AuraFrames;
_G["af"] = AuraFrames;


-----------------------------------------------------------------
-- Function OnInitialize
-----------------------------------------------------------------
function AuraFrames:OnInitialize()

end


-----------------------------------------------------------------
-- Function OnEnable
-----------------------------------------------------------------
function AuraFrames:OnEnable()

  self:DatabaseInitialize();

  self:CheckBlizzardAuraFrames();
  
  self:RegisterChatCommand("af", "OpenConfigDialog");
  
  self:RegisterBlizzardOptions();

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
function AuraFrames:CheckBlizzardAuraFrames()

  if self.db.profile.HideBlizzardAuraFrames ~= true then
    return;
  end

  -- Hide the default Blizz buff frame
  BuffFrame:Hide();
  TemporaryEnchantFrame:Hide();
  ConsolidatedBuffs:Hide();

  -- The default buff frame is still working,lets destroy
  -- it so it doesnt eat any cpu cycles anymore
  
  -- Disable the events to the default buff frame
  BuffFrame:UnregisterAllEvents(); 
  TemporaryEnchantFrame:UnregisterAllEvents();
  ConsolidatedBuffs:UnregisterAllEvents();
  
  -- Remove the OnUpdate call (shouldn't be called anyway because the frame is hidden, but just to make sure)
  BuffFrame:SetScript("OnUpdate", nil); 
  TemporaryEnchantFrame:SetScript("OnUpdate", nil);
  ConsolidatedBuffs:SetScript("OnUpdate", nil);
  
end


-----------------------------------------------------------------
-- Function Confirm
-----------------------------------------------------------------
function AuraFrames:Confirm(Message, Func, ButtonText1, ButtonText2)
  
  if not StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"] then

    StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"] = {
      timeout = 0,
      whileDead = 1,
      hideOnEscape = 1,
    };
    
  end
  
  local Popup = StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"];
  Popup.text = Message;

  Popup.button1 = ButtonText1 or "Yes";
  Popup.button2 = ButtonText2 or "No";

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
function AuraFrames:Message(Message, Func, ButtonText)

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
  
  Popup.button1 = ButtonText or "Okay";

  if Func then
    Popup.OnAccept = function()
      Func(true);
    end
  else
    Popup.OnAccept = nil;
  end

  StaticPopup_Show("AURAFRAMESCONFIG_MESSAGE_DIALOG");

end
