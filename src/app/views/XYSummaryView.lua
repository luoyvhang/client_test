local cache = require('app.helpers.cache')
local app = require('app.App'):instance()
local GameLogic = require('app.libs.niuniu.NNGameLogic')

local XYSummaryView = {}

function XYSummaryView:layout(data)
    local mainPanel = self.ui:getChildByName('MainPanel')
    mainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = mainPanel
    --self.MainPanel:setScale(1.15)
    local panel = mainPanel:getChildByName('Panel')
    if data.groupInfo then 
        panel = mainPanel:getChildByName('Panel1')
    end
    panel:setVisible(true)

    self.panel = panel

    local item1 = panel:getChildByName('item1')
    local item2 = panel:getChildByName('item2')
    local item3 = panel:getChildByName('item3')
    self.item1 = item1
    self.item2 = item2
    self.item3 = item3
    local subList = panel:getChildByName('subList')
    subList:setItemModel(item1)
    subList:removeAllItems()
    subList:setScrollBarEnabled(false)
    local summaryList = panel:getChildByName('summaryList')
    summaryList:setItemModel(subList)
    summaryList:removeAllItems()
    summaryList:setScrollBarEnabled(false)
    self.subList = subList
    self.summaryList = summaryList

    if data.records then
    self.records = data.records
    else
    self.records = data.record
    end
    self.ownerName = data.ownerName

    local rounds
    for _,v in pairs(self.records) do
       rounds=v.loseCnt+v.winCnt
    end

    local app = require("app.App"):instance()
  	self.user = app.session.user

    dump(data)
    self.item = panel:getChildByName('item')
    self:loadSummaryList(data)

    local deskInfo = data.deskInfo
    local roomId = panel:getChildByName('roomId')
    roomId:setString("" .. data.deskId)

    if data.groupInfo then 
        local clubId = panel:getChildByName('clubId')
        clubId:setString(data.groupInfo.id)
    end

    local round = panel:getChildByName('round')
    round:setString("" .. deskInfo.round)

    local base = panel:getChildByName('base')
    local tabBaseStr = {
        ['1/2'] = '1/2',
		['2/4'] = '2/4',
		['3/6'] = '3/6',
		['4/8'] = '4/8',
		['5/10'] = '5/10',
    }
    local baseStr = tabBaseStr[deskInfo.base] or deskInfo.base
    base:setString("" .. baseStr)

    local gameplay = panel:getChildByName('gameplay')
    gameplay:setString(GameLogic.getGameplayText(deskInfo))

    local date = panel:getChildByName('date')
    local time = data.time or os.time()
    date:setString(os.date("%Y/%m/%d %H:%M:%S", time))
end

function XYSummaryView:getWinner(tbl)
    local score, key
    for k, v in pairs(tbl) do
        if score == nil and key == nil then
            score, key = v.score, k
        else
            if score < v.score then
                score, key = v.score, k
            end
        end
    end

    return score
end

function XYSummaryView:getloser(tbl) -- 获取土豪（输最多的人）
    local score, key
    for k, v in pairs(tbl) do
        if score == nil and key == nil then
            score, key = v.score, k
        else
            if score >= v.score then
                score, key = v.score, k
            end
        end
    end

    return score
end

function XYSummaryView:loadSummaryList(data)

    --itemCnt:3列或4列; subListNum:第一排或第二排
    local function freshSublist(subList, itemCnt, subListNum, players, winnerScore, loserScore)
        local idx = 0
        local record        
        for i, v in ipairs(players) do
            repeat
                if itemCnt == 3 and i >= 4 and subListNum == 1 then --6人第1排
                    break
                elseif itemCnt == 4 and i >= 5 and subListNum == 1 then --8人第1排
                    break
                elseif itemCnt == 5 and i >= 6 and subListNum == 1 then --10人第1排
                    break
                elseif itemCnt == 3 and subListNum == 2 then --6人第2排
                    if i <= 3 then break end
                elseif itemCnt == 4 and subListNum == 2 then --8人第2排
                    if i <= 4 then break end
                elseif itemCnt == 5 and subListNum == 2 then --10人第2排
                    if i <= 5 then break end
                end
                record = self.records[v.uid]
                subList:pushBackDefaultItem()
                local item = subList:getItem(idx)
                self:freshItem(item, v, record, winnerScore, loserScore, #players)
                idx = idx + 1
                break
            until true
        end
    end

    local function freshSummaryList(pieceCnt, itemCnt, players, winnerScore, loserScore)
        for i = 1, pieceCnt do
            self.summaryList:pushBackDefaultItem()
            local subList = self.summaryList:getItem(i-1)
            freshSublist(subList, itemCnt, i, players, winnerScore, loserScore)	
        end
    end

    --按分数排序
    local function sortScore(data)
        -- 按大到小排序
	    table.sort(data, function(a, b)
            local A = a.result or a.money
            local B = b.result or b.money

            if A > B then return true end
            return false
	    end)
    end

    local players
    if data.players then
        players = data.players
    else
        players = data.fsummay
    end
    
    sortScore(players) --按分数排序

    local winnerScore = self:getWinner(self.records)
    local loserScore = self:getloser(self.records)

    local pieceCnt = 1 --一排或两排
    local itemCnt = 3 --每排最多列数(3或4)
    if #players == 0 then return end
    if #players > 8 then
        self.subList:setItemModel(self.item3)
        pieceCnt = 2
        itemCnt = 5
    elseif #players > 6 then
        self.subList:setItemModel(self.item2)
        pieceCnt = 2
        itemCnt = 4
    else
        if #players > 3 then pieceCnt = 2 end
        self.subList:setItemModel(self.item1)
    end

    self.subList:removeAllItems()    
    self.summaryList:removeAllItems()    
    freshSummaryList(pieceCnt, itemCnt, players, winnerScore, loserScore)
end

--[[ function XYSummaryView:loadSummaryList(data)
    
    --local list = self.list
    
    local players
    if data.players then
    players = data.players
    else
    players = data.fsummay
    end

    local winner = self:getWinner(self.records)
    local loser = self:getloser(self.records)
    --print(" -> winner : ", winner)

    local w = 0
    for i, v in ipairs(players) do
        --list:pushBackDefaultItem()
        local item = self.item:clone()
        self.panel:addChild(item)
        self:freshItem(item, v, self.records[v.uid], winner,loser)

        local grid = self.panel:getChildByName(tostring(i))
        local gsz = grid:getContentSize()
        local gx, gy = grid:getPosition()
        item:setPosition(cc.p(gx - gsz.width / 2, gy - gsz.height / 2))
    end
end ]]

function XYSummaryView:freshItem(item, player, record, win, lose, playernum)
    if record then
        -- 抢庄, 庄家, 推注次数
        local textQiang = item:getChildByName('Text_qiang')
        textQiang:setString(record.qiangCnt or 0)

        local textZuo = item:getChildByName('Text_zuo')
        textZuo:setString(record.bankerCnt or 0)

        local textTui = item:getChildByName('Text_tui')
        textTui:setString(record.pushCnt or 0)
    end


	local head = item:getChildByName('head')
	local name =(head:getChildByName('namePanel')):getChildByName('name')
	name:setString(player.nickName)
	
	local id =(head:getChildByName('IDPanel')):getChildByName('id')
	id:setString(player.playerId)
	
	local img = head:getChildByName('img')
	img:retain()
	cache.get(player.avatar, function(ok, path)
		if ok then
			img:loadTexture(path)
		end
		img:release()
	end)

    local bg1 = item:getChildByName('bg1')
	local bg2 = item:getChildByName('bg2')
	local bg3 = item:getChildByName('bg3')
	local bg4 = item:getChildByName('bg4')
	bg1:setVisible(false)
	bg2:setVisible(false)
	bg3:setVisible(false)
    bg4:setVisible(false)

    local playerscore = player.score or player.money

	if self.user.playerId == player.playerId then
		if playerscore == win or playerscore == lose then
			bg2:setVisible(true)
		else
			bg3:setVisible(true)
		end
	else
		if playerscore == win or playerscore == lose then
			bg1:setVisible(true)
		else
			bg4:setVisible(true)
		end
	end

    local owner = item:getChildByName('owner')
    owner:setVisible(false)
	if player.nickName == self.ownerName then
		owner:setVisible(true)
	end
	
    local top = item:getChildByName("top")
    --listView里面放scd动画的Node节点无法获取,神坑
    --只能在代码里面手动添加Node节点
    if playerscore == win then
        -- local node =  cc.CSLoader:createNode("views/xysummary/winnerAnimation.csb")
        -- item:addChild(node)
        -- node:setPosition(top:getPosition())
        -- self:startCsdAnimation(node,"winnerAnimation",true, 1.3)
        top:loadTexture('views/record/winner.png')
    elseif playerscore == lose then
        -- local node =  cc.CSLoader:createNode("views/xysummary/loserAnimation.csb")
        -- item:addChild(node)
        -- node:setPosition(top:getPosition())
        -- self:startCsdAnimation(node,"loserAnimation",true, 1.3)
        top:loadTexture('views/record/loser.png')
	end
    
    local total = item:getChildByName('total'):getChildByName('result')
	local zheng = total:getChildByName('zheng')
    local fu = total:getChildByName('fu')
    zheng:setVisible(false)
	fu:setVisible(false)
    local playerresult = player.result or player.money
    
	if playerresult then
		if playerresult > 0 then
            zheng:getChildByName('value'):setString(math.abs(playerresult))
            zheng:getChildByName('value'):getChildByName('sign'):setVisible(true)
        	zheng:setVisible(true)
		else
            fu:getChildByName('value'):setString(math.abs(playerresult))
            fu:getChildByName('value'):getChildByName('sign'):setVisible(playerresult ~= 0)
        	fu:setVisible(true)
		end
	end

	-- local total = (item:getChildByName('total')):getChildByName('cnt')
    -- if record and record.score >= 0 then
    --     total:setColor(cc.c3b(255,0,0))
    --     total:setString("+"..record.score)
    -- elseif record and record.score < 0 then
    --     total:setColor(cc.c3b(56,157,16))
	--     total:setString(record.score)
    -- else 
    --     item:setVisible(false)
    --     total:setColor(cc.c3b(255,0,0))
    --     total:setString("--")
    -- end
end

function XYSummaryView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/xysummary/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
      action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function XYSummaryView:startPlistAnimation( plistName, sprite, length)
    local spriteFrame = cc.SpriteFrameCache:getInstance( )  
    spriteFrame:addSpriteFrames( "views/xysummary/"..plistName..".plist" )  
         
    local animation = cc.Animation:create()  
    for i=1, 9 do  
        -- local frameName = string.format( "shuohua%01d.png", i )  
        local blinkFrame = spriteFrame:getSpriteFrame( string.format( "shuohua%01d.png", i ) )  
        animation:addSpriteFrame( blinkFrame )  
    end  
    for i=10, length do  
        -- local frameName = string.format( "shuohua%02d.png", i )  
        local blinkFrame = spriteFrame:getSpriteFrame( string.format( "shuohua%02d.png", i ) )  
        animation:addSpriteFrame( blinkFrame )  
    end 
    animation:setDelayPerUnit( 0.1 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( true )--设置播放完成后是否回归最初状态  
    local action = cc.Animate:create(animation)  
    sprite:runAction( cc.RepeatForever:create( action ) )
end



return XYSummaryView
