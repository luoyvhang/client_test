local class = require('middleclass')
local Observable = require('lash.core.Observable')
local ha = require('lash.core.HashArray')
local ComponentMatchingFamily = require('lash.core.ComponentMatchingFamily')

--[[
The Engine class is the central point for creating and managing your game state. Add
entities and systems to the engine, and fetch families of nodes from the engine.

fileds:

updating (boolean)

Indicates if the engine is currently in its update loop.

entities (array)

And list of all entities.

events:

* updateComplete()

Dispatched when the update loop ends. If you want to add and remove systems from the
engine it is usually best not to do so during the update loop. To avoid this you can
listen for this signal and make the change when the signal is dispatched.
]]
local Engine = class('Engine'):include(Observable)


--[[

@param familyClass: (Family) Optional

The class used to manage node lists. In most cases the default class is sufficient
but it is exposed here so advanced developers can choose to create and use a
different implementation.

The class must implement the Family interface.
]]


function Engine:initialize(familyClass)
  Observable.initialize(self)
  self.familyClass = familyClass or ComponentMatchingFamily
  self.updating = false

  self.entities = {}
  self.unique = {}

  self.systems = {}
  self.families = {}
end


--[[
Add an entity to the engine.

@param entity (Entity) The entity to add.
]]
function Engine:addEntity(entity)
  local families = self.families
  local entities = self.entities
  local unique = self.unique

  assert(not unique[entity],
    "The entity " .. entity.name .. " is already added.")

  unique[entity] = true
  entities[#entities+1] = entity

  entity.connections = {
    entity:on('componentAdded', function(addedEntity, componentClass)
      for _, family in pairs(families) do
        family:componentAddedToEntity(addedEntity, componentClass)
      end
    end),

    entity:on('componentRemoved', function(removedEntity, componentClass)
      for _, family in pairs(families) do
        family:componentRemovedFromEntity(removedEntity, componentClass)
      end
    end),
  }

  for _, family in pairs(families) do
    family:newEntity(entity)
  end
end

local function clearForEntity(self, entity)
  for _, v in ipairs(entity.connections) do
    v:dispose()
  end

  for _, family in pairs(self.families) do
    family:removeEntity(entity)
  end
end


--[[
Remove an entity from the engine.

@param entity (Entity) The entity to remove.
]]
function Engine:removeEntity(entity)
  --if not self.unique[entity] then return end

  clearForEntity(self, entity)

  self.unique[entity] = nil

  for i, v in ipairs(self.entities) do
    if v == entity then
      table.remove(self.entities, i)
      return
    end
  end
end

--[[
Get an array of entities based on its name.

More than one entities may have the same name.

@param name (String) The name of the entity
@return (Entity) The entity, or nil if no entity with that name exists on the engine
]]
function Engine:getEntityByName(name)
  local matches = {}
  for _, v in ipairs(self.entities) do
    if v.name == name then
      matches[#matches+1] = v
    end
  end
  return matches
end

--[[
Remove all entities from the engine.
]]
function Engine:removeAllEntities()
  for i, v in ipairs(self.entities) do
    clearForEntity(self, v)
    self.entities[i] = nil
    self.unique[v] = nil
  end
  assert(next(self.entities) == nil) -- should be empty table
end

--[[
Returns a array containing all the entities in the engine.
]]
function Engine:getEntities()
  local all = {}
  for i, v in ipairs(self.entities) do
    all[i] = v
  end
  return all
end




--[[
Get a collection of nodes from the engine, based on the type of the node required.

<p>The engine will create the appropriate NodeList if it doesn't already exist and
will keep its contents up to date as entities are added to and removed from the
engine.</p>

<p>If a NodeList is no longer required, release it with the releaseNodeList method.</p>

@param nodeClass (Class) The type of node required.
@return A array of all nodes of this type from all entities in the engine.
]]
function Engine:getNodeList(nodeClass)
  local families = self.families
  if not families[nodeClass] then
    local family = self.familyClass(nodeClass, self)
    families[nodeClass] = family

    for _, entity in ipairs(self.entities) do
      family:newEntity(entity)
    end
  end

  return families[nodeClass].nodes
end

--[[
If a NodeList is no longer required, this method will stop the engine updating
the list and will release all references to the list within the framework
classes, enabling it to be garbage collected.

<p>It is not essential to release a list, but releasing it will free
up memory and processor resources.</p>

@param nodeClass (Class) The type of the node class if the list to be released.
]]
function Engine:releaseNodeList(nodeClass)
  local families = self.families
  if families[nodeClass] then
    families[nodeClass]:cleanUp()
  end
  families[nodeClass] = nil
end

--[[
Add a system to the engine, and set its priority for the order in which the
systems are updated by the engine update loop.

<p>The priority dictates the order in which the systems are updated by the engine update
loop. Lower numbers for priority are updated first. i.e. a priority of 1 is
updated before a priority of 2.</p>

@param system (System) The system to add to the engine.
@param priority (integer) The priority for updating the systems during the engine loop. A
lower number means the system is updated sooner.
]]
function Engine:addSystem(system, priority)
  assert(type(priority) == 'number', 'arg #2: priority should be number')
  system.priority = priority

  ha.add(self.systems, system.class, system)
  self._systems_needs_sort = true
  system:addToEngine(self, self.emitter)
end

--[[
Get the system instance of a particular type from within the engine.

@param type (Class) The type of system
@return (System) The instance of the system type that is in the engine, or
nil if no systems of this type are in the engine.
]]
function Engine:getSystem(type)
  return ha.value(self.systems, type)
end

--[[
Returns a array containing all the systems in the engine.
]]
function Engine:getAllSystems()
  return ha.values(self.systems)
end


--[[
Remove a system from the engine.

@param system (System) The system to remove from the engine.
]]
function Engine:removeSystem(system)
  if self.systems[system.class] then
    ha.remove(self.systems, system.class, system)
    system:removeFromEngine(self, self.emitter)
  end
end

--[[
Remove all systems from the engine.
]]
function Engine:removeAllSystems()
  local emitter = self.emitter
  for i, system in ipairs(self.systems) do
    self.systems[i] = nil
    self.systems[system.class] = nil
    system:removeFromEngine(self, emitter)
  end
end

--[[
Update the engine. This causes the engine update loop to run, calling update on all the
systems in the engine.

<p>The package net.richardlord.ash.tick contains classes that can be used to provide
a steady or variable tick that calls this update method.</p>

@time The duration, in seconds, of this update step.
]]
function Engine:update(time)
  if self._systems_needs_sort then
    table.sort(self.systems, function(a, b) return a.priority < b.priority end)
    self._systems_needs_sort = nil
  end
  self.updating = true
  local emitter = self.emitter
  for _, system in ipairs(self.systems) do
    system:update(time, emitter)
  end
  self.updating = false;
  emitter:emit('updateComplete')
end


return Engine
