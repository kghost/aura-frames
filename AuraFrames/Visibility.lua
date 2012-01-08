local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LibAura = LibStub("LibAura-1.0");

-----------------------------------------------------------------
-- Local status table
-----------------------------------------------------------------
local Status = {
  InCombat = false,
  OutOfCombat = false,
  PrimaryTalents = false,
  SecondaryTalents = false,
  Mounted = false,
  Vehicle = false,
  Solo = false,
  InInstance = false,
  NotInInstance = false,
  InParty = false,
  InRaid = false,
  InBattleground = false,
  InArena = false,
  FocusEqualsTarget = false,
};


-----------------------------------------------------------------
-- Local frames for handling events and updates
-----------------------------------------------------------------
local EventFrame = CreateFrame("Frame");
local UpdateFrame = CreateFrame("Frame");
UpdateFrame:Hide();


-----------------------------------------------------------------
-- Function CheckVisibility
-----------------------------------------------------------------
function AuraFrames:CheckVisibility(Container)

  if Container.Config.Visibility.AlwaysVisible == false then
  
    local Visible = false;
    
    for Key, _ in pairs(Container.Config.Visibility.VisibleWhen) do
    
      if Status[Key] == true then
        
        Visible = true;
        break;
      
      end
    
    end
  
    if Container._Visible ~= Visible then
    
      if Container._Visible ~= nil then
        Container._VisibleTransitionStart = GetTime();
        UpdateFrame:Show();
      end
    
      Container._Visible = Visible;
    
    end
  
  else
  
    Container._Visible = true;
  
  end
  
  self:UpdateVisibility(Container)

end


-----------------------------------------------------------------
-- Function UpdateVisibility
-----------------------------------------------------------------
function AuraFrames:UpdateVisibility(Container)

  if Container._Visible == nil then
    self:CheckVisibility(Container);
  end

  local Opacity = Container._Visible == true and Container.Config.Visibility.OpacityVisible or Container.Config.Visibility.OpacityNotVisible;
  
  if Container._VisibleTransitionStart then 
  
    local OpacityFrom = Container._Visible == true and Container.Config.Visibility.OpacityNotVisible or Container.Config.Visibility.OpacityVisible;
  
    local x;
  
    if Container._Visible == true and Container.Config.Visibility.FadeIn == true then
    
      x = (GetTime() - Container._VisibleTransitionStart) / Container.Config.Visibility.FadeInTime;
    
    elseif Container._Visible == false and Container.Config.Visibility.FadeOut == true then
    
      x = (GetTime() - Container._VisibleTransitionStart) / Container.Config.Visibility.FadeOutTime;
    
    end
    
    if not x or x > 1 then
      x = 1;
      Container._VisibleTransitionStart = nil;
    elseif x < 0 then
      x = 0;
    end
    
    Opacity = OpacityFrom + ((Opacity - OpacityFrom) * x);
  
  end
  
  if Opacity == 0 then
    
    if Container.Frame:IsShown() then
      Container.Frame:Hide();
    end
  
  else
  
    Container.Frame:SetAlpha(Opacity * (Container._VisibleMultiplier or 1));
    
    if not Container.Frame:IsShown() then
      Container.Frame:Show();
    end
    
  end
  
end


-----------------------------------------------------------------
-- Function ProcessStatusChanges
-----------------------------------------------------------------
local function ProcessStatusChanges(Event, Force)

  local StatusChanges = {};

  if Event == "PLAYER_ENTERING_WORLD" then
    Event = "ALL";
  end

  if Event == "ALL" or Event == "PLAYER_REGEN_ENABLED" or Event == "PLAYER_REGEN_DISABLED" then

    StatusChanges.InCombat = UnitAffectingCombat("player") == 1;
    StatusChanges.OutOfCombat = not StatusChanges.InCombat;
  
  end
  
  if Event == "ALL" or Event == "ACTIVE_TALENT_GROUP_CHANGED" then
  
    local ActiveGroup = GetActiveTalentGroup(false, false);
  
    StatusChanges.PrimaryTalents = ActiveGroup == 1;
    StatusChanges.SecondaryTalents = ActiveGroup == 2;
  
  end
  
  if Event == "ALL" or Event == "COMPANION_UPDATE" then
  
    StatusChanges.Mounted = IsMounted() == 1;
  
  end
  
  if Event == "ALL" or Event == "UNIT_ENTERED_VEHICLE" or Event == "UNIT_EXITED_VEHICLE" then
  
    StatusChanges.Vehicle = UnitInVehicle("player") == 1;
  
  end
  
  local InstanceType, NumPartyMembers, InRaid;

  if Event == "ALL" or Event == "PARTY_MEMBERS_CHANGED" then
  
    NumPartyMembers = NumPartyMembers ~= nil and NumPartyMembers or GetNumPartyMembers();
  
    StatusChanges.Solo = NumPartyMembers == 0;
  
  end
  
  if Event == "ALL" then
  
    InstanceType = InstanceType or select(2, GetInstanceInfo());
    
    StatusChanges.InInstance = InstanceType == "party" or InstanceType == "raid";
    StatusChanges.NotInInstance = not StatusChanges.InInstance;
  
  end
  
  if Event == "ALL" or Event == "PARTY_MEMBERS_CHANGED" then
  
    NumPartyMembers = NumPartyMembers ~= nil and NumPartyMembers or GetNumPartyMembers();
    InRaid = InRaid or UnitInRaid("player") ~= nil;
  
    StatusChanges.InParty = NumPartyMembers ~= 0 and InRaid == false;
    
  end
  
  if Event == "ALL" or Event == "PARTY_MEMBERS_CHANGED" then
  
    InRaid = InRaid or UnitInRaid("player") ~= nil;
  
    StatusChanges.InRaid = InRaid;
  
  end
  
  if Event == "ALL" then
  
    InstanceType = InstanceType or select(2, GetInstanceInfo());
    
    StatusChanges.InBattleground = InstanceType == "pvp";
  
  end
  
  if Event == "ALL" then
  
    InstanceType = InstanceType or select(2, GetInstanceInfo());
    
    StatusChanges.InArena = InstanceType == "arena";
  
  end
  
  if Event == "ALL" or Event == "PLAYER_FOCUS_CHANGED" or Event == "PLAYER_TARGET_CHANGED" then
  
    StatusChanges.FocusEqualsTarget = UnitIsUnit("focus", "target") == 1;
  
  end
  
  local Changed = false;
  
  for Key, Value in pairs(StatusChanges) do
  
    if Status[Key] ~= Value then
    
      Status[Key] = Value;
      
      --af:Print(Key, "changed to", Value);
      
      Changed = true;
    
    end
  
  end
  
  if not Changed and Force ~= true then
    return;
  end
  
  local CurrentTime = GetTime();
  
  for _, Container in pairs(AuraFrames.Containers) do
    
    AuraFrames:CheckVisibility(Container);
  
  end
  
end


-----------------------------------------------------------------
-- Script OnUpdate
-----------------------------------------------------------------
UpdateFrame:SetScript("OnUpdate", function()

  local Transitions = false;

  for _, Container in pairs(AuraFrames.Containers) do
    
    if Container._VisibleTransitionStart then
      AuraFrames:UpdateVisibility(Container);
      Transitions = true;
    end
  
  end
  
  if Transitions == false then
  
    UpdateFrame:Hide();
  
  end
  
end);


-----------------------------------------------------------------
-- Script OnEvent
-----------------------------------------------------------------
EventFrame:SetScript("OnEvent", function(_, Event)

  ProcessStatusChanges(Event);

end);


-----------------------------------------------------------------
-- Register Events
-----------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
EventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
EventFrame:RegisterEvent("COMPANION_UPDATE");
EventFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
EventFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
EventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
EventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
