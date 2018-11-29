local class = require('middleclass')
local Hex = class('Hex')

function Hex:initialize(q, r, s)
  self.q, self.r, self.s = q, r, s or (-q-r)
end

function Hex:__tostring()
  return ('Hex[%f, %f, %f]'):format(self.q, self.r, self.s)
end

function Hex:__add(rhs)
  return Hex:new(self.q + rhs.q, self.r + rhs.r, self.s + rhs.s)
end


function Hex:__sub(rhs)
  return Hex:new(self.q - rhs.q, self.r - rhs.r, self.s - rhs.s)
end

function Hex:__mul(k)
  if type(self) == 'number' then
    return Hex(k.q * self, k.r * self, k.s * self)
  else
    return Hex(self.q * k, self.r * k, self.s * k)
  end
end

function Hex:scale(k)
  self.q, self.r, self.s = self.q * k, self.r * k, self.s * k
  return self
end

function Hex:__eq(rhs)
  return self.q == rhs.q and self.r == rhs.r and self.s == rhs.s
end

function Hex:length()
  return (math.abs(self.q) + math.abs(self.r) + math.abs(self.s)) / 2
end


local directions = {
  Hex:new(1, 0, -1), Hex:new(1, -1, 0),
  Hex:new(0, -1, 1), Hex:new(-1, 0, 1),
  Hex:new(-1, 1, 0), Hex:new(0, 1, -1)
}



function Hex.static.direction(direction)
  return directions[direction]
end

function Hex:neighbor(direction)
  return self + Hex.direction(direction)
end




function Hex:round()
  local q = math.floor(self.q+0.5)
  local r = math.floor(self.r+0.5)
  local s = math.floor(self.s+0.5)
  local q_diff = math.abs(q - self.q)
  local r_diff = math.abs(r - self.r)
  local s_diff = math.abs(s - self.s)

  if q_diff > r_diff and q_diff > s_diff then
    q = -r - s
  elseif r_diff > s_diff then
    r = -q - s
  else
    s = -q - r
  end

  self.q, self.r, self.s = q, r, s

  return self
end


function Hex.static.distance(a, b)
  return (a - b):length()
end


function Hex.static.lerp(a, b, t)
  return Hex:new(a.q + (b.q - a.q) * t, a.r + (b.r - a.r) * t, a.s + (b.s - a.s) * t)
end


function Hex.static.linedraw(a, b)
  local N = Hex.distance(a, b)
  local results = {}
  local step = 1.0 / math.max(N, 1)
  for i = 0, N do
    results[#results+1] = Hex.lerp(a, b, step * i):round()
  end
  return results
end


return Hex
