local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVSetScoreView = {}

local default_join = 400
local default_qiang = 400
local default_tui = 400

function GVSetScoreView:initialize()
	self.group = nil

end

function GVSetScoreView:layout(data)
	self.group = data[1]
	self.mode = data[2]

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)

	self.roomlitLayer = mainPanel:getChildByName('roomlimit')
	self.fanshuiLayer = mainPanel:getChildByName('fanshui')
	self.zhuanrangLayer = mainPanel:getChildByName('zhuanrang')
	self.shangfenLayer = mainPanel:getChildByName('shangfen')

	-- self:freshLayer(self.mode)
end

function GVSetScoreView:freshLayer(msg)
	local mode = msg.mode
	local data = msg.data
	self.roomlitLayer:setVisible(false)
	self.fanshuiLayer:setVisible(false)
	self.zhuanrangLayer:setVisible(false)
	self.shangfenLayer:setVisible(false)
	if mode == 'fanshui' then
		self.fanshuiLayer:setVisible(true)
		self:freshChoushuiPart(data)
	elseif mode == 'roomlimit' then
		dump(data)
		self.roomlitLayer:setVisible(true)

		local join = self.roomlitLayer:getChildByName('join')
		self.joinEditBox = tools.createEditBox(join, {
			-- holder
			defaultString = data.join or '' .. default_join,
			holderSize = 25,
			holderColor = cc.c3b(255,255,255),

			-- text
			fontColor = cc.c3b(255,255,255),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
		self.join = data.join or '' .. default_join

		local qiang = self.roomlitLayer:getChildByName('qiang')
		self.qiangEditBox = tools.createEditBox(qiang, {
			-- holder
			defaultString = data.qiang or '' .. default_qiang,
			holderSize = 25,
			holderColor = cc.c3b(255,255,255),

			-- text
			fontColor = cc.c3b(255,255,255),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
		self.qiang = data.qiang or '' .. default_qiang

		local tui = self.roomlitLayer:getChildByName('tui')
		self.tuiEditBox = tools.createEditBox(tui, {
			-- holder
			defaultString = data.tui or '' .. default_tui,
			holderSize = 25,
			holderColor = cc.c3b(255,255,255),

			-- text
			fontColor = cc.c3b(255,255,255),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
		self.tui = data.tui or '' .. default_tui

		local choushui = self.roomlitLayer:getChildByName('choushui')
		choushui:setString('' .. data.choushui .. '%')
		self.choushui = data.choushui

		local rule1 = self.roomlitLayer:getChildByName('1')
		local rule2 = self.roomlitLayer:getChildByName('2')
		local rule = data.rule or 1
		self:freshRule(rule == 1 and rule1 or rule2)
	elseif mode == 'shangfen' then
		self.shangfenLayer:setVisible(true)
		self:freshShangfenPart(data)
	elseif mode == 'zhuanrang' then
		self.zhuanrangLayer:setVisible(true)
		local input = self.zhuanrangLayer:getChildByName('input')
		self.playerIDEditBox = tools.createEditBox(input, {
			-- holder
			defaultString = '请输入要转让的成员ID',
			holderSize = 25,
			holderColor = cc.c3b(169,169,172),

			-- text
			fontColor = cc.c3b(255,255,255),
			size = 25,
			maxCout = 6,
			fontType = 'views/font/Fangzheng.ttf',	
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})
	end
end

------------------------反水部分--------------------------------------------------------------
function GVSetScoreView:freshChoushuiPart(data)
	local yesterday_fanshui = self.fanshuiLayer:getChildByName('fanshui_text')
	local list = self.fanshuiLayer:getChildByName('list')
	local fanshuiList = self.fanshuiLayer:getChildByName('fanshuiList')
	fanshuiList:setItemModel(list)
	fanshuiList:removeAllItems()
	fanshuiList:setScrollBarEnabled(false)

	local idx = 0
	local sum = 0
	local nowtime = os.date("*t", os.time())
	local today_lingchen = os.time({year = nowtime.year, month = nowtime.month, day = nowtime.day, hour = 0, min = 0, sec = 0})
	local oneday = 60 * 60 * 24

	dump(data)
	for i, v in pairs(data) do
		for j, k in pairs(v.chouShuiList) do
			fanshuiList:pushBackDefaultItem()
			local item = fanshuiList:getItem(idx)
			local time = os.date("%Y/%m/%d %H:%M:%S", v.time)
			item:getChildByName('time'):setString(time)
			item:getChildByName('id'):setString(k.playerId)
			item:getChildByName('nickname'):setString(k.nickName)
			item:getChildByName('num'):setString(k.score)
			idx = idx + 1

			-- 判断时间
			if today_lingchen - v.time <= oneday and today_lingchen - v.time > 0 then
				sum = sum + k.score
			end
		end
	end
	yesterday_fanshui:setString('' .. sum)
end
----------------------------------------------------------------------------------------------

------------------------上下分部分-------------------------------------------------------------
function GVSetScoreView:freshShangfenPart(data)
	local yesterday_shang = self.shangfenLayer:getChildByName('shangfen_text')
	local yesterday_xia = self.shangfenLayer:getChildByName('xiafen_text')
	local list = self.shangfenLayer:getChildByName('list')
	local shangfenList = self.shangfenLayer:getChildByName('shangfenList')
	shangfenList:setItemModel(list)
	shangfenList:removeAllItems()
	shangfenList:setScrollBarEnabled(false)

	local idx = 0
	local shang_sum = 0
	local xia_sum = 0
	local nowtime = os.date("*t", os.time())
	local today_lingchen = os.time({year = nowtime.year, month = nowtime.month, day = nowtime.day, hour = 0, min = 0, sec = 0})
	local oneday = 60 * 60 * 24

	for i, v in pairs(data) do
		shangfenList:pushBackDefaultItem()
		local item = shangfenList:getItem(idx)
		local time = os.date("%Y/%m/%d %H:%M:%S", v.time)
		item:getChildByName('id'):setString(v.memberId)
		item:getChildByName('operate'):setString(v.mode == 0 and '下分' or '上分')
		item:getChildByName('num'):setString(v.score)
		item:getChildByName('time'):setString(time)
		idx = idx + 1

		-- 判断时间
		if today_lingchen - v.time <= oneday and today_lingchen - v.time > 0 then
			if v.mode == 0 then
				xia_sum = xia_sum + v.score
			else
				shang_sum = shang_sum + v.score
			end
		end
	end
	yesterday_shang:setString('' .. shang_sum)
	yesterday_xia:setString('' .. xia_sum)
end
----------------------------------------------------------------------------------------------

------------------------转让群主部分-----------------------------------------------------------
function GVSetScoreView:getChangePlayerId()
	return self.playerIDEditBox:getText()
end
----------------------------------------------------------------------------------------------

------------------------房间限制部分-----------------------------------------------------------
function GVSetScoreView:freshChoushui(mode)
	local choushui = self.roomlitLayer:getChildByName('choushui')
	if mode == 'add' then
		self.choushui = self.choushui == 10 and 10 or (self.choushui + 1)
	elseif mode == 'reduce' then
		self.choushui = self.choushui == 1 and 1 or (self.choushui - 1)
	end
	choushui:setString('' .. self.choushui .. '%')
end

function GVSetScoreView:freshRule(sender)
	local rule1 = self.roomlitLayer:getChildByName('1')
	local rule2 = self.roomlitLayer:getChildByName('2')
	rule1:getChildByName('active'):setVisible(false)
	rule2:getChildByName('active'):setVisible(false)
	sender:getChildByName('active'):setVisible(true)
end

function GVSetScoreView:getRoomLimit()
	local msg = {}
	local join = self.joinEditBox:getText()
	local qiang = self.qiangEditBox:getText()
	local tui = self.tuiEditBox:getText()
	local rule1 = self.roomlitLayer:getChildByName('1')
	msg.join = join == '' and self.join or tonumber(join)
	msg.qiang = qiang == '' and self.qiang or tonumber(qiang)
	msg.tui = tui == '' and self.tui or tonumber(tui)
	msg.choushui = self.choushui
	msg.rule = rule1:getChildByName('active'):isVisible() and 1 or 2
	return msg
end
-----------------------------------------------------------------------------------------------

function GVSetScoreView:getCurGroup()
	local groupInfo = self.group:getCurGroup()
	return groupInfo
end

return GVSetScoreView