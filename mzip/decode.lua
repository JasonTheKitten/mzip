local function decode(s, tree, padding)
  s = string.sub(s, 1, #s - padding)
  local bsl = #s
  local decString = ""
  local treeleft = tree
  while not (s=="") do
    local bit = tonumber(string.sub(s, 1, 1))+1
	s = string.sub(s, 2, #s)
	if treeleft[bit] then
	  treeleft = treeleft[bit]
	  if treeleft.letter then
		decString = decString..treeleft.letter
		treeleft = tree
	  end
	else
	  error("Decompression error")
	end
  end
  return decString
end

return {decode = decode}
