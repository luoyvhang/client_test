local class = require('middleclass')
local NodeList = require('lash.core.NodeList')

--[[
The default class for managing a NodeList. This class creates the NodeList and adds and removes
nodes to/from the list as the entities and the components in the engine change.

It uses the basic entity matching pattern of an entity system - entities are added to the list if
they contain components matching all the public properties of the node class.
]]
local ComponentMatchingFamily = class('ComponentMatchingFamily')

--[[
The constructor. Creates a ComponentMatchingFamily to provide a NodeList for the
given node class.

@param nodespec (node table) The type of node to create and manage a NodeList for.
@param engine (Engine) The engine that this family is managing teh NodeList for.
]]
function ComponentMatchingFamily:initialize(nodespec, engine)
  self.nodespec = nodespec
  self.engine = engine

  self.nodes = NodeList()
  self.components = {}

  for k,v in pairs(nodespec) do
    self.components[v] = k
  end
end


--[[
ComponentMatchingFamily.nodes

The nodelist managed by this family. This is a reference that remains valid always
since it is retained and reused by Systems that use the list. i.e. we never recreate the list,
we always modify it in place.
]]




-- If the entity is not in this family's NodeList, tests the components of the entity to see
-- if it should be in this NodeList and adds it if so.
local function addIfMatch(self, entity)
  if self.nodes:has(entity) then return end

  for componentClass, _ in pairs(self.components) do
    if not entity:has(componentClass) then
      return
    end
  end

  local node = {}
  node.entity = entity
  for componentClass, field in pairs(self.components) do
    node[field] = entity:get(componentClass)
  end

  self.nodes:_add(node)
end



-- Removes the entity if it is in this family's NodeList.
local function removeIfMatch(self, entity)
  local node = self.nodes:get(entity)
  if node then
    self.nodes:_remove(node)
  end
end


--[[
Called by the engine when an entity has been added to it. We check if the entity should be in
this family's NodeList and add it if appropriate.
]]
function ComponentMatchingFamily:newEntity(entity)
  addIfMatch(self, entity)
end

--[[
Called by the engine when a component has been added to an entity. We check if the entity is not in
this family's NodeList and should be, and add it if appropriate.
]]
function ComponentMatchingFamily:componentAddedToEntity(entity, componentClass)
  if self.components[componentClass] then
    addIfMatch(self, entity)
  end
end

--[[
Called by the engine when a component has been removed from an entity. We check if the removed component
is required by this family's NodeList and if so, we check if the entity is in this this NodeList and
remove it if so.
]]
function ComponentMatchingFamily:componentRemovedFromEntity(entity, componentClass)
  if self.components[componentClass] then
    removeIfMatch(self, entity)
  end
end

--[[
Called by the engine when an entity has been rmoved from it. We check if the entity is in
this family's NodeList and remove it if so.
]]
function ComponentMatchingFamily:removeEntity(entity)
  removeIfMatch(self, entity)
end




--[[
Removes all nodes from the NodeList.
]]
function ComponentMatchingFamily:cleanUp()
  self.nodes:_removeAll()
end

return ComponentMatchingFamily
