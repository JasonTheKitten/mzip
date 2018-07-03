local args = {...}

if not args[1] then
  error("Please use correctly", -1)
end

local load = load or function(s, _, _2, env)
	return loadstring(s, _, env)
end

local mzipload
local cache = {}
mzipload = function(file, env)
  file = fs.combine('/', file)
  env = env or _ENV
  env._G = env
  env.mzipload = mzipload
  if cache[file] then
    setfenv(cache[file], env)
    return cache[file]
  end
  local url = "https://raw.githubusercontent.com/JasonTheKitten/mzip/master/mzip/"
  local method = (fs.exists("mzip") and "file") or "url"
  env.mzipload = mzipload
  if method == "file" then
    local mfile = fs.open(fs.combine("mzip", file), "r")
    local c = mfile.readAll()
    mfile:close()
    cache[file], e = load(c, "MZIP "..file, nil, env)
    if e then error(e) end
  else
    local handle = http.get(url.."/"..file)
    local c = handle:readAll()
    handle:close()
    cache[file], e = load(c, "MZIP "..file, nil, env)
    if e then error(e) end
  end
  return cache[file]
end

if args[1] == "#compress" then
  local compress = mzipload("compress.lua")()
  local compressed = compress.compress(compress.fromFolder(args[2]))
  local handle = fs.open(args[3], "wb")
  for k, v in pairs(compressed) do
    handle.write(v)
  end
  handle.close()
elseif args[1] == "#extract" then
  local decompress = mzipload("decompress.lua")()
  local handle = fs.open(args[2], "rb")
  local result = {}
  local c = handle.read()
  if c>127 then
    c = handle.read()
    while c do
      table.insert(result, c)
	  c = handle.read()
    end
	result = decompress.decompress(result)
  else
    result = ""
    c = handle.read()
    while c and c>-1 do
      result = result..string.char(c)
    end
  end
  handle.close()
  decompress.toFolder(result, args[3])
end
