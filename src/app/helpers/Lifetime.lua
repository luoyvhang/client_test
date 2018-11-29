local Lifetime = {}

function Lifetime:initialize(lifetime)
  self._lifetime = lifetime
  self._runtime = 0
end

function Lifetime:update(time)
  self._runtime = self._runtime + time
  if self._runtime > self._lifetime then
    self._runtime = self._lifeime
  end
end

function Lifetime:done()
  return self._runtime == self._lifeime
end

function Lifetime:progress()
  return self._runtime / self._lifeime
end

function Lifetime:reset(lifetime)
  if lifetime then
    self._lifeime = lifetime
  end
  self._runtime = 0
end


return Lifetime
