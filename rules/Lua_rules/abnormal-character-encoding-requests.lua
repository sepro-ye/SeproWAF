-- rules/lua_rules/abnormal-charset.lua

function abnormal_charset_rule(method, uri, headers, ip)
    if headers == nil then
      return false
    end
  
    local rct = headers["Content-Type"]
    if rct == nil then return false end
  
    rct = string.lower(rct)
  
    if not string.find(rct, "charset") then
      return false
    end
  
    local safeCharsets = {
      "utf%-8", "gbk", "gb2312", "iso%-8859%-1", "iso%-8859%-15", "windows%-1252"
    }
  
    -- Check if rct matches any safe charset
    local safe = false
    for _, pattern in ipairs(safeCharsets) do
      if string.find(rct, "charset%s*=%s*" .. pattern) then
        safe = true
        break
      end
    end
  
    -- Count how many times "charset" appears
    local count = 0
    for _ in string.gmatch(rct, "charset") do count = count + 1 end
  
    -- If charset is unsafe or repeated
    if not safe or count > 1 then
      return true
    end
  
    return false
  end
  