local arg1 = ...

if not arg1 then
  error("Please use correctly", -1)
end

if (string.sub(arg1, 1, 1) == "/") or (string.sub(arg1, 1, 2) == "./") then
  local encode = loadfile("mzip/encode.lua", _G)()
  local decode = loadfile("mzip/decode.lua", _G)()
  local word = string.sub(arg1, 2, #arg1)
  local str, padding = encode.encode(word)
  local tree = encode.getEncodingTree(encode.getFreq(encode.getChars(word)))
  print(decode.decode(str, tree, padding))
end
