local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local H5ShopController = class("H5ShopController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"

function H5ShopController:initialize(data)
	Controller.initialize(self)
	HasSignals.initialize(self)

	if data then
		self.data = data[1]
	end

end

function H5ShopController:viewDidLoad()
	self.view:layout(self.data)
	
	if device.platform == 'ios' then
		self.iap = app.session.iap
	end

	self.listener = {
		app.session.user:on('chargeResult',function(msg)
			self.view:freshResultInfo(msg)
		end),

		app.session.user:on('chargeRecord',function(msg)
			self.view:freshExchangeRecordList(msg)
		end),

		app.session.user:on('freshBindText',function(msg)
			self.view:freshBindText(msg)
		end),

		self.view:on('onTouch',function(msg)
        	self.view:freshTitleAndContent(msg)
		end),  
		
		-- ======== IOS IAP ========
		self.view:on('chargeDiamond', function(idx)
			self:onChargeDiamond(idx)
		end)
	}

	app.session.user:querychargeRecord()
	
	-- 每隔两秒定时发送请求更新充值记录
	local scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler:scheduleScriptFunc(function()
		app.session.user:querychargeRecord()
	end, 10, false)

end

function H5ShopController:clickBack()

	-- local CaptureScreen = require('app.helpers.capturescreen')
	-- CaptureScreen.capture('6.jpg',function(ok, path)
	-- if ok then
	-- end
	-- end, self.view, 1)


	SoundMng.playEft('btn_click.mp3')
	self.view:stopLoading()
	self.emitter:emit('back')
end

function H5ShopController:clickCloseBindLayer()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshBindLayer(false)
end

function H5ShopController:clickResult()
	SoundMng.playEft('btn_click.mp3')
	self.view:hideResultView()
end

function H5ShopController:clickPayChannel()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshPayChannelView(false)
end

--选择微信支付
--[[ function H5ShopController:clickWeiXin()
	SoundMng.playEft('btn_click.mp3')
	self.view:changePayChannel(1)
	self.view:freshPayWebView(true)
end ]]

--选择支付宝支付
--[[ function H5ShopController:clickZhiFuBao()
	SoundMng.playEft('btn_click.mp3')
	self.view:changePayChannel(2)
	self.view:freshPayWebView(true)
end ]]

function H5ShopController:clickWebLayer()
	SoundMng.playEft('btn_click.mp3')
	self.view:onClickWebLayer()
end

function H5ShopController:finalize()-- luacheck: ignore
	for i = 1,#self.listener do
    	self.listener[i]:dispose()
	end

	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
end

function H5ShopController:onChargeDiamond(idx)
	if device.platform == 'ios' then
		self.iap:requestProduct(idx)
	elseif device.platform == 'windows' then 	
		-- self:httptest() 
		local str = string.format("感谢您的支持, 本次充值共获得%s钻石.", idx)
    	tools.showMsgBox("充值结果", str)
	end
end


return H5ShopController
