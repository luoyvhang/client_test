
local class = require('middleclass')
local Input = class('Input')

--[[
Touch.phase:
  - Began	A finger touched the screen.
  - Moved	A finger moved on the screen.
  - Stationary	A finger is touching the screen but hasn't moved.
  - Ended	A finger was lifted from the screen. This is the final phase of a touch.
  - Canceled	The system cancelled tracking for the touch.
]]


local function createTouchListener(self)
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(false)
  listener:registerScriptHandler(function(touch, _)
    touch.phase = 'Began'
    table.insert(self.touches, touch)
    touch:retain()
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, _)
    touch.phase = 'Moved'
  end, cc.Handler.EVENT_TOUCH_MOVED)

  listener:registerScriptHandler(function(touch, _)
    touch.phase = 'Ended'
  end, cc.Handler.EVENT_TOUCH_ENDED)

  listener:registerScriptHandler(function(touch, _)
    touch.phase = 'Canceled'
  end, cc.Handler.EVENT_TOUCH_CANCELLED)
  return listener
end

local function createKeyListener(self)
  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(function(keycode, _)
    self.keys[keycode] = true
    self.keydowns[keycode] = true
  end, cc.Handler.EVENT_KEYBOARD_PRESSED)

  listener:registerScriptHandler(function(keycode, _)
    self.keys[keycode] = nil
    self.keyups[keycode] = true
  end, cc.Handler.EVENT_KEYBOARD_RELEASED)
  return listener
end

local function createEndFreameListener(self, dispatcher)
  return dispatcher:addCustomEventListener('director_after_draw', function()
    for i=#self.touches,1,-1 do
      local touch = self.touches[i]
      if touch.phase == 'Ended' or touch.phase == 'Canceled' then
        table.remove(self.touches, i)
        touch:release()
      else
        touch.phase = 'Stationary'
      end
    end
    self.keydowns = {}
    self.keyups = {}
  end)
end


function Input:initialize()
  self.touches = {}
  self.keys = {}
  self.keydowns = {}
  self.keyups = {}
  local listeners = {}
  local dispatcher = cc.Director:getInstance():getEventDispatcher()
  for _, create in ipairs({createTouchListener, createKeyListener}) do
    local listener = create(self)
    dispatcher:addEventListenerWithFixedPriority(listener, -10000)
    listeners[#listeners+1] = listener
  end


  listeners[#listeners+1] = createEndFreameListener(self, dispatcher)
  self.listeners = listeners
end

function Input:delete()
  local dispatcher = cc.Director:getInstance():getEventDispatcher()
  for _, listener in ipairs(self.listeners) do
    dispatcher:removeEventListener(listener)
  end
end

function Input:getTouchCount()
  return #self.touches
end

function Input:getTouch(index)
  return self.touches[index]
end

local function convertKeycode(keycode)
  return type(keycode) == 'string' and cc.KeyCode[keycode] or keycode
end

function Input:getKey(keycode)

  return self.keys[convertKeycode(keycode)]
end

function Input:getKeyDown(keycode)
  return self.keydowns[convertKeycode(keycode)]
end


function Input:getKeyUp(keycode)
  return self.keyups[convertKeycode(keycode)]
end

return Input
