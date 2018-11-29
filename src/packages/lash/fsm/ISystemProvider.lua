-- This class is not used in this Lua port of Ash
-- We in Lua has ducking type


-- luacheck: ignore self
local ISystemProvider = class('ISystemProvider')

function ISystemProvider:getSystem() end

function ISystemProvider:identifier() end

function ISystemProvider:priority() end

return ISystemProvider
