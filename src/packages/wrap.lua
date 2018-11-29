local wrap = {}

local execludes = {
  __add = true,
  __call = true,
  __call = true,
  __div = true,
  __eq = true,
  __gc = true,
  __index = true,
  __le = true,
  __lt = true,
  __mul = true,
  __newindex = true,
  __sub = true,
  create = true,
  init = true,
  new = true,
  onCleanup_ = true,
  onEnterTransitionFinish_ = true,
  onEnter_ = true,
  onExitTransitionStart_ = true,
  onExit_ = true,
}


local function allmethods(meta)
  local methods = {}
  while meta do
    for k, v in pairs(meta) do
      if not execludes[k] and type(v) == 'function' then
        methods[k] = true
      end
    end
    meta = getmetatable(meta)
  end
  return methods
end

local function hasmeta(instance, meta)
  local m = getmetatable(instance)
  while m do
    if m == meta then
      return true
    end
    m = getmetatable(m)
  end
  return false
end

function wrap.wrap(classname, toluaclass)
  local class = require('middleclass')
  local Wrapped = class(classname)
  local meta = getmetatable(toluaclass)

  for k, _ in pairs(allmethods(meta)) do
    Wrapped[k] = function(self, ...)
      local ud = self._ud
      return ud[k](ud, ...)
    end
  end

  function Wrapped:initialize(userdata)
    self:set(userdata)
  end

  function Wrapped:set(userdata)
    -- I just don't know how to convert some thing like cc.Node to 'cc.Node'
    --assert(hasmeta(userdata, meta), "arg #1 expected userdata with specified tolua type")
    self._ud = userdata
  end

  function Wrapped:get()
    -- I just don't know how to convert some thing like cc.Node to 'cc.Node'
    return self._ud
  end

  return Wrapped
end

setmetatable(wrap, { __call = function(_, ...) return wrap.wrap(...) end })


return wrap
