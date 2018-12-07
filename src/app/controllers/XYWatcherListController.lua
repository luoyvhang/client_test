local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local XYWatcherListController = class("XYWatcherListController", Controller):include(HasSignals)

function XYWatcherListController:initialize(deskModel)
	Controller.initialize(self)
	HasSignals.initialize(self)
	self.desk = deskModel
end

function XYWatcherListController:viewDidLoad()
	local app = require("app.App"):instance()
	self.view:layout(self.desk)
	
	self.listener = {		
		self.desk:on('watcherList', function(msg)
			local data = self.desk:getWatcherList()
			self.view:freshListView(data)
		end),
	}
	
	self.desk:watcherList()
end


function XYWatcherListController:clickBack()
	self.emitter:emit('back')
end

function XYWatcherListController:finalize()-- luacheck: ignore
	for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return XYWatcherListController
