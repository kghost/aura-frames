local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LibAura = LibStub("LibAura-1.0");

local NewContainerName = nil;
local NewContainerType = nil;

local CopySettingsFrom = nil;
local CopySettingsSelection = {};

-----------------------------------------------------------------
-- Function deepcopy
-----------------------------------------------------------------
function deepcopy(object)
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
-- Function ConfirmPopup
-----------------------------------------------------------------
function AuraFrames:ConfirmPopup(Message, Func)
  
  if not StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"] then
    StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"] = {};
  end
  
  local Popup = StaticPopupDialogs["AURAFRAMESCONFIG_CONFIRM_DIALOG"];
  Popup.text = Message;
  Popup.button1 = "Accept";
  Popup.button2 = "Cancel";

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

  Popup.timeout = 0;
  Popup.whileDead = 1;
  Popup.hideOnEscape = 1;

  StaticPopup_Show("AURAFRAMESCONFIG_CONFIRM_DIALOG");

end


-----------------------------------------------------------------
-- Function MessagePopup
-----------------------------------------------------------------
function AuraFrames:MessagePopup(Message, Func)

  if not StaticPopupDialogs["AURAFRAMESCONFIG_MESSAGE_DIALOG"] then
    StaticPopupDialogs["AURAFRAMESCONFIG_MESSAGE_DIALOG"] = {};
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

  Popup.timeout = 0;
  Popup.whileDead = 1;
  Popup.hideOnEscape = 1;

  StaticPopup_Show("AURAFRAMESCONFIG_MESSAGE_DIALOG");

end


-----------------------------------------------------------------
-- Function InitializeConfig
-----------------------------------------------------------------
function AuraFrames:InitializeConfig()

  LibStub("AceConfig-3.0"):RegisterOptionsTable("AuraFrames", function() return AuraFrames:GetConfigOptions(); end);

  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig");
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig");
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig");
  self.db.RegisterCallback(self, "OnDatabaseShutdown", function() AuraFrames:SetConfigMode(false); end);

end


-----------------------------------------------------------------
-- Function RefreshConfigDialog
-----------------------------------------------------------------
function AuraFrames:RefreshConfigDialog(...)

  LibStub("AceConfigRegistry-3.0"):NotifyChange("AuraFrames");
  
  if select('#', ...) > 0 then
    LibStub("AceConfigDialog-3.0"):SelectGroup("AuraFrames", ...);
  end

end


-----------------------------------------------------------------
-- Function RefreshConfig
-----------------------------------------------------------------
function AuraFrames:RefreshConfig()

  self:DeleteAllContainers();
  
  -- We can be called because of a profile copy, this means that we can get a profile with an old db version.
  if self.db.profile.DbVersion < AuraFrames.DbVersion then
    self:UpgradeDb();
  end
  
  self:CreateAllContainers();
  
  if self.db.profile.HideBlizzardAuraFrames then
    self:DisableBlizzardAuraFrames();
  end

end


-----------------------------------------------------------------
-- Function CopyContainerConfig
-----------------------------------------------------------------
function AuraFrames:CopyContainerConfig(Id)

  if not self.db.profile.Containers[Id] or not self.db.profile.Containers[CopySettingsFrom] then
    AuraFrames:MessagePopup("Not a valid destination or source container");
    return;
  end

  for Key, Value in pairs(AuraFrames.db.profile.Containers[CopySettingsFrom]) do
    if type(Value) == "table" and CopySettingsSelection[Key] and CopySettingsSelection[Key] == true then
      self.db.profile.Containers[Id][Key] = deepcopy(Value);
    end
  end
  
  self:DeleteContainer(Id);
  self:CreateContainer(Id);
  
  self:RefreshConfigDialog("Containers", "Container_"..Id);

end


-----------------------------------------------------------------
-- Function DeleteContainerConfig
-----------------------------------------------------------------
function AuraFrames:DeleteContainerConfig(Id)

  if not self.db.profile.Containers[Id] then
    return;
  end

  self.Containers[Id]:Delete();
  self.Containers[Id] = nil;
  self.db.profile.Containers[Id] = nil;
  
  self:RefreshConfigDialog("Containers");

end


-----------------------------------------------------------------
-- Function SetConfigMode
-----------------------------------------------------------------
function AuraFrames:SetConfigMode(Mode)
  
  self.ConfigMode = Mode;
  
  for _, Container in pairs(self.Containers) do
  
    Container:SetConfigMode(Mode);
  
  end
  
  if Mode == true then
  
    self:ShowUnlockDialog();
    self:RefreshConfigDialog();
    LibStub("AceConfigDialog-3.0"):Close("AuraFrames");
    GameTooltip:Hide();
  
  else
  
    if self.UnlockDialog then
      self.UnlockDialog:Hide();
    end
    
    self:RefreshConfigDialog();
    LibStub("AceConfigDialog-3.0"):Open("AuraFrames");
  
  end
  

end


-----------------------------------------------------------------
-- Function SetContainerEnabled
-----------------------------------------------------------------
function AuraFrames:SetContainerEnabled(Id, Enabled)
  
  if not self.db.profile.Containers[Id] or self.db.profile.Containers[Id].Enabled == Enabled then
    return;
  end
  
  self.db.profile.Containers[Id].Enabled = Enabled;
  
  if Enabled == true then
  
    self:CreateContainer(Id);
  
  else
  
    self:DeleteContainer(Id);
  
  end
  
  self:RefreshConfigDialog("Containers", "Container_"..Id);
  
end


-----------------------------------------------------------------
-- Function SetAuraSource
-----------------------------------------------------------------
function AuraFrames:SetAuraSource(Id, Unit, Type, Enabled)

  if Enabled then
  
    if not self.db.profile.Containers[Id].Sources[Unit] then
      self.db.profile.Containers[Id].Sources[Unit] = {};
    end
        
    self.db.profile.Containers[Id].Sources[Unit][Type] = true;
    LibAura:RegisterObjectSource(self.Containers[Id], Unit, Type);

  else

    if self.db.profile.Containers[Id].Sources[Unit] then
    
      if self.db.profile.Containers[Id].Sources[Unit][Type] then
        self.db.profile.Containers[Id].Sources[Unit][Type] = nil;
      end
      
      if next(self.db.profile.Containers[Id].Sources[Unit]) == nil then
        self.db.profile.Containers[Id].Sources[Unit] = nil;
      end
      
      
    end
    
    LibAura:UnregisterObjectSource(self.Containers[Id], Unit, Type);
    
  end

end


-----------------------------------------------------------------
-- Function GetAuraSource
-----------------------------------------------------------------
function AuraFrames:GetAuraSource(Id, Unit, Type)

  return self.db.profile.Containers[Id].Sources[Unit] and self.db.profile.Containers[Id].Sources[Unit][Type];

end


-----------------------------------------------------------------
-- Function ShowUnlockDialog
-----------------------------------------------------------------
function AuraFrames:ShowUnlockDialog()

  if not self.UnlockDialog then
    local f = CreateFrame("Frame", "AuraFramesUnlockDialog", UIParent)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:SetWidth(360)
    f:SetHeight(110)
    f:SetBackdrop{
      bgFile="Interface\\DialogFrame\\UI-DialogBox-Background" ,
      edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      insets = {left = 11, right = 12, top = 12, bottom = 11},
      tileSize = 32,
      edgeSize = 32,
    }
    f:SetPoint("TOP", 0, -50)
    f:Hide()
    f:SetScript("OnShow", function() PlaySound("igMainMenuOption") end)
    f:SetScript("OnHide", function() PlaySound("gsTitleOptionExit") end)

    local tr = f:CreateTitleRegion()
    tr:SetAllPoints(f)

    local header = f:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetWidth(256); header:SetHeight(64)
    header:SetPoint("TOP", 0, 12)

    local title = f:CreateFontString("ARTWORK")
    title:SetFontObject("GameFontNormal")
    title:SetPoint("TOP", header, "TOP", 0, -14)
    title:SetText("Aura Frames")

    local desc = f:CreateFontString("ARTWORK")
    desc:SetFontObject("GameFontHighlight")
    desc:SetJustifyV("TOP")
    desc:SetJustifyH("LEFT")
    desc:SetPoint("TOPLEFT", 18, -32)
    desc:SetPoint("BOTTOMRIGHT", -18, 48)
    desc:SetText("Containers unlocked. Move them now and click Lock when you are done.")

    local lockBars = CreateFrame("CheckButton", "AuraFramesUnlockDialogLock", f, "OptionsButtonTemplate")
    getglobal(lockBars:GetName() .. "Text"):SetText("Lock")

    lockBars:SetScript("OnClick", function(self)
      AuraFrames:SetConfigMode(false);
    end)

    --position buttons
    lockBars:SetPoint("BOTTOMRIGHT", -14, 14)

    self.UnlockDialog = f
  end
  
  self.UnlockDialog:Show()
  
end

-----------------------------------------------------------------
-- Function GetConfigOptions
-----------------------------------------------------------------
function AuraFrames:GetConfigOptions()

  local Options = {
    name = "Aura Frames",
    handler = AuraFrames,
    type = "group",
    args = {
      General = {
        type = "group",
        name = "General",
        order = 1,
        args = {
          HideBlizzardAuraFrames = {
            type = "toggle",
            name = "Hide Blizz buff frames",
            desc = "Disable and hide the default frames that are used by Blizzard to display buff/debuff aura's. When you enable the Blizzard frames again you need to reload/relog to show them!",
            get = function(Info) return self.db.profile.HideBlizzardAuraFrames; end,
            set = function(Info, Value) self.db.profile.HideBlizzardAuraFrames = Value; if Value then self:DisableBlizzardAuraFrames(); end; end,
            order = 1,
          },
          Sep = {
            type = "description",
            name = "",
            fontSize = "medium",
            order = 2,
          },
          Header = {
            type = "header",
            name = "Credits",
            order = 3,
          },
          Credits = {
            type = "description",
            name = "\nThis addon is developed and mainted by Nexiuz (Beautiuz) @ Bloodhoof EU.\n\nSome code are based on other addons, the two most imported addons that helped me and inspired me are SatrinaBuffFrame and LibBuffet.\n\nSpecial thanks goes to Ripsomeone @ Bloodhoof EU for testing and helping me giving the addon his current form.",
            fontSize = "medium",
            order = 4,
          },
        },
      },
--[[
      ContainerDefaults = {
        type = "group",
        name = "Container Defaults",
        order = 2,
        args = {
          Info = {
            type = "description",
            name = "Container defaults are used for setting the default configuration for a container type.",
            fontSize = "medium",
            order = 1,
          },
        },
      },
]]--
      Containers = {
        type = "group",
        name = "Containers",
        order = 3,
        args = {
          ContainerInfo = {
            type = "description",
            name = "Containers are used for grouping aura's together. There are different kind of containers, every type with there own ways of displaying aura's. Click the button below to create a new container:\n\n",
            fontSize = "medium",
            order = 1,
          },
          Create = {
            type = "execute",
            name = "Create container",
            func = function()
              LibStub("AceConfigDialog-3.0"):Close("AuraFrames");
              -- AceConfigDialog is forgetting to close the game tooltip :(
              GameTooltip:Hide();
              AuraFrames:ShowCreateContainerWizard();
            end,
            order = 2,
          },
          Space1 = {
            type = "description",
            name = "\n",
            order = 3,
          },
          Header2 = {
            type = "header",
            name = "Move containers",
            order = 4,
          },
          MoveInfo = {
            type = "description",
            name = "Containers can only be moved when they are unlocked. Unlock/lock the containers by using the button below:\n\n",
            fontSize = "medium",
            order = 5,
          },
          ConfigMode = {
            type = "execute",
            name = AuraFrames.ConfigMode and "Lock containers" or "Unlock containers",
            func = function() AuraFrames:SetConfigMode(not AuraFrames.ConfigMode); end,
            order = 6,
          },
        },
      },
      Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    },
  };

  for ContainerId, Container in pairs(AuraFrames.db.profile.Containers) do
  
    if Container.Enabled == true then
  
      local SettingsToCopy = {};
      
      for Key, Value in pairs(Container) do
        if type(Value) == "table" then
          SettingsToCopy[Key] = Key;
        end
      end
      
      local CopyFrom = {};
      
      for Key, Value in pairs(AuraFrames.db.profile.Containers) do
        if Key ~= ContainerId and Value.Type == Container.Type then
          CopyFrom[Key] = Key;
        end
      end
    
      Options.args.Containers.args["Container_"..ContainerId] = {
        type = "group",
        name = Container.Name .. " (" .. Container.Type .. ")",
        args = {
          ContainerEnabled = {
            type = "toggle",
            name = "Container Enabled",
            get = function(Info) return Container.Enabled; end,
            set = function(Info, Value) AuraFrames:SetContainerEnabled(ContainerId, Value); end,
            order = 1,
          },
          HeaderCopy = {
            type = "header",
            name = "Copy Settings",
            order = 2,
          },
          CopyDescription = {
            type = "description",
            name = "You can only copy settings from the same type of container.",
            order = 3,
          },
          CopySelection = {
            type = "multiselect",
            name = "Settings to copy",
            values = SettingsToCopy,
            get = function(Info, Setting) return CopySettingsSelection[Setting]; end,
            set = function(Info, Setting, Value) CopySettingsSelection[Setting] = Value; end,
            order = 4,
          },
          CopyFrom = {
            type = "select",
            name = "Copy From",
            values = CopyFrom,
            get = function(Info) return CopySettingsFrom; end,
            set = function(Info, Value) CopySettingsFrom = Value; end,
            order = 5,
          },
          CopySettings = {
            type = "execute",
            name = "Copy settings",
            func = function() AuraFrames:CopyContainerConfig(ContainerId); end,
            confirm = true,
            confirmText = "Are you sure you want to over write the selected settings for the container "..Container.Name,
            order = 6,
          },
          HeaderMisc = {
            type = "header",
            name = "Miscellaneous",
            order = 7,
          },
          Delete = {
            type = "execute",
            name = "Delete this container",
            func = function() AuraFrames:DeleteContainerConfig(ContainerId); end,
            confirm = true,
            confirmText = "Are you sure you want to delete the container "..Container.Name,
            order = 8,
          },
          ConfigMode = {
            type = "execute",
            name = AuraFrames.ConfigMode and "Lock containers" or "Unlock containers",
            func = function() AuraFrames:SetConfigMode(not AuraFrames.ConfigMode); end,
            order = 9,
          },
          Sources = {
            type = "group",
            name = "Sources",
            order = 1,
            args = {

              HeaderSources = {
                type = "header",
                name = "Current Sources",
                order = 1,
              },
              HelpfulUnits = {
                type = "multiselect",
                name = "Monitor helpful buffs on the following units",
                values = {
                  player = "Player",
                  target = "Target",
                  targettarget = "Target's Target",
                  focus = "Focus",
                  focustarget = "Focus Target",
                  pet = "Pet",
                  pettarget = "Pet Target",
                  vehicle = "Vehicle",
                  vehicletarget = "Vehicle Target",
                  mouseover = "Mouseover",
                  test = "Test",
                },
                get = function(Info, Unit) return AuraFrames:GetAuraSource(ContainerId, Unit, "HELPFUL"); end,
                set = function(Info, Unit, Value) AuraFrames:SetAuraSource(ContainerId, Unit, "HELPFUL", Value); end,
                order = 2,
              },
              HarmfulUnits = {
                type = "multiselect",
                name = "Monitor harmful debuffs on the following units",
                values = {
                  player = "Player",
                  target = "Target",
                  targettarget = "Target's Target",
                  focus = "Focus",
                  focustarget = "Focus Target",
                  pet = "Pet",
                  pettarget = "Pet Target",
                  vehicle = "Vehicle",
                  vehicletarget = "Vehicle Target",
                  mouseover = "Mouseover",
                  test = "Test",
                },
                get = function(Info, Unit) return AuraFrames:GetAuraSource(ContainerId, Unit, "HARMFUL"); end,
                set = function(Info, Unit, Value) AuraFrames:SetAuraSource(ContainerId, Unit, "HARMFUL", Value); end,
                order = 3,
              },
              Misc = {
                type = "group",
                inline = true,
                name = "Miscellaneous",
                args = {
                  PlayerWeapons = {
                    type = "toggle",
                    name = "Weapon Enchantments",
                    get = function(Info) return AuraFrames:GetAuraSource(ContainerId, "player", "WEAPON"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(ContainerId, "player", "WEAPON", Value); end,
                    order = 1,
                  },
--[[
                  InternalCooldownItem = {
                    type = "toggle",
                    name = "Item Cooldowns",
                    get = function(Info) return AuraFrames:GetAuraSource(ContainerId, "player", "INTERNALCOOLDOWNITEM"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(ContainerId, "player", "INTERNALCOOLDOWNITEM", Value); end,
                    order = 2,
                  },
                  InternalCooldownTalents = {
                    type = "toggle",
                    name = "Talent Cooldowns",
                    get = function(Info) return AuraFrames:GetAuraSource(ContainerId, "player", "INTERNALCOOLDOWNTALENT"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(ContainerId "player", "INTERNALCOOLDOWNTALENT", Value); end,
                    order = 3,
                  },
]]--
                  PlayerSpellCooldowns = {
                    type = "toggle",
                    name = "Spell Cooldowns (Player)",
                    get = function(Info) return AuraFrames:GetAuraSource(ContainerId, "player", "SPELLCOOLDOWN"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(ContainerId, "player", "SPELLCOOLDOWN", Value); end,
                    order = 4,
                  },
                  PetSpellCooldowns = {
                    type = "toggle",
                    name = "Spell Cooldowns (Pet)",
                    get = function(Info) return AuraFrames:GetAuraSource(ContainerId, "pet", "SPELLCOOLDOWN"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(ContainerId, "pet", "SPELLCOOLDOWN", Value); end,
                    order = 5,
                  },
                  PlayerTotems = {
                    type = "toggle",
                    name = "Totems",
                    get = function(Info) return AuraFrames:GetAuraSource(ContainerId, "player", "TOTEM"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(ContainerId, "player", "TOTEM", Value); end,
                    order = 6,
                  },
                },
                order = 4,
              },

            },
          },
        },
      };
      
      local ContainerOptions = self.Containers[ContainerId]:GetConfigOptions();
      
      for OptionName, OptionValue in pairs(ContainerOptions) do
        
        Options.args.Containers.args["Container_"..ContainerId].args[OptionName] = OptionValue;
        Options.args.Containers.args["Container_"..ContainerId].args[OptionName].order = 10 + Options.args.Containers.args["Container_"..ContainerId].args[OptionName].order;
        
      end
      
    else
    
      Options.args.Containers.args["Container_"..ContainerId] = {
        type = "group",
        name = Container.Name,
        args = {
          ContainerEnabled = {
            type = "toggle",
            name = "Container Enabled",
            get = function(Info) return Container.Enabled; end,
            set = function(Info, Value) AuraFrames:SetContainerEnabled(ContainerId, Value); end,
            order = 1,
          },
        }
      };
    
    end
  
  end
  
--[[
  
  for ModuleId, Module in pairs(AuraFrames.ContainerHandlers) do
  
    Options.args.ContainerDefaults.args["Module_"..ModuleId] = {
      type = "group",
      name = Module:GetName(),
      args = {
        Temp = {
          type = "toggle",
          name = "Container Enabled",
          get = function(Info) end,
          set = function(Info, Value) end,
          order = 1,
        },
      },
    };
  
  end
  
]]--
  
  return Options;

end
