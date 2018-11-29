local tools = require('app.helpers.tools')
local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"
local cjson = require('cjson')
local LocalSettings = require('app.models.LocalSettings')

local MagicExpressView = {}
local emotionPath = 'views/xychat/'

function MagicExpressView:initialize()

    self.options = {}
    self.options['express'] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}


	if not io.exists(cc.FileUtils:getInstance():getWritablePath() .. '.ExpressConfig')  then
        LocalSettings:setExpressConfig('express', self.options['express'])
    else
        print(" LocalSettings:getExpressConfig(v..n) is not == nil")
    end

    self.options['express'] =  LocalSettings:getExpressConfig('express')
    dump(self.options['express'])
end

function MagicExpressView:layout(data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.user = data
    self.MainPanel = MainPanel

    self.top = self.MainPanel:getChildByName('top')
    self.emotion1 = self.MainPanel:getChildByName('emotion1')
    self.emotion2 = self.MainPanel:getChildByName('emotion2')
    self.emotion3 = self.MainPanel:getChildByName('emotion3')
    self.emotion4 = self.MainPanel:getChildByName('emotion4')
    self.midLayer = self.MainPanel:getChildByName('mid_layer')
    self.selectedExpress = self.MainPanel:getChildByName('selectedExpress')

    self:freshAllNodeAnimation()
    self:freshAllExpress()
end

function MagicExpressView:changeTab(sender, data)

    for i = 1, 4 do
        self.top:getChildByName('express' .. i):getChildByName('active'):setVisible(false)
        self.MainPanel:getChildByName('emotion' .. i):setVisible(false)
    end

    self.top:getChildByName('express' .. data):getChildByName('active'):setVisible(true)
    self.MainPanel:getChildByName('emotion' .. data):setVisible(true)
end

function MagicExpressView:setSelect(sender, tab)

    local num = sender:getName()
    local data = (tab - 1) * 12 + tonumber(num)
    local emotionNum = self:getEmotionNum()
    if not self.MainPanel:getChildByName('emotion' .. tab):getChildByName(num):isVisible() then
        if emotionNum == 0 then return end
        for i,v in pairs(self.options['express']) do
            if v == data then
                self:stopOneAnimation(v)
                for j = i, emotionNum - 1 do
                    self.options['express'][j] = self.options['express'][j + 1]
                end
                self.options['express'][emotionNum] = 0
                LocalSettings:setExpressConfig('express', self.options['express'])
                self:freshAllExpress()
                return 
            end
        end
    else
        if emotionNum == 12 then
            tools.showRemind("最多只能选择12个表情")
            return 
        end
        for i,v in pairs(self.options['express']) do
            if i > emotionNum then
                self.options['express'][i] = data
                LocalSettings:setExpressConfig('express', self.options['express'])
                local node = self.MainPanel:getChildByName('emotion' .. tab):getChildByName('node'):getChildByName('node' .. num)
                self.selectedExpress:getChildByName('' .. (emotionNum + 1)):getChildByName('image'):loadTexture(emotionPath .. data .. '.png')
                self.selectedExpress:getChildByName('' .. (emotionNum + 1)):getChildByName('image'):setVisible(true)
                self:freshSelected(node, tab, tonumber(num), false)
                self:startCsdAnimation(node,data,true,1.0)
                return 
            end
        end
    end
end

function MagicExpressView:freshAllNodeAnimation()
    for i = 1, 12 do
        local data = self.options['express'][i]
        if data > 0 then
            local hang, lie = self:getLocation(data)
            local node = self.MainPanel:getChildByName('emotion' .. hang):getChildByName('node'):getChildByName('node' .. lie)
            self:freshSelected(node, hang, lie, false)
            self:startCsdAnimation(node,data,true,1.0)
        end
    end
end

function MagicExpressView:freshSelected(node, hang, lie, show)
    node:setVisible(not show)
    self.MainPanel:getChildByName('emotion' .. hang):getChildByName('' .. lie):setVisible(show)
    self.MainPanel:getChildByName('emotion' .. hang):getChildByName('selected'):getChildByName('' .. lie):setVisible(not show)
end

function MagicExpressView:freshOneExpress(sender)
    local data = tonumber(sender:getParent():getName())
    if not sender:getParent():getChildByName('image'):isVisible() then
        return 
    end
    local emotionNum = self:getEmotionNum()
    if emotionNum == 0 then return end
    for i,v in pairs(self.options['express']) do
        if i == data then
            self:stopOneAnimation(v)
            for j = i, emotionNum - 1 do
                self.options['express'][j] = self.options['express'][j + 1]
            end
            self.options['express'][emotionNum] = 0
            LocalSettings:setExpressConfig('express', self.options['express'])
            self:freshAllExpress()
            return 
        end
    end
end

function MagicExpressView:freshAllExpress()
    for i = 1, 12 do
        self.selectedExpress:getChildByName('' .. i):getChildByName('image'):setVisible(false)
        if self.options['express'][i] > 0 then
            self.selectedExpress:getChildByName('' .. i):getChildByName('image'):loadTexture(emotionPath .. self.options['express'][i] .. '.png')
            self.selectedExpress:getChildByName('' .. i):getChildByName('image'):setVisible(true)
        end
    end
end

function MagicExpressView:getEmotionNum()
    local num = 0
    for i, v in pairs(self.options['express']) do
        if v > 0 then
            num = num + 1
        end
    end
    return num
end

function MagicExpressView:getLocation(data)
    local hang = math.ceil(data / 12)
    local lie = (data - 1) % 12 + 1
    return hang, lie
end

function MagicExpressView:startCsdAnimation(node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/animation/magicExpress/csb/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
        action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function MagicExpressView:stopOneAnimation(data)
    local hang, lie = self:getLocation(data)
    local node = self.MainPanel:getChildByName('emotion' .. hang):getChildByName('node'):getChildByName('node' .. lie)
    self:freshSelected(node, hang, lie, true)
    node:stopAllActions()
end

function MagicExpressView:stopAllAnimation()
    for i = 1, 12 do
        local data = self.options['express'][i]
        if data > 0 then
            local hang, lie = self:getLocation(data)
            local node = self.MainPanel:getChildByName('emotion' .. hang):getChildByName('node'):getChildByName('node' .. lie)
            self:freshSelected(node, hang, lie, true)
            node:stopAllActions()
        end
    end
end

return MagicExpressView
