local tools = require('app.helpers.tools')
local app = require("app.App"):instance()
local SoundMng = require "app.helpers.SoundMng"
local ShowWaiting = require('app.helpers.ShowWaiting')

local TaskView = {}

function TaskView:initialize()
	
end

function TaskView:layout(data)
    local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width, display.height))
    MainPanel:setPosition(display.cx, display.cy)
    self.MainPanel = MainPanel

    self.data = data
	self.user = data[1]
    self.type = data[2]
    
    self.ZhuanPanLayer = MainPanel:getChildByName('ZhuanPanLayer')
    self.SignLayer = MainPanel:getChildByName('SignLayer')

    local weekList = self.SignLayer:getChildByName('weekList')
    weekList:setItemModel(weekList:getItem(0))
	weekList:removeAllItems()
    weekList:setScrollBarEnabled(false)

    self.menologyList = self.SignLayer:getChildByName('menologyList')
    self.menologyList:setItemModel(weekList)
	self.menologyList:removeAllItems()
    self.menologyList:setScrollBarEnabled(false)
    
    self:startCsdAnimation(self.SignLayer:getChildByName('RoleAnimation'), "RoleAnimationNode", true, 2/3)

    self:setLayer(self.type)
    
end

function TaskView:setLayer(type)
    if type == 'ZhuanPan' then
        self.ZhuanPanLayer:setVisible(true)
        self.SignLayer:setVisible(false)
    elseif type == 'Sign' then
        self.ZhuanPanLayer:setVisible(false)
        self.SignLayer:setVisible(true)
    end
end

function TaskView:getMenology()
    local date = os.date("*t", os.time())
    -- 获取到的今天的日期
    local today_month = date.month
    local today_year = date.year
    local today_day = date.day
    local today_wday = date.wday  -- 注意：星期天是1 星期六是7

    local last_month = (today_month - 1) == 0 and 12 or (today_month - 1)  -- 上一个月是几月

    local first_month_wday = 1      -- 这个月的1号是星期几
    local first_sunday_day = 1      -- 这个月的第一个星期日是几号
    local last_month_days = 0     -- 上个月有多少天

    if today_day ~= 1 then
        -- 这个月的1号是星期几
        first_month_wday = (today_wday - today_day % 7) % 7 + 1
    end

    if first_month_wday ~= 1 then
        -- 算出这个月的第一个星期日是几号和上个月有多少天
        if last_month == 1 or last_month == 3 or last_month == 5 or last_month == 7 
        or last_month == 8 or last_month == 10 or last_month == 12 then

            first_sunday_day = 33 - first_month_wday
            last_month_days = 31
        elseif last_month == 2 then
            if today_year % 4 == 0 then
                first_sunday_day = 31 - first_month_wday
                last_month_days = 29
            else
                first_sunday_day = 30 - first_month_wday
                last_month_days = 28
            end
        else
            first_sunday_day = 32 - first_month_wday
            last_month_days = 30
        end
    end

    local final_sunday_day = 30      -- 这个月的最后一天是几号
    local today_month_days = 30     -- 这个月有多少天

    -- 算出这个月的最后一天是几号和这个月有多少天
    if today_month == 1 or today_month == 3 or today_month == 5 or today_month == 7 
    or today_month == 8 or today_month == 10 or today_month == 12 then

        final_sunday_day = 12 - first_month_wday
        today_month_days = 31
    elseif today_month == 2 then
        if today_year % 4 == 0 then
            final_sunday_day = 14 - first_month_wday
            today_month_days = 29
        else
            final_sunday_day = 15 - first_month_wday
            today_month_days = 28
        end
    else
        final_sunday_day = 13 - first_month_wday
        today_month_days = 30
    end

    local menology = {}

    for i = 0, 41 do
        local everyday = first_sunday_day + i - last_month_days
        menology[i + 1] = {}
        if i <= 6 then
            menology[i + 1].date = (first_sunday_day + i) > last_month_days and everyday or (first_sunday_day + i)
            menology[i + 1].thisMonth = (first_sunday_day + i) > last_month_days and true or false
        elseif i > 6 and i <= 27 then
            menology[i + 1].date = everyday
            menology[i + 1].thisMonth = true
        elseif i > 27 then
            menology[i + 1].date = everyday > today_month_days and (everyday - today_month_days) or everyday
            if everyday > today_month_days then
                menology[i + 1].thisMonth = false
            else
                menology[i + 1].thisMonth = true
            end
        end
    end

    local msg = {
        menology = menology,
        date = date,
    }

    return  msg
end

function TaskView:freshWeekList(MenologyList, msg, row)
    local function setColor(node, thisMonth, isSign, isthrough)
        -- node: 节点
        -- thisMonth: 是否这个月
        -- isSign: 是否签到
        -- isthrough: 是否已经过了这天
        local color = cc.c3b(255,255,255)  -- 默认白色
        if not thisMonth then 
            color = cc.c3b(127,127,127)    -- 灰色
        else
            if not isSign then
                if isthrough then
                    color = cc.c3b(233,163,255)   -- 浅紫色
                else
                    color = cc.c3b(239,218,159)    -- 金色
                end
            end
        end
        node:setColor(color)
    end

    local weekList = MenologyList
    weekList:removeAllItems()

    local menology = msg.menology
    local date = msg.date
    local record = msg.records
    local text = '' .. date.year .. date.month
    local cnt = 0
    for i, v in pairs(menology) do
        if cnt > 6 then return end
        weekList:pushBackDefaultItem()
        local item = weekList:getItem(i - 1)
        local today = menology[i + (row - 1) * 7].date 
        local flag = menology[i + (row - 1) * 7].thisMonth 
        cnt = cnt + 1
        item:getChildByName('date'):setString(tostring(today))
        item:getChildByName('kuang1'):setVisible(not flag)
        item:getChildByName('kuang2'):setVisible(flag)
        item:getChildByName('today'):setVisible(false)
        
        local isSign = false
        if record and record[text] and next(record[text]) ~= nil then
            for i, v in pairs(record[text]) do
                if i == tostring(today) and flag and v then
                    isSign = true
                end
            end
        end
        
        if flag and date.day == today then
            item:getChildByName('today'):setVisible(true)
            self:freshSignInBtn(not isSign)
        end

        item:getChildByName('sign'):setVisible(isSign)

        setColor(item:getChildByName('date'), flag, isSign, date.day > today)
    end
end

function TaskView:freshMenologyList(msg)
    local menologyList = self.menologyList
    menologyList:removeAllItems()

    for i = 1, 6 do
        menologyList:pushBackDefaultItem()
        local item = menologyList:getItem(i - 1)
        self:freshWeekList(item, msg, i)
    end

    self.SignLayer:getChildByName('date'):setString('' .. msg.date.year .. '年' .. msg.date.month .. '月')
end

function TaskView:freshInfo(msg)

    self:freshSignInBtn(true)
    local menologymsg = self:getMenology()
    msg.menology = menologymsg.menology
    msg.date = menologymsg.date
    self:freshMenologyList(msg)

    local date = msg.date
    local record = msg.records
    local text = '' .. date.year .. date.month
    local cnt = 0
    if record and record[text] and next(record[text]) ~= nil then
        for i, v in pairs(record[text]) do
            if v then
                cnt = cnt + 1
            end
        end
    end 

    self.SignLayer:getChildByName('signCnt'):setString(tostring(cnt))
end

function TaskView:freshSignInBtn(bool)
    self.SignLayer:getChildByName('qiandao'):setEnabled(bool)
end

function TaskView:startCsdAnimation(node, dircsbName, isRepeat, timeSpeed)
    local action = cc.CSLoader:createTimeline("views/task/"..dircsbName..".csb")
    action:gotoFrameAndPlay(0,isRepeat)
    if timeSpeed then
      action:setTimeSpeed(timeSpeed)
    end
    node:stopAllActions()
    node:runAction(action)
end

return TaskView
