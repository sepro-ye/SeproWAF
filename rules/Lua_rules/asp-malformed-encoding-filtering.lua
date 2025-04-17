--[[
Rule name: ASP malformed encoding filtering
Filtering stage: Request phase
Threat level: Critical
Rule description: Abnormal encoding of Unicode in ASP can cause WAF bypass hazards
--]]

-- rules/lua_rules/asp_unicode_bypass_rule.lua

function asp_unicode_bypass_rule(method, uri, headers, ip)
   -- Convert URI to lowercase for case-insensitive match
   local lowerUri = string.lower(uri)
 
   -- Lua pattern for %u00 followed by dangerous sequences
   local pattern = "%%u00(aa|ba|d0|de|e2|f0|fe)"
 
   if string.find(lowerUri, pattern) then
     return true
   end
 
   return false
 end
 