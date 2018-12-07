local AddBlackLayer = {}
local winSize = cc.Director:getInstance():getWinSize()

function AddBlackLayer.swallowTouches(node, call)
  local function onTouchBegin()
    if not node:isVisible() then
      return false
    end
    
    return true
  end

  local function onTouchEnded()
    if call then
      call()
    end
  end

  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
  listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

  local eventDispatcher = node:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function AddBlackLayer.add(call)
  local bg = cc.LayerColor:create(cc.c4b(0,0,0,255 * 0.2),winSize.width,winSize.height)
  AddBlackLayer.swallowTouches(bg, call)
  print('create AddBlackLayer...')
  return bg
end

return AddBlackLayer
