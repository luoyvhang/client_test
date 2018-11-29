local tools = require('app.helpers.tools')

local ApplyView = {}
function ApplyView:initialize()
  self.nCountDown = 0 -- 当前倒计时
  self.bCountDownBegin = false
end

function ApplyView:layout(desk)
  self.desk = desk

  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel = MainPanel

  local content = MainPanel:getChildByName('content')
  self.MainPanel.content = content
  self.MainPanel.list = content:getChildByName('list')
  self.MainPanel.list:setItemModel(self.MainPanel.list:getItem(0))
  self.MainPanel.list:removeAllItems()
  local listSize=self.MainPanel.list:getContentSize() 
  self.listSize=listSize

  local timeBg=content:getChildByName('bgTime')
  local timeLength=timeBg:getChildByName('timeLength')
  timeBg:setVisible(false) 
  self.timeBg=timeBg
  self.timeLength=timeLength

  -- 倒计时 node : Text
  local countDown = content:getChildByName("countDown")
  countDown:setVisible(false)
  self.nodeCountDown = countDown

end


function ApplyView:loadData(desk)
	local apply, applyEx = self.desk:getDismissInfo()
	
	-- 倒计时
	if applyEx then
		if self.bCountDownBegin == false then
			-- 开始
			self.bCountDownBegin = true
			self.nCountDown = math.floor(applyEx.countDown / 1000)
			local timeTotal= tonumber(math.floor(applyEx.countDown / 1000))
			self.nodeCountDown:setVisible(false)
			self.nodeCountDown:stopAllActions()
			self.nodeCountDown:runAction(
			cc.Sequence:create(
			cc.Repeat:create(
			cc.Sequence:create(cc.CallFunc:create(function()
				self.nodeCountDown:setString(string.format("(%s)", tonumber(self.nCountDown)))
				self.nCountDown = self.nCountDown - 1
				self.timeLength:setContentSize(cc.size(self.timeLength:getContentSize().width*(tonumber(self.nCountDown)/timeTotal),self.timeLength:getContentSize().height))
                timeTotal=tonumber(self.nCountDown)
			end),
			cc.DelayTime:create(1)
			),
			self.nCountDown
			),
			cc.Hide:create()
			)
			)
		end
	end
	
	self.MainPanel.list:removeAllItems()
	local app = require("app.App"):instance()
	local meUid = app.session.user.uid
	dump(apply)
	local playerNum=0
    for k,v in pairs(apply.result) do
		playerNum=playerNum+1
	end
    
	local sizeOfWidth = self.listSize.width * playerNum <= 734 and self.listSize.width * playerNum or 734
	self.MainPanel.list:setContentSize(cc.size(sizeOfWidth, self.listSize.height))
	local isprocessed = false
	local idx = 0
    
	for uid, status in pairs(apply.result) do
		self.MainPanel.list:pushBackDefaultItem()
		local player = {}
		local info = self.desk:getPlayerInfo(uid)
		if info then
			local actor = info.player:getActor()
			player.actor = actor
		else
			player = false
		end

        local isHorse = false
		
		if player then
			local item = self.MainPanel.list:getItem(idx)
			local name = item:getChildByName('name')
			local avatar = item:getChildByName('avatar')
			
			local cache = require('app.helpers.cache')
			if player.actor.avatar then
				avatar:retain()
				cache.get(player.actor.avatar, function(ok, path)
					if ok then
						avatar:loadTexture(path)
					end
					avatar:release()
				end)
			end
			
			if isHorse then
				name:setString(player.nickName)
			else
				name:setString(player.actor.nickName)
			end
			
			
			local shenqingren = self.MainPanel.content:getChildByName('Panel'):getChildByName('shenqingren')
			if apply.uid == uid then
				shenqingren:setString("" .. player.actor.nickName)
				-- shenqingren:setColor(cc.c3b(227,41,41))
			end
			
			local path
			if status == 0 then
				path = 'views/jiesan/weixuanze.png'
			elseif status == 1 then
				path = 'views/jiesan/yitongyi.png'
				
				if meUid == uid then
					isprocessed = true
				end
			else
				path = 'views/jiesan/weixuanze.png'
				if meUid == uid then
					isprocessed = true
				end
			end
			item:getChildByName('icon'):loadTexture(path)
			idx = idx + 1
		end
	end
	
	local agree = self.MainPanel.content:getChildByName('agree')
	local refuse = self.MainPanel.content:getChildByName('refuse')
	
	if isprocessed then
		local function common()
			tools.showRemind('您已经处理过了')
		end
		agree:setVisible(false)
		refuse:setVisible(false)
		self.nodeCountDown:setVisible(false)
		self.timeBg:setVisible(true)
		--agree:addClickEventListener(common)
        --refuse:addClickEventListener(common)
	else
		agree:addClickEventListener(function()
			self.emitter:emit('apply', 'agree')
		end)
		
		refuse:addClickEventListener(function()
			self.emitter:emit('apply', 'refuse')
		end)
	end
end 

return ApplyView
