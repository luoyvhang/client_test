local tools = require('app.helpers.tools')
local PersonalPageView = {}

function PersonalPageView:initialize()
end

local itemlist = {1, 2, 3, 4, 5, 6, 7, 8, 12, 15}

function PersonalPageView:layout(data)
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width,display.height))
	MainPanel:setPosition(display.cx,display.cy)

	--MainPanel:setScale(0)
	--MainPanel:setAnchorPoint(cc.p(0.5,0.5))
	MainPanel:setAnchorPoint(0.5,0.5)
	--MainPanel:setVisible(false)
	print("setPositionX:",display.cx)
	print("setPositionY:",display.cy)
    print("setContentSizeX:",display.width)
	print("setContentSizeY:",display.height)

	--MainPanel->runAction(ScaleTo::create(0.2,1.0));
	self.MainPanel = MainPanel

	local middle = MainPanel:getChildByName('middle')
	middle:setPosition(display.cx,display.cy)

	local name = middle:getChildByName('name')
	name:setString(data.nickName)

	local id = middle:getChildByName('id')
	id:setString( data.playerId)
	
	local ip = middle:getChildByName('ip')
	if data.ip then
		ip:setString(data.ip)
	end
    dump(data)

	local app = require("app.App"):instance()
	local userinfo = app.session.user

	local round = userinfo.win + userinfo.lose 
	local level = math.floor(round/500)
	if level < 1 then 
		level = 1
	elseif level > 9 then
		level = 9
	end
	-- level = 4
	local path = 'views/personalpage/hz_'..level..'.png'
	local levelImg = middle:getChildByName('img_level')
	levelImg:loadTexture(path)

	local male = middle:getChildByName('img_nan')
	local femal = middle:getChildByName('img_nv')
	male:setVisible(false)
	femal:setVisible(false)
	if data.sex and data.sex == 1 then
		femal:setVisible(true)
	else
		male:setVisible(true)
	end

	local registerTime=middle:getChildByName('registerTime')
	registerTime:setString(os.date("%Y/%m/%d", data.secondsFrom1970))

	local cache = require('app.helpers.cache')

	local avatar = middle:getChildByName('avatar')
	if data.avatar then
		avatar:retain()
		cache.get(data.avatar,function(ok,path)
		    if ok then
		      avatar:loadTexture(path)
		    end
		    avatar:release()
		end)
	end

	local userId = app.session.user.uid
	local kusoListPanel = middle:getChildByName('kusoListPanel')
	local tips = kusoListPanel:getChildByName('tips')
	tips:setVisible(userId == data.uid)
	local kusoList = kusoListPanel:getChildByName('kusoList')
	local Panel_1 = middle:getChildByName('Panel_1')
	local bg = middle:getChildByName('bg')
	local bg1 = middle:getChildByName('bg1')
	bg:setVisible(false)
	bg1:setVisible(false)

	if not data.searchMode then
		bg:setVisible(true)
		kusoListPanel:setVisible(true)
		kusoList:setVisible(true)
		Panel_1:setVisible(true)

		kusoList:setItemModel(kusoList:getItem(0))
    	kusoList:removeAllItems()
		kusoList:setScrollBarEnabled(false)
		
		for i, v in pairs(itemlist) do
			kusoList:pushBackDefaultItem()
			local item = kusoList:getItem(i-1)
			local img = item:getChildByName('img')
			img:loadTexture('views/xydesk/kuso/icon/'.. v .. '.png')
			
			if v == 8 and level >= 2 then
				img:loadTexture('views/xydesk/kuso/icon/'.. v .. 'on.png')
			end
			
			if v == 12 and level >= 3 then
				img:loadTexture('views/xydesk/kuso/icon/'.. v .. 'on.png')
			end
			
			if v == 15 and level >= 4 then
				img:loadTexture('views/xydesk/kuso/icon/'.. v .. 'on.png')
			end
			
			-- img:setScale(2)
			if userId ~= data.uid then 
				item:addClickEventListener(function()
					local dt = os.time()
					local biaoqingflag = self:biaoqingremind(v, level)
					local msg = { uid = data.uid, clickSender = data.clickSender, idx = v ,flag = false, dt = dt, level = level, biaoqingflag = biaoqingflag}
					self.emitter:emit('choosed', msg)
				end)
			else
				item:addClickEventListener(function()
					local dt = os.time()
					local biaoqingflag = self:biaoqingremind(v, level)
					local msg = { uid = data.uid, clickSender = data.clickSender, idx = v ,flag = true, dt = dt, level = level, biaoqingflag = biaoqingflag}
					self.emitter:emit('choosed', msg)
				end)
			end 
		end
	else
		middle:setPosition(display.cx,display.cy-50)
		bg1:setVisible(true)
		kusoListPanel:setVisible(false)
		kusoList:setVisible(false)
		Panel_1:setVisible(false)
	end

	--播放上一次的语音
	local panel_1 = middle:getChildByName('Panel_1')
	local playvoicebutton = panel_1:getChildByName('Button')

	playvoicebutton:addClickEventListener(function ()
		local msg = {uid = data.uid}
		self.emitter:emit('playoldvoice',msg)
	end)
end

function PersonalPageView:biaoqingremind(idx, level)
	if idx == 8 and level < 2 then 
		tools.showRemind('解锁该表情需要青铜牛牛等级')
		return false
	end
			
	if idx == 12 and level < 3 then
		tools.showRemind('解锁该表情需要白银牛牛等级')
		return false
	end
			
	if idx == 15 and level < 4 then
		tools.showRemind('解锁该表情需要黄金牛牛等级')
		return false
	end
	return true
end
return PersonalPageView
