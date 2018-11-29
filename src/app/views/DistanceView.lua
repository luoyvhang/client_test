local cache = require('app.helpers.cache')
local DistanceView = {}
local distance = require('distance.distance')

function DistanceView:initialize()
end

function DistanceView:layout(desk)
  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setPosition(display.cx,display.cy)

  self.MainPanel:setScale(0.1)
  local sc = cc.ScaleTo:create(0.1,1.0)
  self.MainPanel:runAction(sc)

  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))

  self:load(desk)
end

function DistanceView:load(desk)
  local list = self.MainPanel:getChildByName('list')
  list:setItemModel(list:getItem(0))
  list:removeAllItems()

  local idx = 0
  local function push()
    list:pushBackDefaultItem()
    local item = list:getItem(idx)
    idx = idx + 1

    return item
  end


  local down = desk:getPlayerByKey('down')
  local left = desk:getPlayerByKey('left')
  local right = desk:getPlayerByKey('right')
  local top = desk:getPlayerByKey('top')

  local function loadAvatar(head,data)
    if data.actor.avatar then
      head:retain()
      cache.get(data.actor.avatar,function(ok,path)
        if ok then
          head:loadTexture(path)
        end

        head:release()
      end)
    end
  end


  local function setDistance(player0,player1,item)
    if not player0.actor.x then return end
    if not player1.actor.x then return end

    local startPos = cc.p(player0.actor.x,player0.actor.y)
    local endPos = cc.p(player1.actor.x,player1.actor.y)

    local ret = distance.getDistance(startPos,endPos)
    local tdistance = item:getChildByName('distance')
    ret = math.floor(ret)

    if ret > 1000 then
      tdistance:setString('距离:'..math.floor(ret/1000)..'公里')
    else
      tdistance:setString('距离:'..math.floor(ret)..'米')
    end
  end

  if down and left then
    local item = push()

    local l = item:getChildByName('left')
    local r = item:getChildByName('right')

    l:getChildByName('name'):setString(down.actor.nickName)
    r:getChildByName('name'):setString(left.actor.nickName)

    loadAvatar(l,down)
    loadAvatar(r,left)

    setDistance(down,left,item)
  end

  if down and right then
    local item = push()

    local l = item:getChildByName('left')
    local r = item:getChildByName('right')

    l:getChildByName('name'):setString(down.actor.nickName)
    r:getChildByName('name'):setString(right.actor.nickName)

    loadAvatar(l,down)
    loadAvatar(r,right)

    setDistance(down,right,item)
  end

  if down and top then
    local item = push()

    local l = item:getChildByName('left')
    local r = item:getChildByName('right')

    l:getChildByName('name'):setString(down.actor.nickName)
    r:getChildByName('name'):setString(top.actor.nickName)

    loadAvatar(l,down)
    loadAvatar(r,top)

    setDistance(down,top,item)
  end

  if left and right then
    local item = push()

    local l = item:getChildByName('left')
    local r = item:getChildByName('right')

    l:getChildByName('name'):setString(left.actor.nickName)
    r:getChildByName('name'):setString(right.actor.nickName)

    loadAvatar(l,left)
    loadAvatar(r,right)

    setDistance(left,right,item)
  end

  if left and top then
    local item = push()

    local l = item:getChildByName('left')
    local r = item:getChildByName('right')

    l:getChildByName('name'):setString(left.actor.nickName)
    r:getChildByName('name'):setString(top.actor.nickName)

    loadAvatar(l,left)
    loadAvatar(r,top)

    setDistance(left,top,item)
  end

  if right and top then
    local item = push()

    local l = item:getChildByName('left')
    local r = item:getChildByName('right')

    l:getChildByName('name'):setString(right.actor.nickName)
    r:getChildByName('name'):setString(top.actor.nickName)

    loadAvatar(l,right)
    loadAvatar(r,top)

    setDistance(right,top,item)
  end
end

return DistanceView
