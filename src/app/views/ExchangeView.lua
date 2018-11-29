local tools = require('app.helpers.tools')
local Scheduler = require('app.helpers.Scheduler')

local ExchangeView = {}
function ExchangeView:initialize()
end

function ExchangeView:onExit()
end

function ExchangeView:layout()
  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))

  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setPosition(display.cx,display.cy)
end

return ExchangeView
