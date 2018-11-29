local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local MagicExpressController = class("MagicExpressController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')
local cjson = require('cjson')

local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"

function MagicExpressController:initialize(data)
	Controller.initialize(self)
	HasSignals.initialize(self)

	if data then
		self.data = data[1]
	end

end

function MagicExpressController:viewDidLoad()
	self.view:layout(self.data)
	
	self.listener = {

	}
end

function MagicExpressController:clickBack()
	SoundMng.playEft('btn_click.mp3')
	self.emitter:emit('back')
end

function MagicExpressController:clickChange(sender)
	SoundMng.playEft('btn_click.mp3')
	local data = sender:getComponent("ComExtensionData"):getCustomProperty()
	self.view:changeTab(sender, data)
end

function MagicExpressController:clickCancel(sender)
	SoundMng.playEft('btn_click.mp3')
	self.view:freshOneExpress(sender)
end

function MagicExpressController:clickItem(sender)
	SoundMng.playEft('btn_click.mp3')
	local data = sender:getComponent("ComExtensionData"):getCustomProperty()
	self.view:setSelect(sender, data)
end

function MagicExpressController:finalize()-- luacheck: ignore
	for i = 1,#self.listener do
    	self.listener[i]:dispose()
	end

	-- 停止所有动画
	self.view:stopAllAnimation()
end

return MagicExpressController
