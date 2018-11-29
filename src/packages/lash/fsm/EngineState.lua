local class = require('middleclass')
local SystemInstanceProvider = require('lash.fsm.SystemInstanceProvider')
local SystemSingletonProvider = require('lash.fsm.SystemSingletonProvider')
local DynamicSystemProvider = require('lash.fsm.DynamicSystemProvider')
local StateSystemMapping = require('lash.fsm.StateSystemMapping')

--[[
Represents a state for a SystemStateMachine. The state contains any number of SystemProviders which
are used to add Systems to the Engine when this state is entered.
]]
local EngineState = class('EngineState')


function EngineState:initialize()
  self.providers = {}
end

--[[
Creates a mapping for the System type to a specific System instance. A
SystemInstanceProvider is used for the mapping.

@param system The System instance to use for the mapping
@return This StateSystemMapping, so more modifications can be applied
]]
function EngineState:addInstance(system)
  return self:addProvider(SystemInstanceProvider(system))
end

--[[
Creates a mapping for the System type to a single instance of the provided type.
The instance is not created until it is first requested. The type should be the same
as or extend the type for this mapping. A SystemSingletonProvider is used for
the mapping.

@param type The type of the single instance to be created. If omitted, the type of the
mapping is used.
@return This StateSystemMapping, so more modifications can be applied
]]
function EngineState:addSingleton(type)
  return self:addProvider(SystemSingletonProvider(type))
end

--[[
Creates a mapping for the System type to a method call.
The method should return a System instance. A DynamicSystemProvider is used for
the mapping.

@param method The method to provide the System instance.
@return This StateSystemMapping, so more modifications can be applied.
]]
function EngineState:addMethod(method)
  return self:addProvider(DynamicSystemProvider(method))
end

--[[
Adds any SystemProvider.

@param provider The component provider to use.
@return This StateSystemMapping, so more modifications can be applied.
]]
function EngineState:addProvider(provider)
  local mapping = StateSystemMapping(self, provider)
  self.providers[#self.providers+1] = provider;
  return mapping
end

function EngineState:__eq(rhs)
  return rawequal(self, rhs)
end

return EngineState
