local PriorityQueue = require('graph.PriorityQueue')
local array = require('array')

local function reconstruct_path(start, goal, came_from)
  local path = {}
  local current = goal

  path[1] = current
  while current ~= start do
    current = came_from[current];
    path[#path+1] = current
  end
  array.reverse(path)
  return path
end

return function (map, start, goal, heuristic)
  heuristic = heuristic or map.distance
  start, goal = map:node(start), map:node(goal) -- convert to interal node.

  local came_from, cost_so_far = {}, {}

  local frontier = PriorityQueue()
  frontier:enqueue(start, 0)

  came_from[start] = start
  cost_so_far[start] = 0

  local current = start
  while current do
    if current == goal then
      break
    end

    for _, next in ipairs(map:neighbors(current)) do
      local new_cost = cost_so_far[current] + map:cost(current, next)
      if not cost_so_far[next] or new_cost < cost_so_far[next] then
        cost_so_far[next] = new_cost
        local priority = new_cost + heuristic(map, next, goal) -- heuristic
        frontier:enqueue(next, priority)
        came_from[next] = current
      end
    end
    current = frontier:dequeue()
  end

  return reconstruct_path(start, goal, came_from)
end
