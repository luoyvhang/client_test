local class = require('middleclass')
local EntityState = require('lash.fsm.EntityState')

--[[
This is a state machine for an entity. The state machine manages a set of states,
each of which has a set of component providers. When the state machine changes the state, it removes
components associated with the previous state and adds components associated with the new state.
]]
local EntityStateMachine = class('EntityStateMachine')

--[[
Constructor. Creates an EntityStateMachine.
]]
function EntityStateMachine:initialize(entity)
  self.entity = entity
  self.states = {}
end

--[[
Add a state to this state machine.

@param name The name of this state - used to identify it later in the changeState method call.
@param state The state.
@return This state machine, so methods can be chained.
]]
function EntityStateMachine:addState(name, state)
  self.states[name] = state
  return self
end

--[[
Create a new state in this state machine.

@param name The name of the new state - used to identify it later in the changeState method call.
@return The new EntityState object that is the state. This will need to be configured with
the appropriate component providers.
]]
function EntityStateMachine:createState(name)
  local state = EntityState()
  self.states[name] = state
  return state
end

--[[
Change to a new state. The components from the old state will be removed and the components
for the new state will be added.

@param name The name of the state to change to.
]]
function EntityStateMachine:changeState(name)
  local newState = self.states[name]
  assert(newState, "Entity state " .. name .. " doesn't exist")

  if newState == self.currentState then
    return
  end
  self.current = name

  local toAdd = {}

  for type, provider in pairs(newState.providers) do
    toAdd[type] = provider
  end

  if self.currentState then
    for type, provider in pairs(self.currentState.providers) do
      local other = toAdd[type]

      if other
      and other:identifier() == provider:identifier() then
        toAdd[type] = nil
      else
        self.entity:remove(type)
      end
    end
  end
  for type, provider in pairs(toAdd) do
    self.entity:add(provider:getComponent(), type)
  end
  self.currentState = newState
end


function EntityStateMachine:__eq(rhs)
  return rawequal(self, rhs)
end

return EntityStateMachine
