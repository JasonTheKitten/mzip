local args = {...}

if not args[1] then
  error("Please use correctly", -1)
end

local mzipload
local cache = {}
mzipload = function(file, env)
  file = fs.combine('/', file)
  env = env or _G
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
    cache[file] = load(c, "MZIP "..file, nil, env)
  else
    local handle = http.get(url.."/"..file)
    local c = handle:readAll()
    handle:close()
    textutils.pagedPrint(c)
    cache[file] = load(c, "MZIP "..file, nil, env)
  end
  return cache[file]
end

local compress = mzipload("compress.lua")()
local decompress = mzipload("decompress.lua")()

if args[1] == "#compress" then
  local compressed = compress.compress(compress.fromFolder())
  local handle = fs.open(args[2], "w")
  handle:write(compressed)
  handle:close()
elseif args[1] == "#extract" then
  local handle = fs.open(args[2], "r")
  local result = handle:readAll()
  handle:close()
  decompress.toFolder(decompress.decompress(result), args[3])
end
