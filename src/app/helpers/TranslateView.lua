local TranslateView = {}
local winSize = cc.Director:getInstance():getWinSize()

local ghostLayer = cc.LayerColor:create(cc.c4b(0,0,0,0),winSize.width,winSize.height)
ghostLayer:retain()
ghostLayer:setVisible(false)

local function showGhostLayer()
  if ghostLayer:isVisible() then
    return
  end

  local function onTouchBegin()
    if not ghostLayer:isVisible() then
      return false
    end

    return true
  end

  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
  local eventDispatcher = ghostLayer:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, ghostLayer)
  ghostLayer.listener = listener

  ghostLayer:setVisible(true)
  ghostLayer:removeFromParent()

  local app = require("app.App"):instance()
  app.layers.top:addChild(ghostLayer,999)
end

local function hideGostLayer()
  if not ghostLayer:isVisible() then
    return
  end

  local eventDispatcher = ghostLayer:getEventDispatcher()
  if ghostLayer.listener then
    eventDispatcher:removeEventListener(ghostLayer.listener)
  end

  ghostLayer:removeFromParent()
  ghostLayer:setVisible(false)
end


function TranslateView.moveCtrl(ctrl,dir,call,isVertical)
  local time = 0.5

    
  if not ctrl.orgPos then
    ctrl.orgPos = cc.p(ctrl:getPosition())
  end

  local curPos = cc.p(ctrl:getPosition())
  local des = cc.p(curPos.x + dir * winSize.width,curPos.y)
  if isVertical then
    des = cc.p(curPos.x,curPos.y + dir * winSize.height)
  end

  local mv = cc.MoveTo:create(time,des)
  --local mv = cc.ScaleTo::create(0.2,1.0)

  --if call then
    mv = cc.Sequence:create(mv,cc.CallFunc:create(function()
      if call then
        call()
      end

      hideGostLayer()
    end))
  --end
  ctrl:runAction(cc.EaseBackOut:create(mv))
  --ctrl->runAction(ScaleTo::create(0.2,1.0))
  showGhostLayer()
end

function TranslateView.fadeIn(ctrl,dir,call,isVertical)
  local time = 0.5
    
  if not ctrl.orgPos then
    ctrl.orgPos = cc.p(ctrl:getPosition())
  end


  ctrl:setVisible(true)


  local curPos = cc.p(ctrl:getPosition())
  --local des = cc.p(curPos.x + dir * winSize.width,curPos.y)
  --local mv = cc.MoveTo:create(time,des)
  --ctrl:setPosition(des)
  --ctrl:setPosition(winSize)
  --ctrl:setPositionX(winSize.width)
  --ctrl:setPositionY(winSize.height)
  ctrl:setPosition(cc.p(0,0))

  print("winSizeX:",winSize.width)
  print("winSizeY:",winSize.height)
  print("curPosX:",curPos.x)
  print("curPosY:",curPos.y)
  
  ctrl:setAnchorPoint(cc.p(0.5,0.5))  
  ctrl:setScale(1)
  local mv = cc.ScaleTo:create(0.3,1)

  --if call then
    mv = cc.Sequence:create(mv,cc.CallFunc:create(function()
      if call then
        call()
      end

      hideGostLayer()
    end))
  --end
  ctrl:runAction(cc.EaseBackOut:create(mv))
  showGhostLayer()
end

function TranslateView.fadeOut(ctrl,dir,call,isVertical)
  local time = 0.5

    
  if not ctrl.orgPos then
    ctrl.orgPos = cc.p(ctrl:getPosition())
  end

  ctrl:setVisible(false)

  ctrl:setPosition(winSize)
  --ctrl:setScale(1)
  local mv = cc.ScaleTo:create(0.3,1)

  --if call then
    mv = cc.Sequence:create(mv,cc.CallFunc:create(function()
      if call then
        call()
      end

      hideGostLayer()
    end))
  --end
  ctrl:runAction(cc.EaseBackOut:create(mv))
  showGhostLayer()
end

return TranslateView
