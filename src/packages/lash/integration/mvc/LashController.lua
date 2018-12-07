
local class = require('middleclass')
local Controller = require('mvc.Controller')
local LashController = class('LashController', Controller)

local Engine = require('lash.core.Engine')
local TickProvider = require('lash.integration.cocos2d-x.TickProvider')
local Input = require('lash.integration.cocos2d-x.Input')

function LashController:initialize()
  self.engine = Engine()
  self.tick = TickProvider(function(dt)
    self.engine:update(dt)
  end)
end


function LashController:loadView()
  local view = cc.Node:create()
  view:registerScriptHandler(function(event)
    if event == "enter" then
      self.tick:start()
    elseif event == "exit" then
      self.tick:stop()
    end
  end)
  self.input = Input()
  return view
end

function LashController:finalize()
  self.input:delete()
end

function LashController:viewDidLoad()
  print('Running Lash Engine....')
  self:initSystems()
  self:initEntities()
end

-- This function is intend to be overwrite by subclass
function LashController:initSystems() end

-- This function is intend to be overwrite by subclass
function LashController:initEntities() end

return LashController
