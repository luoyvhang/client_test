local class = require('middleclass')
local HasSignals = require('HasSignals')
local Group = class('Group'):include(HasSignals)


function Group:initialize()
	HasSignals.initialize(self)
	local app = require("app.App"):instance()

	self.listGroupInfo = {}	-- k:groupId v: packageInfo()
	self.listAdminMsg = {}	-- k:groupId v: packageAdminMsg()
	self.listGroupMemberInfo = {} -- k:groupId v: packageMemberInfo()
	self.listAdminFuInfo = {} -- k:groupId v:
	self.listMemberScoreInfo = {} -- k:groupId v:
	self.listGroupRoom = {} -- k:groupId v:{k:deskId  v:{ ownerPlayerId = int, playerCnt = int, rule = {}}}
	self.listGroupNotice = {} -- k:groupId v: notice
	self.recordList = {} -- k:groupId v:recordData
	self.summaryList = {} --k:groupId v:data
	
	self.foundationRecord = {} --k:groupId v:data

	self.listGroupMsg = {}	--k:groupId v:{}

	self.listAdvanceOption = {} --k:groupId option:{}

	self.personalInfo = ''

	self.requestJoinData = nil

	self.curGroupId =  nil

	-- 服务器返回 信息
	app.conn:on('listGroup', function(msg)
		self:onListGroup(msg)
		self.emitter:emit('listGroup', msg)
	end)
	
	-- app.conn:on('listRequest', function(msg)
	-- 	self:onAdminMsg(msg)
	-- 	self.emitter:emit('listRequest', msg)
	-- end)

	app.conn:on('groupInfo', function(msg)
		self:onGroupInfo(msg)
		self.emitter:emit('groupInfo', msg)
	end)


	app.conn:on('memberList', function(msg)
		self:onMemberList(msg)
		self.emitter:emit('memberList', msg)
	end)

	--账单信息
	app.conn:on('foundationRecord', function(msg)
		self:onfoundationRecordList(msg)
		self.emitter:emit('foundationRecord', msg)
	end)

	app.conn:on('groupDismiss', function(msg)
		self.emitter:emit('groupDismiss', msg)
	end)

	app.conn:on('newDesk', function(msg)
		if msg.groupId and self.curGroupId == msg.groupId then
			self:roomList(self.curGroupId)
		end
		self.emitter:emit('newDesk', msg.groupId)
	end)

	app.conn:on('groupRoomList', function(msg)
		self:onGroupRoomList(msg)
		self.emitter:emit('groupRoomList', msg)
	end)

	app.conn:on('delDesk', function(msg)
		if msg.groupId and self.curGroupId == msg.groupId then
			self:roomList(self.curGroupId)
		end
	end)

	app.conn:on("Group_setRoomConfigResult",function(msg)
		self.emitter:emit('Group_setRoomConfigResult', msg)
	end)

	-- 服务器返回 结果
	app.conn:on('GroupMgr_creatResult', function(msg)
		self.emitter:emit('GroupMgr_creatResult', msg)
	end)

	app.conn:on('GroupMgr_dismissResult', function(msg)
		self.emitter:emit('GroupMgr_dismissResult', msg)
	end)

	app.conn:on('GroupMgr_getGroupResult', function(msg)
		if not msg then return end
		if msg.code == 1 then 
			local groupInfo = msg.groupInfo
			if msg.mode == 1 then -- 查询群信息
				self.requestJoinData = groupInfo
			elseif msg.mode == 2 then  -- 设置当前操作的群
				self.listGroupInfo[groupInfo.id] = groupInfo
				self:setCurGroupId(groupInfo.id)
				self:roomList(groupInfo.id)
			end
		end
		self.emitter:emit('GroupMgr_getGroupResult', msg)
	end)

	app.conn:on('Group_createRoomResult', function(msg)
		self.emitter:emit('Group_createRoomResult', msg)
	end)

	app.conn:on('onModifyInfoResult', function(msg)
		self.emitter:emit('onModifyInfoResult', msg)
	end)

	app.conn:on('resultSetAdminPlayer', function(msg)
		self:onSetAdminInfo(msg)
		self.emitter:emit('resultSetAdminPlayer')
	end)

	app.conn:on('resultSetRoomlimit', function(msg)
		self.emitter:emit('resultSetRoomlimit',msg)
	end)

	app.conn:on('resultSetNewOwner', function(msg)
		self.emitter:emit('resultSetNewOwner',msg)
	end)

	app.conn:on('resultSetMemberScore', function(msg)
		self:onSetMemberScoreInfo(msg)
		self.emitter:emit('resultSetMemberScore',msg)
	end)

	-- modifyGroupNotice
	app.conn:on('Group_modifyNoticeResult', function(msg)
		self.emitter:emit('onModifyNoticeResult', msg)
	end)

	app.conn:on('groupNotice', function(msg)
		self:onGroupNotice(msg)
		self.emitter:emit('getGroupNotice', msg)		
	end)

	app.conn:on('modifyPersonalInfo', function(msg)
		self:onPersonalInfo(msg)
		self.emitter:emit('modifyPersonalInfo', msg)		
	end)

	app.conn:on('roomConfig', function(msg)
		self.emitter:emit('roomConfig', msg)		
	end)

	app.conn:on('onDismissResult', function(msg)
		self.emitter:emit('onDismissResult', msg)
	end)
	
	app.conn:on('joinRequestResult', function(msg)
		self.emitter:emit('joinRequestResult', msg)
	end)

	app.conn:on('Group_adminMsgResult', function(msg)
		self:onAdminMsg(msg)
		self.emitter:emit('Group_adminMsgResult', msg)
	end)

	app.conn:on('Group_acceptJoinResult', function(msg)
		self.emitter:emit('Group_acceptJoinResult', msg)
	end)

	app.conn:on('resultSetRobotCreateRoom', function(msg)
		self.emitter:emit('resultSetRobotCreateRoom', msg)
	end)

	app.conn:on('Group_requestResult', function(msg)
		self.emitter:emit('Group_requestResult', msg)
	end)

	app.conn:on('Group_quitResult', function(msg)
		self.emitter:emit('Group_quitResult', msg)
	end)

	app.conn:on('Group_quickStartResult', function(msg)
		self.emitter:emit('Group_quickStartResult', msg)
	end)

	app.conn:on('Group_winnerListResult', function(msg)
		self:onWinnerList(msg)
		self.emitter:emit('Group_winnerListResult', msg) -- 可能存在多个大赢家
	end)

	app.conn:on('Group_recentlSummaryResult', function(msg)
		self:onSummaryList(msg)
		self.emitter:emit('Group_recentlSummaryResult', msg)
	end)

	app.conn:on('Group_synMsgResult', function(msg)
		self:onSynMsg(msg)
		self.emitter:emit('Group_synMsgResult', msg)
	end)

	app.conn:on('Group_chargeDiamondResult', function(msg)
		self.emitter:emit('Group_chargeDiamondResult', msg)
	end)

	app.conn:on('Group_recaptionDiamondResult', function(msg)
		self.emitter:emit('Group_recaptionDiamondResult', msg)
	end)

	app.conn:on('Group_createRoom', function(msg)
		self.emitter:emit('Group_createRoom', msg)
	end)

	app.conn:on('queryUserInfoResult', function(msg)
		self.emitter:emit('queryUserInfoResult', msg)
	end)

	app.conn:on('Group_queryAdvanceOptionResult', function(msg)
		self:onQueryAdvanceOptionResult(msg)
		self.emitter:emit('Group_queryAdvanceOptionResult', msg)
	end)

	app.conn:on('Group_modifyAdvanceOptionResult', function(msg)
		self.emitter:emit('Group_modifyAdvanceOptionResult', msg)
	end)

	app.conn:on('Group_querySetScoreInfoResult', function(msg)
		self.emitter:emit('Group_querySetScoreInfoResult', msg)
	end)

end

function Group:test()
	-- self:creatGroup("666")
	-- self:groupList("666")
	self:adminMsgList()
end

function Group:test1()
	self:requestJoin(636296)
end

function Group:onListGroup(msg)
	self.listGroupInfo = {}
	if msg and msg.list then
		for k,v in pairs(msg.list) do
			self.listGroupInfo[v.id] = v
		end
	end
end

function Group:onAdminMsg(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		self.listAdminMsg[groupId] = msg.data
	end
end

function Group:onSynMsg(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		self.listGroupMsg[groupId] = msg.data
	end
end

function Group:onGroupInfo(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		if not self.listGroupInfo[groupId] then self.listGroupInfo[groupId] = {} end
		self.listGroupInfo[groupId] = msg.data
	end
end

function Group:setCurGroupId(id)
	self.curGroupId = id
end

function Group:onMemberList(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		if not self.listGroupMemberInfo[groupId] then self.listGroupMemberInfo[groupId] = {} end
		local groupInfo = self.listGroupInfo[groupId]
		local ownerId = groupInfo.ownerInfo.playerId
		
		local tabMember = {}
		local tabOnline = {}
		local tabOffline = {}

		for i, v in pairs(msg.data) do
			if v.playerId == ownerId then
				table.insert( tabMember, v)
			elseif v.online then
				table.insert( tabOnline, v)
			else
				table.insert( tabOffline, v)
			end
		end		
		table.insertto(tabMember, tabOnline)
		table.insertto(tabMember, tabOffline)
		-- table.sort( tabMember, function(a, b)
		-- 	if a.playerId == ownerId and b.playerId ~= ownerId then
		-- 		return true
		-- 	end
		-- 	if a.online and not b.online then
		-- 		return true
		-- 	end
		-- end)
		self.listGroupMemberInfo[groupId] = tabMember
	end
end

function Group:onSetAdminInfo(msg)
	if not msg then return end
	local groupId = msg.groupId or msg.id
	local groupInfo = self.listGroupInfo[groupId]
	local ownerId = groupInfo.ownerInfo.playerId
	local list = {}
	for i, v in pairs(msg.adminList) do
		if ownerId ~= v then
			table.insert(list, v)
		end
	end
	self.listAdminFuInfo[groupId] = list
end

function Group:onSetMemberScoreInfo(msg)
	if not msg then return end
	local groupId = msg.groupId or msg.id
	local groupInfo = self.listGroupInfo[groupId]
	local list = msg.scoreList
	self.listMemberScoreInfo[groupId] = list
end

function Group:onfoundationRecordList(msg)
	local gId = msg.groupId
	if gId and not self.foundationRecord[gId] then
		self.foundationRecord[gId] = {}
	end
	self.foundationRecord[gId] = msg.records
end

function Group:getfoundationRecord(groupId)
	return self.foundationRecord[groupId]
end

function Group:onGroupRoomList(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		self.listGroupRoom[groupId] = {}
		local tabDesk = msg.data
		for i, v in pairs(tabDesk) do
			local deskId = tonumber(i)
			if deskId then
				self.listGroupRoom[groupId][deskId] = v
			end
		end
	end
end

function Group:onWinnerList(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		self.recordList[groupId] = {}
		self.recordList[groupId] = msg
	end
end

function Group:onSummaryList(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		self.summaryList[groupId] = {}
		self.summaryList[groupId] = msg
	end
end

function Group:onGroupNotice(msg)
	if not msg then return end
	local groupId = msg.groupId
	if groupId then
		self.listGroupNotice[groupId] = msg.data or ''
	end
end

function Group:onPersonalInfo(msg)
	if not msg then return end
	self.personalInfo = msg.data or ''
end

function Group:onQueryAdvanceOptionResult(msg)
	if not msg then return end
	if not msg.groupId then return end
	self.listAdvanceOption[msg.groupId] = msg.data
end

-- =============== C, V getData =======================

function Group:getPlayerRes(res)
	-- nickName 
	-- avatar 
	-- sex
	-- diamond
	-- playerId
	-- uid
	local app = require("app.App"):instance()
	return app.session.user[res]
end

function Group:getCurGroup()
	if self.listGroupInfo[self.curGroupId] then
		return self.listGroupInfo[self.curGroupId]
	end
end

function Group:getGroupInfo(groupId)
	return self.listGroupInfo[groupId]
end

function Group:getListGroup()
	return self.listGroupInfo
end

function Group:getCurAdminMsg()
	if self.curGroupId then
		local gId = self.curGroupId
		if gId and self.listAdminMsg[gId] then
			return self.listAdminMsg[gId]
		end
	end
end

function Group:getMemberInfo(groupId)
	return self.listGroupMemberInfo[groupId]
end

function Group:getMemberScoreInfo(groupId)
	return self.listMemberScoreInfo[groupId]
end

function Group:getAdminFuInfo(groupId)
	return self.listAdminFuInfo[groupId]
end

function Group:getRoomList(groupId)
	return self.listGroupRoom[groupId]
end

function Group:getRecordList(groupId)
	return self.recordList[groupId]
end

function Group:getSummaryList(groupId)
	return self.summaryList[groupId]
end

function Group:getNotice(groupId)
	return self.listGroupNotice[groupId] 
end

function Group:getPersonalInfo()
	return self.personalInfo
end

function Group:getMsgList(groupId)
	return self.listGroupMsg[groupId] 
end

function Group:getAdvanceOption(groupId)
	return self.listAdvanceOption[groupId] 
end

-- =============== send 2 groupmgr =======================

-- 创建牛友群
function Group:creatGroup(name)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'GroupMgr_creat',
		name = name,
	}
	app.conn:send(msg)
end

function Group:groupList()
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'GroupMgr_list', 
	}
	app.conn:send(msg)
end

function Group:getGroupById(groupId, mode)
	assert(type(groupId) == 'number')
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'GroupMgr_getGroup', 
		groupId = groupId,
		mode = mode, -- 1:查询加入 2:刷新界面
	}
	app.conn:send(msg)
end

function Group:dismissGroup(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'GroupMgr_dismiss',
		groupId = groupId,
	}
	app.conn:send(msg)
end

-- =============== send 2 group =======================
-- 必须指定 groupId

function Group:requestJoin(groupId)
	local id = 123456
	if groupId then
		id = groupId
	elseif self.requestJoinData then
		id = self.requestJoinData.id
	end

	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_requestJoin',
		groupId = id,
	}
	app.conn:send(msg)
end

function Group:adminMsgList(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_adminMsg',
		groupId = groupId,
	}
	app.conn:send(msg)
end

-- operate: 'accept', 'reject' 'block'
function Group:acceptJoin(groupId, playerId, operate)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_acceptJoin',
		groupId = groupId,
		playerId = playerId,
		operate = operate,
	}
	app.conn:send(msg)
end

function Group:delUser(groupId, playerId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_delUser',
		groupId = groupId,
		playerId = playerId,
	}
	app.conn:send(msg)
end

function Group:banUser(groupId, playerId, mode)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_banPlayer',
		mode = mode,
		groupId = groupId,
		playerId = playerId,
	}
	app.conn:send(msg)
end

function Group:setAdmin(groupId, adminFuList)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_setAdminPlayer',
		groupId = groupId,
		adminFuList = adminFuList,
	}
	app.conn:send(msg)
end

function Group:setMemberScore(groupId, options)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_setMemberScore',
		groupId = groupId,
		options = options,
	}
	app.conn:send(msg)
end

function Group:setNewOwner(groupId, id)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_setNewOwner',
		groupId = groupId,
		playerId = id,
	}
	app.conn:send(msg)
end

function Group:setRoomlimit(groupId, options)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_setRoomlimit',
		groupId = groupId,
		options = options,
	}
	app.conn:send(msg)
end

function Group:setRobotCreateRoom(groupId, bool)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_setRobotCreateRoom',
		groupId = groupId,
		flag = bool
	}
	app.conn:send(msg)
end

function Group:memberList(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_memberList',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:modifyGroupName(groupId, name)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_modifyInfo',
		groupId = groupId,
		name = name
	}
	app.conn:send(msg)
end

function Group:modifyGroupNotice(groupId, notice)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_modifyNotice',
		groupId = groupId,
		data = notice
	}
	app.conn:send(msg)
end

function Group:getRoomConfig(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_getRoomConfig',
		groupId = groupId
	}
	app.conn:send(msg)
end

function Group:getGroupNotice(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_getNotice',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:quitGroup(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_quit',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:roomList(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_roomList',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:quickStart(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_quickStart',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:winnerList(groupId) --todo: 分页请求
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_winnerList',
		groupId = groupId,
	}
	app.conn:send(msg)
end


function Group:recentlSummary(groupId)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_recentlSummary',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:shortcutChat(groupId, idx, chatStr)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_shortcutChat',
		groupId = groupId,
	}
	if idx then
		msg.chatType = 1
		msg.chatIdx = idx
	elseif chatStr then
		msg.chatType = 2
		msg.chatContent = chatStr
	else 
		return
	end
	app.conn:send(msg)
end

function Group:synMsg(groupId, idx)
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_synMsg',
		groupId = groupId,
		mode = idx,
	}
	app.conn:send(msg)
end

function Group:chargeDiamond(groupId, cnt)
	if cnt <= 0 then return end
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_chargeDiamond',
		groupId = groupId,
		diamond = cnt,
	}
	app.conn:send(msg)
end

function Group:recaptionDiamond(groupId, cnt)
	if cnt <= 0 then return end
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_recaptionDiamond',
		groupId = groupId,
		diamond = cnt,
	}
	app.conn:send(msg)
end

function Group:queryFoundationRecord(groupId)
	if not groupId then return end
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_queryFoundationRecord',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:queryUserInfo(playerId)
	if not playerId then return end
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'queryUserInfo',
		playerId = playerId,
	}
	app.conn:send(msg)
end

function Group:queryAdvanceOption(groupId)
	if not groupId then return end
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_queryAdvanceOption',
		groupId = groupId,
	}
	app.conn:send(msg)
end

function Group:querySetScoreInfo(groupId, mode)
	if not groupId then return end
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_querySetScoreInfo',
		groupId = groupId,
		mode = mode,
	}
	app.conn:send(msg)
end

function Group:modifyAdvanceOption(groupId, option)
	if not groupId then return end
	if not option then return end
	local app = require("app.App"):instance()
	local msg = {
		msgID = 'Group_modifyAdvanceOption',
		groupId = groupId,
		data = option,
	}
	app.conn:send(msg)
end

-- ===================================================

function Group:enterRoom(deskId)
	local app = require("app.App"):instance()
	if deskId then
		deskId = tostring(deskId)
		app.session.room:enterRoom(deskId)
	end
end


return Group
