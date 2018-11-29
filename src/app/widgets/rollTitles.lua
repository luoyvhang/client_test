local display = require('cocos.framework.display')

local tools = require('app.helpers.tools')
local stack = class("stack")

function stack:ctor(max)
    self.data = {}
    self.max = max or 3
end

function stack:setCallBack(func)
    self.releaseFunc = func
end

function stack:size()
    return #self.data
end

function stack:clean()
    self.data = {}
end

function stack:at(id)
    return self.data[id]
end

function stack:getAll()
    return self.data
end

function stack:push(value)
    table.insert(self.data, value)

    if #self.data > self.max then
        local inst = table.remove(self.data, 1)
        if self.releaseFunc then
            self.releaseFunc(inst)
        end
    end
end

function stack:has(key)
    for i, v in ipairs(self.data) do
        if v == key then
            return true
        end
    end

    return false
end

function stack:getTop()
    return self.data[#self.data]
end

local RollTitles = class("RollTitles", function()
    return display.newNode()
end)

function RollTitles:ctor()
    self.layer = display.newNode()
    self.start = false
    self.content = {}
    self.RollWidth = 0

    self.scrollView = cc.ScrollView:create()
    self.scrollView:setTouchEnabled(false)
    self.scrollView:ignoreAnchorPointForPosition(true)
    self.scrollView:setBounceable(true)
    self.layer:addChild(self.scrollView)
    self:addChild(self.layer)

    self.msgStack = stack.new(300)
    self.current_index = 0
    self.stack = stack.new()

    self.myLbal = display.newNode():addTo(self.scrollView)
    self.myLbal:retain()

    tools.gcnode(function()
        self.myLbal:release()
    end):addTo(self):hide()

    self:registerScriptHandler(function(event)
        if "enter" == event then
            tools.schedule(self, function() self:step() end, 0.01)
        end
    end)
end

function RollTitles:startUpdate()
    self:performWithDelay(function()
        self:request_start()
    end, 0.5)
end

function RollTitles:setWorldMessageInstance(inst)
    local last = self.WorldMessageInstance
    self.WorldMessageInstance = inst
    if last == nil then
        self.WorldMessageInstance:addMessages(self.msgStack:getAll())

        self.WorldMessageInstance:swapBuffer()
    end
end

function RollTitles:setRollSize(size)
    self.scrollView:setViewSize(size)
end

function RollTitles:step()
    if self.start then
        local x = self.myLbal:getPositionX()
        self.myLbal:setPositionX(x - 1)
        if x <= -self.myLbal:getContentSize().width then
            self:doNext()
        end
    end
end

function RollTitles:doNext()
    self.myLbal:setPosition(self.scrollView:getViewSize().width, 40)

    self.current_index = self.current_index + 1

    if self.current_index > self.msgStack:size() then
        self.current_index = 1
    end

    self.myLbal:removeAllChildren()
    local msg = self.msgStack:at(self.current_index)

    --title
    for color, text in string.gmatch(msg.title, "(%[%d+%,%d+%,%d+%])(.*)") do
            local r,g,b = string.match(color, "%[(%d+)%,(%d+)%,(%d+)%]")

            titleColor = cc.c3b(r,g,b)
            titleContent = text
     end

    local namelabel = cc.LabelTTF:create(titleContent..": ", "Microsoft YaHei", 35)
    self.myLbal:addChild(namelabel)
    --self.myLbal:setPosition(cc.p(0,40))
    namelabel:setAnchorPoint(cc.p(0,1))
    namelabel:setFontFillColor(titleColor)

    --[[local namelabel = display.newTTFLabel({
        text = titleContent..": ",
        font = "Microsoft YaHei", color = titleColor, size = 35
    }):addTo(self.myLbal):pos(0,20)]]

    --content
    local endLabel = ""
    for color, text in string.gmatch(msg.content, "(%[%d+%,%d+%,%d+%])([^%]%[\n]*)") do
        local r,g,b = string.match(color, "%[(%d+)%,(%d+)%,(%d+)%]")
        titleColor = cc.c3b(r,g,b)
        titleContent = text
        endLabel = endLabel.."[color="..string.format("%X",r)..string.format("%X",g)..string.format("%X",b).."]"..text.."[/color]"
    end

    local nRichLabel = require('app.widgets.nRichLabel')
    local label = nRichLabel.new({str=endLabel, font="Microsoft Yahei", fontSize=35, rowWidth=10000, rowSpace = 0})
    self.myLbal:addChild(label,14)
    label:setAnchorPoint(cc.p(0,1))
    label:setPosition(cc.p(namelabel:getContentSize().width,0))

    self.myLbal:setContentSize(cc.size(namelabel:getContentSize().width+label.ocWidth+250, 25))

    self.start = true
end

function RollTitles:addMsg(messages)
    local newmsg = {}
    for i = 1, #messages do
        local msg = messages[i]
        table.insert(newmsg, msg)

        self.msgStack:push(msg)
    end

    if self.WorldMessageInstance then
        self.WorldMessageInstance:addMessages(newmsg)
    end

    self:stopAllActions()
    print(self.aready_start, old_count ~= self.stack:size())
    print(old_count, self.stack:size())
    if not self.aready_start then
        self.aready_start = true
        self:doNext()
    end
end

return RollTitles
