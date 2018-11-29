-- Quad Tree implementation in Lua
-- Adaptd form https://github.com/kikito/middleclass-ai/blob/master/QuadTree.lua
-- Original by @kito Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com )
-- 12 Dec 2010
-- BSD-LICENSE: see https://github.com/kikito/middleclass-ai/blob/master/BSD-LICENSE.txt

local class = require('middleclass')
local Quadtree = class('Quadtree')

--------------------------------
--      PRIVATE STUFF
--------------------------------

-- returns true if two boxes intersect
local function _intersect(ax1,ay1,aw,ah, bx1,by1,bw,bh)

  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end

-- returns true if a is contained in b
local function _contained(ax1,ay1,aw,ah, bx1,by1,bw,bh)

  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return bx1 <= ax1 and bx2 >= ax2 and by1 <= ay1 and by2 >= ay2
end


local function _Node(node, width, height, x, y)
  assert(type(width) == 'number' and type(height) == 'number')
  node.x, node.y, node.width, node.height = x or 0,y or 0,width,height

  node.items = setmetatable({}, {__mode = "k"})
  node.itemsCount = 0
  return node
end


local function _getBounds(self)
  return self.x, self.y, self.width, self.height
end


-- create child nodes
local function _subdivide(node)
  -- if the node is too small, or it already has nodes,, stop dividing it
  if(node.width * node.height < 16 or #(node) > 0) then return end

  local hw = node.width / 2.0
  local hh = node.height / 2.0

  node[1] = _Node({parent=node}, hw, hh, node.x,    node.y)
  node[2] = _Node({parent=node}, hw, hh, node.x,    node.y+hh)
  node[3] = _Node({parent=node}, hw, hh, node.x+hw, node.y)
  node[4] = _Node({parent=node}, hw, hh, node.x+hw, node.y+hh)
end


-- Returns the smallest possible node that would contain a given item.
-- It does create additional nodes if needed, but it does *not* assign the node
-- if searchUp==true, search recursively up (parents), until root is reached
-- returns nil if the item isn't fully contained on the node, or searUp is true but
-- neither the node or its ancestors contain the item.
local function _findNode(node, x,y,w,h, searchUp)
  if _contained(x,y,w,h , _getBounds(node)) then
    -- the item is contained on the node. See if the node's descendants can hold the item
    _subdivide(node)
    for i=1,#node do
      local descendant = _findNode(node[i], x,y,w,h, false)
      if descendant then return descendant end
    end
    return node
  -- not contained on the node. Can we search up on the hierarchy?
  elseif(searchUp == true and node.parent) then
    return _findNode(node.parent, x,y,w,h, true)
  else
    return nil
  end
end

local function _getCount(node)
  local count = node.itemsCount
  for i=1,#node do
    count = count + _getCount(node[i])
  end
  return count
end

-- removes a node's children if they are all empty
local function _emptyCheck(node, searchUp)
  if(not node) then return end
  if _getCount(node) == 0 then
    node[1], node[2], node[3], node[4] = nil, nil, nil, nil
    if(searchUp) then _emptyCheck(node.parent) end
  end
end

-- inserts an item on a node. Doesn't check whether it is the correct node
local function _doInsert(node, item, root)
  if(node) then
    root.previous[item] = node
    root.unassigned[item] = nil
    node.items[item]= item
    node.itemsCount = node.itemsCount + 1
  end
  return node
end

-- removes an item from a node. It does not recursively traverse the node's children
-- if makeUnassigned is true, and the item isn't on the node, then the item
-- is "put on hold" on the unassigned table on the root node. Otherwise it's completely removed
local function _doRemove(node, item, root, makeUnassigned)
  if(node and node.items[item]) then
    root.previous[item]= nil
    node.items[item] = nil
    node.itemsCount = node.itemsCount - 1
    if(makeUnassigned==true) then
      root.unassigned[item]= item -- node might enter the quadtree again, via update
    end
  end
end

--------------------------------
--      PUBLIC STUFF
--------------------------------


function Quadtree:initialize(itemBounds, width, height, x, y)

  _Node(self, width, height, x, y)
  assert(type(itemBounds) == 'function', 'arg #1 require a function')
  self._itemBounds = itemBounds

  -- root node has two special properties:
  -- "previous" stores node assignments between updates
  -- "unassigned" is a list of items that are outside of the root
  self.previous = setmetatable({}, {__mode = "k"})
  self.unassigned = setmetatable({}, {__mode = "k"})
end

function Quadtree:getBoundingBox()
  return _getBounds(self)
end

function Quadtree:__len() -- make #qudtree works for Lua 5.2 and above and Luajit.
  return rawlen(self)
end

-- Counts the number of items on a Quadtree, including child nodes
function Quadtree:size()
  return _getCount(self)
end

local function _getAllItems(node, results)
  for i=1,#node do
    _getAllItems(node[i], results)
  end
  for _,item in pairs(node.items) do
    table.insert(results, item)
  end
  return results
end

-- Gets items of the quadtree, including child nodes
function Quadtree:getAllItems()
  return _getAllItems(self, {})
end

-- Inserts an item on the Quadtree. Returns the node containing it
function Quadtree:insert(item)
  assert(not self.previous[item], 'one item can only add once!')
  local x,y,w,h = self._itemBounds(item)
  return _doInsert(_findNode(self, x,y,w,h), item, self)
end

-- Removes an item from the Quadtree. The item will be completely removed from the quadtree
-- update will not "see" it unless it is manually re-inserted
function Quadtree:remove(item)
  local node = self.previous[item]
  _doRemove(node, item, self, false)
  _emptyCheck(node, true)
end

local function _query(node, itemBounds, x,y,w,h, test, filter, results)
  local nx,ny,nw,nh

  for _,item in pairs(node.items) do
    local ix, iy, iw, ih = itemBounds(item)
    if(test(ix,iy,iw,ih, x,y,w,h)) then
      if not filter or filter(item) then
        table.insert(results, item)
      end
    end
  end

  for i=1,#node do
    local child = node[i]
    nx,ny,nw,nh = _getBounds(child)

    -- case 1: area is contained on the child completely
    -- add the items that intersect and then break the loop
    if(_contained(x,y,w,h, nx,ny,nw,nh)) then
      _query(child, itemBounds, x,y,w,h, test, filter, results)
      break

    -- case 2: child is completely contained on the area
    -- add all the items on the child and continue the loop
    elseif(_contained(nx,ny,nw,nh, x,y,w,h)) then
      _getAllItems(child, results)

    -- case 3: node and area are intersecting
    -- add the items contained on the node's children and continue the loop
    elseif(_intersect(x,y,w,h, nx,ny,nw,nh)) then
      _query(child, itemBounds, x,y,w,h, test, filter, results)
    end
  end
end

-- Returns the items intersecting with a given area
function Quadtree:intersects(x, y, w, h, filter)
  local results = {}
  _query(self, self._itemBounds, x,y,w,h, _intersect, filter, results)
  return results
end

-- Returns the items completely inside a given area
function Quadtree:inside(x, y, w, h, filter)
  local results = {}
  _query(self, self._itemBounds, x,y,w,h, _contained, filter, results)
  return results
end

local function sqDistPointRect(x,y, rx,ry,rw,rh)
  local x2, y2 = rx + rw, ry + rh
  local dx, dy
  if (x < rx) then
    dx = rx - x
    if (y < ry) then
      dy = ry - y
      return dx * dx + dy * dy
    elseif (y > y2) then
      dy = y - y2
      return dx * dx + dy * dy
    else
      return dx*dx
    end
  elseif (x > x2) then
    dx = x - x2
    if (y < ry) then
      dy = ry - y
      return dx * dx + dy * dy
    elseif (y > y2) then
      dy = y - y2
      return dx * dx + dy * dy
    else
      return dx * dx
    end
  else
    if (y < ry) then
      dy = ry - y
      return dy * dy
    elseif (y > y2) then
      dy = y - y2
      return dy * dy
    else
      return 0.0
    end
  end
end

local function _nearest(node, itemBounds, x, y, bestsq, item, filter)

  -- exclude node if point is farther away than best distance in either axis
  if sqDistPointRect(x,y, _getBounds(node)) > bestsq then
    return bestsq, item
  end
  -- test items if there is one, potentially updating best
  for _,it in pairs(node.items) do
    local ix, iy, iw, ih = itemBounds(it)
    local cx, cy = ix + iw/2, iy + ih/2
    local dx, dy = cx-x, cy-y
    local d = dx*dx + dy*dy
    if d < bestsq and ((not filter) or filter(it)) then
      bestsq = d
      item = it
    end
  end

  for i=1,#node do
    bestsq, item = _nearest(node[i], itemBounds, x, y, bestsq, item, filter)
  end

  return bestsq, item
end


-- Returns the items intersecting with a given area
function Quadtree:nearest(x, y, filter)
  local item
  local w, h = self.width, self.height
  local bestsq = w*w + h*h
  bestsq, item = _nearest(self, self._itemBounds, x, y, bestsq, nil, filter)

  return item, item and math.sqrt(bestsq) or nil
end



local function _update(node, root)
  for _,item in pairs(node.items) do
    local x,y,w,h = root._itemBounds(item)
    local newNode = _findNode(node, x,y,w,h, true)
    if node ~= newNode then
      _doRemove(node, item, root, true)
      _doInsert(newNode, item, root)
    end
  end

  for i=1,#node do
    _update(node[i], root)
  end

  _emptyCheck(node, false)
end

-- Updates all the quadtree items
-- This method always updates the whole tree (starting from the root node)
function Quadtree:update()
  for _,item in pairs(self.unassigned) do
    self:insert(item)
  end
  _update(self, self)
end

return Quadtree
