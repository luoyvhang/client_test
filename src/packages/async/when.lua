--Deferred

local type = type
local unpack = unpack
local select = select


local Deferred = require('async.Deferred')

local function when(...)
  local resolveValues = {...}
  local length, first = #resolveValues, resolveValues[1]

  local remaining = length
  if length == 1 and type(first.promise) ~= 'function' then
    remaining = 0
  end

  local resolveContexts, progressValues, progressContexts
  local deferred = (remaining == 1) and first or Deferred()

  local function updateFunc(inst, i, contexts, values)
    return function(...)
      contexts[i] = inst
      values[i] = (select('#', ...) > 1) and {...} or select(1, ...)
      if values == progressValues then
        deferred:notify(unpack(progressValues))
      else
        remaining = remaining - 1
        if remaining == 0 then
          deferred:resolve(unpack(resolveValues))
        end
      end
    end
  end

  if length > 1 then
    progressValues, progressContexts, resolveContexts = {}, {}, {}
    for i = 1, length do
      local rv = resolveValues[i]
      if rv and type(rv.promise) == 'function' then
        rv:promise()
          :progress(updateFunc(rv, i, progressContexts, progressValues))
          :done(updateFunc(rv, i, resolveContexts, resolveValues))
          :fail(function(...) deferred:reject(...) end)
      else
        remaining = remaining - 1
      end
    end
  end

  if remaining == 0 then
    deferred:resolve(unpack(resolveValues))
  end

  return deferred:promise()
end

return when
