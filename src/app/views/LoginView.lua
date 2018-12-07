local tools = require('app.helpers.tools')

local LoginView = {}
function LoginView:initialize()
end

function LoginView:layout(version)
  local MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel = MainPanel
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)

  -- 取消logo掉落动画
  -- local logo = MainPanel:getChildByName("logo")
  -- local x = logo:getPositionX()
  -- logo:runAction(transition.sequence {
  --       cc.DelayTime:create(0.3),
  --       transition.newEasing(cc.MoveTo:create(0.9, cc.p(x, 450)), "BOUNCEOUT"),
  --     })

  -- MainPanel:getChildByName('version'):setString(tostring(version))

  self.XieyiLayer = self.MainPanel:getChildByName('XieyiLayer')
  self:freshXieyiLayer(false)

  self.agree = self.MainPanel:getChildByName('ok'):getChildByName('yes')

  self.XieyiList = self.XieyiLayer:getChildByName('XieyiList')
  self.XieyiList:setScrollBarEnabled(false)

  self:startAction()
  --self:init3dLayer()
end

function LoginView:init3dLayer()

  local layer3D = cc.Layer:create()
  self:addChild(layer3D,999)
  layer3D:setCameraMask(cc.CameraFlag.USER1)

  self._camera = cc.Camera:createPerspective(45, display.width / display.height, 1,3000)
  self._camera:setCameraFlag(cc.CameraFlag.USER1)
  layer3D:addChild(self._camera)
  self._camera:setDepth(1)

  local node1 = cc.Node:create()
  layer3D:addChild(node1)
  --node1:setRotation3D(cc.vec3(0,0,90))

  local node = cc.Node:create()
  node1:addChild(node)
  node:setRotation3D(cc.vec3(0,0,180))

  local path = '3d/su.c3t'

  local card3d = cc.Sprite3D:create(path)
  node:addChild(card3d)
  card3d:setScale(1.3)
  card3d:setTexture('3d/test05.jpg')
  card3d:setCameraMask(cc.CameraFlag.USER1)

  

  self._camera:setPosition3D(cc.vec3(0, 0, -1400))
  self._camera:lookAt(cc.vec3(0,0,0), cc.vec3(0, 1, 0))

  local animation = cc.Animation3D:create(path)
  if nil ~= animation then
      local animate = cc.Animate3D:createWithFrames(animation,0,0)
      animate:setQuality(3)
      local speed = 0.6
      animate:setSpeed(speed)
      animate:setTag(110)

      --[[local call = cc.CallFunc:create(function()
        card3d:hide()

        path = '3d/sec.c3t'

        local card3d_flip = cc.Sprite3D:create(path)
        node:addChild(card3d_flip)
        card3d_flip:setTexture('3d/poker.jpg')
        card3d_flip:setCameraMask(cc.CameraFlag.USER1)

        animation = cc.Animation3D:create(path)
        if nil ~= animation then
          animate = cc.Animate3D:createWithFrames(animation,0,15)
          speed = 1.0
          animate:setSpeed(speed)

          card3d_flip:runAction(animate)
        end
      end)]]

      card3d:runAction(animate)--(cc.Sequence:create(animate,call))--
  end
end

function LoginView:freshXieyiLayer(bool)
  self.XieyiLayer:setVisible(bool)
end

function LoginView:getIsAgree()
  return self.agree:isVisible()
end

function LoginView:freshIsAgree()
  local bool = self:getIsAgree()
  self.agree:setVisible(not bool)
end

function LoginView:startAction( )
  self:startCsdAnimation(self.MainPanel:getChildByName("nnBodyNode"), "nnBodyAnimation", true, 1/3)
  self:startCsdAnimation(self.MainPanel:getChildByName("starNode1"), "starAnimation", true)
  self:startCsdAnimation(self.MainPanel:getChildByName("starNode2"), "starAnimation", true)
  self:startCsdAnimation(self.MainPanel:getChildByName("lightBeamNode1"), "lightBeamAnimation", true)
  self:startCsdAnimation(self.MainPanel:getChildByName("lightBeamNode2"), "lightBeamAnimation", true)
  self:startCsdAnimation(self.MainPanel:getChildByName("goldCupNode"), "blinkingCupAnimation", true)
  self:startCsdAnimation(self.MainPanel:getChildByName("logoNode"), "logoAnimation", true, 0.5)
  self:startCsdAnimation(self.MainPanel:getChildByName("login_0"):getChildByName("loginNode"), "loginAnimation", true, 1.5)

end

function LoginView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
  local action = cc.CSLoader:createTimeline("views/login/"..csbName..".csb")
  action:gotoFrameAndPlay(0,isRepeat)
  if timeSpeed then
    action:setTimeSpeed(timeSpeed)
  end
  node:stopAllActions()
  node:runAction(action)
end

function LoginView:stopAllCsdAnimation()
  self.MainPanel:getChildByName("nnBodyNode"):stopAllActions()
  self.MainPanel:getChildByName("starNode1"):stopAllActions()
  self.MainPanel:getChildByName("starNode2"):stopAllActions()
  self.MainPanel:getChildByName("lightBeamNode1"):stopAllActions()
  self.MainPanel:getChildByName("lightBeamNode2"):stopAllActions()
  self.MainPanel:getChildByName("goldCupNode"):stopAllActions()
  self.MainPanel:getChildByName("logoNode"):stopAllActions()
  self.MainPanel:getChildByName("login_0"):getChildByName("loginNode"):stopAllActions()
end
return LoginView
