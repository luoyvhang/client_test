local KefuView = {}

function KefuView:initialize()
end

function KefuView:layout()
  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setPosition(display.cx,display.cy)

  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))

  local sc = cc.ScaleTo:create(0.1,1.0)
  self.MainPanel:setScale(0.1)
  self.MainPanel:runAction(sc)
end

function KefuView:fresh(msg)
  local content = self.MainPanel:getChildByName('content')
  content:setString(msg.content)
end

return KefuView
