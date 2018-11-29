local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local TaskController = class("TaskController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')
local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"

function TaskController:initialize(data)
	Controller.initialize(self)
	HasSignals.initialize(self)

	self.data = data
	self.user = data[1]
	self.type = data[2]

end 

function TaskController:viewDidLoad()
	self.view:layout(self.data)

	self.listener = {
		app.session.user:on('SignInRecord',function(msg)
			self.view:freshInfo(msg)
		end),

		app.session.user:on('SignInResult',function(msg)
			if msg then
				if msg.code == 0 then
					tools.showRemind('签到成功')
				elseif msg.code == -1 then
					tools.showRemind('你已经签过到了')
				end
				self.view:freshInfo(msg)
			end
		end),
	}

	app.session.user:querySignInRecord()

end

function TaskController:clickBack()
	SoundMng.playEft('btn_click.mp3')
	self.emitter:emit('back')
end

function TaskController:clickSign()
	local date = os.date("*t", os.time())
	app.session.user:querySignIn(date)
end

function TaskController:finalize()-- luacheck: ignore
	for i = 1,#self.listener do
    	self.listener[i]:dispose()
	end
end

return TaskController
