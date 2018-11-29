local EnableBuildingTouch = {}
local MainCityController = require('app.controllers.MainCityController')


function EnableBuildingTouch.enable(building,touchBegan,touchMoved,touchEnded)
  local listener = cc.EventListenerTouchOneByOne:create()
  --listener:setSwallowTouches(true)

  local function clickBuilding(locaition)
    local wpos = locaition:getLocation()
    local size = building:getContentSize()

    local npos = building:convertToNodeSpace(wpos)
    local rect = cc.rect(0,0,size.width * 0.8,size.height * 0.8)
    local flag = cc.rectContainsPoint(rect,npos)

    return flag,wpos
  end

  local function buildingAction(call)
    if not building.orgPos then
      building.orgPos = cc.p(building:getPosition())
    end

    local orgPos = building.orgPos
    local desPos = cc.p(orgPos.x,orgPos.y + 5)
    local m0 = cc.MoveTo:create(0.1,desPos)
    local m1 = cc.MoveTo:create(0.05,orgPos)

    building:runAction(cc.Sequence:create(m0,m1,cc.CallFunc:create(function()
      --local t0 = cc.TintTo:create(0.5,150,150,150)
      --local t1 = cc.TintTo:create(0.5,255,255,255)
      --building:runAction(cc.RepeatForever:create(cc.Sequence:create(t0,t1)))
      call()
    end)))

    --MainCityController.getInstance():setCurClickBuilding(building)
  end

  local function began(locaition)
    local flag,wpos = clickBuilding(locaition)
    if flag and touchBegan then
      touchBegan(wpos.x,wpos.y)
    end
    building.delta = {x = 0, y = 0}
    return flag
  end

  local function moved(touch)
		local delta = touch:getDelta()
    building.delta.x = building.delta.x + math.abs(delta.x)
    building.delta.y = building.delta.y + math.abs(delta.y)
		--self.offset = pos.y - self.prev
		--self.prev = pos.y
  end

  local function isVaildMove()
    if building.delta.x < 20 and building.delta.y < 20 then
      return true
    else
      return false
    end
  end
  local function ended(locaition)
    if isVaildMove() then
      local flag,wpos = clickBuilding(locaition)
      --print(flag,wpos)
      local curSelBuilding = MainCityController.getInstance():getCurClickBuilding()
      if touchEnded  and curSelBuilding ~= building  then
        buildingAction(function()
          touchEnded(wpos.x,wpos.y,flag)
        end)
      end
    end
  end

  listener:registerScriptHandler(began,cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(moved,cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(ended,cc.Handler.EVENT_TOUCH_ENDED)

  local eventDispatcher = building:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, building)
end

return EnableBuildingTouch
