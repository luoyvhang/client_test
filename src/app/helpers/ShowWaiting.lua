local ShowWaiting = {}
local AddBlackLayer = require('app.helpers.AddBlackLayer')
local sblack

function ShowWaiting.delete()
  if sblack then
    sblack:removeFromParent()
    sblack:release()
    sblack = nil
  end
end

function ShowWaiting.show()
  ShowWaiting.delete()

  local app = require("app.App"):instance()
  local black = AddBlackLayer.add()
  local blackSize = black:getContentSize()
  app.layers.top:addChild(black,99)

  local spr = cc.Sprite:create('wait.png')
  black:addChild(spr)
  spr:setPosition(cc.p(blackSize.width / 2,blackSize.height / 2))

  local r = cc.RotateBy:create(0.2,20)
  local action = cc.RepeatForever:create(r)
  spr:runAction(action)

  sblack = black
  sblack:retain()
end

return ShowWaiting
