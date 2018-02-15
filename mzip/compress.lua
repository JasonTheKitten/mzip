local fromTree
fromTree = function(tree)
  local text = "{"
  for k, v in ipairs(tree) do
    if v.letter then
      if (v.letter == "{") or (v.letter == "}") or (v.letter == "\\") then
      	text=text.."\\"
      end
      text=text..v.letter
    else
      text = text..fromTree(v)
    end
  end
  return text.."}"
end

local function compress(text)
  local encode = loadfile("mzip/encode.lua", _G)()
  local es, pad = encode.encode(text)
  local tree = encode.getEncodingTree(encode.getFreq(encode.getChars(text)))
  local compressed = pad..fromTree(tree)..es
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
