local function toITable(mytable)
  local tbl = {}
  local ids = {}
  for k, v in pairs(mytable) do
    if type(k) == "number" then
      local tryIndex = 1
      while tryIndex <= #ids do
        if k >= ids[tryIndex] then table.insert(ids, tryIndex, k) break end
        if tryIndex == #ids then table.insert(ids, tryIndex, k) break end
        tryIndex = tryIndex + 1
      end
      if #ids == 0 then ids[1] = k end
    else
      tbl[k] = v
    end
  end
  for k, v in ipairs(ids) do  --IDs are reversed
    tbl[k] = mytable[ids[#ids - k + 1]]
  end
  return tbl
end

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
  groups = toITable(groups)
  for k, v in ipairs(groups) do
    for k, v in ipairs(k) do
      table.insert(f, v)
    end
  end
  return f
end

local function getValues(f)
  local values = {}
  local code = ''
  for k, v in ipairs(f) do
    if string.sub(code, #code, #code) == "0" then
      local choppedCode = string.sub(code, #code-1, #code-1)
      if k == #f then
        code = code.."1"
      else
        code = code.."0"
      end
      values[v] = code
    else
      code = code .. "0"
      values[v] = code
    end
  end
  return values
end

local function getCharCode()
  
end

local function encode()
  
end

return {
  encode = encode,
  getCharcode = getCharCode,
  
}
