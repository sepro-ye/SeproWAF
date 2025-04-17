--[[
Rule name: Java Security Rule Set
Filtering stage: Request phase
Threat level: Critical
Rule description: Detecting security vulnerabilities related to Spring, Struts, Java serialization, etc
--]]

-- rules/lua_rules/java_security_rule.lua

-- Global SSTI/Java-tracking table (if you need state; here it’s stateless)
-- javaSecTable = javaSecTable or {}
function java_security_rule(method, uri, headers, ip, body)
  local text = ""
  -- combine uri, headers, body into one string for scanning
  print("🧠 Received URI: " .. tostring(uri))
  print("🧠 Received Method: " .. tostring(method))
  print("🧠 Received IP: " .. tostring(ip))
  print("🧠 Body:", body or "nil")

  text = uri
  for k, v in pairs(headers or {}) do
      text = text .. "\n" .. k .. ": " .. v
     

  end
  if body then
      text = text .. "\n" .. body
     

  end
  text = text:lower()

  -- 1) Log4Shell/JNDI lookup
  if string.find(text, "%%${jndi:") or string.find(text, "${jndi:") then
      print("MATCHED Log4Shell attack")
      return true
  end

  -- 2) Java serialization magic bytes
  if string.find(text, "aced0005") or string.find(text, "\226\128\148") then
      print("MATCHED Java serialization attack")
      return true
  end

  -- 3) Spring context RCE pattern
  if string.find(text, "[#%.]%s*context%s*%.%s*[a-z]") then
      print("MATCHED Spring context RCE")
      return true
  end

  -- 4) SSTI
  if string.find(text, "{{.+}}") then
      print("MATCHED SSTI")
      return true
  end

  return false
end
