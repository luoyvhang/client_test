local AnimationProgress = {}
local Scheduler = require('app.helpers.Scheduler')

function AnimationProgress.destroy(bar)
  if bar.updatef then
    Scheduler.delete(bar.updatef)
    bar.updatef = nil
  end
end

function AnimationProgress.go(bar,percent)
  AnimationProgress.destroy(bar)

  if bar.desPercent then
    bar:setPercent(bar.desPercent)
    bar.desPercent = nil
  end

  bar.desPercent = percent
  local speed = 100
  bar.updatef = Scheduler.new(function(dt)
    speed = speed + 100 * dt

    local sign = 1

    local cur = bar:getPercent()
    if cur > bar.desPercent then
      sign = -1
    end

    cur = cur + speed * dt * sign
    if (sign == 1 and cur > bar.desPercent) or (sign == -1 and cur < bar.desPercent) then
      cur = bar.desPercent

      AnimationProgress.destroy(bar)
    end

    bar:setPercent(cur)
  end)
end

return AnimationProgress
