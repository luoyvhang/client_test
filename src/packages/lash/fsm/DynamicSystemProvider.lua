local class = require('middleclass')

--[[
This System provider returns results of a method call. The method
is passed to the provider at initialisation.
]]
local DynamicSystemProvider = class('DynamicSystemProvider')



--[[
Constructor

@param method The method that returns the System instance;
]]
function DynamicSystemProvider:initialize(closure)
  self._closure = closure
  self._priority = 0
end
--[[
Used to request a component from this provider

@return The instance of the System
]]
function DynamicSystemProvider:getSystem()
  return self._closure()
end
--[[
Used to compare this provider with others. Any provider that returns the same component
instance will be regarded as equivalent.

@return self.The _closure used to call the System instances
]]
function DynamicSystemProvider:identifier()
  return self._closure
end
--[[
The priority at which the System should be added to the Engine
]]
function DynamicSystemProvider:priority()
  return self._priority
end

return DynamicSystemProvider
