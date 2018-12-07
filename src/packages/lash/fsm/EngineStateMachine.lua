local class = require('middleclass')
local EngineState = require('lash.fsm.EngineState')

--[[
This is a state machine for the Engine. The state machine manages a set of states,
each of which has a set of System providers. When the state machine changes the state, it removes
Systems associated with the previous state and adds Systems associated with the new state.
]]
local EngineStateMachine = class('EngineStateMachine')

--[[
Constructor. Creates an SystemStateMachine.
]]
function EngineStateMachine:initialize(engine)
  self.engine = engine
  self.states = {}
end

--[[
Add a state to this state machine.

@param name The name of this state - used to identify it later in the changeState method call.
@param state The state.
@return This state machine, so methods can be chained.
]]
function EngineStateMachine:addState(name, state)
  self.states[name] = state
  return self
end

--[[
Create a new state in this state machine.

@param name The name of the new state - used to identify it later in the changeState method call.
@return The new EntityState object that is the state. This will need to be configured with
the appropriate component providers.
]]
function EngineStateMachine:createState(name)
  local state = EngineState()
  self.states[name] = state
  return state
end

--[[
Change to a new state. The Systems from the old state will be removed and the Systems
for the new state will be added.

@param name The name of the state to change to.
]]
function EngineStateMachine:changeState(name)
  local newState = self.states[name]
  assert(newState, "Engine state " .. name .. " doesn't exist")

  if newState == self.currentState then
    return
  end
  local toAdd = {}

  for _, provider in ipairs(newState.providers) do
    local id = provider:identifier()
    toAdd[id] = provider
  end

  if self.currentState then
    for _, provider in ipairs(self.currentState.providers) do
      local id = provider:identifier()
      if toAdd[id] then
        toAdd[id] = nil
      else
        self.engine:removeSystem(provider:getSystem())
      end
    end
  end
  for _, provider in pairs(toAdd) do
    self.engine:addSystem(provider:getSystem(), provider:priority())
  end
  self.currentState = newState
end

function EngineStateMachine:__eq(rhs)
  return rawequal(self, rhs)
end

return EngineStateMachine
