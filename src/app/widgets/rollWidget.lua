--[[
args={
    text={
    {content="hello",color={r=255,g=222,b=123}},
    {content="wahahhasd",color={r=255,g=222,b=0}},
    {content="c喔喔",color={r=255,g=2,b=1}}
    },
    font='Microsoft YaHei',
    size=23
}
]]
local tools = require('app.helpers.tools')
local BIAS = 30
local CONTENT_FORMAT = "[color=%X]%s[/color]"

local RollWidget = class("RollWidget", function()
    return display.newNode()
end)

function RollWidget:ctor()
    -- data
    self.messageList = {}
    self.curMsgIndex = 1
    self.start = false
    self.totalWidth = 0
    self.rollSize = nil

    self.layer = display.newNode()
    self:addChild(self.layer)

    self.myLbal = display.newNode():addTo(self.layer)

    self:registerScriptHandler(function(event)
        if "enter" == event then
            tools.schedule(self, function() self:step() end, 0.01)
        end
    end)

    -- 吞掉区域外的所有事件
    -- local function onTouched(eventType, x, y)
    --     if eventType == "began" then
    --         local wpos = self:convertToWorldSpace(cc.p(0, 0))
    --         print('wx_, wy_',wpos.x, wpos.y,x,y)
    --         print(self.rollSize.width,self.rollSize.height)
    --         if (x > wpos.x) and (x < wpos.x + self.rollSize.width) and
    --             (y < wpos.y) and (y > wpos.y - self.rollSize.height) then
    --             print("in")
    --             return false
    --         else
    --             print('out')
    --         end
    --     elseif eventType == "moved" then
    --     elseif eventType == "ended" then
    --     end
    --     return true
    -- end
    -- local touchLayer = cc.Layer:create()
    -- self:addChild(touchLayer)
    -- touchLayer:setTouchEnabled(true)
    -- touchLayer:registerScriptTouchHandler(onTouched, false, 0, false)
end

function RollWidget:step()
    if self.start then
        local x = self.myLbal:getPositionX() - 1
        if x <= -self.totalWidth - BIAS then
            self:showNextMessage()
        else
            self.myLbal:setPositionX(x)
        end
    end
end

function RollWidget:showNextMessage()
    self.myLbal:removeAllChildren()

    self.curMsgIndex = self.curMsgIndex + 1

    if self.curMsgIndex > #self.messageList then
        self.curMsgIndex = 1
    end
    local msg = self.messageList[self.curMsgIndex]
    if msg == nil then
        print("msg == nil")
        return
    end

    -- 创建label
    local label_ = require('app.widgets.nRichLabel').new(msg, true, self.callBack)
    self.myLbal:addChild(label_)
    label_:setAnchorPoint(cc.p(0,0.5))
    self.myLbal:setPosition(self.rollSize.width + BIAS, 0)
    self.totalWidth = label_.size.width
    self.start = true
end

-- 设置滚动区域
function RollWidget:setRollSize(size)
    self.rollSize = size
end

-- 添加消息
function RollWidget:setMsg(messages)
    self.curMsgIndex = 0
    self.messageList = messages
    self:beginRoll()
end

-- 开始滚动
function RollWidget:beginRoll()
    -- self:stopAllActions()
    self:showNextMessage()
end

-- 开始滚动
function RollWidget:registerClickCallBack(callBack_)
    self.callBack = callBack_
end

return RollWidget
