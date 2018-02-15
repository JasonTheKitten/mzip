local arg1 = [[/Hello

\n{}
]]--...

if not arg1 then
  error("Please use correctly", -1)
end

if (string.sub(arg1, 1, 1) == "/") or (string.sub(arg1, 1, 2) == "./") then
  local compress = loadfile("mzip/compress.lua", _G)()
  local decompress = loadfile("mzip/decompress.lua", _G)()
  local word = string.sub(arg1, 2, #arg1)
  print(decompress.decompress(compress.compress(word)))
end
