local CalcPVECost = {}
function CalcPVECost.cost(level)
  local min = 1
  local max = 40

   if level < min then level = min end
  if level > max then level = max end

  local min_cost = 400
  local max_cost = 10000

  local cost = (level - min) / (max - min) * (max_cost - min_cost) + min_cost
  return math.floor(cost)
end

return CalcPVECost
