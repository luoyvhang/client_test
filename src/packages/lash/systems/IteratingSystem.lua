local class = require('middleclass')
local System = require('lash.core.System')

--[[
A useful class for systems which simply iterate over a set of nodes, performing
the same action on each node. This class removes the need for a lot of
boilerplate code in such systems. Extend this class and pass the node type into
the constructor and overrides the nodeUpdate() nodeAdded() nodeRemoved methods.
The node update method will be called once per node on the update cycle
with the node instance and the frame time as parameters. e.g.

<code>

local MySystem = class('MySystem', IteratingSystem)

local MyNode = require('...MyNode') -- load your node spec class

function MySystem:initialize()
  IteratingSystem.initialize(self, MyNode)
end

function MySystem:nodeUpdate(node, time)
end

function MySystem:nodeAdded(node) -- optional
end

function MySystem:nodeRemoved(node) -- optional
end

return MySystem
</code>
]]

local IteratingSystem = class('IteratingSystem', System)


function IteratingSystem:initialize(nodeClass)
  System.initialize(self)
  self.nodeClass = nodeClass
end


function IteratingSystem:addToEngine(engine)
  local nodes = engine:getNodeList(self.nodeClass)
  local s = {}

  if self.nodeAdded then
    for _, node in ipairs(nodes) do
      self:nodeAdded(node)
    end

    s[#s+1] = nodes:on('nodeAdded', function(...)
      self:nodeAdded(...)
    end)
  end

  if self.nodeRemoved then
    s[#s+1] = nodes:on('nodeRemoved', function(...)
      self:nodeRemoved(...)
    end)
  end
  self.nodes, self._subscribes = nodes, s
end

function IteratingSystem:removeFromEngine(engine) -- luacheck: ignore engine
  for _, v in ipairs(self._subscribes) do
    v:dispose()
  end
  self._subscribes = nil
  self.nodes = nil
end

function IteratingSystem:update(time, emitter)
  local nodes = self.nodes
  for i=#nodes,1,-1 do
    local node = nodes[i]
    if node then
      self:nodeUpdate(node, time, emitter)
    end
  end
end

return IteratingSystem
