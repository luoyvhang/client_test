local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local SpreadController = class("SpreadController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')
local app = require("app.App"):instance()

function SpreadController:initialize()
	Controller.initialize(self)
	HasSignals.initialize(self)
end

function SpreadController:viewDidLoad()
	self.view:layout()

	self.listener = {
		-- 填写邀请码
		app.session.user:on('inputInvitePlayerId',function(msg)
			dump(msg)
			self.view:freshBindBtn(true)
			if nil == msg then return end
			if msg.success then
				self.view:freshBindBtn(false, false)
				self.view:freshEditBox(tostring(msg.invite), false)
				app.session.user.invite = msg.invite
				self.view:freshTips(2)
				tools.showRemind("绑定成功")
			end
			if not msg.success then
				tools.showRemind(msg.errorCode)
			end
		end),
	}
	
	-- 已经有邀请人
	if app.session.user and app.session.user.invite then
		self.view:freshEditBox(tostring(app.session.user.invite), false)
		self.view:freshBindBtn(false, false)
		self.view:freshTips(2)
	else
		self.view:freshTips(1)
	end
end

function SpreadController:clickBind()
	local input = self.view:getEditBoxInfo()
	if input then
		print("inputInvitePlayerId bind", input)
		self.view:freshBindBtn(false)
		local msg = {
			msgID = 'inputInvitePlayerId',
			playerId = input
		}
		app.conn:send(msg)
	end
end

function SpreadController:clickBack()
	self.emitter:emit('back')
end

function SpreadController:finalize()-- luacheck: ignore
	for i = 1,#self.listener do
    	self.listener[i]:dispose()
  	end
end

return SpreadController
