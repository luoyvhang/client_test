local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local tools = require('app.helpers.tools')
local GVRoomCardListController = class("GVRoomCardListController", Controller):include(HasSignals)

function GVRoomCardListController:initialize(data)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = data[1]
	self.isAdmin = data[2]
	self.isAdminFu = data[3] 
end


function GVRoomCardListController:viewDidLoad()
	self.view:layout({self.group, self.isAdmin, self.isAdminFu})
	local group = self.group
	self.listener = {
		-- self.group:on('memberList', function(msg)
		-- 	self.view:freshGameState(true)
		-- 	self.view:freshMemberList()
		-- end),	

		-- self.view:on('userInfo', function(playerId)
		-- 	self.group:queryUserInfo(playerId)
		-- end),

		group:on('foundationRecord',function(msg)
			if msg.code == -100 then
				tools.showRemind('管理员未开启群员查看账单功能')
			end
			self.view:freshinfoList()
		end), 

		-- 查询牛友群结果消息 0:查询失败 1:查询成功
		group:on('GroupMgr_getGroupResult',function(queryMessage)
			if queryMessage.code == 1 and queryMessage.mode == 2 then
				self.view:freshCurCard()
			end
		end),   
	
		-- 新牛友群信息
		group:on('groupInfo',function(msg)
			self.view:freshCurCard()
		end),

		group:on('Group_recaptionDiamondResult',function(msg)
			if msg.code == 1 then
				tools.showRemind(string.format( "成功取出群内 %s 钻石到个人账号.", msg.cnt)) 
				self:clickBack()
			elseif msg.code == -1 then
				tools.showRemind('群内钻石不足')
			end
		end),

		group:on('Group_chargeDiamondResult',function(msg)
			if msg.code == 1 then
				tools.showRemind('充值成功')
				self:clickBack()
			elseif msg.code == -1 then
				tools.showRemind('钻石不足')
			end
		end),

		--查询高级设置选项刷新界面
		group:on('Group_queryAdvanceOptionResult',function(msg)
			self.view:analyseOptions()
		end),
		
		self.view:on('recaptionDiamond',function(cnt)
			local groupInfo = group:getCurGroup()
			local groupId = groupInfo.id
			group:recaptionDiamond(groupId, cnt)
		end),

		self.view:on('chargeDiamond',function(cnt)
			local groupInfo = group:getCurGroup()
			local groupId = groupInfo.id
			group:chargeDiamond(groupId, cnt)
		end),
	}
	
	local groupInfo = group:getCurGroup()
	local groupId = groupInfo.id
	group:queryAdvanceOption(groupId)
end 

function GVRoomCardListController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

function GVRoomCardListController:clickBack()
	self.emitter:emit('back')
end

function GVRoomCardListController:closeAddRoomCard()
	self.view:freshLayer(false,false,false)
	self.emitter:emit('back')
end

function GVRoomCardListController:clickCharge()
	self.view:freshLayer(false,true,false)

	local group = self.group
    local groupInfo = group:getCurGroup()
    local ownerId = groupInfo.ownerInfo.playerId --ID   
    local myPlayerId = group:getPlayerRes("playerId") --自己id
    local gDiamond = groupInfo.diamond
    -- if  ownerId == myPlayerId then     
        local diamond = self.group:getPlayerRes('diamond')
        self.view:freshAddRoomCard(gDiamond, diamond, ownerId == myPlayerId)
    -- end
end

function GVRoomCardListController:clickZhangdan()
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id
	self.group:queryFoundationRecord(groupId)

	self.view:freshLayer(false,false,true)
end

return GVRoomCardListController