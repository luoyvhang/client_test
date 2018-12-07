local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local DistanceController = class("DistanceController", Controller):include(HasSignals)

function DistanceController:initialize(desk)
  Controller.initialize(self)
  HasSignals.initialize(self)

  self.desk = desk
end

function DistanceController:viewDidLoad()
  self.view:layout(self.desk)
end

function DistanceController:clickBack()
  self.emitter:emit('back')
end

function DistanceController:finalize()-- luacheck: ignore
end

return DistanceController
