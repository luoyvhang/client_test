local CreateTip = {}
local winSize = cc.Director:getInstance():getWinSize()

function CreateTip.create(content)
  local text = cc.Label:createWithTTF(content,'views/font/FZXIANGLJW.ttf',32)
  local textSize = text:getContentSize()
  text:setColor(cc.c3b(0,0,0))

  local layer = cc.Layer:create()
  local layerSize = cc.size(textSize.width * 1.2,textSize.height * 1.2)
  layer:setContentSize(layerSize)
  layer:ignoreAnchorPointForPosition(false)
  layer:setAnchorPoint(cc.p(0.5,0))
  layer:addChild(text,1)
  text:setPosition(cc.p(layerSize.width / 2,layerSize.height / 2))

  local bgSpr = ccui.Scale9Sprite:create(cc.rect(15,15,20,20),'views/public/bg/yellowframe.png')
  layer:addChild(bgSpr)
  bgSpr:setPosition(cc.p(layerSize.width / 2,layerSize.height / 2))
  bgSpr:setContentSize(layerSize)

  local jian = cc.Sprite:create('views/public/bg/jian.png')
  layer:addChild(jian)
  jian:setAnchorPoint(cc.p(0.5,1))
  jian:setPosition(cc.p(layerSize.width / 2,5))
  jian:setFlippedY(true)

  layer:setScale(0.1)
  local delay = 0.1

  local mv = cc.MoveBy:create(delay,cc.p(0,50))
  layer:runAction(mv)
  local sc = cc.ScaleTo:create(delay,1.0)
  layer:runAction(sc)

  return layer
end

function CreateTip.destroy(tip)
  local sc = cc.ScaleTo:create(0.1,0.01)
  local des = cc.RemoveSelf:create()
  tip:runAction(cc.Sequence:create(sc,des))
end

return CreateTip
