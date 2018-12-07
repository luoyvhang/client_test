-- This class is not used in this Lua port of Ash
-- We in Lua has ducking type


--luacheck: ignore self
--[[
This is the Interface for component providers. Component providers are used to supply components
for states within an EntityStateMachine. Ash includes three standard component providers,
ComponentTypeProvider, ComponentInstanceProvider and ComponentSingletonProvider. Developers
may wish to create more.
]]
local IComponentProvider = class('IComponentProvider')

--[[
Used to request a component from the provider.

@return A component for use in the state that the entity is entering
]]
function IComponentProvider:getComponent() end

--[[
Returns an identifier that is used to determine whether two component providers will
return the equivalent components.

<p>If an entity is changing state and the state it is leaving and the state is is
entering have components of the same type, then the identifiers of the component
provders are compared. If the two identifiers are the same then the component
is not removed. If they are different, the component from the old state is removed
and a component for the new state is added.</p>

@return An object
]]
function IComponentProvider:identifier() end

return IComponentProvider
