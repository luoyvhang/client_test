local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local MessageController = class("MessageController", Controller):include(HasSignals)

function MessageController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function MessageController:viewDidLoad()
  local app = require("app.App"):instance()
  local user = app.session.user
  self.view:layout()

  self.listener = {
    user:on('getNotify',function(msg)
      self.view:getNotify(msg)
    end),
  }

  user:getNotify()
end

function MessageController:clickBack()
  self.emitter:emit('back')
end

function MessageController:finalize()-- luacheck: ignore
  for i = 1,#self.listener do
    self.listener[i]:dispose()
  end
end

function MessageController:clicktab(sender)
  local data = sender:getComponent("ComExtensionData"):getCustomProperty()
  self.view:freshtab(data)
end

return MessageController
