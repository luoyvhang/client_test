-------------------------------------------------------------------
-- [Binary heap](http://en.wikipedia.org/wiki/Binary_heap) implementation
--
-- The 'plain binary heap' is managed by positions. Which are hard to get once
-- an element is inserted. It can be anywhere in the list because it is re-sorted
-- upon insertion/deletion of items.
--
-- Array with values is stored in field `values`:
--     `peek = heap.values[1]`
--
--
-- Fields of heap object:
--  * values - array of values


local M = {}
local floor = math.floor

--================================================================
-- basic heap sorting algorithm
--================================================================

--- Creates a new binary heap.
-- This is the core of all heaps, the others
-- are built upon these sorting functions.
-- @param swap (function) `swap(heap, idx1, idx2)` swaps values at
-- `idx1` and `idx2` in the heaps `heap.values` and `heap.payloads` lists (see
-- return value below).
-- @param erase (function) `swap(heap, position)` raw removal
-- @param lt (function) in `lt(a, b)` returns `true` when `a < b`
--  (for a min-heap)
-- @return table with two methods; `heap:bubbleUp(pos)` and `heap:sinkDown(pos)`
-- that implement the sorting algorithm and two fields; `heap.values` and
-- `heap.payloads` being lists, holding the values and payloads respectively.
local function create(swap, erase, lt)

  local heap = {
      values = {},  -- list containing values
      erase = erase,
      swap = swap,
      lt = lt,
    }

  function heap:bubbleUp(pos)
    while pos>1 do
      local parent = floor(pos/2)
      if not lt(self.values[pos], self.values[parent]) then
          break
      end
      swap(self, parent, pos)
      pos = parent
    end
  end

  function heap:sinkDown(pos)
    local last = #self.values
    while true do
      local min = pos
      local child = 2*pos

      for c=child, child+1 do
        if c <= last and lt(self.values[c], self.values[min]) then min = c end
      end

      if min == pos then break end

      swap(self, pos, min)
      pos = min
    end
  end

  return heap
end

--================================================================
-- plain heap management functions
--================================================================

local update
--- Updates the value of an element in the heap.
-- @name heap:update
-- @param pos the position which value to update
-- @param newValue the new value to use for this payload
update = function(self, pos, newValue)
  self.values[pos] = newValue
  if pos>1 then self:bubbleUp(pos) end
  if pos<#self.values then self:sinkDown(pos) end
end

--- Removes an element from the heap.
-- @name heap:remove
-- @param pos the position to remove
-- @return value or nil + error if an illegal `pos` value was provided
local function remove(self, pos)
  local last = #self.values
  if pos<1 or pos>last then
    return nil, "illegal position"
  end
  local v = self.values[pos]
  if pos<last then
    self:swap(pos, last)
    self:erase(last)
    self:bubbleUp(pos)
    self:sinkDown(pos)
  else
    self:erase(last)
  end
  return v
end


--- Inserts an element in the heap.
-- @name heap:push
-- @param value the value used for sorting this element
local function push(self, value)
  local pos = #self.values+1
  self.values[pos] = value
  self:bubbleUp(pos)
end

--- Removes the top of the heap and returns it.
-- @name heap:pop
-- When used with timers, `pop` will return the payload that is due.
--
-- Note: this function returns `payload` as the first result to prevent
-- extra locals when retrieving the `payload`.
-- @return value at the top, or `nil` if there is none
local function pop(self)
  if self.values[1] then
    return remove(self, 1)
  end
end

--- Returns the element at the top of the heap, without removing it.
-- @name heap:peek
-- @return value at the top, or `nil` if there is none
local function peek(self)
  return self.values[1]
end

local function swap(heap, a, b)
  heap.values[a], heap.values[b] = heap.values[b], heap.values[a]
end

local function erase(heap, pos)
  heap.values[pos] = nil
end

--================================================================
-- plain heap creation
--================================================================

local function plainHeap(lt)
  local h = create(swap, erase, lt)
  h.peek = peek
  h.pop = pop
  h.remove = remove
  h.push = push
  h.update = update
  return h
end

--- Creates a new min-heap, where the smallest value is at the top.
-- @param lt (optional) comparison function (less-than), see `binaryHeap`.
-- @return the new heap
M.min = function(lt)
  if not lt then
    lt = function(a,b) return (a<b) end
  end
  return plainHeap(lt)
end

--- Creates a new max-heap, where the largest value is at the top.
-- @param gt (optional) comparison function (greater-than), see `binaryHeap`.
-- @return the new heap
M.max = function(gt)
  if not gt then
    gt = function(a,b) return (a>b) end
  end
  return plainHeap(gt)
end


return M
