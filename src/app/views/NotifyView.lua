local NotifyView = {}
local Scheduler = require('app.helpers.Scheduler')



function NotifyView:initialize()
  self.worldnotify = self.ui:getChildByName('worldnotify')
  self.worldnotifySize = self.worldnotify:getContentSize()

  self.notifys = {}
  self.tst_delay = 0
  self.annocement = nil

  self.updatef = Scheduler.new(function(dt)
    self.tst_delay = self.tst_delay + dt
    if self.tst_delay > 20 then
      self.tst_delay = 0
      self:pushNotic()
    end

    self.worldnotify:setVisible(#self.notifys ~= 0)

    for i = #self.notifys,1,-1 do
      local label = self.notifys[i]

      local x = label:getPositionX()
      local size = label:getContentSize()
      if x + size.width <= 0 then
        label:removeFromParent()
        table.remove(self.notifys,i)

        if #self.notifys == 0 then
          self.emitter:emit('hide')
        end
      else
        x = x - dt * 100
        label:setPositionX(x)
      end
    end
  end)
  self:pushNotic()
end

function NotifyView:pushNotic()
      self:pushNotify(
      {
        -- {
        --   text = '欢迎来到 ',
        --   color = {255,255,100}
        -- },
        -- {
        --   text = ' 牛将军 ',
        --   color = {208,47,23}
        -- },
        {
          text = self.annocement or '快乐牛牛启航版新版隆重上线，如果您游戏过程中遇到任何问题，请联系我们客服处理！',--客服微信号： ',
          color = {255,255,255}
        },
        {
          text = '',
          color = {255,0,0}
        },

      })
end


function NotifyView:notify(msg)
  self.annocement = msg.content or '快乐牛牛启航版新版隆重上线，如果您游戏过程中遇到任何问题，请联系我们客服处理！'
  self:pushNotify(
  {
    {
      text = msg.content,
      color = {255,255,255}
    }
  })
end

function NotifyView:pushNotify(tst_data)
  local empty = #self.notifys == 0
  local richText = ccui.RichText:create()
  richText:setAnchorPoint(cc.p(0,0.5))

  for i = 1,#tst_data do
    local data = tst_data[i]
    local re1 = ccui.RichElementText:create( 1,cc.c3b(data.color[1],data.color[2],data.color[3]),255,data.text,'views/font/fangzheng.ttf', 25 )
    richText:pushBackElement(re1)
  end

  local label = richText
  self.worldnotify:addChild(label)
  label:setPositionY(self.worldnotifySize.height / 2)

  if empty then
    label:setPositionX(self.worldnotifySize.width)
  else
    local lst = self.notifys[#self.notifys]
    local lstSize = lst:getContentSize()
    local tmp_x = lst:getPositionX() + lstSize.width + 400
    if tmp_x < self.worldnotifySize.width then
      tmp_x = self.worldnotifySize.width
    end
    label:setPositionX(tmp_x)
  end

  self.notifys[#self.notifys + 1] = label
end

function NotifyView:onNotify(msg)
  self:pushNotify(msg.data)
end

function NotifyView:onExit()
  Scheduler.delete(self.updatef)
end


return NotifyView
