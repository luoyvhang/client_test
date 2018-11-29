local SoundMng = require('app.helpers.SoundMng')
local ShowWaiting = require('app.helpers.ShowWaiting')
local tools = require('app.helpers.tools')
local GameLogic = require('app.libs.niuniu.NNGameLogic')

local CreateRoomView = {}
local LocalSettings = require('app.models.LocalSettings')
local roomType = {
    ['szOption'] = 1, 
    -- ['gzOption'] = 2, 
    ['zqOption'] = 3, 
    ['mqOption'] = 4, 
    -- ['tbOption'] = 5, 
    -- ['fkOption'] = 6, 
    ['bmOption'] = 7,
    ['smOption'] = 8,
}
local typeOptions = {
    ['base'] = 1, 
    ['round'] = 2,
    ['roomPrice'] = 3, 
    ['multiply'] = 4, 
    ['special'] = 5, 
    ['advanced'] = 6, 
    ['qzMax'] = 7, 
    ['putmoney'] = 8,
    ['startMode'] = 9,
    ['wanglai'] = 10,
}
local tabs = {
    ['sz'] = 1, -- 牛牛上庄
    -- ['gz'] = 2, -- 固定上庄
    ['zq'] = 3, -- 自由抢庄
    ['mq'] = 4, -- 明牌抢庄
    -- ['tb'] = 5, -- 通比牛牛
    -- ['fk'] = 6, -- 疯狂加倍
    ['bm'] = 7, -- 八人明牌
    ['sm'] = 8, -- 十人明牌
}

local BASE = {
    [1] = '1/2',
    [2] = '2/4',
    [3] = '3/6',
    [4] = '4/8',
    [5] = '5/10',
}

local ROUND = {
    [1] = 15,
    [2] = 20,
    [3] = 30,
}

local QZ_ROUND = {
    [1] = 15,
    [2] = 20,
    [3] = 30,
}

local costList = {
    szOption1 = 4,
    szOption2 = 6,
    szOption3 = 9,

    gzOption1 = 4,
    gzOption2 = 6,
    gzOption3 = 9,

    zqOption1 = 4,
    zqOption2 = 6,
    zqOption3 = 9,
    
    mqOption1 = 4,
    mqOption2 = 6,
    mqOption3 = 9,

    tbOption1 = 4,
    tbOption2 = 6,
    tbOption3 = 9,

    fkOption1 = 4,
    fkOption2 = 6,
    fkOption3 = 9,

    bmOption1 = 5,
    bmOption2 = 8,
    bmOption3 = 12,

    smOption1 = 6,
    smOption2 = 10,
    smOption3 = 15,
}

local setVersion = 22

function CreateRoomView:initialize()
    self:enableNodeEvents()
    self.options = {}
    self.paymode = 1
    local setPath = cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomConfig'

    if io.exists(setPath) then
        local ver = LocalSettings:getRoomConfig('setVersion')
        if (not ver) or ver < setVersion then
            cc.FileUtils:getInstance():removeFile(setPath)
        end
    end

    print("getincreateroom")

    self.options['szOption'] = { msg = {
        ['gameplay'] = 1,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    self.options['gzOption'] = { msg = {
        ['gameplay'] = 2,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    self.options['zqOption'] = { msg = {
        ['gameplay'] = 3,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    self.options['mqOption'] = { msg = {
        ['gameplay'] = 4,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['qzMax'] = 1,
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    self.options['tbOption'] = { msg = {
        ['gameplay'] = 5,  ['base'] = 1,     ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    self.options['fkOption'] = { msg = {
        ['gameplay'] = 6,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['qzMax'] = 1,
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    self.options['bmOption'] = { msg = {
        ['gameplay'] = 7,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['qzMax'] = 1,
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    self.options['smOption'] = { msg = {
        ['gameplay'] = 8,  ['base'] = 1,   ['round'] = 1,
        ['roomPrice'] = 1, ['multiply'] = 1, ['special'] = { 1, 2, 3, 4, 5, 6, 7, 8},
        ['advanced'] = { 1, 0, 0, 0},
        ['qzMax'] = 1,
        ['putmoney'] = 1,
        ['startMode'] = 1,
        ['wanglai'] = 1,
    } }

    if not io.exists(cc.FileUtils:getInstance():getWritablePath() .. '.CreateRoomConfig')  then

        print(LocalSettings:getRoomConfig('szOptionbase'))

        for i,v in pairs(roomType) do
            for j,n in pairs(typeOptions) do
                LocalSettings:setRoomConfig(i..j, self.options[i]['msg'][j])
            end
        end

        LocalSettings:setRoomConfig('setVersion', setVersion)

    else
        print(" LocalSettings:getRoomConfig(v..n) is not == nil")
    end

    local MainPanel = self.ui:getChildByName('MainPanel')
    local bg = MainPanel:getChildByName('bg')
    self.bg = bg

    if LocalSettings:getRoomConfig("gameplay") then
        self.focus = LocalSettings:getRoomConfig("gameplay")
    else
        self.focus = 'sz'
    end

    for i,v in pairs(roomType) do 
        for j, n in pairs(typeOptions) do 
            local data =  LocalSettings:getRoomConfig(i..j)
            if data then 
                self.options[i]['msg'][j] = data
                local sender = nil
                if j == 'multiply' then 
                    sender =  bg:getChildByName(i):getChildByName(j):getChildByName('opt'):getChildByName(tostring(data))
                elseif j == 'special' or j == 'advanced' then
                    sender = nil 
                elseif j == 'base' or j == 'round' or j == 'startMode' or j == 'putmoney' then
                    sender = nil
                else
                    sender =   bg:getChildByName(i):getChildByName(j):getChildByName(tostring(data))
                end 
                local fun = 'fresh'..j
                if self[fun] then 
                    self[fun](self,data,sender)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomView:freshTab(data)
    for i, v in pairs(tabs) do 
        local currentItem = self.bg:getChildByName(i)
        local currentOpt = self.bg:getChildByName(i .. 'Option')
        if data then 
            self.focus = data
        end
        if self.focus == i then
            currentItem:getChildByName('active'):setVisible(true)
            currentOpt:setVisible(true)
        else
            currentItem:getChildByName('active'):setVisible(false)
            currentOpt:setVisible(false)
        end
    end
    -- if self.isgroup then 
    --     self.bg:getChildByName('tb'):setVisible(false)
    --     self.bg:getChildByName('gz'):setVisible(false)
    -- end
    LocalSettings:setRoomConfig("gameplay", self.focus)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--刷新左边模式是否已配
function CreateRoomView:freshHasSave(data)
    for i, v in pairs(tabs) do 
        local currentItem = self.bg:getChildByName(i)
        local hassaveImage = currentItem:getChildByName('Image')
        if data[v] == 1 then
            hassaveImage:setVisible(true)
        else
            hassaveImage:setVisible(false)
        end
    end
    -- LocalSettings:setRoomConfig("gameplay", self.focus)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
--各个模式的刷新界面逻辑
function CreateRoomView:freshbase(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('base')

    local current_value = self.options[option_type]['msg']['base']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 5 + 1
    end
    item:getChildByName('text'):setString(GameLogic.getBaseOrder(current_value))

    self.options[option_type]['msg']['base'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local info = {
        option =  option_type ,
        item = 'base' ,
        num = 5 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshround(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('round')

    local current_value = self.options[option_type]['msg']['round']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 3 + 1
    end
    item:getChildByName('text'):setString(ROUND[current_value] .. '局')

    self.options[option_type]['msg']['round'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)
    --根据局数更改房卡数值
    if self.paymode == 1 then
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[option_type..current_value]..')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      1)')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[option_type..current_value]..')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      2)')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('1'):getChildByName('Text'):setString('房主支付(      ' .. costList[option_type..current_value]..')')
            option:getChildByName('roomPrice'):getChildByName('2'):getChildByName('Text'):setString('AA支付(每人      3)')
        end
    elseif self.paymode == 2 then 
        if current_value == 1 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[option_type..current_value]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 2 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[option_type..current_value]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
        if current_value == 3 then
            option:getChildByName('roomPrice'):getChildByName('paymode'):getChildByName('Text1'):setString('（      ' .. costList[option_type..current_value]..'）俱乐部管理员已设置从俱乐部基金中扣除，无需你支付')
        end
    end

    local info = {
        option =  option_type ,
        item = 'round' ,
        num = 3 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshroomPrice(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('roomPrice')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('paymode'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['roomPrice'] = data
    LocalSettings:setRoomConfig(option_type..item:getName(), data)

    local info = {
        option =  option_type ,
        item = 'roomPrice' ,
        num = 2 ,
    }

    self:freshTextColor(info)
end

function CreateRoomView:freshmultiply(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('multiply')

    item:getChildByName('opt'):getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('opt'):getChildByName('2'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)
    item:getChildByName('sel'):getChildByName('Text'):setString(sender:getChildByName("Text"):getString())

    self.options[option_type]['msg']['multiply'] = tonumber(data)
    LocalSettings:setRoomConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  option_type ,
        item = 'multiply' ,
        num = 2 ,
    }

    self:freshTextColor(info)
end

function CreateRoomView:freshspecial(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('special')
    self.specialselect = 0

    for i = 1, 8 do
        item:getChildByName('opt'):getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end

    for i = 1, #data do
        if data[i] == i then
            item:getChildByName('opt'):getChildByName(tostring(i)):getChildByName('select'):setVisible(true)
            self.specialselect = self.specialselect + 1
        end
    end
    if self.specialselect == 8 then 
        item:getChildByName('sel'):getChildByName('Text'):setString("全部勾选")
    else
        item:getChildByName('sel'):getChildByName('Text'):setString("部分勾选")
    end

    self.options[option_type]['msg']['special'] = data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['special'])

    local info = {
        option =  option_type ,
        item = 'special' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshspecialnow(data,sender)
    local data = tonumber(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('special')
    local flag = sender:getChildByName('select'):isVisible()

    sender:getChildByName('select'):setVisible(not flag)

    local specialselect =  self.options[option_type]['msg']['special']
    local specialselectnum = 0

    for i, v in pairs(specialselect) do
        if v == i then
            specialselectnum = specialselectnum + 1
        end
    end

    if flag then
        specialselectnum = specialselectnum - 1
    else
        specialselectnum = specialselectnum + 1
    end

    if specialselectnum == 8 then 
        item:getChildByName('sel'):getChildByName('Text'):setString("全部勾选")
    else
        item:getChildByName('sel'):getChildByName('Text'):setString("部分勾选")
    end
    
    self.options[option_type]['msg']['special'][data] = flag and 0 or data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['special'])

    local info = {
        option =  option_type ,
        item = 'special' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshqzMax(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('qzMax')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)
    item:getChildByName('4'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['qzMax'] = tonumber(data)
    LocalSettings:setRoomConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  option_type ,
        item = 'qzMax' ,
        num = 4 ,
    }

    self:freshTextColor(info)
end

function CreateRoomView:freshstartMode(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('startMode')

    local current_value = self.options[option_type]['msg']['startMode']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 4 + 1
    end
    item:getChildByName('text'):setString(GameLogic.getStartModeOrder(current_value, self.focus))

    self.options[option_type]['msg']['startMode'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local info = {
        option =  option_type ,
        item = 'startMode' ,
        num = 4 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshputmoney(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('putmoney')

    local current_value = self.options[option_type]['msg']['putmoney']
    if sender then
        current_value = (current_value + (tonumber(data) == 0 and -1 or 1) - 1) % 4 + 1
    end
    item:getChildByName('text'):setString(GameLogic.getPutMoneyOrder(current_value))

    self.options[option_type]['msg']['putmoney'] = current_value
    LocalSettings:setRoomConfig(option_type..item:getName(), current_value)

    local info = {
        option =  option_type ,
        item = 'putmoney' ,
        num = 4 ,
    }

    -- self:freshTextColor(info)
end

function CreateRoomView:freshadvanced(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('advanced')

    for i = 1, 4 do
        item:getChildByName('' .. i):getChildByName('select'):setVisible(false)
    end

    -- if option_type == 'zqOption' or option_type == 'mqOption' or option_type == 'fkOption' or option_type == 'bmOption' or option_type == 'smOption' then
    --     item:getChildByName('4'):getChildByName('select'):setVisible(false)
    -- end

    -- if option_type == 'mqOption' or option_type == 'fkOption' or option_type == 'bmOption' or option_type == 'smOption' then
    --     item:getChildByName('5'):getChildByName('select'):setVisible(false)
    -- end

    for i = 1, #data do
        if data[i] == i then
            item:getChildByName(tostring(i)):getChildByName('select'):setVisible(true)
        end
    end

    self.options[option_type]['msg']['advanced'] = data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['advanced'])

    local info = {
        option =  option_type ,
        item = 'advanced' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshadvancednow(data,sender)
    local data = tonumber(data)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('advanced')
    local flag = sender:getChildByName('select'):isVisible()

    sender:getChildByName('select'):setVisible(not flag)
    
    self.options[option_type]['msg']['advanced'][data] = flag and 0 or data
    LocalSettings:setRoomConfig(option_type..item:getName(), self.options[option_type]['msg']['advanced'])

    local info = {
        option =  option_type ,
        item = 'advanced' ,
    }

    self:freshmulTextColor(info)
end

function CreateRoomView:freshwanglai(data,sender)
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName('wanglai')

    item:getChildByName('1'):getChildByName('select'):setVisible(false)
    item:getChildByName('2'):getChildByName('select'):setVisible(false)
    item:getChildByName('3'):getChildByName('select'):setVisible(false)
    sender:getChildByName('select'):setVisible(true)

    self.options[option_type]['msg']['wanglai'] = tonumber(data)
    LocalSettings:setRoomConfig(option_type..item:getName(), tonumber(data))

    local info = {
        option =  option_type ,
        item = 'wanglai' ,
        num = 3 ,
    }

    self:freshTextColor(info)
end

---------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--刷新字体颜色
function CreateRoomView:freshmulTextColor(data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName(data.item)
    if data.item == 'multiply' or data.item == 'special' then 
        item = item:getChildByName('opt')
    end
    local selectdata = self.options[data.option]['msg'][data.item]

    for i = 1, #selectdata do
        if selectdata[i] ~= 0 then
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,245,205))
        else
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,187,115))
        end
    end
end

function CreateRoomView:freshTextColor(data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type)
    local item = option:getChildByName(data.item)
    if data.item == 'multiply' or data.item == 'special' then 
        item = item:getChildByName('opt')
    end
    local selectdata = self.options[data.option]['msg'][data.item]
    
    for i = 1, data.num do
        if i == selectdata then
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,245,205))
        else
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,255,255))
            item:getChildByName(tostring(i)):getChildByName('Text'):setColor(cc.c3b(255,187,115))
        end
    end
end
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomView:freshPriceLayer(bShow) 
    self.bg:getChildByName('priceLayer'):setVisible(bShow)
end

function CreateRoomView:freshTuiZhuLayer(bShow) 
    self.bg:getChildByName('tuizhuLayer'):setVisible(bShow)
    if bShow then
        self.bg:getChildByName('tuizhuLayer'):getChildByName('qz'):setVisible(false)
        self.bg:getChildByName('tuizhuLayer'):getChildByName('sz'):setVisible(false)
        if (self.focus == 'bm' or self.focus == 'mq' or self.focus == 'sm') then
            self.bg:getChildByName('tuizhuLayer'):getChildByName('qz'):setVisible(true)
        else
            self.bg:getChildByName('tuizhuLayer'):getChildByName('sz'):setVisible(true)
        end
    end
end

function CreateRoomView:freshXiaZhuLayer(bShow) 
    self.bg:getChildByName('xiazhuLayer'):setVisible(bShow)
    if bShow then
        self.bg:getChildByName('xiazhuLayer'):getChildByName('qz'):setVisible(false)
        self.bg:getChildByName('xiazhuLayer'):getChildByName('sz'):setVisible(false)
        if (self.focus == 'bm' or self.focus == 'mq' or self.focus == 'sm') then
            self.bg:getChildByName('xiazhuLayer'):getChildByName('qz'):setVisible(true)
        else
            self.bg:getChildByName('xiazhuLayer'):getChildByName('sz'):setVisible(true)
        end
    end
end

function CreateRoomView:freshquickLayer(bShow) 
    self.bg:getChildByName('quickLayer'):setVisible(bShow)
end

function CreateRoomView:freshWangLaiLayer(bShow, data) 
    self.bg:getChildByName('wanglaiLayer'):setVisible(bShow)
    if bShow then
        if (self.focus == 'bm' or self.focus == 'mq') and data then
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):setVisible(true)
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):getChildByName('1'):setVisible(false)
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):getChildByName('2'):setVisible(false)
            self.bg:getChildByName('wanglaiLayer'):getChildByName('bm'):getChildByName(data):setVisible(true)
        end
    end
end

--两个模式的点击事件
function CreateRoomView:freshSpecialLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type) 
    option:getChildByName('special'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('special'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('Image'):loadTexture(path)
end

function CreateRoomView:freshMultiplyLayer(bShow,data) 
    local option_type = self.focus .. 'Option'
    local option = self.bg:getChildByName(option_type) 
    option:getChildByName('multiply'):getChildByName('opt'):setVisible(bShow)
    local path = 'res/views/createroom/' .. data.direction ..'.png'
    local bg = option:getChildByName('multiply'):getChildByName('sel'):getChildByName('bg')
    bg:getChildByName('Image'):loadTexture(path)
end
------------------------------------------------------------------------------------------

function CreateRoomView:freshgroupcreateroomview()
    local MainPanel = self.ui:getChildByName('MainPanel')
    local bg = MainPanel:getChildByName('bg')
    for i,v in pairs(roomType) do
        for j,n in pairs(typeOptions) do
            local view = bg:getChildByName(i)
            local opView = view:getChildByName(j)
            if(j == 'roomPrice') then
                opView:getChildByName('1'):getChildByName('select'):setVisible(false)
                opView:getChildByName('2'):getChildByName('select'):setVisible(false)
                opView:getChildByName('paymode'):setVisible(true)
                opView:getChildByName('1'):setVisible(false)
                opView:getChildByName('2'):setVisible(false)
                opView:getChildByName('dm1'):setVisible(false)
                opView:getChildByName('dm2'):setVisible(false)
                opView:getChildByName('why'):setVisible(false)
                local round = LocalSettings:getRoomConfig(i ..'round')
                self:freshround({['type'] = i, ['round'] = round},view:getChildByName('round'):getChildByName(tostring(round)))
            end
        end
    end
    self.isgroup = true
end

function CreateRoomView:layout(isGroup, createmode, paymode)
    local MainPanel = self.ui:getChildByName('MainPanel')
    MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = MainPanel

    local bg = MainPanel:getChildByName('bg')
    bg:setPosition(display.cx, display.cy)
    self.bg = bg
    self.isgroup = isGroup
    self.paymode = paymode
    if self.isgroup then --group
        if createmode == 1 then
            self.bg:getChildByName('confirm'):setVisible(false)
            self.bg:getChildByName('tips'):setVisible(false)
            self.bg:getChildByName('sureBtn'):setVisible(true)
        elseif createmode == 2 then
            self.bg:getChildByName('confirm'):setVisible(true)
            self.bg:getChildByName('tips'):setVisible(false)
            self.bg:getChildByName('sureBtn'):setVisible(false)
            self.bg:getChildByName('quickstart'):setVisible(true)
            self:startCsdAnimation(self.bg:getChildByName('quickstart'):getChildByName("PurpleNode"),"PurpleAnimation",true,0.8)
        end
        if paymode == 2 then 
            self:freshgroupcreateroomview()
        end
    else
        -- 正常创建
        self.bg:getChildByName('confirm'):setVisible(true)
        self.bg:getChildByName('tips'):setVisible(true)
        self.bg:getChildByName('sureBtn'):setVisible(false)    
    end
    
    if LocalSettings:getRoomConfig("gameplay") then
        self.focus = LocalSettings:getRoomConfig("gameplay")
    else
        self.focus = 'sz'
    end

    -- if self.isgroup then
    --     if self.focus == 'gz' or self.focus == 'tb' then
    --         self.focus = 'sz'
    --     end
    -- end
    self:freshTab()

    --启动csd动画
    self:startallAction()
end

function CreateRoomView:getOptions()
    SoundMng.playEft('room_dingding.mp3')
    local key = self.focus .. 'Option'
    local savedata = self.options[key].msg
    local msg = clone(savedata)
    if key == 'fkOption' then
        -- msg.putmoney = 1
        -- msg.qzMax = 1
    end

    if key == 'tbOption' then
        msg.gameplay = 4
        key = 'mqOption'
    end

    if key == 'tbOption' then
        msg.base = tostring(msg.base)
    else
        msg.base = BASE[msg.base]
    end

    if msg.gameplay == 4 or msg.gameplay == 6 or msg.gameplay == 7 or msg.gameplay == 8 then
        msg.round = QZ_ROUND[msg.round]
    else
        msg.round = ROUND[msg.round]
    end

    if self.isgroup and self.paymode == 2 then
        msg.roomPrice = 1
    end

    msg.enter = {}
    msg.robot = 1
    msg.enter.buyHorse = 0
    msg.enter.enterOnCreate = 1
    
    msg.maxPeople = 6
    if msg.gameplay == 7 then
        msg.maxPeople = 8
    elseif msg.gameplay == 8 then
        msg.maxPeople = 10
    end

    if key == 'zqOption' then
        msg.qzMax = 1
    end

    dump(msg)

    return msg
end

function CreateRoomView:showWaiting()
    local scheduler = cc.Director:getInstance():getScheduler()
    if not self.schedulerID then

        ShowWaiting.show()
        self.waitingView = true

        self.schedulerID = scheduler:scheduleScriptFunc(function()
            ShowWaiting.delete()
            self.waitingView = false

            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            self.schedulerID = nil
        end, 3, false)
    end
end

function CreateRoomView:delShowWaiting()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
        if self.waitingView then
            ShowWaiting.delete()
            self.waitingView = false
        end
    end
end

function CreateRoomView:onExit()
    self:delShowWaiting()
end

function CreateRoomView:startCsdAnimation( node, csbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/createroom/"..csbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
    action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

function CreateRoomView:startallAction()
    for i,v in pairs(tabs) do
        self:startCsdAnimation(self.bg:getChildByName(i):getChildByName("active"):getChildByName("blinkingBoxNode"),"blinkingBoxAnimation",true,1.3)
    end

    self:startCsdAnimation(self.bg:getChildByName("flashBoxNode"),"flashBoxAnimation",true,0.8)  
end

return CreateRoomView