local class = require('middleclass')

--[[
This component provider always returns a new instance of a component. An instance
is created when requested and is of the type passed in to the constructor.
]]
local ComponentTypeProvider = class('ComponentTypeProvider')


--[[
Constructor

@param type The type of the instances to be created
]]
function ComponentTypeProvider:initialize(type)
  self.componentType = type;
end

--[[
Used to request a component from this provider

@return A new instance of the type provided in the constructor
]]
function ComponentTypeProvider:getComponent()
  return self.componentType()
end

--[[
Used to compare this provider with others. Any ComponentTypeProvider that returns
the same type will be regarded as equivalent.

@return The type of the instances created
]]
function ComponentTypeProvider:identifier()
  return self.componentType
end

return ComponentTypeProvider
