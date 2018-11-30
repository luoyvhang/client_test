local tools = require('app.helpers.tools')
local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"
local cjson = require('cjson')
local ShowWaiting = require('app.helpers.ShowWaiting')

local H5ShopView = {}

local ACTION_GET_CODE    = 1
local ACTION_COMMIT_CODE = 2

function H5ShopView:initialize()
	
end

function H5ShopView:layout(data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.data = data
    self.shopRight = self.data.shopRight or 0 
    self.phoneNum = self.data.phoneNum or app.session.user:getMyPhoneNum()
    self.MainPanel = MainPanel
    self.shopLayer = self.MainPanel:getChildByName('shopLayer')
    -- self:freshBindLayer(true)

    self.selectIdx = 1 --选择位置
    self.payChannel = 1 --支付渠道:2支付宝;1微信
    local content = self.shopLayer:getChildByName('Content')
    self.content = content

    self.orderIdLayer = self.shopLayer:getChildByName('orderIdLayer')
    self:freshOrderIdLayer(false)
    self.orderIdLayer:addClickEventListener(function()
        self:freshOrderIdLayer(false)
    end)
    self.recordLayer = self.shopLayer:getChildByName('record')
    self.shopItemLayer = self.shopLayer:getChildByName('shop')
    self:freshLayer('shop')

    content:getChildByName('touch1'):addClickEventListener(function()			
        -- self.emitter:emit('onTouch', 'touch1')
        self:freshLayer('shop')
    end)

    content:getChildByName('touch2'):addClickEventListener(function()			
        -- self.emitter:emit('onTouch', 'touch2')
        self:freshLayer('record')
    end)

    -- 商店列表
    local exchangeList = self.shopItemLayer:getChildByName('exchangeList')
	self.exchangeList = exchangeList
	exchangeList:setItemModel(exchangeList:getItem(0))
	exchangeList:removeAllItems()
	exchangeList:setScrollBarEnabled(false)

    self:freshExchangeList()

    -- 充值记录列表
    local exchangeRecordList = self.recordLayer:getChildByName('exchangeRecordList')
	self.exchangeRecordList = exchangeRecordList
	exchangeRecordList:setItemModel(exchangeRecordList:getItem(0))
	exchangeRecordList:removeAllItems()
    exchangeRecordList:setScrollBarEnabled(false)
    

    local closeBtn = content:getChildByName('close')

    local bg = content:getChildByName('bg')

    local type = 1 --微信支付
    local playerId = app.session.user.playerId
    self.webLayer = self.shopLayer:getChildByName('webLayer')
    self.baseUrl = string.format("http://nnstart.qiaozishan.com/wxpay/test.php?playerId=%s&payType=1&num=%s&shopRight=%s&hasPhoneNum=%s", playerId, "%s", self.shopRight,"%s")

    self.resultView = content:getChildByName("result")
    self.resultView:setVisible(false)

end

function H5ShopView:freshExchangeRecordList(msg)
    if not msg.records then return end
    local exchangeRecordList = self.exchangeRecordList
    exchangeRecordList:removeAllItems()
    local orderIdLayerPosx = 3
    local orderIdLayerPosy = 490
    for i,v in pairs(msg.records) do
        self.exchangeRecordList:pushBackDefaultItem()
        local item = exchangeRecordList:getItem(i - 1)
        item:getChildByName('textLayer'):getChildByName('orderId'):setString(v.orderId)
        item:getChildByName('textLayer'):addClickEventListener(function()
            self:freshOrderIdLayer(true)
            self.orderIdLayer:getChildByName('layer'):setPosition(orderIdLayerPosx,orderIdLayerPosy - (i - 1) * 50)
            self.orderIdLayer:getChildByName('layer'):getChildByName('orderId'):setString(v.orderId)
        end)
        item:getChildByName('chargenum'):setString(v.diamond)
        item:getChildByName('money'):setString(v.money)
        item:getChildByName('state'):setString('已到账')
        local time = os.date("%Y/%m/%d %H:%M:%S", v.time)
        item:getChildByName('time'):setString(time)
    end
end

function H5ShopView:freshExchangeList()
    local givePath = 'views/shop/give/'
    local diamondPath = 'views/shop/diamond/'
    local jiagePath = 'views/shop/jiage/'
    local buttonPath = 'views/shop/button/'
    local countList = {'x18', 'x30', 'x68', 'x128', 'x328', 'x698'}
    local costList = {'18元', '30元', '68元', '128元', '328元', '698元'}
    local giveList = {'3', '6', '14', '28', '72', '154'}

    local newcountList = {'x50', 'x30', 'x68', 'x128', 'x328', 'x698'}
    local newcostList = {'50元', '100元', '500元', '1000元', '2000元', '3000元'}
    local newgiveList = {'30', '80', '750', '2000', '5000', '9000'}

	local exchangeList = self.exchangeList
	exchangeList:removeAllItems()
    local index = 0
	for k = 1, 6 do
		self.exchangeList:pushBackDefaultItem()
		local item = exchangeList:getItem(index)

        --item:getChildByName('give_img'):loadTexture(givePath..k..'.png')
        --item:getChildByName('diamond_img'):loadTexture(diamondPath..k..'.png')

        local node =  cc.CSLoader:createNode("views/shop/starAnimation"..k..".csb")
        item:addChild(node)
        node:setPosition(item:getChildByName('diamond_img'):getPosition())
        self:startCsdAnimation(node,"starAnimation"..k, true)

        item:getChildByName('jiage'):loadTexture(self.shopRight == 0 and jiagePath..k..'.png' or jiagePath.. (k) ..'.png')
        item:getChildByName('button'):loadTexture(self.shopRight == 0 and buttonPath..k..'.png' or buttonPath.. (k) ..'.png')
        -- if device.platform == 'ios' or device.platform == 'windows' then
        --     item:getChildByName('jiage'):loadTexture(jiagePath..(k + 6)..'.png')
        --     item:getChildByName('button'):loadTexture(buttonPath..(k + 6)..'.png')
        -- end
        -- item:getChildByName('count'):setString(countList[k])
        -- item:getChildByName('cost'):setString(costList[k])
        item:getChildByName('give_number'):setString(self.shopRight == 0 and giveList[k] or giveList[k])

        local idx = k
        item:getChildByName('touch'):addClickEventListener(function()	
            local phoneNum = self.phoneNum or app.session.user:getMyPhoneNum()
            local hasPhoneNum = phoneNum == nil and 0 or 1	
            local link = string.format(self.baseUrl, idx, hasPhoneNum)	
            self:freshPayWebView(true, link)
        end)

		index = index + 1	
	end
end

function H5ShopView:freshLayer(mode)
    if mode == 'shop' then
        self.shopItemLayer:setVisible(true)
        self.recordLayer:setVisible(false)
        self.content:getChildByName('title1_1'):setVisible(true)
        self.content:getChildByName('title2_1'):setVisible(false)
    elseif mode == 'record' then
        self.shopItemLayer:setVisible(false)
        self.recordLayer:setVisible(true)
        self.content:getChildByName('title1_1'):setVisible(false)
        self.content:getChildByName('title2_1'):setVisible(true)
    end
end

function H5ShopView:freshOrderIdLayer(bool)
    self.orderIdLayer:setVisible(bool)
end

-- 切换标题相关
--[[ function H5ShopView:freshTitleAndContent(mode)
    self:freshSelectTitle1()
    if mode == 'touch1' then
        self:freshSelectTitle1()
    elseif mode == 'touch2' then   
        self:freshSelectTitle2()
    end
end

function H5ShopView:freshSelectTitle1()
    self.content:getChildByName('title1_1'):setVisible(true)
    self.content:getChildByName('Image_1'):setVisible(true) 
    self.content:getChildByName('exchangeList'):setVisible(true)        
    self.content:getChildByName('title2_1'):setVisible(false)
    self.content:getChildByName('Image_2'):setVisible(false) 
    self.content:getChildByName('exchangeRecordList'):setVisible(false) 
end

function H5ShopView:freshSelectTitle2()
    self.content:getChildByName('title1_1'):setVisible(false)
    self.content:getChildByName('Image_1'):setVisible(false)  
    self.content:getChildByName('exchangeList'):setVisible(false) 
    self.content:getChildByName('title2_1'):setVisible(true)
    self.content:getChildByName('Image_2'):setVisible(true) 
    self.content:getChildByName('exchangeRecordList'):setVisible(true) 
end ]]


function H5ShopView:onClickWebLayer()
    self:freshPayWebView(false)
end

function H5ShopView:changePayChannel(type)
    self.payChannel = type
end

function H5ShopView:freshPayChannelView(bShow)
    self.shopLayer:getChildByName('Content'):getChildByName('payChannel'):setVisible(bShow)
end

function H5ShopView:freshPayWebView(bShow, link)
    if not bShow then
        local sizePanel = self.webLayer:getChildByName('Panel2')
        if self.webView then
            -- self.webView:setPosition(sizePanel:getPosition())
            self:stopLoading()
            self.webView:removeFromParent()
            self.webView = nil
        end
        self.webLayer:setVisible(false)
        return
    end

    ShowWaiting.show()
    local scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler:scheduleScriptFunc(function()
		ShowWaiting.delete()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
    end, 3, false)
    
    if self.webView then
        self:stopLoading()
        self.webView:removeFromParent()
        self.webView = nil
    end
    local sizePanel = self.webLayer:getChildByName('Panel2')

    self.webView = ccexp.WebView:create()
    self.webView:setPosition(sizePanel:getPosition())
    self.webView:setContentSize(sizePanel:getContentSize())
    self.webView:setScalesPageToFit(true)
    self.webLayer:addChild(self.webView)

    self.webView:loadURL(link)
    self.webLayer:setVisible(true)

end

function H5ShopView:hideResultView()
    self.resultView:setVisible(false)
end

function H5ShopView:freshResultInfo(result)
    if not result then return end
    local diamond = self.resultView:getChildByName("diamond")
    local reward = self.resultView:getChildByName("reward")
    diamond:setString(string.format("%s", result.diamond))
    local song = (result.invite == -1) and "--" or result.song
    reward:setString(string.format("%s", song))
    self.resultView:setVisible(true)
end

function H5ShopView:stopLoading()
    if device.platform == 'ios' or device.platform == 'android' then
        if self.webView then
            self.webView:stopLoading()
        end
    end
end

function H5ShopView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/shop/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
      action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

return H5ShopView
