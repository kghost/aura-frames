local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");


-- Import most used functions into the local namespace.
local tinsert, tremove, tconcat, sort = tinsert, tremove, table.concat, sort;
local fmt, tostring = string.format, tostring;
local select, pairs, next, type, unpack = select, pairs, next, type, unpack;
local loadstring, assert, error = loadstring, assert, error;
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget;
local GetTime = GetTime;


AuraFrames.ImportExport = {};


-----------------------------------------------------------------
-- Function Import
-----------------------------------------------------------------
function AuraFrames.ImportExport:Import(Name, Version, Config, Data)

end


-----------------------------------------------------------------
-- Function Export
-----------------------------------------------------------------
function AuraFrames.ImportExport:Export(Name, Version, Config)

end


-----------------------------------------------------------------
-- Function BuildConfigOptions
-----------------------------------------------------------------
function AuraFrames.ImportExport:BuildConfigOptions(Name, Config, NotifyFunc)

  local Options = {};


  return Options;

end

