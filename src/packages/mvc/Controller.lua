local class = require('middleclass')
local Controller = class("Controller")
local View = require('mvc.View')

local callbackTypeToRegisterMethod = {
  ["Click"] = 'addClickEventListener',
  ["Touch"] = 'addTouchEventListener',
  ["Event"] = 'addCCSEventListener',
}

local function bindSignal(target, node)
  if not node.getCallbackName then return end -- Only Widget has this method

  local f, t = node:getCallbackName(), node:getCallbackType()
  local m = callbackTypeToRegisterMethod[t]
  if not m or not f or #f == 0 then return false end
  -- call the addXXXListener() function...
  node[m](node, function(sender, ...)
    if target[f] then
        target[f](target, sender, ...)
    else
        target.emitter:emit(f, sender, ...)
    end
  end)
end

local function bindSignalForTree(target, node)
  bindSignal(target, node)
  for _, v in ipairs(node:getChildren()) do
    bindSignalForTree(target, v)
  end
end


function Controller.static:load(name, ...)
  print(type(name))
  assert(type(name) == 'string', 'Controller.loadController is a static method')
  local Klass = require('app.controllers.'..name)
  assert(type(Klass) ~= 'boolean', '"app/controllers/'..name..'" must return a class')
  local c = Klass(...)
  c.view = assert(c:loadView(), name)
  c.view:retain()
  if c.viewDidLoad then
    c:viewDidLoad()
  end
  return c
end

-- ctor -> init -> loadView ->


function Controller:loadView()
  local viewName = self.class.name:gsub('Controller', 'View')
  local view = View:create(viewName, self)
  bindSignalForTree(self, view.ui)
  return view
end

function Controller:finalize() -- called before controller removed from stage
  -- This function is intend to be overwrite by subclass
  -- DO NOT ADD CODE HERE
end

function Controller:viewDidLoad()
  -- This function is intend to be overwrite by subclass
  -- DO NOT ADD CODE HERE
end

local function instanceof(obj, klass)
  local k = obj.class
  while k and k ~= klass do
    k = k.super
  end

  return k == klass
end

function Controller:add(controller)
  assert(controller, 'contoller should not be nil')
  assert(instanceof(controller, Controller), 'arg #2 requires a contoller') -- luacheck: ignore iskindof
  self.children = self.children or {}
  self.children[controller] = controller
  controller._parent = self
end

function Controller:clearView()
  if not self.view then
    return
  end

  if self.view:getParent() then
    self.view:removeFromParent()
  end
  self.view:release()
  self.view = nil
end

function Controller:delete()
  self:finalize()

  if self.children then
    for k, _ in pairs(self.children) do
      k:delete()
    end
    self.children = nil
  end

  self:clearView()

  if self._parent then
    self._parent.children[self] = nil
    self._parent = nil
  end
end

return Controller
