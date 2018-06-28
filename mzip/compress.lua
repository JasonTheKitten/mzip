

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
        table.insert(segs, v.letter)
      else
        for k, v in ipairs(getTree(v)) do
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
      rtn = rtn..string.rep(c, n)
    end
    while #rtn > 1 do
      if segs[1] == "{" then
        int = int + 1
        processN(out, "}")
        out = 0
      elseif segs[1] == "}" then
        out = out + 1
        processN(int, "{")
        int = 0
      else
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
  local encode = loadfile("mzip/encode.lua", _G)()
  local es, pad = encode.encode(text)
  local tree = encode.getEncodingTree(encode.getFreq(encode.getChars(text)))
  local compressed = pad..fromSegs(fromTree(tree))..es
  local mytext
  if #compressed < #text then
    mytext = "c"..compressed
  else
    mytext = "u"..text
  end
  return mytext
end

local function split(str, symb)
  local  words  =  {}
  for word in string.gmatch(str, '[^"'..symb..'"]+')  do
    table.insert(words,  word)
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
  fromFolder = fromFolder
}
