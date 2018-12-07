local ContactUsView = {}
function ContactUsView:initialize()
end

function ContactUsView:layout()
  self.ui:setPosition(display.cx,display.cy)
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  self.MainPanel = MainPanel

  --启动动画
  self:startCsdAnimation(MainPanel:getChildByName("Content"):getChildByName("lightBeamNode"),"lightBeamAnimation",true,0.5)
  self:startCsdAnimation(MainPanel:getChildByName("Content"):getChildByName("feedbackNode"),"feedbackAnimation",true,1.3)
end

function ContactUsView:getNotify(msg)
  self.ui:getChildByName("Content"):getChildByName("title"):setString(msg.title)
 -- self.ui:getChildByName("Content"):getChildByName("content"):setString(msg.content)
end

function ContactUsView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
  local action = cc.CSLoader:createTimeline("views/contactus/"..csbName..".csb")
  action:gotoFrameAndPlay(0,isRepeat)
  if timeSpeed then
    action:setTimeSpeed(timeSpeed)
  end
  node:stopAllActions()
  node:runAction(action)
end

function ContactUsView:stopCsdAnimation( )
  self.MainPanel:getChildByName("Content"):getChildByName("lightBeamNode"):stopAllActions()
  self.MainPanel:getChildByName("Content"):getChildByName("feedbackNode"):stopAllActions()
end

return ContactUsView
