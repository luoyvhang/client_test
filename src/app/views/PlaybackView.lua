local cache = require('app.helpers.cache')
local GameLogic = require('app.libs.niuniu.NNGameLogic')

local SUIT = {
    ['♠'] = 'h',
    ['♣'] = 'm',
    ['♥'] = 'z',
    ['♦'] = 'f',
    ['★'] = 'j1',
    ['☆'] = 'j2',
}

local CARD = {
    ['♠A'] = 1,   ['♠2'] = 2,  ['♠3'] = 3,  ['♠4'] = 4, ['♠5'] = 5,
    ['♠6'] = 6,   ['♠7'] = 7,  ['♠8'] = 8,  ['♠9'] = 9,
    ['♠T'] = 10, ['♠J'] = 10, ['♠Q'] = 10, ['♠K'] = 10,

    ['♥A'] = 1,   ['♥2'] = 2,  ['♥3'] = 3,  ['♥4'] = 4, ['♥5'] = 5,
    ['♥6'] = 6,   ['♥7'] = 7,  ['♥8'] = 8,  ['♥9'] = 9,
    ['♥T'] = 10, ['♥J'] = 10, ['♥Q'] = 10, ['♥K'] = 10,

    ['♣A'] = 1,   ['♣2'] = 2,  ['♣3'] = 3,  ['♣4'] = 4, ['♣5'] = 5,
    ['♣6'] = 6,   ['♣7'] = 7,  ['♣8'] = 8,  ['♣9'] = 9,
    ['♣T'] = 10, ['♣J'] = 10, ['♣Q'] = 10, ['♣K'] = 10,

    ['♦A'] = 1,   ['♦2'] = 2,  ['♦3'] = 3,  ['♦4'] = 4, ['♦5'] = 5,
    ['♦6'] = 6,   ['♦7'] = 7,  ['♦8'] = 8,  ['♦9'] = 9,
    ['♦T'] = 10, ['♦J'] = 10, ['♦Q'] = 10, ['♦K'] = 10,
    ['☆'] = 10,   ['★'] = 10
}


local PlaybackView = {}

function PlaybackView:initialize(data) 
    self.data = data
    self.curPage = 0 --当前局数
end

function PlaybackView:layout(desk)
    self.desk = desk

    local gameplayIdx = self.desk:getGameplayIdx()
    
	local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setPosition(display.cx, display.cy)
    -- 默认6人场景
    local bg = MainPanel:getChildByName('bg')
    local bg8 = MainPanel:getChildByName('bg8')
    local bg10 = MainPanel:getChildByName('bg10')
    self.bg = bg

    bg:setVisible(true)
    bg8:setVisible(false)
    bg10:setVisible(false)
    self.rowCnt = 3
    
    if gameplayIdx == 7 then
        bg8:setVisible(true)
        bg:setVisible(false)
        bg10:setVisible(false)
        self.bg = bg8
        self.rowCnt = 4
    elseif gameplayIdx == 8 then
        bg10:setVisible(true)
        bg8:setVisible(false)
        bg:setVisible(false)
        self.bg = bg10
        self.rowCnt = 5
    end

	local defaultItem = self.bg:getChildByName('item')
    defaultItem:setVisible(false)
    self.item = defaultItem

	local ListView1 = self.bg:getChildByName('ListView')
	self.ListView1 = ListView1
	ListView1:setItemModel(defaultItem)
	ListView1:removeAllItems()
	ListView1:setScrollBarEnabled(false)       
    
    self.operation = MainPanel:getChildByName('operation')
  
    local curRoomId = self.desk:getDeskId()
    self:freshRoomId(curRoomId)
end

function PlaybackView:freshRoomId(roomId)
	local roomId = self.bg:getChildByName('roomId'):setString(roomId)
end

-- ================ list ================
function PlaybackView:sortData(oneRoundData)
    local data = clone(oneRoundData)
    local retTab = {}
    for uid, v in pairs(data) do
        local info = self.desk:getPlayerInfo(uid)
        local agent = info.player
        local viewKey, viewPos = info.player:getViewInfo()
        v.uid = info.uid
        v.idx = viewPos
        v.actor = agent:getActor()
        table.insert(retTab, v)
    end
    table.sort( retTab, function(a, b)
        return a.idx < b.idx
    end)
    return retTab
end


function PlaybackView:freshRecordView(mode, freshMode)
    local deskRecord = self.desk:getDeskRecord()
    if #deskRecord == 0 then 
        self:freshCurPage('--', '--') 
        return 
    end
    freshMode = freshMode or 1
    if freshMode == 2 and self.curPage ~= 0 then
        self:freshCurPage(self.curPage, #deskRecord, true)        
        return
    end

    if mode == 'firstPage' then
        self.curPage = 1
    elseif mode == 'frontPage' then
        self.curPage = self.curPage - 1
    elseif mode == 'nextPage' then
        self.curPage = self.curPage + 1
    elseif mode == 'lastPage' then
        self.curPage = #deskRecord
    end
    if self.curPage > #deskRecord then
        self.curPage = #deskRecord
    elseif self.curPage < 1 then
        self.curPage = 1
    end

    self:freshCurPage(self.curPage, #deskRecord)
    local one = self:sortData(deskRecord[self.curPage])

    self.ListView1:removeAllItems()

    local rCnt = self.rowCnt
    for i, v in ipairs(one) do
        local j = math.ceil(i/rCnt)
        local k = i % rCnt
        -- k = (k == 0) and 3 or k
        self:freshListItem(j, k, v)
    end
end

function PlaybackView:freshCurPage(idx, total, mode)    
    local curPage = self.operation:getChildByName('curPage'):setString(idx..'/')
    local totalPage = self.operation:getChildByName('totalPage'):setString(total..'')
    if mode then
        totalPage:setColor(cc.c3b(255,0,0))
        totalPage:setFontSize(40)
    else
        totalPage:setColor(cc.c3b(255,255,255))
        totalPage:setFontSize(40)        
    end
end

function PlaybackView:freshListItem(row, column, data)
    dump(data)
    local listView = self.ListView1
    listView:pushBackDefaultItem()
    local tabItem = listView:getItems()
    local item = tabItem[#tabItem]
    item:setVisible(true)

    local actor = data.actor

    -- 头像
    self:freshHeadImg(item, actor.avatar)
    -- 名字
    self:freshUserInfo(item, actor.nickName, actor.playerId)
    -- 庄家 押注
    self:freshBankerAndPutmoney(item, data.bIsBanker, data.nPutScore, data.qiangCnt)
    -- 牌
    self:freshCards(item, data.hand, data.niuCnt, data.specialType)
    -- 分数
    self:freshScore(item, data.score)
end

-- ================ item  views ================
function PlaybackView:freshHeadImg(item, headUrl)
    local node = item:getChildByName('avatar')
    if headUrl == nil or headUrl == '' then return end
    local cache = require('app.helpers.cache')		 
	cache.get(headUrl, function(ok, path)
		if ok then
			node:show()
			node:loadTexture(path)
		else
			node:loadTexture('views/public/tx.png')
		end
	end)
end

function PlaybackView:freshUserInfo(item, name, id)
    local node = item:getChildByName('userInfo')
    node:getChildByName('userName'):setString(name)
    node:getChildByName('userId'):setString(id)
end

function PlaybackView:freshScore(item, score)
    local score = score or 0
    local scoreNode = item:getChildByName('score')
    scoreNode:setString(score..'')
    if score >= 0 then
        scoreNode:setColor(cc.c3b(254,254,42))
    else
        scoreNode:setColor(cc.c3b(120,185,251))
    end
end

function PlaybackView:freshBankerAndPutmoney(item, banker, putmoney, qiangCnt)
    local bankerImg = item:getChildByName('banker')
    local coin = item:getChildByName('coin')
    local qiang = item:getChildByName('qiang')
    local coinStr = coin:getChildByName('coinCnt')
    local gameplayIdx = self.desk:getGameplayIdx()

    bankerImg:setVisible(false)
    coin:setVisible(false)

    if banker and gameplayIdx ~= 5 then
        bankerImg:setVisible(true)
    else
        coin:setVisible(true)
        coinStr:setString(tostring(putmoney))
    end

    local path = 'views/xydesk/result/qiang/bq.png'
    if qiangCnt then
        path = 'views/xydesk/result/qiang/' .. qiangCnt .. '.png'
    end
    qiang:loadTexture(path)
end

function PlaybackView:freshCards(item, cards, niuCnt, specialType)

    local cardNode = item:getChildByName('cards')
    local typeImg = item:getChildByName('cardType')
    local specialTypeImg = item:getChildByName('specialType')
    
    --上局回顾：战绩的牌序位置（前三张组合成牛的，后两张组合几点的 区分来）
    local cards1 = {}
    for i ,v in pairs(cards) do
        table.insert(cards1, i)
    end
    local gameplay = self.desk:getGameplayIdx()
    local wanglai = self.desk:getWanglai()
    local gCard, groupInfo = GameLogic.groupingCardData(cards1, specialType, gameplay, wanglai)

    local card3 = cardNode:getChildByName('card' .. 3)
    local card4 = cardNode:getChildByName('card' .. 4)
    local card5 = cardNode:getChildByName('card' .. 5)
        
    local rX = 10
    if groupInfo[2] and #groupInfo[2] == 1 then
        local x5, y5 = card5:getPosition()
        card5:setPosition(cc.p(x5, y5 + rX))
    elseif groupInfo[2] and #groupInfo[2] == 2 then
        local x4, y4 = card4:getPosition()
        local x5, y5 = card5:getPosition()
        card4:setPosition(cc.p(x4, y4 + rX))
        card5:setPosition(cc.p(x5, y5 + rX))
    end

    local SUIT_UTF8_LENGTH = 3
    local function card_suit(c)
        if not c then print(debug.traceback()) end
        if c == '☆' or c == '★' then
            return c
        else
            return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
        end
    end
    
    local function card_rank(c)
        return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH+1, #c) or nil
    end
    
    local j = 1
    for i, v in pairs(gCard) do
        local card = cardNode:getChildByName('card' .. j)
        local suit = SUIT[card_suit(v)]
        local rnk = card_rank(v)

        local path
        if suit == 'j1' or suit == 'j2' then
            path = 'views/xydesk/cards/' .. suit .. '.png'
        else
            path = 'views/xydesk/cards/' .. suit .. rnk .. '.png'
        end
        card:loadTexture(path)
        j = j + 1
    end

    local path = ''
    specialTypeImg:setVisible(false)
    typeImg:setVisible(false)
    if specialType > 0 then
        local gameplayIdx = self.desk:getGameplayIdx()
        path = 'views/xydesk/result/' .. GameLogic.getSpecialTypeByVal(gameplayIdx, specialType) .. '.png'
        specialTypeImg:loadTexture(path)
        specialTypeImg:setVisible(true)
    else
        path = 'views/xydesk/result/' .. niuCnt .. '.png'
        typeImg:loadTexture(path)   
        typeImg:setVisible(true)     
    end
    
end

return PlaybackView
