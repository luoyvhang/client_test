local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local CertifyController = class("CertifyController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"

function CertifyController:initialize(data)
	Controller.initialize(self)
	HasSignals.initialize(self)

	if data then
		self.data = data[1]
	end

end

function CertifyController:viewDidLoad()
	self.view:layout(self.data)
	
	self.listener = {

	}

end

function CertifyController:clickBack()
	SoundMng.playEft('btn_click.mp3')
	self.emitter:emit('back')
end

function CertifyController:clickSubmit()
	SoundMng.playEft('btn_click.mp3')
	if self.view:getName() == '' then
		tools.showRemind('真实姓名不能为空')
		return
	end
	if self.view:getCertifyNum() == '' then
		tools.showRemind('真实有效证件号不能为空')
		return
	end
end

function CertifyController:finalize()-- luacheck: ignore
	for i = 1,#self.listener do
    	self.listener[i]:dispose()
	end

	-- 停止所有动画
	self.view:stopAllAnimation()
end

return CertifyController
