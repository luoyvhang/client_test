local cache = {}

local fu = cc.FileUtils:getInstance()
local prefix = fu:getWritablePath() .. '.cache/'
print(prefix)

local lockfiles = {}

function cache.isDownloaded(url)
  local md5 = require('md5')
  local to = prefix..md5.sum(url)

  if fu:isFileExist(to) then
    return true
  end
end

function cache.getPrefix()
  return prefix
end

function cache.lockFile(path)
  lockfiles[path] = true
end

function cache.isLock(file)
  for k,_ in pairs(lockfiles) do
    if file:find(k) then
      return true
    end
  end

  return false
end

function cache.get(url, func,notImage,immediate,progressCall,dontLoadaAsyn,suffix)
  if not fu:isDirectoryExist(prefix) then
    fu:createDirectory(prefix)
  end

  if not immediate then
    immediate = false
  end

  --print('getting '..url)
  local function logic(ok,path)
    if not ok then
      func(ok,path)
    else
      if notImage then
        func(ok,path)
      else
        if dontLoadaAsyn then--or device.platform == "android" then
          cc.Director:getInstance():getTextureCache():addImage(path)
          func(ok,path)
        else
          cc.Director:getInstance():getTextureCache():addImageAsync(path,function(texture)
            if not texture then
              ok = false
            end
            func(ok,path)
          end)
        end
      end
    end
  end

  if not url then
    print(url, ' is not a URL')
    logic(false,nil)
    return
  end

  if not (url:find('^http://')) and not (url:find('^https://')) then
    print(url, ' is not a URL')
    logic(false,nil)
    return
  end
  local http = require('http')
  local md5 = require('md5')
  local to = prefix..md5.sum(url)
  if suffix then to = to..suffix end

  if fu:isFileExist(to) then
    --print('already cached as:', to)
    logic(true,to)
    return
  end

  local req = http.fetch(url, to, logic,immediate,function(progress)
    if progressCall then
      progressCall(progress)
    end
  end)

  return req
end

function cache.getCache(url)
  local http = require('http')
  local md5 = require('md5')
  local to = prefix..md5.sum(url)

  if not url then
    print(url, ' is not a URL')
    return
  end

  if not (url:find('^http://')) and not (url:find('^https://')) then
    print(url, ' is not a URL')
    return
  end

  if fu:isFileExist(to) then
    return true, to
  end
end

return cache
