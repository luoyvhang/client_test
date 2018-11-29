local class = require('middleclass')
local HasSignals = require('HasSignals')
local Session = class('Session'):include(HasSignals)

function Session:initialize()
    local User = require('app.models.User')
    local Room = require('app.models.Room')
    local Login = require('app.models.Login')
    local Net = require('app.models.Net')
    local Desk = require('app.models.desk')
    local Record = require('app.models.Record')
    local AppEvent = require('app.models.AppEvent')

    --local XYDesk = require('app.models.xydesk') -- xy : xiaoyao
    local SZDesk = require('app.models.szdesk') -- sz : niumowang 固定上庄
    local QZDesk = require('app.models.qzdesk') -- qz : niumowang 明牌抢庄

    local Group = require('app.models.Group') -- 牛友群
    local Scheme = require('app.models.Scheme') -- 唤醒

    HasSignals.initialize(self)
    self.user = User()
    self.login = Login()
    self.room = Room()
    self.net = Net()
    self.qidong1 = Desk()
    self.record = Record()
    self.appEvent = AppEvent()
    self.niumowang = SZDesk()
    self.niumowangqz = QZDesk()
    self.group = Group()
    self.scheme = Scheme()

    if device.platform == 'ios' then
        local Iap = require('app.models.Iap') -- 苹果内购
        self.iap = Iap()
    end
end

function Session:getServerTime()
    return (os.time() - self.mistiming)
end

return Session
