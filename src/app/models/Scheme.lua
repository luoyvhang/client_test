local class = require('middleclass')
local HasSignals = require('HasSignals')
local Scheme = class('Scheme'):include(HasSignals)
local tools = require('app.helpers.tools')

local luaoc
local luaj

if device.platform == 'ios' then
	luaoc = require('cocos.cocos2d.luaoc')
end

if device.platform == 'android' then
	luaj = require('cocos.cocos2d.luaj')
end

function Scheme:initialize()
	HasSignals.initialize(self)
	self.tabUrl = {}
	self.run = false
	-- cd = 2.33
	local cd = 2
	local function timerFunc()
		if not self.run then
			return
		end
		if device.platform == 'ios' then
			self:getSchemeDataIos()
		end
		if device.platform == 'android' then
			self:getSchemeDataAndroid()
		end
		if device.platform == 'windows' then
			-- self:onScheme('wjfijoqwofe://niwono.com&roomID=100033')
			-- self:onScheme('wjfijoqwofe://niwono.com&groupID=666666')
		end
	end
	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(timerFunc, cd, false)
end

function Scheme:resume()
	self.run = true
end

function Scheme:pause()
	self.run = false
end

function Scheme:getSchemeDataIos()
	local ok, ret = luaoc.callStaticMethod("AppController", "getUrlInfo", {ww = '666'})
	if ok and ret ~= '' then
		table.insert( self.tabUrl, ret)
		self:onScheme(ret)
	end
end 

function Scheme:getSchemeDataAndroid()
	local className = "org.cocos2dx.lua.AppActivity"
	local sigs = "()Ljava/lang/String;"
	local ok, ret = luaj.callStaticMethod(className, "getUrlInfo", {}, sigs)
	if ok and ret ~= '' then
		table.insert( self.tabUrl, ret)
		self:onScheme(ret)
	end 
end

function Scheme:onScheme(url)
	local roomId = string.match(url, 'roomID=(%d+)')
	local groupId = tonumber(string.match(url, 'groupID=(%d+)'))
	if roomId then
		self.emitter:emit("schemeRoomId", roomId)
	end
	if groupId then
		self.emitter:emit("schemeGroupId", groupId)
	end
end

return Scheme
