local class = require('middleclass')
local XYDeskController = require('app.controllers.XYDeskController')
local SZDeskController = class('SZDeskController', XYDeskController)
local SoundMng = require('app.helpers.SoundMng')
local app = require('app.App'):instance()
local tools = require('app.helpers.tools')

function SZDeskController:initialize(deskName)
    XYDeskController.initialize(self, deskName)
end

function SZDeskController:postAppendListens()
end

function SZDeskController:viewDidLoad()
    XYDeskController.viewDidLoad(self)
end

function SZDeskController:onQiangZhuang(msg)
    self.view:freshQiangZhuangBar(true)
end

function SZDeskController:clickCloseCuoPai()
    self.view:freshCards('bottom', false, nil, 1, 5, true)
    self.view:freshCuoPaiDisplay(false, nil)
    self.view:onMessageState({msgID = 'cpBack'})
end

function SZDeskController:clickSQZYes()
    self.view:freshQiangZhuangBar(false)
    self.desk:qiangzhuang(1)
    self:timerFinish()
end

function SZDeskController:clickSQZNo()
    self.view:freshQiangZhuangBar(false)
    self.desk:qiangzhuang(0)
    self:timerFinish()
end

return SZDeskController
