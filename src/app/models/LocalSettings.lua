local class = require('middleclass')
local HasSignals = require('HasSignals')
local LocalSettings = class('LocalSettings'):include(HasSignals)
local cjson = require('cjson')

local function savename()
  return cc.FileUtils:getInstance():getWritablePath() .. '.LocalSettings'
end

local function saveCreateRoomConfigName()
  return cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomConfig'
end

local function saveExpressConfigName()
  return cc.FileUtils:getInstance():getWritablePath() .. '.ExpressConfig'
end

local function saveCreateRecordConfigName()
  return cc.FileUtils:getInstance():getWritablePath() .. '.CreateRecordConfig'
end

local function saveCreateDetailedRecordConfigName()
  return cc.FileUtils:getInstance():getWritablePath() .. '.CreateDetailedRecordConfig'
end

local function saveGroupConfigName()
  return cc.FileUtils:getInstance():getWritablePath() .. '.GroupConifg'
end

local roomConfig = {}
local recordConfig={}
local detailedRecordConfig={}
local groupConfig = {}
local expressConfig = {}

local function merge(dst, src)
  for k,v in pairs(src) do
    if type(dst[k]) == 'table' and type(v) == 'table' then
      merge(dst[k], v)
    else
      dst[k] = v
    end
  end
end

function LocalSettings:initialize()
  HasSignals.initialize(self)
  local fu = cc.FileUtils:getInstance()
  local s = fu:getStringFromFile(savename())
  local devinfo = require('devinfo')
  local defaults = {
    language = select(1, devinfo.locale()),
    auth = {
      methods={},
      gesture={}
    }
  }

  self.values = defaults
  if #s > 2 then
    local loaded = cjson.decode(s)
    merge(self.values, loaded)
  end

  if io.exists(saveCreateRoomConfigName())  then
    local s = fu:getStringFromFile(saveCreateRoomConfigName())
    if #s > 2 then
    local loaded = cjson.decode(s)
    merge(roomConfig, loaded)
    end
  end

  if io.exists(saveExpressConfigName())  then
    local s = fu:getStringFromFile(saveExpressConfigName())
    if #s > 2 then
    local loaded = cjson.decode(s)
    merge(expressConfig, loaded)
    end
  end
  
  if io.exists(saveGroupConfigName())  then
    local s = fu:getStringFromFile(saveGroupConfigName())
    if #s > 2 then
    local loaded = cjson.decode(s)
    merge(groupConfig, loaded)
    end
  end

  local fu_record=cc.FileUtils:getInstance()
  local s_record=fu_record:getStringFromFile(saveCreateRecordConfigName())
  
  if #s_record > 2 then
  local loaded_record = cjson.decode(s_record)
  merge(recordConfig, loaded_record)
  end

  local fu_DRecord=cc.FileUtils:getInstance()
  local s_DRecord=fu_DRecord:getStringFromFile(saveCreateDetailedRecordConfigName())
  
  if #s_DRecord > 2 then
  local loaded_DRecord = cjson.decode(s_DRecord)
  merge(detailedRecordConfig, loaded_DRecord)
  end

end


function LocalSettings:get(key)
  return self.values[key]
end

function LocalSettings:set(key, value,dontSave)
  self.values[key] = value

  if not dontSave then
    self:save()
  end
end

function LocalSettings:setRoomConfig(key, value)
  roomConfig[key] = value
  self:saveCreateRoomConfig()
end

function LocalSettings:getRoomConfig(key)
  return roomConfig[key]
end

function LocalSettings:save()
  local f = io.open(savename(), 'wb')
  f:write(cjson.encode(self.values))
  f:close()
end

--==============================--
--desc: 保存创建房间时的配置
--time:2017-07-04 05:26:25
--@return 
--==============================----
function LocalSettings:saveCreateRoomConfig()
  local f = io.open(saveCreateRoomConfigName(), 'wb')
  f:write(cjson.encode(roomConfig))
  f:close()
end

function LocalSettings:setEffectFlag(flag)
	self.effectOn = flag
	self.emitter:emit('effectSettingChg')
end

function LocalSettings:setMusicFlag(flag)
	self.musicOn = flag

	self.emitter:emit('musicSettingChg')
end


--====================================--
--desc:保存每一轮的数据
--time:2017-07-06
--====================================--

function LocalSettings:getRecordConfig(key)
  return recordConfig[key]
end

function LocalSettings:getRecordTable()
 return recordConfig
end

function LocalSettings:setRecordTable()
self:saveCreateRecordConfig()
end

function LocalSettings:setRecordConfig(t)
  table.insert(recordConfig,t) 
  if recordConfig[11]~=nil then
  table.remove(recordConfig,1)
  end
  self:setRecordTable()
end

function LocalSettings:saveCreateRecordConfig()
  local r = io.open(saveCreateRecordConfigName(), 'wb')
  r:write(cjson.encode(recordConfig))
  r:close()
end

--===========================================--
--desc:保存每一轮的战绩详情
--time:2017-07-07
--===========================================--

function LocalSettings:getDetailedRecordConfig(key)
  return detailedRecordConfig[key]
end


function LocalSettings:getDetailedRecordConfigTable()
	local key = 0
	for _, v in ipairs(recordConfig) do
		local tb = {}
		local round = v.round
		for i = 1, round do
			table.insert(tb, detailedRecordConfig[i + key])	
		end
		key = key + round
	--	dump(round)
		v.records = tb
		--dump(v)
	end
	return recordConfig
end 

--保存每一局的战绩
function LocalSettings:setDetailedRecordConfig(t)
  table.insert(detailedRecordConfig,t) 
  if detailedRecordConfig[11]~=nil then
  table.remove(detailedRecordConfig,1)
  end
  self:saveCreateDetailedRecordConfig()
end

function LocalSettings:saveCreateDetailedRecordConfig()
  local dr = io.open(saveCreateDetailedRecordConfigName(), 'wb')
  dr:write(cjson.encode(detailedRecordConfig))
  dr:close()

end


-------------------------------------------------------------------------------------------------------------------------------------------------
function LocalSettings:setGroupConfig(key, value)
  if not key then return end
  if value == nil then return end
  groupConfig[key] = value
  self:saveGroupConfig()
end

function LocalSettings:getGroupConfig(key)
  if not key then return end
  return groupConfig[key]
end

function LocalSettings:saveGroupConfig()
  local r = io.open(saveGroupConfigName(), 'wb')
  r:write(cjson.encode(groupConfig))
  r:close()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- 魔法表情
function LocalSettings:setExpressConfig(key, value)
  expressConfig[key] = value
  self:saveExpressConfig()
end

function LocalSettings:getExpressConfig(key)
  return expressConfig[key]
end

function LocalSettings:saveExpressConfig()
  local f = io.open(saveExpressConfigName(), 'wb')
  f:write(cjson.encode(expressConfig))
  f:close()
end

return LocalSettings
