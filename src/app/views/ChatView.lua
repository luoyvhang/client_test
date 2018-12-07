local tools = require('app.helpers.tools')
local ChatView = {}

function ChatView:initialize()
end

local chatsTbl = {
  '大家好，很高兴见到各位！',
  '快点呀，等到花儿都谢了！',
  '我是庄家，谁敢挑战我',
  '风水轮流转，底裤都输光了',
  '大牛吃小牛，不要伤心哦',
  '一点小钱，那都不是事',
  '大家一起浪起来',
  '底牌亮出来，绝对吓死你',
  '你真是个天生的演员',
  '不要走，决战到天亮'
}

local emojiTbl = {
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25'
}

function ChatView.getChatsTbl()
  return chatsTbl
end

function ChatView:getEmojiTbl()
  return emojiTbl
end

function ChatView:layout()
  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))
  self.ui:setPosition(display.cx,display.cy)
  self.MainPanel = black

  local content = self.ui:getChildByName('content')

  self.list = content:getChildByName('list')
  self.list:setItemModel(self.list:getItem(0))
  self.list:removeAllItems()

  self:loadChats()

  self:loadSelBnts()
  self:loadEmoji()

  local editbox = content:getChildByName('chat')
  local edit = tools.createEditBox(editbox,{
    fontColor = cc.c3b(244,238,229)
  },'views/send/4.png',cc.rect(11,11,388 - 11*2,101 - 11*2))

  self.edit = edit
end

function ChatView:getSendText()
  return self.edit:getText()
end

function ChatView:loadChats()
  for i = 1,#chatsTbl do
    self.list:pushBackDefaultItem()
    local item = self.list:getItem(i-1)
    item:getChildByName('text'):setString(chatsTbl[i])
    item:addClickEventListener(function()
      self.emitter:emit('choosed', i)
    end)
  end
end

local keys = {
  'selChat','selEmoji'
}

function ChatView:loadSelBnts()
  local content = self.ui:getChildByName('content')

  --local pathYellow = 'res/views/shop/sc17'
  --local pathOrange = 'res/views/shop/sc4'
  local emojiList = content:getChildByName('emojiList')
  emojiList:setItemModel(emojiList:getItem(0))
  emojiList:removeAllItems()
  self.emojiList = emojiList

  --local selChat = content:getChildByName('selChat')
  --local selEmoji = content:getChildByName('selEmoji')
  --local zOrder = selChat:getLocalZOrder() + 5
  for i = 1,#keys do
    local key = keys[i]
    local tab = content:getChildByName(key)

    tab:addClickEventListener(function()
      self.focus = key
      self:freshFocus()
    end)
  end

  self.focus = 'selChat'
  self:freshFocus()

  --selChat:addClickEventListener(function()
    --selChat:loadTexture(pathOrange)
    --selEmoji:loadTexture(pathYellow)
    --selChat:setLocalZOrder(zOrder)
    --selEmoji:setLocalZOrder(zOrder - 1)
    --emojiList:setVisible(false)
    --self.list:setVisible(true)
  --end)

  --selEmoji:addClickEventListener(function()
  --  selChat:loadTexture(pathYellow)
  --  selEmoji:loadTexture(pathOrange)
  --  selEmoji:setLocalZOrder(zOrder)
  --  selChat:setLocalZOrder(zOrder - 1)
  --  emojiList:setVisible(true)
  --  self.list:setVisible(false)
  --end)
end

function ChatView:freshFocus()
  local content = self.ui:getChildByName('content')

  for i = 1,#keys do
    local key = keys[i]
    local tab = content:getChildByName(key)
    local active = tab:getChildByName('active')

    if key == self.focus then
      active:show()
    else
      active:hide()
    end
  end

  if self.focus ~= 'selChat' then
    self.emojiList:show()
    self.list:hide()
  else
    self.emojiList:hide()
    self.list:show()
  end
end

function ChatView:loadEmoji()
  local content = self.ui:getChildByName('content')
  local emojiList = content:getChildByName('emojiList')
  emojiList:removeAllItems()

  local line = #emojiTbl / 3
  if line == 0 then
    line = 1
  end

  for i = 1, line do
    emojiList:pushBackDefaultItem()
    local item = emojiList:getItem(i - 1)
    self:setBtnClickEvent(item, i - 1, 3)
  end
end

function ChatView:setBtnClickEvent(item, line, col)
  for i = 1, col do
    local btn = item:getChildByName('btn_'..i)
    local id = 3 * line + i
    local path = "views/chat/"..id..".png"
    btn:loadTextures(path, "")
    btn:setVisible(true)

    btn:addClickEventListener(function()
      self.emitter:emit('back')
      local app = require("app.App"):instance()
      local tmsg = {
        msgID = 'chatInGame',
        type = 1,
        msg = id
      }
      app.conn:send(tmsg)
    end)
  end
end

return ChatView
