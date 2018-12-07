local class = require('middleclass')
local XYDeskController = require('app.controllers.XYDeskController')
local QZDeskController = class('QZDeskController', XYDeskController)
local transition = require('cocos.framework.transition')
local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local app = require('app.App'):instance()

function QZDeskController:initialize(deskName)
    XYDeskController.initialize(self, deskName)
end

function QZDeskController:postAppendListens()
end

function QZDeskController:viewDidLoad()
    XYDeskController.viewDidLoad(self)
end


function QZDeskController:clickQZBettingOne()
    self.desk:qiangzhuang(1)
    self:timerFinish()
end

function QZDeskController:clickQZBettingDouble()
    self.desk:qiangzhuang(2)
    self:timerFinish()
end

function QZDeskController:clickQZBettingTriple()
    self.desk:qiangzhuang(3)
    self:timerFinish()
end

function QZDeskController:clickQZBettingFour()
    self.desk:qiangzhuang(4)
    self:timerFinish()
end

function QZDeskController:clickQZBettingZero()
    self.desk:qiangzhuang(0)
    self:timerFinish()
end

function QZDeskController:clickCloseCuoPai()
    self.view:freshCards('bottom', false, nil, 1, 5, true)
    self.view:freshCuoPaiDisplay(false, nil)
    self.view:onMessageState({msgID = 'cpBack'})
end

return QZDeskController
