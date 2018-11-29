local WanFaView = {}
function WanFaView:initialize()
end

function WanFaView:layout()
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel = MainPanel

  local middle = MainPanel:getChildByName('middle')
  middle:setPosition(display.cx,display.cy)  
  local ListView = middle:getChildByName('rulePanel'):getChildByName('ListView')   
  ListView:setScrollBarEnabled(false)
  --middle:setVisible(false)

  --local TopBar = MainPanel:getChildByName('TopBar')
  --TopBar:setPositionY(display.height)

  --local bg = MainPanel:getChildByName('bg')
  --bg:setContentSize(cc.size(display.width,display.height))
  --bg:setPosition(display.cx,display.cy)

  self.focus = 1
end

function WanFaView:clickTab(tag)
  self.focus = tag
end


return WanFaView
