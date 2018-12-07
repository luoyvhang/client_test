local class = require('middleclass')

local ComponentInstanceProvider = require('lash.fsm.ComponentInstanceProvider')
local ComponentTypeProvider = require('lash.fsm.ComponentTypeProvider')
local ComponentSingletonProvider = require('lash.fsm.ComponentSingletonProvider')
local DynamicComponentProvider = require('lash.fsm.DynamicComponentProvider')

--[[
Used by the EntityState class to create the mappings of components to providers via a fluent interface.
]]

local StateComponentMapping = class('StateComponentMapping')


--[[
Used internally, the constructor creates a component mapping. The constructor
creates a ComponentTypeProvider as the default mapping, which will be replaced
by more specific mappings if other methods are called.

@param creatingState The EntityState that the mapping will belong to
@param type The component type for the mapping
]]

function StateComponentMapping:initialize(creatingState, type)
  self.creatingState = creatingState
  self.componentType = type
  self:withType(type)
end

local function setProvider(self, provider)
  self.provider = provider
  self.creatingState.providers[ self.componentType ] = provider
end

--[[
Creates a mapping for the component type to a specific component instance. A
ComponentInstanceProvider is used for the mapping.

@param component The component instance to use for the mapping
@return This ComponentMapping, so more modifications can be applied
]]
function StateComponentMapping:withInstance(component)
  setProvider(self, ComponentInstanceProvider(component))
  return self
end

--[[
Creates a mapping for the component type to new instances of the provided type.
The type should be the same as or extend the type for this mapping. A ComponentTypeProvider
is used for the mapping.

@param type The type of components to be created by this mapping
@return This ComponentMapping, so more modifications can be applied
]]
function StateComponentMapping:withType(type)
  setProvider(self, ComponentTypeProvider(type))
  return self
end

--[[
Creates a mapping for the component type to a single instance of the provided type.
The instance is not created until it is first requested. The type should be the same
as or extend the type for this mapping. A ComponentSingletonProvider is used for
the mapping.

@param The type of the single instance to be created. If omitted, the type of the
mapping is used.
@return This ComponentMapping, so more modifications can be applied
]]
function StateComponentMapping:withSingleton(type)
  setProvider(self, ComponentSingletonProvider(type or self.componentTypee))
  return self
end


--[[
Creates a mapping for the component type to a method call. A
DynamicComponentProvider is used for the mapping.

@param method The method to return the component instance
@return This ComponentMapping, so more modifications can be applied
]]
function StateComponentMapping:withMethod(method)
  setProvider(self, DynamicComponentProvider(method))
  return self
end

--[[
Creates a mapping for the component type to any ComponentProvider.

@param provider The component provider to use.
@return This ComponentMapping, so more modifications can be applied.
]]
function StateComponentMapping:withProvider(provider)
  setProvider(self, provider)
  return self
end

--[[
Maps through to the add method of the EntityState that this mapping belongs to
so that a fluent interface can be used when configuring entity states.

@param type The type of component to add a mapping to the state for
@return The new ComponentMapping for that type
]]
function StateComponentMapping:add(type)
  return self.creatingState:add(type)
end


return StateComponentMapping
