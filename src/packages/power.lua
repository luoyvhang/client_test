local Power = {}
local invoke = require('invoke')

function Power.getNetPower(callback)
  if device.platform == 'android' or device.platform == 'ios' then
    invoke('com.shininggames.power.Power','getNetPower','not',function(power)
      callback(power)
    end)
  else
    callback(100)
  end
end

function Power.getBatteryPower(callback)
  if device.platform == 'android' or device.platform == 'ios'  then
    invoke('com.shininggames.power.Power','getBatteryPower','not',function(power)
      print('power is ',power)

      callback(power)
    end)
  else
    callback(100)
  end
end

return Power
