local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local app = require("app.App"):instance()
local NotifyController = class("NotifyController", Controller):include(HasSignals)

function NotifyController:initialize()
  HasSignals.initialize(self)
  Controller.initialize(self)
end

function NotifyController:finalize()
  for i = 1,#self.listens do
    self.listens[i]:dispose()
  end
end

function NotifyController:viewDidLoad()
  self.listens = {}

  self.view:on('hide',function()
    self.emitter:emit('hide')
  end)

  app.session.user:queryNotify()
end

function NotifyController:notify(msg)
  self.view:notify(msg)
end

function NotifyController:close()
  self:delete()
end

return NotifyController
