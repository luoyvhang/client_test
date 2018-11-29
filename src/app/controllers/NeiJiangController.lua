local class = require('middleclass')
local MaJiangDeskController = require('app.controllers.MaJiangDeskController')
local NeiJiangController = class("NeiJiangController", MaJiangDeskController)
local SoundMng = require('app.helpers.SoundMng')

function NeiJiangController:initialize(deskName)
  MaJiangDeskController.initialize(self,deskName)
end

function NeiJiangController:viewDidLoad()
  MaJiangDeskController.viewDidLoad(self)

  self.listener[#self.listener+1] =
    self.desk:on('freshWeidun',function()
      self.view:freshWeidun()
    end)

  self.listener[#self.listener+1] =
    self.desk:on('somebodyChi',function(player,key,isMe,cards,targetKey)
      self.view:somebodyPengGangChi(player,key,isMe,cards,'chi',nil,targetKey)
      SoundMng.playEft('woman/chi.mp3')
    end)

  self.listener[#self.listener+1] =
    self.desk:on('selectWeiDun',function(wd)
      self.view:selectWeiDun(wd)
    end)

  self.listener[#self.listener+1] =
    self.desk:on('baojiao',function()
      self.view:showReportAction()
    end)

  self.listener[#self.listener+1] =
    self.desk:on('banggang',function(msg)
      self.view:showBanggangReportAction(msg)
    end)


  self.view:on('report',function()
    self.desk:doReportJiao('report')
    self.view:showBaoJiaoPanel()
  end)

  self.view:on('baogang',function(cards)
    self.desk:doBaoGang(cards)
  end)

  self.view:on('reportSkip',function()
    self.desk:doReportJiao('reportSkip')
  end)

  self.view:on('chi',function(index,card)
    self.desk:doChi(index,card)
  end)

  self.view:on('selectWD',function(card)
    self.desk:selectWD2Server(card)
  end)
end

local suit2Sound = {
  ['东'] = 'dongfeng.mp3',
  ['南'] = 'nanfeng.mp3',
  ['西'] = 'xifeng.mp3',
  ['北'] = 'beifeng.mp3',
  ['发'] = 'facai.mp3',
  ['白'] = 'baiban.mp3',
  ['中'] = 'zhong.mp3',
}

function NeiJiangController:getSoundFromSuit(suit)
  return 'woman/'..suit2Sound[suit]
end

function NeiJiangController:customappendWanFa(list)
  if self.deskName == 'xuezhan' then
    self:appendWanFaXueZhan(list)
  else
    self:appendWanFaXueZhan(list)
  end
end

return NeiJiangController
