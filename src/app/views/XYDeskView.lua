local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local HeartbeatCheck = require('app.helpers.HeartbeatCheck')
local app = require("app.App"):instance() 
local GameLogic = require('app.libs.niuniu.NNGameLogic')

local testluaj = nil
if device.platform == 'android' then
    testluaj = require('app.models.luajTest')--引入luajTest类
end

local SUIT_UTF8_LENGTH = 3

local XYDeskView = {}

function XYDeskView:initialize() -- luacheck: ignore
    --节点事件
    self:enableNodeEvents()
    
    --心跳包模块
    self.heartbeatCheck = HeartbeatCheck()

    self.suit_2_path = {
        ['♠'] = 'h',
        ['♣'] = 'm',
        ['♥'] = 'z',
        ['♦'] = 'f',
        ['★'] = 'j1',
        ['☆'] = 'j2',
    }

    self.kusoArr = {
        { path = 'views/xydesk/kuso/kuso1.plist',
          frame = 24, prefix = 'cjd_' },

        { path = 'views/xydesk/kuso/kuso2.plist',
          frame = 24, prefix = 'dg_' },

        { path = 'views/xydesk/kuso/kuso3.plist',
          frame = 24, prefix = 'fz_' },

        { path = 'views/xydesk/kuso/kuso4.plist',
          frame = 20, prefix = 'hpj_' },

        { path = 'views/xydesk/kuso/kuso5.plist',
          frame = 24, prefix = 'hqc_' },

        { path = 'views/xydesk/kuso/kuso6.plist',
          frame = 17, prefix = 'wen_' },

        { path = 'views/xydesk/kuso/kuso7.plist',
          frame = 20, prefix = 'zhd_' },

        { path = 'views/xydesk/kuso/kuso8.plist',
          frame = 22, prefix = 'zht_' },

        { path = 'views/xydesk/kuso/kuso9.plist',
          frame = 20, prefix = 'zj_' },
    }

    -- state
    self.state = 'none'

    -- 作弊界面 相关状态
    self.cheatViewStatus = {
        startPos = nil, -- cc.p
        endPos = nil,   -- cc.p
        signalCount = 0,
        signalCheck = false,
    }

    self.viewKey = {
        'bottom',
        'left',
        'lefttop',
        'top',
        'righttop',
        'right',
    }

    self.bankerPlayedSound = false

    -- 显示庄家动画相关
    self.updateBankerFunc = nil

    -- 储存所有扑克节点纹理路径
    self.tabCardsTexture = {}

    -- 所有进行中的动画
    self.tabRuningAnimate = {}

    --tick
    self.stateTick = 0
    self.deviceTick = 0
    -- tips
    self.tipText = ''

    -- 作弊标签
    self.tabCheatLable = {}

    self.updateF = Scheduler.new(function(dt)
        self:update(dt)
    end)
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state

function XYDeskView:reloadState(toState)
    -- if self.state and self['onOut' .. self.state] then
    --     self['onOut' .. self.state](self)
    -- end
    self.next = toState
    self.state = toState
end

function XYDeskView:checkState()
	if self.next ~= self.state then
        if self.state and self['onOut' .. self.state] then
            print(string.format('onOut %s', self.state))
			self['onOut' .. self.state](self)
		end
		self.state = self.next
        if self.state and self['onEnter' .. self.state] then
            print(string.format('onEnter %s', self.state))
			self['onEnter' .. self.state](self)
		end
	end
end

function XYDeskView:setState(state)
    print(string.format('setState %s', self.state))
    self.next = state
    self:checkState()
end

function XYDeskView:updateState(dt)
    if self.state and self['onUpdate' .. self.state] then
        self['onUpdate' .. self.state](self, dt)
    end
end

function XYDeskView:onMessageState(msg)
    if self.state and self['onMessage' .. self.state] then
        self['onMessage' .. self.state](self, msg)
    end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state: Ready
function XYDeskView:onEnterReady(curState)
    local desk = self.desk
    
    self:showlastcard()
    -- tip
    if self.desk:isGamePlayed() then
        local tick = self.desk:getTick()
        self:freshTip(true, '下局游戏开始：', tick)
    end


    self:freshPrepareBtn(false) --坐下自动准备不显示中部准备按钮
    if desk:isMePlayer() then
        -- 自己是玩家
        local bottomAgnet = desk:getMeAgent()
        self:freshWatcherBtn(false)
        if bottomAgnet:isReady() then
            -- 已经准备
            self:freshContinue(false)
            self:freshPrepareBtn(false)
        else
            -- 没有准备
            if desk:isGamePlayed() then
                self:freshContinue(true)
            end
        end
    else
        -- 不是玩家
        local cnt = self.desk:getPlayerCnt()
        if cnt == self.desk:getMaxPlayerCnt() then
            self:freshWatcherBtn(false) -- 显示坐下按钮
        else
            self:freshWatcherBtn(true) -- 显示坐下按钮
        end
    end 


    local ownerInfo = desk:getOwnerInfo()
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    if meUid == ownerInfo.uid and not desk:isGamePlayed() then
        -- 自己是房主, 且游戏没开始
        self:freshGameStartBtn(true, false) --显示开始游戏按钮
    else
        self:freshGameStartBtn(false, false)
    end

    if not desk:isGamePlayed() then
        self:freshInviteFriend(true) -- 邀请按钮
    end

    self:freshBtnPos() -- 调整按钮位置

    -- 隐藏界面
    self:freshWatcherSp(false)
end

function XYDeskView:onOutReady(curState)
    self:freshTip(false)

    -- self:freshWatcherBtn(false)
    if not self.desk:isMePlayer() then
        self:freshWatcherSp(true)   
    else
        self:freshWatcherBtn(false)
    end

    self:freshGameStartBtn(false, false)
    self:freshPrepareBtn(false)
    self:freshInviteFriend(false)
    self:freshContinue(false)
    

    -- 隐藏当局得分
    self:freshAllOneRoundScore()
    -- 隐藏所有玩家卡牌
    self:freshAllCards()
    -- 隐藏所有 玩家头像的准备
    self:freshAllReady(false)
    -- 隐藏所有 玩家的标记牌
    self:hideAllLastCard()
end

function XYDeskView:onUpdateReady(dt)
    -- 调整界面位置
    self:freshBtnPos()

    -- 刷新提示文本
    local played = self.desk:isGamePlayed()
    local canStart = (self.desk:getReadyPlayerCnt()>=2)
    if not played then
        local name = '房主'
        if self.desk:isGroupDesk() then
            -- 牛友群房间
            local startPlayer = self.desk:getCanStartPlayer()
            if startPlayer then
                name = startPlayer:getNickname() or name
                local meUid = self.desk:getMeUID()
                if meUid == startPlayer:getUID() then
                    self:freshGameStartBtn(true, canStart)
                else
                    self:freshGameStartBtn(false, false)
                end
            else
                self:freshGameStartBtn(false, false)
            end
        else
            -- 普通房间
            if self.desk:isMeOwner() then
                self:freshGameStartBtn(true, canStart)
            else
                self:freshGameStartBtn(false, false)
            end
        end
        
        -- 刷新开始按钮
        if canStart then
            self:freshTip(true, string.format( "等待 %s 开始游戏...", name))
        else
            self:freshTip(true, '请等待其他玩家加入...')
        end
    end
        
    if not self.desk:isMePlayer() then -- 坐下按钮 | 请等待下局开始
        -- self:freshWatcherSp(true) 
        local cnt = self.desk:getPlayerCnt()
        if cnt == self.desk:getMaxPlayerCnt() then
            self:freshWatcherBtn(false) -- 显示坐下按钮
        else
            self:freshWatcherBtn(true) -- 显示坐下按钮
        end
    end
end


function XYDeskView:onMessageReady(msg)
    if msg.msgID == 'canStart' then
        local enable = msg.canStart or false
        if not self.desk:isGroupDesk() then
            if self.desk:isMeOwner() then
                self:freshGameStartBtn(true, enable)
            end
        end

    elseif msg.msgID == 'somebodyPrepare' then 
        local playerInfo = msg.info
        local viewKey = playerInfo.viewKey
        if viewKey == 'bottom' then
            self:freshTipText('等待其他玩家准备')
            self:freshPrepareBtn(false)
            self:freshContinue(false)
        end
        self:freshReadyState(viewKey, true)

    elseif msg.msgID == 'waitStart' then
    

    elseif msg.msgID == 'responseSitdown' then
        local retCode = msg.errCode
        local textTab = {
            [1] = "没有足够的座位",
            [2] = "您已经坐下了",
            [3] = "本房间为AA模式, 您的房卡不足",
            [4] = "您暂时不能加入该牛友群的游戏, 详情请联系该群管理员",
            [5] = "本房间开启了游戏途中禁止加入功能",
            [6] = "您的信誉值不足",
        }
        if retCode and retCode ~= 0 then
            tools.showRemind(textTab[retCode])
        end
        self:freshWatcherBtn(false)
    else
        self:onMessagePlaying(msg)
    end
end

function XYDeskView:onReloadReady(curState)
    if self.desk.tabPlayer then 
        for uid, agent in pairs(self.desk.tabPlayer) do
            local viewKey, viewPos = agent:getViewInfo()
            self:freshReadyState(viewKey, agent:isReady())
        end
    end
    self:reloadState('Ready')
    self:onEnterReady()
end

function XYDeskView:freshIsCoin()
    if not self.desk.tabBaseInfo then return end
    local deskInfo = self.desk.tabBaseInfo.deskInfo
    if not deskInfo then return end
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local img = seat:getChildByName('avatar'):getChildByName('point'):getChildByName('img')
        img:setVisible(deskInfo.roomMode == 'bisai')
    end
end

function XYDeskView:freshWatcherSp(bShow)
    bShow = bShow or false
    self.watcherStatusSp:setVisible(bShow)
end

function XYDeskView:freshWatcherBtn(bShow)
    bShow = bShow or false
    self.watcherSitdownBtn:setVisible(bShow)
    self.playerViews.msg:setVisible(not bShow)
    self.playerViews.voice:setVisible(not bShow)
end

function XYDeskView:onResponseSitdown(msg)
    local retCode = msg.errCode
    local textTab = {
        [1] = "没有足够的座位",
        [2] = "您已经坐下了",
        [3] = "本房间为AA模式, 您的房卡不足",
        [4] = "您暂时不能加入该牛友群的游戏, 详情请联系该群管理员",
        [5] = "本房间开启了游戏途中禁止加入功能",
        [6] = "您的信誉值不足",
    }
    if retCode and retCode ~= 0 then
        tools.showRemind(textTab[retCode])
    else
        self:freshWatcherBtn(false)
    end
end

function XYDeskView:freshContinue(bool)
    local component = self.MainPanel:getChildByName('bottom')
    local continue = component:getChildByName('continue')
    continue:setVisible(bool)
end

function XYDeskView:freshPrepareBtn(bool)
	local btn = self.MainPanel:getChildByName('prepare')
    self.outerFrameBool = false
	btn:setVisible(bool)
end

function XYDeskView:freshBtnPos()
    local btnTab = {
        self.prepareBtn,
        self.startBtn,
        self.watcherSitdownBtn
    }
    local showCnt = 0
    for i, v in pairs(btnTab) do
        if v:isVisible() then
            showCnt = showCnt + 1
        end
    end
    if showCnt == 1 then
        self.startBtn:setPosition(self.tabBtnPos.middle)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
        self.prepareBtn:setPosition(self.tabBtnPos.middle)
    elseif showCnt == 2 then
        self.startBtn:setPosition(self.tabBtnPos.left)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.right)
        self.prepareBtn:setPosition(self.tabBtnPos.right)
    elseif showCnt == 0 then
        self.startBtn:setPosition(self.tabBtnPos.middle)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
        self.prepareBtn:setPosition(self.tabBtnPos.middle)
    end
end

function XYDeskView:freshGameStartBtn(show, enable)
	local btn = self.MainPanel:getChildByName('gameStart')
	btn:setVisible(show)
    btn:setEnabled(enable)
end


function XYDeskView:freshAllReady(bool)
    bool = bool or false
    for _, v in pairs(self.viewKey) do
        self:freshReadyState(v, bool)
    end
end 


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:StateStarting
function XYDeskView:onEnterStarting(curState)
    -- 重置座位界面
    for k,v in pairs(self.viewKey) do
        self:clearDesk(v)
    end
    self:freshRoomInfo(true)

    local gameplay = self.desk:getGameplayIdx()
    if gameplay == 1 or gameplay == 2 then
        -- 刷新庄家
        local info = self.desk:getBankerInfo()
        if info then
            self:freshBanker(info.viewKey, true)
        end
    end

end

function XYDeskView:onOutStarting(curState)

end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Dealing
function XYDeskView:onEnterDealing(curState)
    
end

function XYDeskView:onOutDealing(curState)

end

function XYDeskView:onMessageDealing(msg)
    if msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)
    end
end

function XYDeskView:onDealMsg(reload) -- virtual
    local deskInfo = self.desk:getDeskInfo()
    if GameLogic.isQzGame(deskInfo) then
        -- 抢庄模式
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    local cardData = agent:getHandCardData()
                    if cardData then
                        self:freshCards(viewKey, false, cardData, 1, 4)
                        self:freshCards(viewKey, false, nil, 5, 5)
                    else
                        self:freshCards(viewKey, false, nil, 1, 5)
                    end
                    if not reload then
                        self:showCardsAction(viewKey, 1, 4)
                    else
                        self:freshCards(viewKey, true, cardData, 1, 4)
                    end
                end
            end
        end
    end

    if GameLogic.isSzGame(deskInfo) then
        -- 上庄模式
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    local cardData = agent:getHandCardData()
                    if cardData then
                        -- self:freshCards(viewKey, false, cardData, 1, 5)
                        self:freshCards(viewKey, false, nil, 1, 5)
                    else
                        self:freshCards(viewKey, false, nil, 1, 5)
                    end
                    if not reload then
                        self:showCardsAction(viewKey, 1, 5)
                    else
                        self:freshCards(viewKey, true, cardData, 1, 5)
                    end
                end
            end
        end
    end
end

-- 隐藏所有扑克
function XYDeskView:freshAllCards()
    for k,v in pairs(self.viewKey) do
        self:freshCards(v, false, nil, 1, 5)
        if v == 'bottom' then
            self:freshMiniCards(false)
        end
    end
end

function XYDeskView:freshCards(name, show, data, head, tail, noTexture) -- virtual
    show = show or false
    noTexture = noTexture or false

    -- 刷新扑克显示
    local component = self.MainPanel:getChildByName(name)
    if not component then return end
    if head > tail then return end
    local cards = component:getChildByName('cards')
 

    for i = 1, 5 do
        if i >= head and i <= tail then
            local card = cards:getChildByName('card' .. i)
            -- 停止动作
            card:stopAllActions()
            -- 重置坐标
            local oriPos = self.cardsOrgPos[name][i]
            card:setPosition(oriPos.x, oriPos.y)
            -- 缩放
            card:setScale(1)
            -- 显示
            card:setVisible(show)

            if not noTexture then
                -- 纹理
                if data and data[i] then
                    -- 牌面
                    local cardData = data[i]
                    self:freshCardsTexture(name, i, cardData)
                else
                    -- 牌背
                    local idx = self:getCurCuoPai()
                    self:freshCardsTexture(name, i, nil, idx)
                end
            end
        end
    end

    cards:setVisible(show)
end

function XYDeskView:showCardsAction(name, head, tail) -- virtual
    -- 发牌动画 不刷新纹理
    local component = self.MainPanel:getChildByName(name)
    if not component then return end
    if head > tail then return end

    local delay, duration, offset = 0.3, 0.3, 0.15
    local cards = component:getChildByName('cards')
    cards:setVisible(true)

    for i = head, tail do
        local card = cards:getChildByName('card' .. i)

        -- 使用原始坐标
        local oriPos = self.cardsOrgPos[name][i]

        local startPos = cards:convertToNodeSpace(cc.p(display.cx, display.cy))
        card:setPosition(startPos.x, startPos.y)

        delay = delay + offset
        local dtime = cc.DelayTime:create(delay)
        local move = cc.MoveTo:create(duration, oriPos)
        local show = cc.Show:create()
        local eft = cc.CallFunc:create(function()
            SoundMng.playEft('desk/fapai.mp3')
        end)
        local sequence = cc.Sequence:create(dtime, show, eft, move, 
            cc.CallFunc:create(function()
                if i == tail then
                    self:cardsBackToOriginSeat(name)
                    card:setVisible(true)
                    card:setScale(1)
                end
            end
        ))
        card:stopAllActions()
        
        card:runAction(sequence)

        local sc = cc.ScaleTo:create(duration, 1.0)
        local sq = cc.Sequence:create(dtime, sc, dtime, cc.CallFunc:create(function ()
            if i == tail then
                self.emitter:emit("showCardsActionEnd",{msgID = 'showCardsActionEnd', name = name})
            end
        end))
        card:setScale(0.7)
        card:runAction(sq)
        
    end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:QiangZhuang
function XYDeskView:onEnterQiangZhuang(curState)
    self:freshAutoFanpaiLayer(true)
    local tick = self.desk:getTick()
    self:freshTip(true , '操作抢庄：', tick)

    self:hideAllLastCard()

    -- 显示操作界面
    if self.desk:isMeInMatch() then
        local agent = self.desk:getMeAgent()
        if not agent:getQiang() then
            self:freshQiangZhuangBar(true, agent)
        else
            self:freshTipText('等待其他玩家抢庄：')
        end
    end
end

function XYDeskView:freshQiangZhuangBar(bool)   -- virtual
    assert(false)
end

function XYDeskView:onOutQiangZhuang(curState)
    -- 清除庄家动画相关界面
    self:freshTip(false)
    self:freshQiangZhuangBar(false)
    self:freshAllCanPutMoney(false)
    self:freshAutoFanpaiLayer(false)
end

function XYDeskView:onUpdateQiangZhuang(dt)

end

function XYDeskView:onReloadQiangZhuang(curState)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    local flagBanker = gameplay:getFlagFindBanker()
    if flagBanker then
        -- 抢庄结果
        self:showBankerActionEnd()
    else
        -- 抢庄过程
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    local num = agent:getQiang()
                    if num then self:freshQZBet(viewKey, num, true) end
                end
            end
        end
    end
    
    --显示可推注提示
    self:freshAllCanPutMoney(true)
    
    self:reloadState('QiangZhuang')
    self:onEnterQiangZhuang()
end

function XYDeskView:onMessageQiangZhuang(msg)
    if msg.msgID == 'somebodyQiang' then
        -- 有人完成抢庄
        local name = msg.info.viewKey
        local num = msg.number
        if name == "bottom" then
            self:freshQiangZhuangBar(false)
            self:freshTipText('等待其他玩家抢庄：')
        end
        self:playEftQz(num, msg.info.player:getSex())
        self:freshQZBet(name, num, true)

    elseif msg.msgID == 'newBanker' then
        self:freshTip(false)
        self:freshQiangZhuangBar(false)
        local name = msg.info.viewKey
        self:freshAllQZBet()
        -- 播放抢庄动画
        self:showBankerAction(name, msg.number, msg.qiangPlayer)
        -- 隐藏可推注动画
        self:freshCanPutMoney(name,false)
    elseif msg.msgID == 'showBankerActionEnd' then
        self:showBankerActionEnd()
    elseif msg.msgID == 'CanPutMoneyPlayer' then
        -- 显示可推注动画
        for i = 1, msg.cnt do
            self:freshCanPutMoney(msg.viewKey[i],true)
        end
    end
end


-- 隐藏所有抢庄界面
function XYDeskView:freshAllQZBet()
    for _, v in pairs(self.viewKey) do
        self:freshQZBet(v, 0, false)
    end
end 


function XYDeskView:freshQZBet(name, num, bool)
    -- 在用户头像显示抢（不抢）
	local component = self.MainPanel:getChildByName(name)
	local avatar = component:getChildByName('avatar')
	
	local qzBet = avatar:getChildByName('qzBet')
	local qz = qzBet:getChildByName('qz')
    local bq = qzBet:getChildByName('bq')
	local path = 'views/xydesk/result/qiang/'

    bq:setVisible(false)
    qz:setVisible(false)	
	if num == 0 then
		bq:setVisible(true)
    else
        qz:loadTexture(path..num..'.png')
        qz:setVisible(true)
	end

	qzBet:setVisible(bool)
end 

-- 刷新庄家
function XYDeskView:freshBanker(name, bool, qzNum) --virtual
    bool = bool or false

    local function getOutFrame(name)
        local component = self.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local outerFrame = frame:getChildByName('outerFrame')
        return outerFrame
    end

    local function getBankerIcon(name)
        local component = self.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local banker = avatar:getChildByName('banker')
        return banker
    end

    local function freshQZNum(bool, num)
        local component = self.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local numNode = avatar:getChildByName('qzNum')
        numNode:setVisible(bool)

        if not num or num == 0 then
            numNode:setVisible(false)
            return
        end
        local path = 'views/xydesk/result/bei/' .. num .. '.png'
        numNode:loadTexture(path)
    end

    getOutFrame(name):setVisible(bool)
    getBankerIcon(name):setVisible(bool)
    freshQZNum(bool, qzNum)
end

-- 隐藏所有庄家界面
function XYDeskView:freshAllBanker()
    for _, v in pairs(self.viewKey) do
        self:freshBanker(v, false)
    end
end

-- 隐藏所有可推注动画
function XYDeskView:freshAllCanPutMoney(show)
    for _, v in pairs(self.viewKey) do
        self:freshCanPutMoney(v, false)
    end
    if show then
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getCanPutMoney() then
                    local viewKey = agent:getViewInfo()
                    self:freshCanPutMoney(viewKey, true)
                end
            end
        end        
    end
end


function XYDeskView:showBankerAction(viewKey, qzNum, qiangData)

    if not self.updateBankerFunc then
        self.updateBankerFunc = self:initShowBankerAction(viewKey, qzNum, qiangData)
        return
    end

    -- 停止当前动画
    self.updateBankerFunc(self, nil, true)
    self.updateBankerFunc = nil

    self.updateBankerFunc = self:initShowBankerAction(viewKey, qzNum, qiangData)
end

function XYDeskView:stopBankerAction()
    if self.updateBankerFunc then
        self.updateBankerFunc(self, nil, true)
        self.updateBankerFunc = nil
    end
end

function XYDeskView:onUpdateBanker(dt)
    if self.updateBankerFunc then
        self.updateBankerFunc(self, dt)
    end
end

-- 显示抢庄动画
function XYDeskView:initShowBankerAction(viewKey, qzNum, qiangData)
    local gameplay = self.desk:getGameplayIdx()

    local rank = {}
    local idx = 1
    for k,v in pairs(self.viewKey) do
        rank[v] = k
    end
    -- local rank = {
    --     ['bottom'] = 6,
    --     ['left'] = 5,
    --     ['lefttop'] = 4,
    --     ['top'] = 3,
    --     ['righttop'] = 2,
    --     ['right'] = 1,
    -- }
    -- if gameplay == 8 then
    --     rank = {
    --         ['bottom'] = 6,
    --         ['left'] = 5,
    --         ['lefttop'] = 4,
    --         ['top'] = 3,
    --         ['righttop'] = 2,
    --         ['right'] = 1,
    --     }
    -- end

    local data =  {}
    local this = self
    local mulNum = qzNum or 0
    local function resetData()
        data = {
            run = false,        -- 运行标志
            players = {},       -- 所有的抢庄者 {"left", "bottom"}
            time = 1.9,         -- p1动画时间    
            time1 = 0.9,          -- p2动画时间 
            time2 = 3,          -- 动画总时间  
            interval = 0.08,    -- 切换间隔

            tick1 = 0,          -- 切换tick
            tick2 = 0,          -- 总时间tick
            tick3 = 0,
            tick4 = 0,      --ios播放抢庄声音间隔
            lanxuCnt = 0,

            idx = 1,            -- 切换IDX    
            bankerSeat = "",    -- 庄家位置
            pervIdx = 1,
            mulNum = mulNum,
            gameplay = gameplay,
            status = 1,
            cnt = 1,
        }
        return data
    end

    local function getOutFrame(name)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local outerFrame = frame:getChildByName('outerFrame')
        return outerFrame
    end

    local function getBankerIcon(name)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local banker = avatar:getChildByName('banker')
        return banker
    end

    local function freshBlinkAction(name, show)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local node = avatar:getChildByName('bankAnimation')
        node:setVisible(show)
        if show then
            local action = cc.CSLoader:createTimeline("views/animation/Zhuangjia1.csb")
            action:gotoFrameAndPlay(0, false)
            node:stopAllActions()
            node:runAction(action)
        end
    end

    local function freshBankerAction(name, show)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local node = avatar:getChildByName('qzAnimation')
        node:setVisible(show)
        if show then
            local action = cc.CSLoader:createTimeline("views/animation/Zhuangjia.csb")
            action:gotoFrameAndPlay(0, false)
            node:stopAllActions()
            node:runAction(action)
        end
    end

    local function freshIconAction(name, show)
        local component = this.MainPanel:getChildByName(name)
        local avatar = component:getChildByName('avatar')
        local node = avatar:getChildByName('bankAnimation1')
        node:setVisible(show)
        if show then
            local action = cc.CSLoader:createTimeline("views/animation/Zhuangjia2.csb")
            action:gotoFrameAndPlay(0, false)
            node:stopAllActions()
            node:runAction(action)
        end
    end

    data = resetData()
    data.players = qiangData
    data.idx = 1
    data.bankerSeat = viewKey
    data.run = true

    local interval2 = data.interval * 3

    if data.players and #data.players == 0 then
        -- 没人抢庄, 加入所有玩家
        data.players = {}
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local viewKey = agent:getViewInfo()
                    table.insert(data.players, viewKey)
                end
            end
        end
        table.sort(data.players, function(a,b)
            if rank[a] and rank[b] then
                return rank[a] > rank[b]
            end
        end)

    elseif data.players and #data.players == 1 then
        -- 一人抢庄
        data.time = 0.1
        
    elseif data.players and #data.players > 1  then
        -- 多人抢庄 排序
        -- table.sort(data.players, function(a,b)
        --     if a.number and b.number then
        --         return a.number > b.number
        --     end
        -- end)

        -- local max = data.players[1].number
        -- for i = #data.players, 1, -1 do
        --     if max ~= data.players[i].number then
        --         table.remove( data.players, i)
        --     end
        -- end

        table.sort(data.players, function(a,b)
            if rank[a] and rank[b] then
                return rank[a] > rank[b]
            end
        end)

        -- if #data.players == 1 then
        --     data.time = 0.1
        -- end
    end
    
    return function(this, dt, stopFlag)
        -- 更新函数
        dt = dt or 0.01
        local function showBanker()
            this.emitter:emit('showBankerActionEnd', 
            {
                msgID = 'showBankerActionEnd',
                viewKey = data.bankerSeat, 
                qzNum = data.mulNum,
            })
            resetData()
        end

        if data.run then
            if stopFlag then
                resetData()
                return data.run
            end

            if dt then
                data.tick1 = data.tick1 + dt
                data.tick2 = data.tick2 + dt
            end

            -- p1 播放声音
            if device.platform == 'ios' and data.status == 1 then
                data.tick4 = data.tick4 + dt
                if data.tick4 >= 1 then
                    SoundMng.playEft('desk/random_banker_lianxu.mp3')
                    data.tick4 = 0
                end
            end

            -- p1
            if data.status == 1 and data.tick1 > data.interval then
                -- 轮换
                local cur = data.players[data.idx]
                local perv = data.players[data.pervIdx]
                if perv then
                    getOutFrame(perv):setVisible(false)
                    getBankerIcon(perv):setVisible(false)
                    freshBlinkAction(perv, false)
                end
                if cur then
                    data.pervIdx = data.idx
                    getOutFrame(cur):setVisible(false)
                    getBankerIcon(cur):setVisible(false)
                    freshBlinkAction(cur, true)
                    if device.platform ~= 'ios' then
                        SoundMng.playEft('desk/random_banker.mp3')
                    end
                end
                local idx = data.idx + 1
                data.idx = (idx > #data.players) and 1 or idx
                data.tick1 = 0
                
                -- 时间到
                if data.tick2 > data.time then
                    data.interval = interval2
                    if cur and cur == data.bankerSeat then
                        getOutFrame(cur):setVisible(false)
                        getBankerIcon(cur):setVisible(false)
                        freshBankerAction(cur,true)
                        data.status = 2
                    end
                end
            end
            -- p2
            if data.status == 2 then
                data.tick3 = data.tick3 + dt
                if data.tick1 > data.interval then
                    data.cnt = data.cnt + 1
                    local bShow = data.cnt%2 == 1
                    -- getOutFrame(data.bankerSeat):setVisible(bShow)
                    -- getBankerIcon(data.bankerSeat):setVisible(bShow)
                    data.tick1 = 0
                end
                if data.tick3 > data.time1 then
                    freshIconAction(data.bankerSeat, true)
                    getOutFrame(data.bankerSeat):setVisible(true)
                    getBankerIcon(data.bankerSeat):setVisible(true)
                    showBanker()
                    return data.run
                end
            end
            -- time out
            if data.tick2 > data.time2 then
                showBanker()
                resetData()
                return data.run
            end
        end
        return data.run
    end
end

function XYDeskView:showBankerActionEnd()
    local banker = self.desk:getBankerInfo()
    if not banker then return end

    local qzNum = banker.player:getQiang()
    self:freshAllBanker()
    self:freshBanker(banker.viewKey, true, qzNum)
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:PutMoney
function XYDeskView:onEnterPutMoney(curState)
    local tick = self.desk:getTick()

    self:freshAutoFanpaiLayer(true)
    --显示可推注提示
    self:freshAllCanPutMoney(true)

    self:hideAllLastCard()

    local bankerInfo = self.desk:getBankerInfo()
    if bankerInfo and bankerInfo.viewKey == 'bottom' then
        self:freshTip(true , '等待其他玩家下注：', tick)
    else
        self:freshTip(true , '选择下注：', tick)
    end
end


function XYDeskView:onOutPutMoney(curState)
    -- 清除庄家动画相关界面
    self:freshBettingBar(false)
    self:freshTip(false)
    self:freshAllCanPutMoney(false)
    self:freshAutoFanpaiLayer(false)
end

function XYDeskView:onUpdatePutMoney(dt)
    -- > next state
end

function XYDeskView:onReloadPutMoney(curState)
    local gameplay = self.desk.gameplay
    if not gameplay then return end

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey)
            end
        end
    end

    -- 操作界面
    if self.desk:isMeInMatch() then
        local agent = self.desk:getMeAgent()
        if not agent:getPutscore() then
            local putOpt = agent:getThisPutOpt()
            if putOpt then
                self:freshBettingBar(true, putOpt)
            end
        end
    end

    self:reloadState('PutMoney')
    self:onEnterPutMoney()
end

function XYDeskView:onMessagePutMoney(msg)
    if msg.msgID == 'somebodyPut' then
        local viewKey = msg.info.viewKey
        if viewKey == "bottom" then
            self:freshBettingBar(false)
            self:freshTipText('等待其他玩家下注：')
        end
        self:showBettingAction(viewKey, msg.tuizhuflag)
        
        -- 隐藏已推注的人的可推注动画
        self:freshCanPutMoney(viewKey,false)

    elseif msg.msgID == 'putMoney' then  
        local putInfo = msg.putInfo  
        self:freshBettingBar(true, putInfo)

    elseif msg.msgID == 'showBankerActionEnd' then
        self:showBankerActionEnd()
        
    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)
    end
end

-- 下注按钮界面
function XYDeskView:freshBettingBar(bool, tabPutInfo)
    local component = self.MainPanel:getChildByName('bottom')
    local betting = component:getChildByName('betting')
    betting:setScrollBarEnabled(false)

    local function hideAllBtn()
        for i = 1, 4 do
            local btn = betting:getChildByName(tostring(i))
            btn:setVisible(false)
        end
    end

    hideAllBtn()

    if bool then
        if tabPutInfo then
            local len = #tabPutInfo
            
            for k, v in pairs(tabPutInfo) do
                local btn = betting:getChildByName(tostring(k))
                btn:setVisible(true)
                local val = btn:getChildByName('val')
                val:setString(v)

                btn:addClickEventListener(function()
                    SoundMng.playEft('btn_click.mp3')
                    self.emitter:emit('clickBet', v)
                end)
            end
            
            local item = betting:getChildByName(tostring(1))
            local margin = betting:getItemsMargin()
            local cnt = len
            local itemWidth = item:getContentSize().width * item:getScaleX() * betting:getScaleX()
            local listWidth = (itemWidth*cnt) + (margin*(cnt-1))
            local posX = display.cx - (listWidth/2)
            betting:setPositionX(posX)
        end
    end

    betting:setVisible(bool)
end

-- 显示下注动画
function XYDeskView:showBettingAction(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local multiple = avatar:getChildByName('multiple')
    local num = multiple:getChildByName('num')

    multiple:setVisible(false)

    local function getStartPos(name)
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    local function getDestPos(name)
        local coin = multiple:getChildByName('value')
        local pos = multiple:convertToWorldSpace(cc.p(coin:getPosition()))
        return pos
    end

    local dest = getDestPos(name)
    local start = getStartPos(name)

    for i = 1, 3 do
        local sprite = cc.Sprite:create('views/xydesk/3x.png')
        sprite:setVisible(false)
        sprite:setScale(1)
        self:addChild(sprite)

        sprite:setPosition(start)

        local delay = cc.DelayTime:create(0.05 * i) 
        local moveTo = cc.MoveTo:create(0.4, dest)
        local show = cc.Show:create()

        local eft = cc.CallFunc:create(function()
            if i == 2 then
                self:playEftBet(bool)
            end
        end)
        local callBack = cc.CallFunc:create(function()
            if i == 3 then
                -- 动画结束
                self.emitter:emit('bettingActionEnd', {
                    msgID = 'bettingActionEnd',
                    viewKey = name,
                })
                -- multiple:setVisible(true)
                -- num:setString(tostring(value))
            end
        end)

        local rmvSelf = cc.RemoveSelf:create()
        local retainTime = cc.DelayTime:create(1) 
        local sequence = cc.Sequence:create(
            delay, 
            show, 
            moveTo, 
            eft, 
            callBack,
            retainTime, 
            rmvSelf
        )   

        sprite:runAction(sequence)
    end
end

function XYDeskView:showBettingActionEnd(name)
    local info = self.desk:getPlayerInfo(nil, name)
    if not info then return end

    local banker = self.desk:getBankerInfo()
    local gameplay = self.desk:getGameplayIdx()
    if banker and gameplay ~= 5 then
        if banker.viewKey == info.viewKey then
            self:freshBetting(name, false)
            return
        end
    end

    local putScore = info.player:getPutscore()
    if putScore then
        self:freshBetting(name, true, putScore)
    else
        self:freshBetting(name, false)
    end
end

-- 刷新下注界面
function XYDeskView:freshBetting(name, bool, value)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local multiple = avatar:getChildByName('multiple')
    local num = multiple:getChildByName('num')

    if not bool then
        multiple:setVisible(false)
        return
    end

    if value then
        num:setString(tostring(value))
        multiple:setVisible(true)
    end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- state:Playing
function XYDeskView:onEnterPlaying(reload)
    local deskInfo = self.desk:getDeskInfo()
    
    self:freshAutoFanpaiLayer(false)
    if self.desk.tabPlayer and (not reload) then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                local cardData = agent:getHandCardData()
                -- 显示搓牌中
                self:freshSeatCuoPai(viewKey, false)

                if GameLogic.isQzGame(deskInfo) then
                    -- 发最后一张牌(牌背)
                    self:freshCards(viewKey, false, nil, 5, 5)
                    self:showCardsAction(viewKey, 5, 5)
                end
            end
        end
    end

    local tick = self.desk:getTick()
    self:freshTip(true , '查看手牌：', tick)

    -- 操作界面
    if self.desk:isMeInMatch() then
        local agent = self.desk:getMeAgent()
        if agent:getChoosed() then
            -- 已经亮牌
            self:freshTipText('等待其他玩家亮牌')
        else
            if reload then
                self:onClickTips()
                self:freshOpBtns(false, true)
            else
                local enableCuopai = GameLogic.isEnableCuoPai(deskInfo)
                self:freshCuoButton(enableCuopai)
                self:freshOpBtns(true, false)
            end
        end
    end
end

function XYDeskView:onOutPlaying(curState)
    self:freshAllSeatCuoPai()
    self:freshOpBtns(false, false)
    self:freshCuoPaiDisplay(false)
    self:freshAutoFanpaiLayer(false)
    self:hideAllLastCard()
end

function XYDeskView:onUpdatePlaying(dt)

end

function XYDeskView:onReloadPlaying(curState)

    -- 押注过程
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:showBettingActionEnd(viewKey)
            end
        end
    end

    -- 刷新扑克
    local isDeal = self.desk.gameplay:getFlagDealAllPlayer()
    if isDeal then
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                if agent:getInMatch() then
                    local choose = agent:getChoosed()
                    local viewKey = agent:getViewInfo()
                    
                    self:freshSeatCuoPai(viewKey, (not choose))

                    local cardsData = agent:getSummaryCardData()
                    if choose and cardsData then
                        self:freshCards(viewKey, true, cardsData, 1, 5)
                        self:onSomeBodyChoosed(viewKey, true)
                    else
                        self:freshCards(viewKey, true, nil, 1, 5)
                    end
                end
            end
        end
    end

    self:reloadState('Playing')
    self:onEnterPlaying(true)
    self:showlastcard()
end

function XYDeskView:onMessagePlaying(msg)
    if msg.msgID == 'someBodyChoosed' then
        local info = msg.info
        local agent = info.player
        local viewKey = info.viewKey
        local hasCardData = msg.hasCardData
        self:onSomeBodyChoosed(viewKey)

    elseif msg.msgID == 'summary' then
        self:freshTip(false)
        self.flagEftSummary = false
        self:onSummary()

    elseif msg.msgID == 'showCoinFlayActionEnd' then
        self:showCoinFlayActionEnd(msg.start, msg.dest)

    elseif msg.msgID == 'showCardsActionEnd' then
        local autofanpai = false
        if self.desk.tabPlayer then
            for uid, agent in pairs(self.desk.tabPlayer) do
                local viewKey, viewPos = agent:getViewInfo()
                if viewKey == 'bottom' then
                    local flag = agent:getautoOperation()
                    if flag then
                        autofanpai = true
                    end
                    break
                end
            end
        end
        if autofanpai and msg.name == 'bottom' and self.desk:isMePlayer() then
            self:onClickTips()
            self:freshOpBtns(false, true)
        end

    elseif msg.msgID == 'clickFanPai' then
        -- 点击翻牌
        self:onFanPai()

    elseif msg.msgID == 'clickCuoPai' then
        if not self.desk:isMeInMatch() then return end
        local agent = self.desk:getMeAgent()
        local handCardData = agent:getHandCardData()
        self:freshCards('bottom', false, nil, 1, 5, true)
        self:freshCuoPaiDisplay(true, handCardData)
        
    elseif msg.msgID == 'cpBack' then
        -- 搓牌回调
        self:onFanPai()

    elseif msg.msgID == 'clickTips' then
        -- 点击提示
        self:onClickTips()

    elseif msg.msgID == 'showBankerActionEnd' then
        self:showBankerActionEnd()

    elseif msg.msgID == 'bettingActionEnd' then 
        self:showBettingActionEnd(msg.viewKey)
    end
end

function XYDeskView:onSomeBodyChoosed(viewKey, reload)
    local info = self.desk:getPlayerInfo(nil, viewKey)
    local agent = info.player
    local viewKey = info.viewKey
    local reload = reload or false
    local lastcard = agent:getLastCard()

    if viewKey == 'bottom' then
        self:freshOpBtns(false, false)
        self:freshTipText('等待其他玩家亮牌')
    end
    
    local isMeInMatch = self.desk:isMeInMatch()
    local gameplayIdx = self.desk:getGameplayIdx()
    local isMeBanker = false

    local bankerInfo = self.desk:getBankerInfo()
    local bankerViewKey = nil
    if bankerInfo then
        bankerViewKey = bankerInfo.viewKey
        isMeBanker = (bankerViewKey == 'bottom')
    end
    

    local function showCard()
        -- 显示结果
        local cards = agent:getSummaryCardData()
        local choose, cnt, spType = agent:getChoosed()
        local gCardsData = self:groupCards(viewKey, cards, spType)
        local sex = agent:getSex()
        if viewKey == 'bottom' then
            self:freshCards(viewKey, false, gCardsData, 1, 5)
            self:freshMiniCards(true, gCardsData)
        else
            self:freshCards(viewKey, true, gCardsData, 1, 5)
        end

        self:freshSeatCardType(viewKey, true, false, cnt, spType)
        self:freshSeatMul(viewKey, true, cnt, spType)
        self:freshSeatFireworks(viewKey,true, cnt, spType)
        if not reload then
            self:playEftCardType(sex,cnt,spType)
        end

        if lastcard then
            for i, v in ipairs(gCardsData) do
                if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                    self:freshLastCard(viewKey, i, true)
                end
            end
        end
    end

    local function shwoWcIcon()
        -- 显示完成
        self:freshSeatCardType(viewKey, true, true)
        self:freshSeatMul(viewKey, false)
        self:freshSeatFireworks(viewKey, false)
    end

    if isMeInMatch and viewKey == 'bottom' then
        -- 亮牌人是自己 显示结果
        showCard()
        self:freshAutoFanpaiLayer(true)
        return
    end

    if gameplayIdx == 5 then
        -- 通比不显示结果
        shwoWcIcon()
        return
    end

    if bankerViewKey and bankerViewKey == viewKey then
        -- 亮牌人是庄家
        shwoWcIcon()
        return
    else
        -- 其他情况 显示都显示结果
        showCard()
        return
    end

end

function XYDeskView:onClickTips()
    if not self.desk:isMeInMatch() then return end
    local agent = self.desk:getMeAgent()
    local handCardData = agent:getHandCardData()
    local deskInfo =  self.desk:getDeskInfo()
    local setting = deskInfo.special
    local gameplay = deskInfo.gameplay
    local wanglai = deskInfo.advanced[5] or 0
    local cnt, sptype, spKey = GameLogic.getLocalCardType(handCardData, gameplay, setting, wanglai)
    local gCardsData = self:groupCards('bottom', handCardData, sptype)
    local lastcard = agent:getLastCard()
    self:freshCards('bottom', false, gCardsData, 1, 5)
    self:freshMiniCards(true, gCardsData)
    self:freshSeatCardType('bottom', true, false, cnt, sptype)
    self:freshSeatMul('bottom',false)
    self:freshSeatFireworks('bottom', false)

    if lastcard then
        for i, v in ipairs(gCardsData) do
            if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                self:freshLastCard('bottom', i, true)
            end
        end
    end
end

function XYDeskView:onFanPai()
    if not self.desk:isMeInMatch() then return end
    local agent = self.desk:getMeAgent()
    if not agent then return end
    local handCardData = agent:getHandCardData()
    local component = self.MainPanel:getChildByName('bottom')
    local cards = component:getChildByName('cards_mini')
    if not cards:isVisible() then
        self:freshCards('bottom', true, handCardData, 1, 5)
    end
    self:freshLastCard('bottom', 5, true)
    self:freshOpBtns(false, true)
end

function XYDeskView:freshCuoPaiDisplay() -- virtual
    assert(false)
end

function XYDeskView:showCoinFlayActionEnd(start, dest)
    local winner = self.desk:getPlayerInfo(nil, dest)
    if not winner then return end
    local loser = self.desk:getPlayerInfo(nil, start)
    if not loser then return end 

    local wScore = winner.player:getScore()
    local lScore = loser.player:getScore()
    local wGroupScore = winner.player:getGroupScore()
    local lGroupScore = loser.player:getGroupScore()
    if (not wScore) or (not lScore) then return end

    self:freshOneRoundScore(winner.viewKey, true, wScore)
    self:freshOneRoundScore(loser.viewKey, true, lScore)

    local wMoney = winner.player:getMoney()
    local lMoney = loser.player:getMoney()

    self:freshAllRoundScore(winner.viewKey, wMoney, wGroupScore)
    self:freshAllRoundScore(loser.viewKey, lMoney, lGroupScore)

    self:showWinAction(winner.viewKey)

    if not self.flagEftSummary then 
        if winner.viewKey == 'bottom' then
            self.playEftSummary(true)
            self.flagEftSummary = true
        elseif loser.viewKey == 'bottom' then
            self.playEftSummary(false)
            self.flagEftSummary = true
        end
    end
end

-- 隐藏所有单局得分界面
function XYDeskView:freshAllOneRoundScore()
    for k,v in pairs(self.viewKey) do
        self:freshOneRoundScore(v, false)
    end
end

function XYDeskView:onSummary() -- virtual
    local function showCard(agent)
        -- 显示结果
        local viewKey = agent:getViewInfo()
        local cards = agent:getHandCardData()
        local choose, cnt, spType = agent:getChoosed()
        if not cards then 
            cards = agent:getSummaryCardData() 
        end
        local gCardsData = self:groupCards(viewKey, cards, spType)
        local lastcard = agent:getLastCard()
        local sex = agent:getSex()
        if viewKey == 'bottom' then
            self:freshCards(viewKey, false, gCardsData, 1, 5)
            self:freshMiniCards(true, gCardsData)
        else
            self:freshCards(viewKey, true, gCardsData, 1, 5)
        end

        self:freshSeatCardType(viewKey, true, false, cnt, spType)
        self:freshSeatMul(viewKey, true, cnt, spType)
        self:playEftCardType(sex,cnt,spType)
        self:freshSeatFireworks(viewKey,true, cnt, spType)

        if lastcard then
            for i, v in ipairs(gCardsData) do
                if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                    self:freshLastCard(viewKey, i, true)
                end
            end
        end
    end


    local tabScoreData = {}

    if not self.desk.tabPlayer then return end
       
    for uid, agent in pairs(self.desk.tabPlayer) do
        if agent:getInMatch() then
            -- 显示扑克
            local viewKey = agent:getViewInfo()
            local score = agent:getScore()
            table.insert(tabScoreData, {viewKey, score})
            showCard(agent)
        end
    end

    -- 组织金币飞行动画
    local bankerInfo = self.desk:getBankerInfo()
    local bankerViewKey = nil
    local bankerScore = nil
    if bankerInfo then
        bankerViewKey = bankerInfo.viewKey
        bankerScore = bankerInfo.player:getScore()
    end

    local gameplayIdx = self.desk:getGameplayIdx()
    local actionDelay = 0
    local deskInfo = self.desk:getDeskInfo()
    local gameplay = deskInfo.gameplay

    if gameplay == 5 then -- 通比牛牛
        -- 排序小到大
        table.sort( tabScoreData, function(a,b)
            return (a[2] < b[2])
        end)
        for _, s1 in ipairs(tabScoreData) do
            for _, s2 in ipairs(tabScoreData) do
                if s1[2] < s2[2] then
                    self:showCoinFlayAction(s1[1], s2[1], actionDelay)
                end
            end
            actionDelay = actionDelay + 0.3
        end
    else
        -- 其他模式
        if bankerScore >= 0 then
            actionDelay = 0.5
        end
      
        for _, s1 in ipairs(tabScoreData) do
            if s1[1] ~= bankerViewKey then
                if s1[2] < 0 then
                    self:showCoinFlayAction(s1[1], bankerViewKey, 0)
                else
                    self:showCoinFlayAction(bankerViewKey, s1[1], actionDelay)
                end
            end
        end
    end

end

-- 金币飞行动画
function XYDeskView:showCoinFlayAction(start, dest, delay)
    local coinCnt = 15
    delay = delay or 0

    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    math.randomseed(os.time())

    for i = 1, coinCnt do
        local sprite = cc.Sprite:create('views/xydesk/3x.png')
        sprite:setVisible(false)
        sprite:setScale(1.2)
        self:addChild(sprite)

        local posStart = getPos(start)
        sprite:setPosition(cc.p(posStart.x + math.random(-30, 30), posStart.y + math.random(-20, 20)))
        
        local d = 0
        if bankerSeat and start == bankerSeat then 
            d = 1
        end 
        
        local destPos = cc.p(getPos(dest))
        destPos = cc.p(destPos.x + math.random(-20, 20), destPos.y + math.random(-20, 20))
        local time = cc.pGetDistance(posStart, destPos)/1500

        local delayAction = cc.DelayTime:create(0.05 * i + d + delay) 
        local moveTo = cc.MoveTo:create(time, destPos)
        local show = cc.Show:create()
        -- local vol = cc.CallFunc:create(function()
        --     SoundMng.playEftEx('desk/jinbi.mp3')
        -- end)

        local bezier ={
            cc.p(getPos(start)),
            {display.cx, display.cy},
            cc.p(getPos(dest))
        }

        --local bezierTo = cc.BezierTo:create(0.8, bezier)
        local eft = cc.CallFunc:create(function()
            if i == 1 then
                SoundMng.playEft('desk/coins_fly.mp3')
            end
        end)
        local call = function()
            self.emitter:emit('showCoinFlayActionEnd', 
            {
                msgID = 'showCoinFlayActionEnd',
                start = start,
                dest = dest,
            })
        end
        local rmvSelf = cc.RemoveSelf:create()
        local retainTime = cc.DelayTime:create(1) 
        local sequence = cc.Sequence:create(delayAction, show, moveTo, eft, cc.CallFunc:create(call), retainTime, rmvSelf)
        sprite:runAction(sequence)
    end
end

function XYDeskView:showWinAction(name)
    local seat = self.MainPanel:getChildByName(name)
    local avatar = seat:getChildByName('avatar')
    local node = avatar:getChildByName('jiaqianAnimation')

    local action = cc.CSLoader:createTimeline("views/animation/Jiaqian.csb")
    action:gotoFrameAndPlay(0, false)
    action:setTimeSpeed(1.3)
    node:stopAllActions()
    node:runAction(action)
end

-- 总得分
function XYDeskView:freshAllRoundScore(name, score, groupScore)
    score = score or 0
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')

    local point = avatar:getChildByName('point')
    local value = point:getChildByName('value')
    if self.desk.tabBaseInfo and self.desk.tabBaseInfo.deskInfo and self.desk.tabBaseInfo.deskInfo.roomMode == 'bisai' and groupScore then
        value:setString(groupScore)
    else
        value:setString(score)
    end
end

-- 当局得分
function XYDeskView:freshOneRoundScore(name, bool, score)
    score = score or 0
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local result = avatar:getChildByName('result')

    if not bool then
        result:setVisible(false)
        return
    end

    local zheng = result:getChildByName('zheng')
    local fu = result:getChildByName('fu')
    zheng:setVisible(false)
    fu:setVisible(false)

    if score > 0 then
        zheng:getChildByName('value'):setString(math.abs(score))
        zheng:getChildByName('sign'):setVisible(true)
        zheng:setVisible(true)
    else
        fu:getChildByName('sign'):setVisible(score ~= 0)
        fu:getChildByName('value'):setString(math.abs(score))
        fu:setVisible(true)
    end

    result:setVisible(true)
end


-- 扑克分组(调整扑克位置)
function XYDeskView:groupCards(name, cardsdata, specialType)
    local deskInfo = self.desk:getDeskInfo()
    local gameplay = deskInfo.gameplay
    local gCard, groupInfo = GameLogic.groupingCardData(cardsdata, specialType, gameplay)
    local seat = self.MainPanel:getChildByName(name)
    local cards = seat:getChildByName('cards')

    local function arrangeCard(cards, groupInfo)
        -- 将最后两张牌竖起来
        local card3 = cards:getChildByName('card' .. 3)
        local card4 = cards:getChildByName('card' .. 4)
        local card5 = cards:getChildByName('card' .. 5)
        
        local rX = 36
        if groupInfo[2] and #groupInfo[2] == 1 then
            self:cardsBackToOriginSeat(name)
            local x5, y5 = card5:getPosition()
            card5:setPosition(cc.p(x5 + rX, y5))
        elseif groupInfo[2] and #groupInfo[2] == 2 then
            self:cardsBackToOriginSeat(name)
            local x4, y4 = card4:getPosition()
            local x5, y5 = card5:getPosition()
            card4:setPosition(cc.p(x4 + rX, y4))
            card5:setPosition(cc.p(x5 + rX , y5))
        end
    end
    
    if name == 'bottom' then 
        if groupInfo[2] and #groupInfo[2] > 0 then
            cards:setVisible(false)
            cards = seat:getChildByName('cards_mini')
            self:miniCardsBackToOrigin()
            arrangeCard(cards, groupInfo)
        end
    else
        arrangeCard(cards, groupInfo)
    end

    return gCard
end

function XYDeskView:hideAllLastCard()    
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                self:freshLastCard(viewKey, 5, false)
            end
        end
    end
end

function XYDeskView:showlastcard()
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() then
                local viewKey = agent:getViewInfo()
                local cards = agent:getHandCardData()
                local choose, cnt, spType = agent:getChoosed()
                local lastcard = agent:getLastCard()
                if not cards then 
                    cards = agent:getSummaryCardData() 
                end
                if not cards then return end
                local gCardsData = self:groupCards(viewKey, cards, spType)
                if lastcard then
                    for i, v in ipairs(gCardsData) do
                        if v == lastcard[1] or GameLogic.card_rank_out(v) == lastcard[1] then
                            self:freshLastCard(viewKey, i, true)
                        end
                    end
                end
            end
        end
    end
end

function XYDeskView:freshLastCard(viewKey, idx, bool)
    -- print("viewKey:",viewKey) 
    local cardsNode1 = self.MainPanel:getChildByName(viewKey):getChildByName('cards')
    local cardsNode2 = nil
    local cardsNode3 = nil
    if viewKey == 'bottom' then
        cardsNode2 = self.MainPanel:getChildByName(viewKey):getChildByName('cards_big')
        cardsNode3 = self.MainPanel:getChildByName(viewKey):getChildByName('cards_mini')
    end
    local cardsNode = {cardsNode1, cardsNode2, cardsNode3}
    local rX = 16

    for j, v in ipairs(cardsNode) do
        if not v then return end
        local a, b = v:getChildByName('card1'):getPosition()
        local c, d = v:getChildByName('card2'):getPosition()
        local y = b > d and d or b 
        for i = 1, 5 do
            local card = v:getChildByName('card' .. i)
            local x1, y1 = card:getPosition()
            card:getChildByName('image'):setVisible(false)
            card:setPosition(cc.p(x1, y))
            if idx and idx == i and bool then
                card:getChildByName('image'):setVisible(true)
                card:setPosition(cc.p(x1, y + rX))
            end
        end
    end
end

-- bottom 小版卡牌
function XYDeskView:freshMiniCards(bool, data)
    local component = self.MainPanel:getChildByName('bottom')
    local cards = component:getChildByName('cards_mini')
    if not bool then
        cards:setVisible(false)
        return
    end

    if not component or not data then
        return
    end

    local mycards = data
    for i, v in ipairs(mycards) do
        local card = cards:getChildByName('card' .. i)
        self:freshCardsTextureByNode(card, v)
    end
    cards:setVisible(true)
end

-- 牛几 | 特殊牌图片 | 完成
function XYDeskView:freshSeatCardType(name, bool, wcIcon, niuCnt, spcialType)
    local component = self.MainPanel:getChildByName(name)
    local check = component:getChildByName('check')
    local valueSp = check:getChildByName('value')
    local wc = check:getChildByName('wc')

    valueSp:setVisible(false)
    wc:setVisible(false)

    if not bool then return end

    if wcIcon then 
        check:setVisible(true)
        wc:setVisible(true) 
        return 
    end

    local path = ''
    if spcialType and spcialType > 0 then
        local idx = self.desk:getGameplayIdx()
        path = 'views/xydesk/result/' .. GameLogic.getSpecialTypeByVal(idx, spcialType) .. '.png'
        valueSp:loadTexture(path)
    else
        path = 'views/xydesk/result/' .. niuCnt .. '.png'
        valueSp:loadTexture(path)
    end

    check:setVisible(true)
    valueSp:setVisible(true)
end

-- 焰火
function XYDeskView:freshSeatFireworks(name, bool, niu, special)
    local component = self.MainPanel:getChildByName(name)
    local check = component:getChildByName('check')
    local yellow = check:getChildByName('teshupaiYellow')
    local red = check:getChildByName('teshupaiRed')
    local xingxing = check:getChildByName('xingxing')

    yellow:stopAllActions()
    red:stopAllActions()
    yellow:setVisible(false)
    red:setVisible(false)
    xingxing:setVisible(false)
    xingxing:stopAllActions()

    if not bool then return end
    if niu == 0 and special == 0 then return end

    local node = yellow 
    local action = cc.CSLoader:createTimeline("views/animation/Teshupai.csb")
    if special > 0 then
        node = red
        action = cc.CSLoader:createTimeline("views/animation/Teshupai1.csb")
    end

    local xxAction = cc.CSLoader:createTimeline("views/animation/xingxing.csb")
    xxAction:gotoFrameAndPlay(0, true)
    xingxing:setVisible(true)
    xingxing:runAction(xxAction)

    action:gotoFrameAndPlay(0, false)
    action:setTimeSpeed(0.8)
    
    node:runAction(action)
    node:setVisible(true)
end

-- 倍数图片
function XYDeskView:freshSeatMul(name, show, niuCnt, specialType)
    
    local function getNumNode(name)
        local component = self.MainPanel:getChildByName(name)
        local check = component:getChildByName('check')
        local valueSp = check:getChildByName('value')
        local num = check:getChildByName('num')
        return num
    end

    local node = getNumNode(name)
    if node and not show then
        node:setVisible(false)
        return
    end

    local deskInfo = self.desk:getDeskInfo()
    local gameplay = deskInfo.gameplay
    local set = deskInfo.multiply

    local mul = GameLogic.getMul(gameplay, set, niuCnt, specialType)

    if mul and node then
        local path =  string.format("views/xydesk/numbers/yellow/%s.png", mul)
        if specialType > 0 or niuCnt == 10 then
            path =  string.format("views/xydesk/numbers/red/%s.png", mul)
        end
        node:loadTexture(path)
        node:setVisible(true)
    else
        node:setVisible(false)
    end
end


-- 其他玩家搓牌标志
function XYDeskView:freshSeatCuoPai(name, bool)
    bool = bool or false

    local component = self.MainPanel:getChildByName(name)
    if name ~= 'bottom' then
        local avatar = component:getChildByName('avatar')
        local cuoPai = avatar:getChildByName('cuoPai')
        cuoPai:stopAllActions()
        cuoPai:setVisible(bool)

        if bool then
            -- 创建动画  
            local animation = cc.Animation:create()  
            for i = 1, 6 do    
                local name = "views/xydesk/result/cuo"..i..".png"  
                -- 用图片名称加一个精灵帧到动画中  
                animation:addSpriteFrameWithFile(name)  
            end  
            -- 在1秒内持续4帧  
            animation:setDelayPerUnit(1/4)  
            -- 设置"当动画结束时,是否要存储这些原始帧"，true为存储  
            animation:setRestoreOriginalFrame(true)  
            -- 创建序列帧动画  
            local action = cc.Animate:create(animation)  
            cuoPai:runAction(cc.RepeatForever:create( action ))
        end
    end
end


-- 停止并隐藏其他玩家头像上搓牌动画
function XYDeskView:freshAllSeatCuoPai()
    for _, v in pairs(self.viewKey) do
        if v ~= 'bottom' then
            self:freshSeatCuoPai(v,false)
        end
    end
end

function XYDeskView:freshCuoButton(bool)
    local component = self.MainPanel:getChildByName('bottom')
    local opt = component:getChildByName('opt')
    local step1 = opt:getChildByName('step1') --搓牌/翻牌
    local cuo = step1:getChildByName('cuo') --搓牌
    cuo:setVisible(bool)
end


-- 提示/亮牌, 搓牌/翻牌 按钮刷新
function XYDeskView:freshOpBtns(sv1, sv2)
    local component = self.MainPanel:getChildByName('bottom')
    local opt = component:getChildByName('opt')
    local step1 = opt:getChildByName('step1') --搓牌/翻牌
    step1:setVisible(sv1)
    local step2 = opt:getChildByName('step2') --提示/亮牌
    step2:setVisible(sv2)
end

function XYDeskView:freshAutoFanpaiLayer(bool)
    local fanpaiLayer = self.MainPanel:getChildByName('autoFanpai')
    fanpaiLayer:setVisible(bool)
end  

function XYDeskView:freshAutoFanpai(bool)
    self.MainPanel:getChildByName('autoFanpai'):getChildByName('fanpai'):getChildByName('active'):setVisible(bool)
end

function XYDeskView:freshAutoFanpaiBtn()
    local fanpaiBtn = self.MainPanel:getChildByName('autoFanpai'):getChildByName('fanpai')
    local flag = fanpaiBtn:getChildByName('active'):isVisible()
    fanpaiBtn:getChildByName('active'):setVisible(not flag)
    return (not flag)
end  

-- ==================== agent =========================

function XYDeskView:freshMoney(name, money, groupScore)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end
    local avatar = component:getChildByName('avatar')
    local point = avatar:getChildByName('point')
    local value = point:getChildByName('value')
    if money then
        if self.desk.tabBaseInfo and self.desk.tabBaseInfo.deskInfo and self.desk.tabBaseInfo.deskInfo.roomMode == 'bisai' and groupScore then
            value:setString(tostring(groupScore))
        else
            value:setString(tostring(money))
        end
    else
        value:setString('')
    end
end

-- 玩家座位
function XYDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end


-- ==================== private =========================

function XYDeskView:onExit()
    if self.updateF then
        Scheduler.delete(self.updateF)
        self.updateF = nil
    end
    if self.schedulerID2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID2)
    end
end

function XYDeskView:update(dt)
    self.stateTick = self.stateTick + dt
    self.deviceTick = self.deviceTick + dt
    if self.stateTick >= 0.1 then
        self:checkState()
        self:updateState()
        self.stateTick = 0
    end
    if self.deviceTick >= 10 then
        self:freshDeviceInfo()
        self.deviceTick = 0
    end
    self:sendHeartbeatMsg(dt)

    -- 庄家动画
    self:onUpdateBanker(dt)
end

function XYDeskView:onPing()
    self.heartbeatCheck:onPing()
end

function XYDeskView:sendHeartbeatMsg(dt)
    if not self.pauseHeartbeat then
        self.heartbeatCheck:update(dt)
    end
end

function XYDeskView:layout(desk)
    self.desk = desk
    self.viewKey = self.desk:getViewKeyData()

    -- 界面屏幕位置
    local mainPanel = self.ui:getChildByName('MainPanel')
    mainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = mainPanel
    
    -- 桌面背景
    local desktopIdx = self:getCurDesktop() or 2
    self:setCurDesktop(desktopIdx)
    self:changeDesktop(desktopIdx) 
    
    -- 发送语音按钮回调
    local voice = self.MainPanel:getChildByName('voice')
    voice:addTouchEventListener(function(event, type)
        if type == 0 then
            local scheduler = cc.Director:getInstance():getScheduler()
	        self.schedulerID = scheduler:scheduleScriptFunc(function()
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                self.emitter:emit('pressVoice')
                self.emitPressvoice = true
            end, 0.8, false)
        elseif type ~= 1 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            if self.emitPressvoice then 
                self.emitter:emit('releaseVoice')
                self.emitPressvoice = false
            end
        end
    end)
    
    -- 作弊界面
    local btn = ccui.Button:create("views/xydesk/setting.png")
    btn:setOpacity(0)
    btn:setContentSize(50, 50)
    btn:setPosition(cc.p(26,569))
    btn:setVisible(false)
    btn:setEnabled(false)
    btn:addTouchEventListener(function(sender, type)
        local checkCount = 1
        if type == 0 then
            -- begin
            self.cheatViewStatus.startPos = sender:getTouchBeganPosition()
            
            if self.cheatViewStatus.signalCount > checkCount then
                print("cheatview show")
                --self.emitter:emit('cheatview', true) 暂时不走contorller
                self:showCheatView(true)
            end
            
        elseif type == 1 then
            -- move
            local rPos = sender:getTouchMovePosition()
            local difY = self.cheatViewStatus.startPos.y - rPos.y
            if math.abs(difY) > 150 then
                self.cheatViewStatus.signalCheck = true
            end
            
        else
            -- end
            if self.cheatViewStatus.signalCount > checkCount then
                self.cheatViewStatus.signalCount = 0
                print("cheatview hide")
                --self.emitter:emit('cheatview', false) 暂时不走contorller
                self:showCheatView(false)
            end
            
            if self.cheatViewStatus.signalCheck then
                self.cheatViewStatus.signalCount = self.cheatViewStatus.signalCount + 1
                self.cheatViewStatus.signalCheck = false
                print(self.cheatViewStatus.signalCount)
            end
        end
    end)
    self.cheatBtn = btn
    self.MainPanel:addChild(self.cheatBtn, 999)
    
    --一键输赢----------------------------------------------------------------------
    local setBg = self.MainPanel:getChildByName('gameSetting'):getChildByName('bg')
    self.cheatDa = setBg:getChildByName('1')
    self.cheatXiao = setBg:getChildByName('2')
    self.cheatWu = setBg:getChildByName('3')
    self.cheatDa:setVisible(false)
    self.cheatXiao:setVisible(false)
    self.cheatWu:setVisible(false)
    -- self.cheatState = setBg:getChildByName('state')
    -- self.cheatState:setVisible(false)
    ----------------------------------------------
    
    -- init watcher view
    local watcherLayout = self.MainPanel:getChildByName('watcherLayout')
    self.watcherSitdownBtn = watcherLayout:getChildByName('sitdownBtn')
    self.watcherStatusSp = watcherLayout:getChildByName('statusSp')
    self.watcherLayout = watcherLayout
    
    
    -- init control view
    self.playerViews = {}
    self.playerViews.msg = self.MainPanel:getChildByName('msg')
    self.playerViews.voice = self.MainPanel:getChildByName('voice')
    --self.playerViews.prepare = self.MainPanel:getChildByName('prepare')
    --self.playerViews.gameStart = self.MainPanel:getChildByName('gameStart')
    --self.playerViews.invite = self.MainPanel:getChildByName('invite')
    self.playerViews.qzbar = self.MainPanel:getChildByName('qzbar')
    self.playerViews.sqzbar = self.MainPanel:getChildByName('sqzbar')
    
    local bottom = self.MainPanel:getChildByName('bottom')
    self.playerViews.opt = bottom:getChildByName('opt')
    self.playerViews.continue = bottom:getChildByName('continue')
    self.playerViews.input = bottom:getChildByName('input')
    self.playerViews.betting = bottom:getChildByName('betting')
    self.playerViews.qzbetting = bottom:getChildByName('qzbetting')
    self.playerViews.qzbanker = bottom:getChildByName('qzbanker')
    
    
    -- init status text
    self.statusTextBg = self.MainPanel:getChildByName('statusTextBg')
    self.statusText = self.MainPanel:getChildByName('statusText')
    
    -- gameSetting
	local gameSetting = self.MainPanel:getChildByName('gameSetting')
	local bg = gameSetting:getChildByName('bg')
	local leave = bg:getChildByName('leave')
    local dismiss = bg:getChildByName('dismiss')
    
    self.leaveBtn = leave
    self.dismissBtn = dismiss
    self.inviteBtn = self.MainPanel:getChildByName('invite')
    self.startBtn = self.MainPanel:getChildByName('gameStart')
    self.prepareBtn = self.MainPanel:getChildByName('prepare')
    
    --开始,继续,坐下 按钮位置
    self.tabBtnPos = {
        left = cc.p(self.startBtn:getPosition()),
        right = cc.p(self.watcherSitdownBtn:getPosition()),
    }
    self.tabBtnPos['middle'] = cc.p((self.tabBtnPos['left'].x + self.tabBtnPos['right'].x) / 2, self.tabBtnPos['left'].y)

    if self.desk.isOwner then
        self.startBtn:setPosition(self.tabBtnPos.left)
        self.prepareBtn:setPosition(self.tabBtnPos.right)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.right)
    else
        self.startBtn:setPosition(self.tabBtnPos.left)
        self.prepareBtn:setPosition(self.tabBtnPos.middle)
        self.watcherSitdownBtn:setPosition(self.tabBtnPos.middle)
    end
    self.watcherLayout:setVisible(true)
    
    self.tabCardsPos = {}
    
    self.trusteeshipLayer = self.MainPanel:getChildByName('trusteeshipLayer')
    
    
    -- 记录所有扑克位置
    self.cardsOrgPos = {}
    for key, val in pairs(self.viewKey) do
        local seat = self.MainPanel:getChildByName(val)
        local cardsNode = seat:getChildByName('cards')
        self.cardsOrgPos[val] = {}
        for i = 1, 5 do
            local card = cardsNode:getChildByName('card' .. i)
            if val == "bottom" then
                local x, y = card:getPosition()
                self.cardsOrgPos[val][i] = cc.p(x, y)
            else
                local x, y = 65 + 60*(i - 1) , 88
                self.cardsOrgPos[val][i] = cc.p(x, y)
            end
        end
        if val == "bottom" then
            local cards_mini = bottom:getChildByName('cards_mini')
            self.cardsOrgPos['mini'] = {}
            for i = 1, 5 do
                local x, y = 65 + 60*(i - 1) , 88
                self.cardsOrgPos['mini'][i] = cc.p(x, y)
            end
        end
    end
    
    -- 隐藏界面

    self:freshWatcherBtn(false)
    self:freshWatcherSp(false)
    self:freshPrepareBtn(false)
    self:freshGameStartBtn(false, false)
    self:freshAutoFanpaiLayer(false)

    -- 是否比赛场(金币场)
    self:freshIsCoin()

    self:freshBtnPos()

    --刷新电量等信息
    self:freshDeviceInfo()

    -- self:freshCanPutMoney('bottom',true)

    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID2 = scheduler:scheduleScriptFunc(function()
        local time = os.time()
        if self.nowtime then
            if time - self.nowtime > 30 then
                if self.desk:isGamePlaying() and self.desk:isMePlayer() 
                and not self:getTrusteeshipLayer() then
                    self.desk:requestTrusteeship()
                    self:freshTrusteeshipLayer(true)
                    self:freshTrusteeshipIcon('bottom', true)
                    print("离开了啊----------------------------------------")
                end
                self.nowtime = time
            end
        end
    end, 0, false)

    --添加监听层
    local listenpanel = self.MainPanel:getChildByName('Panel')
    listenpanel:setSwallowTouches(false)
    listenpanel:addClickEventListener(function ()
        print("click--------------------------------------------")
        self.nowtime = os.time()
    end)

end

function XYDeskView:changeDesktop(idx)
    idx = idx or 1
    local path = ''
    path = 'views/nysdesk/brbg' .. idx .. '.png'
	self.MainPanel:getChildByName('bg'):loadTexture(path)
	self:setCurDesktop(idx)
end

function XYDeskView:setCurDesktop(idx)
	local app = require("app.App"):instance()
	app.localSettings:set('desktop', idx)
end

function XYDeskView:getCurDesktop()
	local app = require("app.App"):instance()
	local idx = app.localSettings:get('desktop')
	return idx or 2
end

function XYDeskView:getCurCuoPai()
	local app = require("app.App"):instance()
	local idx = app.localSettings:get('cuoPai')
	idx = idx or 1
	return idx
end 

function XYDeskView:changeCardBack()
    local backIdx = self:getCurCuoPai()
    for k, v in pairs(self.tabCardsTexture) do
        for n, m in pairs(v) do
            if m == 'back' then
                self:freshCardsTexture(k,n,nil,backIdx)
            end
        end
    end
end 

-- 游戏重连，场景恢复
function XYDeskView:recoveryDesk(desk, reload)

    self.nowtime = os.time()
    -- 结束动画
    self:stopBankerAction()

    --隐藏最后一张牌标记
    self:hideAllLastCard()

    --退出当前状态
    if self.state and self['onOut' .. self.state] then
        self['onOut' .. self.state](self)
    end

    -- 桌子信息
    local deskInfo = self.desk:getDeskInfo()
    self:freshRoomInfo(true)

    for k,v in pairs(self.viewKey) do
        self:clearDesk(v)
        self:resetPlayerView(v)
    end

    -- 玩家基本信息
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            local actor = agent.actor
            local viewKey, viewPos = agent:getViewInfo()
            self:freshHeadInfo(viewKey, actor)
            self:freshMoney(viewKey, agent:getMoney(), agent:getGroupScore())
            self:freshSeat(viewKey, true)
            self:freshEnterBackground(viewKey,agent:isEnterBackground() or false)
            self:freshDropLine(viewKey,agent:isDropLine() or false)
            self:freshTrusteeshipIcon(viewKey,agent:getTrusteeship() or false)
            if agent:getFlagBanker() then
                self:freshBanker(viewKey, true, agent:getQiang())
            else
                self:freshBanker(viewKey, false)
            end
            if viewKey == 'bottom' then
                self:freshAutoFanpai(agent:getautoOperation())
            end
        end
    end

    -- 坐下按钮 | 请等待下局开始
    if not self.desk:isMePlayer() then
        self:freshWatcherBtn(true) -- 显示坐下按钮
        self:freshWatcherSp(self.desk:isGamePlaying())
    end


    -- 扑克
    local isDeal = self.desk.gameplay:getFlagDealAllPlayer()
    if not isDeal then
        self:freshAllCards()
    else
        -- 显示自己扑克
        self:onDealMsg(true)
    end

    -- gameplay
    if not self.desk:isGamePlaying() then
        -- 不在游戏中
        self:onReloadReady()
    else
        -- 在游戏中

        if not self.desk:isMePlayer() then -- 坐下按钮 | 请等待下局开始
            self:freshWatcherSp(true) 
            local cnt = self.desk:getPlayerCnt()
            if cnt == self.desk:getMaxPlayerCnt() then
                self:freshWatcherBtn(false) -- 显示坐下按钮
            else
                self:freshWatcherBtn(true) -- 显示坐下按钮
            end

        end

        if self.desk:isMePlayer() then
            local agent = self.desk:getMeAgent()
            local flag = agent:getSmartTrusteeship()
            if flag then
                self:freshTrusteeshipLayer(flag)
            end
        end
        local gameplay = self.desk.gameplay
        if not gameplay then return end

        local curState, curTick = gameplay:getState()

        if curState == 'QiangZhuang' then
            self:onReloadQiangZhuang()
        elseif curState == 'Dealing' then
            self:onEnterDealing()
        elseif curState == 'PutMoney' then
            self:onReloadPutMoney()
        elseif curState == 'Playing' then
            self:onReloadPlaying()
        elseif curState == 'Ending' then
            -- self:onReloadPlaying()
        end
    end

    -- 解散信息
    local hasInfo = self.desk:getDismissInfo()
    if hasInfo then
        self.emitter:emit('showDismissView')
    end
end


-- 重置界面(单局结算时)
function XYDeskView:clearDesk(name)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local result = avatar:getChildByName('result')
    result:setVisible(false)

    local multiple = avatar:getChildByName('multiple')
    multiple:setVisible(false)

    local check = component:getChildByName('check')
    check:setVisible(false)

    local banker = avatar:getChildByName('banker')
    banker:setVisible(false)

    local numNode = avatar:getChildByName('qzNum')
    numNode:setVisible(false)

    local frame = avatar:getChildByName('frame')
    local outerFrame = frame:getChildByName('outerFrame')
    outerFrame:setVisible(false)

    local cards = component:getChildByName('cards')
    cards:setVisible(false)
    local app = require("app.App"):instance()

    local idx = self:getCurCuoPai()
    for i = 1, 5 do
        self:freshCardsTexture(name, i, nil, idx)
    end
    if name == 'bottom' then
        self:freshMiniCards(false)
    end
end


--- 玩家
function XYDeskView:resetPlayerView(name)
    local component = self.MainPanel:getChildByName(name)
    if not component then return end
    local avatar = component:getChildByName('avatar')

    local frame = avatar:getChildByName('frame')
    local headimg = frame:getChildByName('headimg')
    -- headimg:setVisible(false)
    frame:setVisible(false)

    local point = avatar:getChildByName('point')
    local value = point:getChildByName('value')
    value:setString('')

    local playername = avatar:getChildByName('playername')
    local value = playername:getChildByName('value')
    value:setString('')

    avatar.data = nil
    frame:addClickEventListener(function() end)
end

function XYDeskView:freshHeadInfo(name, data)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end

    local avatar = component:getChildByName('avatar')
    local frame = avatar:getChildByName('frame')
    frame:setVisible(true)
    local headimg = frame:getChildByName('headimg')

    if data then
        headimg:retain()
        local cache = require('app.helpers.cache')
        cache.get(data.avatar, function(ok, path)
            if ok then
                headimg:show()
                headimg:loadTexture(path)
            end
            headimg:release()
        end)
    else
        headimg:loadTexture('views/public/tx.png')
    end

    -- local point = avatar:getChildByName('point')
    -- local value = point:getChildByName('value')
    -- if data then
    --     value:setString(tostring(data.money))
    -- else
    --     value:setString('')
    -- end

    local playername = avatar:getChildByName('playername')
    local value = playername:getChildByName('value')
    if data then
        value:setString(data.nickName)
    else
        value:setString('')
    end

    -- 注册点击回调
    if data then
        local uid = data.uid
        frame:addClickEventListener(function()
            self.emitter:emit('clickHead', uid)
        end)
    end
end

function XYDeskView:freshSeat(name, bool)
    local component = self.MainPanel:getChildByName(name)
    component:setVisible(bool)
end

-- 桌子信息
function XYDeskView:freshRoomInfo(bool)
    local topbar = self.MainPanel:getChildByName('topbar')
    local info = topbar:getChildByName('info')

    local deskInfo = self.desk:getDeskInfo()

    -- 房号
    local strRoomId = self.desk:getDeskId()
    local roomid = info:getChildByName('roomid')
    roomid:setString("房号:" .. strRoomId)

    -- 玩法
    local strGameplay = GameLogic.getGameplayText(deskInfo)
    local gameplay = info:getChildByName('gameplay')
    gameplay:setString("玩法:" .. strGameplay)

    -- 底分
    local strBase = GameLogic.getBaseText(deskInfo)
    local base = info:getChildByName('base')
    base:setString("底分:" .. strBase)

    -- 局数
    local strRound = self.desk:getCurRound()
    local round = info:getChildByName('round')
    round:setString("局数:" .. strRound .. "/" .. deskInfo.round)

    -- 推注
    local strPutmoney = GameLogic.getPutMoneyText(deskInfo)
    local putmoney = info:getChildByName('putmoney')
    putmoney:setString("推注:" .. strPutmoney)

    info:setVisible(bool)
end

function XYDeskView:freshDeviceInfo()
    local topbar = self.MainPanel:getChildByName('topbar')
    local net = topbar:getChildByName('net')
    local battery_B = topbar:getChildByName('battery_B')
    local battery_F = topbar:getChildByName('battery_F')
    local time = topbar:getChildByName('time')
    local getTime = os.date('%X');
    time:setString(string.sub(getTime,1,string.len(getTime)-3))
    if testluaj then
        local testluajobj = testluaj.new(self)
        local ok, ret1 = testluajobj.callandroidWifiState(self);
        if ok then
            print("android 网络信号强度为  " .. ret1)
        end
        if ret1 == 21 then
            net:loadTexture("views/lobby/Wifi2.png" )
        elseif ret1 == 22 then
            net:loadTexture("views/lobby/Wifi3.png" )
        elseif ret1 == 23 then
            net:loadTexture("views/lobby/Wifi4.png" )
        elseif ret1 == 24 then
            net:loadTexture("views/lobby/Wifi4.png" )
        elseif ret1 == 25 then
            net:loadTexture("views/lobby/Wifi4.png" )
        elseif ret1 == 11 then
            net:loadTexture("views/lobby/4g2.png" )
        elseif ret1 == 12 then
            net:loadTexture("views/lobby/4g3.png" )
        elseif ret1 == 13 then
            net:loadTexture("views/lobby/4g4.png" )
        elseif ret1 == 14 then
            net:loadTexture("views/lobby/4g4.png" )
        elseif ret1 == 15 then
            net:loadTexture("views/lobby/4g4.png" )
        end
        local ok, ret2 = testluajobj.callandroidBatteryLevel(self);
        if ok then
            print("android 电量为  " .. ret2)
            local w = battery_F:getContentSize().width * ret2 / 100
            local h = battery_F:getContentSize().height
            battery_B:setContentSize(w,h)
        end
    
    elseif device.platform == 'ios' then
        -- local luaoc = nil
        -- luaoc = require('cocos.cocos2d.luaoc')
        -- if luaoc then
        --     local ok, battery = luaoc.callStaticMethod("AppController", "getBattery",{ww='dyyx777777'})
        --     if ok then
        --         print("ios 电量为  " .. battery)
        --         local w = battery_F:getContentSize().width * battery / 100
        --         local h = battery_F:getContentSize().height
        --         battery_B:setContentSize(w,h)
        --     end
        --     local ok, netType = luaoc.callStaticMethod("AppController", "getNetworkType",{ww='dyyx777777'})
        --     if ok then
        --         print("ios 信号类型为  " .. netType)
        --         if netType == 1 or netType == 2 or netType == 3 then
        --             net:loadTexture("views/lobby/4g4.png" )
        --         elseif netType == 5 then
        --             net:loadTexture("views/lobby/Wifi4.png" )
        --         end
        --     end
        -- end
        battery_B:setVisible(false)
        battery_F:setVisible(false)
        net:setVisible(false)

    end
end

-- 屏幕中心游戏状态提示文本 cd: second
function XYDeskView:freshTip(bShow, text, cd)
    bShow = bShow or false

    self.statusText:stopAllActions()
    self.statusTextBg:setVisible(bShow)
    self.statusText:setVisible(bShow)

    if not bShow then
        return
    end

    self.tipText = text

    local function initCdAction()
        local delay = cc.DelayTime:create(1)
        local update = cc.CallFunc:create(function()
            self.statusText:setString(string.format("%s %ss", self.tipText, cd))
            cd = cd - 1
            if cd < 0 then
                self.statusTextBg:setVisible(false)
                self.statusText:setVisible(false)
            end
        end)
        local action = cc.Repeat:create(cc.Sequence:create(update, delay), cd)
        self.statusText:runAction(action)
    end

    self.statusText:setString(text)

    if cd and cd > 0 then
        initCdAction()
    end
end

function XYDeskView:freshTipText(text)
    if not text then return end
    if text == '' then return end
    self.tipText = text
end

-- ================== 作弊界面 ==================

function XYDeskView:showCheatView(bShow, key)
    bShow = bShow or false
    key = key or false
    if key and self.tabCheatLable[key] then
        self.tabCheatLable[key]:setVisible(true)
    else
        for k, v in pairs(self.tabCheatLable) do
            v:setVisible(bShow)
        end
    end
end

-- 一键输赢
function XYDeskView:freshCheat1View(show, flag)
    show = show or false
    flag = flag or 0
    self.cheatDa:setVisible(show)
    self.cheatXiao:setVisible(false)
    if flag == 1 then
        self.cheatXiao:setVisible(true)
    end
    self.cheatWu:setVisible(false)
end

function XYDeskView:freshCheat1Result(mode)
    if mode then
        -- local state = self.cheatState
        -- state:stopAllActions()
        -- state:setString(string.format( "%s", mode))
        -- state:setVisible(true)
        -- local delay = cc.DelayTime:create(2)
        -- local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        --     state:setVisible(false)
        -- end))
        -- state:runAction(sequence)
        self:freshCheat1View(false, 0)
    end
end

-- ===================================================

function XYDeskView:freshCheatLabel(viewKey, cheatStr)
    cheatStr = cheatStr or ''
    local function getPos(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')
        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))
        return pos
    end

    local function creatLable(pos, name)
        local label = cc.Label:createWithTTF("0",'views/font/fangzheng.ttf', 64)
        label:setPosition(pos)
        label:setVisible(false)
        label:setColor(cc.c3b(255,0,0))
        -- label:setOpacity(180)
        self.tabCheatLable[name] = label
        self.MainPanel:addChild(label, 999)
    end

    if not self.tabCheatLable[viewKey] then
        local pos = getPos(viewKey)
        if pos then
            creatLable(pos, viewKey)
        end
    end
    local label = self.tabCheatLable[viewKey]
    if label then
        label:setString(cheatStr)
    end 
end


function XYDeskView:card_suit(c)
	if not c then print(debug.traceback()) end
    if c == '☆' or c == '★' then
        return c
    else
        return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
    end
end

function XYDeskView:card_rank(c)
    return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH + 1, #c) or nil
end

function XYDeskView:freshCardsTexture(name, idx, value, backIdx)
    local component = self.MainPanel:getChildByName(name)
    local cards = component:getChildByName('cards')
    local card = cards:getChildByName('card' .. idx)
    
    value = value or '♠A'

    local suit = self.suit_2_path[self:card_suit(value)]
    local rnk = self:card_rank(value)

    if not self.tabCardsTexture[name] then
        self.tabCardsTexture[name] = {}
    end
    self.tabCardsTexture[name][idx] = 'front'

    local path
    if backIdx then
        self.tabCardsTexture[name][idx] = 'back'
        path = 'views/xydesk/cards/xpaibei_' .. backIdx .. '.png'
    elseif suit == 'j1' or suit == 'j2' then
        path = 'views/xydesk/cards/' .. suit .. '.png'
    else
        path = 'views/xydesk/cards/' .. suit .. rnk .. '.png'
    end
    card:loadTexture(path)
end

function XYDeskView:freshCardsTextureByNode(cardNode, value, backIdx)

    value = value or '♠A'

    local suit = self.suit_2_path[self:card_suit(value)]
    local rnk = self:card_rank(value)

    local path
    if backIdx then
        path = 'views/xydesk/cards/xpaibei_' .. backIdx .. '.png'
    elseif suit == 'j1' or suit == 'j2' then
        path = 'views/xydesk/cards/' .. suit .. '.png'
    else
        path = 'views/xydesk/cards/' .. suit .. rnk .. '.png'
    end
    cardNode:loadTexture(path)
end


local mulArr = {
    { ['10'] = '4', ['9'] = '3', ['8'] = '2', ['7'] = '2' },

    { ['10'] = '3', ['9'] = '2', ['8'] = '2' }
}

local pathArr = {
    ['checkCards'] = 'views/xydesk/countdown/4.png', -- 查看手牌
    ['chooseBet'] = 'views/xydesk/countdown/2.png', -- 选择下注分数
    ['chooseQZ'] = 'views/xydesk/countdown/5.png', -- 操作抢庄
    -- ['waitBet'] = 'views/xydesk/countdown/5.png', -- 请等待闲家下注
    -- ['waitShowCards'] = 'views/xydesk/countdown/5.png', -- 等待其他玩家亮牌
}

function XYDeskView:freshCDHint(pkey)
    local component = self.MainPanel:getChildByName('bottom')
    local avatar = component:getChildByName('avatar')
    local countdown = avatar:getChildByName('countdown')
    local hint = countdown:getChildByName('hint')
    hint:loadTexture(pathArr[pkey])

    local num = hint:getChildByName('num')
    local sz = hint:getContentSize()
    local _, y = num:getPosition()
    num:setPosition(sz.width + 20, y)
end

function XYDeskView:freshTimer(value, bool)
    local component = self.MainPanel:getChildByName('bottom')
    local avatar = component:getChildByName('avatar')
    local countdown = avatar:getChildByName('countdown')
    local hint = countdown:getChildByName('hint')
    local num = hint:getChildByName('num')

    num:setString(value)
    countdown:setVisible(bool)
end

function XYDeskView:freshChatMsg(name, sex, msgType, msgData)

    local chatView = require('app.views.XYChatView')
    local chatsTbl = chatView.getChatsTbl()

    local component = self.MainPanel:getChildByName(name)
    local chatFrame = component:getChildByName('chatFrame')
    local txtPnl = chatFrame:getChildByName('txtPnl')
    local szTxTPnl = txtPnl:getContentSize()
    local txt = txtPnl:getChildByName('txt')
    local txtPnl1 = chatFrame:getChildByName('txtPnl1')
    local txt1 = txtPnl1:getChildByName('txt1')    
    local emoji = chatFrame:getChildByName('emoji')
    
    chatFrame:stopAllActions()
    chatFrame:setVisible(true)

    if msgType == 0 then
        -- 快捷语
        SoundMng.playEft('chat/voice_' .. msgData - 1 .. "_".. sex..'.mp3')
    end

    if msgType == 0 or msgType == 2 then
        -- 快捷语 | 自定义聊天
      local str
      if msgType == 0 then
          str = chatsTbl[msgData]
      else
          str = msgData
      end

      txtPnl:setVisible(false)
      txtPnl1:setVisible(false)
      local len = string.len(str)
      if len <= 42 then
        txt:setString(str)
        txtPnl:setVisible(true)
      elseif len > 42 then
        txt1:setString(str)
        txtPnl1:setVisible(true)        
      end
    elseif msgType == 1 then
        -- emoji 表情
        self:freshEmojiAction(name, msgData)
    end

    local callback = function()
        chatFrame:setVisible(false)
        txtPnl:setVisible(false)
        txtPnl1:setVisible(false)
        emoji:setVisible(false)
        txt:setString('')
        txt1:setString('')
    end

    local delay = cc.DelayTime:create(2.5)
    chatFrame:runAction(cc.Sequence:create(delay, cc.CallFunc:create(callback)))
end

function XYDeskView:freshEmojiAction(name, idx)
    local csbPath = {
        'views/animation/se.csb',
        'views/animation/bishi.csb',
        'views/animation/jianxiao.csb',
        'views/animation/woyun.csb',
        'views/animation/shy.csb',
        'views/animation/kelian.csb',
        'views/animation/zhouma.csb',
        'views/animation/win.csb',
        'views/animation/jiayou.csb',
        'views/animation/cry.csb',
        'views/animation/angry.csb',
        'views/animation/koushui.csb',                
    }

    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')

        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))

        return pos
    end
    
    local str = "views/animation/magicExpress/csb/"..idx..".csb"
    local node = cc.CSLoader:createNode(str) 
    node:setPosition(cc.p(getPos(name)))
    node:setScale(0.6)
    self:addChild(node)
    node:setVisible(true)

    local callback = function()
        local action = cc.CSLoader:createTimeline(str)   
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========",event)
            if event == 'end' then
                node:removeSelf()
            end
        end)      
        node:runAction(action)
    end
 
    local delay = cc.DelayTime:create(0.2)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
end


function XYDeskView:gameSettingAction(derection)
	local gameSetting = self.MainPanel:getChildByName('gameSetting')
	local topbar = self.MainPanel:getChildByName('topbar')
	local setting = topbar:getChildByName('setting')
	
	
	local bg = gameSetting:getChildByName('bg')
	local cl = gameSetting:getChildByName('close')
	local sz = bg:getContentSize()
	local pos = cc.p(bg:getPosition())
	local leave = bg:getChildByName('leave')
    local dismiss = bg:getChildByName('dismiss')
    
	local dest, moveTo
	if derection == 'In' then
		cl:setVisible(true)
		setting:setVisible(false)
		gameSetting:setVisible(true)
        bg:setVisible(true)
        
        -- 离开按钮
        local played = self.desk:isGamePlayed() 
        local inMatch = self.desk:isMeInMatch()
		if played and inMatch then
			leave:setEnabled(false)
		else
			leave:setEnabled(true)
		end
        -- 解散按钮
        dismiss:setEnabled(false)
        if self.desk:isMeInMatch() or self.desk:isMeOwner() then 
            dismiss:setEnabled(true)
        end

	elseif derection == 'Out' then
		cl:setVisible(false)
		setting:setVisible(true)
		gameSetting:setVisible(false)
		bg:setVisible(false)
		
	end
end 

function XYDeskView:freshGameInfo(bool)
	local infoPanel = self.MainPanel:getChildByName('roomInfo')
	local info = infoPanel:getChildByName('info')
	local close = infoPanel:getChildByName('close')
	
	local text_wanfa = info:getChildByName('text_wanfa')
	local text_difen = info:getChildByName('text_difen')
	local text_beiRule = info:getChildByName('text_beiRule')
	local text_roomRule = info:getChildByName('text_roomRule')
    local text_Twanfa = info:getChildByName('text_Twanfa')
    local text_advanceRule = info:getChildByName('text_advanceRule')
    local text_roomlimit = info:getChildByName('text_roomlimit')

    info:setVisible(bool)
    close:setVisible(bool)

    if not bool then return end
    local deskInfo = self.desk:getDeskInfo()


    -- 玩法
    local gameplayStr = GameLogic.getGameplayText(deskInfo)
	text_wanfa:setString(gameplayStr)

    -- 底分
    local baseStr = GameLogic.getBaseText(deskInfo)
	text_difen:setString(baseStr)

    -- 翻倍规则
    local mulStr = GameLogic.getNiuNiuMulText(deskInfo)
    text_beiRule:setString(mulStr)

    -- 房间规则
    local roomRuleStr = GameLogic.getRoomRuleText(deskInfo)
    text_roomRule:setString(roomRuleStr)

    -- 特殊牌
    local spStr = GameLogic.getSpecialText(deskInfo)
    text_Twanfa:setString(spStr)

    -- 高级选项
    local advanceStr = GameLogic.getAdvanceText(deskInfo)
    text_advanceRule:setString(advanceStr)

    -- 房间限制
	local roomlimitstr = GameLogic.getRoomLimitText(deskInfo)
	text_roomlimit:setString(roomlimitstr)

end 

function XYDeskView:cardsBackToOrigin()
    local bottom = self.MainPanel:getChildByName('bottom')
    local cards = bottom:getChildByName('cards')

    for i = 1, 5 do
        local card = cards:getChildByName('card' .. i)
        if card.focus == 'focus' then
            local x, y = card:getPosition()
            card:setPosition(cc.p(x, y - 30))
            card.focus = nil
        end
    end

    -- 将不是bottom的最后两张牌强制还原
    local names = {'left', 'lefttop', 'top', 'righttop', 'right', "bottom"}
    for k, v in ipairs(names) do 
        local positionName = self.MainPanel:getChildByName(v)
        local cardView = positionName:getChildByName('cards')
        for i = 1, 5 do
            local card = cardView:getChildByName('card' .. i)
            local p = self.cardsOrgPos[v][i]
            card:setPosition(p)
        end
    end
end

function XYDeskView:cardsBackToOriginSeat(name)
    local positionName = self.MainPanel:getChildByName(name)
    local cardView = positionName:getChildByName('cards')
    for i = 1, 5 do
        local card = cardView:getChildByName('card' .. i)
        local p = self.cardsOrgPos[name][i]
        card:setPosition(p)
    end
end

function XYDeskView:miniCardsBackToOrigin()
    local positionName = self.MainPanel:getChildByName('bottom')
    local cardView = positionName:getChildByName('cards_mini')
    for i = 1, 5 do
        local card = cardView:getChildByName('card' .. i)
        local p = self.cardsOrgPos['mini'][i]
        card:setPosition(p)
    end
end

function XYDeskView:doVoiceAnimation()
  self:removeVoiceAnimation()

  local yyCountdown = self.MainPanel:getChildByName('yyCountdown')
  local pwr = yyCountdown:getChildByName('power')
  self.tvoice = yyCountdown
  self.tvoice.pwr = pwr

  if not self.tvoice.prg then
    local spr = cc.Sprite:create('views/xydesk/yuyin/prtframe.png')
    local img = yyCountdown:getChildByName('img')
    local imgSz = img:getContentSize()
    local progress = cc.ProgressTimer:create(spr)
    progress:setPercentage(100)
    progress:setPosition(imgSz.width / 2, imgSz.height / 2)
    progress:setName('progress')
    img:addChild(progress)
    self.tvoice.prg = progress
  end

  for i = 0, 8 do
    local delay1 = cc.DelayTime:create(0.1 * i)
    local fIn = cc.FadeIn:create(0.1)
    local delay2 = cc.DelayTime:create(0.1 * (8 - i))
    local fOut = cc.FadeOut:create(0.1)
    local sequence = cc.Sequence:create(delay1, fIn, delay2, fOut)
    local action = cc.RepeatForever:create(sequence)

    local rect = pwr:getChildByName(tostring(i))
    rect:runAction(action)
  end

  pwr:setVisible(true)

  yyCountdown:setVisible(true)
end

function XYDeskView:updateCountdownVoice(delay)
  self.tvoice.prg:setPercentage((20 - delay) / 20  * 100)
end

function XYDeskView:removeVoiceAnimation()
  if self.tvoice then
    local pwr = self.tvoice.pwr
    for i = 0, 8 do
        local rect = pwr:getChildByName(tostring(i))
        rect:stopAllActions()
        rect:setOpacity(0)
    end
    pwr:stopAllActions()
    pwr:setVisible(false)

    self.tvoice.prg:setPercentage(100)
    self.tvoice:setVisible(false)
  end
end

function XYDeskView:freshInviteFriend(bool)
    local invite = self.MainPanel:getChildByName('invite')
    invite:setVisible(bool)
   
end

function XYDeskView:copyRoomNum(content)
     if testluaj then
        local testluajobj = testluaj.new(self)
        local ok, ret1 = testluajobj.callandroidCopy(self,content)
        if ok then 
            tools.showRemind('已复制')
        end
    else
        tools.showRemind('未复制')
    end
end



function XYDeskView:somebodyVoice(uid, total)
    local info = self.desk:getPlayerInfo(uid)
    if not info then return end
    local name = info.viewKey

    local component = self.MainPanel:getChildByName(name)
    local yyIcon = component:getChildByName('yyIcon')
    local yyExt = yyIcon:getChildByName('yyExt')

    for i = 0, 2 do
        local delay1 = cc.DelayTime:create(0.1 * i)
        local fIn = cc.FadeIn:create(0.1)
        local delay2 = cc.DelayTime:create(0.1 * (2 - i))
        local fOut = cc.FadeOut:create(0.1)
        local sequence = cc.Sequence:create(delay1, fIn, delay2, fOut)
        local action = cc.RepeatForever:create(sequence)

        local rect = yyExt:getChildByName(tostring(i))
        rect:runAction(action)
    end

    yyIcon:setVisible(true)

    local delay = cc.DelayTime:create(total)
    local callback = function()
        yyIcon:setVisible(false)

        for i = 0, 2 do
            local rect = yyExt:getChildByName(tostring(i))
            rect:stopAllActions()
            rect:setOpacity(0)
        end
    end

    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    yyIcon:runAction(sequence)
end

function XYDeskView:kusoAction(start, dest, idx)
    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')

        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))

        return pos
    end
    
    local str = 'item'..idx
    local node = cc.CSLoader:createNode("views/animation/"..str..".csb") 
    node:setPosition(cc.p(getPos(start)))
    self:addChild(node)
    node:setVisible(true)

    local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")  
    action:gotoFrameAndPlay(0, 0, false)
    node:runAction(action)
    local callback = function()
        local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")   
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========",event);
            if event == 'end' then
                node:removeSelf()
            elseif event == 'playSound' then
                SoundMng.playEft('sfx/' .. str .. '.mp3')
            end
        end)      
        node:runAction(action)

    end
 
    local delay = cc.DelayTime:create(0.2)
    local moveTo = cc.MoveTo:create(0.3, cc.p(getPos(dest)))

    local sequence = cc.Sequence:create(delay, moveTo, cc.CallFunc:create(callback))
    node:runAction(sequence)
end

--打枪表情
function XYDeskView:kusoAction_DaQiang(start, dest, num)
    local getPos = function(name)
        local seat = self.MainPanel:getChildByName(name)
        local avatar = seat:getChildByName('avatar')
        local frame = avatar:getChildByName('frame')
        local headimg = frame:getChildByName('headimg')

        local pos = frame:convertToWorldSpace(cc.p(headimg:getPosition()))

        return pos
    end
    
    local str = 'item15'
    local str1 = 'item15_1'
    local str2 = 'item15_2'

    local node = cc.CSLoader:createNode("views/animation/"..str..".csb") 
    node:setPosition(cc.p(getPos(start)))
    self:addChild(node)
    node:setVisible(true)

    local node1 = cc.CSLoader:createNode("views/animation/"..str1..".csb") 
    node1:setPosition(cc.p(getPos(dest)))
    self:addChild(node1)
    node1:setVisible(true)

    local node2 = cc.CSLoader:createNode("views/animation/"..str2..".csb") 
    node2:setPosition(cc.p(getPos(dest)))
    self:addChild(node2)
    node2:setVisible(true)

    local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")  
    action:gotoFrameAndPlay(0, 0, false)
    node:runAction(action)

    local action1 = cc.CSLoader:createTimeline("views/animation/"..str1..".csb")  
    action1:gotoFrameAndPlay(0, 0, false)
    node1:runAction(action1)

    local action2 = cc.CSLoader:createTimeline("views/animation/"..str2..".csb")  
    action2:gotoFrameAndPlay(0, 0, false)
    node2:runAction(action2)

    local callback = function(str, action, node)
        local action = cc.CSLoader:createTimeline("views/animation/"..str..".csb")   
        action:gotoFrameAndPlay(0, false)
        action:setFrameEventCallFunc(function(frame)
            local event = frame:getEvent();
            print("=========",event);
            if event == 'end' then
                node:removeSelf()
            elseif event == 'playSound' then
                SoundMng.playEft('sfx/' .. str .. '.mp3')
                node:setVisible(true)    
            end
        end)      
        node:runAction(action)

    end
    
    local delay = cc.DelayTime:create(0.2)

    local moveTo = cc.MoveTo:create(1.5, cc.p(getPos(dest)))

    -- local spawnAction = cc.Spawn:create(moveTo, cc.CallFunc:create(function()
    --     callback(str1, action1, node1)
    -- end))

    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function ()
        callback(str, action, node)
    end))
    local sequence1 = cc.Sequence:create(delay, cc.CallFunc:create(function()
        callback(str1, action1, node1)
    end))
    local sequence2 = cc.Sequence:create(delay, cc.CallFunc:create(function ()
        callback(str2, action2, node2)
    end))

    if num == 1 then
        node:runAction(sequence)
    else
        node:removeSelf()
    end
    if dest == 'right' or dest == 'rightmid' or dest == 'righttop' then
        node1:runAction(sequence1)
    else
        node1:setRotation(180)
        node1:runAction(sequence1)
    end
    node2:runAction(sequence2)
end


function XYDeskView:freshSummaryView(show, data)
    local view = self.MainPanel:getChildByName('summary')
    if not show then
        view:setVisible(false)
        return
    end

    if self.schedulerID2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID2)
    end

    view:setVisible(true)

    self:freshTrusteeshipLayer(false)
    self.playerViews.continue:setVisible(false)
    self.watcherLayout:setVisible(false)

    local quit = view:getChildByName('quit')
    local summary = view:getChildByName('summary')

    local function onClickQuit()
        app:switch('LobbyController')
    end

    local function onClickSummary()
        app:switch('XYSummaryController', data)
    end

    quit:addClickEventListener(onClickQuit)
    summary:addClickEventListener(onClickSummary)
end

-- ============================ agent ============================

-- 玩家准备
function XYDeskView:freshReadyState(name, bool)
    local component = self.MainPanel:getChildByName(name)
    if not component then
        return
    end

    local avatar = component:getChildByName('avatar')
    local ready = avatar:getChildByName('ready')
    ready:setVisible(bool)
end

-- 玩家掉线
function XYDeskView:freshDropLine(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local dropLine = avatar:getChildByName('dropLine')
    dropLine:setVisible(bool)
    if name == 'bottom' then
        dropLine:setVisible(false)
    end
    if bool then 
        self:freshEnterBackground(name,false)
    end
end

-- 玩家切换后台
function XYDeskView:freshEnterBackground(name, bool)
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local enterbackground = avatar:getChildByName('enterbackground')
    enterbackground:setVisible(bool)
    if name == 'bottom' then
        enterbackground:setVisible(false)
    end
end

-- 托管/取消托管
function XYDeskView:freshTrusteeshipIcon(name, bool)
    bool = bool or false
    local component = self.MainPanel:getChildByName(name)
    local avatar = component:getChildByName('avatar')
    local trusteeship = avatar:getChildByName('trusteeship')
    trusteeship:setVisible(bool)
end

function XYDeskView:freshTrusteeshipLayer(bool)
    self.trusteeshipLayer:setVisible(bool)
end

function XYDeskView:getTrusteeshipLayer()
    return self.trusteeshipLayer:isVisible()
end

function XYDeskView:getPlayerView(startUid)
    local viewKey = {}
    local i = 1
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            if agent:getInMatch() and uid ~= startUid then
                viewKey[i] = agent:getViewInfo()
                i = i + 1
            end
        end
    end
    return viewKey
end

-- ===========================声音=================================

-- 抢庄声音
function XYDeskView:playEftQz(qzNum, sex)
    if not qzNum then return end
    if not sex then return end

    local qiangStr = 'buqiang_'
    if qzNum and qzNum > 0 then
        qiangStr = 'qiangzhuang_'
    end
    local sexStr = '0'
    if sex and sex ~= 0 then
        sexStr = '1'
    end
    
    local soundPath = 'desk/' .. tostring(qiangStr .. sexStr .. '.mp3')
    SoundMng.playEftEx(soundPath)
end

-- 下注音效
function XYDeskView:playEftBet(bool)
    local soundPath = 'desk/coin_big.mp3'
    if bool then
        soundPath = 'desk/coins_fly.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

-- 牌型
function XYDeskView:playEftCardType(sex, niuCnt, specialType)
    local soundPath = 'cscompare/' .. tostring('f' .. sex .. "_nn" .. niuCnt .. '.mp3')
    if specialType > 0 then
        local idx = self.desk:getGameplayIdx()
        soundPath = 'cscompare/' .. tostring('f'.. sex .."_nn" .. GameLogic.getSpecialTypeByVal(idx, specialType) .. '.mp3')
    end
    SoundMng.playEftEx(soundPath)
end

-- 输赢音效
function XYDeskView:playEftSummary(win)
    local soundPath = 'desk/lose.mp3'
    if win then
        soundPath = 'desk/win.mp3'
    end
    SoundMng.playEftEx(soundPath)
end

function XYDeskView:freshCanPutMoney(name,bool)
    local picture =  self.MainPanel:getChildByName(name):getChildByName('avatar'):getChildByName('CanPutMoney')
    local node = picture:getChildByName('CanPutMoneyAnimation')
    picture:setVisible(bool)
    if bool then
        self:startCsdAnimation(node,true)
    else
        self:stopCsdAnimation(node)
    end
end

function XYDeskView:startCsdAnimation(node, isRepeat)
    local action = cc.CSLoader:createTimeline("views/xydesk/putmoney/CanPutMoneyAnimation.csb")
    action:gotoFrameAndPlay(0,isRepeat)
    node:stopAllActions()
    node:runAction(action)
end
  
function XYDeskView:stopCsdAnimation(node)
    node:stopAllActions()
end

return XYDeskView
