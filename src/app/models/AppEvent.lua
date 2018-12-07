local class = require('middleclass')
local HasSignals = require('HasSignals')
local AppEvent = class('AppEvent'):include(HasSignals)
local EventCenter = require("EventCenter")
local SoundMng = require("app.helpers.SoundMng")

function AppEvent:initialize()
  HasSignals.initialize(self)

  EventCenter.register("app", function(event)
    if event then
      if event == 'didEnterBackground' then

        SoundMng.isPauseVol(true)
        self.emitter:emit('didEnterBackground')
      elseif event == 'willEnterForeground' then
        
        SoundMng.isPauseVol(false)
        self.emitter:emit('willEnterForeground')
      end
    end
  end)
end


return AppEvent
