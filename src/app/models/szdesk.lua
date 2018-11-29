local class = require('middleclass')
local XYDesk = require('app.models.xydesk')
local SZDesk = class("SZDesk", XYDesk)

function SZDesk:initialize()
    XYDesk.initialize(self)

    self:listen()
end

function SZDesk:onCustomSwitch()
    local app = require('app.App'):instance()
    app:switch('SZDeskController', self.DeskName)
end

function SZDesk:onPutMoney(msg)
    self.emitter:emit('freshBettingBar', msg)
    self.emitter:emit('bettingTimerStart')
end

function SZDesk:onQiangZhuang()
    self.emitter:emit('qiangZhuang')
    self.emitter:emit('qzTimerStart')
end


return SZDesk
