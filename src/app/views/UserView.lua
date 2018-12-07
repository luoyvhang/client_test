local UserView = {}

function UserView:initialize()
end

function UserView:layout(player)
  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))

  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setPosition(display.cx,display.cy)

  self.MainPanel:setScale(0.1)
  local sc = cc.ScaleTo:create(0.1,1.0)
  self.MainPanel:runAction(sc)

  local list = self.MainPanel:getChildByName('list')
  local idPanel = list:getChildByName('id')
  local vipPanel = list:getChildByName('vip')
  local namePanel = list:getChildByName('name')

  dump(player)

  idPanel:getChildByName('value'):setString(player.actor.playerId)
  vipPanel:getChildByName('value'):setString(player.actor.vip)
  namePanel:getChildByName('value'):setString(player.actor.nickName)
end

return UserView
