local tools = require('app.helpers.tools')
local app = require("app.App"):instance()

local SpreadView = {}
function SpreadView:initialize()
end

function SpreadView:layout()
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width, display.height))
	MainPanel:setPosition(display.cx, display.cy)
	self.MainPanel = MainPanel
    local content = self.MainPanel:getChildByName('Content')
    local bind = content:getChildByName('bind')
    bind:setPressedActionEnabled(true)
    self.bindBtn = bind

    self.tip1 = content:getChildByName('tip1')
    self.tip2 = content:getChildByName('tip2')
    self.reward = content:getChildByName('reward')

    -- 编辑框
    local editHanlder = function(event,editbox)
        -- self:onEditEvent(event,editbox)
    end

    local editBoxOrg = content:getChildByName('editBox')
    self.editbox = tools.createEditBox(editBoxOrg,{
        -- holder
		defaultString = '请输入推荐码',
        holderSize = 35,
        holderfontType = 'views/font/Fangzheng.ttf',
		holderColor = cc.c3b(233,163,255),

		-- text
		fontColor = cc.c3b(150,134,243),
        size = 35,
        maxCout = 6,
		fontType = 'views/font/Fangzheng.ttf',	
		inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
    },
    'views/shop/empty.png')

    --启动动画
    self:startCsdAnimation(content:getChildByName('lightBeamNode'),"contactus/lightBeamAnimation",true)
    self:startCsdAnimation(content:getChildByName('klNNNode'),"spread/klNNAnimation",true)

end

function SpreadView:freshTips(mode)
    self.tip1:setVisible(false)
    self.tip2:setVisible(false)
    self.reward:setVisible(false)
    if mode == 1 then
        self.tip1:setVisible(true)
        self.reward:setVisible(true)
    elseif mode == 2 then
        self.tip2:setVisible(true)
    end
end

function SpreadView:freshEditBox(content, enable)
    enable = enable or false
    self.editbox:setText(content)
    self.editbox:setEnabled(enable)
end

function SpreadView:freshBindBtn(enable, visible)
    enable = enable or false
    self.bindBtn:setEnabled(enable)
    if visible ~= nil then
        self.bindBtn:setVisible(visible)
    end
end

function SpreadView:getEditBoxInfo()
    local text = self.editbox:getText()
    local num = tonumber(text)
    return num 
end

function SpreadView:onRespondBind(msg)
    if nil == msg then return end
    if msg.success then
        self:freshEditBox(tostring(msg.invite, false))
        tools.showRemind("绑定成功")
        return
    end
    if not msg.success then
        tools.showRemind(msg.errorCode)
        return
    end
end

function SpreadView:startCsdAnimation( node, dircsbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/"..dircsbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
      action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end



return SpreadView
