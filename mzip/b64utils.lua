local b64s = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local b64t = {}
for i = 1, #b64s do
  b64t[i-1] = string.sub(b64s, i, i)
end
 
return {encode = function(str)
  local rtn, buff = "", {}
  for nSP = 1, #str do
    buff[nSP] = string.byte(string.sub(str, nSP, nSP))
  end
  while not ((#buff % 3) == 0) do
    table.insert(buff, 0)
  end
  local mode = 0
  local i = 1
  while i <= #buff do
    if mode == 0 then
      rtn = rtn .. b64t[ bit.brshift(buff[i], 2) ]
    elseif mode == 1 then
      rtn = rtn .. (b64t[
        bit.bor(
          bit.blshift( (buff[i-1] % 4), 4),
          bit.brshift( buff[i],4) )
      ] or "=")
    elseif mode == 2 then
      rtn = rtn ..
        (((#str-(i - mode -1)) > 1) and
        b64t[
          bit.bor(
            bit.blshift(buff[i-1] % 16,2),
            bit.brshift(buff[i], 6)
          )
        ] or "=")
--    else
      rtn = rtn ..
        (((#str-(i - mode - 1)) > 2) and
        b64t[(buff[i] % 64)]
        or "=")
    end
    i = i + 1
    mode = (mode + 1) %3
  end
  return rtn
end, decode = function(str)

end}
