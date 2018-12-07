local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local PlaybackController = class("PlaybackController", Controller):include(HasSignals)

function PlaybackController:initialize(deskModel)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.desk = deskModel    
end

function PlaybackController:viewDidLoad()
    self.view:layout(self.desk)
	self.listener = {		
        self.desk:on('deskRecord', function(msg)
			self.view:freshRecordView('lastPage', msg.mode)
		end),   

    } 

    self.desk:deskRecord()
end

function PlaybackController:firstPage()
    self.view:freshRecordView('firstPage')   
end

function PlaybackController:frontPage()
    self.view:freshRecordView('frontPage')   
end

function PlaybackController:nextPage()
    self.view:freshRecordView('nextPage')   
end

function PlaybackController:lastPage()
    self.view:freshRecordView('lastPage')   
end

function PlaybackController:clickBack()
    self.emitter:emit('back')
end

function PlaybackController:finalize()
	for i = 1, #self.listener do
		self.listener[i]:dispose()
	end
end

return PlaybackController
