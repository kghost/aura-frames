local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-----------------------------------------------------------------
-- Version information
-----------------------------------------------------------------
AuraFrames.Version = {
  
  String   = "@project-version@",
  Revision = "@project-revision@",
  Date     = date("%m/%d/%y %H:%M:%S", tonumber("@project-timestamp@")),
  
};

if AuraFrames.Version.String == "@".."project-version".."@" then

  AuraFrames.Version.String = "SVN Repository";
  AuraFrames.Version.Revision = "SVN Repository";

end
