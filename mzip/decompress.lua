local decode = loadfile("mzip/decode.lua", _G)()

local function getTree(text)
  if not (string.match(text, "{.*}") and (string.sub(text, 1, 1)=="{")) then
    error("Error", -1)
  else
    local treeLoadString = "{"
	text = string.sub(text, 2, #text)
	local parLevel = 1
	while not (parLevel == 0) do
	  local char = string.sub(text, 1, 1)
	  text = string.sub(text, 2, #text)
	  if char == "\\" then
	    char = string.sub(text, 1, 1)
	    text = string.sub(text, 2, #text)
        treeLoadString = treeLoadString.."{letter='\\"..char.."'},"
	  elseif char == "{" then
	    parLevel = parLevel+1
		treeLoadString = treeLoadString.."{"
	  elseif char == "}" then
	    parLevel = parLevel-1
	    treeLoadString = treeLoadString.."},"
	  else
	    treeLoadString = treeLoadString.."{letter='"..char.."'},"
	  end
	end
	return textutils.unserialize(string.sub(treeLoadString, 1, #treeLoadString-1)), text
  end
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

local function toFolder(text, folder)

end

return {decompress=decompress}
