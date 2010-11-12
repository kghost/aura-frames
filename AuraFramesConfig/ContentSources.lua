local AuraFramesConfig = LibStub("AceAddon-3.0"):GetAddon("AuraFramesConfig");
local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local AceGUI = LibStub("AceGUI-3.0");
local LibAura = LibStub("LibAura-1.0");

local ExpertMode = false;

local SimpleSourcelist = {
  player = {
    HELPFUL = true,
    HARMFUL = true,
    WEAPON = true,
  },
  target = {
    HELPFUL = true,
    HARMFUL = true,
  },
  test = {
    HELPFUL = true,
    HARMFUL = true,
  },
};

local SimpleSources = {
  {
    Name = "|cff6af36aBuffs|r on yourself",
    Unit = "player",
    Type = "HELPFUL",
  },
  {
    Name = "|cfff36a6aDebuffs|r on yourself",
    Unit = "player",
    Type = "HARMFUL",
  },
  {
    Name = "|cff6af36aBuffs|r on your target",
    Unit = "target",
    Type = "HELPFUL",
  },
  {
    Name = "|cfff36a6aDebuffs|r on your target",
    Unit = "target",
    Type = "HARMFUL",
  },
  {
    Name = "Your own weapon enchantments",
    Unit = "player",
    Type = "WEAPON",
  },
  {
    Space = true,
    Rows = 2,
  },
  {
    Text = "For testing purpose, you can enable temporarily the test sources which will generate fake aura's so you can test the layout of a container.",
  },
  {
    Space = true,
  },
  {
    Name = "Test buffs",
    Unit = "test",
    Type = "HELPFUL",
  },
  {
    Name = "Test debuffs",
    Unit = "test",
    Type = "HARMFUL",
  },
};


local AllSources = {
  {
    Group = true,
    Title = "|cff6af36aHelpful buffs|r",
    Width = 175,
    Childeren = {
      {
        Name = "Player",
        Unit = "player",
        Type = "HELPFUL",
      },
      {
        Name = "Target",
        Unit = "target",
        Type = "HELPFUL",
      },
      {
        Name = "Target's Target",
        Unit = "targettarget",
        Type = "HELPFUL",
      },
      {
        Name = "Focus",
        Unit = "focus",
        Type = "HELPFUL",
      },
      {
        Name = "Focus Target",
        Unit = "focustarget",
        Type = "HELPFUL",
      },
      {
        Name = "Pet",
        Unit = "pet",
        Type = "HELPFUL",
      },
      {
        Name = "Pet Target",
        Unit = "pettarget",
        Type = "HELPFUL",
      },
      {
        Name = "Vehicle",
        Unit = "vehicle",
        Type = "HELPFUL",
      },
      {
        Name = "Vehicle Target",
        Unit = "vehicletarget",
        Type = "HELPFUL",
      },
      {
        Name = "Mouseover",
        Unit = "mouseover",
        Type = "HELPFUL",
      },
      {
        Name = "Test",
        Unit = "test",
        Type = "HELPFUL",
      },
    },
  },
  {
    Space = true,
  },
  {
    Group = true,
    Title = "|cfff36a6aHarmful debuffs|r",
    Width = 175,
    Childeren = {
      {
        Name = "Player",
        Unit = "player",
        Type = "HARMFUL",
      },
      {
        Name = "Target",
        Unit = "target",
        Type = "HARMFUL",
      },
      {
        Name = "Target's Target",
        Unit = "targettarget",
        Type = "HARMFUL",
      },
      {
        Name = "Focus",
        Unit = "focus",
        Type = "HARMFUL",
      },
      {
        Name = "Focus Target",
        Unit = "focustarget",
        Type = "HARMFUL",
      },
      {
        Name = "Pet",
        Unit = "pet",
        Type = "HARMFUL",
      },
      {
        Name = "Pet Target",
        Unit = "pettarget",
        Type = "HARMFUL",
      },
      {
        Name = "Vehicle",
        Unit = "vehicle",
        Type = "HARMFUL",
      },
      {
        Name = "Vehicle Target",
        Unit = "vehicletarget",
        Type = "HARMFUL",
      },
      {
        Name = "Mouseover",
        Unit = "mouseover",
        Type = "HARMFUL",
      },
      {
        Name = "Test",
        Unit = "test",
        Type = "HARMFUL",
      },
    }
  },
  {
    Space = true,
  },
  {
    Group = true,
    Title = "|cffffffffMiscellaneous|r",
    Width = 262,
    Childeren = {
      {
        Name = "Weapon Enchantments",
        Unit = "player",
        Type = "WEAPON",
      },
      {
        Name = "Spell Cooldowns (Player)",
        Unit = "player",
        Type = "SPELLCOOLDOWN",
      },
      {
        Name = "Spell Cooldowns (Pet)",
        Unit = "pet",
        Type = "SPELLCOOLDOWN",
      },
      {
        Name = "Totems",
        Unit = "player",
        Type = "TOTEM",
      },
    }
  },
};


-----------------------------------------------------------------
-- Local Function BuildOptions
-----------------------------------------------------------------
local function BuildOptions(Content, ContainerId, Options, Width)

  local SourceConfig = AuraFrames.db.profile.Containers[ContainerId].Sources;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  for _, Item in pairs(Options) do
  
    if Item.Space and Item.Space == true then
    
      Content:AddSpace(Item.Rows or 1);
    
    elseif Item.Text then
    
      Content:AddText(Item.Text);
      
    elseif Item.Group and Item.Group == true then
    
      local Group = AceGUI:Create("InlineGroup");
      Group:SetTitle(Item.Title or "");
      Group:SetRelativeWidth(1);
      Group:SetLayout("Flow");
      Content:AddChild(Group);
      
      BuildOptions(Group, ContainerId, Item.Childeren or {}, Item.Width);
    
    else
  
      local CheckBoxSource = AceGUI:Create("CheckBox");
      if not Width or Width == 0 then
        CheckBoxSource:SetRelativeWidth(1);
      else
        CheckBoxSource:SetWidth(Width);
      end
      CheckBoxSource:SetLabel(Item.Name);
      CheckBoxSource:SetValue(SourceConfig[Item.Unit] and SourceConfig[Item.Unit][Item.Type] and (SourceConfig[Item.Unit][Item.Type] == true));
      CheckBoxSource:SetCallback("OnValueChanged", function(_, _, Value)
      
        if Value == true then
        
          if not SourceConfig[Item.Unit] then
            SourceConfig[Item.Unit] = {};
          end
        
          SourceConfig[Item.Unit][Item.Type] = true;
          LibAura:RegisterObjectSource(ContainerInstance, Item.Unit, Item.Type);
        
        else
        
          if not SourceConfig[Item.Unit] then
            return;
          end
          
          SourceConfig[Item.Unit][Item.Type] = nil;
          LibAura:UnregisterObjectSource(ContainerInstance, Item.Unit, Item.Type);
          
          if next(SourceConfig[Item.Unit]) == nil then
            SourceConfig[Item.Unit] = nil;
          end
        
        end
      
      end);
      Content:AddChild(CheckBoxSource);
    
    end
  
  end

end


-----------------------------------------------------------------
-- Function ContentSourcesRefresh
-----------------------------------------------------------------
function AuraFramesConfig:ContentSourcesRefresh(Content, ContainerId)

  local SourceConfig = AuraFrames.db.profile.Containers[ContainerId].Sources;
  local ContainerInstance = AuraFrames.Containers[ContainerId];

  Content:PauseLayout();
  Content:ReleaseChildren();
  
  Content:SetLayout("List");
  
  Content:AddText("Sources\n", GameFontNormalLarge);
  
  Content:AddText("Every container can have different aura's, on this page you can configure what kind of of aura's are available for this container.");
  Content:AddSpace();
  
  if ExpertMode then
  
    BuildOptions(Content, ContainerId, AllSources);
  
  else
  
    BuildOptions(Content, ContainerId, SimpleSources);
  
  end
  
  Content:AddSpace();
  Content:AddHeader("Expert mode");
  Content:AddText("There are way more sources available, but those are lesser commen and aren't used a lot. Enable the expert mode to see all posible sources.\n");
  
  local CheckBoxExpertMode = AceGUI:Create("CheckBox");
  CheckBoxExpertMode:SetRelativeWidth(1);
  CheckBoxExpertMode:SetLabel("Enable expert mode");
  CheckBoxExpertMode:SetValue(ExpertMode);
  CheckBoxExpertMode:SetCallback("OnValueChanged", function(_, _, Value)
    ExpertMode = Value;
    
    if ExpertMode == false then
    
      -- Remove all sources that are not in the simple list.
      
      for Unit, List in pairs(SourceConfig) do
      
        for Type, Value in pairs(List) do
        
          if not SimpleSourcelist[Unit] or not SimpleSourcelist[Unit][Type] or SimpleSourcelist[Unit][Type] ~= true then
          
            SourceConfig[Unit][Type] = nil;
            LibAura:UnregisterObjectSource(ContainerInstance, Unit, Type);
          
          end
          
          if next(SourceConfig[Unit]) == nil then
            SourceConfig[Unit] = nil;
          end
        
        end
      
      end
    
    end
    
    AuraFramesConfig:ContentSourcesRefresh(Content, ContainerId);
  end);
  Content:AddChild(CheckBoxExpertMode);

  Content:ResumeLayout();
  Content:DoLayout();

end


-----------------------------------------------------------------
-- Function ContentSources
-----------------------------------------------------------------
function AuraFramesConfig:ContentSources(ContainerId)

  ExpertMode = false;
  
  local SourceConfig = AuraFrames.db.profile.Containers[ContainerId].Sources;
  
  -- See if we have sources outside the simple list, if so
  -- then directly activate the expert mode.
  
  for Unit, List in pairs(SourceConfig) do
  
    for Type, Value in pairs(List) do
    
      if not SimpleSourcelist[Unit] or not SimpleSourcelist[Unit][Type] or SimpleSourcelist[Unit][Type] ~= true then
      
        ExpertMode = true;
        break;
      
      end
    
    end
    
    -- If we found a mismatch then break.
    if ExpertMode == true then
      break;
    end
    
  end

  self.Content:SetLayout("Fill");
  
  local Content = AceGUI:Create("ScrollFrame");
  Content:SetLayout("List");
  self:EnhanceContainer(Content);
  self.Content:AddChild(Content);
  
  self:ContentSourcesRefresh(Content, ContainerId);

end
