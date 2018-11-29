local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local KefuController = class("KefuController", Controller):include(HasSignals)

function KefuController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function KefuController:viewDidLoad()
  local app = require("app.App"):instance()

  self.listener = {
    app.session.user:on('queryContact',function(msg)
      self.view:fresh(msg)
    end)
  }

  self.view:layout()
  app.session.user:queryContact()
end

function KefuController:clickBack()
  self.emitter:emit('back')
end

function KefuController:finalize()
  for i = 1,#self.listener do
    self.listener[i]:dispose()
  end
end

return KefuController
