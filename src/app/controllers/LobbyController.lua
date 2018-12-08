local class = require('middleclass')
local Controller = require('mvc.Controller')
local LobbyController = class("LobbyController", Controller)
local TranslateView = require('app.helpers.TranslateView')
local SoundMng = require "app.helpers.SoundMng"
local tools = require('app.helpers.tools')
local GameLogic = require('app.libs.niuniu.NNGameLogic')
local EventCenter = require("EventCenter")
local cjson = require('cjson')
local app = require("app.App"):instance()

local function setWidgetAction(controller, self, args, ...)
    SoundMng.playEft('btn_click.mp3')
    local ctrl 
    if not args then
        ctrl = Controller:load(controller, ...)
    else
        ctrl = Controller:load(controller, args)
    end
    self:add(ctrl)

    local app = require("app.App"):instance()
    app.layers.ui:addChild(ctrl.view)
    -- ctrl.view:setPositionX(display.width)

    --TranslateView.moveCtrl(ctrl.view, -1)
    -- TranslateView.fadeIn(ctrl.view, -1)
    ctrl:on('back', function()
        -- TranslateView.fadeOut(ctrl.view, 1, function()
            ctrl:delete()
        -- end)
    end)
end


function LobbyController:initialize()
	Controller.initialize(self)
	local bgmFlag = SoundMng.getEftFlag(SoundMng.type[1])
    local EftFlag = SoundMng.getEftFlag(SoundMng.type[2])
    local bgmVol, sfxVol = SoundMng.getVol()
    SoundMng.setBgmVol(bgmVol)
    SoundMng.setSfxVol(sfxVol)
	SoundMng.setBgmFlag(bgmFlag)
    SoundMng.setEftFlag(EftFlag)
    SoundMng.setPlaying(false)
    if bgmFlag == nil then
       bgmFlag = true
    end
    if EftFlag == nil then
        EftFlag = true
    end

	SoundMng.playBgm('hall_bg1.mp3')
	
	app.session.user:queryListRooms()
	
	self.menuVisible = false

	-- 每隔两秒定时发送请求更新房间列表
	local scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler:scheduleScriptFunc(function()
		app.session.user:queryListRooms()
	end, 10, false)
end 

function LobbyController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
    -- 暂停Scheme获取URL
    app.session.scheme:pause()
    -- 注销 切换事件监听
    --EventCenter.clear("app")
end

function LobbyController:viewDidLoad()
    self.view:layout()
    local user = app.session.user
    local scheme = app.session.scheme

    -- EventCenter.register("app", function(event)
    --     if event then 
    --         -- didEnterBackground   
    --         -- willEnterForeground
    --        if event == 'didEnterBackground' then
    --             SoundMng.isPauseVol(true)
    --        elseif event == 'willEnterForeground'then
    --             SoundMng.isPauseVol(false)
    --        end
    --     end
    -- end)
    self.listener = {

    app.session.appEvent:on('didEnterBackground', function(msg)
        SoundMng.isPauseVol(true)
    end),
    app.session.appEvent:on('willEnterForeground', function(msg)
        SoundMng.isPauseVol(false)
    end),

    app.session.room:on('needEnterRoom',function()
        app:switch('GamesCityDeskController')
    end),
    
    app.conn:on('ping',function()
        self.view:onPing()
    end),
    user:on('freshInfo',function()
        self.view:freshInfo()
    end),
    user:on('updateRes',function()
        self.view:freshInfo()
    end),
    user:on('notify',function(msg)
        self.notifyController:notify(msg)
    end),

    user:on('listRooms',function(rooms)
      self.view:loadRooms(rooms)
    end),

    scheme:on('schemeRoomId',function(roomId)
        self:onSchemeRoomId(roomId)
    end),
    
    scheme:on('schemeGroupId',function(groupId)
        self:onSchemeGroupId(groupId)
    end),

    }

    
    self.view:on('inviteBtn',function(data)
        self:inviteFriend(data)
    end)

    self:loadNotifyController()
    app.session.room:doSync()
    app.session.scheme:resume()

    -- 默认房间列表在可见界面外
    self.ROOM_LIST_FLAG = true

    -- nextSwitchParam
    local switchParam = app:getNextSwitchParam("LobbyController")
    if switchParam then
        if switchParam.subCtrl == "GroupController" then
            setWidgetAction('GroupController', self, nil, switchParam)
            self:hideMenu()
        end
        app:delNextSwitchParam("LobbyController")
    end
end



function LobbyController:getSelf()
     return self
end

function LobbyController:clickMenuVisible()
     self:hideMenu()
     if not self.ROOM_LIST_FLAG then
        self:runRoomListAction()
     end
end
function LobbyController:clickWelfare()
    setWidgetAction('WelfareController', self)
    self:hideMenu()
end

function LobbyController:clickShare()
    setWidgetAction('ShareController', self)
    self:hideMenu()
end

function LobbyController:clickSpread()
    setWidgetAction('SpreadController', self)
    self:hideMenu()
end

function LobbyController:clickTask(sender)
    local user = app.session.user
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    local type = body.type or 'ZhuanPan'
    setWidgetAction('TaskController', self, {user,type})
    self:hideMenu()
end

function LobbyController:clickBind()
    local user = app.session.user
    setWidgetAction('BindPhoneController', self, {user})
    self:hideMenu()
end

function LobbyController:clickCertify()
    local user = app.session.user
    setWidgetAction('CertifyController', self, {user})
    self:hideMenu()
end

function LobbyController:clickExpression()
    local user = app.session.user
    setWidgetAction('MagicExpressController', self, {user})
    self:hideMenu()
end

function LobbyController:buyDiamonds()
    local user = app.session.user
    -- setWidgetAction('BuyDiamondsController', self)
    setWidgetAction('H5ShopController', self, {user})
    self:hideMenu()
end

function LobbyController:clickHead()
    local app = require("app.App"):instance()
    local user = app.session.user
    user.searchMode = true
    setWidgetAction('PersonalPageController', self, {user})
    self:hideMenu()
end

function LobbyController:clickMyRoom()
    setWidgetAction('MyRoomController', self)
     self:hideMenu()
end

function LobbyController:clickRecord()

    setWidgetAction('RecordController', self)
    self:hideMenu()
end

function LobbyController:clickMenu()
    SoundMng.playEft('btn_click.mp3')
    self.menuVisible=not self.menuVisible
    self.view:displayMenu(self.menuVisible)
end

function LobbyController:hideMenu()
    if self.menuVisible then
      self.menuVisible=not self.menuVisible
      self.view:displayMenu(self.menuVisible)
     else
     --SoundMng.playEft('btn_click.mp3')
    end
end

function LobbyController:runRoomListAction()
   SoundMng.playEft('btn_click.mp3')
   local MainPanel = self.view:getMainPanel()
   local roomList = MainPanel:getChildByName('TopBar'):getChildByName("roomList")
   local btn_roomList = MainPanel:getChildByName('roomListBtn')
   local moveTime = 0.2
   local moveDistanceX = 700
   local moveDistanceY = 0
   if(self.ROOM_LIST_FLAG) then
        --房间列表出现在可见界面
        btn_roomList:runAction(cc.MoveBy:create(moveTime, cc.p(moveDistanceX,moveDistanceY)))
        roomList:runAction(cc.MoveBy:create(moveTime, cc.p(moveDistanceX,moveDistanceY)))
        -- self.view:stopRoomAnimation()
        MainPanel:getChildByName('entryNN'):hide()
        MainPanel:getChildByName('entryMJ'):hide()
        MainPanel:getChildByName('entryNY'):hide()
        self.ROOM_LIST_FLAG = false
   else
        --房间列表退回到不可见界面
        local show = cc.CallFunc:create(function()
            MainPanel:getChildByName('entryNN'):show()
            MainPanel:getChildByName('entryMJ'):show()
            MainPanel:getChildByName('entryNY'):show()
            -- self.view:startRoomAnimation()
        end)
        local sequence = cc.Sequence:create(cc.MoveBy:create(moveTime, cc.p(-moveDistanceX,moveDistanceY)),show)
        btn_roomList:runAction(cc.MoveBy:create(moveTime, cc.p(-moveDistanceX,moveDistanceY)))
        roomList:runAction(sequence)
        self.ROOM_LIST_FLAG = true
   end

end

-- 点击进入牛牛
function LobbyController:clickEntryNN()
    setWidgetAction('CreateRoomController', self)
     self:hideMenu()
end

function LobbyController:clickEntryMJ()
    setWidgetAction('CreateRoomController', self, true)
     self:hideMenu()
end


function LobbyController:clickEnterRoom()
    setWidgetAction('EnterRoomController', self)
    self:hideMenu()
end

function LobbyController:clickGroup()
    setWidgetAction('GroupController', self)
    self:hideMenu()
end

function LobbyController:clickContact()
    -- setWidgetAction('MessageController', self)
    setWidgetAction('ContactUsController', self)
    self:hideMenu()
end

function LobbyController:clickHelp()
    --setWidgetAction('HelpController', self)
    setWidgetAction('MessageController', self)
    self:hideMenu()
end

function LobbyController:clickRule()
    setWidgetAction('WanFaController', self)
    self:hideMenu()
end

function LobbyController:clickFeedback()
    setWidgetAction('FeedbackController', self)
    self:hideMenu()
end
function LobbyController:clickActivity()
    setWidgetAction('ActivityController', self)
    self:hideMenu()
end

function LobbyController:clickMessage()
    local group = app.session.group
    group:test1()
    setWidgetAction('MessageController', self)
    self:hideMenu()
end

function LobbyController:clickSetting()
    setWidgetAction('SettingController', self)
     self:hideMenu()
end

function LobbyController:inviteFriend(data)
    local invokefriend = require('app.helpers.invokefriend')
    invokefriend.invoke(data.deskId, data.options)
end

function LobbyController:clickExchange()
    setWidgetAction('ExchangeController', self)
end

function LobbyController:loadNotifyController()
  local ctrl = Controller:load('NotifyController')
  self:add(ctrl)
  local MainPanel = self.view.ui:getChildByName('MainPanel')
  local TopBar = MainPanel:getChildByName('TopBar')

  TopBar:getChildByName('notify'):getChildByName('node'):addChild(ctrl.view)
  self.notifyController = ctrl
end

function LobbyController:clickCoinRoom()
  tools.showRemind("金币场暂未开放")
end

function LobbyController:clickGem()
  SoundMng.playEft('common/audio_button_click.mp3')

  tools.showMsgBox("提示", "购买钻石请联系xxxx")
end

function LobbyController:clickKefu()
  SoundMng.playEft('btn_click.mp3')
  local app = require("app.App"):instance()
  local ctrl = Controller:load('KefuController')
  self:add(ctrl)
  app.layers.ui:addChild(ctrl.view)
  ctrl:on('back',function()
    ctrl:delete()
  end)
end

function LobbyController:clickExit()
  SoundMng.playEft('btn_click.mp3')
  tools.showMsgBox("提示", "是否退出游戏?",2):next(function(btn)
    if btn == 'enter' then
        -- 关闭定时器
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        if device.platform == 'ios' then
            local luaoc = nil
            luaoc = require('cocos.cocos2d.luaoc')
            if luaoc then
                luaoc.callStaticMethod("AppController", "clickExit",{ww='dyyx777777'})
            end
        else
            cc.Director:getInstance():endToLua()
        end
    end
  end)
  self:hideMenu()
end

function LobbyController:share()
    local SocialShare = require('app.helpers.SocialShare')
    local share_url = 'http://www.zmdaj.com/'
    local image_url = 'https://mmbiz.qlogo.cn/mmbiz_png/cjGIMFD8QBib8ic7NZ91HaAk2tnY3At7tbBKibobsX1pJ8YLW5qqERicWSWLQcEaRDZLzcsDNGoezrp2ecPy22DpEw/0?wx_fmt=png'
    local text = '众人乐棋牌重磅推出正宗的曲靖小鸡麻将，随时随地想玩就玩，独乐乐不如众人乐，快分享给朋友吧！'
    SocialShare.share(1,function(platform,stCode,errorMsg)
    print('platform,stCode,errorMsg',platform,stCode,errorMsg)
    end,
    share_url,
    image_url,
    text,
    '众人乐棋牌')
end

function LobbyController:onSchemeRoomId(roomId)
    tools.showMsgBox('提示', '点击确定自动加入房间。\n\n(房间号: '.. tostring(roomId)..')'):next(function(btn)
        if btn == 'enter' then
            app.session.room:enterRoom(roomId, false)
        end
    end)
end

function LobbyController:onSchemeGroupId(groupId)
    app.session.group:requestJoin(groupId)
    tools.showMsgBox('提示', '成功向群主提交了加入申请。\n\n(群id: '.. tostring(groupId)..')')
end

function LobbyController:getChildCtrlConut()
    if self.children then
        return table.nums(self.children)
    end
    return 0
end

-- function LobbyController:clickDownload()
--   self.view:clickDownload()
-- end

return LobbyController
