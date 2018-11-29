local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local SendController = class("SendController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function SendController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function SendController:viewDidLoad()
  self.view:layout()
end

function SendController:clickBack()
  self.emitter:emit('back')
end

function SendController:finalize()-- luacheck: ignore
end

function SendController:clickSure()
  local id,diamond = self.view:getIdAndDiamond()

  if id == nil or diamond == nil then
    tools.showRemind('请填写正确的数字')
    return
  end

  local app = require("app.App"):instance()
  app.session.user:giveRes(id,diamond)
end

function SendController:clickBlack()
  self.view:clickBlack()
end

return SendController
