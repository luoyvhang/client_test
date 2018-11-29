local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local ExchangeController = class("ExchangeController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function ExchangeController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function ExchangeController:viewDidLoad()
  local app = require("app.App"):instance()

  self.view:layout()

  self.listener = {

  }
end

function ExchangeController:clickBack()
  self.emitter:emit('back')
end

function ExchangeController:clickSub()
  self.view:clickSub()
end

function ExchangeController:clickAdd()
  self.view:clickAdd()
end

function ExchangeController:clickExchange()
  local app = require("app.App"):instance()
  local jewels = self.view.needjewels
  if jewels == 0 then
    tools.showRemind('兑换的房钻必须大于0')
    return
  end

  app.session.user:exchangeLucks(jewels)
end

function ExchangeController:finalize()-- luacheck: ignore
  for i = 1,#self.listener do
    self.listener[i]:dispose()
  end
end

function ExchangeController:clickExchange()
  local app = require("app.App"):instance()
  if app.session.user.diamond <= 0 then
    tools.showRemind('钻石不足')
  else
    app.session.user:exchange()
  end
end

return ExchangeController
