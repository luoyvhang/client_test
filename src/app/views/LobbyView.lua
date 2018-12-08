local HeartbeatCheck = require('app.helpers.HeartbeatCheck')
local cache = require('app.helpers.cache')
local GameLogic = require('app.libs.niuniu.NNGameLogic')
local Scheduler = require('app.helpers.Scheduler')

local app = require("app.App"):instance()
local tools = require('app.helpers.tools')

local LobbyView = {}
function LobbyView:initialize(ctrl)
  self.ctrl = ctrl

  self.heartbeatCheck = HeartbeatCheck()
	
	self.updateF = Scheduler.new(function(dt)
		self:update(dt)
	end)
	
	self:enableNodeEvents()

 
	--安卓返回键监听
	local eventDispatcher = self:getEventDispatcher()
	local listenerKey = cc.EventListenerKeyboard:create()
	
  local function onKeyReleaseed(keycode, event)
		if keycode == cc.KeyCode.KEY_BACK and self.ctrl:getChildCtrlConut()==1 then
			tools.showMsgBox("提示", "是否退出游戏?", 2):next(function(btn)
				if btn == 'enter' then
					cc.Director:getInstance():endToLua()
					-- 关闭定时器
					-- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
				end
			end)
		end
	end
	
	listenerKey:registerScriptHandler(onKeyReleaseed, cc.Handler.EVENT_KEYBOARD_RELEASED)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerKey, self)
end 

function LobbyView:layout()

  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel = MainPanel

  local bg = MainPanel:getChildByName('bg')
  bg:setContentSize(cc.size(display.width,display.height))
  bg:setPosition(display.cx,display.cy)

  local TopBar = MainPanel:getChildByName('TopBar')
  TopBar:setPositionY(display.height)
  self.TopBar = TopBar

  local topSize = TopBar:getContentSize()
  topSize.height = topSize.height + 50

  local BottomBar = self.MainPanel:getChildByName('BottomBar')
  local bottomSize = BottomBar:getContentSize()
  local middleHeight = display.height - bottomSize.height - topSize.height
  local headNode = TopBar:getChildByName('head')
  self.TopBar.headNode = headNode

  --if device.platform == 'ios' then
  --  BottomBar:getChildByName('exit'):hide()
  --end

  local head = headNode:getChildByName('icon')
  head:retain()
  cache.get(app.session.user.avatar,function(ok,path)
    if ok then
      head:loadTexture(path)
    end
    head:release()
  end)
  self.head = head

  self:loadData()

  self.roomList = TopBar:getChildByName('roomList')
  local list = self.roomList:getChildByName('list')
  list:setItemModel(list:getItem(0))
  list:removeAllItems()
  --list:setItemsMargin(5)
  list:setScrollBarEnabled(false)

  --执行动画
  self:startAllAnimation()

  -- 刷新时间
  local scheduler_ = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler_:scheduleScriptFunc(function()
		self:freshTime()
	end,1, false)
end

function LobbyView:clickDownload()
  -- local spr = cc.Sprite:create('views/lobby/mmexport1488249280343.jpg')
  -- self:addChild(spr)
  -- spr:setPosition(display.cx,display.cy)
  -- local sprSize = spr:getContentSize()

  -- local label = cc.Label:createWithTTF('扫码下载','views/font/fangzheng.ttf',35, cc.size(620,0),cc.TEXT_ALIGNMENT_CENTER)
  -- spr:addChild(label)
  -- label:setPosition(sprSize.width/2,-40)

  -- self.black:addClickEventListener(function()
  --   spr:removeFromParent()
  --   self.black:hide()
  -- end)
end

function LobbyView:getHeadWorldPos()
  local pos = cc.p(self.head:getPosition())
  local world = self.head:getParent():convertToWorldSpace(pos)

  return world
end

function LobbyView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
  local action = cc.CSLoader:createTimeline("views/lobby/"..csbName..".csb")
  action:gotoFrameAndPlay(0,isRepeat)
  if timeSpeed then
    action:setTimeSpeed(timeSpeed)
  end
  node:stopAllActions()
  node:runAction(action)
end

--执行全部动画
function LobbyView:startAllAnimation()
  self:showShopAction()
  self:showLogoAction()
  self:showDiamondAction()
  self:showActivityAction()
  self:showSignInAction()
  self:showExpressionAction()
  self:showNNbodyAction()
  self:startRoomAnimation()
end
--停止全部动画
function LobbyView:stopAllAnimation()
  self.TopBar:getChildByName("logo"):getChildByName("logoNode"):stopAllActions()
  self.TopBar:getChildByName("head"):getChildByName("frame"):getChildByName("diamondNode"):stopAllActions()
  self.MainPanel:getChildByName("activity"):getChildByName("activityNode"):stopAllActions()
  self.MainPanel:getChildByName("signIn"):getChildByName("signInNode"):stopAllActions()
  self.MainPanel:getChildByName("expression"):getChildByName("expressionNode"):stopAllActions()
  self.MainPanel:getChildByName("shop"):getChildByName("shopNode"):stopAllActions()
  self.MainPanel:getChildByName("nnBodyNode"):stopAllActions()
  self:stopRoomAnimation()
end

--停止room动画并隐藏
function LobbyView:stopRoomAnimation()
  self.MainPanel:getChildByName("entryNN"):getChildByName("createRoomNode"):stopAllActions()
  self.MainPanel:getChildByName("entryNN"):getChildByName("createRoomNode"):hide()
  self.MainPanel:getChildByName("entryMJ"):getChildByName("joinRoomNode"):stopAllActions()
  self.MainPanel:getChildByName("entryMJ"):getChildByName("joinRoomNode"):hide()
  self.MainPanel:getChildByName("entryNY"):getChildByName("clubRoomNode"):stopAllActions()
  self.MainPanel:getChildByName("entryNY"):getChildByName("clubRoomNode"):hide()
end


--执行room动画
function LobbyView:startRoomAnimation()
  self:startCsdAnimation(self.MainPanel:getChildByName("entryNN"):getChildByName("createRoomNode"),"createRoomAnimation",true,0.5)
  self:startCsdAnimation(self.MainPanel:getChildByName("entryMJ"):getChildByName("joinRoomNode"),"joinRoomAnimation",true,0.5)
  self:startCsdAnimation(self.MainPanel:getChildByName("entryNY"):getChildByName("clubRoomNode"),"clubRoomAnimation",true,0.5)
end

function LobbyView:showDiamondAction()
  self:startCsdAnimation(self.TopBar:getChildByName("head"):getChildByName("frame"):getChildByName("diamondNode"),"diamondAnimation",true,1.3)

end

function LobbyView:showShopAction()
  self:startCsdAnimation(self.MainPanel:getChildByName("shop"):getChildByName("shopNode"),"shopAnimation",true,1.3)
end

function LobbyView:showActivityAction()
  self:startCsdAnimation(self.MainPanel:getChildByName("activity"):getChildByName("activityNode"),"signInAnimation",true,1)
end

function LobbyView:showSignInAction()
  self:startCsdAnimation(self.MainPanel:getChildByName("signIn"):getChildByName("signInNode"),"signInAnimation",true,1)
end

function LobbyView:showExpressionAction()
  self:startCsdAnimation(self.MainPanel:getChildByName("expression"):getChildByName("expressionNode"),"signInAnimation",true,1)
end

function LobbyView:showLogoAction()
  self:startCsdAnimation(self.TopBar:getChildByName("logo"):getChildByName("logoNode"),"logoAnimation",true,0.8)
end

function LobbyView:showNNbodyAction()
  self:startCsdAnimation(self.MainPanel:getChildByName("nnBodyNode"),"nnBodyAnimation",true,1/3)
end

function LobbyView:loadData()
  self:freshInfo()
end

function LobbyView:freshInfo()
  local app = require("app.App"):instance()
  local user = app.session.user
  self.TopBar.headNode:getChildByName('nickname'):setString(user.nickName)
  self.TopBar.headNode:getChildByName('id'):getChildByName('value'):setString(user.playerId)
  self.TopBar.headNode:getChildByName('frame'):getChildByName('number'):setString(user.diamond)
  local femal = self.TopBar.headNode:getChildByName('femal')
  local male = self.TopBar.headNode:getChildByName('male')
  femal:setVisible(false)
  male:setVisible(false)
  if user.sex == 1 then
    femal:setVisible(true)
  else
    male:setVisible(true)
  end
end

function LobbyView:onExit()
  if self.updateF then
    Scheduler.delete(self.updateF)
    self.updateF = nil
  end
  if self.schedulerID then
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
  end
end

function LobbyView:update(dt)
  self:sendHeartbeatMsg(dt)
end

function LobbyView:onPing()
  self.heartbeatCheck:onPing()
end

function LobbyView:sendHeartbeatMsg(dt)
  self.heartbeatCheck:update(dt)
end

function LobbyView:freshRoomListBtn(btnName)
  local roomList = self.MainPanel:getChildByName('TopBar'):getChildByName('roomList')
  local kf = roomList:getChildByName('Image_kuang')
  local kg = roomList:getChildByName('Image_kuang_0')
  kf:setVisible(false)
  kg:setVisible(false)
  if btnName == 'friend' then
    kf:setVisible(true)
  else
    kg:setVisible(true)
  end 

end

function LobbyView:loadRooms(rooms)
  local roomList = self.roomList
  local list = roomList:getChildByName('list')
  local Image_noRoom = self.roomList:getChildByName('Image_noRoom')
  local Text_noRoom = self.roomList:getChildByName('Text_noRoom')

    
  if not (rooms and rooms.rooms and #rooms.rooms>0) then
    list:setVisible(false)
    Image_noRoom:setVisible(true)
    Text_noRoom:setVisible(true)
    list:removeAllItems()
    return
  end

  list:setVisible(true)
  Image_noRoom:setVisible(false)
  Text_noRoom:setVisible(false)
  -- list:setItemModel(list:getItem(0))
  list:removeAllItems()

  local data = rooms.rooms
  local arr = GameLogic.SPECIAL_GAMEPLAY


  for i, v in ipairs(data) do
    list:pushBackDefaultItem()
    local item = list:getItem(i - 1)
    local roomId = item:getChildByName('roomId')
    roomId:setString(v.deskId)

    local deskInfo = v.options

    -- 玩法
    local gameplayStr = GameLogic.getGameplayText(deskInfo)
    -- 底分
    local baseStr = GameLogic.getBaseText(deskInfo)
    -- 支付
    local payStr = GameLogic.getPayModeText(deskInfo)

    local gameplay = item:getChildByName('game')
    gameplay:setString(gameplayStr)

    local base = item:getChildByName('base')
    base:setString(baseStr)

    local round = item:getChildByName('round')
    round:setString(v.options.round)

    local pay = item:getChildByName('pay')
    pay:setString(payStr)

    local maxPeople = item:getChildByName('maxPeople')
    maxPeople:setString(v.actors)

    local inviteBtn=item:getChildByName('invite')
    inviteBtn:addClickEventListener(function()
        self.emitter:emit('inviteBtn',v) --邀请
    end)

    item:addClickEventListener(function()
      local rId = v.deskId
      app.session.room:enterRoom(rId, false)
    end)
  end
end

function LobbyView:freshTime()
  local time = self.MainPanel:getChildByName('time')
  local nowtime = os.date('*t',os.time())
  time:setString('' .. nowtime.month .. '.' .. nowtime.day .. '  '  .. nowtime.hour .. ':' .. nowtime.min .. ':' .. nowtime.sec)
  time:setVisible(true)
end

function LobbyView:displayMenu(bool)
    local BottomBar = self.MainPanel:getChildByName('BottomBar')
    local menu=BottomBar:getChildByName('menuBG')
    menu:setVisible(bool)
  
end

function LobbyView:getMainPanel()
  return self.MainPanel

end

return LobbyView
