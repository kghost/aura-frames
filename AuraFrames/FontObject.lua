local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");
local LSM = LibStub("LibSharedMedia-3.0");

-----------------------------------------------------------------
-- Function SetFontObjectProperties
-----------------------------------------------------------------
function AuraFrames:SetFontObjectProperties(FontObject, Font, Size, Outline, Monochrome, Color)

  local Flags;

  if Outline ~= "NONE" then
    Flags = Outline;
  end

  if Monochrome == true then
    Flags = (Flags ~= nil and (Flags .. ",") or "") .. "MONOCHROME";
  end
  
  FontObject:SetFont(LSM:Fetch("font", Font), Size, Flags);
  
  if Color then
    FontObject:SetTextColor(unpack(Color));
  end

end


-----------------------------------------------------------------
-- Function SetFontObjectPropertyList
-----------------------------------------------------------------
function AuraFrames:SetFontObjectPropertyList(FontObject, Properties)

  return self:SetFontObjectProperties(FontObject, Properties.Font, Properties.Size, Properties.Outline, Properties.Monochrome, Properties.Color);

end
