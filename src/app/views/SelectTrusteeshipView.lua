local GameLogic = require('app.libs.niuniu.NNGameLogic')
local cjson = require('cjson')

local SelectTrusteeshipView = {}
function SelectTrusteeshipView:initialize()
    self.bettingRunFlag = false
    self.iSeC = cc.c3b(239, 149, 57)
    self.iNoC = cc.c3b(116, 53, 12)
    self.SeC = cc.c3b(255, 245, 205)
    self.NoC = cc.c3b(255, 255, 255)
end

local Tabs = {
    'putmoney',
    'getbanker',
    'betting'
}

function SelectTrusteeshipView:layout(deskdata)
    local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = MainPanel

	local deskInfo = deskdata.tabBaseInfo.deskInfo
	local base = GameLogic.getBaseInfoText(deskInfo) or {1,2}
	local qzMax = GameLogic.getQzMaxInfoText(deskInfo) or {1,2,3,4}
	self.options = { 
		['deskInfoBase'] = base,  ['putmoneyBase'] = 1, ['putmoneyIn'] = 1, ['putmoneyflag'] = true,
		['getbankerBase'] = 1, ['getbankerInOption'] = qzMax, ['getbankerIn'] = 1, ['inSelected'] = 1,
		['bettingBase'] = 1, ['bettingIn'] = 1,
	}

    self:loadPutMoneyList()
	self:loadgetBankerList()
	self:loadBetting()
	self:freshText(base)
    self:freshTabNum(deskInfo)
end


function SelectTrusteeshipView:freshTab(data, sender)
    if data ~= Tabs[1] then
        self.MainPanel:getChildByName(data):getChildByName('1'):getChildByName('select'):setVisible(false)
        self.MainPanel:getChildByName(data):getChildByName('2'):getChildByName('select'):setVisible(false)
        self.MainPanel:getChildByName(data):getChildByName('3'):getChildByName('select'):setVisible(false)
        self:freshcolor(data, sender)
    else
        self.MainPanel:getChildByName(data):getChildByName('3'):getChildByName('select'):setVisible(false)
    end
	sender:getChildByName('select'):setVisible(true)

	local flag = self.MainPanel:getChildByName('putmoney'):getChildByName('3'):getChildByName('select'):isVisible()
	if flag then
		self.options['putmoneyflag'] = false
	else
		self.options['putmoneyflag'] = true
	end
	if data == Tabs[2] and sender:getName() == '1' and self.bettingRunFlag then 
		self:runbettingUpAction()
		self.bettingRunFlag = false
	end

    for i, v in ipairs(Tabs) do
        if v == data then
            self.options[data .. "Base"] = tonumber(sender:getName())
        end
    end

    --判断点击的对象的名称==3,显示intelligent
    if (sender:getName() == "3") then
        local intelligent = self.MainPanel:getChildByName(data):getChildByName('intelligent')
        local b_intelligent = self.MainPanel:getChildByName('betting'):getChildByName('intelligent')
        if data == Tabs[1] then
            self:hiddenPutMoneyList()

            if intelligent:isVisible() then
                intelligent:setVisible(false)
            else
                intelligent:setVisible(true)
            end
        elseif data == Tabs[2] then
            if not self.bettingRunFlag then
                self:runbettingDownAction()
				self.bettingRunFlag = true
				b_intelligent:setVisible(false)
            else
                self:runbettingUpAction()
                self.bettingRunFlag = false
            end
        elseif data == Tabs[3] then
            if not self.bettingRunFlag then
                if intelligent:isVisible() then
                    intelligent:setVisible(false)
                else
                    intelligent:setVisible(true)
                end
            else
                self:runbettingUpAction()
				self.bettingRunFlag = false
				intelligent:setVisible(true)
            end
        end

        self:freshIntelligent(data, nil)
    else
        self.MainPanel:getChildByName(data):getChildByName('intelligent'):setVisible(false)
    end

end

function SelectTrusteeshipView:freshText(base)
	local maxBase = base[#base]
	local str = '以上押' .. maxBase .. '分'
	local intelligent = self.MainPanel:getChildByName('putmoney'):getChildByName('intelligent')
	intelligent:getChildByName('1'):getChildByName('text'):setString('牛八' .. str)
	intelligent:getChildByName('2'):getChildByName('text'):setString('牛九' .. str)
	intelligent:getChildByName('3'):getChildByName('text'):setString('牛牛' .. str)
end

function SelectTrusteeshipView:freshIntelligent(data, sender)
    local intelligent = self.MainPanel:getChildByName(data):getChildByName('intelligent')
    intelligent:getChildByName('1'):getChildByName('select'):setVisible(false)
    intelligent:getChildByName('2'):getChildByName('select'):setVisible(false)
    intelligent:getChildByName('3'):getChildByName('select'):setVisible(false)

    if sender then
        sender:getChildByName('select'):setVisible(true)
        --设置文本
        self.MainPanel:getChildByName(data):getChildByName('3'):getChildByName('text'):setString(sender:getChildByName('text'):getString())
        self:freshcolor(data, sender, intelligent)
        for i, v in ipairs(Tabs) do
            if v == data then
                self.options[data .. "In"] = tonumber(sender:getName())
            end
        end
    end

    if data == Tabs[1] then
        self:hiddenPutMoneyList()
    end
    local value = self:getOptionsIntelligentValue(data)
    intelligent:getChildByName(value):getChildByName('select'):setVisible(true)
    self:freshcolor(data, intelligent:getChildByName(value), intelligent)
end

function SelectTrusteeshipView:freshcolor(data, sender, intelligent)
    if intelligent then
        intelligent:getChildByName('1'):getChildByName('text'):setColor(self.iNoC)
        intelligent:getChildByName('2'):getChildByName('text'):setColor(self.iNoC)
        intelligent:getChildByName('3'):getChildByName('text'):setColor(self.iNoC)
        sender:getChildByName('text'):setColor(self.iSeC)
    else
        self.MainPanel:getChildByName(data):getChildByName('1'):getChildByName('text'):setColor(self.NoC)
        self.MainPanel:getChildByName(data):getChildByName('2'):getChildByName('text'):setColor(self.NoC)
        self.MainPanel:getChildByName(data):getChildByName('3'):getChildByName('text'):setColor(self.NoC)
        sender:getChildByName('text'):setColor(self.SeC)
    end
end


--返回指定fatherName的intelligent 在self.options 的值
function SelectTrusteeshipView:getOptionsIntelligentValue(fatherName)
    local value = nil
    for i, v in ipairs(Tabs) do
        if fatherName == v then
            value = self.options[fatherName .. "In"]
        end
    end
    return value
end

function SelectTrusteeshipView:freshTabNum(deskInfo)
    if deskInfo.gameplay == 1 then 
        self.MainPanel:getChildByName(Tabs[2]):setVisible(false)
    end
end

function SelectTrusteeshipView:getOptions()
    return self.options
end

function SelectTrusteeshipView:setOptions(option)
	self.options = option
	self:loadPutMoneyList()
	self:loadgetBankerList()
	self:loadBetting()
end

function SelectTrusteeshipView:freshHelpView(data)
    local helpView = self.MainPanel:getChildByName('helpView')
    if helpView:isVisible() then
        helpView:setVisible(false)
    else
        helpView:setVisible(true)
        local tips  = helpView:getChildByName('tips')
        tips:loadTexture('views/nysdesk/selecttrusteeship/' .. data .. '.png')
    end
end

function SelectTrusteeshipView:setVisibleAndColor(item, bool, color)
    item:getChildByName("select"):setVisible(bool)
    item:getChildByName('text'):setColor(color)
end

function SelectTrusteeshipView:hiddenPutMoneyList()
    self.options['putmoneyBase'] = 3
    for i, v in ipairs(self.putMoneyList:getItems()) do
        self:setVisibleAndColor(v, false, self.NoC)
    end
end


function SelectTrusteeshipView:loadPutMoneyList()
    self.putMoneyList = self.MainPanel:getChildByName('putmoney'):getChildByName('list')
    self.putMoneyList:setItemModel(self.putMoneyList:getItem(0))
    self.putMoneyList:removeAllItems()
    self.putMoneyList:setScrollBarEnabled(false)

    local deskInfoBase = self.options["deskInfoBase"]
    if #deskInfoBase >= 4 then
        self.putMoneyList:setItemsMargin(180 / (#deskInfoBase))
    else
        self.putMoneyList:setItemsMargin(300 / (#deskInfoBase))
    end
    for i, v in ipairs(deskInfoBase) do
        self.putMoneyList:pushBackDefaultItem()
        local item = self.putMoneyList:getItem(i - 1)
        item:setName(i)
        local text = item:getChildByName('text')
        text:setString(v .. "分")
        self:setVisibleAndColor(item, false, self.NoC)
		if self.options['putmoneyBase'] == i then
			self:setVisibleAndColor(item, true, self.SeC)
		end
		if self.options['putmoneyBase'] == 3 and not self.options['putmoneyflag'] then
			self:setVisibleAndColor(item, false, self.SeC)
			self.MainPanel:getChildByName('putmoney'):getChildByName('3'):getChildByName('select'):setVisible(true)
		end
        item:addClickEventListener(function()
            local intelligent = self.MainPanel:getChildByName('putmoney'):getChildByName('intelligent')
            self.MainPanel:getChildByName('putmoney'):getChildByName('3'):getChildByName('select'):setVisible(false)
            if intelligent:isVisible() then
                intelligent:setVisible(false)
            end
            for i, v in ipairs(self.putMoneyList:getItems()) do
                self:setVisibleAndColor(v, false, self.NoC)
            end
            self:setVisibleAndColor(item, true, self.SeC)
            self.options['putmoneyflag'] = true
            self.options["putmoneyBase"] = tonumber(item:getName())
        end)
    end
end

function SelectTrusteeshipView:loadgetBankerList()
    self.getBankerList = self.MainPanel:getChildByName('getbanker'):getChildByName('intelligent'):getChildByName('list')
    self.getBankerList:setItemModel(self.getBankerList:getItem(0))
    self.getBankerList:removeAllItems()
    self.getBankerList:setScrollBarEnabled(false)

    local getbankerInOption = self.options["getbankerInOption"]
    for i, v in ipairs(getbankerInOption) do
        self.getBankerList:pushBackDefaultItem()
        local item = self.getBankerList:getItem(i - 1)
        item:setName(i)
        local text = item:getChildByName('text')
        text:setString(v .. "倍")
        self:setVisibleAndColor(item, false, self.iNoC)
        if self.options['inSelected'] == i then
            self:setVisibleAndColor(item, true, self.iSeC)
		end
		self.MainPanel:getChildByName('getbanker'):getChildByName('1'):getChildByName('select'):setVisible(false)
		self.MainPanel:getChildByName('getbanker'):getChildByName('2'):getChildByName('select'):setVisible(false)
		self.MainPanel:getChildByName('getbanker'):getChildByName('3'):getChildByName('select'):setVisible(false)
		self.MainPanel:getChildByName('getbanker'):getChildByName(tostring(self.options.getbankerBase)):getChildByName('select'):setVisible(true)
        item:addClickEventListener(function()
            for i, v in ipairs(self.getBankerList:getItems()) do
                self:setVisibleAndColor(v, false, self.iNoC)
            end
            self:setVisibleAndColor(item, true, self.iSeC)
            self.options["inSelected"] = tonumber(item:getName())
        end)
    end
end

function SelectTrusteeshipView:loadBetting()
	local betting = self.MainPanel:getChildByName('betting')
	local intelligent = betting:getChildByName('intelligent')
	for i = 1, 3 do
		betting:getChildByName(tostring(i)):getChildByName('select'):setVisible(false)
		intelligent:getChildByName(tostring(i)):getChildByName('select'):setVisible(false)
	end
	
	betting:getChildByName(tostring(self.options['bettingBase'])):getChildByName('select'):setVisible(true)
	intelligent:getChildByName(tostring(self.options['bettingIn'])):getChildByName('select'):setVisible(true)
end

function SelectTrusteeshipView:runbettingDownAction()
    local betting = self.MainPanel:getChildByName('betting')
    local moveTime = 0.2
    local moveDistanceX = 0
    local moveDistanceY = 50
    --下移
    local show = cc.CallFunc:create(function()
        self.MainPanel:getChildByName(Tabs[2]):getChildByName('intelligent'):setVisible(true)
    end)
    local sequence = cc.Sequence:create(cc.MoveBy:create(moveTime, cc.p(moveDistanceX, -moveDistanceY)), show)
    betting:runAction(sequence)
end

function SelectTrusteeshipView:runbettingUpAction()
    self.MainPanel:getChildByName(Tabs[2]):getChildByName('intelligent'):setVisible(false)
    local betting = self.MainPanel:getChildByName('betting')
    local moveTime = 0.2
    local moveDistanceX = 0
    local moveDistanceY = 50
    local show = cc.CallFunc:create(function()
        --self.MainPanel:getChildByName(Tabs[3]):getChildByName('intelligent'):setVisible(true)
    end)
    local sequence = cc.Sequence:create(cc.MoveBy:create(moveTime, cc.p(moveDistanceX, moveDistanceY)), show)
    betting:runAction(sequence)
end

return SelectTrusteeshipView