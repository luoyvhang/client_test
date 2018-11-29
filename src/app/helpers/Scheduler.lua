local Scheduler = {}
local sc = cc.Director:getInstance():getScheduler()

function Scheduler.new(call)
  return sc:scheduleScriptFunc(call,0,false)
end

function Scheduler.delete(call)
  sc:unscheduleScriptEntry(call)
end

return Scheduler
