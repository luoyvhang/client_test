local Scheduler = require('app.helpers.Scheduler')
local cache = require('app.helpers.cache')
local Controller = require('mvc.Controller')
local TranslateView = require('app.helpers.TranslateView')
local SoundMng = require "app.helpers.SoundMng"
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local app = require('app.App'):instance()
local GameLogic = require('app.libs.niuniu.NNGameLogic')
local LocalSettings = require('app.models.LocalSettings')

local testluaj = nil
local luaoc = nil
if device.platform == 'android' then
    testluaj = require('app.models.luajTest')--引入luajTest类
elseif device.platform == 'ios' then
    luaoc = require('cocos.cocos2d.luaoc')
end

local GroupView = {}

function GroupView:initialize(group)
	self:enableNodeEvents()
	self.tabNewDeskPoint = {}	-- key: groupId v:groupId
end


local chatsTbl = {
    '游戏搞起来, 气氛热起来!',
    '缺一, 没人就开了!',
    '房里的赶紧准备, 开始了!',
    '大家一起浪起来!',
    '我有点事, 你们先玩!',  
}


function GroupView:layout()
	local app = require("app.App"):instance()
	local group = app.session.group
	self.group = group

	self.ui:setPosition(display.cx,display.cy)
	local MainPanel = self.ui:getChildByName('MainPanel')
	local bg = MainPanel:getChildByName('bg')
	self.bg = bg

	-- 编辑框
    local editHanlder = function(event,editbox)
        self:onEditEvent(event,editbox)
    end

	local input = self.bg:getChildByName('left_bg'):getChildByName('createGroup'):getChildByName('input')
    local editBoxOrg = input:getChildByName('editBox')
    self.createEditbox = tools.createEditBox(editBoxOrg, {
		-- holder
		defaultString = '请输入俱乐部名称',
		holderSize = 25,
		holderColor = cc.c3b(169,169,172),

		-- text
		fontColor = cc.c3b(169,169,172),
		size = 25,
		fontType = 'views/font/Fangzhenzhunhei.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
    })

	local input = self.bg:getChildByName('left_bg'):getChildByName('joinGroup'):getChildByName('input')
    local joinEditBoxOrg = input:getChildByName('editBox')
    self.joinEditbox = tools.createEditBox(joinEditBoxOrg, {
		-- holder
		defaultString = '请输入俱乐部ID',
		holderSize = 25,
		holderColor = cc.c3b(169,169,172),

		-- text
		fontColor = cc.c3b(169,169,172),
		size = 25,
		fontType = 'views/font/Fangzhenzhunhei.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
    })

	self.bg:getChildByName('filterLayer'):setLocalZOrder(10)
	self.bg:getChildByName('dialogs'):setLocalZOrder(11)

	local setNotifyLayer = self.bg:getChildByName('filterLayer'):getChildByName('setNotifyLayer')
	local curNotice = setNotifyLayer:getChildByName('input'):getChildByName('editBox')
	self.modifyNoticeEditBox = tools.createEditBox(curNotice, {
		-- holder
		defaultString = '请输入公告',
		holderSize = 25,
		holderColor = cc.c3b(169,169,172),

		-- text
		fontColor = cc.c3b(169,169,172),
		size = 25,
		fontType = 'views/font/Fangzheng.ttf',	
		inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
	})

	-- local setPersonalInfoLayer = self.bg:getChildByName('filterLayer'):getChildByName('setPersonalInfoLayer')
	-- local curNotice = setPersonalInfoLayer:getChildByName('input'):getChildByName('editBox')
	-- self.personalInfoEditBox = tools.createEditBox(curNotice, {
	-- 	-- holder
	-- 	defaultString = '请输入个人信息',
	-- 	holderSize = 25,
	-- 	holderColor = cc.c3b(169,169,172),

	-- 	-- text
	-- 	fontColor = cc.c3b(169,169,172),
	-- 	size = 25,
	-- 	fontType = 'views/font/Fangzhenzhunhei.ttf',	
	-- 	inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
	-- })
		

	-- groupList
	local groupList = self.bg:getChildByName('left_bg'):getChildByName('groupList')
	self.groupList = groupList
	local roomSelect = self.bg:getChildByName('left_bg'):getChildByName('roomSelect')
	self.roomSelect = roomSelect
	groupList:setItemModel(groupList:getItem(0))
	groupList:removeAllItems()
	groupList:setScrollBarEnabled(false)
	
	-- ROOMLIST
	local roomList_bisai = self.bg:getChildByName('roomList_bisai')
	local roomList_normal = self.bg:getChildByName('roomList_normal')
	self.roomList_bisai = roomList_bisai
	self.roomList_normal = roomList_normal
	self.roomListRowMe = self.bg:getChildByName('item1')
	self.roomListRowOther = self.bg:getChildByName('item2')
	roomList_bisai:removeAllItems()
	roomList_bisai:setScrollBarEnabled(false)
	roomList_normal:removeAllItems()
	roomList_normal:setScrollBarEnabled(false)
end

function GroupView:onExit()
end

function GroupView:freshListGroups(groups, initGroupId)
	-- 选中上一个
	local groupInfo = self.group:getCurGroup()
	local curGroupId
	if groupInfo then
		curGroupId = groupInfo.id 
	end

	-- 初始化选中
	if initGroupId then
		for k, v in pairs(groups) do
			if v.id == initGroupId then
				curGroupId = initGroupId
			end
		end
	end

	local groupList = self.groupList
	groupList:removeAllItems()
	local index = 0
	local num = nil
	for k, v in pairs(groups) do

		-- 刷新每个俱乐部的管理员
		self.group:onSetAdminInfo(v)
		-- 刷新每个俱乐部成员的分数
		self.group:onSetMemberScoreInfo(v)

		self.groupList:pushBackDefaultItem()
		local item = groupList:getItem(index)
		
		item:getChildByName('select'):hide()
		item:getChildByName('normal'):show() 
		item.groupId = v.id

		if not item:getChildByName('select'):getChildByName("blinkingBox") then
			--将动画加入到select里面
			local node =  cc.CSLoader:createNode("views/clubhlnn/blinkingBoxAnimation.csb")
			node:setName("blinkingBox")
			item:getChildByName('select'):addChild(node)
			node:setScale(1.90)
			node:setPosition(cc.p(160,59))
			self:startCsdAnimation(node,"blinkingBoxAnimation",true,0.6)
		end

		local headimg = item:getChildByName('txKuang') --头像   
		self:freshHeadImg(headimg, v.ownerInfo.avatar)

		local panel = item:getChildByName('groupName')
		local groupName = panel:getChildByName('value')
		groupName:setString(v.name)
		local panelSize = panel:getContentSize()
		local groupNameSize = groupName:getAutoRenderSize()
		local size = (groupNameSize.width >= panelSize.width) and panelSize or groupNameSize

		local position = groupName:getWorldPosition()
		local memberCnt = item:getChildByName('member_num')
		memberCnt:setString(v.memberCnt)

		item:getChildByName('room_num'):setString(v.roomCnt)

		local idx = index + 1
		item:getChildByName('touch'):addClickEventListener(function()			
			local groupId = v.id
			self:freshGroupNameAndID(false)
			self:freshListGroupsSelect(idx)
			self.emitter:emit('selectGroup', groupId)
    	end)

		if curGroupId and curGroupId == v.id then
			local groupName = v.name
			local groupId = v.id
			num = index + 1
			self:freshGroupNameAndID(true, groupName, groupId)
			self.emitter:emit('selectGroup', groupId)
			
		elseif (not curGroupId) and index==0 then
			-- 默认选中第一个
			local groupName = v.name
			local groupId = v.id
			num = 1
			self:freshGroupNameAndID(true, groupName, groupId)
			self.emitter:emit('selectGroup', groupId)
		end	
		index = index + 1	
	end
	self:freshListGroupsSelect(num, true)

	self:freshGroupListPoint()
end

function GroupView:freshGroupListPoint()
	local tabItem = self.groupList:getItems()
	if tabItem and #tabItem > 0 then
		for _, item in pairs(tabItem) do
			local groupId = item.groupId
			if groupId then
				local point = item:getChildByName('point')
				point:setVisible(false)
				if self.tabNewDeskPoint[groupId] then
					point:setVisible(true)
				end
			end
		end
	end
end

function GroupView:setViewDataTabNewDeskPoint(operation, groupId)
	if not groupId then return end
	if operation == 'add' then
		self.tabNewDeskPoint[groupId] = groupId
	elseif operation == 'del' then
		if not self.tabNewDeskPoint[groupId] then return end
		self.tabNewDeskPoint[groupId] = nil
	end
end

function GroupView:getGroupsCnt()
	local items = self.groupList:getItems()
	return items
end

function GroupView:freshHeadImg(headimg, headUrl)
	if headUrl == nil or headUrl == '' then return end	
	cache.get(headUrl, function(ok, path)
		local function loadImg()
			if tolua.isnull(headimg) then return end
			if ok then
				headimg:show()
				headimg:loadTexture(path)
			else
				headimg:loadTexture('views/public/tx.png')
			end
		end
		pcall(loadImg, 'headImg')
	end)
end

function GroupView:freshListGroupsSelect(index, flag)
	if not index then return end
	if self.roomSelect_idx and not flag then
		self.groupList:removeItem(self.roomSelect_idx)
	end
	local items = self.groupList:getItems()
	if items then
		for i, v in ipairs(items) do
			v:getChildByName('select'):setVisible(i==index)
			v:getChildByName('normal'):show(i~=index) 

			if i == index then
				local roomSelectModule = self.roomSelect:clone()
				self.groupList:insertCustomItem(roomSelectModule, i)
				self.roomSelect_idx = i
				self:freshRoomSelect_type(self:getRoomMode())
			end
		end
	end
end

function GroupView:freshGroupNameAndID(bShow, name, id)
	local groupNamePanel = self.bg:getChildByName('groupName')
	local groupName = groupNamePanel:getChildByName('value')
	local groupId = self.bg:getChildByName('groupID')
	local panelSize = groupNamePanel:getContentSize().width
	local panelPositionX = groupNamePanel:getWorldPosition().x	
	if bShow then		
		groupName:setString(name)
		groupId:setString('ID: '..id)

		local groupNameSize = groupName:getAutoRenderSize().width
		local nodePositionX = groupName:getWorldPosition().x		
		local positionX = 0
		local size = 0
		if groupNameSize <= panelSize then
			size = groupNameSize
			positionX = nodePositionX
		else
			size = panelSize
			positionX = panelPositionX
		end

		-- groupId:setPositionX(positionX + size)
	end
	groupName:setVisible(bShow)
	groupId:setVisible(bShow)
end

function GroupView:freshRoomListNum(idx_bisai, idx_normal)
	local item = self.groupList:getItem(self.roomSelect_idx):getChildByName('panel')
	if not item then return end
	local bisai = item:getChildByName('bisai')
	local normal = item:getChildByName('normal')
	bisai:getChildByName('room_num'):setString('' .. idx_bisai)
	normal:getChildByName('room_num'):setString('' .. idx_normal)
end

function GroupView:freshRoomSelect_type(mode)
	local item = self.groupList:getItem(self.roomSelect_idx):getChildByName('panel')
	if not item then return end
	local bisai = item:getChildByName('bisai')
	local normal = item:getChildByName('normal')
	bisai:getChildByName('active'):setVisible(false)
	normal:getChildByName('active'):setVisible(false)
	item:getChildByName(mode):getChildByName('active'):setVisible(true)
	self:setRoomMode(mode)
	self.roomList_bisai:setVisible(mode == 'bisai')
	self.roomList_normal:setVisible(mode == 'normal')
end

function GroupView:setRoomMode(mode)
	self.roomMode = mode
end

function GroupView:getRoomMode()
	return self.roomMode or 'bisai'
end

function GroupView:freshTopCopyBtn(bShow, curGroupId)	
	local copyBtn = self.bg:getChildByName('copyBtn')
	local groupId = self.bg:getChildByName('groupID')
	local groupIdSize = groupId:getContentSize().width
	local positionX = groupId:getWorldPosition().x	
	copyBtn:setVisible(bShow)
	if bShow then
		copyBtn:setPositionX(positionX + groupIdSize)		
	end
	copyBtn:addClickEventListener(function()
		self.emitter:emit('copyGroupId', curGroupId)
	end)		
end

function GroupView:freshNotifyLayer(bShow)
	local notify = self.bg:getChildByName('notify')
	notify:setVisible(bShow)
	if not bShow then return end
	local copyBtn = notify:getChildByName('copyBtn')	
	copyBtn:addClickEventListener(function()
		self.emitter:emit('copyGroupNotice')
	end)	
end

function GroupView:onClickTopCopyBtn(groupId)
	local content = '牛牛王子圈号$'..groupId..'$\n快来加入我的俱乐部吧!\n'
    if testluaj then
      print('android 1111111111111111111111111111111111111111111111111111111111') 
      -- "getNetInfo"
      --local ok netInfo = self.luaj.callStaticMethod(javaClassName, javaMethodName, args, javaMethodSig)
      --在这里尝试调用android static代码
      local testluajobj = testluaj.new(self)
      local ok, ret1 = testluajobj.callandroidCopy(self, content)
      print("GroupView".. ret1)
      if ok then 
        tools.showRemind('已复制到剪切板')
      else
        tools.showRemind('未复制')
      end
  end
  if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "copyToClipboard",{ww=content})
      if ok then 
        tools.showRemind('已复制到剪切板')
      else
        tools.showRemind('未复制')
      end
  end
end

function GroupView:onClickCopyNotice(content)
    local contentLength = string.match(content, "%S+")
	if not contentLength then
		tools.showRemind('快让圈主设置公告信息吧!')
		return
	end
    if testluaj then
      print('android 1111111111111111111111111111111111111111111111111111111111') 
      local testluajobj = testluaj.new(self)
      local ok, ret1 = testluajobj.callandroidCopy(self, content)
      print("GroupView".. ret1)
      if ok then 
        tools.showRemind('已复制到剪切板')
      else
        tools.showRemind('未复制')
      end
  end
  if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "copyToClipboard",{ww=content})
      if ok then 
        tools.showRemind('已复制到剪切板')
      else
        tools.showRemind('未复制')
      end
  end
end

-- 管理员消息按钮
function GroupView:freshAdminMsgBtn(bShow)
	self.bg:getChildByName('messageBtn'):setVisible(bShow)
end

-- 普通成员消息按钮
function GroupView:freshNormalMsgBtn(bShow)
	self.bg:getChildByName('normalmessageBtn'):setVisible(bShow)
end

--邀请按钮
function GroupView:freshInviteBtn(bShow)
	self.bg:getChildByName('inviteBtn'):setVisible(bShow)
end

--基金按钮
function GroupView:freshRoomCardBtn(bShow)
	self.bg:getChildByName('moneyBtn'):setVisible(bShow)
end

--设置按钮
function GroupView:freshSettingBtn(bShow)
	self.bg:getChildByName('settingBtn'):setVisible(bShow)
end

--成员按钮
function GroupView:freshMemberBtn(bShow)
	self.bg:getChildByName('memberBtn'):setVisible(bShow)
end

--背景
function GroupView:freshRightbg(bShow)
	self.bg:getChildByName('rightbg'):setVisible(bShow)
	self.bg:getChildByName('notifybg'):setVisible(bShow)
end

--创建房间按钮
function GroupView:freshCreateBtn(mode)
	if mode == 1 then  		--有俱乐部且是管理员
		self.bg:getChildByName('quickset'):setVisible(true)
		self.bg:getChildByName('createroomBtn'):setVisible(true)
		self.bg:getChildByName('createroomBtn1'):setVisible(false)
	elseif mode == 0 then   --有俱乐部不是管理员
		self.bg:getChildByName('quickset'):setVisible(false)
		self.bg:getChildByName('createroomBtn'):setVisible(false)
		self.bg:getChildByName('createroomBtn1'):setVisible(true)
	else                    --没有俱乐部
		self.bg:getChildByName('quickset'):setVisible(false)
		self.bg:getChildByName('createroomBtn'):setVisible(false)
		self.bg:getChildByName('createroomBtn1'):setVisible(false)
	end
end

--创建房间的提示
function GroupView:freshCreateRoomTips(bShow)
	bShow = bShow or false
	self.bg:getChildByName('createroomBtn'):getChildByName('createtips'):setVisible(bShow)
	self.bg:getChildByName('createroomBtn1'):getChildByName('createtips'):setVisible(bShow)
end

--设置界面 
function GroupView:freshAdminSettingLayer(bShow)	
	--admin设置
	local filterLayer = self.bg:getChildByName('filterLayer')
	local adminSettingLayer = filterLayer:getChildByName('adminSettingLayer'):setVisible(bShow) 
	local adminSetting = adminSettingLayer:getChildByName('adminSetting'):setVisible(bShow)		
	local alterNameBtn = adminSetting:getChildByName('alterName')
	alterNameBtn:addClickEventListener(function()
		self.emitter:emit('settingOperateModify')
	end)
	local dismissBtn = adminSetting:getChildByName('dismiss')
	dismissBtn:addClickEventListener(function()
		self.emitter:emit('settingOperateDismiss')
	end)	
end

function GroupView:freshNormalSettingLayer(bShow)	
	--普通设置
	local filterLayer = self.bg:getChildByName('filterLayer')
	local normalSettingLayer = filterLayer:getChildByName('normalSettingLayer'):setVisible(bShow) 
	local normalSetting = normalSettingLayer:getChildByName('normalSetting'):setVisible(bShow)	
	local exitBtn = normalSetting:getChildByName('exitBtn')	
end

-- setting : rule.special
function GroupView:getSpecialStr(deskInfo, mode, oneLine)
	return GameLogic.getSpecialText(deskInfo, mode, oneLine)
end

function GroupView:freshRoomDetailInfo(bShow, rule)
	if not bShow then
		self.roomInfo:setVisible(false)
		return
	end
	local info = self.roomInfo:getChildByName('info')

	-- 玩法
	local gameplayStr = GameLogic.getGameplayText(rule)
	info:getChildByName('text_wanfa'):setString(gameplayStr)

	-- 底分
	info:getChildByName('text_difen'):setString(rule.base)

	-- 翻倍
	local mulStr = GameLogic.getNiuNiuMulText(rule)
	info:getChildByName('text_beiRule'):setString(mulStr)

	-- 房间规则
    local advanceStr = GameLogic.getRoomRuleText(rule)
	info:getChildByName('text_roomRule'):setString(advanceStr)

	-- 特殊玩法
	local spStr = self:getSpecialStr(rule, 1, false)
	info:getChildByName('text_Twanfa'):setString(spStr)

	-- 高级选项
	local advanceStr = GameLogic.getAdvanceText(rule)
	info:getChildByName('text_advanceRule'):setString(advanceStr)

	-- 房间限制
	local roomlimitstr = GameLogic.getRoomLimitText(rule)
	info:getChildByName('text_roomlimit'):setString(roomlimitstr)

	self.roomInfo:setVisible(true)
end

function GroupView:freshRoomInfo(bShow, msg)
	local roomInfoLayer = self.bg:getChildByName('filterLayer'):getChildByName('roomInfoLayer')
	roomInfoLayer:setVisible(bShow)
	if not msg then return end

	local data = msg.data
	roomInfoLayer:getChildByName('roomId'):setString(''..msg.roomId)
	roomInfoLayer:getChildByName('playTime') --Todo
	roomInfoLayer:getChildByName('playerCnt'):setString(data.playerCnt..'/6')

	-- 房间详情
	local detailBtn = roomInfoLayer:getChildByName('detailBtn')
	detailBtn:addClickEventListener(function()
		self:freshRoomDetailInfo(true, data.rule)
	end)

	local roomInfo = roomInfoLayer:getChildByName('roomInfo')
	
	--底分
	roomInfo:getChildByName('base'):setString('底分'..data.rule.base)
	roomInfo:getChildByName('round'):setString(tostring(data.rule.round..'局'))

	-- 翻倍
	local mulStr = GameLogic.getNiuNiuMulText(data.rule)
	roomInfo:getChildByName('multiply'):setString(mulStr)

	-- 特殊玩法
	local spStr = self:getSpecialStr(data.rule, 2, true)
	roomInfo:getChildByName('special'):setString(spStr)

	local list = msg.data.playerList
	if list then
		self.playerList:removeAllItems()
		local idx = 0
		for i, v in pairs(list) do -- Todo
			self.playerList:pushBackDefaultItem()
			local item = self.playerList:getItem(idx)
			local info = string.format( "%s[%s]", v.nickname, v.playerId)
			item:getChildByName('userNameAndId'):setString(info)	

			idx = idx + 1
		end	
	end

	roomInfoLayer:getChildByName('joinBtn'):addClickEventListener(function()
		self.emitter:emit('enterRoom', msg.roomId)
	end)
end

function GroupView:freshRoomList(roomList, myPlayerId, clear)
	self.roomList_bisai:removeAllItems()
	self.roomList_normal:removeAllItems()

	if clear then return end 
	
	local function addRow(roomId, idx, isOwner, data)
		if isOwner then
			self.roomList:setItemModel(self.roomListRowMe)
		else
			self.roomList:setItemModel(self.roomListRowOther)
		end
		self.roomList:pushBackDefaultItem()	-- self
		local item = self.roomList:getItem(idx)		

		item:getChildByName('roomId'):setString('房号: '..roomId)	
		item:getChildByName('roomMemberCnt'):setString('人数: '..data.playerCnt..'/6')
		if data.rule.gameplay == 7 then 
			item:getChildByName('roomMemberCnt'):setString('人数: '..data.playerCnt..'/8')
		elseif data.rule.gameplay == 8 then
			item:getChildByName('roomMemberCnt'):setString('人数: '..data.playerCnt..'/10')
		end

		-- 房主信息
		local txKuang = item:getChildByName('txKuang')
		self:freshHeadImg(txKuang, data.ownerInfo.avatar)
		local name = txKuang:getChildByName('name')
		name:setString(data.ownerInfo.nickname or '--')
		local id = txKuang:getChildByName('ID')
		id:setString('ID: ' .. (data.ownerInfo.playerId or '--'))

		-- 状态
		local gameState = item:getChildByName('gameState')
		gameState:setString('状态:等待中')
		-- gameState:setColor(cc.c3b(255,255,255))
		gameState:setColor(cc.c3b(144,238,144))
		if data.played then
			-- gameState:setColor(cc.c3b(255,255,255))
			gameState:setColor(cc.c3b(255,243,74))
			gameState:setString('状态:游戏中')
		end

		-- 玩法
		local roomType = item:getChildByName('roomType')
		local wanfaStr = GameLogic.getGameplayText(data.rule)
		roomType:setString(wanfaStr)

		-- 底分
		local base = item:getChildByName('base')
		local baseStr = GameLogic.getBaseText(data.rule)
		base:setString(baseStr)

		-- 局数
		local round = item:getChildByName('round')
		round:setString(data.rule.round or "--")

		--支付方式
		local roomprice = item:getChildByName('roomprice')
		local priceStr = GameLogic.getPayModeText(data.rule) .. '支付'
		roomprice:setString(priceStr)
		
		-- 牛牛倍数
		local multiply = item:getChildByName('multiply')
		local multiplyStr = GameLogic.getNiuNiuMulText(data.rule, true)
		multiply:setString(multiplyStr)

		-- 特殊牌
		local special = item:getChildByName('special')
		local specialStr = GameLogic.getSpecialText(data.rule, 1, true)
		special:setString(specialStr)

		-- 房间限制
		local roomlimit = item:getChildByName('roomlimit')
		local roomlimitStr = '房间限制:' .. GameLogic.getRoomLimitText(data.rule)
		roomlimit:setString(roomlimitStr)

		-- 是否机器人建的房
		local autoroom = item:getChildByName('autoroom')
		autoroom:setVisible(data.autoroom or false)

		-- 进入房间
		local touch = item:getChildByName('touch')
		touch:addClickEventListener(function()
			self.emitter:emit('enterRoom', roomId)
		end)

		-- 房间信息
		local roominfo = item:getChildByName('roominfo')
		roominfo:addClickEventListener(function()
			self:freshRoomDetailInfo(true, data.rule)
		end)

		-- 房主信息
		local ownerinfo = item:getChildByName('ownerinfo')
		ownerinfo:addClickEventListener(function()
			self.emitter:emit('ownerinfo', data.ownerInfo.playerId)
		end)
	end

	local idx_bisai, idx_normal = 0, 0
	for roomId, data in pairs(roomList) do
		if data.rule.roomMode == 'bisai' then
			self.roomList = self.roomList_bisai
			addRow(roomId, idx_bisai, myPlayerId == data.ownerPlayerId, data)
			idx_bisai = idx_bisai + 1
		elseif data.rule.roomMode == 'normal' then
			self.roomList = self.roomList_normal
			addRow(roomId, idx_normal, myPlayerId == data.ownerPlayerId, data)
			idx_normal = idx_normal + 1
		end
	end
	self:freshRoomListNum(idx_bisai, idx_normal)

end

function GroupView:freshMemberList_bak(memberInfo, adminInfo)

	local function addRow(mode, node, idx, name, playerId, bMgr, headUrl, isBanPlayer)
		node:pushBackDefaultItem()
		local item = node:getItem(idx)
		-- 头像
		local headimg = item:getChildByName('txKuang')
		self:freshHeadImg(headimg, headUrl)
		-- 管理图标
		item:getChildByName('manager'):setVisible(bMgr)
		-- 名字
		item:getChildByName('userName'):setString(tostring(name))
		-- playerId
		item:getChildByName('userID'):setString('ID:'..tostring(playerId))
		-- 按钮
		local btn = item:getChildByName('sureDelete')
		if btn then
			btn:setVisible(false)
			btn:addClickEventListener(function()
				self.emitter:emit('memberListDelMember', playerId)
    		end)
		end

		local banImg = item:getChildByName('sureBanImg')
		banImg:setVisible(isBanPlayer)

		local banBtn = item:getChildByName('sureBan')
		if banBtn then
			banBtn:setVisible(false)
			banBtn:addClickEventListener(function()
				self.emitter:emit('memberListBanMember', {playerId, 'unban'})
    		end)
		end

		local unbanBtn = item:getChildByName('unban')
		if unbanBtn then
			unbanBtn:setVisible(false)
			unbanBtn:addClickEventListener(function()
				self.emitter:emit('memberListBanMember', {playerId, 'ban'})
    		end)
		end
	end

	self.adminMemberList:removeAllItems()
	self.normalMemberList:removeAllItems()
	if table.nums(memberInfo) == 0 then return end

	local tabM = clone(memberInfo)
	table.sort( tabM, function(a, b)
		if a.playerId == adminInfo.playerId then
			return true
		end
	end)
	
	local listIdx = 0
	for i,v in pairs(tabM) do
		local bMgr = (v.playerId == adminInfo.playerId)
		addRow(1, self.adminMemberList, listIdx, v.nickname, v.playerId, bMgr, v.avatar, v.isBanplayer)
		addRow(2, self.normalMemberList, listIdx, v.nickname, v.playerId, bMgr, v.avatar, v.isBanplayer)
		listIdx = listIdx + 1
	end
end


function GroupView:freshMemberList(memberInfo, adminInfo)

	local function addRow(mode, node, idx, name, playerId, bMgr, headUrl, isBanPlayer)
		node:pushBackDefaultItem()
		local item = node:getItem(idx)
		-- 头像
		local headimg = item:getChildByName('txKuang')
		self:freshHeadImg(headimg, headUrl)
		-- 管理图标
		item:getChildByName('manager'):setVisible(bMgr)
		-- 名字
		item:getChildByName('userName'):setString(tostring(name))
		-- playerId
		item:getChildByName('userID'):setString('ID:'..tostring(playerId))
		-- 按钮
		local btn = item:getChildByName('sureDelete')
		if btn then
			btn:setVisible(false)
			btn:addClickEventListener(function()
				self.emitter:emit('memberListDelMember', playerId)
    		end)
		end

		local banImg = item:getChildByName('sureBanImg')
		banImg:setVisible(isBanPlayer)

		local banBtn = item:getChildByName('sureBan')
		if banBtn then
			banBtn:setVisible(false)
			banBtn:addClickEventListener(function()
				self.emitter:emit('memberListBanMember', {playerId, 'unban'})
    		end)
		end

		local unbanBtn = item:getChildByName('unban')
		if unbanBtn then
			unbanBtn:setVisible(false)
			unbanBtn:addClickEventListener(function()
				self.emitter:emit('memberListBanMember', {playerId, 'ban'})
    		end)
		end
	end

	self.adminMemberList:removeAllItems()
	if table.nums(memberInfo) == 0 then return end

	local tabM = clone(memberInfo)
	table.sort( tabM, function(a, b)
		if a.playerId == adminInfo.playerId then
			return true
		end
	end)
	
	local listIdx = 0
	for i,v in pairs(tabM) do
		local bMgr = (v.playerId == adminInfo.playerId)
		addRow(1, self.adminMemberList, listIdx, v.nickname, v.playerId, bMgr, v.avatar, v.isBanplayer)
		addRow(2, self.normalMemberList, listIdx, v.nickname, v.playerId, bMgr, v.avatar, v.isBanplayer)
		listIdx = listIdx + 1
	end
end

function GroupView:freshAdminMemberListDelBtn(bShow, toggle)
	local items = self.adminMemberList:getItems()
	if items then
		for i, v in ipairs(items) do
			v:getChildByName('sureBanImg'):setVisible(false)
			v:getChildByName('sureBan'):setVisible(false)
			v:getChildByName('unban'):setVisible(false)

			local btn = v:getChildByName('sureDelete')
			local visible = btn:isVisible()
			local mgr = v:getChildByName('manager'):isVisible()
			if toggle then
				btn:setVisible(not visible)
			else
				btn:setVisible(bShow)
			end
			if mgr then btn:setVisible(false) end
		end
	end
end

function GroupView:freshAdminMemberListBanBtn(bShow, toggle)
	
	local items = self.adminMemberList:getItems()
	if items then
		for i, v in ipairs(items) do
			local img = v:getChildByName('sureBanImg')
			local imgV = img:isVisible()

			local ban = v:getChildByName('sureBan')
			local banV = ban:isVisible()

			local unban = v:getChildByName('unban')
			local unbanV = unban:isVisible()

			local mgrView = (banV or unbanV)
			local function setView(i, b, u)
				img:setVisible(i)
				ban:setVisible(b)
				unban:setVisible(u)
			end

			if toggle then
				if not mgrView then
					setView(false, imgV, not imgV)
				else
					setView(banV, false, false)
				end
			else
				setView(bShow, bShow, bShow)
			end

			local mgr = v:getChildByName('manager'):isVisible()
			if mgr then 
				setView(false, false, false)
			end
		end
	end
end

function GroupView:freshModifyGroupName(bShow, curName)	
	local modifyGroupName = self.bg:getChildByName('dialogs')
		:getChildByName('modifyGroupName')
		:setVisible(bShow) 
	local curGroupName = modifyGroupName:getChildByName('input'):getChildByName('editBox')
	if curName and curGroupName then
		curGroupName = tools.createEditBox(curGroupName, {
			-- holder
			defaultString = curName,
			holderSize = 30,
			holderColor = cc.c3b(169,169,172),

			-- text
			fontColor = cc.c3b(169,169,172),
			size = 30,
			fontType = 'views/font/Fangzhenzhunhei.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
		self.modifyGroupEditBox = curGroupName
	end		
end

-- topBtn
function GroupView:freshRoomCardState(bShow, groupCardCnt, isOwner)
	local roomCard = self.bg:getChildByName('roomCard')
	local cardCnt = roomCard:getChildByName('cardCnt')
	local addRoomCardBtn = roomCard:getChildByName('addRoomCardBtn')
	addRoomCardBtn:setVisible(isOwner) 	
	roomCard:setVisible(bShow) 	
	if not bShow then return end
	groupCardCnt = groupCardCnt or 0
	cardCnt:setString(groupCardCnt)
end

function GroupView:freshQuickJoinBtn(bShow)
	-- self.bg:getChildByName('quickJoinBtn'):setVisible(bShow)
end

-- 弹窗
function GroupView:freshAddRoomCard(bShow, groupCardCnt, personalCardCnt)	
	local addRoomCard = self.bg:getChildByName('dialogs'):getChildByName('addRoomCard')
	addRoomCard:setVisible(bShow) 		
	if not bShow then return end
	addRoomCard:getChildByName('groupRoomCard'):setString(groupCardCnt..'')
	addRoomCard:getChildByName('personalRoomCard'):setString(personalCardCnt..'')
	local reduceBtn = addRoomCard:getChildByName('reduceBtn')
	local addBtn = addRoomCard:getChildByName('addBtn')
	local cardCnt = addRoomCard:getChildByName('currentCardCnt')
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

	local takeOutBtn = addRoomCard:getChildByName('takeOutBtn')
	takeOutBtn:addClickEventListener(function()
		if cnt > groupCardCnt then cnt = groupCardCnt end
		cardCnt:setString(cnt..'')
		self.emitter:emit('recaptionDiamond', cnt)
	end)	
	local saveBtn = addRoomCard:getChildByName('saveBtn')
	saveBtn:addClickEventListener(function()
		if cnt > personalCardCnt then cnt = personalCardCnt end
		cardCnt:setString(cnt..'')
		self.emitter:emit('chargeDiamond', cnt)
	end)	
end

function GroupView:freshRecordLayer(bShow)
	self.bg:getChildByName('filterLayer'):getChildByName('recordLayer'):setVisible(bShow) 
end

function GroupView:freshOpenRoomInfoLayer(bShow)
	self.bg:getChildByName('filterLayer'):getChildByName('openRoomInfoLayer'):setVisible(bShow) 
end

function GroupView:freshShortcutListLayer(bShow)
	self.bg:getChildByName('filterLayer'):getChildByName('shortcutListLayer'):setVisible(bShow) 
end

function GroupView:freshSetNotifyLayer(bShow)	
	self.bg:getChildByName('filterLayer'):getChildByName('setNotifyLayer'):setVisible(bShow) 		
end

function GroupView:freshPersonalInfoLayer(bShow)	
	self.bg:getChildByName('filterLayer'):getChildByName('setPersonalInfoLayer'):setVisible(bShow) 	
end

function GroupView:freshNotifyContent(bShow, notice)
	notice = notice or ''
	if notice == '' then 
		notice = "这个俱乐部的管理员很懒， 尚未设置公告"
	end
	self:freshNormalGonggao(notice)
	local panel = self.bg:getChildByName('notify')
	local text = panel:getChildByName('Text_notify')	
	local curText = text:getString()
	if curText == notice then return end
	text:setString(notice)
	text:setVisible(bShow)
	local positionX = panel:getWorldPosition().x	

	local panelSize = panel:getContentSize()
	local textSize = text:getAutoRenderSize()
   
    text:setPositionX(panelSize.width-25)

	local speed = (panelSize.width + textSize.width) / 50
	local action2 = cc.MoveTo:create(0.000001, cc.p(panelSize.width-25, 18))
	local action1 = cc.MoveTo:create(speed, cc.p(-textSize.width, 18))
	local sequence = cc.Sequence:create(action1, action2)
	local action = cc.RepeatForever:create(sequence)
	text:stopAllActions()
	text:runAction(action)
end

function GroupView:freshDismissGroup(bShow, groupName)	
	local modifyGroupName = self.bg:getChildByName('dialogs'):getChildByName('dismissGroup'):setVisible(bShow) 
	local tipsContent = modifyGroupName:getChildByName('content')
	if groupName then 
		local content = '您确定要解散俱乐部['..groupName..']吗?'
		tipsContent:setString(content) 
	end
end

function GroupView:freshQuitGroup(bShow, groupName)	
	local quitGroupName = self.bg:getChildByName('dialogs'):getChildByName('quitGroup'):setVisible(bShow) 
	local tipsContent = quitGroupName:getChildByName('content')
	if groupName then 
		local content = '您确定要退出俱乐部['..groupName..']吗?'
		tipsContent:setString(content) 
	end
end

--开房声音
function GroupView:freshRoomSound(bShow)	
	self.bg:getChildByName('dialogs'):getChildByName('roomSound'):setVisible(bShow) 
	local groupInfo = self.group:getCurGroup()
	local ison = self:getGrouopSoundData(groupInfo.id)
	self:freshRoomSoundOpt(ison, not ison)
end

function GroupView:freshRoomSoundOpt(ison, isoff)	
	self.bg:getChildByName('dialogs'):getChildByName('roomSound'):getChildByName('sound_on'):setVisible(ison) 
	self.bg:getChildByName('dialogs'):getChildByName('roomSound'):getChildByName('sound_off'):setVisible(isoff) 
end

function GroupView:getGrouopSoundData(groupId)
	local ison = LocalSettings:getGroupConfig('roomsound'..groupId)
	if ison == nil then return true end
	return ison
end

function GroupView:saveGroupSoundData()	
	local groupInfo = self.group:getCurGroup()
	local ison = self.bg:getChildByName('dialogs'):getChildByName('roomSound'):getChildByName('sound_on'):isVisible()  
	LocalSettings:setGroupConfig('roomsound'..groupInfo.id, ison)
end

--新消息提示
function GroupView:freshNewMessageTips(bShow, cnt)
	local newMessage = self.bg:getChildByName('messageBtn'):getChildByName('newMessage')
	local msgCnt = newMessage:getChildByName('msgCnt')
	newMessage:setVisible(bShow)
	if not bShow then return end
	local cnt = cnt or 0
	msgCnt:setString(cnt..'')
end

--普通成员消息提醒
function GroupView:freshNormalMessage(bShow)	
	self.bg:getChildByName('dialogs'):getChildByName('normalMessage'):setVisible(bShow) 
end

function GroupView:freshNormalGonggao(msg)	
	local text = self.bg:getChildByName('dialogs'):getChildByName('normalMessage'):getChildByName('Text_gonggao')
	text:setString(msg) 
end

--刷新admin成员列表
-- function GroupView:adminMemberList(memberInfo)
-- 	local adminMemberList = self.adminMemberList
-- 	adminMemberList:removeAllItems()
-- 	for i, v in pairs(memberInfo) do
-- 		self.adminMemberList:pushBackDefaultItem()
-- 		local item = adminMemberList:getItem(i - 1)	
-- 		-- local playerId = 
-- 		-- local nickname =
-- 		item:getChildByName('userID')
-- 		item:getChildByName('userName'):setString(nickname)		
-- 	end		
-- end

function GroupView:freshAddLayer(bShow) 
	local filterLayer = self.bg:getChildByName('filterLayer')
	local addLayer = filterLayer:getChildByName('addLayer'):setVisible(bShow) 
	local addDetail = addLayer:getChildByName('addDetail'):setVisible(bShow)
end

-- 显示&隐藏创建牛友群界面
function GroupView:freshGroupCreateLayer(bShow) 
	self.bg:getChildByName('left_bg'):getChildByName('createGroup'):setVisible(bShow) 
end

function GroupView:freshGroupJoinLayer(bShow) 
	local left_bg = self.bg:getChildByName('left_bg'):getChildByName('joinGroup'):setVisible(bShow) 
	if bShow then
		self:freshBtnState(true)
		self:freshQueryResult(false)
	end
end

function GroupView:getModifyEditBoxInfo() 
    local text = self.modifyGroupEditBox:getText()
    return text 	
end

function GroupView:getNoticeEditBoxInfo() 
    local text = self.modifyNoticeEditBox:getText()
    return text 	
end

function GroupView:freshNoticeEditBox(content, enable)
    enable = enable or false
	content = content or '请输入公告'
    self.modifyNoticeEditBox:setText(content)
    self.modifyNoticeEditBox:setEnabled(enable)
end

function GroupView:getPersonalEditBoxInfo() 
    local text = self.personalInfoEditBox:getText()
    return text 	
end

function GroupView:freshPersonalEditBox(content, enable)
    enable = enable or false
	content = content or '请输入个人信息'
    self.personalInfoEditBox:setText(content)
    self.personalInfoEditBox:setEnabled(enable)
end

function GroupView:getCreateEditBoxInfo() 
    local text = self.createEditbox:getText()
    return text 	
end

function GroupView:freshCreateEditBox(content, enable)
    enable = enable or false
    self.createEditbox:setText(content)
    self.createEditbox:setEnabled(enable)
end

function GroupView:getJoinEditBoxInfo() 
    local text = self.joinEditbox:getText()
	local num = tonumber(text)
    return num 	
end

function GroupView:freshJoinEditBox(content, enable)
    enable = enable or false
    self.joinEditbox:setText(content)
    self.joinEditbox:setEnabled(enable)
end

function GroupView:freshGroupListVisible(bShow)
	self.groupList:setVisible(bShow)
end

function GroupView:getCurSelectedGroup()
	return self.groupList:getCurSelectedIndex()
end

function GroupView:freshQueryResult(bShow, groupName, adminName, avatar)
	local input = self.bg:getChildByName('left_bg')
		:getChildByName('joinGroup')
		:getChildByName('queryResult')

	if not bShow then 
		input:setVisible(false)
		return
	end
	local headimg = input:getChildByName('txKuang')
	self:freshHeadImg(headimg, avatar)	
	local gName = input:getChildByName('groupName')
	gName:setString(groupName)
	local aName = input:getChildByName('adminName')
	aName:setString(adminName)
	input:setVisible(bShow)
end

function GroupView:freshBtnState(bShow)
	local sureBtn = self.bg:getChildByName('left_bg')
		:getChildByName('joinGroup')
		:getChildByName('sureBtn')
		:setVisible(bShow)

	local input = self.bg:getChildByName('left_bg')
		:getChildByName('joinGroup')
		:getChildByName('backBtn')
		:setVisible(bShow)		
end

function GroupView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/clubhlnn/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
      action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

return GroupView
