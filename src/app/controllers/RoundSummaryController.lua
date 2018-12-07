local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local RoundSummaryController = class("RoundSummaryController", Controller):include(HasSignals)
local CaptureScreen = require('app.helpers.capturescreen')
local SocialShare = require('app.helpers.SocialShare')

function RoundSummaryController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function RoundSummaryController:viewDidLoad()
  self.view:layout(self.data,self.desk,self.isover)

  self.view:on('share',function()
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
    end,self.view,0.8,function()
      local list = self.view.MainPanel:getChildByName('middle'):getChildByName('list')
      list:setClippingEnabled(false)
    end)
  end)
end

function RoundSummaryController:clickBack()
  self.emitter:emit('back')
end

function RoundSummaryController:clickAgain()
  self.emitter:emit('again')
  self.emitter:emit('back')
end

function RoundSummaryController:clickTab(sender)
  local tag = sender:getTag()
  self.view:clickTab(tag)
end

function RoundSummaryController:finalize()-- luacheck: ignore
end

return RoundSummaryController
