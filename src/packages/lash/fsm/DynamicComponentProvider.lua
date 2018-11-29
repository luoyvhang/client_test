local class = require('middleclass')

--[[
This component provider calls a function to get the component instance. The function must
return a single component of the appropriate type.
]]
local DynamicComponentProvider = class('DynamicComponentProvider')

--[[
Constructor

@param closure The function that will return the component instance when called.
]]
function DynamicComponentProvider:initialize(closure)
  self._closure = closure
end
--[[
Used to request a component from this provider

@return The instance returned by calling the function
]]
function DynamicComponentProvider:getComponent()
  return self._closure()
end
--[[
Used to compare this provider with others. Any provider that uses the function or method
closure to provide the instance is regarded as equivalent.

@return The function
]]
function DynamicComponentProvider:identifier()
  return self._closure
end

return DynamicComponentProvider
