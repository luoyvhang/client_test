local FormatTime = {}
function FormatTime.format(diff)
  local hour_seconds = 60 * 60

  if diff > hour_seconds then
    local hour = math.floor(diff / hour_seconds)
    local minute = math.floor((diff - hour * hour_seconds) / 60)
    return string.format('%2d时%2d分',hour,minute)
  else
    local minute = math.floor(diff / 60)
    local second = math.floor(diff % 60)
    return string.format('%02d分%02d秒',minute,second)
  end
end

return FormatTime
