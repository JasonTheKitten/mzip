local function getChars(s)
  local c = {}
  local i = 1
  while i <= #s do
    local char = string.sub(s, i, i)
    if not c[char] then c[char] = 0 end
    c[char] = c[char] + 1
    i = i + 1
  end
  return c
end

local function getFreq(tC)
  local f = {}
  local groups = {}
  for k, v in pairs(tC) do
    if not groups[v] then groups[v] = {} end
    table.insert(groups[v], k)
  end
end

return function(s)
  
end
