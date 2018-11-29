local Hex = require('graph.Hex')
local Layout = {}
Layout.__index = Layout


local function Orientation(f0, f1, f2, f3, b0, b1, b2, b3, start_angle)
  return {
    f0 = f0,
    f1 = f1,
    f2 = f2,
    f3 = f3,
    b0 = b0,
    b1 = b1,
    b2 = b2,
    b3 = b3,
    start_angle = start_angle
  }
end


local SQRT3 = math.sqrt(3.0)

local orientations = {
  pointy = Orientation(SQRT3, SQRT3 / 2.0, 0.0, 3.0 / 2.0, SQRT3 / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5),
  flat = Orientation(3.0 / 2.0, 0.0, SQRT3 / 2.0, SQRT3, 2.0 / 3.0, 0.0, -1.0 / 3.0, SQRT3 / 3.0, 0.0)
}


function Layout:new(orientation, sizeX, sizeY, originX, originY) -- luacheck: ignore self
  local o = orientations[orientation]
  assert(o, 'unknown orientation name')
  return setmetatable({
    orientation=o,
    sizeX=sizeX,
    sizeY=sizeY,
    originX=originX,
    originY=originY,
  }, Layout)
end

function Layout:hexToPixel(h)
  local M = self.orientation
  local x = (M.f0 * h.q + M.f1 * h.r) * self.sizeX
  local y = (M.f2 * h.q + M.f3 * h.r) * self.sizeY
  return x + self.originX, y + self.originY
end


function Layout:pixelToHex(x, y)
  local M = self.orientation
  local px, py = (x-self.originX)/self.sizeX, (y-self.originY)/self.sizeY
  local q = M.b0 * px + M.b1 * py
  local r = M.b2 * px + M.b3 * py
  return Hex:new(q, r, -q - r):round()
end


function Layout:hexCornerOffset(corner)
  local M = self.orientation
  local angle = 2.0 * math.PI * (corner + M.start_angle) / 6
  return self.sizeX * math.cos(angle), self.sizeY * math.sin(angle)
end


function Layout:polygonCorners(h)
  local corners = {}
  local center = self:hexToPixel(h)
  for i = 0, 5 do
    local offset = self:hexCornerOffset(i)
    corners[#corners+1] = {center.x + offset.x, center.y + offset.y}
  end
  return corners
end


setmetatable(Layout, {__call=Layout.new})

return Layout
