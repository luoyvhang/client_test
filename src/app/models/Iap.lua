local class = require('middleclass')
local HasSignals = require('HasSignals')
local Iap = class('Iap'):include(HasSignals)
local cjson = require('cjson')
local luaoc = require('cocos.cocos2d.luaoc')

function Iap:initialize()
	HasSignals.initialize(self)
	self.tabReceipt = {}
	self.tabProduct = {
		'diamond6',
		'diamond12',
		'diamond68',
		'diamond108',
		'diamond388',
		'diamond648',
	}

	local scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler:scheduleScriptFunc(function()
		self:dumpIapCache()
		self:synPayment()
    end, 5, false)
end

function Iap:requestProduct(idx)
	local pId = self.tabProduct[idx]
	if not pId then return end

	local app = require("app.App"):instance()
	local user = app.session.user
	local uid = user.uid
	local playerId = tostring(user.playerId)
	
	luaoc.callStaticMethod("AppController", "requestProduct", {
		productId = pId, 
		userInfo = playerId,
	}) 
end

function Iap:synPayment()
	for k, v in pairs(self.tabReceipt) do
		if k ~= "testkey" then
			local playerId = string.split(k,"_")[1]
			if not playerId then 
				print('Invalid cacheId', k)
				return 
			end
			local cacheId = k
			self:upload2IapServer(playerId, cacheId, v)
		end
	end
end

function Iap:dumpIapCache()
	local ok, cache = luaoc.callStaticMethod("AppController", "iapCahceOperation", {operate = 'dump'})
	if ok then
		self.tabReceipt = {}
		for k,v in pairs(cache) do
			if k ~= "testkey" then
				print('receipt key', k)
				self.tabReceipt[k] = v
			end
		end
		-- dump(self.tabReceipt)
	end
end

function Iap:delIapCacheElement(key)
	local ok, cache = luaoc.callStaticMethod(
		"AppController", 
		"iapCahceOperation", 
		{
			operate = 'del', 
			key = key,
		}
	)
end

function Iap:upload2IapServer(playerId, cacheId, receipt)
	local cjson = require('cjson') 
	-- local config = require('welcome')

	local postData = {
		playerId = tonumber(playerId),
		cacheId = cacheId,
		receipt = receipt,
	}

	print('symPayment')
	print(postData.playerId, postData.cacheId)

	local http = require('http')
	local opt = {
		host = '192.168.1.5',
		path = '/apple/apple.php',
		method = 'POST'
	}

	local req = http.request(opt, function(response)
		local body = response.body
		if not body then return end 
		body = cjson.decode(body)
		if not body then 
			print('iapserver err', cacheId)
			return 
		end
		if body.status then
			print('upload payment success')
			self:delIapCacheElement(cacheId)
			return
		end
		print('iapserver err1', cacheId)
	end)

	local pData = cjson.encode(postData)
	req:write(pData)
	req:done()
end 


return Iap
