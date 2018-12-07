local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local VipController = class("VipController", Controller):include(HasSignals)

function VipController:initialize(targetPos)
  Controller.initialize(self)
  HasSignals.initialize(self)

  self.targetPos = targetPos
end

function VipController:viewDidLoad()
  self.view:layout(self.targetPos)
end

function VipController:clickBack()
  self.emitter:emit('back')
end

function VipController:finalize()-- luacheck: ignore
end

return VipController
