local tools = require('app.helpers.tools')
local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"
local cjson = require('cjson')

local CertifyView = {}

function CertifyView:initialize()
	
end

function CertifyView:layout(data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.data = data
    self.MainPanel = MainPanel
    self.leftLayer = self.MainPanel:getChildByName('leftlayer')

    -- editbox
    -- 手机号码
    local name = self.MainPanel:getChildByName('name')
	self.modifyNameEditBox = tools.createEditBox(name, {
		-- holder
		defaultString = '请填写真实姓名',
        holderSize = 25,
        holderfontType = 'views/font/Fangzheng.ttf',
		holderColor = cc.c3b(139,105,20),

		-- text
		fontColor = cc.c3b(238,202,111),
        size = 25,
        maxCout = 4,
		fontType = 'views/font/Fangzheng.ttf',	
		inputMode = cc.EDITBOX_INPUT_MODE_ANY,
    },
    'views/shop/empty.png')

    -- 验证码
    local certifyNum = self.MainPanel:getChildByName('certifyNum')
	self.modifyCertifyNumEditBox = tools.createEditBox(certifyNum, {
		-- holder
		defaultString = '请填写真实有效证件号',
        holderSize = 25,
        holderfontType = 'views/font/Fangzheng.ttf',
		holderColor = cc.c3b(139,105,20),

		-- text
		fontColor = cc.c3b(238,202,111),
        size = 25,
        maxCout = 18,
		fontType = 'views/font/Fangzheng.ttf',	
		inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    },
    'views/shop/empty.png')

    -- self:freshBindBottom(self.phoneNum,self.phoneNum == nil and true or false)

    -- 开始动画
    self:startCsdAnimation(self.MainPanel:getChildByName("CertifyNode"),"Certify/CertifyAnimation", true, 1.0)
    self:startCsdAnimation(self.MainPanel:getChildByName("BlinkNode"),"Certify/BlinkAnimation", true, 0.5)
    self:startCsdAnimation(self.leftLayer:getChildByName("nnbodyNode"),"lobby/nnBodyAnimation", true, 0.6)
end

function CertifyView:getName()
    return self.modifyNameEditBox:getText()
end

function CertifyView:getCertifyNum()
    return self.modifyCertifyNumEditBox:getText()
end

function CertifyView:startCsdAnimation(node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
        action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function CertifyView:stopAllAnimation()
    self.MainPanel:getChildByName("CertifyNode"):stopAllActions()
    self.leftLayer:getChildByName("nnbodyNode"):stopAllActions()
    self.MainPanel:getChildByName("BlinkNode"):stopAllActions()
end

return CertifyView
