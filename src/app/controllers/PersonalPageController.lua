local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local PersonalPageController = class('PersonalPageController', Controller):include(HasSignals)

function PersonalPageController:initialize(data)
	Controller.initialize(self)
  	HasSignals.initialize(self)
    
    self.data = data[1]
    if #data > 1 then
        self.desk = data[2]
    end
end

function PersonalPageController:viewDidLoad()
    self.view:layout(self.data)

    local app = require('app.App'):instance()
    self.listener = {

        self.view:on("choosed", function(msg)
            local tmsg = {
                msgID = 'chatInGame',
                type = 3,
                msg = msg
            }
            app.conn:send(tmsg)
            self.emitter:emit('back')
        end),

        self.view:on("playoldvoice", function(msg)
            if self.desk then
                self.desk:getLastVoice(msg)
                self.emitter:emit('back')
            end
        end)
    }
end

function PersonalPageController:clickBack()
  	self.emitter:emit('back')
end

function PersonalPageController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return PersonalPageController
