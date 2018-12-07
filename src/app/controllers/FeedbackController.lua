local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local FeedbackController = class('FeedbackController', Controller):include(HasSignals)

function FeedbackController:initialize()
	Controller.initialize(self)
  	HasSignals.initialize(self)
end

function FeedbackController:viewDidLoad()
	self.view:layout()
end

function FeedbackController:clickBack()
  self.emitter:emit('back')
end

function FeedbackController:clickSend()
	-- body
end

function FeedbackController:finalize()-- luacheck: ignore
end

return FeedbackController