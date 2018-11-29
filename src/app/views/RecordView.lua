local Scheduler = require('app.helpers.Scheduler')
local cache = require('app.helpers.cache')
local Controller = require('mvc.Controller')
local TranslateView = require('app.helpers.TranslateView')
local SoundMng = require "app.helpers.SoundMng"
local app = require('app.App'):instance()
local GameLogic = require('app.libs.niuniu.NNGameLogic')
local RecordView = {}


function RecordView:initialize()
	self.updateF = Scheduler.new(function(dt)
		self:update(dt)
	end)
	
	self.delay = 0
	self:enableNodeEvents()
	
	self.suit_2_path = {
		['♠'] = 'h',
		['♣'] = 'm',
		['♥'] = 'z',
		['♦'] = 'f',
		['★'] = 'j1',
		['☆'] = 'j2',
	}
	
	self.CARDS = {
		['♠A'] = 1, ['♠2'] = 2, ['♠3'] = 3, ['♠4'] = 4, ['♠5'] = 5,
		['♠6'] = 6, ['♠7'] = 7, ['♠8'] = 8, ['♠9'] = 9,
		['♠T'] = 10, ['♠J'] = 10, ['♠Q'] = 10, ['♠K'] = 10,
		
		['♥A'] = 1, ['♥2'] = 2, ['♥3'] = 3, ['♥4'] = 4, ['♥5'] = 5,
		['♥6'] = 6, ['♥7'] = 7, ['♥8'] = 8, ['♥9'] = 9,
		['♥T'] = 10, ['♥J'] = 10, ['♥Q'] = 10, ['♥K'] = 10,
		
		['♣A'] = 1, ['♣2'] = 2, ['♣3'] = 3, ['♣4'] = 4, ['♣5'] = 5,
		['♣6'] = 6, ['♣7'] = 7, ['♣8'] = 8, ['♣9'] = 9,
		['♣T'] = 10, ['♣J'] = 10, ['♣Q'] = 10, ['♣K'] = 10,
		
		['♦A'] = 1, ['♦2'] = 2, ['♦3'] = 3, ['♦4'] = 4, ['♦5'] = 5,
		['♦6'] = 6, ['♦7'] = 7, ['♦8'] = 8, ['♦9'] = 9,
		['♦T'] = 10, ['♦J'] = 10, ['♦Q'] = 10, ['♦K'] = 10,
		['☆'] = 10, ['★'] = 10
	}
end 

function RecordView:getCardValue(var)
    return self.CARDS[var]
end

function RecordView:onExit()
    Scheduler.delete(self.updateF)
    self.updateF = nil
end

function RecordView:update(dt)
    self.delay = self.delay + dt
    if self.delay > 5.0 then
    self.delay = 0

    --self.emitter:emit('fresh')
    end
end

function RecordView:layout()
    local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setContentSize(cc.size(display.width,display.height))
    MainPanel:setPosition(display.cx,display.cy)
    self.MainPanel = MainPanel

    local bg = MainPanel:getChildByName('bg')
    bg:setPosition(display.cx, display.cy)
    self.bg = bg

	self.ntLayer = bg:getChildByName('ntLayer')
	self.ctLayer = bg:getChildByName('ctLayer')

    local list = bg:getChildByName('nt'):getChildByName('list')
    list:setItemModel(bg:getChildByName("row"))
	list:removeAllItems()
	list:setVisible(false)
	self.list = list
	
	local list1 = bg:getChildByName('ct'):getChildByName('list1')
    list1:setItemModel(bg:getChildByName("row_club"))
    list1:removeAllItems()
    self.list1 = list1

	local app = require("app.App"):instance()
  	self.user = app.session.user


    local infobg=MainPanel:getChildByName('infoBg')
    infobg:setPosition(display.cx, display.cy)
    self.infobg=infobg

    local listView = infobg:getChildByName('Panel'):getChildByName('ListView')
    local ListViewItem0 = infobg:getChildByName('Panel'):getChildByName('ListViewItem0')
    local ListViewItem1 = infobg:getChildByName('Panel'):getChildByName('ListViewItem1')
    local ListViewItem2 = infobg:getChildByName('Panel'):getChildByName('ListViewItem2')
    listView:setItemModel(ListViewItem0)
    listView:removeAllItems()
    self.ListViewItem0 = ListViewItem0
    self.ListViewItem1 = ListViewItem1 --self.ListViewItem1玩家超过6人时使用
    self.ListViewItem2 = ListViewItem2 --self.ListViewItem2玩家超过8人时使用
    self.listView = listView

    local listTopView = infobg:getChildByName('ListTopView')
    local ListTopItem0 = infobg:getChildByName('ListTopItem0')
    local ListTopItem1 = infobg:getChildByName('ListTopItem1')
    local ListTopItem2 = infobg:getChildByName('ListTopItem2')
    listTopView:setItemModel(ListTopItem0)
    listTopView:removeAllItems()
    self.ListTopItem0 = ListTopItem0
    self.ListTopItem1 = ListTopItem1 --self.ListTopItem1玩家超过6人时使用
    self.ListTopItem2 = ListTopItem2 --self.ListTopItem2玩家超过8人时使用
    self.listTopView = listTopView

    local ListBottomView = infobg:getChildByName('ListBottomView')
    local ListBottomItem0 = infobg:getChildByName('ListBottomItem0')
    local ListBottomItem1 = infobg:getChildByName('ListBottomItem1')
    local ListBottomItem2 = infobg:getChildByName('ListBottomItem2')
    ListBottomView:setItemModel(ListBottomItem0)
    ListBottomView:removeAllItems()
    self.ListBottomItem0 = ListBottomItem0
    self.ListBottomItem1 = ListBottomItem1 --self.ListBottomItem1玩家超过6人时使用
    self.ListBottomItem2 = ListBottomItem2 --self.ListBottomItem2玩家超过8人时使用
	self.ListBottomView = ListBottomView
	
	self.namelayer = infobg:getChildByName('namelayer')
	self.namelayer:setLocalZOrder(999)
	
	self:freshClubTips(true)
	self:freshTips(true)
	local sender = bg:getChildByName('nt')
	self:freshTab(sender)
end

function RecordView:getWinner(players)
    local result
    for k, v in ipairs(players) do
        if result == nil then
            result = v.result
        else
            if result < v.result then
                result = v.result
            end
        end
    end
    return result
end

function RecordView:getloser(players)
    local result
    for k, v in ipairs(players) do
        if result == nil then
            result = v.result
        else
            if result >= v.result then
                result = v.result
            end
        end
    end
    return result
end

function RecordView:getorder(players)
	-- 自己为第一人
    -- local orderplayers = players
    -- local orderplayers1 = players[1]
    -- for i, v in ipairs(players) do
    --     if v.playerId == self.user.playerId then
    --         orderplayers[1] = v
    --         orderplayers[i] = orderplayers1
    --     end
	-- end

	--从大到小
	-- 按大到小排序
	table.sort(players, function(a, b)
		local A = a.result or a.money
		local B = b.result or b.money

		if A > B then return true end
		return false
	end)
end

function RecordView:freshRowInfo(rItem, data)
	local rList = rItem:getChildByName('rlist')
	if data and #data.player <= 6 then
		rList:setItemModel(self.bg:getChildByName("rItem"))
	elseif #data.player <= 8 then
		rList:setItemModel(self.bg:getChildByName("rItem1"))
	else
		rList:setItemModel(self.bg:getChildByName("rItem2"))
	end
    rList:removeAllItems()



    local players = data.player
    local winner = self:getWinner(players)
	local loser = self:getloser(players)
	self:getorder(players)

	if (#players > 3 and #players <= 6) or (#players > 6) then
		local rList2 = rItem:getChildByName('rlist2')
		local playMode = 6
		if #players > 3 and #players <= 6 then
			rList2:setItemModel(self.bg:getChildByName("rItem"))
		elseif #players <= 8 then
			playMode = 8
			rList2:setItemModel(self.bg:getChildByName("rItem1")) --6人以上
		else
			playMode = 10
			rList2:setItemModel(self.bg:getChildByName("rItem2")) --6人以上
		end
		rList2:removeAllItems()
		rList2:setEnabled(false)

		for i, v in ipairs(players) do
			if playMode == 6 and i <= 3 then
				rList:pushBackDefaultItem()
				local item = rList:getItem(i - 1)
				self:freshRListItem(item, v,winner,loser, data.ownerName, #players)
				rList:setEnabled(false) -- 禁止滑动
			elseif playMode == 6 and i > 3 then
				rList2:pushBackDefaultItem()
				local item = rList2:getItem(i - 4)
				self:freshRListItem(item, v,winner,loser, data.ownerName, #players)
				rList2:setEnabled(false) -- 禁止滑动
			elseif playMode == 8 and i <= 4 then
				rList:pushBackDefaultItem()
				local item = rList:getItem(i - 1)
				self:freshRListItem(item, v,winner,loser, data.ownerName, #players)
				rList:setEnabled(false) -- 禁止滑动
			elseif playMode == 8 and i > 4 then
				rList2:pushBackDefaultItem()
				local item = rList2:getItem(i - 5)
				self:freshRListItem(item, v,winner,loser, data.ownerName, #players)
				rList2:setEnabled(false) -- 禁止滑动
			elseif playMode == 10 and i <= 5 then
				rList:pushBackDefaultItem()
				local item = rList:getItem(i - 1)
				self:freshRListItem(item, v,winner,loser, data.ownerName, #players)
				rList:setEnabled(false) -- 禁止滑动
			elseif playMode == 10 and i > 5 then
				rList2:pushBackDefaultItem()
				local item = rList2:getItem(i - 6)
				self:freshRListItem(item, v,winner,loser, data.ownerName, #players)
				rList2:setEnabled(false) -- 禁止滑动
			end
        end
	
	else
		for i, v in ipairs(players) do
			rList:pushBackDefaultItem()
			local item = rList:getItem(i - 1)
			self:freshRListItem(item, v,winner,loser, data.ownerName, #players)
			rList:setEnabled(false) -- 禁止滑动
        end
	end
	
	local clubId = rItem:getChildByName('clubId')
	if data.groupInfo then 
		clubId:setString(data.groupInfo.id)
	end
    local roomId = rItem:getChildByName('roomId')
    if data.deskId then
        roomId:setString( data['deskId'])
    end
    local round = rItem:getChildByName('round')
    if data.round then
        round:setString(data['round'])
    end

    local base = rItem:getChildByName('base')
	if data.base then
		local tabBaseStr = {
			['1/2'] = '1/2',
			['2/4'] = '2/4',
			['3/6'] = '3/6',
			['4/8'] = '4/8',
			['5/10'] = '5/10',
		}
		local baseStr = tabBaseStr[data['base']] or data['base']
        base:setString(baseStr)  
    end

    local gameplay = rItem:getChildByName('gameplay')
    if data.gameplay then
        gameplay:setString(GameLogic.getGameplayText(data))
    end

	local date = rItem:getChildByName('date')
    date:setString(os.date("%Y/%m/%d %H:%M:%S", data['time']))
end

function RecordView:freshRListItem(item, player, win, lose, ownerName, playernum)
	
	local bg1 = item:getChildByName('bg1')
	local bg2 = item:getChildByName('bg2')
	local bg3 = item:getChildByName('bg3')
	local bg4 = item:getChildByName('bg4')
	bg1:setVisible(false)
	bg2:setVisible(false)
	bg3:setVisible(false)
	bg4:setVisible(false)
	bg1:setVisible(true)
	-- 抢庄, 庄家, 推注次数
	local textQiang = item:getChildByName('Text_qiang')
	textQiang:setString(player.qiangCnt or 0)

	local textZuo = item:getChildByName('Text_zuo')
	textZuo:setString(player.bankerCnt or 0)

	local textTui = item:getChildByName('Text_tui')
	textTui:setString(player.pushCnt or 0)


	if self.user.playerId == player.playerId then
		-- if player.result == win or player.result == lose then
		-- 	bg2:setVisible(true)
		-- else
		-- 	bg3:setVisible(true)
		-- end
		item:getChildByName('frame'):setVisible(true)
	else
		-- if player.result == win or player.result == lose then
		-- 	bg1:setVisible(true)
		-- else
		-- 	bg4:setVisible(true)
		-- end
	end

	local head = item:getChildByName('head')
	local name =(head:getChildByName('name')):getChildByName('value')
	if player.nickName then
		name:setString(player.nickName)
	end
	
	local id =(head:getChildByName('id')):getChildByName('value')
	if player.playerId then
		id:setString(player.playerId)
	end
	
	local img = head:getChildByName('img')
	if player.avatar then
		img:retain()
		cache.get(player.avatar, function(ok, path)
			if ok then
				img:loadTexture(path)
			end
			img:release()
		end)
	end
	
	local owner = item:getChildByName('owner')
	owner:setVisible(false)
	if player.nickName == ownerName then
		owner:setVisible(true)
	end

	local top = item:getChildByName('top')
	if player.result == win then
		-- local node =  cc.CSLoader:createNode("views/xysummary/winnerAnimation.csb")
        -- item:addChild(node)
        -- node:setPosition(top:getPosition())
		-- self:startCsdAnimation(node,"winnerAnimation",true, 1.3)
		top:loadTexture('views/record/winner.png')
	elseif player.result == lose then
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
	
	if player.result then
		if player.result > 0 then
			zheng:getChildByName('value'):setString(math.abs(player.result))
			zheng:getChildByName('value'):getChildByName('sign'):setVisible(true)
        	zheng:setVisible(true)
		else
			fu:getChildByName('value'):getChildByName('sign'):setVisible(player.result ~= 0)
        	fu:getChildByName('value'):setString(math.abs(player.result))
        	fu:setVisible(true)
		end
	end
end 

function RecordView:freshTips(bool)
	bool = bool or false
	local tips = self.bg:getChildByName('ntLayer'):getChildByName('tips')
	tips:setVisible(bool)
end

function RecordView:freshClubTips(bool)
	bool = bool or false
	local tips = self.bg:getChildByName('ctLayer'):getChildByName('clubtips')
	tips:setVisible(bool)
end

function RecordView:pushBackRecords(record)
	if not record then return end
	local tips = self.bg:getChildByName('ntLayer'):getChildByName('tips')
	tips:setVisible(false)
	-- self.list:setVisible(true)
	
	if #record.player > 3 then
		self.list:setItemModel(self.bg:getChildByName("row"))
	else
		self.list:setItemModel(self.bg:getChildByName("row_custom"))
	end
	
	self.list:pushBackDefaultItem()
	
	local tabItem = self.list:getItems()
	local item = tabItem[#tabItem]

	self:freshRowInfo(item, record)
	
	local btn_info = item:getChildByName('info')
	btn_info:setTouchEnabled(true)
	btn_info:addClickEventListener(function()
		--每一轮的数据
		self:listOnceRecords(record)
	end)
	
	local btn_info = item:getChildByName('share')
	btn_info:setTouchEnabled(true)
	btn_info:addClickEventListener(function()
		--每一轮的数据
		self:gotoSummaryShareRecord(record)
	end)
	
end 

function RecordView:pushBackClubRecords(record)
	if not record then return end
	local tips = self.bg:getChildByName('ctLayer'):getChildByName('clubtips')
	tips:setVisible(false)
	-- self.list1:setVisible(true)
	
	if #record.player > 3 then
		self.list1:setItemModel(self.bg:getChildByName("row_club"))
	else
		self.list1:setItemModel(self.bg:getChildByName("row_club_br"))
	end
	
	self.list1:pushBackDefaultItem()
	
	local tabItem = self.list1:getItems()
	local item = tabItem[#tabItem]

	self:freshRowInfo(item, record)
	
	local btn_info = item:getChildByName('info')
	btn_info:setTouchEnabled(true)
	btn_info:addClickEventListener(function()
		--每一轮的数据
		self:listOnceRecords(record)
	end)
	
	local btn_info = item:getChildByName('share')
	btn_info:setTouchEnabled(true)
	btn_info:addClickEventListener(function()
		--每一轮的数据
		self:gotoSummaryShareRecord(record)
	end)
	
end 

function RecordView:listRecords(records)
--
    --local DetailedRecordTable=app.localSettings:getDetailedRecordConfigTable()
   -- dump(DetailedRecordTable[1].records[1].bottom.hand)

    local tips = self.bg:getChildByName('ntLayer'):getChildByName('tips')
    if #records == 0 then
        self.list:setVisible(false)
        tips:setVisible(true)
        return
    end
    
    self.list:setVisible(true)
    tips:setVisible(false)

	-- records 排序 将自己放在第一位
	-- for _, v in ipairs(records) do
	-- 	for j, w in ipairs(v.player) do
	-- 		if w.playerId == self.user.playerId and j ~= 1 then
	-- 			local temp = v.player[1]
	-- 			v.player[1] = v.player[j]
	-- 			v.player[j] = temp
	-- 		end
	-- 	end
	-- end

    local items = self.list:getItems()
    local diff = #records - #items
  
    if diff > 0 then
      for i = 1,diff do
		local playerCnt = #records[i].player		
		if (playerCnt > 3 and playerCnt <= 6) or (playerCnt > 6) then
			self.list:setItemModel(self.bg:getChildByName("row"))
		else
			self.list:setItemModel(self.bg:getChildByName("row_custom"))
		end

		self.list:pushBackDefaultItem()
      end
    else
      for _ = 1, math.abs(diff) do
        self.list:removeLastItem()
      end
    end

    for i, v in pairs(records) do
        local item = self.list:getItem(i - 1)
        self:freshRowInfo(item, v)

        local btn_info=item:getChildByName('info')
        btn_info:setTouchEnabled(true)
        btn_info:addClickEventListener(function ()
        --每一轮的数据
        self:listOnceRecords(v)
    	end)

		local btn_info=item:getChildByName('share')
        btn_info:setTouchEnabled(true)
        btn_info:addClickEventListener(function ()
        --每一轮的数据
        self:gotoSummaryShareRecord(v)
    	end)
     
    end
end

function RecordView:listClubRecords(records)
	--
	--local DetailedRecordTable=app.localSettings:getDetailedRecordConfigTable()
	-- dump(DetailedRecordTable[1].records[1].bottom.hand)
	
	local tips = self.bg:getChildByName('ctLayer'):getChildByName('clubtips')
	if #records == 0 then
		self.list1:setVisible(false)
		tips:setVisible(true)
		return
	end
		
	self.list1:setVisible(true)
	tips:setVisible(false)
	
	-- records 排序 将自己放在第一位
	-- for _, v in ipairs(records) do
	-- 	for j, w in ipairs(v.player) do
	-- 		if w.playerId == self.user.playerId and j ~= 1 then
	-- 			local temp = v.player[1]
	-- 			v.player[1] = v.player[j]
	-- 			v.player[j] = temp
	-- 		end
	-- 	end
	-- end
	
	local items = self.list1:getItems()
	local diff = #records - #items
	  
	if diff > 0 then
		for i = 1,diff do
		local playerCnt = #records[i].player		
		if (playerCnt > 3 and playerCnt <= 6) or (playerCnt > 6) then
			self.list1:setItemModel(self.bg:getChildByName("row_club"))
		else
			self.list1:setItemModel(self.bg:getChildByName("row_club_br"))
		end
	
		self.list1:pushBackDefaultItem()
		end
	else
		for _ = 1, math.abs(diff) do
		self.list1:removeLastItem()
		end
	end
	
	for i, v in pairs(records) do
		local item = self.list:getItem(i - 1)
		self:freshRowInfo(item, v)
	
		local btn_info=item:getChildByName('info')
		btn_info:setTouchEnabled(true)
		btn_info:addClickEventListener(function ()
		--每一轮的数据
		self:listOnceRecords(v)
		end)
	
		local btn_info=item:getChildByName('share')
		btn_info:setTouchEnabled(true)
		btn_info:addClickEventListener(function ()
		--每一轮的数据
		self:gotoSummaryShareRecord(v)
		end)
		 
	end
end

function RecordView:listOnceRecords(data)

	-- 通比牛牛模式隐藏庄家
	if data.gameplay == 5 then
		self.isTBGame = true
		self.TBbase = data.base
	else
		self.isTBGame = false
	end
	self.infobg:setVisible(true)
	self.bg:setVisible(false)
	
	local rounds = data.gameRecord
	local players = data.player
	
	if #players <= 6 then
		self.listView:setItemModel(self.ListViewItem0)
		self.listTopView:setItemModel(self.ListTopItem0)
		self.ListBottomView:setItemModel(self.ListBottomItem0)
	elseif #players <= 8 then
		self.listView:setItemModel(self.ListViewItem1)
		self.listTopView:setItemModel(self.ListTopItem1)
		self.ListBottomView:setItemModel(self.ListBottomItem1)
	else
		self.listView:setItemModel(self.ListViewItem2)
		self.listTopView:setItemModel(self.ListTopItem2)
		self.ListBottomView:setItemModel(self.ListBottomItem2)
	end
	self.listView:removeAllItems()
	self.listTopView:removeAllItems()
	self.ListBottomView:removeAllItems()	
	
	for i = 1, #rounds+3 do
		self.listView:pushBackDefaultItem()
	end

	for i=#rounds,#rounds+2 do
		local item = self.listView:getItem(i)
		item:setVisible(false)
	end
		
	for _ = 1, #players do	
		self.listTopView:pushBackDefaultItem()
		self.ListBottomView:pushBackDefaultItem()
	end
	
	for i, v in pairs(players) do
		local item1 = self.listTopView:getItem(i - 1)
		local item2 = self.ListBottomView:getItem(i - 1)
		self:freshNameAndResultInfo(item1, item2, v, i, #players)
	end
	
	local gameplay = data.gameplay

	--遍历每一轮的战绩
	for i, v in pairs(data.gameRecord) do
		local item = self.listView:getItem(i - 1)
		self:freshOnceRecordRowInfo(item, v, i, players)
		local btn_moveDown = item:getChildByName('MoveDown')
		local btn_moveUp = item:getChildByName('MoveUp')
		btn_moveUp:setTouchEnabled(true)
		btn_moveDown:setTouchEnabled(true)
	
		btn_moveUp:addClickEventListener(function()
			self:adjustmentRowSize(i, data.gameRecord, v, true, players, gameplay)
		end)
		
		btn_moveDown:addClickEventListener(function()
			btn_moveDown:setVisible(false)
			btn_moveUp:setVisible(true)
			self:adjustmentRowSize(i, data.gameRecord, v, false, players, gameplay)
		end)
		
	end
	
	local close = self.infobg:getChildByName('close')
	close:addClickEventListener(function()
		
		self.infobg:setVisible(false)
		self.bg:setVisible(true)
		self:recoveryState(data.gameRecord)
		
	end)
end 

function RecordView:adjustmentRowSize(key, data, onceData, bool, players, gameplay)
	--dump(data)
	local rowSize = self.listView:getItem(0):getContentSize()

	for i, v in ipairs(data) do
		
		local item = self.listView:getItem(i - 1)
		local listCol = item:getChildByName('ListCol')
		local image = item:getChildByName('Image')
		local pos = cc.p(item:getPosition())
		local listColSize=listCol:getContentSize()
	
		local btn_moveDown = item:getChildByName('MoveDown')
		local btn_moveUp = item:getChildByName('MoveUp')
		
		if bool then
			if i == key then	
				listCol:setVisible(true)
				listCol:setItemModel(listCol:getItem(0))
				listCol:removeAllItems()
				image:setVisible(true)
				
				btn_moveDown:setVisible(true)
				btn_moveUp:setVisible(false)
				
				local n = 1
				for k, v in pairs(players) do
					listCol:pushBackDefaultItem()
					local itemCol = listCol:getItem(n - 1)
					if onceData[v.uid] then
						self:freshOnceRecordColInfo(itemCol, onceData[v.uid], gameplay)
						itemCol:setVisible(true)
					else
						itemCol:setVisible(false)
					end
					n = n + 1
				end
			else
				listCol:setVisible(false)
				image:setVisible(false)
				btn_moveDown:setVisible(false)
				btn_moveUp:setVisible(true)
			end
			
			
			if i < key then	
				self.listView:getItem(i):setPosition(0, pos.y - rowSize.height)
				
			end
			
			if i > key then
				local po = cc.p(self.listView:getItem(i - 2):getPosition())
				if i - 1 == key then
					item:setPosition(cc.p(0, po.y - listColSize.height - rowSize.height))
				else
					item:setPosition(cc.p(0, po.y - rowSize.height))
				end
			end
			
		else	
			
			self.listView:getItem(key - 1):getChildByName('ListCol'):setVisible(false)
			self.listView:getItem(key - 1):getChildByName('Image'):setVisible(false)
			
			if i > key then
				item:setPosition(cc.p(0, pos.y + listColSize.height))
			end
			
		end
		
	end
	
end 

function RecordView:recoveryState(data)

	for i, v in ipairs(data) do
        
		local item = self.listView:getItem(i - 1)

		local listCol = item:getChildByName('ListCol')
		listCol:setItemModel(listCol:getItem(0))
		listCol:removeAllItems()
		listCol:setVisible(false)

		local btn_moveDown = item:getChildByName('MoveDown')
		local btn_moveUp = item:getChildByName('MoveUp')
		btn_moveDown:setVisible(false)
		btn_moveUp:setVisible(true)

		local image = item:getChildByName('Image')
		image:setVisible(false)
	end
	
end 

function RecordView:freshNameAndResultInfo(item1,item2,playersData, key, playernum)
	local textName = item1:getChildByName('mash'):getChildByName('Text')
	local texttouch = item1:getChildByName('mash'):getChildByName('Touch')
	local total = item2:getChildByName('result')
	local zheng = total:getChildByName('zheng')
    local fu = total:getChildByName('fu')
    zheng:setVisible(false)
	fu:setVisible(false)
	
	textName:setString(playersData.nickName)
	if playersData.result >= 0 then
		zheng:getChildByName('value'):setString(math.abs(playersData.result))
		zheng:getChildByName('sign'):setVisible(true)
		zheng:setVisible(true)
	else
		fu:getChildByName('sign'):setVisible(playersData.result ~= 0)
		fu:getChildByName('value'):setString(math.abs(playersData.result))
		fu:setVisible(true)
	end

	texttouch:addClickEventListener(function ()
		self:showPlayerFullName(true, playersData, key, playernum)
	end)
end

function RecordView:showPlayerFullName(flag, playersData, key, playernum)
	self.namelayer:setVisible(flag)
	if not playersData then return end
	local namebg = self.namelayer:getChildByName('bg')
	local name = namebg:getChildByName('Text')
	name:setString(playersData.nickName)
	local key = key - 1 or 0
	if playernum > 8 then
		playernum = 10
	elseif playernum > 6 then
		playernum = 8
	else
		playernum = 6
	end
	local x = self.listTopView:getContentSize()
	local avan = key * x.width / playernum
	namebg:setPosition(cc.p(180 + avan, 585))
end

function RecordView:freshOnceRecordRowInfo(item, data, key, players)
		
    local listScore=item:getChildByName('ListScore')
    listScore:setItemModel(listScore:getItem(0))
    listScore:removeAllItems()

	
	local no = item:getChildByName('No')
	local noText = no:getChildByName('Text')
	noText:setString('第' .. key .. '局')
	local i = 1
	for k, v in pairs(players) do
		listScore:pushBackDefaultItem()
		local itemScore = listScore:getItem(i - 1)
		self:freshOnceRoundScore(itemScore, data[v.uid])
		i = i + 1
	end
	
end 

function RecordView:freshOnceRoundScore(item, v)
	local score = item:getChildByName('Text')
	if v and v.score >= 0 then
		score:setString("+" .. v.score)
		score:setColor(cc.c3b(249,182,98))
	elseif v and v.score < 0 then
		score:setString("-" ..math.abs(v.score))
		score:setColor(cc.c3b(167,149,224))
	else
		score:setString('--')
		score:setColor(cc.c3b(249,182,98))
	end
	
end

function RecordView:getCards(cards)
	local cardsT = {}
	local i = 1
	for k, v in pairs(cards) do
		table.insert(cardsT, i, k)
		i = i + 1
	end	
	
	return cardsT
end

function RecordView:freshTab(sender)
	self.bg:getChildByName('nt'):getChildByName('active'):setVisible(false)
	self.bg:getChildByName('ct'):getChildByName('active'):setVisible(false)
	sender:getChildByName('active'):setVisible(true)

	if sender:getName() == 'nt' then
		self.list:setVisible(true)
		self.list1:setVisible(false)
		self.ntLayer:setVisible(true)
		self.ctLayer:setVisible(false)
	elseif sender:getName() == 'ct' then 
		self.list:setVisible(false)
		self.list1:setVisible(true)
		self.ntLayer:setVisible(false)
		self.ctLayer:setVisible(true)
	end
end

function RecordView:freshOnceRecordColInfo(item, data, gameplay)
	local cards = item:getChildByName('cards')
	local niuCnt = item:getChildByName('niuCnt')
	local qiang = item:getChildByName('qiang')
	local banker = item:getChildByName('banker')
	local putScore = item:getChildByName('putScore')
	
	local isSpecial = (data.specialType and data.specialType > 0)

	local path = string.format('views/xydesk/result/%s.png', data.niuCnt)
	if isSpecial then
		path = string.format('views/xydesk/result/%s.png', GameLogic.getSpecialTypeByVal(gameplay, data.specialType))
	end

	niuCnt:loadTexture(path)

	local qiangCntpath = 'views/record/result/bq.png'
    if data.qiangCnt then
        qiangCntpath = 'views/record/result/' .. data.qiangCnt .. '.png'
    end
    qiang:loadTexture(qiangCntpath)
	
	local mycards = self:getCards(data.hand)
	local result = self:findNiuniu(mycards, data.specialType, gameplay)
	local n = 1
    local cardPos=cc.p(cards:getChildByName('card1'):getPosition()) 
	
	if result and not isSpecial then	
		for _, v in ipairs(result[1]) do
			for i, cv in ipairs(mycards) do
				if v == cv then		
					local card = cards:getChildByName('card' .. n)
					local p = self:getCardTexturePath(cv)
					card:loadTexture(p)
					n = n + 1
					table.remove(mycards, i)	
				end
			end
		end
		
		local m = 4
		for _, mv in ipairs(mycards) do	
			local card = cards:getChildByName('card' .. m)
			local nowCardPos=cc.p(card:getPosition())
			card:setPosition(cc.p(nowCardPos.x,cardPos.y+8))
			local p = self:getCardTexturePath(mv)
			card:loadTexture(p)
			m = m + 1
		end

	else
		for i, v in ipairs(mycards) do
			local card = cards:getChildByName('card' .. n)
			local p = self:getCardTexturePath(v)
			local nowCardPos=cc.p(card:getPosition())
			card:setPosition(cc.p(nowCardPos.x,cardPos.y))
			card:loadTexture(p)
			n = n + 1
		end
	end
	
	local mPath = string.format('views/xydesk/3x.png')
	-- local bPath = string.format('views/xydesk/i1.png')
	local gold = putScore:getChildByName('gold')
	local goldNum = putScore:getChildByName('Text')
	
	if data.nPutScore > 0 then
		goldNum:setString(data.nPutScore)
		gold:loadTexture(mPath)
		putScore:setVisible(true)
	else
		putScore:setVisible(false)
	end
	
	
	-- banker:loadTexture(bPath)
	if self.isTBGame then
		banker:setVisible(false)
		goldNum:setString(self.TBbase)
		gold:loadTexture(mPath)
		putScore:setVisible(true)
	else
		banker:setVisible(data.bIsBanker)
	end
	
end 

function RecordView:findNiuniu(cards, specialType, gameplay)
	-- 弃用原逻辑
    -- local niunius = {}
    -- local cnt = #cards
    -- for i = 1, cnt - 2 do
    --     for j = i + 1, cnt - 1 do
    --         for x = j + 1, cnt do
    --             local value = self:getCardValue(cards[i]) + self:getCardValue(cards[j]) + self:getCardValue(cards[x])
    --             if (value % 10) == 0 then
    --                 table.insert(niunius, {cards[i], cards[j], cards[x]})
    --             end
    --         end
    --     end
    -- end

    -- if table.empty(niunius) then
    --     return nil
    -- else
    --     return niunius
	-- end
	local cards, laizinum = GameLogic.sortCards(cards)
	local card, niuniusP = GameLogic.groupingCardData(cards, specialType, gameplay, laizinum)

	if niuniusP then
        return clone(niuniusP)
    else
        return nil
	end
end

function RecordView:getCardTexturePath(value)
    local suit = self.suit_2_path[self:card_suit(value)]
    local rnk = self:card_rank(value)

    local path
    if suit == 'j1' or suit == 'j2' then
         path = 'views/xydesk/cards/' .. suit .. '.png'
    else
       path = 'views/xydesk/cards/' .. suit .. rnk .. '.png'
    end

    return path
end

local SUIT_UTF8_LENGTH = 3
function RecordView:card_suit(c)
    if not c then print(debug.traceback()) end
    if c == '☆' or c == '★' then
        return c
    else
        return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
    end
end

function RecordView:card_rank(c)
    return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH+1, #c) or nil
end

function RecordView:getCardType(type)
	if type == "♠" then
		return "h"
	elseif type == "♣" then
		return "m"
	elseif type == "♥" then
		return "z"
	elseif type == "♦" then
		return "f"
	elseif type == "★" then
		return "j1"
	elseif type == "☆" then
		return "j2"
	end
end 

function RecordView:gotoSummaryShareRecord(msg)


	print('6666666')
	-- 配record
	local gameRecord = msg['gameRecord']
	local result = {}
	local record = {}
	local numberOfGames = 1
	for i, v in ipairs(gameRecord) do
		numberOfGames = i
	end
	local winC = numberOfGames
	print(888888888)
	print(winC)

	local index = 1
	for k, v in pairs(msg['player']) do
		print(1111111111111)
		print(k)
		record[v.uid] = {
			winCnt = winC, 
			loseCnt = 0, 
			score = v['result'],
			bankerCnt = v.bankerCnt or 0,
			qiangCnt = v.qiangCnt or 0,
			pushCnt = v.pushCnt or 0,
		}
		index = index + 1
	end
	result['record'] = record
	result['over'] = true
	result['deskInfo'] = {base = msg['base'], gameplay = msg['gameplay'], round = msg['round']}
	result['ownerName'] = msg['ownerName']
	result['fsummay'] = msg['player']
	result['deskId'] = msg['deskId']
	result['autoShare'] = true
	result['time'] = msg.time
	if msg.groupInfo then
		result.groupInfo = msg.groupInfo
	end
	
	print('777777')
	-- dump(result)

	--app:switch('XYSummaryController', result)
	--local lobbyController = require('app.controllers.LobbyController')
	--self:setWidgetAction('XYSummaryController', result)
	self.emitter:emit('shareRecord', result)
end

function RecordView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/xysummary/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
      action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

return RecordView
