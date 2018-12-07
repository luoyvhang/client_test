local class = require('middleclass')
local Observable = require('lash.core.Observable')

--[[
A collection of nodes.

<p>Systems within the engine access the components of entities via NodeLists. A NodeList contains
a node for each Entity in the engine that has all the components required by the node. To iterate
over a NodeList, start from the head and step to the next on each loop, until the returned value
is null.</p>

<p>for( var node : Node = nodeList.head; node; node = node.next )
{
  // do stuff
}</p>

<p>It is safe to remove items from a nodelist during the loop. When a Node is removed form the
NodeList it's previous and next properties still point to the nodes that were before and after
it in the NodeList just before it was removed.</p>
]]


local NodeList = class('NodeList'):include(Observable)


--[[
Events:

 - nodeAdded:

A signal that is dispatched whenever a node is added to the node list.

<p>The signal will pass a single parameter to the listeners - the node that was added.</p>

- nodeRemoved:

A signal that is dispatched whenever a node is removed from the node list.

<p>The signal will pass a single parameter to the listeners - the node that was removed.</p>
]]

function NodeList:initialize()
  Observable.initialize(self)
end

function NodeList:_add(node)
  assert(not self[node.entity])
  self[node.entity] = node
  self[#self+1] = node
  self.emitter:emit('nodeAdded', node)
end

function NodeList:_remove(node, index)
  assert(self[node.entity])
  if not index then
    for i=1,#self do
      local v = self[i]
      if v == node then
        index = i
        break
      end
    end
  else
    assert(node == self[index])
  end
  local last = #self

  if index == last then
    self[index] = nil
  else
    self[index], self[last] = self[last], nil
  end
  self[node.entity] = nil
  self.emitter:emit('nodeRemoved', node)
end

function NodeList:_removeAll()
  for i=#self,1,-1 do
    local node = self[i]
    self.emitter:emit('nodeRemoved', node)
    self[i] = nil
    self[node.entity] = nil
  end
end

function NodeList:has(entity)
  return self[entity] ~= nil
end

function NodeList:get(entity)
  return self[entity]
end

--[[
true if the list is empty, false otherwise.
]]
function NodeList:empty()
  return #self == 0
end

return NodeList
