-- rules/lua_rules/anti_cc_rule.lua

antiCC = antiCC or {}

function anti_cc_rule(method, uri, headers, ip)
  local now = os.time()

  -- Only monitor /api/ paths
  if not string.find(string.lower(uri), "^/api/") then
    return false
  end

  local entry = antiCC[ip]

  if not entry then
    -- New IP: start tracking
    antiCC[ip] = { count = 1, start = now, banned_until = 0 }
    return false
  end

  -- Check if IP is currently banned
  if now < entry.banned_until then
    return true
  end

  -- Check if within 60-second window
  if now - entry.start <= 60 then
    entry.count = entry.count + 1
    if entry.count >= 360 then
      entry.banned_until = now + 300 -- 5-minute ban
      return true
    end
  else
    -- Reset window
    entry.count = 1
    entry.start = now
  end

  antiCC[ip] = entry
  return false
end
