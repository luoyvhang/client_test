local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local HelpController = class("HelpController", Controller):include(HasSignals)

function HelpController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function HelpController:viewDidLoad()
  self.view:layout()
end

function HelpController:clickBack()
  self.emitter:emit('back')
end

function HelpController:clickTab(sender)
  local tag = sender:getTag()
  self.view:clickTab(tag)
end

function HelpController:finalize()-- luacheck: ignore
end

function HelpController:clickNotOpen()
  local tools = require('app.helpers.tools')
  tools.showRemind('暂未开放，敬请期待')
end

return HelpController

