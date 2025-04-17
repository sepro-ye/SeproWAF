-- rules/lua_rules/brute-force-login-prevention.lua

-- Global table for IP-based rate limiting
-- rules/lua_rules/brute_force_rule.lua

-- Global table for IP-based rate limiting
bruteForceTable = bruteForceTable or {}

-- Configurable parameters
local threshold = 10           -- Max allowed attempts
local window = 180             -- Time window in seconds
local banDuration = 3600       -- Ban time in seconds

function brute_force_rule(method, uri, headers, ip)
  local now = os.time()
  local lowerUri = string.lower(uri)

  local keywords = { "login", "signin", "signup", "register", "reset", "passwd", "account", "user" }
  local matched = false

  for _, keyword in ipairs(keywords) do
    if string.find(lowerUri, keyword) then
      matched = true
      break
    end
  end

  if not matched then return false end

  -- Get or init tracking for this IP
  local info = bruteForceTable[ip] or { count = 0, first = now, bannedUntil = 0 }

  if now < info.bannedUntil then
    return true
  end

  if now - info.first > window then
    info.count = 1
    info.first = now
  else
    info.count = info.count + 1
  end

  if info.count > threshold then
    info.bannedUntil = now + banDuration
    bruteForceTable[ip] = info
    return true
  end

  bruteForceTable[ip] = info
  return false
end
