local fs = cc.FileUtils:getInstance()
local rmrf = require('rmrf')
local class = require('middleclass')
local HasSignals = require('HasSignals')
local http = require('http')
local semver = require('semver')
local Updater = class('Updater'):include(HasSignals)
local log = print

local consts = {
  root = fs:getWritablePath()..'up/',
  version_name = 'v',
  index_name = 'index',
  buildin_suffix = '.build-in'
}

local function readVersion(file)
  local v = fs:getStringFromFile(file)
  v = v:gsub('%s$', '')
  return semver(#v == 0 and '0.0.1' or v)
end

local function parseIndex(content)
  local index = {}
  --for hash, file in string.gmatch(content, "([%x/%w%.]+): ([^\n]+)") do
  for hash, file in string.gmatch(content, "([%x/]+): ([^\n]+)") do
    index[file] = hash
  end
  return index
end

local function readIndex(file)
  return parseIndex(fs:getStringFromFile(file))
end

local function removeIfExists(file)
  if fs:isFileExist(file) then
    log('remove '.. file)
    fs:removeFile(file)
  end
end

local function removeOldUpdates()
  log('removing all old updates...')
  rmrf(consts.root)
  fs:createDirectory(consts.root)
end

local function loadClientVersion(self)
  local opt = consts
  local buildin = readVersion(opt.version_name..opt.buildin_suffix)
  local updated = readVersion(consts.root..opt.version_name)
  if buildin >= updated then
    removeOldUpdates(self)
    return buildin, readIndex(opt.index_name..opt.buildin_suffix)
  else
    return updated, readIndex(consts.root..opt.index_name)
  end
end

local function ensureEndSlash(s)
  return s:sub(-1, -1) == '/' and s or s..'/'
end

function Updater.static:appVersion()
  local buildin = readVersion(consts.version_name..consts.buildin_suffix)
  local updated = readVersion(consts.root..consts.version_name)
  log('appVersion: %s : %s', tostring(buildin), tostring(updated))
  return updated > buildin and updated or buildin
end

-- url: 'http://192.168.8.228:8888/'
function Updater:initialize(url)
  HasSignals.initialize(self)
  self.url = ensureEndSlash(url)
  if not fs:isDirectoryExist(consts.root) then
    fs:createDirectory(consts.root)
  end
  local v, m = loadClientVersion(self)
  log('version:', v)
  self.current = { version = v, files = m }
end



--[[
1. check url/v for remote version
2. compare with local version
  2.1. update to date: nothing
  2.2. major update: major
  2.3. minor or path update
    2.3.1. download index from url/index
    2.3.2. parse index
    2.3.3. comapre local and remote index get updates and removes
    2.3.4. download updates as file.ok
    2.3.5. cleanup
      2.3.5.1. rename file.ok to file
      2.3.5.2. remove files needs to remove
    2.3.6. save new version (v and index) to update dir.
]]
function Updater:run()
  local function fire(...)
    log('fired:'..table.concat({...}))
    self.emitter:emit(...)
  end
  local function hasHotfixes(version)
    log(self.current.version, version)
    local v, c = version, self.current.version

    if v > c then
      if v.major ~= c.major then
        log(v.major, c.major)
        fire('major')
        return false
      elseif v.minor ~= c.minor then
        fire('minor')
        return true
      elseif v.patch ~= c.patch then
        fire('patch')
        return true
      end
    end

    fire('nothing')
    return false
  end

  local function getUpdates(remoteIndex)
    local tabRename = {} -- key:hash v:fileName

    local updates = {}
    local localIndex = self.current.files
    local meet = {}
    for file, hash in pairs(remoteIndex) do
      local lhash = localIndex[file]
      if not lhash or lhash ~= hash then-- updated
        if not meet[hash] then
          meet[hash] = true
          updates[#updates+1] = hash
          tabRename[hash] = file
        end
      end
    end
    return updates, tabRename
  end

  local function download(updates, callback)
    if #updates == 0 then
      log('0 object to download.')
      callback()
    end
    local url = self.url
    log('download update form:', url, '->', consts.root)
    local got = 0
    local function gotone()
      got = got + 1
      fire('progress', got/#updates)
      if got == #updates then callback() end
    end
    local function fetch(hash)
      log(hash)
      local todir = consts.root .. hash:match('(%x%x)/%x+')
      local tofile = consts.root .. hash
      if not fs:isDirectoryExist(todir) then
        fs:createDirectory(todir)
      end

      if fs:isFileExist(tofile) or fs:isFileExist(tofile..'.2') then
        gotone()
      else
        http.fetch(url..hash, tofile..'.1', function(ok, wip)
          if not ok then return fire('error', 'download') end
          fs:renameFile(wip, (wip:gsub('%.1$', '.2')))
          gotone()
        end)
      end
    end
    fire('update')
    for _, item in ipairs(updates) do
      fetch(item)
    end
  end

  local function cleanup(index, updates, tabRename)
    log('Cleanup...')
    -- 2.3.5.1. rename file.2 to file
    assert(#updates > 0)

    local function getName(fileName, path)
        local tmpStr = string.reverse(fileName)
        local pos = string.find(tmpStr, "%.", 1)
        if pos then
             pos = string.find(fileName, "%.", -1 * pos)
             tmpStr = string.sub(fileName, pos, string.len(fileName))
             return path..tmpStr
        end
        return path
    end


    for _, hash in ipairs(updates) do
      local file = consts.root .. hash
      -- 改名hedi
      local name = tabRename[hash]
      local file2 = getName(name, file)
      fs:renameFile(file..'.2', file2)
    end

    -- 2.3.5.2.
    log('removeing out dated updates...')
    local  hashes = {}
    for file,hash in pairs(index) do
      hashes[hash] = file
    end

    local localIndex = self.current.files
    for file, hash in pairs(localIndex) do
      if not hashes[hash] then -- not on remote, remove
        local f = consts.root..hash
        local f_org = consts.root..hash
        f = getName(file, f)
        removeIfExists(f)
        removeIfExists(f_org)
      end
    end
  end

  local function save(v, index)
    local function fwrite(file, content)
      local f = io.open(file, 'wb')
      f:write(content)
      f:close()
    end
    fwrite(consts.root..consts.version_name, tostring(v))
    fwrite(consts.root..consts.index_name, index)
  end

  http.read(self.url..'v', function(ok, version)
    if not ok then return fire('error', 'v') end
    log(version)
    version = semver(version:gsub('%s$', ''))
    if hasHotfixes(version) then
      http.read(self.url..'index', function(success, content)
        if not success then return fire('error', 'index') end
        local index = parseIndex(content)
        local updates, tabRename = getUpdates(index)
        download(updates, function()
          cleanup(index, updates, tabRename)
          save(version, content)
          fire('done')
        end)
      end)
    end
  end)
end

return Updater
