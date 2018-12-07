local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local SummaryController = class("SummaryController", Controller):include(HasSignals)

function SummaryController:initialize(desk,data,record)
  Controller.initialize(self)
  HasSignals.initialize(self)

  self.desk = desk
  self.data = data
  self.record = record
end

function SummaryController:viewDidLoad()
  self.view:layout()
  self.view:loadByDesk(self.desk,self.data,self.record)
end

function SummaryController:clickBack()
  self.emitter:emit('back')
end

function SummaryController:finalize()-- luacheck: ignore
end

function SummaryController:clickShare()
  local CaptureScreen = require('app.helpers.capturescreen')
  local SocialShare = require('app.helpers.SocialShare')

  CaptureScreen.capture('screen.jpg',function(ok,path)
    if ok then
      if device.platform == 'ios' then
        path = cc.FileUtils:getInstance():getWritablePath()..path
      end

      SocialShare.share(1,function(stcode)
        print('stcode is ',stcode)
      end,
      nil,
      path,
      '我在曲靖小鸡麻将中玩的很嗨，快来加入我们吧',
      '众人乐棋牌',true)
    end
  end,self.view,0.8)
end

return SummaryController
