local UnlockSoldier = {}
local winSize = cc.Director:getInstance():getWinSize()
local CreateBoneNode = require('app.helpers.CreateBoneNode')

function UnlockSoldier.show(data)
  if not data then return end

  local index = data.index
  if index > 9 then index = index - 9 end

  local path = string.format('views/barracks/soldier_%02d.png',index)
  local spr = cc.Sprite:create(path)
  local app = require("app.App"):instance()
  local bg = cc.LayerColor:create(cc.c4b(0,0,0,255 * 0.7),winSize.width,winSize.height)
  app.layers.top:addChild(bg)

  local bottom = CreateBoneNode.createWithExport('animations/hdbg/hdbg.ExportJson','hdbg')
  app.layers.top:addChild(bottom)
  bottom:getAnimation():play("idle")
  bottom:setPosition(winSize.width / 2,winSize.height / 2 - 100)

  app.layers.top:addChild(spr)
  spr:setPosition(winSize.width / 2,winSize.height / 2)

  local delay = cc.DelayTime:create(2.0)
  local call = cc.CallFunc:create(function()
    spr:removeFromParent()
    bottom:removeFromParent()
    bg:removeFromParent()
  end)
  spr:runAction(cc.Sequence:create(delay,call))
end

return UnlockSoldier
