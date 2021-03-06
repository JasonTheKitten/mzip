local function toITable(mytable) --This is based off of GetOpts toITable method
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
    for k2, v in ipairs(v) do
      table.insert(f, {letter = v, freq = k})
    end
  end
  return f
end

local function getEncodingTree(f)
  local values = f
  if #values == 1 then
  	values = {values}
  end
  while #values > 1 do
    local i = 1
    local min, min2, posA, posB
    for k, v in ipairs(values) do
      if (not min) then
        min, posA = v, k
      elseif (not min2) then
      	min2, posB = v, k
      elseif v.freq<min.freq then
        min2, posB, min, posA = min, posA, v, k
      elseif v.freq == min.freq then
        min2, posB = v, k
      end
    end
    values[posA] = nil
    values[posB] = nil
    values = toITable(values)
    table.insert(values, {min, min2, freq = min.freq + min2.freq})
  end
  local tree = values[1]
  return tree
end

local function getValues(t)
  local descend
  descend = function(branch)
    local rtn = {}
    local merge
    merge = function(prefix, dat)
      if dat.letter then
        rtn[prefix] = dat.letter
      else
        for k, v in pairs(descend(dat)) do
          rtn[prefix..k] = v
        end
      end
    end
    if branch[1] then
      merge("0", branch[1])
    end
    if branch[2] then
      merge("1", branch[2])
    end
    return rtn
  end
  local result = descend(t)
  local rtn = {}
  for k, v in pairs(result) do
    rtn[v] = k
  end
  return rtn
end

local function getCharCode(s)
  return getValues(getEncodingTree(getFreq(getChars(s))))
end

local function encode(s)
  local code = getCharCode(s)
  local str, strb = "", {}
  for i=1, #s do
    str = str..code[string.sub(s, i, i)]
  end
  local padding = (8-(#str % 8))%8
  str = str..string.rep("0", padding)

  return str, padding
end

return {
  encode = encode,
  getCharcode = getCharCode,
  getChars = getChars,
  getValues = getValues,
  getEncodingTree = getEncodingTree,
  getFreq = getFreq,
  toITable = toITable
}


