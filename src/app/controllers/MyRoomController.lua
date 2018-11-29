local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local MyRoomController = class("MyRoomController", Controller):include(HasSignals)
local invokefriend = require('app.helpers.invokefriend')

function MyRoomController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function MyRoomController:viewDidLoad()
  local app = require("app.App"):instance()

  self.view:layout()
  self.listener = {
    app.session.room:on('listRooms',function(rooms)
      self.view:loadRooms(rooms)
    end),
    app.session.room:on('dismisscomplete',function()
      app.session.room:listRooms()
    end),
    app.session.room:on('deletecomplete',function()
      app.session.room:listRooms()
    end)
  }

  app.session.room:listRooms()

  -- view events
  self.view:on('fresh',function()
    app.session.room:listRooms()
  end)

  self.view:on('dismiss',function(room)
    app.session.room:dismiss(room.id)
  end)

  self.view:on('delete',function(room)
    app.session.room:delete(room.id)
  end)

  self.view:on('enter',function(room)
    app.session.room:enterRoom(room.deskId)
  end)

  self.view:on('invoke',function(room)
    invokefriend.invoke(room)
  end)
end

function MyRoomController:clickBack()
  self.emitter:emit('back')
end

function MyRoomController:clickBlack()
  self.view:clickBlack()
end

function MyRoomController:closeRoomInfo()
  self.view:clickBlack()
end

function MyRoomController:finalize()
  for i = 1,#self.listener do
    self.listener[i]:dispose()
  end
end

return MyRoomController
