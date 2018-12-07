
package.path = 'src/?.lua;src/packages/?.lua'
local fu = cc.FileUtils:getInstance()
fu:setPopupNotify(false)
fu:addSearchPath("res/")
local config = require('config')

local remote_debug = false

if remote_debug then
  require('mobdebug').start()
end

local ok, devconf = pcall(require, 'devconf')
if not ok then devconf = {} end

if not devconf.SKIP_UPDATE then
  fu:addSearchPath(fu:getWritablePath().."up/", true)
end

_G.debug.traceback = require('StackTracePlus').stacktrace
require('config')
require('cocos.init')

if devconf.ZBS then
  package.path = package.path..string.gsub(';%ZBS%/lualibs/?/?.lua;%ZBS%/lualibs/?.lua', '%%ZBS%%', devconf.ZBS)
  package.cpath = package.cpath..string.gsub('%ZBS%/bin/?.dll;%ZBS%/bin/clibs/?.dll', '%%ZBS%%', devconf.ZBS)
  CC_DISABLE_GLOBAL=false
  require('mobdebug').start()
  CC_DISABLE_GLOBAL=true
end

local function main()
  if jit then
    print(jit.version, jit.arch)
  else
    print(_VERSION)
  end
  if devconf.GENERATE_TRANSLATION then
    require("locale").collect()
  end

  --cc.Director:getInstance():getScheduler():scheduleScriptFunc(require('pomelo').poll,0,false)

  local app = require("app.App"):instance()
  local startup = config.STARTUP
  if not startup then
    startup = 'UpdateController'
  end

  --if devconf.STARTUP then
  --  startup = devconf.STARTUP
  --end

  app:run(startup)
end

local breakInfoFun, xpcallFun
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_WINDOWS == targetPlatform then
  local debugFile = cc.FileUtils:getInstance():getWritablePath() .. 'debug'
  local bFileExist = cc.FileUtils:getInstance():isFileExist(debugFile)
  print('debug file exist', bFileExist)
  if bFileExist then
    CC_DISABLE_GLOBAL = false
    breakInfoFun, xpcallFun = require("LuaDebugjit")("localhost", 7003)
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakInfoFun, 0.1, false)
    CC_DISABLE_GLOBAL = true
  end
end

-- luacheck: ignore __G__TRACKBACK__
local traceback = __G__TRACKBACK__

function __G__TRACKBACK__(msg)
  if xpcallfun then xpcallFun() end
  traceback(msg)
  if devconf.EXIT_ON_ERROR then os.exit(1) end -- This is useful when works with atom-build.
end

xpcall(main, __G__TRACKBACK__)
print(string.lower('C14EBBFFF1FF1319782C778FE058F528'))
