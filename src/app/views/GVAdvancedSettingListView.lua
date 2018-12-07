local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVAdvancedSettingListView = {}

local Tabs = {
	'cr',
	'rp',
	'fr',
	'rb',
}

function GVAdvancedSettingListView:initialize()
	self.group = nil
	self.isAdmin = nil
	self.options = {1, 1, 1, 1} 
	self.netoptions = {}
end

function GVAdvancedSettingListView:layout(data)
	self.group = data[1]
	self.isAdmin = data[2]
	self.gameState = nil

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)

	self.top = mainPanel:getChildByName('top')
	self.bottom = mainPanel:getChildByName('bottom')

	self:settab(nil)

	local curNotice = mainPanel:getChildByName('bottom'):getChildByName('TextField')
	self.modifyNoticeEditBox = tools.createEditBox(curNotice, {
		-- holder
		defaultString = '请编辑俱乐部公告，最多80个汉字。',
		holderSize = 25,
		holderColor = cc.c3b(169,169,172),

		-- text
		fontColor = cc.c3b(169,169,172),
		maxCout = 80,
		size = 25,
		fontType = 'views/font/Fangzheng.ttf',	
		inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
	})
end

function GVAdvancedSettingListView:settab(setting)
	local sender = nil 
	if setting == nil then 
		for i, v in ipairs(Tabs) do
			sender = self.top:getChildByName(v):getChildByName('1')
			self:freshTab(v,sender)
		end
	else
		for i = 1, #setting do
			sender = self.top:getChildByName(Tabs[i]):getChildByName(tostring(setting[i]))
			self:freshTab(Tabs[i],sender)
		end
	end
end

function GVAdvancedSettingListView:getCurGroup()
	local groupInfo = self.group:getCurGroup()
	return groupInfo
end

function GVAdvancedSettingListView:freshTab(data,sender)
	self.top:getChildByName(data):getChildByName('1'):getChildByName('select'):setVisible(false)
	self.top:getChildByName(data):getChildByName('2'):getChildByName('select'):setVisible(false)
	sender:getChildByName('select'):setVisible(true)
	for i, v in ipairs(Tabs) do
		if v == data then
			self.options[i] = tonumber(sender:getName())
		end
	end
	self:freshcolor(data,sender)
end

function GVAdvancedSettingListView:freshcolor(data,sender)
	self.top:getChildByName(data):getChildByName('1'):getChildByName('text'):setColor(cc.c3b(255,255,255))
	self.top:getChildByName(data):getChildByName('2'):getChildByName('text'):setColor(cc.c3b(255,255,255))
	sender:getChildByName('text'):setColor(cc.c3b(255,245,205))
end

function GVAdvancedSettingListView:getOptions()
	local msg = {
		['createRoom'] = self.options[1],
		['payMode'] = self.options[2],
		['chargeMode'] = self.options[3],
		['billMode'] = self.options[4],
	}
	return msg
end

function GVAdvancedSettingListView:setOptions(data)
	local temp = {1, 1, 1, 1}
	temp[1] = data.createRoom
	temp[2] = data.payMode
	temp[3] = data.chargeMode
	temp[4] = data.billMode
	self:settab(temp)
end

function GVAdvancedSettingListView:getNoticeEditBoxInfo() 
    local text = self.modifyNoticeEditBox:getText()
    return text 	
end

function GVAdvancedSettingListView:freshNoticeEditBox(content, enable)
    enable = enable or false
	content = content or '请编辑俱乐部公告，最多80个汉字。'
    self.modifyNoticeEditBox:setText(content)
    self.modifyNoticeEditBox:setEnabled(enable)
end

return GVAdvancedSettingListView