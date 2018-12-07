local class = require('middleclass')
local Observable = require('lash.core.Observable')


--[[
An entity is composed from components. As such, it is essentially a collection object for components.
Sometimes, the entities in a game will mirror the actual characters and objects in the game, but this
is not necessary.

<p>Components are simple value objects that contain data relevant to the entity. Entities
with similar functionality will have instances of the same components. So we might have
a position component</p>

<p><code>local PositionComponent = class('PositionComponent')

function PositionComponent:initialize(x, y)
  self.x = x
  self.y = y
end

return PositionComponent

</code></p>

<p>All entities that have a position in the game world, will have an instance of the
position component. Systems operate on entities based on the components they have.</p>
]]

local Entity = class('Entity'):include(Observable)

local ID = 1

--local private = setmetatable({}, {__mode = "k"})   -- weak table storing all private attributes

--[[

Events:
- componentAdded(entity, class) : emitted when a component is added to the entity.
- componentRemoved(entity, class): emitted when a component is removed from the entity.

]]

--[[
The constructor

@param name: string The name for the entity. If left blank, a default name is assigned with the form _entityN where N is an integer.
]]
function Entity:initialize(name)
  Observable.initialize(self)
  self.components = {}
  self.name = name or string.format('E[%04d]', ID)
  ID = ID + 1
end


--[[
Add a component to the entity.

@param component The component object to add.
@param componentClass The class of the component. This is only necessary if the component
extends another component class and you want the framework to treat the component as of
the base class type. If not set, the class type is determined directly from the component.

@return A reference to the entity. This enables the chaining of calls to add, to make
creating and configuring entities cleaner. e.g.

<code>local entity = Entity()
    :add(Position(100, 200)
    :add(Display(PlayerClip());</code>
]]
function Entity:add(component, componentClass)
  if not componentClass then
    componentClass = component.class
  end

  if self.components[componentClass] then
    self:remove(componentClass)
  end

  self.components[componentClass] = component
  self.emitter:emit('componentAdded', self, componentClass)
  return self
end


--[[
Remove a component from the entity.

@param componentClass The class of the component to be removed.
@return the component, or null if the component doesn't exist in the entity
]]
function Entity:remove(componentClass)
  local component = self.components[componentClass]
  if component then
    self.components[componentClass] = nil
    self.emitter:emit('componentRemoved', self, componentClass)
    return component
  end
end

--[[
Get a component from the entity.

@param componentClass The class of the component requested.
@return The component, or null if none was found.
]]
function Entity:get(componentClass)
  return self.components[componentClass]
end

--[[
Get all components from the entity.

@return An array containing all the components that are on the entity.
]]
function Entity:getAll()
  local all = {}
  for _, v in pairs(self.components) do
    all[#all+1] = v
  end
  return all
end

--[[
Does the entity have a component of a particular type.

@param componentClass The class of the component sought.
@return true if the entity has a component of the type, false if not.
]]
function Entity:has(componentClass)
  return self.components[componentClass] ~= nil
end

function Entity:__eq(rhs)
  return rawequal(self, rhs)
end

return Entity
