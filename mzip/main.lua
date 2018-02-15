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

if args[1] == "#run" then
  local handle = http.get("https://pastebin.com/raw/"..args[2])
  local result = handle:readAll()
  handle:close()
  decompress.toFolder(decompress.decompress(result), ".temp")
  shell.run(".temp/main.lua")
  fs.delete(".temp")
elseif args[1] == "#put" then
    local key = "0ec2eb25b6166c0c27a394ae118ad829"
    local text = compress.compress(compress.fromFolder(args[2]))
    local response = http.post(
      "https://pastebin.com/api/api_post.php",
      "api_option=paste&"..
      "api_dev_key="..key.."&"..
      "api_paste_format=lua&"..
      "api_paste_name="..textutils.urlEncode((args[3] or "")..".mzip").."&"..
      "api_paste_code="..textutils.urlEncode(text)
    )

    if response then
      local sResponse = response.readAll()
        response.close()
        local sCode = string.match( sResponse, "[^/]+$" )
        print( "Uploaded as "..sResponse )
    else
        print( "Err." )
    end
elseif args[1] == "#get" then
  local handle = http.get("https://pastebin.com/raw/"..args[2])
  local result = handle:readAll()
  handle:close()
  decompress.toFolder(decompress.decompress(result), args[3])
end
