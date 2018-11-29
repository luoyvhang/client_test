--luacheck: ignore self engine time
local class = require('middleclass')

--[[
The base class for a system.

<p>A system is part of the core functionality of the game. After a system is added to the engine, its
update method will be called on every frame of the engine. When the system is removed from the engine,
the update method is no longer called.</p>

<p>The aggregate of all systems in the engine is the functionality of the game, with the update
methods of those systems collectively constituting the engine update loop. Systems generally operate on
node lists - collections of nodes. Each node contains the components from an entity in the engine
that match the node.</p>

<code>
local class = require('middleclass')
local System = require('lash.core.System')
local CollisionSystem = class('CollisionSystem', System)

function CollisionSystem:initialize(creator)
	self.creator = creator
end

function CollisionSystem:addToEngine(engine)
	self.games = engine.getNodeList(GameNode)
	self.spaceships = engine.getNodeList(SpaceshipCollisionNode)
	self.bullets = engine.getNodeList(BulletCollisionNode)
end

function CollisionSystem:update(time)
	for _, spaceship in ipairs(self.spaceships) do
		for _, bullet in ipairs(self.bullets) do
			if bullet:hit(spaceship) then
				self.creator:destroy(spaceship)
				self.games[1].score = self.games[1].score + 1
				break
			end
		end
	end
end
return CollisionSystem

</code>

]]

local System = class('System')


--[[
priority:


Used internally to hold the priority of this system within the system list. This is
used to order the systems so they are updated in the correct order.
]]

function System:initialize()
  self.priority = 0
end

--[[
Called just after the system is added to the engine, before any calls to the update method.
Override this method to add your own functionality.

@param engine The engine the system was added to.
]]

function System:addToEngine(engine) end

--[[
Called just after the system is removed from the engine, after all calls to the update method.
Override this method to add your own functionality.

@param engine The engine the system was removed from.
]]

function System:removeFromEngine(engine) end


--[[
After the system is added to the engine, this method is called every frame until the system
is removed from the engine. Override this method to add your own functionality.

<p>If you need to perform an action outside of the update loop (e.g. you need to change the
systems in the engine and you don't want to do it while they're updating) add a listener to
the engine's updateComplete signal to be notified when the update loop completes.</p>

@param time The duration, in seconds, of the frame.
]]

function System:update(time) end

function System:__eq(rhs)
  return rawequal(self, rhs)
end

return System
