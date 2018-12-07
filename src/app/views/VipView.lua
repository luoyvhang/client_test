local VipView = {}

function VipView:initialize()
end

function VipView:layout(targetPos)
  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))

  targetPos.x = targetPos.x - 40
  targetPos.y = targetPos.y - 40

  self.MainPanel = self.ui:getChildByName('MainPanel')
  local size = self.MainPanel:getContentSize()

  self.MainPanel:setPositionY(targetPos.y)
  self.MainPanel:setPositionX(targetPos.x - size.width)

  local mv = cc.MoveTo:create(0.1,targetPos)
  self.MainPanel:runAction(mv)

  local bar = self.MainPanel:getChildByName('bar')
  local progress = bar:getChildByName('progress')

  local app = require("app.App"):instance()
  local user = app.session.user

  local vip_map = user.getVipMap()
  local segment = #vip_map - 1
  local block = 100 / segment

  local vipIdx,mod,distance = user:calcVIP()
  local percent = (vipIdx-1) * block
  progress:setPercent(percent + block * mod)

  local hint = self.MainPanel:getChildByName('hint')
  hint:setString('离下一等级还差：'..distance)

  for i = 0,(vipIdx-1) do
    local img = bar:getChildByName('v'..i)
    img:loadTexture('views/vip/4.png')
  end
end

return VipView
