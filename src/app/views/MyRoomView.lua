local FrameAction = require('app.helpers.FrameAction')
local Scheduler = require('app.helpers.Scheduler')

local MyRoomView = {}
function MyRoomView:initialize()
  self.updateF = Scheduler.new(function(dt)
    self:update(dt)
  end)

  self.delay = 0
  self:enableNodeEvents()
end

function MyRoomView:onExit()
  Scheduler.delete(self.updateF)
  self.updateF = nil
end

function MyRoomView:update(dt)
  self.delay = self.delay + dt
  if self.delay > 5.0 then
    self.delay = 0

    --self.emitter:emit('fresh')
  end
end

function MyRoomView:layout()
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel = MainPanel

  local bg = MainPanel:getChildByName('bg')
  bg:setContentSize(cc.size(display.width,display.height))
  bg:setPosition(display.cx,display.cy)

  local TopBar = self.MainPanel:getChildByName('TopBar')
  TopBar:setPositionY(display.height)
  local size = TopBar:getContentSize()

  local topY = TopBar:getPositionY() - size.height - 5
  local list = self.MainPanel:getChildByName('list')
  local listHeight = topY - 20
  list:setPositionY(topY)
  size = list:getContentSize()
  list:setContentSize(cc.size(size.width,listHeight))

  local item = list:getItem(0)
  list:setItemModel(item)
  list:removeAllItems()
  self.list = list

  self.black = self.ui:getChildByName('black')
  self.black:setContentSize(cc.size(display.width,display.height))
  self.black:hide()

  self.RoomInfo = self.ui:getChildByName('RoomInfo')
  self.RoomInfo:hide()
  self.RoomInfo:setPosition(display.cx,display.cy)

  self.RoomInfo.list = self.RoomInfo:getChildByName('list')
  self.RoomInfo.list:setItemModel(self.RoomInfo.list:getItem(0))
  self.RoomInfo.list:removeAllItems()

  size = self.RoomInfo:getContentSize()
  local arrow = cc.Sprite:create('animation/arrow0/arrow-1.png')
  self.RoomInfo:addChild(arrow)
  arrow:setPosition(size.width / 2,40)

  local action = FrameAction.create('animation/arrow0/arrow-%d.png',8,1,0.03)
  arrow:runAction(action)
end

local wan_fa = {
  xuezhan = '血战到底',
  yunnan = '曲靖小鸡',
  neijiang = '内江麻将',
}

function MyRoomView:loadRooms(rooms)
  local items = self.list:getItems()
  local diff = #rooms - #items

  if diff > 0 then
    for _ = 1,diff do
      self.list:pushBackDefaultItem()
    end
  else
    for _ = 1,math.abs(diff) do
      self.list:removeLastItem()
    end
  end

  for i, v in pairs(rooms) do
    local room = v
    local item = self.list:getItem(i-1)

    local frame = item:getChildByName('frame')

    local path
    local isover = false
    if room.over then
      path = 'views/myroom/wan2.png'
      isover = true
    else
      path = 'views/myroom/wan1.png'
    end

    frame:getChildByName('head'):loadTexture(path)
    local horse = frame:getChildByName('horse')
    horse:setVisible(room.options.enter.buyHorse == 1)

    frame:getChildByName('bt1'):addClickEventListener(function()
      self.emitter:emit('invoke',room)
    end)

    local wanfa = frame:getChildByName('wanfa')
    dump(room)
    wanfa:setString('玩法: '..wan_fa[room.game])

    local jushu = frame:getChildByName('jushu')
    jushu:setString(room.round..'/'..room.options.round)

    item:getChildByName('no'):getChildByName('value'):setString(room.deskId)
    --item:getChildByName('no'):getChildByName('pvalue'):setString(#room.actors..'/'..room.maxActors)
    item:getChildByName('no'):getChildByName('pvalue'):setString(room.actors..'/'..room.maxActors)

    local bt4 = frame:getChildByName('bt4')
    local bt3 = frame:getChildByName('bt3')

    if not isover then
      bt3:addClickEventListener(function()
        self.emitter:emit('enter',room)
      end)
    else
      bt4:loadTextures('views/myroom/del.png','')
      bt4:addClickEventListener(function()
        self.emitter:emit('delete',room)
      end)
    end
  end
end

function MyRoomView:showRoomInfo(room)
  self.black:show()
  self.RoomInfo:show()

  self.RoomInfo:setScale(0.1)
  local sc = cc.ScaleTo:create(0.05,1)
  self.RoomInfo:runAction(sc)
  self.RoomInfo.list:removeAllItems()

  for i = 1,#room.actors do
    self.RoomInfo.list:pushBackDefaultItem()
    local item = self.RoomInfo.list:getItem(i-1)
    item:getChildByName('nickname'):setString(room.actors[i].nickName)
    item:getChildByName('id'):setString(room.actors[i].id)
  end
end

function MyRoomView:clickBlack()
  self.black:hide()
  self.RoomInfo:hide()
end

return MyRoomView
