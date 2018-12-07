local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local tools = require('app.helpers.tools')
local SoundMng = require('app.helpers.SoundMng')
local GVAdvancedSettingListController = class("GVAdvancedSettingListController", Controller):include(HasSignals)

function GVAdvancedSettingListController:initialize(data)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = data[1]
	self.isAdmin = data[2]
	local groupInfo = self.group:getCurGroup()
	self.bindgroupId = groupInfo.id
	self.flag = false  
end


function GVAdvancedSettingListController:viewDidLoad()
	self.view:layout({self.group, self.isAdmin})
	local group = self.group

	self.listener = {
		group:on('Group_queryAdvanceOptionResult',function(msg)
			local groupInfo = self.group:getCurGroup()
			local groupId = groupInfo.id
			local data = group:getAdvanceOption(groupId)
			if msg.groupId == self.bindgroupId and not self.flag then 
				self.flag = true
				self.view:setOptions(data)
			end
		end),

		group:on('Group_modifyAdvanceOptionResult',function(msg)
			self:clickCloseAdvanced()
			tools.showRemind('已成功保存设置并生效')
		end),
	}
	
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id
	local curNotice = self.group:getNotice(groupId)
	self.view:freshNoticeEditBox(curNotice, true)

	group:queryAdvanceOption(groupId)
end 

function GVAdvancedSettingListController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

function GVAdvancedSettingListController:clickselect(sender)
	SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshTab(data,sender)
end

function GVAdvancedSettingListController:clickCloseAdvanced(sender)
	if sender then 
		local data = sender:getComponent("ComExtensionData"):getCustomProperty()
		if data == 'cancel' then 
			SoundMng.playEft('btn_click.mp3')
		end
	end
	self.emitter:emit('back')
end

function GVAdvancedSettingListController:clickSure()
	SoundMng.playEft('btn_click.mp3')
	local options = self.view:getOptions()
	local groupInfo = self.group:getCurGroup()
	local groupId = groupInfo.id

	--发送高级设置信息
	self.group:modifyAdvanceOption(groupId,options)

	--发送公告信息
	local input = self.view:getNoticeEditBoxInfo()
    local inputLength = string.match(input, "%S+")    
	if input and inputLength then
		self.group:modifyGroupNotice(groupId, input)                      
	end 
end

return GVAdvancedSettingListController