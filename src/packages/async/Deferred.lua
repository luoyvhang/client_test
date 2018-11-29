--Deferred

local pairs, ipairs = pairs, ipairs
local type = type
local Callbacks = require('async.Callbacks')

local function _extend(target, ...)
  for _, t in ipairs{...} do
    for k, v in pairs(t) do
      target[k] = v
    end
  end
  return target
end

local _methods = {
  {'resolve', 'done'},
  {'reject', 'fail'},
  {'progress', 'notify'}
}

local function Deferred(func)
  local _state, deferred, promise = 'pending', {}, {}
  local _done = Callbacks('once', 'memory')
  local _fail = Callbacks('once', 'memory')
  local _progress = Callbacks('memory')

  _done:add(function()
    _state = 'resolved'
    _fail:disable()
    _progress:lock()
  end)

  _fail:add(function()
    _state = 'rejected'
    _done:disable()
    _progress:lock()
  end)

  function promise:state() return _state end

  function promise:always(...)
    deferred:done(...):fail(...)
    return self
  end

  --params: fnDone, fnFail, fnProgress
  function promise:pipe(...)
    local fns = {...}
    return Deferred(function(newDefer)
      for i, method in ipairs(_methods) do
        local fn = (type(fns[i]) == 'function') and fns[i]
        deferred[method[2]](deferred, function(...)
          local returned = fn and fn(...)
          if returned and type(returned.promise) == 'function' then
            returned:promise()
              :done(function(...) newDefer:resolve(...) end)
              :fail(function(...) newDefer:reject(...) end)
              :progress(function(...) newDefer:notify(...) end)
          else
            newDefer[method[1]](newDefer, ...)
          end
        end)
      end

      fns = nil
    end):promise()
  end

  function promise:promise(obj)
    return (obj) and _extend(obj, promise) or promise
  end

  function promise:done(...)
    _done:add(...)
    return self
  end

  function promise:fail(...)
    _fail:add(...)
    return self
  end

  function promise:progress(...)
    _progress:add(...)
    return self
  end

  function deferred:resolve(...)
    _done:fire(...)
    return self
  end

  function deferred:reject(...)
    _fail:fire(...)
    return self
  end

  function deferred:notify(...)
    _progress:fire(...)
    return self
  end

  promise:promise(deferred)
  if func then func(deferred) end
  return deferred
end

return Deferred
