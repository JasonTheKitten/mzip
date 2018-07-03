local decode = mzipload("decode.lua", _G)()

local function getTree(text)
  local tbl = ""
  local inb = 0
  local tblm = {}
  local function getByte(text, b)
    return string.char(tonumber(string.sub(text, (b-1)*8+1, b*8), 2))
  end
  repeat
    char = getByte(text, 1)
    text = string.sub(text, 9, #text)
	if tonumber(char) then
	  local times = char
      while tonumber(getByte(text, 1)) do
        times = times..getByte(text, 1)
        text = string.sub(text, 9, #text)
      end
      times = tonumber(times)
	  local char2 = getByte(text, 1)
      tbl = tbl..string.rep(char2, times)
	  text = string.sub(text, 9, #text)
	  if char2 == "{" then
	    for i = 1, times do
	      table.insert(tblm, {})
		end
		inb = inb + times
	  else
	    for i = 1, times do
		  inb = inb-1
		  if #tblm == 1 then break end
	      table.insert(tblm[#tblm-1], tblm[#tblm])
		  table.remove(tblm, #tblm)
		end
	  end
	elseif char == "{" then
	  table.insert(tblm, {})
	  inb = inb + 1
	elseif char == "}" then
	  inb = inb-1
      if #tblm == 1 then break end
      table.insert(tblm[#tblm-1], tblm[#tblm])
      table.remove(tblm, #tblm)
	elseif char == "\\" then
	  local char2 = getByte(text, 1)
      text = string.sub(text, 9, #text)
	  table.insert(tblm[#tblm], {letter = char2})
	else
	  table.insert(tblm[#tblm], {letter = char})
	end
  until inb == 0
  return tblm[1], text
end

local function decompress(tbl)
  local function toBin(dec)
    local orgDec = dec
    local bits = (8) - 1
    local bin = ""
    while bits >= 0 do
      if 2^bits <= dec then
        bin = bin.."1"
        dec = dec-2^bits
      else
        bin = bin.."0"
      end
      bits = bits-1
    end
    return bin
  end
  local padding = tonumber(string.char(tbl[1]))

  table.remove(tbl, 1)
  local text = ""
  for k, v in ipairs(tbl) do
    text = text..toBin(v)
  end
  local tree, text = getTree(text)
  return decode.decode(text, tree, padding)
end

local function split(str, symb)
  local  words  =  {}
  for word in string.gmatch(str, '[^'..symb..']+')  do
	table.insert(words,  word)
  end
  return words
end

local function toFolder(text, folder)
  fs.delete(folder)
  fs.makeDir(folder)
  local oldHandle
  local textWall = split(text, "\n")
  for k, v in ipairs(textWall) do
    if string.sub(v, 1, 1) == " " then
      oldHandle.writeLine(string.sub(v, 2, #v))
    else
      if oldHandle then oldHandle:close() end
      if not fs.exists(fs.combine(fs.combine(folder, v), "..")) then
        fs.makeDir(fs.combine(fs.combine(folder, v), ".."))
      end
      oldHandle = fs.open(fs.combine(folder, v), "w")
      oldHandle.write("")
    end
  end
  if oldHandle then oldHandle:close() end
end

return {
  decompress=decompress,
  toFolder = toFolder,
  getTree = getTree
}
