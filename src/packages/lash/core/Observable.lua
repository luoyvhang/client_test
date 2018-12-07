
local function Subscription(slots, callback)
  local this = {slots=slots, callback= callback}
  function this:dispose()
    self.slots[self.callback] = nil
  end
  return this
end

local function Emitter()
  local emitter = {}
  local subscribes = {}

  local function on(signal, callback, once)
    assert(type(signal) == 'string')
    assert(type(callback) == 'function' or type(getmetatable(callback).__call) == 'function')
    local t = subscribes[signal]
    if not t then
      t = {}
      subscribes[signal] = t
    end

    t[callback] = once and true or false
    return Subscription(t, callback)
  end

  function emitter:on(event, callback)
    assert(self == emitter, 'Use emitter:on() not emitter.on()')
    return on(event, callback)
  end

  function emitter:once(event, callback)
    assert(self == emitter, 'Use emitter:once() not emitter.once()')
    return on(event, callback, true)
  end

  function emitter:emit(signal, ...)
    assert(self == emitter, 'Use emitter:emit() not emitter.emit()')
    local slots = subscribes[signal]
    if slots then
      for f, once in pairs(slots) do
        f(...)
        if once then
          slots[f] = nil
        end
      end
    end
  end

  return emitter
end

local Observable = {}

function Observable:on(event, callback)
  return self.emitter:on(event, callback)
end

function Observable:once(event, callback)
  return self.emitter:once(event, callback)
end

function Observable:emit(event, ...)
  return self.emitter:emit(event, ...)
end

function Observable:initialize()
  Observable.reset(self)
end

function Observable:reset()
  self.emitter = Emitter()
end

return Observable
