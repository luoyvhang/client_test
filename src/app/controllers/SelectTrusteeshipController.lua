local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local SoundMng = require('app.helpers.SoundMng')
local tools = require('app.helpers.tools')
local SelectTrusteeshipController = class("SelectTrusteeshipController", Controller):include(HasSignals)

function SelectTrusteeshipController:initialize(data)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.desk = data[1]
end

function SelectTrusteeshipController:viewDidLoad()
	self.view:layout(self.desk)
	self.listener = {
		self.desk:on('smartTrusteeshipResult', function(msg)
			--智能托管返回结果
			self:clickClose()
			if msg.retCode == -1 then 
				tools.showRemind('游戏还没开始不能托管')
			end
		end),

		self.desk:on('smartOpt', function(msg)
			--托管状态返回结果
			if msg.data then
				self.view:setOptions(msg.data)
			end
		end),
	}
	self.desk:requestTrusteeshipMsg()
end

function SelectTrusteeshipController:clickClose()
    self.emitter:emit('back')
end


function SelectTrusteeshipController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

function SelectTrusteeshipController:clickselect(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshTab(data, sender)
end
function SelectTrusteeshipController:clickIntelligentSelect(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshIntelligent(data, sender)
end
function SelectTrusteeshipController:clickSure()
    SoundMng.playEft('btn_click.mp3')
    if self.desk:isMeInMatch() then
		local msg = self.view:getOptions()
		dump(msg)
		self.desk:sendTrusteeshipMsg(true, msg)
    end
end

function SelectTrusteeshipController:clickHelp(sender)
	SoundMng.playEft('btn_click.mp3')
	local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshHelpView(data)
end

return SelectTrusteeshipController