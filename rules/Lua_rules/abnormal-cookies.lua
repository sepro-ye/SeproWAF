--[[
Rule name: Abnormal Cookies
Filtering stage: Request phase
Threat level: Medium
Rule description: Block outdated cookie versions with support for $Version and double quotation mark values to prevent WAF from being bypassed and to attack websites.
--]]
-- rules/lua_rules/abnormal_cookie_rule.lua

function abnormal_cookie_rule(method, uri, headers, ip)
    if headers == nil then return false end
  
    local cookie = headers["Cookie"]
    if cookie == nil then return false end
  
    -- If somehow header has multiple values, we concatenate them
    -- In real Go -> Lua flow, only the first value is passed, so this is just in case
    if type(cookie) == "table" then
      cookie = table.concat(cookie, "; ")
    end
  
    -- Check for suspicious patterns in the cookie
    if string.find(cookie, "%$Version%s*=") or string.find(cookie, '=%s*"') then
      return true
    end
  
    return false
  end
  