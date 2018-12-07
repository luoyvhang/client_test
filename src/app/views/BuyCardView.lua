local tools = require('app.helpers.tools')

local BuyCardView = {}
function BuyCardView:initialize()
  local app = require("app.App"):instance()
  self.cards = 0
  self.max = app.session.user.diamond
end

function BuyCardView:layout()
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel = MainPanel

  local ContentPanel = MainPanel:getChildByName('ContentPanel')
  self.middle = ContentPanel:getChildByName('middle')
  local sendPanel = self.middle:getChildByName('sendPanel')
  local editbg = sendPanel:getChildByName('editbg')
  local editbox = editbg:getChildByName('editbox')
  self.editbox = tools.createEditBox(editbox,{
    inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC
  })

  self.cardnumber = sendPanel:getChildByName('frame'):getChildByName('number')
end

function BuyCardView:getTargetPlayerId()
  return self.editbox:getText()
end

function BuyCardView:getSendCardCnt()
  return self.cards
end

function BuyCardView:clickSub()
  self.cards = self.cards - 1
  if self.cards < 0 then self.cards = 0 end

  self:freshCards()
end

function BuyCardView:clickAdd()
  self.cards = self.cards + 1
  if self.cards > self.max then self.cards = self.max end

  self:freshCards()
end

--196609
function BuyCardView:freshCards()
  self.cardnumber:setString(self.cards)
end

return BuyCardView
