local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local DeskController = class("DeskController", Controller):include(HasSignals)
local TranslateView = require('app.helpers.TranslateView')

function DeskController:initialize(deskName)
  local app = require("app.App"):instance()

  Controller.initialize(self)
  HasSignals.initialize(self)
  self.deskName = deskName
  print('self.deskName is ',self.deskName)
  self.desk = app.session[self.deskName]

  self.isPausedBGM = false
end

function DeskController:finalize()
  for i = 1,#self.listener do
    self.listener[i]:dispose()
  end
end

function DeskController:viewDidLoad()
  local app = require("app.App"):instance()

  self.listener = {
    app.conn:on('ping',function()
      self.view:onPing()
    end),
    self.desk:on('somebodySitdown',function()
      self.view:freshPrepareUI()
    end),
    self.desk:on('somebodyPrepare',function()
      self.view:freshPrepareUI()
    end),
    self.desk:on('somebodyLeave',function()
      self.view:freshPrepareUI()
    end),
    self.desk:on('start',function(key)
      self.view:freshBanker(key)
      print('call playBeginAnimation action')
      self.view:playBeginAnimation()
    end),
    self.desk:on('dealt',function()
      self.view:freshDesk()
    end),
    self.desk:on('chgCurrent',function(msg)
      self.view:freshFlipCardByCurrent(msg)
    end),
    self.desk:on('onPlaySuccess',function(msg)
      if self.onPlaySuccess then
        self.onPlaySuccess(msg)
        self.onPlaySuccess = nil
      end
    end),
    self.desk:on('action',function(msg)
      self.view:showActionPanel(msg)
    end),
    self.desk:on('summary',function()
      self.view:setState('prepare')
      self.view:clearDesk()
      self:loadRoundSummary()
    end),
  }
  self.view:layout(self.desk)

  self.view:on('play',function(card,onPlaySuccess)
    self.onPlaySuccess = onPlaySuccess
    self.desk:play(card)
  end)

  self.view:on('skip',function()
    self.view:hideActionPanel()
    self.desk:skip()
  end)

  -- 自动准备
  if self.desk.info.state == nil then
    self.desk:prepare()
  end

  self.view:load()
  --self:loadRoundSummary()
end

function DeskController:loadRoundSummary()
  local ctrl = Controller:load('RoundSummaryController')
  self:add(ctrl)

  local app = require("app.App"):instance()
  app.layers.ui:addChild(ctrl.view)
  ctrl.view:setPositionX(display.width)

  TranslateView.moveCtrl(ctrl.view,-1)

  ctrl:on('back',function()
    TranslateView.moveCtrl(ctrl.view,1,function()
      ctrl:delete()

      if self.finalSummary then
        self:loadSummary(self.finalSummary,self.record)
        self.finalSummary = nil
        self.record = nil
      end
    end)

    self.desk:prepare()
  end)

  ctrl:on('again',function()
    self:clickPrepare()
  end)

  self.roundSummary = ctrl
end

return DeskController
