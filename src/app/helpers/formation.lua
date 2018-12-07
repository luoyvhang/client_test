local formation = {}

local Body = require('app.components.Body')
local Cellref = require('app.components.Cellref')
local Square = require('app.components.Square')

local config = require('config')

local ROWS = config.COMBAT_ROWS


local function zigzag(rows)
  local positions = {}
  local function fill(pos, idx, max, v, delta)
    for i=idx,max,2 do
      pos[i], v = v, v + delta
    end
  end
  if rows%2==0 then -- even
    fill(positions, 1, rows, rows/2, -1)
    fill(positions, 2, rows, rows/2+1, 1)
  else -- odd
    fill(positions, 1, rows, (rows+1)/2, 1)
    fill(positions, 2, rows, (rows-1)/2, -1)
  end
  local priority = {}
  for i, v in ipairs(positions) do
    priority[v] = i
  end
  return positions, priority
end

local PRIO_TO_ROW, ROW_TO_PRIO = zigzag(ROWS)




local function getPriority(cell)
  return (cell.col-1)*ROWS + ROW_TO_PRIO[cell.row]
end

local function getColumns(amount)
  return math.ceil(amount/ROWS)
end

-- return col, row
local function getIndexes(priority)
  return getColumns(priority), PRIO_TO_ROW[(priority-1)%ROWS+1]
end


local party_config = {
  left = {6.5*config.COMBAT_GRID_WIDTH, 1},
  right = {10.5*config.COMBAT_GRID_WIDTH, -1}
}


local class = require('middleclass')
local Formation = class('Formation')

function Formation:initialize(square, amount, face, front)
  local columns = getColumns(amount)
  local XSTEP, YSTEP = -face*config.COMBAT_GRID_WIDTH, config.COMBAT_GRID_HEIGHT
  for c=1,columns do
    self[c] = {}
    for r=1,ROWS do
      self[c][r] = {col=c, row=r, x=c*XSTEP, y=r*YSTEP, unit=nil}
    end
  end
  self.square = square
  self.face, self.front = face, front
  self.size = 0
  self.capacity = amount
end


local function _link(self, unit, cell)
  cell.unit = unit
  unit:add(Cellref(self, cell))
end

function Formation:add(child)
  local newsize = self.size+1
  local col, row = getIndexes(newsize)
  local cell = self:get(col, row)
  assert(cell)
  _link(self, child, cell)
  self.size = newsize
end


function Formation:remove(unit)
  local cell = unit:get(Cellref).cell
  cell.unit = nil
  unit:remove(Cellref)
end

-- purge tail n cells.
-- cleanup all the empty tailing columns
function Formation:purge(n)
  n = math.min(n, self.size)

  local size = self.size
  for i=0,n-1,1 do
    local priority = size - i
    local col, row = getIndexes(priority)
    local c = self[col][row]
    assert(c)
    if c.unit then
      self:remove(c.unit)
    end
    self[col][row] = nil
  end
  self.size = self.size - n
  local columns = getColumns(self.size)
  -- Cleanup all the empty tailing columns
  for i=#self, columns+1,-1 do
    self[i] = nil
  end
end



-- return last n cells
-- optinal only condition() return ture values.
function Formation:last(n, condition)
  local cells = {}

  local size = self.size
  while #cells < n and size > 0 do
    local col, row = getIndexes(size)
    local c = self[col][row]
    if c and (not condition or condition(c)) then
      cells[#cells+1] = c
    end
    size = size - 1
  end

  return cells
end

function Formation:get(column, row)
  return self[column][row]
end

-- just move in formation
-- to make entity movement, you need to add Path yourself
function Formation:move(unit, cell)
  local cellref = unit:get(Cellref)
  if cellref then
    if cellref.cell == cell then
      print('already there')
      return -- already there
    end
    self:remove(unit)
  end

  if cell.unit then
    self:remove(cell.unit)
  end
  _link(self, unit, cell)
end

function Formation:columns()
  return math.ceil(self.size/ROWS)
end

function Formation:generatemap()
  local MAX = self:columns()
  local map = {}
  for r=1, ROWS do
    map[r] = {}
  end
  for c, column in ipairs(self) do
    if c <= MAX then
      for r=1, ROWS do
        local cell = column[r]
        map[r][c] = cell and 0 or 1
      end
    end
  end
  return map
end


function Formation:each(callback)
  for _, column in ipairs(self) do
    for r=1, ROWS do
      local cell = column[r]
      if cell then
        callback(cell)
      end
    end
  end
end


-- returns x position where next square should start.
function Formation:setup(front)
  local face = self.face
  self:each(function(cell)
    if cell.unit then
      local body = cell.unit:get(Body)
      body:setPosition(cell.x + front, cell.y)
      body:setLocalZOrder(-cell.y)
      body:setScaleX(face*body:getScaleY())
    end
  end)
  return front-(#self+1)*config.COMBAT_GRID_WIDTH*face
end

function formation.sort(cells)
  table.sort(cells, function(a, b)
    return getPriority(a) < getPriority(b)
  end)
  return cells
end

formation.priority = getPriority

function formation.setup(parties)
  for name, party in pairs(parties) do
    local front = party_config[name][1]
    for _, square in ipairs(party) do
      local s = square:get(Square)
      local f = Formation(s, #s.units, s.face)
      for _, u in ipairs(s.units) do
        f:add(u)
      end
      s.form = f
      square:get(Body):setPositionX(front)
      front = f:setup(front)
    end
  end
end


return formation
