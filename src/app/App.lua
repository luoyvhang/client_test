local class = require('middleclass')
local Application = require('mvc.Application')
local App = class('app.App', Application)
local Connection = require('network.Connection')
local Engine = require('lash.core.Engine')
local Session = require('app.Session')
local LocalSettings = require('app.models.LocalSettings')

function Engine:getNodes(nodename) -- Patch the engine for get node node list by node name
  local Node = require('app.nodes.'..nodename)
  return self:getNodeList(Node)
end

local app = nil
function App.static.instance()
  if app == nil then
    app = App()
  end
  return app
end

function App:initialize()
  self.conn = Connection()
  self.localSettings = LocalSettings()
end

function App:createSession()
  self.session = Session()
end

return App
