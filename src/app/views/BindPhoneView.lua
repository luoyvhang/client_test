local tools = require('app.helpers.tools')
local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"
local cjson = require('cjson')

local smssdk = nil
if device.platform == 'ios' or device.platform == 'android' then
    smssdk = require('smssdk')
end

local BindPhoneView = {}

local ACTION_GET_CODE    = 1
local ACTION_COMMIT_CODE = 2

function BindPhoneView:initialize()
	
end

function BindPhoneView:layout(data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.data = data
    self.shopRight = self.data.shopRight or 0 
    self.phoneNum = self.data.phoneNum or app.session.user:getMyPhoneNum()
    self.MainPanel = MainPanel
    self.bindLayer = self.MainPanel:getChildByName('bindLayer')
    self.leftLayer = self.bindLayer:getChildByName('leftlayer')

    -- editbox
    -- 手机号码
    local phone = self.bindLayer:getChildByName('phone')
	self.modifyPhoneEditBox = tools.createEditBox(phone, {
		-- holder
		defaultString = '请输入您的手机号码',
        holderSize = 25,
        holderfontType = 'views/font/Fangzheng.ttf',
		holderColor = cc.c3b(139,105,20),

		-- text
		fontColor = cc.c3b(238,202,111),
        size = 25,
        maxCout = 11,
		fontType = 'views/font/Fangzheng.ttf',	
		inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    },
    'views/shop/empty.png')

    -- 验证码
    local code = self.bindLayer:getChildByName('code')
	self.modifyCodeEditBox = tools.createEditBox(code, {
		-- holder
		defaultString = '请输入验证码',
        holderSize = 25,
        holderfontType = 'views/font/Fangzheng.ttf',
		holderColor = cc.c3b(139,105,20),

		-- text
		fontColor = cc.c3b(238,202,111),
        size = 25,
        maxCout = 4,
		fontType = 'views/font/Fangzheng.ttf',	
		inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    },
    'views/shop/empty.png')

    self:freshBindBottom(self.phoneNum,self.phoneNum == nil and true or false)

    -- 开始动画
    self:startCsdAnimation(self.bindLayer:getChildByName("BindPhoneNode"),"BindPhone/BindPhoneAnimation", true, 0.8)
end

--正则检测手机号
function BindPhoneView:checkPhoneNum()
    local num = self:getPhone()
    if num == "" then
        tools.showRemind("请输入手机号!")
        return false
    end
    local num1 = string.match(num,"[1][3][0,1,2,3,4,5,6,7,8,9]%d%d%d%d%d%d%d%d")
    local num2 = string.match(num,"[1][4][5,7]%d%d%d%d%d%d%d%d")
    local num3 = string.match(num,"[1][5][0,1,2,3,5,6,7,8,9]%d%d%d%d%d%d%d%d")
    local num4 = string.match(num,"[1][7][3,6,7,8]%d%d%d%d%d%d%d%d")
    local num5 = string.match(num,"[1][8][0,1,2,3,4,5,6,7,8,9]%d%d%d%d%d%d%d%d")
    local num6 = string.match(num,"[1][7][0][0,5,7,8,9]%d%d%d%d%d%d%d")
    print("num1------------------"..string.format( "%s",num1 ))
    print("num2------------------"..string.format( "%s",num2 ))
    print("num3------------------"..string.format( "%s",num3 ))
    print("num4------------------"..string.format( "%s",num4 ))
    print("num5------------------"..string.format( "%s",num5 ))
    print("num6------------------"..string.format( "%s",num6 ))
    print("---------------------------------------------------------")
    if  num1 == num or num2 == num or num3 == num or 
        num4 == num or num5 == num or num6 == num then
            return true
    end
    tools.showRemind("请输入正确的手机号!")
    return false
end

function BindPhoneView:getPhone()
    return self.modifyPhoneEditBox:getText()
end

function BindPhoneView:getCode()
    return self.modifyCodeEditBox:getText()
end

function BindPhoneView:getResult()
    local data = nil
    local body = nil
    if device.platform == 'ios' or device.platform == 'android' then
        data = smssdk.getResult()
        body = cjson.decode(data)
        print('getResult!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    end
    if body then
        if body.code == 0 then
            -- 0是默认值 什么都不做
            print('Resultcode = 0')
            return 
        elseif body.code == 1 then
            -- 1是成功
            if body.action and body.action == ACTION_GET_CODE then
                tools.showRemind("短信验证码已发送!")
            elseif body.action == ACTION_COMMIT_CODE then
                tools.showRemind("验证成功")
                app.session.user:setPhoneNum(self:getPhone())
                app.session.user:stopScheduler()
                self:freshBindBottom(nil,false)
            end
        elseif body.code == -1 then
            -- -1是失败
            if body.action and body.action == ACTION_GET_CODE then
                tools.showRemind("获取验证码失败!")
            elseif body.action == ACTION_COMMIT_CODE then
                tools.showRemind("验证码错误或已过期")
            end
        end
    end
end

function BindPhoneView:freshBindText(msg)
    local text = self.bindLayer:getChildByName('send'):getChildByName('text')
    local dt = msg.tick
    if dt < 60 then
        text:setString('   ' .. dt .. 's后\n重新获取')
        self.bindLayer:getChildByName('send'):setEnabled(false)
    else
        text:setString('  获取\n验证码')
        self.bindLayer:getChildByName('send'):setEnabled(not msg.flag)
    end
end

function BindPhoneView:freshBindBottom(phoneNum,enable)
    local sendBtn = self.bindLayer:getChildByName('send')
    local submitBtn = self.bindLayer:getChildByName('submit')
    sendBtn:setEnabled(enable)
    submitBtn:setEnabled(enable)

    if phoneNum then
        self.modifyPhoneEditBox:setText(phoneNum)
        self.modifyPhoneEditBox:setEnabled(enable)
        self.modifyCodeEditBox:setEnabled(enable)
    end
end

function BindPhoneView:startCsdAnimation(node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
        action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function BindPhoneView:stopAllAnimation()
    self.bindLayer:getChildByName("BindPhoneNode"):stopAllActions()
end

return BindPhoneView
