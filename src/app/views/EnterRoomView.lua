local SoundMng = require "app.helpers.SoundMng"
local EnterRoomView = {}
function EnterRoomView:initialize()
end

function EnterRoomView:layout()
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(3 * display.width,display.height))
  self.ui:setPosition(display.cx,display.cy)

  self.roomNo = ''

  local bg = self.ui:getChildByName('bg')
  self.bg = bg

  for i = 0,9 do
    local btn = bg:getChildByName('bt'..i)
    btn:addClickEventListener(function()
      self:clickNumber(i)
    end)
  end

  --启动csd动画
  self:startCsdAnimation(bg:getChildByName("nnBodyNode"),"nnBodyAnimation",true,0.6)
end

function EnterRoomView:clickNumber(i)
  if #self.roomNo == 6 then return end
  SoundMng.playEft('btn_click.mp3')
  self.roomNo = self.roomNo..tostring(i)
  self:freshNumber()

  if #self.roomNo == 6 then
    self.emitter:emit('clickEnterGame')
  end
end

function EnterRoomView:clear()
  self.roomNo = ''
  self:freshNumber()
end

function EnterRoomView:clickDelete()
  self.roomNo = string.sub(self.roomNo,1,#self.roomNo-1)
  self:freshNumber()
end

function EnterRoomView:clickReenter()
  self:clear()
end

function EnterRoomView:clickJoin()
  if #self.roomNo == 6 then
    self.emitter:emit('clickEnterGame')
  end
end

function EnterRoomView:freshNumber()
  local bg = self.ui:getChildByName('bg')
  local numberFrame = bg:getChildByName('numberFrame')
  local list = numberFrame:getChildByName('list')

  for n = 1,6 do
    --list:getChildByName('n'..n):getChildByName('number'):setString('')
    list:getChildByName('n'..n):getChildByName('atlasNumber'):setString('')
  end

  local cnt = #self.roomNo
  for i = 1,cnt do
    local numUi = list:getChildByName('n'..i)
    --local idx = cnt - i + 1
    local n = string.sub(self.roomNo,i,i)
    --numUi:getChildByName('number'):setString(n)
    numUi:getChildByName('atlasNumber'):setString(n)
  end
end

function EnterRoomView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
  local action = cc.CSLoader:createTimeline("views/enterroom/"..csbName..".csb")
  action:gotoFrameAndPlay(0,isRepeat)
  if timeSpeed then
    action:setTimeSpeed(timeSpeed)
  end
  node:stopAllActions()
  node:runAction(action)
end

function EnterRoomView:stopCsdAnimation( )
  self.bg:getChildByName("nnBodyNode"):stopAllActions()
end

return EnterRoomView
