-- In MoP some functions are renamed, make some backwards compatibility links.

if not GetActiveTalentGroup then
  GetActiveTalentGroup = GetActiveSpecGroup;
end

if not SetActiveTalentGroup then
  SetActiveTalentGroup  = SetActiveSpecGroup;
end

if not GetNumTalentGroups then
  GetNumTalentGroups  = GetNumSpecGroups;
end

if not GetPrimaryTalentTree then
  GetPrimaryTalentTree = GetSpecialization;
end

if not GetNumPartyMembers then
  GetNumPartyMembers = GetNumSubgroupMembers;
end

if not GetNumRaidMembers then
  GetPrimaryTalentTree = GetNumGroupMembers;
end
