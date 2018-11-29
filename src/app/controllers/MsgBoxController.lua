local class = require('middleclass')
local Controller = require('mvc.Controller')
local MsgBoxController = class("MsgBoxController", Controller)
local SoundMng = require "app.helpers.SoundMng"

function MsgBoxController:initialize(title,content,btnCount)
  Controller.initialize(self)
  self.parms = {
    title = title,
    content = content,
    btnCount = btnCount,
  }
end

function MsgBoxController:next(func)
  self.func = func
end

function MsgBoxController:clickEnter()
SoundMng.playEft('btn_click.mp3')
  if self.func then
    self.func("enter")
  end
  self:delete()
end

function MsgBoxController:clickCancel()
SoundMng.playEft('btn_click.mp3')
  if self.func then
    self.func("cancel")
  end
  self:delete()
end

function MsgBoxController:viewDidLoad()
  self.view:layout(self.parms)
end

function MsgBoxController:onClickBlackLayer()-- luacheck: ignore
  SoundMng.playEft('btn_click.mp3')
  if self.func then
    self.func("blackLayer")
  end
  print(' onClickBlackLayer ')

  self:delete()
end

return MsgBoxController
