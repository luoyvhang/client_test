local tools = require('app.helpers.tools')
local XYChatView = {}
local LocalSettings = require('app.models.LocalSettings')

function XYChatView:initialize()
end

local chatsTbl = {
    '别跟我抢庄，小心玩死你们！',
    '喂，赶紧亮牌，别墨迹！',
    '搏一搏，单车变摩托。',
    '快点儿啊，我等到花儿都谢了。',
    '时间就是金钱，我的朋友。',
    '不要因我是娇花怜惜我，使劲推注吧',
    '我是牛牛，我怕谁！',
    '大牛吃小牛，哈哈哈。',
    '下的多输的多，小心推注当内裤。',
    '有没有天理，有没有王法，这牌也输了？',
    '一点小钱，拿去喝茶吧。',
    '不好意思，全赢！',
    '真倒霉，全输。',
}

local emojiTbl = {
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
}

function XYChatView.getChatsTbl()
    return chatsTbl
end

function XYChatView:getEmojiTbl()
    return emojiTbl
end

function XYChatView:layout(desk)
    self.desk = desk
    local black = self.ui:getChildByName('black')
    black:setContentSize(cc.size(display.width,display.height))
    self.ui:setPosition(display.cx,display.cy)
    local MainPanel = self.ui:getChildByName('MainPanel')
    self.MainPanel = MainPanel

	local emojiList = self.MainPanel:getChildByName('emoji'):getChildByName('emojiList')
    self.emojiList = emojiList
	emojiList:setItemModel(emojiList:getItem(0))
	emojiList:removeAllItems()
	emojiList:setScrollBarEnabled(false)    
    emojiList:setVisible(false)
	
    local shortcut = self.MainPanel:getChildByName('shortcut')
    self.shortcut = shortcut
	local shortcutList = shortcut:getChildByName('shortcutList')
    self.shortcutList = shortcutList
	shortcutList:setItemModel(shortcutList:getItem(0))
	shortcutList:removeAllItems()
	shortcutList:setScrollBarEnabled(false)    
    shortcutList:setVisible(false)

	local chattingRecord = self.MainPanel:getChildByName('chattingRecord')
    local item1 = chattingRecord:getChildByName('item1')
    local item2 = chattingRecord:getChildByName('item2')   
    local item3 = chattingRecord:getChildByName('item3')   
    self.item1 = item1
    self.item2 = item2 
    self.item3 = item3
    item1:setVisible(false)    
    item2:setVisible(false) 
    item3:setVisible(false)
    local recordList = chattingRecord:getChildByName('recordList')
	self.recordList = recordList
	recordList:setItemModel(item1)
	recordList:removeAllItems()
    recordList:setScrollBarEnabled(false)
    
    local app = require("app.App"):instance()
    local userinfo = app.session.user

	local round = userinfo.win + userinfo.lose 
	self.level = math.floor(round/500)

	local chatEditBox = chattingRecord:getChildByName('Text_input')
    self.chatEditBox = tools.createEditBox(chatEditBox, {
		-- holder
		defaultString = '请输入发言',
		holderSize = 25,
		holderColor = cc.c3b(172,108,64),

		-- text
		fontColor = cc.c3b(172,108,64),
		size = 25,
        maxCout = 28,
		fontType = 'views/font/fangzheng.ttf',	
        inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
    })

    self.emotionList = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
    if io.exists(cc.FileUtils:getInstance():getWritablePath() .. '.ExpressConfig') then
        self.emotionList = LocalSettings:getExpressConfig('express')
        local num = 0
        for i, v in pairs(self.emotionList) do
            if v == 0 then
                num = num + 1
            end
        end
        if num == 12 then
            self.emotionList = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
        end
    end

    self:initShortcutList()
    self:initEmojiList()
    self:freshBtnState('shortcut')
    self:freshListState('shortcut')    
end

function XYChatView:initShortcutList()
	local function addRow(node, content, index)
        local item = node:getItem(index)
        item:getChildByName('content'):setString(content)
        item:getChildByName('touch'):addClickEventListener(function()
			self.emitter:emit('choosed', index+1)
    	end)
    end
	local shortcutList = self.shortcutList
    shortcutList:setVisible(true)    
	shortcutList:removeAllItems()
    local index = 0
	for i, v in pairs(chatsTbl) do
		shortcutList:pushBackDefaultItem()
        addRow(shortcutList, v, index)
        index = index + 1			
	end	
end

function XYChatView:freshBtnState(mode)
    local shortcutBtn = self.MainPanel:getChildByName('shortcutBtn'):getChildByName('active')
    local emojiBtn = self.MainPanel:getChildByName('emojiBtn'):getChildByName('active')
    local recordBtn = self.MainPanel:getChildByName('recordBtn'):getChildByName('active')
    local mode = mode or 'shortcut'
    if mode == 'shortcut' then
        shortcutBtn:setVisible(true)
        emojiBtn:setVisible(false)
        recordBtn:setVisible(false)
    elseif mode == 'emoji' then
        emojiBtn:setVisible(true)    
        shortcutBtn:setVisible(false)
        recordBtn:setVisible(false)
    elseif mode == 'record' then
        recordBtn:setVisible(true)
        emojiBtn:setVisible(false)    
        shortcutBtn:setVisible(false)
    end
end

function XYChatView:freshListState(mode)
    local chattingRecord = self.MainPanel:getChildByName('chattingRecord')
    local mode = mode or 'shortcut'
    if mode == 'shortcut' then
        self.shortcut:setVisible(true)
        self.emojiList:setVisible(false)
        chattingRecord:setVisible(false)
    elseif mode == 'emoji' then
        self.emojiList:setVisible(true)    
        self.shortcut:setVisible(false)
        chattingRecord:setVisible(false)
    elseif mode == 'record' then
        chattingRecord:setVisible(true)
        self.emojiList:setVisible(false)    
        self.shortcut:setVisible(false)
    end    
end

function XYChatView:freshRecordList(msg)
    if msg == nil then return end
    
    local avatarTab = {}
    if self.desk.tabPlayer then
        for uid, agent in pairs(self.desk.tabPlayer) do
            local actor = agent:getActor()
            local acatar = actor.avatar
            avatarTab[uid] = acatar
        end
    end

	local function addRow(content, idx, uid, mode, emojiIdx)  
        local size = nil
        if content then size = string.len(content) end    --42
        if mode == 'text' and size <= 42 then
            self.recordList:setItemModel(self.item1)
        elseif  mode == 'text' and size > 42 then 
            self.recordList:setItemModel(self.item2)
        elseif mode == 'emoji' and emojiIdx then
            self.recordList:setItemModel(self.item3)            
        end

        self.recordList:pushBackDefaultItem()
        local item = self.recordList:getItem(idx)    
        item:setVisible(true)
        if mode == 'text' then
            local contentNode = item:getChildByName('contentPanel')
                :getChildByName('img_content')
                :getChildByName('content')                       
            contentNode:setString(content)
        elseif mode == 'emoji' then
            local contentNode = item:getChildByName('contentPanel')
                :getChildByName('img_emoji')
            local path = 'views/xychat/'..emojiIdx..'.png'
            contentNode:loadTexture(path)
        end   
        self:freshHeadImg(item, avatarTab[uid])
    end

    local recordList = self.recordList  
    recordList:removeAllItems()  
    local idx = 0
    local mode = nil
    local content = nil
    local emojiIdx = nil
    for k, v in pairs(msg) do
        if v.type == 0 and v.msg then --快捷语
            content = chatsTbl[v.msg]
            mode = 'text'
        elseif v.type == 1 and v.msg then --表情
            emojiIdx = v.msg
            mode = 'emoji'
        elseif v.type == 2 and v.msg then --自定义文字
            content = v.msg
            mode = 'text'
        end        
       
        addRow(content, idx, v.uid, mode, emojiIdx) 
        idx = idx + 1
    end
    recordList:jumpToBottom()
end

function XYChatView:freshHeadImg(item, headUrl)
    local node = item:getChildByName('avatar')
    if headUrl == nil or headUrl == '' then return end
    local cache = require('app.helpers.cache')		 
	cache.get(headUrl, function(ok, path)
		if ok then
			node:show()
			node:loadTexture(path)
		else
			node:loadTexture('views/public/tx.png')
		end
	end)
end

function XYChatView:getChatEditBoxInfo() 
    local text = self.chatEditBox:getText()
    return text 	
end

function XYChatView:freshChatEditBox(content, enable)
    enable = enable or false
    self.chatEditBox:setText(content)
    self.chatEditBox:setEnabled(enable)
end

function XYChatView:initEmojiList()
    local emojiList = self.emojiList
    self.MainPanel:getChildByName('emoji'):setVisible(true)
    emojiList:removeAllItems()

    local line = #emojiTbl / 3
    if line == 0 then
        line = 1
    end

    for i = 1, line do
        emojiList:pushBackDefaultItem()
        local item = emojiList:getItem(i - 1)
        self:setBtnClickEvent(item, i - 1, 3)
    end
end

function XYChatView:setBtnClickEvent(item, line, col)
    for i = 1, col do
        local touch = item:getChildByName('touch_'..i)
        local id = self.emotionList[3 * line + i]
        if id == 0 then
            touch:setVisible(false) 
        end
        local flag = self:biaoqingRemind(id, false)
        local path = "views/xychat/"..id..".png"
        if not flag then 
            path = "views/xychat/"..id.."_1.png" 
        end
        touch:getChildByName('imoji_img'):loadTexture(path)

        touch:addClickEventListener(function()
            local flag = self:biaoqingRemind(id, true)
            if not flag then return end
            self.emitter:emit('back')
            local app = require("app.App"):instance()
            local tmsg = {
                msgID = 'chatInGame',
                type = 1,
                msg = id
            }
            app.conn:send(tmsg)
        end)
    end
end

function XYChatView:biaoqingRemind(idx, bool)
    local level = self.level
    if idx % 12 == 9 and level < 2 then 
        if bool then
            tools.showRemind('解锁该表情需要青铜牛牛等级')
        end
		return false
	end
			
    if idx % 12 == 10 and level < 3 then
        if bool then
            tools.showRemind('解锁该表情需要白银牛牛等级')
        end
		return false
	end
			
    if idx % 12 == 11 and level < 4 then
        if bool then
            tools.showRemind('解锁该表情需要黄金牛牛等级')
        end
		return false
    end
    
    if idx % 12 == 0 and level < 5 then
        if bool then
            tools.showRemind('解锁该表情需要铂金牛牛等级')
        end
		return false
	end
	return true
end

return XYChatView
