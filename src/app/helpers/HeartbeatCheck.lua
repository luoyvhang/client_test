local class = require('middleclass')

local HasSignals = require('HasSignals')
local HeartbeatCheck = class("HeartbeatCheck"):include(HasSignals)

function HeartbeatCheck:initialize()
  HasSignals.initialize(self)

  self.delayHeartbeat = 0
  self.tryCntHeartbeat = 0
  self.heartbeatStep = 0
end

function HeartbeatCheck:onPing()
  self:resetHeartbeat()
  self.tryCntHeartbeat = 0

  local cur = cc.Director:getInstance():getTimeInMilliseconds()

  if self.sendTime then
    local diff = cur - self.sendTime
    self.emitter:emit('ping',diff)
  end
end

function HeartbeatCheck:resetHeartbeat()
  self.heartbeatStep = 0
  self.delayHeartbeat = 0
end

function HeartbeatCheck:update(dt)
  local app = require("app.App"):instance()

  if self.heartbeatStep == 0 then
    self.delayHeartbeat = self.delayHeartbeat + dt

    if self.delayHeartbeat > 3 then
      self.delayHeartbeat = 0

      local msg = {
        msgID = 'ping'
      }


      app.conn:send(msg)
      self.heartbeatStep = 1

      self.sendTime = cc.Director:getInstance():getTimeInMilliseconds()
    end
  elseif self.heartbeatStep == 1 then
    self.delayHeartbeat = self.delayHeartbeat + dt

    if self.delayHeartbeat > 10 then
      self.delayHeartbeat = 0
      self.tryCntHeartbeat = self.tryCntHeartbeat + 1

      print('heartbeat timeout',self.tryCntHeartbeat)

      self.emitter:emit('timeout')

      if self.tryCntHeartbeat >= 3 then
        app.conn:close()
      else
        self:resetHeartbeat()
      end
    end
  end
end


return HeartbeatCheck
