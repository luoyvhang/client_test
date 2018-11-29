local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local EnterRoomController = class("EnterRoomController", Controller):include(HasSignals)
local SoundMng = require "app.helpers.SoundMng"

function EnterRoomController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function EnterRoomController:viewDidLoad()
  self.view:layout()

  self.view:on('clickEnterGame',function()
    self:clickEnterGame()
  end)
end

function EnterRoomController:clickBack()
  SoundMng.playEft('btn_click.mp3')
  self.view:stopCsdAnimation()
  self.emitter:emit('back')
end

function EnterRoomController:clickClear()
  SoundMng.playEft('btn_click.mp3')
  self.view:clear()
end

function EnterRoomController:clickDelete()
  SoundMng.playEft('btn_click.mp3')
  self.view:clickDelete()
end

function EnterRoomController:clickReenter()
  SoundMng.playEft('btn_click.mp3')
  self.view:clickReenter()
end

function EnterRoomController:clickJoin()
  SoundMng.playEft('btn_click.mp3')
  self.view:clickJoin()
end

function EnterRoomController:clickHide()
  SoundMng.playEft('btn_click.mp3')
  self.emitter:emit('back')
end

function EnterRoomController:buyHorse(sender)
  local select = sender:getChildByName("select")
  self.buy = not select:isVisible()
  select:setVisible(self.buy)
end

function EnterRoomController:clickEnterGame()
  -- 102014
  local app = require("app.App"):instance()
  local roomNo = self.view.roomNo
  app.session.room:enterRoom(roomNo, false or self.buy)
end

function EnterRoomController:finalize()-- luacheck: ignore
end

return EnterRoomController
