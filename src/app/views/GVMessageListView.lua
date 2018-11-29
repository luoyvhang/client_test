local Scheduler = require('app.helpers.Scheduler')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local ConvertToTableView = require('app.helpers.ConvertToTableView')
local cache = require('app.helpers.cache')
local app = require('app.App'):instance()

local GVMessageListView = {}

function GVMessageListView:initialize()
	self.group = nil
	self.selectIdx = nil
end

function GVMessageListView:layout(group)
	self.group = group

	local mainPanel = self.ui:getChildByName('MainPanel')
	mainPanel:setPosition(display.cx, display.cy)
	self.mainPanel = mainPanel
	local messageLayer = mainPanel:getChildByName('messageLayer')
	local messageList = messageLayer:getChildByName('messageHandle')
	local messageItem = messageLayer:getChildByName('messageItem')
	messageList = ConvertToTableView.convert(messageList)

	self.item = messageItem
	self.tableView = messageList
	self.item:setVisible(false)

	local function handler(func)
		return function(...)
			return func(self, ...)
		end
	end

	self.tableView:registerScriptHandler(handler(self.tableCellTouched), cc.TABLECELL_TOUCHED)
	self.tableView:registerScriptHandler(handler(self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	self.tableView:registerScriptHandler(handler(self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	self.tableView:registerScriptHandler(handler(self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.tableView:registerScriptHandler(handler(self.cellHightLight), cc.TABLECELL_HIGH_LIGHT)
	self.tableView:registerScriptHandler(handler(self.cellUnHightLight), cc.TABLECELL_UNHIGH_LIGHT)
	self.tableView:reloadData()
end

function GVMessageListView:reloadTableView()
	self.tableView:reloadData()
end

function GVMessageListView:freshTips(bShow)
	local messageLayer = self.mainPanel:getChildByName('messageLayer')
	local tips = messageLayer:getChildByName('tips')
	tips:setVisible(bShow)
end

function GVMessageListView:freshCellSelectImg(cell, bShow)
	-- local item = cell:getChildByTag(6666)
	-- item:getChildByName('selectBg'):setVisible(bShow or false)
end

function GVMessageListView:freshCell(cell, data)
	local item = cell:getChildByTag(6666)
	item:setVisible(true)

	local headimg = item:getChildByName('txKuang')
	self:freshCellHeadImg(headimg, data.userInfo.avatar)	
	local playerId = data.userInfo.playerId
	item:getChildByName('userID'):setString('ID:'..playerId)
	item:getChildByName('userName'):setString(data.userInfo.nickname)

	item:getChildByName('refuse'):addClickEventListener(function()
		self.emitter:emit('messageListOperate', {playerId, "reject"})
	end)
	item:getChildByName('agree'):addClickEventListener(function()
		self.emitter:emit('messageListOperate', {playerId, "accept"})
	end)			
end

function GVMessageListView:freshCellHeadImg(headimg, headUrl)
	headimg:loadTexture('views/public/tx.png')
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

-- ==================== table view callback =========================

function GVMessageListView:tableCellTouched(view, cell)
	if self.selectIdx then
		local lastCell = self.tableView:cellAtIndex(self.selectIdx)
		if lastCell then
			-- self:freshCellSelectImg(lastCell, false)
		end
	end
	self.selectIdx = cell:getIdx()
	-- self:freshCellSelectImg(cell, true)
end

function GVMessageListView:cellSizeForTable(view, idx)
	local size = self.item:getContentSize()
	return size.width, size.height
end

function GVMessageListView:tableCellAtIndex(view, idx)
	local dataIdx = idx + 1
	local cell = view:dequeueCell()

	local msg = self.group:getCurAdminMsg()
	if msg == nil then return end
	local data  
	local index = 1
	for k, v in pairs(msg) do
		if index == dataIdx then
			data = v
			break
		end
		index = index + 1
	end

    if nil == cell then
        cell = cc.TableViewCell:new()
        --创建列表项
        local item = self.item:clone()
        item:setPosition(cc.p(0, 0))
        item:setTag(6666)
		cell:addChild(item)
	end
	
	self:freshCell(cell, data)
	return cell
end

function GVMessageListView:numberOfCellsInTableView()
	local msg = self.group:getCurAdminMsg()
	local msgCnt = 0

	if msg then
		msgCnt = table.nums(msg) 
	end
	return msgCnt
end

function GVMessageListView:cellHightLight()
	
end

function GVMessageListView:cellUnHightLight()
	
end



return GVMessageListView