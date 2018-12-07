local FormatRes = {}
function FormatRes.format(num)
  num = math.floor(num)
  if num < 1000 then
    return num
  end

  local k = math.floor(num / 1000)
  local m = math.floor(num % 1000) / 1000

  return string.format('%.2fk',(k + m))
end

return FormatRes
