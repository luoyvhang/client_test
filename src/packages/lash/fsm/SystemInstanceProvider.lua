local class = require('middleclass')


--[[
This System provider always returns the same instance of the component. The system
is passed to the provider at initialisation.
]]
local SystemInstanceProvider = class('SystemInstanceProvider')


--[[
Constructor

@param instance The instance to return whenever a System is requested.
]]
function SystemInstanceProvider:initialize(instance)
  self._instance = instance
  self._priority = 0
end

--[[
Used to request a component from this provider

@return The instance of the System
]]
function SystemInstanceProvider:getSystem()
  return self._instance
end

--[[
Used to compare this provider with others. Any provider that returns the same component
instance will be regarded as equivalent.

@return The instance
]]
function SystemInstanceProvider:identifier()
  return self._instance
end

--[[
The priority at which the System should be added to the Engine
]]
function SystemInstanceProvider:priority()
  return self._priority;
end


return SystemInstanceProvider
