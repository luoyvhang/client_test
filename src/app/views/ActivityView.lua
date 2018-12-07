local ActivityView = {}
function ActivityView:initialize()
end

function ActivityView:layout()
  self.ui:setPosition(display.cx,display.cy)
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  self.MainPanel = MainPanel

  --启动动画
  self:startCsdAnimation(MainPanel:getChildByName("titleNode"),"titleanimation",true,1.0)
  self:startCsdAnimation(MainPanel:getChildByName("titleNode2"),"lightBeamAnimation",true,0.5)
  self:startCsdAnimation(MainPanel:getChildByName("tabNode"),"blinkingBoxAnimation",true,1.3)
end

function ActivityView:getNotify(msg)
  self.ui:getChildByName("Content"):getChildByName("title"):setString(msg.title)
 -- self.ui:getChildByName("Content"):getChildByName("content"):setString(msg.content)
end

function ActivityView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
  local action = cc.CSLoader:createTimeline("views/activity/"..csbName..".csb")
  action:gotoFrameAndPlay(0,isRepeat)
  if timeSpeed then
    action:setTimeSpeed(timeSpeed)
  end
  node:stopAllActions()
  node:runAction(action)
end

function ActivityView:stopCsdAnimation( )
  self.MainPanel:getChildByName("titleNode"):stopAllActions()
  self.MainPanel:getChildByName("titleNode2"):stopAllActions()
  self.MainPanel:getChildByName("tabNode"):stopAllActions()
end

return ActivityView
