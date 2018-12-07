local class = require('middleclass')


local Finder = class('Finder')

function Finder:initialize(map)
  self.map = map
  self.algorithm = require('graph.search.astar')
  self.heuristic = map.distance
end

function Finder:search(start, goal)
  return self.algorithm(self.map, start, goal, self.heuristic)
end


return Finder
