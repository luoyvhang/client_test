local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local ShareController = class('ShareController', Controller):include(HasSignals)

function ShareController:initialize(groupInfo)
	Controller.initialize(self)
	HasSignals.initialize(self)
	self.groupInfo = groupInfo
end

function ShareController:viewDidLoad()
	self.view:layout()
end

function ShareController:clickBack()
  self.emitter:emit('back')
end

function ShareController:setShare(flag)
	local SocialShare = require('app.helpers.SocialShare')

	local share_url = 'http://nnstart.qiaozishan.com/download'
	local image_url = 'http://192.168.1.5/icon.png'
	local text = '我在 快乐牛牛启航版 玩嗨了，快来加入吧！'
	local token = "0"
	if self.groupInfo then 
		text = text .. '俱乐部id：' .. self.groupInfo.id
	end
	SocialShare.share(flag, function(platform, stCode, errorMsg)
		print('platform, stCode, errorMsg', platform, stCode, errorMsg)
	end,
	share_url,
	image_url,
	text,
	'快乐牛牛启航版')
end

function ShareController:clickHaoYouQun()
	self:setShare(1)
end

function ShareController:clickPengYouQuan()
	self:setShare(2)
end

function ShareController:finalize()-- luacheck: ignore
end

return ShareController
