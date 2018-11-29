local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVRoomCardListView = {}

local Text = {
	'当前状态：管理员尚未开启基金支付模式',
	'当前状态：管理员已经开启基金支付模式',
	'当前状态：管理员尚未开启全员可充值模式',
	'当前状态：管理员已经开启全员可充值模式',
	'当前状态：管理员尚未开启全员可查看模式',
	'当前状态：管理员已经开启全员可查看模式',
}

function GVRoomCardListView:initialize()
	self.group = nil
	self.isAdmin = nil
	self.isAdminFu = nil
	self.selectIdx = nil
	self.tabPlaying = {} -- k:playerId v:bool
	self.operationMode = 'none'
end

function GVRoomCardListView:layout(data)
	self.group = data[1]
	self.isAdmin = data[2]
	self.isAdminFu = data[3]
	self.gameState = nil

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)

	self.RoomCardLayer = mainPanel:getChildByName('RoomCardLayer')
	self.addRoomCardLayer = mainPanel:getChildByName('addRoomCardLayer')
	self.ZhangDanLayer = mainPanel:getChildByName('ZhangDanLayer')
	self:freshLayer(true,false,false)
	self:freshCurCard()
	self:analyseOptions()

	-- 账单列表
	local Item = self.ZhangDanLayer:getChildByName('info')
	self.infolist = self.ZhangDanLayer:getChildByName('infolist')
	self.infolist:setItemModel(Item)
	self.infolist:removeAllItems()
end

function GVRoomCardListView:freshinfoList()
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id
	local zhangdaninfo = self.group:getfoundationRecord(groupId)

	local idx = 0
	self.infolist:removeAllItems()
	for i,v in pairs(zhangdaninfo) do
		self.infolist:pushBackDefaultItem()
		local rowItem = self.infolist:getItem(idx)
		idx = idx + 1 
		self:freshinfoItem(rowItem, v)
	end
end

function GVRoomCardListView:freshinfoItem(item,data)
	if not data then return end

	local action = item:getChildByName('Text_action')
	if data.operation == 1 then
		action:setString('充值房卡')
	elseif data.operation == 2 then
		action:setString('取出房卡')
	elseif data.operation == 3 then
		action:setString('创建房间')
	-- elseif data.operation == 4 then
	-- 	action:setString('解散退还')
	end

	local price = item:getChildByName('Text_price')
	price:setString(data.number)

	local name = item:getChildByName('Text_name')
	name:setString(data.nickname)

	local id = item:getChildByName('Text_id')
	local idStr = '(ID:' .. data.playerId .. ')'
	id:setString(idStr)

	local time = item:getChildByName('Text_time')
	time:setString(os.date("%Y/%m/%d %H:%M:%S", data.time))
end

function GVRoomCardListView:getCurGroup()
	local groupInfo = self.group:getCurGroup()
	return groupInfo
end

function GVRoomCardListView:analyseOptions()
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id
	local data = self.group:getAdvanceOption(groupId)
	local flag1,flag2,flag3 = false, false, false
	if data.payMode == 2 then 
		flag1 = true
	end
	if data.chargeMode == 1 then 
		flag2 = true
	end
	if data.billMode == 1 then 
		flag3 = true
	end
	self:freshstatetext(flag1, flag2, flag3)
end

function GVRoomCardListView:freshstatetext(flag1, flag2, flag3)
	if not self.RoomCardLayer then 
		print("self.RoomCardLayer is nil")
		return 
	end

	local state1 = self.RoomCardLayer:getChildByName('1'):getChildByName('state')
	local state2 = self.RoomCardLayer:getChildByName('2'):getChildByName('state')
	local state3 = self.RoomCardLayer:getChildByName('3'):getChildByName('state')
	state1:setString(Text[1])
	state2:setString(Text[3])
	state3:setString(Text[5])

	if flag1 then 
		state1:setString(Text[2])
	end

	if flag2 then 
		state2:setString(Text[4])
	end

	if flag3 then 
		state3:setString(Text[6])
	end
end

function GVRoomCardListView:freshCurCard()
	if not self.RoomCardLayer then 
		print("self.RoomCardLayer is nil")
		return 
	end
	local groupInfo = self:getCurGroup()
	if not groupInfo then return end
	local diamond = groupInfo.diamond or 0
	local roomcardnum = self.RoomCardLayer:getChildByName('roomcard'):getChildByName('roomcardnum')
	roomcardnum:setString(diamond..'')
end

function GVRoomCardListView:freshSelfCard(idx)
	if not self.addRoomCardLayer then 
		print("self.addRoomCardLayer is nil")
		return 
	end

	local personalRoomCard = self.addRoomCardLayer:getChildByName('personalRoomCard')
	personalRoomCard:setString(idx)
end

function GVRoomCardListView:freshLayer(isroomcard,isaddroomcard,iszhangdan)
	self.RoomCardLayer:setVisible(isroomcard)
	self.addRoomCardLayer:setVisible(isaddroomcard)
	self.ZhangDanLayer:setVisible(iszhangdan)
end

function GVRoomCardListView:freshAddRoomCard(groupCardCnt, personalCardCnt, isMgr)	
	if not self.addRoomCardLayer then 
		print("self.addRoomCardLayer is nil")
		return 
	end
	
	self.addRoomCardLayer:getChildByName('groupRoomCard'):setString(groupCardCnt..'')
	self.addRoomCardLayer:getChildByName('personalRoomCard'):setString(personalCardCnt..'')

	local reduceBtn = self.addRoomCardLayer:getChildByName('reduceBtn')
	local addBtn = self.addRoomCardLayer:getChildByName('addBtn')
	local cardCnt = self.addRoomCardLayer:getChildByName('currentCardCnt')
	local cnt = 0
	cardCnt:setString(cnt..'')
	reduceBtn:addClickEventListener(function()
		cnt = cnt - 10
		if cnt < 0 then cnt = 0 end
		cardCnt:setString(cnt..'')
	end)	
	addBtn:addClickEventListener(function()
		cnt = cnt + 10
		cardCnt:setString(cnt..'')
	end)	

	local takeOutBtn = self.addRoomCardLayer:getChildByName('takeOutBtn')
	takeOutBtn:setEnabled(isMgr)
	takeOutBtn:addClickEventListener(function()
		if cnt > groupCardCnt then cnt = groupCardCnt end
		cardCnt:setString(cnt..'')
		self.emitter:emit('recaptionDiamond', cnt)
	end)	
	local saveBtn = self.addRoomCardLayer:getChildByName('saveBtn')
	saveBtn:addClickEventListener(function()
		if cnt > personalCardCnt then cnt = personalCardCnt end
		cardCnt:setString(cnt..'')
		self.emitter:emit('chargeDiamond', cnt)
	end)	
end

return GVRoomCardListView