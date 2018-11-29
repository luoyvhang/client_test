local ListView = class('ListView', function()
	return display.newNode()
end)
local tools = require('app.helpers.tools')

ListView.TOUCH_BEGAN = "TOUCH BEGAN"
ListView.TOUCH_MOVED = "TOUCH_MOVED"
ListView.TOUCH_ENDED = "TOUCH_ENDED"
ListView.FOCUS_CHANGES = "FOCUS_CHANGES"

ListView.pageState = {
    Horizontal = 1,
    Vertical = 2
}

function ListView:getFrameByRatio(nowState, tgState, Ratio)
    if type(nowState) == "table" then
        local result = {}
        for i = 1, #nowState do
            result[i] = (nowState[i] + (tgState[i] - nowState[i]) * Ratio)
        end
        return result
    else
        return (nowState + (tgState - nowState) * Ratio)
    end
end

function ListView:getFrameByDistane(nowState, tgState, nowDistance, totleDistance)
    if totleDistance ~= 0 then
        local frame = math.abs(nowDistance / totleDistance)
        if frame <= 1 then
            return self:getFrameByRatio(nowState, tgState, frame)
        else
            return self:getFrameByRatio(nowState, tgState, 1)
        end
    else
        return self:getFrameByRatio(nowState, tgState, 1)
    end
end

function ListView:horGetTarget(forward, nowPos)
    if forward then
        for i = #self.designItems - 1, 1, -1  do
            if nowPos > self.designItems[i].x then
                return i + 1
            elseif nowPos == self.designItems[i].x then
                return i
            end
        end
    else
        for i = 2, #self.designItems, 1  do
            if nowPos < self.designItems[i].x then
                return i - 1
            elseif nowPos == self.designItems[i].x then
                return i
            end
        end
    end
end

function ListView:verGetTarget(forward, nowPos)
    if forward then
        for i = #self.designItems - 1, 1, -1  do
            if nowPos > self.designItems[i].y then
                return i + 1
            elseif nowPos == self.designItems[i].y then
                return i
            end
        end
    else
        for i = 2, #self.designItems, 1  do
            if nowPos < self.designItems[i].y then
                return i - 1
            elseif nowPos == self.designItems[i].y then
                return i
            end
        end
    end
end


function ListView:__updateFocus()
    for i,v in pairs(self.items) do
        if v.targetPos == self.designFocus then
            self.focus = i
            self:sendEvent(ListView.FOCUS_CHANGES, v.item, self.focus)
            break
        end
    end
end

function ListView:adjustOver()
    self.isRun = false
    self:stopAllActions()
    self.useTime = 0
    self.adjustSpeed = 0
end

function ListView:__itemAdjust(dt)
	self.useTime = self.useTime + 1
	if self.useTime < self.adjustTime then
		if self.needInertia then
			self.adjustSpeed = self.adjustSpeed + self.drag
			if self.movToDis then
				self.nowDis = self.nowDis + self.adjustSpeed
				if self.nowDis >= self.movToDis then
					self.movToDis = nil
					self.useTime = 0
					self.offset = 0
					self:generateAdjustInfo()
					return
				end
			else
				if math.abs(self.adjustSpeed) < 10 then
					self.useTime = 0
					self.offset = 0
					self:generateAdjustInfo()
					return
				end
			end
		end
		self.moveProcess(self.adjustSpeed)
	else
		self:__updateFocus()
		self:adjustOver()
	end
end

function ListView:generateAdjustInfo()
    if self.offset ~= nil and math.abs(self.offset) > 10 then
        if math.abs(self.offset) > 45 then
            self.offset = self.offset > 0 and 45 or -45
        end
        self.adjustSpeed = self.offset
        self.drag = self.offset > 0 and -0.5 or 0.5
        self.adjustTime = math.abs(self.adjustSpeed / self.drag)
        self.needInertia = true
    else
        self.needInertia = false
        self.adjustTime = 15
        if self.direction == self.pageState.Horizontal then
            local Pos = self:horGetTarget(false, self.items[1].x)
            if self.designItems[Pos + 1].x - self.items[1].x > self.items[1].x - self.designItems[Pos].x then
                self.adjustSpeed = -(self.items[1].x - self.designItems[Pos].x) / self.adjustTime
            else
                self.adjustSpeed = (self.designItems[Pos + 1].x - self.items[1].x) / self.adjustTime
            end
        else
            local Pos = self:verGetTarget(false, self.items[1].y)
            if self.designItems[Pos + 1].y - self.items[1].y > self.items[1].y - self.designItems[Pos].y then
                self.adjustSpeed = -(self.items[1].y - self.designItems[Pos].y) / self.adjustTime
            else
                self.adjustSpeed = (self.designItems[Pos + 1].y - self.items[1].y) / self.adjustTime
            end
        end
    end
end

function ListView:movingEffect(items)
    items.item:setPosition(items.x, items.y)
    for i = 1, #items.Property do
        items.Property[i] = self:getFrameByRatio(self.designItems[items.startPos].Property[i], self.designItems[items.targetPos].Property[i],
        self.movePer)
        self.setEffectRunc[i](items.item, items.Property[i])
    end
end

function ListView:horMovingProcess(offset)
    self.items[1].x = self:__borderJudgment(self.items[1].x + offset)
    if offset < 0 then
        for i = 1,#self.items do
            if i == 1 then
                self.items[i].targetPos = self:horGetTarget(false, self.items[i].x)
                self.items[i].startPos = self.items[i].targetPos + 1
                self.movePer = (self.designItems[self.items[i].startPos].x - self.items[i].x) / (self.designItems[self.items[i].startPos].x - self.designItems[self.items[i].targetPos].x)
            else
                self.items[i].targetPos = (self.items[i - 1].targetPos == (#self.designItems - 1)) and 1 or (self.items[i - 1].targetPos + 1)
                self.items[i].startPos = self.items[i].targetPos + 1
                self.items[i].x = (self.designItems[self.items[i].startPos].x - (self.designItems[self.items[i].startPos].x - self.designItems[self.items[i].targetPos].x) * self.movePer)
            end
            self:movingEffect(self.items[i])
        end
    else
        for i = 1,#self.items do
            if i == 1 then
                self.items[i].targetPos = self:horGetTarget(true, self.items[i].x)
                self.items[i].startPos = self.items[i].targetPos - 1
                self.movePer = (self.items[i].x - self.designItems[self.items[i].startPos].x) / (self.designItems[self.items[i].targetPos].x - self.designItems[self.items[i].startPos].x)
            else
                self.items[i].targetPos = self.items[i - 1].targetPos == #self.designItems and 2 or self.items[i - 1].targetPos + 1
                self.items[i].startPos = self.items[i].targetPos - 1
                self.items[i].x = (self.designItems[self.items[i].startPos].x + (self.designItems[self.items[i].targetPos].x - self.designItems[self.items[i].startPos].x) * self.movePer)
            end
            self:movingEffect(self.items[i])
        end
    end
end

function ListView:vorMovingProcess(offset)
    self.items[1].y = self:__borderJudgment(self.items[1].y + offset)
    if offset < 0 then
        for i = 1,#self.items do
            if i == 1 then
                self.items[i].targetPos = self:verGetTarget(false, self.items[i].y)
                self.items[i].startPos = self.items[i].targetPos + 1
                self.movePer = (self.designItems[self.items[i].startPos].y - self.items[i].y) / (self.designItems[self.items[i].startPos].y - self.designItems[self.items[i].targetPos].y)
            else
                self.items[i].targetPos = (self.items[i - 1].targetPos == (#self.designItems - 1)) and 1 or (self.items[i - 1].targetPos + 1)
                self.items[i].startPos = self.items[i].targetPos + 1
                self.items[i].y = (self.designItems[self.items[i].startPos].y - (self.designItems[self.items[i].startPos].y - self.designItems[self.items[i].targetPos].y) * self.movePer)
            end
            self:movingEffect(self.items[i])
        end
    else
        for i = 1,#self.items do
            if i == 1 then
                self.items[i].targetPos = self:verGetTarget(true, self.items[i].y)
                self.items[i].startPos = self.items[i].targetPos - 1
                self.movePer = (self.items[i].y - self.designItems[self.items[i].startPos].y) / (self.designItems[self.items[i].targetPos].y - self.designItems[self.items[i].startPos].y)
            else
                self.items[i].targetPos = self.items[i - 1].targetPos == #self.designItems and 2 or self.items[i - 1].targetPos + 1
                self.items[i].startPos = self.items[i].targetPos - 1
                self.items[i].y = (self.designItems[self.items[i].startPos].y + (self.designItems[self.items[i].targetPos].y - self.designItems[self.items[i].startPos].y) * self.movePer)
            end
            self:movingEffect(self.items[i])
        end
    end
end

function ListView:__borderJudgment(nextPos)
    if nextPos < 0 then
        return (self.boundary - (0 - nextPos))
    end

    if nextPos > self.boundary then
        return (0 - (self.boundary - nextPos))
    end
    return nextPos
end

function ListView:addEffectOnMoing(getEffectFunc, setEffectRunc, defaultEffect)
    local itemsCout = #self.items
    for i = 1,itemsCout do
        local scale = getEffectFunc(self.items[i].item)
        table.insert(self.items[i].Property, scale)
        table.insert(self.designItems[i + 1].Property, scale)
        if i == itemsCout then
            if defaultEffect then
                table.insert(self.designItems[1].Property, defaultEffect)
            else
                table.insert(self.designItems[1].Property, scale)
            end
        end
    end
    table.insert(self.setEffectRunc, setEffectRunc)
end

--插入一个item到pageView--
--itemTouchFunc 当item在焦点时被点中触发的回调函数
function ListView:insertItem(item, x, y, z, itemTouchFunc)
    if self.direction == self.pageState.Horizontal then
        x = math.abs(x)
        self.boundary = self.boundary + x
        x = self.boundary
    else
        y = math.abs(y)
        self.boundary = self.boundary + y
        y = self.boundary
    end

    local items = {}
    items.targetPos = #self.designItems + 1
    items.item = item
    items.func = itemTouchFunc or nil
    items.x, items.y = x, y
    items.Property = {}
    table.insert(self.items, items)
		self:addChild(item, z)
		item:setPosition(cc.p(x, y))
		print(x,y)
    local itemInfo = {}
    itemInfo.x, itemInfo.y = x, y
    itemInfo.Property = {}
    table.insert(self.designItems, itemInfo)
end

function ListView:moveDesign(itemPos, time)
    self.needInertia = false
    self.adjustTime = time / 0.01
    self.adjustSpeed = (self.designItems[self.designFocus].x - self.items[itemPos].x) / self.adjustTime
    tools.schedule(self, function() self:__itemAdjust(0.01) end, 0.01)
end

--设置可以相应滑动消息的区域--
function ListView:setTouchRect(rect)
    self:setCascadeBoundingBox(rect)
end

function ListView:setHorizontal(bool)
    if bool then
        self.direction = self.pageState.Horizontal
        self.moveProcess = function(offset) self:horMovingProcess(offset) end
    else
        self.direction = self.pageState.Vertical
        self.moveProcess = function(offset) self:vorMovingProcess(offset) end
    end
end

------设置焦点为第一个item,默认为第一个---------
function ListView:setDesignFocusPos(pos)
    self.designFocus = pos + 1
    self.focus = pos
end

function ListView:getFocusItem()
    return self.items[self.focus].item
end

function ListView:setMovDis(dis)
    self.offset = 48
    self.nowDis = 0
    self.movToDis = dis
end

function ListView:on(name, func)
    self.event[name] = func
end

function ListView:sendEvent(name, ...)
    print("send event name:", name)
    if self.event[name] then
        self.event[name](...)
    end
end

function ListView:cantDrag(b)
    self._cantDrag = b
end

function ListView:setTouchRect(rect)
    self.touchRect = rect
end

function ListView:__defaultInit()
    self.event = {}
    self.designItems = {}
    table.insert(self.designItems, {x = 0, y = 0, Property = {}})
    self.boundary = 0
    self.items = {}
    self.setEffectRunc = {}
    self.useTime = 0
    self.designFocus = 2
    self.focus = 1
    self.touchRect = cc.rect(0, 0, display.width, display.height)
    self:setHorizontal(true)

	local function onTouchBegan(touch, event)
    if cc.rectContainsPoint(self.touchRect,touch:getLocation()) then
			print("began")
      self:adjustOver()
			local pos = touch:getLocation()
			self.last = pos.y
			self.prev = pos.y
			self.offset = 0
	    self:sendEvent(ListView.TOUCH_BEGAN, pos.x, pos.y)
			return true
    end
	end

	local function onTouchMoved(touch)
    if self._cantDrag then return end
    --self:sendEvent(ListView.TOUCH_MOVED)
		local pos = touch:getLocation()
		self.offset = pos.y - self.prev
		self.prev = pos.y
    self.moveProcess(self.offset)
	end

	local function onTouchEnded(touch)
		local pos = touch:getLocation()
		self:generateAdjustInfo()
  	self:sendEvent(ListView.TOUCH_ENDED, pos.x, pos.y)
    tools.schedule(self, function() self:__itemAdjust(0.01) end, 0.01)
		if not self.isRun and math.abs(pos.x - self.last) < 22 then
        for i, v in pairs(self.items) do
            local bdBox = v.item:getBoundingBox()
            local wPos = v.item:getParent():convertToWorldSpace(cc.p(v.item:getPosition()))
            bdBox.x = wPos.x - bdBox.width / 2
            bdBox.y = wPos.y - bdBox.height / 2
            if cc.rectContainsPoint(bdBox,cc.p(pos.x,pos.y)) then
                v.func(v.targetPos)
                break
            end
        end
        --self:sendEvent(ListView.TOUCH_CLICK, pos.x, pos.y)
		end
        self.isRun = true
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ListView:ctor()
    self:__defaultInit()
end

return  ListView
