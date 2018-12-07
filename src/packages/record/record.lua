local invoke = require('invoke')
local Record = {}

function Record.go(filename)
  if device.platform ~= 'ios' and device.platform ~= 'android' then return end
  invoke('com.shininggames.record.Recorder', 'startRecording',filename)
end

function Record.getAmplitude()
  if device.platform ~= 'ios' and device.platform ~= 'android' then return end
  return invoke('com.shininggames.record.Recorder', 'getAmplitude','not')
end

function Record.stopRecording(callback)
  if device.platform ~= 'ios' and device.platform ~= 'android' then return end
  
  if device.platform == 'android' then
    invoke('com.shininggames.record.Recorder', 'stopRecording','not')
    callback()
  elseif device.platform == 'ios' then
    invoke('com.shininggames.record.Recorder', 'stopRecording','not',callback)
  end
end

return Record
