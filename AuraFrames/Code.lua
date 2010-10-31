local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");


-----------------------------------------------------------------
-- Function BuildValue
-----------------------------------------------------------------
function AuraFrames:BuildValue(RequestedType, Value)

  if type(Value) == "string" then
  
    if RequestedType == "String" then
    
      local ValueText = string.gsub(Value, "\"", "\\\"");
    
      return "\""..ValueText.."\"";
    
    elseif RequestedType == "Number" then
    
      return tonumber(Value);
    
    elseif RequestedType == "Boolean" then
    
      if string.lower(Value) == "true" or string.lower(Value) == "on" or string.lower(Value) == "yes" or tonumber(Value) == 1 then
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
