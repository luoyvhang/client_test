local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local ActivityController = class("ActivityController", Controller):include(HasSignals)

function ActivityController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function ActivityController:viewDidLoad()
  local app = require("app.App"):instance()
  local user = app.session.user
  self.view:layout()

end

function ActivityController:clickBack()
  self.view:stopCsdAnimation()
  self.emitter:emit('back')
end

function ActivityController:finalize()-- luacheck: ignore
 
end

return ActivityController
