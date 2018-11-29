local Distance = {}

function Distance.get()
  local x = math.random(180)
  local y = math.random(90)

  return x,y
end

local PI = 3.1415926

--[[
// 经度
longitude; -->x
// 维度
dimensionality; -->y
]]

function Distance.getDistance(startPox,endPos)
  local lon1 = (PI / 180) * startPox.x
  local lon2 = (PI / 180) * endPos.x
  local lat1 = (PI / 180) * startPox.y
  local lat2 = (PI / 180) * endPos.y

  -- 地球半径
  local R = 6371;
  --两点间距离 km，如果想要米的话，结果*1000就可以了
  local d = math.acos(math.sin(lat1) * math.sin(lat2) + math.cos(lat1) * math.cos(lat2) * math.cos(lon2 - lon1)) * R;
  return d * 1000;
end

return Distance
