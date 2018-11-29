local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local TranslateView = require('app.helpers.TranslateView')
local SoundMng = require "app.helpers.SoundMng"
local Scheduler = require('app.helpers.Scheduler')
local winSize = cc.Director:getInstance():getWinSize()
local currentwidth = 1136 * 0.7
local RecordController = class("RecordController", Controller):include(HasSignals)

function RecordController:initialize()
  Controller.initialize(self)
	HasSignals.initialize(self)
	
	self.loadIdx = 1
  self.cd = 0.3
  self.run = false
  self.tick = 0

  self.updateF = Scheduler.new(function(dt)
    self:update(dt)
  end)
end

function RecordController:viewDidLoad()--
  local app = require("app.App"):instance()
	local record = app.session.record
	self.record = record
	self.view:layout()
	
  self.listener = {
    record:on('listRecords',function(records)
      --dump(records)
      -- self.view:listRecords(records)
		end),
		
    record:on('newRecord',function(records)
      -- dump(records)
      if not self.run then
        self.loadIdx = 1
        -- self.view:freshTips(false)
        self.run = true
      end
    end),

    record:on('nonelistRecords',function(records)
      -- dump(records)
      -- self.view:freshTips(true)
		end),
		
    self.view:on('shareRecord',function(result)
      --dump(records)
      self:setWidgetAction("XYSummaryController", result)
    end),
  }

  record:listRecords()
end

function RecordController:update(dt)
  if self.run then
    self.tick = self.tick + dt
    if self.tick >= self.cd then
      local tabData = self.record.records
      local cnt = #tabData
      local tabdatainfo = tabData[self.loadIdx]
      if self.loadIdx <= cnt then
        if tabdatainfo.groupInfo then 
          self.view:pushBackClubRecords(tabdatainfo)
        else
          self.view:pushBackRecords(tabdatainfo)
        end
        self.loadIdx = self.loadIdx + 1
      end
      self.tick = 0
    end
  end
end


function RecordController:clickBack()
  self.emitter:emit('back')
end

function RecordController:clicktab(sender)
  self.view:freshTab(sender)
end

function RecordController:clickShare()
	local CaptureScreen = require('app.helpers.capturescreen')
	local SocialShare = require('app.helpers.SocialShare')
  local size = currentwidth / winSize.width 
  local scale = size > 1 and 1 or  size
	CaptureScreen.capture('record.jpg', function(ok, path)
		if ok then
			if device.platform == 'ios' then
				path = cc.FileUtils:getInstance():getWritablePath() .. path
			end
			
			SocialShare.share(1, function(stcode)
				print('stcode is ', stcode)
			end,
			nil,
			path,
			'我们在快乐牛牛启航版玩嗨了，快来加入我们',
			'快乐牛牛启航版', true)
		end
	end, self.view, scale)
end 

function RecordController:clicknamelayer()
    self.view:showPlayerFullName(false)
end

function RecordController:finalize()
	self.run = false
	if self.updateF then
    Scheduler.delete(self.updateF)
    self.updateF = nil
  end
  for i = 1,#self.listener do
    self.listener[i]:dispose()
  end
end

function RecordController:setWidgetAction(controller, args)
	--SoundMng.playEft('btn_click.mp3')
	local ctrl = Controller:load(controller, args)
	self:add(ctrl)

	local app = require("app.App"):instance()
	app.layers.ui:addChild(ctrl.view)
	-- ctrl.view:setPositionX(display.width)

	--TranslateView.moveCtrl(ctrl.view, -1)
	-- TranslateView.fadeIn(ctrl.view, -1)
	ctrl:on('back', function()
		-- TranslateView.fadeOut(ctrl.view, 1, function()
			ctrl:delete()
		-- end)
	end)
end

return RecordController
