local fromTree
fromTree = function(tree)
  local dat = {"{"}
  local segs = {{tree = tree, pos = 1}}
  while true do
    local myseg = segs[#segs]
    if myseg.tree[myseg.pos] then
      myseg.pos = myseg.pos+1
      if myseg.tree[myseg.pos-1].letter then
        dat[#dat+1] = myseg.tree[myseg.pos-1].letter
      else
        table.insert(dat, "{")
        table.insert(segs, {tree = myseg.tree[myseg.pos-1], pos = 1})
      end
    else
      table.remove(segs, #segs)
      dat[#dat + 1] = "}"
      if #segs > 0 then
        segs[#segs].pos = segs[#segs].pos+1
      else
        break
      end
    end
  end
    
    local segs = {"{"}
    for k, v in ipairs(tree) do
      if v.letter then
		if v.letter == "{" or v.letter == "}" or v.letter == "\\" then
		  table.insert(segs, "\\"..v.letter)
		else
          table.insert(segs, v.letter)
		end
      else
        for k, v in ipairs(fromTree(v)) do
          table.insert(segs, v)
        end
      end
    end
    table.insert(segs, "}")
    
    return segs
end
  
local function fromSegs(segs)
    local rtn = ""
    local int = 0
    local out = 0
    local function processN(n, c)
	  if n>1 then
        rtn = rtn..tostring(n)..c
	  elseif n==1 then
		rtn = rtn..c
	  end
    end
    while #segs > 0 do
      if segs[1] == "{" then
        int = int + 1
        processN(out, "}")
        out = 0
      elseif segs[1] == "}" then
        out = out + 1
        processN(int, "{")
        int = 0
      else
	    processN(out, "}")
        out = 0
        processN(int, "{")
        int = 0
        if tonumber(segs[1]) then
          rtn = rtn .. "\\"
        end
        rtn = rtn..segs[1]
      end
      table.remove(segs, 1)
    end
    processN(out, "}")
    return rtn
end

local function compress(text)
  local encode, es = mzipload("encode.lua")(), {}
  local es1, pad = encode.encode(text)
  for i=1, #es1, 8 do
    table.insert(es, tonumber(string.sub(es1, i, i+7), 2))
  end
  local tree = encode.getEncodingTree(encode.getFreq(encode.getChars(text)))
  local compressed = {string.char(tonumber("10000000", 2)), string.byte(tostring(pad))}
  local segs = fromSegs(fromTree(tree))
  for i=1, #segs do
	table.insert(compressed, string.sub(segs, i, i))
  end
  for k, v in ipairs(es) do
	table.insert(compressed, v)
  end
  if #compressed < #text then
    return compressed
  else
    local rtn = {0}
	for i=1, #text do
	  table.insert(rtn, string.byte(string.sub(text, i, i)))
	end
	return rtn
  end
end

local function split(str, symb)
  local  words  =  {""}
  for i=1, #str do
    if string.sub(str, i, i) == symb then
	  table.insert(words, "")
	else
	  words[#words] = words[#words]..string.sub(str, i, i)
	end
  end
  return words
end

local function fromFolder(folder)
  local loadFolder
  loadFolder = function(folder)
    local items = {}
    for k, v in ipairs(fs.list(folder)) do
      if fs.isDir(fs.combine(folder, v)) then
        for k, v2 in ipairs(loadFolder(fs.combine(folder, v))) do
          table.insert(items, fs.combine(v, v2))
        end
      else
        table.insert(items, v)
      end
    end
    return items
  end
  local dat = ""
  for k, v in ipairs(loadFolder(folder)) do
    dat = dat .. v .. "\n"
    local file = io.open(fs.combine(folder, v), "r")
    for line in file:lines() do
      dat = dat.." "..line.."\n"
    end
    file:close()
  end
  return string.sub(dat, 1, #dat-1)
end

return {
  compress = compress,
  fromFolder = fromFolder,
  fromTree = fromTree,
  fromSegs = fromSegs
}
