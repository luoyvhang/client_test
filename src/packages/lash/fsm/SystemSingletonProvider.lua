local class = require('middleclass')

--[[
This System provider always returns the same instance of the System. The instance
is created when first required and is of the type passed in to the constructor.
]]

local SystemSingletonProvider = class('SystemSingletonProvider')

--[[
Constructor

@param klass The class of the single System instance
]]
function SystemSingletonProvider:initialize(klass)
  self._class = klass
  self._priority = 0
end

--[[
Used to request a System from this provider

@return The single instance
]]
function SystemSingletonProvider:getSystem()
  if not self.instance then
    self.instance = self._class()
  end
  return self.instance
end

--[[
Used to compare this provider with others. Any provider that returns the same single
instance will be regarded as equivalent.

@return The single instance
]]
function SystemSingletonProvider:identifier()
  return self:getSystem()
end

--[[
The priority at which the System should be added to the Engine
]]
function SystemSingletonProvider:priority()
  return self._priority
end


return SystemSingletonProvider
