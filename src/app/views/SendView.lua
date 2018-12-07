local tools = require('app.helpers.tools')
local SendView = {}

function SendView:initialize()
end

function SendView:layout()
  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))

  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setScale(0.1)

  local sc = cc.ScaleTo:create(0.1,1.0)
  self.MainPanel:runAction(sc)

  self.MainPanel:setPosition(display.cx,display.cy)

  local keys = {
    'top',
    'bottom'
  }

  self.editboxs = {}
  for i = 1,#keys do
    local panel = self.MainPanel:getChildByName(keys[i])
    local editbox = panel:getChildByName('editbox')

    local edit = tools.createEditBox(editbox,{
      inputMode = cc.EDITBOX_INPUT_MODE_DECIMAL,
      fontColor = cc.c3b(244,238,229)
    },'views/send/4.png',cc.rect(11,11,388 - 11*2,101 - 11*2))

    self.editboxs[#self.editboxs+1] = edit
  end
end

function SendView:clickBlack()
  if device.platform == 'ios' then
    for i = 1,#self.editboxs do
      self.editboxs[i]:closeKeyboard()
    end
  end
end

function SendView:getIdAndDiamond()
  local id = tonumber(self.editboxs[1]:getText())
  local diamond = tonumber(self.editboxs[2]:getText())

  return id,diamond
end

return SendView
