--[[
Rule name: Boundary exception interception
Filtering stage: Request phase
Threat level: Critical
Rule description: Intercept the abnormal boundary of multipart/form data in the content type header of the request, for example, PHP did not comply with the RFC specification when uploading and parsing the boundary, resulting in incorrect parsing of commas.
--]]


-- rules/lua_rules/boundary_exception_rule.lua

function boundary_exception_rule(method, uri, headers, ip)
    if headers == nil then return false end
  
    local ct = headers["Content-Type"]
    if ct == nil then return false end
  
    -- Ensure it's a string (defensive)
    if type(ct) ~= "string" then
      return true
    end
  
    -- Normalize to lowercase
    local ct_lower = string.lower(ct)
  
    -- Check if it contains "boundary"
    if not string.find(ct_lower, "boundary") then
      return false
    end
  
    -- Count how many times "boundary" appears
    local count = 0
    for _ in string.gmatch(ct_lower, "boundary") do count = count + 1 end
  
    -- Check RFC-compliant format
    local isValid = string.match(ct_lower, "boundary=[0-9A-Za-z%-]+$")
  
    if count > 1 or not isValid then
      return true
    end
  
    return false
  end
  