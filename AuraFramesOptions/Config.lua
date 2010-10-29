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
-- Function InitializeConfig
-----------------------------------------------------------------
function AuraFrames:InitializeConfig()

  LibStub("AceConfig-3.0"):RegisterOptionsTable("AuraFrames", function() return AuraFrames:GetConfigOptions(); end);
  --LibStub("AceConfigDialog-3.0"):SetDefaultSize("AuraFrames", 1100.0, 700.0);

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
  
  if select('#', ...) then
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
  
  if self.db.profile.EnableTestUnit then
    LibAura:EnableTestUnit();
  end

end


-----------------------------------------------------------------
-- Function CreateContainerConfig
-----------------------------------------------------------------
function AuraFrames:CreateContainerConfig()

  local Name, Type = NewContainerName, NewContainerType;
  
  if type(Name) ~= "string" or strlen(Name) == 0 then
    message("Not a valid container name");
    return false;
  end
  
  if not self:CreateNewContainer(Name, Type) then
    message("Failed to create a new container");
    return;
  end
  
  NewContainerName, NewContainerType = "", "";
  
  -- Refresh the config dialog and select the new created container.
  self:RefreshConfigDialog("Containers", "Container_"..Name);

end


-----------------------------------------------------------------
-- Function CopyContainerConfig
-----------------------------------------------------------------
function AuraFrames:CopyContainerConfig(Name)

  if not self.db.profile.Containers[Name] or not self.db.profile.Containers[CopySettingsFrom] then
    message("Not a valid destination or source container");
    return;
  end

  for Key, Value in pairs(AuraFrames.db.profile.Containers[CopySettingsFrom]) do
    if type(Value) == "table" and CopySettingsSelection[Key] and CopySettingsSelection[Key] == true then
      self.db.profile.Containers[Name][Key] = deepcopy(Value);
    end
  end
  
  self:DeleteContainer(Name);
  self:CreateContainer(Name);
  
  self:RefreshConfigDialog("Containers", "Container_"..Name);

end


-----------------------------------------------------------------
-- Function DeleteContainerConfig
-----------------------------------------------------------------
function AuraFrames:DeleteContainerConfig(Name)

  if not self.db.profile.Containers[Name] then
    return;
  end

  self.Containers[Name]:Delete();
  self.Containers[Name] = nil;
  self.db.profile.Containers[Name] = nil;
  
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
function AuraFrames:SetContainerEnabled(Name, Enabled)
  
  if not self.db.profile.Containers[Name] or self.db.profile.Containers[Name].Enabled == Enabled then
    return;
  end
  
  self.db.profile.Containers[Name].Enabled = Enabled;
  
  if Enabled == true then
  
    self:CreateContainer(Name);
  
  else
  
    self:DeleteContainer(Name);
  
  end
  
  self:RefreshConfigDialog("Containers", "Container_"..Name);
  
end


-----------------------------------------------------------------
-- Function SetAuraSource
-----------------------------------------------------------------
function AuraFrames:SetAuraSource(Name, Unit, Type, Enabled)

  if Enabled then
  
    if not self.db.profile.Containers[Name].Sources[Unit] then
      self.db.profile.Containers[Name].Sources[Unit] = {};
    end
        
    self.db.profile.Containers[Name].Sources[Unit][Type] = true;
    LibAura:RegisterObjectSource(self.Containers[Name], Unit, Type);

  else

    if self.db.profile.Containers[Name].Sources[Unit] then
    
      if self.db.profile.Containers[Name].Sources[Unit][Type] then
        self.db.profile.Containers[Name].Sources[Unit][Type] = nil;
      end
      
      if next(self.db.profile.Containers[Name].Sources[Unit]) == nil then
        self.db.profile.Containers[Name].Sources[Unit] = nil;
      end
      
      
    end
    
    LibAura:UnregisterObjectSource(self.Containers[Name], Unit, Type);
    
  end

end


-----------------------------------------------------------------
-- Function GetAuraSource
-----------------------------------------------------------------
function AuraFrames:GetAuraSource(Name, Unit, Type)

  return self.db.profile.Containers[Name].Sources[Unit] and self.db.profile.Containers[Name].Sources[Unit][Type];

end


-----------------------------------------------------------------
-- Function GetAuraSource
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
      Containers = {
        type = "group",
        name = "Containers",
        order = 2,
        args = {
          Header1 = {
            type = "header",
            name = "Create new containers",
            order = 1,
          },
          Name = {
            type = "input",
            name = "Container name",
            desc = "Provide a name for the new container",
            get = function(Info) return NewContainerName; end,
            set = function(Info, Value) NewContainerName = Value; end,
            pattern = "^%w+$",
            usage = "Only alphanumeric characters are allowed",
            order = 2,
          },
          Type = {
            type = "select",
            name = "Contaner type",
            desc = "The type of the new container",
            get = function(Info) return NewContainerType; end,
            set = function(Info, Value) NewContainerType = Value; end,
            values = {},
            order = 3,
          },
          Create = {
            type = "execute",
            name = "Create container",
            func = "CreateContainerConfig",
            order = 4,
          },
          Header2 = {
            type = "header",
            name = "Lock/unlock containers",
            order = 5,
          },
        },
      },
      Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    },
  };
  
  if AuraFrames.ConfigMode then
  
    Options.args.Containers.args.LeaveConfigMode = {
      type = "execute",
      name = "Lock containers",
      func = function() AuraFrames:SetConfigMode(false); end,
      order = 6,
    };
  
  else
  
    Options.args.Containers.args.EnterConfigMode = {
      type = "execute",
      name = "Unlock containers",
      func = function() AuraFrames:SetConfigMode(true); end,
      order = 6,
    };
  
  end
  
  for Type, Handler in pairs(AuraFrames.ContainerHandlers) do
    Options.args.Containers.args.Type.values[Type] = Handler:GetName();
  end
  
  for Name, Container in pairs(AuraFrames.db.profile.Containers) do
  
    if Container.Enabled == true then
  
      local SettingsToCopy = {};
      
      for Key, Value in pairs(Container) do
        if type(Value) == "table" then
          SettingsToCopy[Key] = Key;
        end
      end
      
      local CopyFrom = {};
      
      for Key, Value in pairs(AuraFrames.db.profile.Containers) do
        if Key ~= Name and Value.Type == Container.Type then
          CopyFrom[Key] = Key;
        end
      end
    
      Options.args.Containers.args["Container_"..Name] = {
        type = "group",
        name = Name .. " (" .. Container.Type .. ")",
        args = {
          ContainerEnabled = {
            type = "toggle",
            name = "Enabled Container",
            get = function(Info) return Container.Enabled; end,
            set = function(Info, Value) AuraFrames:SetContainerEnabled(Name, Value); end,
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
            func = function() AuraFrames:CopyContainerConfig(Name); end,
            confirm = true,
            confirmText = "Are you sure you want to over write the selected settings for the container "..Name,
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
            func = function() AuraFrames:DeleteContainerConfig(Name); end,
            confirm = true,
            confirmText = "Are you sure you want to delete the container "..Name,
            order = 8,
          },
          -- order 9 is for Lock/Unlock button.
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
                get = function(Info, Unit) return AuraFrames:GetAuraSource(Name, Unit, "HELPFUL"); end,
                set = function(Info, Unit, Value) AuraFrames:SetAuraSource(Name, Unit, "HELPFUL", Value); end,
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
                get = function(Info, Unit) return AuraFrames:GetAuraSource(Name, Unit, "HARMFUL"); end,
                set = function(Info, Unit, Value) AuraFrames:SetAuraSource(Name, Unit, "HARMFUL", Value); end,
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
                    get = function(Info) return AuraFrames:GetAuraSource(Name, "player", "WEAPON"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(Name, "player", "WEAPON", Value); end,
                    order = 1,
                  },
                  InternalCooldownItem = {
                    type = "toggle",
                    name = "Item Cooldowns",
                    get = function(Info) return AuraFrames:GetAuraSource(Name, "player", "INTERNALCOOLDOWNITEM"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(Name, "player", "INTERNALCOOLDOWNITEM", Value); end,
                    order = 2,
                  },
                  InternalCooldownTalents = {
                    type = "toggle",
                    name = "Talent Cooldowns",
                    get = function(Info) return AuraFrames:GetAuraSource(Name, "player", "INTERNALCOOLDOWNTALENT"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(Name, "player", "INTERNALCOOLDOWNTALENT", Value); end,
                    order = 3,
                  },
                  PlayerSpellCooldowns = {
                    type = "toggle",
                    name = "Spell Cooldowns",
                    get = function(Info) return AuraFrames:GetAuraSource(Name, "player", "SPELLCOOLDOWN"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(Name, "player", "SPELLCOOLDOWN", Value); end,
                    order = 4,
                  },
                  PetSpellCooldowns = {
                    type = "toggle",
                    name = "Spell Cooldowns (Pet)",
                    get = function(Info) return AuraFrames:GetAuraSource(Name, "pet", "SPELLCOOLDOWN"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(Name, "pet", "SPELLCOOLDOWN", Value); end,
                    order = 5,
                  },
                  PlayerTotems = {
                    type = "toggle",
                    name = "Totems",
                    get = function(Info) return AuraFrames:GetAuraSource(Name, "player", "TOTEM"); end,
                    set = function(Info, Value) AuraFrames:SetAuraSource(Name, "player", "TOTEM", Value); end,
                    order = 6,
                  },
                },
                order = 4,
              },

            },
          },
--[[
          ImportExport = {
            type = "group",
            name = "Import/Export",
            order = 2,
            args = AuraFrames.ImportExport:BuildConfigOptions("Config", Container, function() Container:Update("ALL"); end),
          },
]]--
        },
      };
      
      if AuraFrames.ConfigMode then

        Options.args.Containers.args["Container_"..Name].args.LeaveConfigMode = {
          type = "execute",
          name = "Lock containers",
          func = function() AuraFrames:SetConfigMode(false); end,
          order = 9,
        };

      else

        Options.args.Containers.args["Container_"..Name].args.EnterConfigMode = {
          type = "execute",
          name = "Unlock containers",
          func = function() AuraFrames:SetConfigMode(true); end,
          order = 9,
        };

      end
      
      local ContainerOptions = self.Containers[Name]:GetConfigOptions();
      
      for OptionName, OptionValue in pairs(ContainerOptions) do
        
        Options.args.Containers.args["Container_"..Name].args[OptionName] = OptionValue;
        Options.args.Containers.args["Container_"..Name].args[OptionName].order = 10 + Options.args.Containers.args["Container_"..Name].args[OptionName].order;
        
      end
      
    else
    
      Options.args.Containers.args["Container_"..Name] = {
        type = "group",
        name = Name,
        args = {
          ContainerEnabled = {
            type = "toggle",
            name = "Enabled",
            get = function(Info) return Container.Enabled; end,
            set = function(Info, Value) AuraFrames:SetContainerEnabled(Name, Value); end,
            order = 1,
          },
        }
      };
    
    end
  
  end

  
  return Options;

end

