local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local tools = require('app.helpers.tools')
local SoundMng = require('app.helpers.SoundMng')
local GVSetScoreController = class("GVSetScoreController", Controller):include(HasSignals)

function GVSetScoreController:initialize(data)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = data[1]
	self.mode = data[2]
	local groupInfo = self.group:getCurGroup()
	self.bindgroupId = groupInfo.id
end


function GVSetScoreController:viewDidLoad()
	self.view:layout({self.group, self.mode})
	local group = self.group

	self.listener = {

		group:on('Group_querySetScoreInfoResult',function(msg)
			self.view:freshLayer(msg)
		end),

		group:on('resultSetRoomlimit', function(msg)
			tools.showRemind("修改成功")
			self:clickBack()
		end),

		group:on('resultSetNewOwner', function(msg)
			if not msg or msg.code == -1 then
				tools.showRemind("操作失败")
			elseif msg.code == 1 then
				tools.showRemind("转让成功")
				self:clickBack()
			elseif msg.code == 0 then
				tools.showRemind(msg.errorCode)
			end
		end),	
	}
	
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id
	self.groupId = groupId
	local curNotice = self.group:getNotice(groupId)

	self:queryInfo()
end 

function GVSetScoreController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

function GVSetScoreController:clickBack()
	self.emitter:emit('back')
end

function GVSetScoreController:queryInfo()
	self.group:querySetScoreInfo(self.groupId, self.mode)
end

------------------------转让群主部分-----------------------------------------------------------
function GVSetScoreController:clickSure()
	SoundMng.playEft('btn_click.mp3')
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id

	local id = tonumber(self.view:getChangePlayerId())
	self.group:setNewOwner(groupId, id)
end
----------------------------------------------------------------------------------------------

------------------------房间限制部分-----------------------------------------------------------
function GVSetScoreController:clickAdd()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshChoushui('add')
end

function GVSetScoreController:clickReduce()
	SoundMng.playEft('btn_click.mp3')
	self.view:freshChoushui('reduce')
end

function GVSetScoreController:clickModify()
	SoundMng.playEft('btn_click.mp3')
	local groupInfo = self.group:getCurGroup()
	if not groupInfo then return end
	local groupId = groupInfo.id
	local msg = self.view:getRoomLimit()
	self.group:setRoomlimit(groupId, msg)
end

function GVSetScoreController:clickRule(sender)
	SoundMng.playEft('btn_click.mp3')
	self.view:freshRule(sender)
end
-----------------------------------------------------------------------------------------------

return GVSetScoreController