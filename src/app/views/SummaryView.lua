local cache = require('app.helpers.cache')

local SummaryView = {}
function SummaryView:initialize()
end

function SummaryView:layout()
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel = MainPanel

  local bg = MainPanel:getChildByName('bg')
  bg:setPosition(display.cx,display.cy)

  --local logo = MainPanel:getChildByName('logo')
  --logo:setPosition(display.cx,display.height)

  local frame = MainPanel:getChildByName('frame')
  frame:setPosition(display.cx,display.cy)
  self.frame = frame

  local clip = frame:getChildByName('clip')
  local players = clip:getChildByName('players')
  players:setItemModel(players:getItem(0))
  players:removeAllItems()
  self.players = players
end

function SummaryView:loadByDesk(desk,fsummay,record)
  dump(fsummay)
  dump(record)

  if desk.info.ownerName then
    self.frame:getChildByName('owner'):setString('房主:'..desk.info.ownerName)
  else
    self.frame:getChildByName('owner'):setString('')
  end

  --local info = desk.info
  --self.frame:getChildByName('room'):getChildByName('number'):setString(info.deskId)
  --self.frame:getChildByName('double'):getChildByName('number'):setString(info.deskInfo.double)
  --local round = self.frame:getChildByName('round'):getChildByName('number')
  --round:setString(info.number..'/'..info.deskInfo.round)
  --self.frame:getChildByName('owner'):getChildByName('number'):setString(info.ownerName)

  local max = -1
  local biggest
  for i = 1,#fsummay do
    self.players:pushBackDefaultItem()

    local nickName = fsummay[i].nickName
    local money = fsummay[i].money
    local playerId = fsummay[i].playerId
    local uid = fsummay[i].uid

    local item = self.players:getItem(i-1)
    local head = item:getChildByName('head')
    local icon = head:getChildByName('icon')
    if fsummay[i].avatar then
      cache.get(fsummay[i].avatar,function(ok,path)
        if ok then
          icon:loadTexture(path)
        end
      end)
    end

    head:getChildByName('nickname'):setString(nickName)
    head:getChildByName('id'):setString(playerId)
    item:getChildByName('title'):getChildByName('score'):setString(money)

    if money < 0 then
      local win_or_lose = item:getChildByName('win_or_lose')
      win_or_lose:loadTexture('views/jiesuan/14.png')
      win_or_lose:setContentSize(cc.size(82,57))
    end

    local keys = {
      'zimo',
      'jiepao',
      'gang',
      'angang',
      'dianpao'
    }

    for k = 1,#keys do
      local value = 0
      if record[uid] and record[uid][keys[k]] then
        value = record[uid][keys[k]]
      end

      item:getChildByName(keys[k]):getChildByName('value'):setString(value)
      item:getChildByName(keys[k]):getChildByName('title'):enableOutline(cc.c4b(115,29,0,255),1)
    end

    item:getChildByName('icon'):hide()

    if money > max then
      max = money
      biggest = item
    end
  end

  biggest:getChildByName('icon'):show()

  if #fsummay > 4 then
    local size = self.players:getContentSize()
    self.players:visit()

    local innerSize = self.players:getInnerContainerSize()
    self.players:setContentSize(innerSize)

    local sc = size.width / innerSize.width
    self.players:setScale(sc)
  end
end

return SummaryView
