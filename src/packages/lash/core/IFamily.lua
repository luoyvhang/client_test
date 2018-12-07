-- This class is not used in this Lua port of Ash
-- We in Lua has ducking type


--luacheck: ignore self entity componentClass
local class = require('middleclass')

--[[
The interface for classes that are used to manage NodeLists (set as the familyClass property
in the Engine object). Most developers don't need to use this since the default implementation
is used by default and suits most needs.
]]

local IFamily = class('IFamily')


--[[
Returns the NodeList managed by this class. This should be a reference that remains valid always
since it is retained and reused by Systems that use the list. i.e. never recreate the list,
always modify it in place.
]]

function IFamily:getNodeList() end

--[[
An entity has been added to the engine. It may already have components so test the entity
for inclusion in this family's NodeList.
]]
function IFamily:newEntity(entity) end

--[[
An entity has been removed from the engine. If it's in this family's NodeList it should be removed.
]]

function IFamily:removeEntity(entity) end

--[[
A component has been added to an entity. Test whether the entity's inclusion in this family's
NodeList should be modified.
]]

function IFamily:componentAddedToEntity( entity, componentClass) end

--[[
A component has been removed from an entity. Test whether the entity's inclusion in this family's
NodeList should be modified.
]]
function IFamily:componentRemovedFromEntity( entity, componentClass) end

--[[
The family is about to be discarded. Clean up all properties as necessary. Usually, you will
want to empty the NodeList at this time.
]]
function IFamily:cleanUp() end
