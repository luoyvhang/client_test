local tools = require('app.helpers.tools')

local XYWatcherListView = {}
function XYWatcherListView:initialize()
	
end

function XYWatcherListView:layout()
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width, display.height))
	MainPanel:setPosition(display.cx, display.cy)
	self.MainPanel = MainPanel
	
	local content = MainPanel:getChildByName('content')
	self.content = content

	self.cnt = content:getChildByName('cnt')
	self.cnt:setVisible(false)
	
	local list = content:getChildByName('list')
	local row = list:getChildByName('item')
	list:setItemModel(list:getItem(0))
	list:removeAllItems()
	self.list = list

end

function XYWatcherListView:freshListView(data)
	self.list:removeAllItems()
	local cnt = 0
	for i, v in ipairs(data) do
		cnt = cnt + 1
        local j = math.ceil(i/4)
        local k = i % 4
        -- k = (k == 0) and 3 or k
        self:freshListItem(j, k, v)
	end
	self:freshCnt(cnt)
end

function XYWatcherListView:freshCnt(cnt)
	self.cnt:setString(string.format( "(%s)",cnt))
	self.cnt:setVisible(cnt>0)
end


function XYWatcherListView:freshListItem(row, column, data)
	if column == 1 then
		self.list:pushBackDefaultItem()
	end

    local tabRow = self.list:getItems()
	local row = tabRow[#tabRow]
	
	if column == 1 then
		row:setItemModel(row:getItem(0))
		row:removeAllItems()
	end

	row:pushBackDefaultItem()
	local tabItme = row:getItems()
	local item = tabItme[#tabItme]

	self:freshHeadImg(item, data.avatar)
	self:freshNameAndId(item, data.nickname, data.playerId)
end

-- ============= item view =============
function XYWatcherListView:freshHeadImg(item, headUrl)
    local node = item:getChildByName('avatar')
    if headUrl == nil or headUrl == '' then return end
    local cache = require('app.helpers.cache')		 
	cache.get(headUrl, function(ok, path)
		if ok then
			node:show()
			node:loadTexture(path)
		else
			node:loadTexture('views/public/tx.png')
		end
	end)
end

function XYWatcherListView:freshNameAndId(item, name, id)
	local idNode = item:getChildByName('id')
	idNode:setString(string.format( "(id:%s)",id))

	local nameNode = item:getChildByName('namelayout'):getChildByName('name')
	nameNode:setString(string.format( "%s",name))
end

return XYWatcherListView
