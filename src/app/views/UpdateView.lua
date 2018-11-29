local UpdateView = {}
local display = require('cocos.framework.display')

function UpdateView:initialize()
  local root = self.ui:getChildByName('root')
  self.progress = root:getChildByName('progress')
  self.message = root:getChildByName('message')
  root:setContentSize(cc.size(display.width,display.height))
  root:setPosition(display.cx,display.cy)
end

function UpdateView:showMessage(message)
  self.message:show()
  self.message:setString(message)
end

function UpdateView:hideMessage()
  self.message:hide()
end

function UpdateView:showProgress(progress)
  self.progress:show()
  -- self.progress:setPercent(progress < 0.5 and 0.5 or progress)
  self.mask = self.progress:getChildByName('mask')
  self.mask:setContentSize(1000 - progress * 10, 38)
  self.message:setString(math.floor(progress)..' %')
end

return UpdateView
