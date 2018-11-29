local class = require('middleclass')
local HasSignals = require('HasSignals')
local XYDesk = class("Desk"):include(HasSignals)
local ShowWaiting = require('app.helpers.ShowWaiting')
local cardHelper = require('app.helpers.card')
local tools = require('app.helpers.tools')
local EventCenter = require("EventCenter")
local Agent = require('app.libs.niuniu.Agent')
local Gameplay = require('app.libs.niuniu.Gameplay')
local GameLogic = require('app.libs.niuniu.NNGameLogic')
local app = require("app.App"):instance()


function XYDesk:initialize()
    HasSignals.initialize(self)

    -- 桌子
    self.gameIdx = 29
    self.DeskName = 'niumowang'


    -- 服务器数据
    self.tabBaseInfo = false        --pdesk:packbaseinfo()
    self.tabPlayer = false          --agent instance
    self.gameplay = false           --gameplay instance

    -- playback 
    self.tabDeskRecord = {}      --pdesk:packageDeskRecord()
    -- watcherlist
    self.tabWatcher = {}
    -- xychat
    self.tabChatList = {} 

    -- viewInfo
    self.tabViewKey = {}
    
    -- overgame
    self.overSuggest = false
    self.overTickInfo = false

    -- is desk summary
    self.isdeskSummary = false

    -- 消息
    self:listen()
end

function XYDesk:resetDesk()
    -- 服务器数据
    self.tabBaseInfo = false        --pdesk:packbaseinfo()
    self.tabPlayer = false          --agent instance
    self.gameplay = false           --gameplay instance

    -- playback 
    self.tabDeskRecord = {}      --pdesk:packageDeskRecord()
    -- watcherlist
    self.tabWatcher = {}
    -- xychat
    self.tabChatList = {} 

    -- viewInfo
    self.tabViewKey = {}

    -- overgame
    self.overSuggest = false
    self.overTickInfo = false

    -- is desk summary
    self.isdeskSummary = false
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////
-- 


function XYDesk:listen()
    local app = require("app.App"):instance()

    if self.onSynDeskHandle then
        self.onSynDeskHandle:dispose()
        self.onSynDeskHandle = nil
    end

    self.onSynDeskHandle = app.conn:on(self.DeskName .. ".synDeskData", function(msg)
        -- 服务端发送消息情景:
        -- 1.进入桌子
        -- 2.请求坐下成功
        -- 3.重连请求成功
        self:onSynDeskData(msg)
    end)
end


function XYDesk:disposeListens()
    if self.listens then
        for i = 1, #self.listens do
            self.listens[i]:dispose()
        end

        self.listens = nil
    end

    -- 注销 切换事件监听
    -- EventCenter.clear("app")
end

function XYDesk:bindMsgHandles()
    local app = require("app.App"):instance()
    self:disposeListens()

    -- 注册 切换事件监听
    -- EventCenter.register("app", function(event)
    --     if event then 
    --         self.emitter:emit(event)
    --     end
    -- end)

    self.listens = {
        -- ============================ state ============================
        --Ready
        app.conn:on(self.DeskName .. '.StateReady', function(msg)
            self.tabBaseInfo.isPlaying = false
            local played = self:isGamePlayed()
            if played then
                for k,v in pairs(self.tabPlayer) do
                    v:setPrepare(false)
                end
            end

            self.tabBaseInfo.number = msg.round

            self.gameplay:setState('Ready', msg.tick)
            self.emitter:emit('StateReady', msg)
        end),

        app.conn:on(self.DeskName .. '.StateStarting', function(msg)
            self.gameplay:initGamePack(msg.data)
            -- 设置玩家比赛状态
            
            local gameplay = self:getGameplayIdx()
            if (gameplay == 1 or gameplay == 2) then
                local info = self:getBankerInfo()
                if info then
                    info.player:setFlagBanker(true)
                end
            end

            for k,v in pairs(self.tabPlayer) do
                v:setInMatch(true)
                v:initHand()
                v:setPrepare(not played)
            end 

            self.tabBaseInfo.isPlaying = true
            self.tabBaseInfo.played = true

            self.gameplay:setState('Starting', 0)
            self.emitter:emit('StateStarting', msg)
        end),

        app.conn:on(self.DeskName .. '.CanPutMoneyPlayer', function(msg)
            -- 获取可推注玩家列表
            if msg.cnt == 0 then return end
            local data = msg.data
            local info = {}

            for k,v in pairs(data) do
                local playerInfo = self:getPlayerInfo(v)
                if playerInfo then 
                    playerInfo.player:setCanPutMoney(true)
                    table.insert(info, playerInfo.viewKey)
                end
            end

            local cMsg = {
                msgID = 'CanPutMoneyPlayer',
                viewKey = info,
                cnt = msg.cnt
            }
            self.emitter:emit('CanPutMoneyPlayer', cMsg)
        end),

        --QiangZhuang
        app.conn:on(self.DeskName .. '.StateQiangZhuang', function(msg)
            self.gameplay:setState('QiangZhuang', msg.tick)
            self.emitter:emit('StateQiangZhuang', msg)
        end),

        app.conn:on(self.DeskName .. '.somebodyQiang', function(msg)
            -- 玩家抢庄操作
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setQiang(msg.number)
            local cMsg = {
                msgID = 'somebodyQiang',
                info = info,
                number = msg.number
            }
            self.emitter:emit('somebodyQiang', cMsg)
        end),

        app.conn:on(self.DeskName .. '.newBanker', function(msg)
            -- 抢庄结果
            local bankerInfo = self:getPlayerInfo(msg.uid)
            if not bankerInfo then return end

            self.gameplay:setFlagFindBanker(true)

            local qiangData = {}
            for k,v in pairs(msg.qiangPlayer) do
                local info = self:getPlayerInfo(v)
                if info then
                    table.insert(qiangData, info.viewKey)
                end
            end

            self.gameplay:setQiangData(qiangData)            
            self.gameplay:setBankerUID(msg.uid)
            bankerInfo.player:setFlagBanker(true)
            bankerInfo.player:setQiang(msg.number)
            bankerInfo.player:setCanPutMoney(false)

            local cMsg = {
                msgID = 'newBanker',
                info = bankerInfo,
                number = msg.number,
                qiangPlayer = qiangData
            }
            self.emitter:emit('newBanker', cMsg)
        end),

        --PutMoney
        app.conn:on(self.DeskName .. '.StatePutMoney', function(msg)
            self.gameplay:setState('PutMoney', msg.tick)
            self.emitter:emit('StatePutMoney', msg)
        end),

        app.conn:on(self.DeskName .. '.putMoney', function(msg)
            --msg.putInfo
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setThisPutOpt(msg.putInfo)
            local cMsg = {
                msgID = 'putMoney',
                info = info,
                putInfo = msg.putInfo
            }
            self.emitter:emit('putMoney', cMsg)
        end),

        app.conn:on(self.DeskName .. '.somebodyPut', function(msg)
            -- 押注
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setPutscore(msg.score)
            info.player:setPutFlag(msg.pushFlag)
            info.player:setCanPutMoney(false)
            local cMsg = {
                msgID = 'somebodyPut',
                info = info,
                score = msg.score,
                putFlag = msg.pushFlag,
                tuizhuflag = msg.tuizhuflag
            }
            self.emitter:emit('somebodyPut', cMsg)
        end),

        --Dealing
        app.conn:on(self.DeskName .. '.StateDealing', function(msg)
            self.gameplay:setState('Dealing', msg.tick)
            self.emitter:emit('StateDealing', msg)
        end),

        app.conn:on(self.DeskName .. '.dealt', function(msg)
            local cMsg = {
                msgID = 'dealt',
            }
            self.gameplay:setFlagDealAllPlayer(true)
            if msg.uid and msg.handData and msg.dealList then
                -- 有扑克数据
                local info = self:getPlayerInfo(msg.uid)
                if info then
                    -- info.player:setHandCardData(msg.handData)
                    info.player:setHandCardData(msg.dealList)
                end
            end

            self.emitter:emit('dealt', cMsg)
        end),

        --Playing
        app.conn:on(self.DeskName .. '.StatePlaying', function(msg)
            self.gameplay:setState('Playing', msg.tick)
            self.emitter:emit('StatePlaying', msg)
        end),

        app.conn:on(self.DeskName .. '.someBodyChoosed', function(msg)
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setLastCard(msg.lastcard)
            local cMsg = {
                msgID = 'someBodyChoosed',
                info = info,
                hasCardData = msg.hasCardData,  --是否有扑克数据
            }
            if msg.hasCardData then
                -- 有扑克数据           
                cMsg.hasCardData = true
                info.player:setSummaryCardData(msg.cards)
                info.player:setChoosed(true, msg.niuCnt, msg.specialType)
            else
                -- 无扑克数据（弃用逻辑）
                info.player:setChoosed(true)
            end

            self.emitter:emit('someBodyChoosed', cMsg)
        end),

        --End
        app.conn:on(self.DeskName .. '.Ending', function(msg)
            self.gameplay:setState('Ending')
            self.emitter:emit('Ending', msg)
        end),

        -- ============================ agent ============================



        app.conn:on(self.DeskName .. ".somebodySitdown", function(msg)
            -- 初始化玩家
            self:initPlayer(msg.uid, msg.userData, not self:isMePlayer())
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            local sitCID = info.player:getChairID()
            self.emitter:emit('somebodySitdown', info)
            if not self:isMePlayer() then
                local playerCnt = self:getPlayerCnt()
                if playerCnt == self:getMaxPlayerCnt() then
                    self:reloadData()
                end
            end
        end),

        app.conn:on(self.DeskName .. ".somebodyLeave", function(msg)
            -- 玩家离开
            if self.isdeskSummary then return end
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end

            local leaveFreeCID = self:getLastFreeChairID()

            -- 清除玩家数据
            self.tabPlayer[msg.uid] = nil
            self.emitter:emit('somebodyLeave', info)

            --刷新视角
            if not self:isMePlayer() then
                if leaveFreeCID ~= self:getLastFreeChairID() then
                    self:reloadData()
                end
            end
        end),

        app.conn:on(self.DeskName .. ".leaveResult", function(msg)
            -- 初始化玩家
            self.emitter:emit('leaveResult', {})
        end),


        app.conn:on(self.DeskName .. ".somebodyPrepare", function(msg)
            -- 玩家准备
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setPrepare(true)

            local cMsg = {
                msgID = 'somebodyPrepare',
                info = info,
            }
            self.emitter:emit('somebodyPrepare', cMsg)
        end),

        app.conn:on(self.DeskName .. '.dropLine', function(msg)
            -- 玩家掉线
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setDropLine(true)
            self.emitter:emit('dropLine', info)
        end),

        app.conn:on(self.DeskName .. ".somebodyCancelTrusteeship", function(msg)
           -- 取消托管
           local info = self:getPlayerInfo(msg.uid)
           if not info then return end
           info.player:setTrusteeship(false)
           self.emitter:emit('somebodyCancelTrusteeship', info)
        end),

        app.conn:on(self.DeskName .. ".somebodyTrusteeship", function(msg)
            -- 托管
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setTrusteeship(true)
            self.emitter:emit('somebodyTrusteeship', info)
        end),

        app.conn:on(self.DeskName .. ".somebodyEnterBackground", function(msg)
            -- 离开
            local info = self:getPlayerInfo(msg.uid)
            if not info then return end
            info.player:setEnterBackground(msg.flag)
            self.emitter:emit('somebodyEnterBackground', info, msg)
        end),

        -- ============================ cheat ============================
        -- 作弊信息
        app.conn:on(self.DeskName .. '.cheat', function(msg)
            self.emitter:emit('cheatInfo', msg.cheatInfo)
        end),

        -- 作弊信息1
        app.conn:on(self.DeskName .. '.cheat1', function(msg)
            self.emitter:emit('cheat1', msg.flag)
        end),

        app.conn:on(self.DeskName .. '.setCheatDataResult', function(msg)
            self.emitter:emit('cheat1Result', msg.mode)
        end),



        -- ============================ desk ============================
        
        app.conn:on(self.DeskName .. '.summary', function(msg)
            -- 单局结算 | 总结算
            self:onSummary(msg)
            local cMsg = {
                msgID = 'summary',
            }
            self.emitter:emit('summary', cMsg)
        end),

        app.conn:on(self.DeskName .. ".deskSummary", function(msg)
            -- 总结算
            self.isdeskSummary = true
            local owner = self:getOwnerInfo()
            local cMsg = {
                deskInfo = self:getDeskInfo(),
                ownerName = owner.name,
                fsummay = msg.fsummay,
                records = msg.record,
                deskId = self:getDeskId(),
            }
            self.emitter:emit('deskSummary', cMsg)
        end),
        
        app.conn:on(self.DeskName .. ".canStart", function(msg)
            -- 客户端可以开始游戏了
            local cMsg = {
                msgID = 'canStart',
                canStart = msg.canStart,
            }
            self.emitter:emit('canStart', cMsg)
        end),

        app.conn:on(self.DeskName .. ".waitStart", function(msg)
            -- 等待 xx 开始游戏
            self.emitter:emit('waitStart', msg)
        end),

        app.conn:on(self.DeskName .. ".responseSitdown", function(msg)
            -- 请求坐下结果
            local cMsg = {
                msgID = 'responseSitdown',
                errCode = msg.errCode,
            }
            self.emitter:emit('responseSitdown', cMsg)
        end),

        app.conn:on(self.DeskName .. '.overgame', function(msg)
            -- 解散房间信息
            self:onOvergame(msg) -- 设置解散数据
            self.emitter:emit('overgame', msg)
        end),

        app.conn:on(self.DeskName .. '.overgameResult', function(msg)
            -- 解散房间结果
            self.emitter:emit('overgameResult')
        end),

        
        app.conn:on(self.DeskName .. ".deskRecord", function(msg)
            -- 上局回顾战绩
            self:onDeskRecord(msg)
            self.emitter:emit('deskRecord', msg)
        end),

        app.conn:on(self.DeskName .. ".watcherList", function(msg)
            -- 旁观者列表
            self:onWatcherList(msg)
            self.emitter:emit('watcherList', msg)
        end),

        app.conn:on('chatInGame', function(msg)
            -- 游戏中聊天
            self:onChatInGame(msg)
            self.emitter:emit('chatInGame', msg)
        end),

        app.conn:on(self.DeskName .. '.getLastVoiceResult', function(msg)
            -- 获取玩家上一条语音
            self.emitter:emit('getLastVoiceResult', msg)
        end),

        app.conn:on(self.DeskName .. '.chatList', function(msg)
            -- 聊天列表(不包含语音)
            self:onChatList(msg.data)        
            self.emitter:emit('chatList', msg)
        end),

        --[[
        app.conn:on(self.DeskName .. '.playVoice', function(msg)
            -- 语音消息, 放入controller处理
        end),
        ]]

        app.conn:on(self.DeskName .. '.smartTrusteeshipResult', function (msg)
            --智能托管返回结果
            self.emitter:emit('smartTrusteeshipResult', msg)
        end),

        app.conn:on(self.DeskName .. '.smartOpt', function (msg)
            --托管状态返回结果
            self.emitter:emit('smartOpt', msg)
        end),

        app.conn:on(self.DeskName .. '.autoOperationrResult', function (msg)
            --自动操作返回结果
            self:onAutoOperation(msg)
            -- self.emitter:emit('autoOperationrResult', msg)
        end),
    }
end



function XYDesk:onCustomSwitch() 
    app:switch('XYDeskController', self.DeskName)
end

-- ============ view key ============

function XYDesk:initViewKey() -- virtual 
    
    local maxCnt = self:getMaxPlayerCnt()

    if maxCnt == 8 then
        self.tabViewKey = {
            'bottom',
            'left',
            'leftmid',
            'lefttop',
            'top',
            'righttop',
            'rightmid',
            'right',
        }
    elseif maxCnt == 10 then
        self.tabViewKey = {
            'bottom',
            'left',
            'leftmid',
            'lefttop',
            'topleft',
            'top',
            'topright',
            'righttop',
            'rightmid',
            'right',
        }
    else
        self.tabViewKey = {
            'bottom',
            'left',
            'lefttop',
            'top',
            'righttop',
            'right',
        }
    end
end


function XYDesk:getViewKey(pos) -- virtual 
    return self.tabViewKey[pos]
end

function XYDesk:getViewKeyData() 
    return self.tabViewKey
end

-- ============ onnetmsg ============

function XYDesk:onSynDeskData(msg)
    self:resetDesk()

    -- 同步数据
    self.tabBaseInfo = msg.base

    self:initViewKey()

    -- gameplay
    self.gameplay = Gameplay(msg.state) 

    -- 解散信息
    if msg.dismissInfo and msg.dismissInfo.hasOverSuggest then
        self:setDismissInfo(
        msg.dismissInfo.data,
        msg.dismissInfo.dataEx
        )
    end
    

    -- bottom 座位
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    local isPlayer = false
    local fPlayer = nil
    local mPlayer = nil
    local bottomPlayer = nil

    local tabValid = {}
    local validCnt = 0
    for i = 1, self:getMaxPlayerCnt() do
        table.insert(tabValid, false)
    end

    for k,v in pairs(msg.agent) do
        tabValid[v.chairIdx] = true
        validCnt = validCnt + 1
        if k == meUid then
            -- 自己
            mPlayer = {k, v} 
            isPlayer = true 
            break 
        end
    end

    local lastFreeCID = 0
    for k,v in pairs(tabValid) do
        if v == false and k > lastFreeCID then
            lastFreeCID = k
        end
    end

    if validCnt == self:getMaxPlayerCnt() then
        lastFreeCID = self:getMaxPlayerCnt()
    end

    if isPlayer then
        -- 自己是玩家
        self:initPlayer(mPlayer[1], mPlayer[2], nil, nil, true)
    end

    -- 初始化玩家
    for k,v in pairs(msg.agent) do
        if (mPlayer and k == mPlayer[1]) then
            --跳过自己
        else
            self:initPlayer(k, v, (not isPlayer), lastFreeCID)  
        end
    end


    if msg.reload then
        self.emitter:emit('reloadData')
    else
		self:onCustomSwitch()
        self:bindMsgHandles()
    end
end


function XYDesk:onSomebodyTrusteeship(msg)
    if self:isMe(msg.uid) then
        local me = self:getMe()
        me.hand.trusteeship = true

        self.emitter:emit('trusteeship')
    end
end

function XYDesk:onDeskRecord(msg)
    self.tabDeskRecord = msg.data or {}
end

function XYDesk:onWatcherList(msg)
    self.tabWatcher = msg.data or {}
end

function XYDesk:onChatInGame(msg)  
    if msg and (msg.type == 0 or msg.type == 1 or msg.type == 2) then
        local newChat = {type = msg.type, 
            uid = msg.uid,
            msg = msg.msg
        }
        table.insert(self.tabChatList, newChat)
    end
end

function XYDesk:onChatList(msg)
    self.tabChatList = msg or {}
end

function XYDesk:onSummary(msg)
    -- 单局结算
    for k,v in pairs(msg.data) do
        local info = self:getPlayerInfo(k)
        if info then
            info.player:setSummaryCardData(v.hand)
            info.player:setLastCard(v.lastcard)
            info.player:setChoosed(true, v.niuCnt, v.specialType)
            info.player:setPutFlag(v.bIsPushBetting)
            info.player:setScore(v.score)
            info.player:setMoney(v.money)
            info.player:setGroupScore(v.groupScore)
        end
    end
end

function XYDesk:onAutoOperation(msg)
    local info = self:getPlayerInfo(msg.uid)
    if info then
        info.player:setautoOperation(msg.flag)
    end
end

function XYDesk:onOvergame(msg)
    self.overSuggest = msg.data
    self.overTickInfo = msg.dataEx
end

-- ============ sendnetmassage ============

function XYDesk:betting(value)
    local app = require("app.App"):instance()
    local conn = app.conn
	local msg = {
		msgID = self.DeskName .. '.puts',
		score = value
	}
	app.conn:send(msg)
end

function XYDesk:watcherList()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = 'watcherList',
    }
    conn:send(msg)
end


function XYDesk:sitDown(deskId, buyHorse) -- luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.sitdown',
        gameIdx = self.gameIdx,
        deskId = deskId,
        buyHorse = buyHorse,
    }
    conn:send(msg)
end

function XYDesk:getLastVoice(msg) -- luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local tmsg = {
        msgID = self.DeskName .. '.getLastVoice',
        uid = msg.uid
    }
    conn:send(tmsg)
end


function XYDesk:quit() -- luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.leaveRoom'
    }
    conn:send(msg)
end

function XYDesk:answer(answer)--luacheck:ignore
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.overAction',
      result = answer
    }
    conn:send(msg)
end

function XYDesk:cancelTrusteeship()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName..'.cancelTrusteeship',
    }
    conn:send(msg)
end

function XYDesk:requestTrusteeship()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName..'.requestTrusteeship',
    }
    conn:send(msg)
end

--智能托管
function XYDesk:sendTrusteeshipMsg(bool, msg)
    local app = require("app.App"):instance()
    local conn = app.conn
    local rmsg = {
        msgID = self.DeskName..'.smartTrusteeship',
        flag = bool
    }
    if bool then
        rmsg.data = msg
    end
    conn:send(rmsg)
end

--请求获取托管状态
function XYDesk:requestTrusteeshipMsg()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName..'.getSmartOpt',
    }
    conn:send(msg)
end


function XYDesk:deskRecord()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.deskRecord',
    }
    conn:send(msg)
end

function XYDesk:deskChatList()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = 'chatList',
    }
    conn:send(msg)
end

function XYDesk:requestSitdown()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.requestSitdown'
    }
    app.conn:send(msg)
end

function XYDesk:prepare()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.prepare'
    }
    app.conn:send(msg)
end

function XYDesk:autoOperation(msg)
    local app = require("app.App"):instance()
    local conn = app.conn
    local tmsg = {
        msgID = self.DeskName .. '.autoOperation',
        msg = msg
    }
    app.conn:send(tmsg)
end

function XYDesk:startGame()
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.bankerStart'
    }
    app.conn:send(msg)
end

function XYDesk:uploadVoiceSuccess(filename, total) --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = 'playVoice',
        filename = filename,
        total = total
    }
    app.conn:send(msg)
end


function XYDesk:leaveRoom() --luacheck

    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.leaveRoom'
    }
    app.conn:send(msg)
end

function XYDesk:dismiss() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.overgame'
    }
    app.conn:send(msg)
end

function XYDesk:reloadData() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.reloadData'
    }
    app.conn:send(msg)
end

function XYDesk:qiangzhuang(qiangNum) --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.qiang',
        number = qiangNum
    }
    app.conn:send(msg)
end

function XYDesk:showCard() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.choosed'
    }
    app.conn:send(msg)
end

--切到后台
function XYDesk:enterBackground() --luacheck
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
        msgID = self.DeskName .. '.enterBackground'
    }
    app.conn:send(msg)
end

--设置作弊信息
function XYDesk:setCheatData(mode)
    local app = require("app.App"):instance()
    local conn = app.conn
    local msg = {
      msgID = self.DeskName..'.setCheatData',
      mode = mode,
    }
    conn:send(msg)
end

--/////////////////////////////////////////////////////////////////////////////////////////////////////
--!public

--@baseInfo
function XYDesk:getMaxPlayerCnt() --virtual
    local deskInfo = self.tabBaseInfo.deskInfo 
    return deskInfo.maxPeople
end

function XYDesk:getDeskInfo()
    -- 游戏规则
    return self.tabBaseInfo.deskInfo 
end

function XYDesk:getgroupInfo()
    -- 俱乐部信息
    return self.tabBaseInfo.groupInfo 
end

function XYDesk:getGameplayIdx()
    return self.tabBaseInfo.deskInfo.gameplay 
end

function XYDesk:getWanglai()
    return self.tabBaseInfo.deskInfo.advanced[5] or 0 
end

function XYDesk:getDismissInfo()
    -- 解散信息
    return self.overSuggest, self.overTickInfo
end

function XYDesk:setDismissInfo(overSuggest, overTickInfo)
    self.overSuggest = overSuggest
    self.overTickInfo = overTickInfo
end

function XYDesk:getOwnerInfo()
    -- 房主信息
    return {
        uid = self.tabBaseInfo.ownerUID,
        name = self.tabBaseInfo.ownerName,
    }
end

function XYDesk:getDeskId()
    return self.tabBaseInfo.deskId
end

function XYDesk:getCurRound()
    return self.tabBaseInfo.number
end

function XYDesk:isGamePlaying()
    return self.tabBaseInfo.isPlaying
end

function XYDesk:isGamePlayed()
    return self.tabBaseInfo.played
end

function XYDesk:isMeOwner()
    local ownerInfo = self:getOwnerInfo()
    local meUid = app.session.user.uid
    return meUid == ownerInfo.uid
end

function XYDesk:getMeUID()
    return app.session.user.uid
end

function XYDesk:getBankerInfo()
    local uid = self.gameplay:getBankerUID()
    if not uid then return end

    local info = self:getPlayerInfo(uid)
    if not info then return end

    return info
end

function XYDesk:isGroupDesk()
    if not self.tabBaseInfo then return end
    return self.tabBaseInfo.isGroupDesk
end


function XYDesk:getCanStartPlayer()
    if not self.tabPlayer then return end
    local cnt = 0
    local player
    for k,v in pairs(self.tabPlayer) do
        cnt = cnt + 1
        if player == nil or player:getChairID()>v:getChairID() then
            player = v
        end
    end
    return player
end

function XYDesk:canStartGame()
    -- 房主
    if (not self:isMeOwner()) then return false end
    -- 没有玩家
    if not self.tabPlayer then return false end

    local cnt = 0
    for k,v in pairs(self.tabPlayer) do
        cnt = cnt + 1
        if not v:isReady() then
            return false
        end
    end
    return (cnt >= 2)
end

function XYDesk:getReadyPlayerCnt()
    local cnt = 0
    if not self.tabPlayer then return cnt end
    for k,v in pairs(self.tabPlayer) do
        if v:isReady() then
            cnt = cnt + 1
        end
    end
    return cnt
end


--@player
function XYDesk:getPlayerInfo(uid, viewKey) --virtual
    local player
    if not self.tabPlayer then return end

    if viewKey then
        for k,v in pairs(self.tabPlayer) do
            local vkey, vPos = v:getViewInfo()
            if viewKey == vkey then 
                player = v
                break
            end
        end
    elseif uid then
        player = self.tabPlayer[uid]
    end

    if not player then return false end
    
    local info = {}
    info.viewKey, info.chairIdx = player:getViewInfo()
    info.player = player
    info.uid = uid
    return info
end

function XYDesk:getPlayerCnt()
    if not self.tabPlayer then return 0 end
    return table.nums(self.tabPlayer) or 0
end

function XYDesk:isMePlayer()
    -- 自己是否在比赛中
    if not self.tabPlayer then return false end
    local app = require("app.App"):instance()    
    local meUid = app.session.user.uid
    for k,v in pairs(self.tabPlayer) do
        local uid = v:getUID()
        if meUid == uid then 
            return true, v
        end
    end
    return false
end


function XYDesk:isMeInMatch()
    -- 自己是否在比赛中
    if not self.tabPlayer then return false end
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    for k,v in pairs(self.tabPlayer) do
        local uid = v:getUID()
        if meUid == uid and v:getInMatch() then 
            return true
        end
    end
    return false
end

function XYDesk:getBottomPlayer()--弃用接口
    -- 主视角玩家
    if self.tabPlayer then
        for k,v in pairs(self.tabPlayer) do
            local vKey, vPos = v:getViewInfo()
            if vKey == "bottom" then 
                return v
            end
        end
    end
end

function XYDesk:getMeAgent()
    -- 主视角玩家
    if not self.tabPlayer then return false end
    local app = require("app.App"):instance()
    local meUid = app.session.user.uid
    for k,v in pairs(self.tabPlayer) do
        local uid = v:getUID()
        if meUid == uid then 
            return v
        end
    end
    return false
end

--@gameplay


function XYDesk:getTick()
    return self.gameplay:getTick()
end

--@deskRecord
function XYDesk:getDeskRecord(msg)
    return self.tabDeskRecord
end

--@watchList
function XYDesk:getWatcherList()
    return self.tabWatcher
end

--@chatList
function XYDesk:getChatList()
    return self.tabChatList
end



--////////////////////////////////////////////////////////////////////////////////////////////////
-- !private
function XYDesk:initPlayer(uid, agentPack, lookupFlag, lookupCID, initSelf) 
    -- 初始化tabPlayer
    if not self.tabPlayer then self.tabPlayer = {} end
    local bottomPos = 1

    local agent = Agent(agentPack)
    
    -- 自己是玩家初始化自己
    if initSelf then
        local key = self:getViewKey(bottomPos)
        agent:setViewInfo(key, bottomPos)
        self.tabPlayer[uid] = agent 
        return
    end

    -- 其他座位
    local bottomCID = 1
    

    if lookupFlag then
        if lookupCID then           
            -- syndeskdata
            bottomCID = lookupCID
        else    
            -- somebodySitdown
            bottomCID = self:getLastFreeChairID()
        end
    else
        local bool, meAgent = self:isMePlayer()
        if bool then
            bottomCID = meAgent:getChairID()
        end
    end

    
    local agentCID = agent:getChairID()
    local maxPlayerCnt = self:getMaxPlayerCnt()

    local pos = ((bottomPos + agentCID - bottomCID -1)%maxPlayerCnt) + 1
    -- local pos = bottomPos + (agentCID - bottomCID)

    print("initPlayer pos:", pos, "bottomCID:", bottomCID, "agentCID:", agentCID, "maxPlayer:", maxPlayerCnt, "bottomPos", bottomPos)
    local key = self:getViewKey(pos)
    agent:setViewInfo(key, pos)
    self.tabPlayer[uid] = agent 
end

function XYDesk:getLastFreeChairID()
    --最后的空位
    local tabValidCID = {}
    local validCnt = 0
    for i = 1, self:getMaxPlayerCnt() do tabValidCID[i] = false end
    for k,v in pairs(self.tabPlayer) do
        tabValidCID[v.chairIdx] = true
        validCnt = validCnt + 1
    end
    local cID = 1
    for k,v in pairs(tabValidCID) do
        if v == false and k > cID then
            cID = k
        end
    end
    if validCnt == self:getMaxPlayerCnt() then
        cID = self:getMaxPlayerCnt()
    end
    return cID
end

return XYDesk
