local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local UserController = class("UserController", Controller):include(HasSignals)

function UserController:initialize(player)
  Controller.initialize(self)
  HasSignals.initialize(self)

  self.player = player
end

function UserController:viewDidLoad()
  self.view:layout(self.player)
end

function UserController:clickBack()
  self.emitter:emit('back')
end

function UserController:finalize()-- luacheck: ignore
end

return UserController
