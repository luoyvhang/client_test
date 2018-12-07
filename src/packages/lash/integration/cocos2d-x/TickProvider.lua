local class = require('middleclass')

--[[
Uses the scheduler to provide a frame tick where the frame duration is the time since the previous frame.
]]

local TickProvider = class('TickProvider')


--[[
Applies a time adjustement factor to the tick, so you can slow down or speed up the entire engine.
The update tick time is multiplied by this value, so a value of 1 will run the engine at the normal rate.
]]

local scheduler = cc.Director:getInstance():getScheduler()


function TickProvider:initialize(callback)
  self.callback = callback
end


function TickProvider:start()
  if self.sched  then return end

  self.sched = scheduler:scheduleScriptFunc(self.callback, 0, false)
end


function TickProvider:stop()
  if not self.sched then return end

  scheduler:unscheduleScriptEntry(self.sched)
  self.sched = nil
end

return TickProvider
