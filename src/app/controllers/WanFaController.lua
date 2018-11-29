local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local WanFaController = class("WanFaController", Controller):include(HasSignals)

function WanFaController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function WanFaController:viewDidLoad()
  self.view:layout()
end

function WanFaController:clickBack()
  self.emitter:emit('back')
end

function WanFaController:clickTab(sender)
  local tag = sender:getTag()
  self.view:clickTab(tag)
end

function WanFaController:finalize()-- luacheck: ignore
end

function WanFaController:clickNotOpen()
  local tools = require('app.helpers.tools')
  tools.showRemind('暂未开放，敬请期待')
end

return WanFaController
