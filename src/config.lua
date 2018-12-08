--luacheck: globals DEBUG CC_USE_FRAMEWORK CC_SHOW_FPS CC_DISABLE_GLOBAL CC_DESIGN_RESOLUTION

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
  width = 1136,
  height = 640,
  --autoscale = "FIXED_WIDTH",
  autoscale = "EXACT_FIT",
  callback = function(framesize)
    local ratio = framesize.width / framesize.height
    if ratio <= 1.34 then
      -- iPad 768*1024(1536*2048) is 4:3 screen
      --return {autoscale = "FIXED_WIDTH"}
      return {autoscale = "EXACT_FIT"}
    end
  end
}

local function devconf()
  local os = require('devinfo').get()
  if os == "Windows" or os == "Mac" then
    print('using dev config...')
    local ok, conf = pcall(require, 'devconf')
    if ok then return conf end
  end
  return {}
end

local production = {
  host='192.168.1.5',
  port = 28302,
  update = 'http://192.168.1.5:3000/chaoshanniuniu',
  download = 'http://nnstart.qiaozishan.com/download',
  STARTUP='UpdateController',
  connectPort = 1234,
}

local function merge(base, overwrite)
  local conf = {}
  for k, v in pairs(base) do
    conf[k] = v
  end
  for k, v in pairs(overwrite) do
    conf[k] = v
  end
  print('loaded config:')
  for k, v in pairs(conf) do print("", k, v) end
  return conf
end

local config = merge(production, devconf())

return config
