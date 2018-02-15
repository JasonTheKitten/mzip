local encoder = mzipload("encode.lua")()

local function toBin(dec)
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

local function decode(s, tree, padding)
  local values = encoder.getValues(tree)
  local binString = ""
  for i = 1, #s do
    binString = binString..toBin(string.byte(string.sub(s, i, i)))
  end
  binString = string.sub(binString, 1, #binString - padding)
  local decString = ""
  while not (binString=="") do
    for k, v in pairs(values) do
      if string.sub(binString, 1, #v) == v then
        decString = decString..k
        binString = string.sub(binString, #v+1, #binString)
        break
      end
    end
  end
  return decString
end

return {decode = decode}
