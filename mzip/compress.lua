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

local function fromFolder(folder)
  
end

return {
  compress = compress
}
