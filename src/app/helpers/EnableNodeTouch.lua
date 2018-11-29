local EnableNodeTouch = {}

function EnableNodeTouch.enable(node,began,moved,ended,Swallow)
  local function onTouchBegin(location)
    local pos = location:getLocation()
    return began(pos)
  end

  local function onTouchMove(location)
    local pos = location:getLocation()
    moved(pos)
  end

  local function onTouchEnded(location)
    local pos = location:getLocation()
    ended(pos)
  end

  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(Swallow)

  if began then
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
  end

  if moved then
    listener:registerScriptHandler(onTouchMove,cc.Handler.EVENT_TOUCH_MOVED)
  end

  if ended then
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
  end

  local eventDispatcher = node:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end


function EnableNodeTouch.enableMultitouchMode(layer)
  print('call enableMultitouchMode function ')
  local function onTouchBeganEx(touches,event)
    if layer.onTouchBeganEx then
      layer:onTouchBeganEx(touches,event)
    end
  end

  local function onTouchMovedEx(touches,event)
    if layer.onTouchMovedEx then
      layer:onTouchMovedEx(touches,event)
    end
  end

  local function onTouchEndedEx(touches,event)
    if layer.onTouchEndedEx then
      layer:onTouchEndedEx(touches,event)
    end
  end

  local touchListener = cc.EventListenerTouchAllAtOnce:create()
  touchListener:registerScriptHandler(onTouchBeganEx, cc.Handler.EVENT_TOUCHES_BEGAN)
  touchListener:registerScriptHandler(onTouchMovedEx, cc.Handler.EVENT_TOUCHES_MOVED)
  touchListener:registerScriptHandler(onTouchEndedEx, cc.Handler.EVENT_TOUCHES_ENDED)
  touchListener:registerScriptHandler(onTouchEndedEx, cc.Handler.EVENT_TOUCHES_CANCELLED)
  local eventDispatcher = layer:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(touchListener, layer)
  layer.touchListener = touchListener
end

return EnableNodeTouch
