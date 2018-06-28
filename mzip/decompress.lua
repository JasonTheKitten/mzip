local decode = mzipload("decode.lua", _G)()

local function getTree(text)
  local tbl = ""
  while #text > 0 do
    local char = string.sub(text, 1, 1)
    text = string.sub(text, 2, #text)
    if tonumber(char) then
      local times = char
      while tonumber(string.sub(text, 1, 1)) do
        times = times..string.sub(text, 1, 1)
        text = string.sub(text, 2, #text)
      end
      times = tonumber(times)
      local char2 = string.sub(text, 2, #text)
      tbl = tbl..string.rep(char2, times)
      if char2 == "}" then
        tbl = tbl .. ","		
      end
    elseif char == "\\" then
      local char2 = string.sub(text, 1, 1)
      text = string.sub(text, 2, #text)
      tbl = tbl.."letter = \""..char2.."\""
    else
      tbl = tbl.."letter = \""..char.."\""
    end
  end
  return textutils.serialize(tbl)
end
local function decompress(text)
  if string.sub(text, 1, 1) == "u" then
    return string.sub(text, 2, #text)
  else
    local padding = tonumber(string.sub(text, 2, 2))
    text = string.sub(text, 3, #text)
    local tree, text = getTree(text)
    return decode.decode(text, tree, padding)
  end
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
  toFolder = toFolder
}
