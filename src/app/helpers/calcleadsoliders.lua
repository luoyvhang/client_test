local CalcLeadSoliders = {}

function CalcLeadSoliders.calc(lvl)
  local min_s = 200
  local max_s = 2000

  local min_l = 1
  local max_l = 40

  local ret = (lvl - min_l) / (max_l - min_l) * (max_s - min_s) + min_s
  return math.floor(ret)
end

return CalcLeadSoliders
