local CalcLevelUpSolider = {}
function CalcLevelUpSolider.calc(level)
  local cost = math.floor(400 + 200 * level * level / 2)
  if cost > 400000 then cost = 400000 end
  return cost
end

function CalcLevelUpSolider.calcTime(level)
  return math.floor(10 + level * 300)
end

function CalcLevelUpSolider.calcGem(level)
  return math.floor(CalcLevelUpSolider.calcTime(level) / 3600 * 10)
end

function CalcLevelUpSolider.calcAttribue(value, level)
  return  value * (1 + CalcLevelUpSolider.getLevelUpPercent(level))
end

function CalcLevelUpSolider.getLevelUpPercent(level)
  return 0.1 * level
end

return CalcLevelUpSolider
