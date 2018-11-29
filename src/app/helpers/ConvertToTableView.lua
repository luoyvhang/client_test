local ConvertToTableView = {}

function ConvertToTableView.convert(listView, param)
	param = param or {}
	local parentNode = listView:getParent()
	local size = listView:getContentSize()
	local direction = listView:getDirection()  --1:垂直 2:水平

	local position = cc.p(listView:getPositionX(), listView:getPositionY())
	listView:removeFromParent()

	local view = cc.TableView:create(cc.size(size.width, size.height))	
	parentNode:addChild(view)	
	view:setPosition(position)	
	view:setDirection(direction)  
    view:setVerticalFillOrder(param.fillOrder or cc.TABLEVIEW_FILL_TOPDOWN)  
	view:setDelegate()

    return view
end

-- TableView被触摸的时候的回调，主要用于选择TableView中的Cell
function ConvertToTableView.tableCellTouched(view, cell)
	
end

-- 返回TableView中Cell的尺寸大小
function ConvertToTableView.cellSizeForTable(view)
	local item = self.item:clone()
	local size = item:getContentSize()
	return size.width, size.height
end

-- 为TableView创建在某个位置的Cell
function ConvertToTableView.tableCellAtIndex(view, idx)
	local index = idx + 1
	local cell = view:dequeueCell()

    local item = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
        --创建列表项
        local item = self.item:clone()
        item:setPosition(cc.p(0, 0))
        item:setTag(123)
        cell:addChild(item)
    else
        item = cell:getChildByTag(123)
    end

	return cell
end

-- 返回TableView中Cell的数量
function ConvertToTableView.numberOfCellsInTableView()
	return 10
end

function ConvertToTableView.cellHightLight()
end

function ConvertToTableView.cellUnHightLight()
end

return ConvertToTableView
