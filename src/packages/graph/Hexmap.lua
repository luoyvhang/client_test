
local class = require('middleclass')
local Hex = require('graph.Hex')


local Hexmap = class('Hexmap')


-- returns col, row
local function axial_to_even_r_offset(q, r)
  -- local x, z = q, r -- axial to cube
  -- local col, row = x + (z + (z&1)) / 2, z -- cube to even-r offset
  return q + (r + r%2)/2, r
end

-- returns q, r
local function even_r_offset_to_axial(col, row)
  -- local x, z = col - (row + (row&1)) / 2, row -- odd-r offset to cube
  -- local q, r = x, z -- axial to cube
  return col - (row+row%2)/2, row
end

function Hexmap:initialize(w, h, evenw)
  self.w, self.h = w, h
  self.evenw = evenw or w


  for row=1,h do
    local line = {}
    local rw = row % 2 ~= 0 and w or self.evenw

    for col=1, rw do
      local q, r = even_r_offset_to_axial(col, row)
      local hex = Hex(q, r)
      hex.cost = 1
      line[q] = hex
    end
    self[row] = line
  end
end

function Hexmap:has(q, r)
  return self[r] ~= nil and self[r][q] ~= nil
end

function Hexmap:at(q, r)
  if not self[r] then
    return nil
  end
  return self[r][q]
end

function Hexmap:node(index)
  return self:at(index.q, index.r)
end

function Hexmap:take(hex)
  local cell = self:at(hex.q, hex.r)
  assert(cell.cost == 1, 'Attempt to take a non free hex: '..tostring(hex))
  cell.cost = math.huge
end

function Hexmap:free(hex)
  local cell = self:at(hex.q, hex.r)
  assert(cell.cost == math.huge, 'Attempt to free a non taken hex: '..tostring(hex))
  cell.cost = 1
end

function Hexmap:isTaken(hex)
  local cell = self:at(hex.q, hex.r)
  return cell.cost == math.huge
end

function Hexmap:neighbors(loc)
  local results = {}

  for dir = 1,6 do
    local n = loc:neighbor(dir)
    local hex = self:at(n.q, n.r)
    if hex then
      results[#results+1] = hex
    end
  end

  return results
end

function Hexmap:cost(_, to)
  local hex = self:at(to.q, to.r)
  return hex and hex.cost or math.huge
end


function Hexmap:distance(from, to) -- luacheck: ignore self
  return Hex.distance(from, to)
end

function Hexmap:__tostring()
  local lines = {}

  for r=1,self.h do

    local s0 = (r % 2) == 0 and '     | ' or '| '
    local s1 = s0

    local rw = r % 2 ~= 0 and self.w or self.evenw
    local q0, _ = even_r_offset_to_axial(1, r)
    local q1, _ = even_r_offset_to_axial(rw, r)
    for q=q0, q1 do

      s0 = s0 ..'        | '
      s1 = s1 ..string.format('%+03d,%+03d | ', q, r)
    end
    lines[#lines+1] = s0
    lines[#lines+1] = s1
    lines[#lines+1] = s0
    lines[#lines+1] = ''
  end
  return '\n'..table.concat(lines, '\n')
end

local html = [[
<html>
  <head><title>Hexmap</title>
  <style>
    body {
      font-family: 'Source Sans Pro', 'Open Sans', 'Lucida Grande', 'Lucida Sans Unicode', 'Lucida Sans', Tahoma, sans-serif;
      background: #B2B2B2;
    }
    .hex {
      float: left;
      margin-left: 1px;
      margin-bottom: -19px;
    }
    .hex .top {
      width: 0;
      border-bottom: 20px solid #F3F3F0;
      border-left: 35px solid transparent;
      border-right: 35px solid transparent;
    }
    .hex .middle {
      width: 70px;
      height: 40px;
      background: #F3F3F0;
    }
    .hex .bottom {
      width: 0;
      border-top: 20px solid #F3F3F0;
      border-left: 35px solid transparent;
      border-right: 35px solid transparent;
    }
    .hex:hover .top {
      border-bottom: 20px solid #C1D6CF;
    }
    .hex:hover .middle {
      background-color:#C1D6CF;
    }
    .hex:hover .bottom {
      border-top: 20px solid #C1D6CF;
    }

    .hex-row {
      clear: left;
    }
    .hex-row.even {
      margin-left: 36px;
    }
    span.q {
      margin-left: 8px;
      float: left;
      font-size: 14px;
      font-weight: bold;
      color: #59B200;
    }
    span.r {
      margin-right: 8px;
      float: right;
      font-size: 14px;
      font-weight: bold;
      color: #0098E5;
    }
  </style>
  </head>
  <body>
    <div style="float: left;">
%s
    </div>
  </body>
</html>

]]
local hex = '        <div class="hex"><div class="top"></div><div class="middle"><span class="q">%+03d</span><span class="r">%+03d</span></div><div class="bottom"></div></div>'
function Hexmap:tohtml()
  local lines = {}

  for r=1,self.h do
    local even = (r % 2) == 0
    lines[#lines+1] = even and '      <div class="hex-row even">' or '      <div class="hex-row">'
    local rw = even and self.evenw or self.w
    local q0, _ = even_r_offset_to_axial(1, r)
    local q1, _ = even_r_offset_to_axial(rw, r)
    for q=q0, q1 do
      lines[#lines+1] = string.format(hex, q, r)
    end
    lines[#lines+1] = '      </div>'
  end

  return string.format(html, table.concat(lines, '\n'))
end



return Hexmap
