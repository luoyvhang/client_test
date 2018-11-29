local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local ApplyController = class("ApplyController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function ApplyController:initialize(desk)
	Controller.initialize(self)
	HasSignals.initialize(self)
	
	self.desk = desk
end

function ApplyController:viewDidLoad()
	self.view:layout(self.desk)

	local app = require("app.App"):instance()
	self.listener = {		
		self.view:on('apply', function(type)
			self:apply(type)
		end),

		self.desk:on('overgame', function(msg)
			self:fresh()
		end),

		self.desk:on('overgameResult', function(type)
			self:fresh()
		end),
	}
	
	self:fresh()
end

function ApplyController:apply(type)
	local answer = 2
	if type == 'agree' then
		answer = 1
	end
	
	self.desk:answer(answer)
end

function ApplyController:fresh()
	local overSuggest, overTickInfo = self.desk:getDismissInfo()
	if (not overSuggest) and (not overTickInfo) then return end

	-- 解散失败
	local result = overSuggest.result
	for uid, status in pairs(result) do
		if status ~= 0 and status ~= 1 then
			local info = self.desk:getPlayerInfo(uid)
			if info then
				local nickname = info.player:getNickname()
				tools.showRemind('玩家 '.. nickname .. ' 拒绝了解散申请, 游戏继续.')
			end
			self:clickBack()
			return 
		end
	end

	self.view:loadData(overSuggest, overTickInfo)
end

function ApplyController:clickBack()
	self.emitter:emit('back')
end

function ApplyController:finalize()-- luacheck: ignore
	for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return ApplyController
