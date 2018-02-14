local arg1 = ...

if not arg1 then
  error("Please use correctly", -1)
end

local function dwrite(mtext)
  local f = io.open("G", "w")
  print(mtext)
  f:write(mtext)
  f:close()
end

if (string.sub(arg1, 1, 1) == "/") or (string.sub(arg1, 1, 2) == "./") then
  local compress = loadfile("mzip/compress.lua", _G)()
  local word = string.sub(arg1, 2, #arg1)
  dwrite(compress.compress(word))
end
