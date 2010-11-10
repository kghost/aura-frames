local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-- Import used global references into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, ipairs, next, type, unpack = select, pairs, ipairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;
local tolower, toupper, tonumber, gsub = string.lower, string.upper, tonumber, string.gsub;


-----------------------------------------------------------------
-- Function BuildValue
-----------------------------------------------------------------
function AuraFrames:BuildValue(RequestedType, Value)

  if type(Value) == "string" then
  
    if RequestedType == "String" or RequestedType == "SpellName" then
    
      local ValueText = gsub(Value, "\"", "\\\"");
    
      return "\""..ValueText.."\"";
    
    elseif RequestedType == "Number" or RequestedType == "SpellId" then
    
      return tonumber(Value);
    
    elseif RequestedType == "Boolean" then
    
      if tolower(Value) == "true" or tolower(Value) == "on" or tolower(Value) == "yes" or tonumber(Value) == 1 then
        return "true";
      else
        return "false";
      end
    
    else
    
      AuraFrames:Print("BuildValue: Unsupported value for requested type "..RequestedType);
      return nil;
    
    end
  
  elseif type(Value) == "number" then
  
    if RequestedType == "String" or RequestedType == "SpellName" then
    
      return "\""..tostring(Value).."\"";
    
    elseif RequestedType == "Number" or RequestedType == "SpellId" then
    
      return tonumber(Value);
    
    elseif RequestedType == "Boolean" then
    
      if Value == 1 then
        return "true";
      else
        return "false";
      end
    
    else
    
      AuraFrames:Print("BuildValue: Unsupported value for requested type "..RequestedType);
      return nil;
    
    end
  
  elseif type(Value) == "boolean" then

    if RequestedType == "String" or RequestedType == "SpellName" then
    
      return "\""..tostring(Value).."\"";
    
    elseif RequestedType == "Number" or RequestedType == "SpellId" then
    
      if Value == true then
        return 1;
      else
        return 0;
      end
    
    elseif RequestedType == "Boolean" then
    
      return Value;
    
    else
    
      AuraFrames:Print("BuildValue: Unsupported value for requested type "..RequestedType);
      return nil;
    
    end
  
  elseif type(Value) == "function" then
  
    if RequestedType == "String" or RequestedType == "SpellName" then
    
      return "\"tostring("..Value.."())\"";
    
    elseif RequestedType == "Number" or RequestedType == "SpellId" then
    
      return "\"tonumber("..Value.."())\"";
    
    elseif RequestedType == "Boolean" then
    
      return "(tContains({\"true\", \"on\", \"yes\", \"1\"}, string.lower("..Value.."())) == true)";
    
    else
    
      AuraFrames:Print("BuildValue: Unsupported value for requested type "..RequestedType);
      return nil;
    
    end
  
  else
  
    AuraFrames:Print("BuildValue: Unsupported value for any type");
    return nil;
  
  end

end
