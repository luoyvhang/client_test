local class = require('middleclass')

--[[
This component provider always returns the same instance of the component. The instance
is passed to the provider at initialisation.
]]
local ComponentInstanceProvider = class('ComponentInstanceProvider')

--[[
Constructor

@param instance The instance to return whenever a component is requested.
]]
function ComponentInstanceProvider:initialize(instance)
  self.instance = instance
end

--[[
Used to request a component from this provider

@return The instance
]]
function ComponentInstanceProvider:getComponent()
  return self.instance
end

--[[
Used to compare this provider with others. Any provider that returns the same component
instance will be regarded as equivalent.

@return The instance
]]
function ComponentInstanceProvider:identifier()
  return self.instance
end

return ComponentInstanceProvider
