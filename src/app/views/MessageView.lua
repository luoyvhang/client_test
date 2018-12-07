local MessageView = {}
function MessageView:initialize()
end
-- local text = "        快乐牛牛启航版正式上线！热烈庆祝快乐牛牛启航版正式上线运营。快乐牛牛启航版游戏团队倾力打造又一斗牛精品，原汁原味地道斗牛经验。各种特色玩法，够麻辣够吃惊！新品上线，诚邀各路伙伴合作共赢，有兴趣的朋友可以联系我们。\n       官方代理咨询及技术问题反馈官方微信号:18819207102 "
local text1 = "亲爱的玩家：\n\n".."抵制不良游戏，拒绝盗版游戏，\n".."注意自我保护，谨防上当受骗。\n".."适度游戏益脑，沉迷游戏伤身，\n".."合理安排时间，享受健康生活。"
local text2 = "亲爱的玩家：\n".."近期收到一些玩家反馈，有些别有用心的谋利者，向外散发快乐牛牛启航版有外挂、作弊器的谣言，想要利用玩家想要获得游戏胜利的心里进行金钱上的诈骗，并可能向亲们传播木马病毒，窃取玩家个人信息，请亲们提高警惕，谨防上当受骗。\n\n".."快乐牛牛启航版游戏郑重声明：如果亲们发现任何实际效果的外挂、作弊器等工具，请联系我们，一经核实，快乐牛牛启航版游戏官方给予现金一百万重奖，决不食言。\n".."祝您游戏愉快。\n\n".."                                                                          快乐牛牛启航版官方运营"
local text3 = "暂无"
local text4 = "亲爱的玩家：\n\n".."新版快乐牛牛启航版已上线，欢迎各位体验"
local text = {
  ['text1'] = text1,
  ['text2'] = text2,
  ['text3'] = text3,
  ['text4'] = text4,
}

-- 亲爱的玩家：
--         近期收到一些玩家反馈，有些别有用心的谋利者，向外散发快乐牛牛启航版有外挂、作弊器的谣言，想要利用玩家想要获得游戏胜利的心里进行金钱上的诈骗，并可能向亲们传播木马病毒，窃取玩家个人信息，请亲们提高警惕，谨防上当受骗。
--         快乐牛牛启航版游戏郑重声明：如果亲们发现任何实际效果的外挂、作弊器等工具，请联系我们，一经核实，快乐牛牛启航版游戏官方给予现金重奖，决不食言。

-- "祝您游戏愉快。"


--亲爱的玩家：
-- 抵制不良游戏，拒绝盗版游戏，注意自我保护，谨防上当受骗。
-- 适度游戏益脑，沉迷游戏伤身，合理安排时间，享受健康生活。

-- 本网络游戏适合年满18岁以上用户使用，请大家文明娱乐，远离赌博。
                                                        


function MessageView:layout()
  self.ui:setPosition(display.cx,display.cy)
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  self.MainPanel = MainPanel
  self.Content = self.MainPanel:getChildByName("Content")
  self.text = self.Content:getChildByName("content")
  self.msg = self.Content:getChildByName("msg")
  self.focus = '1'
  self:freshtab('1')


  self:startAllAnimation()
end

function MessageView:getNotify(msg)
  -- self.ui:getChildByName("Content"):getChildByName("title"):setString(msg.title)
  -- self.ui:getChildByName("Content"):getChildByName("content"):setString(msg.content)
end

local tabs = {
  ['btn1'] = '1',
  ['btn2'] = '2',
  ['btn3'] = '3',
  ['btn4'] = '4',
}
function MessageView:freshtab(data)
  for i, v in pairs(tabs) do 
    local currentItem = self.Content:getChildByName(i)
    local current 
    if data then 
        self.focus = data
    end
    if self.focus == v then
      currentItem:getChildByName('active'):setVisible(true)
      -- current = 'text' .. v
      -- self.text:setFontSize(28)
      -- if v == '1' then
      --   self.text:setFontSize(50)
      -- end
      -- self.text:setString(text[current])
      self.msg:getChildByName('image1'):setVisible(false)
      self.msg:getChildByName('image2'):setVisible(false)
      self.msg:getChildByName('image3'):setVisible(false)
      self.msg:getChildByName('image4'):setVisible(false)
      self.msg:getChildByName('image' .. v):setVisible(true)
    else
      currentItem:getChildByName('active'):setVisible(false)
    end
  end
end

--执行全部动画
function MessageView:startAllAnimation()
  for i, v in pairs(tabs) do
    self:startCsdAnimation(self.Content:getChildByName(i):getChildByName("active"):getChildByName("blinkingBoxNode"),"blinkingBoxAnimation",true)
  end
end

function MessageView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
  local action = cc.CSLoader:createTimeline("views/createroom/"..csbName..".csb")
  action:gotoFrameAndPlay(0,isRepeat)
  if timeSpeed then
    action:setTimeSpeed(timeSpeed)
  end
  node:stopAllActions()
  node:runAction(action)
end

return MessageView
