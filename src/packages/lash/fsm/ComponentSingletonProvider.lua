local class = require('middleclass')


--[[
This component provider always returns the same instance of the component. The instance
is created when first required and is of the type passed in to the constructor.
]]
local ComponentSingletonProvider = class('ComponentSingletonProvider')

--[[
Constructor

@param type The type of the single instance
]]
function ComponentSingletonProvider:initialize(type)
  self.componentType = type
end

--[[
Used to request a component from this provider

@return The single instance
]]
function ComponentSingletonProvider:getComponent()
  if not self.instance then
    self.instance = self.componentType()
  end
  return self.instance
end

--[[
Used to compare this provider with others. Any provider that returns the same single
instance will be regarded as equivalent.

@return The single instance
]]
function ComponentSingletonProvider:identifier()
  return self:getComponent()
end

return ComponentSingletonProvider
