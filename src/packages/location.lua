local Location = {}
local invoke = require('invoke')

function Location.getLatitude()
  -- if device.platform == 'android' or device.platform == 'ios' then
  --   local b = invoke('com.shininggames.location.Location','getLatitude','not')
  --   return b
  -- else
  --   return 0
  -- end
  return 0
end

function Location.getLongitude()
  -- if device.platform == 'android' or device.platform == 'ios'  then
  --   local b = invoke('com.shininggames.location.Location','getLongitude','not')
  --   return b
  -- else
  --   return 0
  -- end
  return 0
end

function Location.getGPS()
  local Longitude = Location.getLongitude()
  local Latitude = Location.getLatitude()

  return Latitude,Longitude
end

return Location
