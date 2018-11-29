local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local BindPhoneController = class("BindPhoneController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

local smssdk = nil
if device.platform == 'ios' or device.platform == 'android' then
    smssdk = require('smssdk')
end

local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"

function BindPhoneController:initialize(data)
	Controller.initialize(self)
	HasSignals.initialize(self)

	if data then
		self.data = data[1]
	end

end

function BindPhoneController:viewDidLoad()
	self.view:layout(self.data)
	
	self.listener = {

		app.session.user:on('freshBindText',function(msg)
			self.view:freshBindText(msg)
		end),

	}

	-- 每隔一秒定时发送请求获取短信验证结果
	local scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler:scheduleScriptFunc(function()
		self.view:getResult()
	end,1, false)

end

function BindPhoneController:clickBack()
	SoundMng.playEft('btn_click.mp3')
	self.emitter:emit('back')
end

function BindPhoneController:clickSubmit()
	SoundMng.playEft('btn_click.mp3')
	local code = self.view:getCode()
	if code == "" then
		tools.showRemind("请输入验证码")
		return 
	end

	local phoneNum = self.view:getPhone()
	
	if device.platform == 'ios' or device.platform == 'android' then
		smssdk.commitCode(phoneNum, "86", code)
	else
		app.session.user:setPhoneNum(self.view:getPhone())
    end
end

function BindPhoneController:clickSend()
	SoundMng.playEft('btn_click.mp3')

	local bool = self.view:checkPhoneNum()
	local phoneNum = self.view:getPhone()
	if not bool then
		return 
	end
	tools.showRemind("请稍后")

	app.session.user:startScheduler()

	if device.platform == 'ios' or device.platform == 'android' then
		smssdk.getCode(phoneNum, "86", "")
	end
end

function BindPhoneController:finalize()-- luacheck: ignore
	for i = 1,#self.listener do
    	self.listener[i]:dispose()
	end

	-- 停止所有动画
	self.view:stopAllAnimation()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
end

return BindPhoneController
