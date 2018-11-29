local CalcHeroExp = {}
local Heroes = require('app.models.Heroes')

function CalcHeroExp.calc(level)
  local cfg = Heroes.getExperience().herolvexp

  local rLevel = level + 1
  if rLevel > #cfg then
    return 10000000000
  else
    return cfg[rLevel]
  end
end

return CalcHeroExp
