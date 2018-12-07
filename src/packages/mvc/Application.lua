local display = require("cocos.framework.display")
local class = require('middleclass')
local Application = class('mvc.Application')
local Controller = require('mvc.Controller')
local ok, devconf = pcall(require, 'devconf')

local function clear_layer(layer)
  local old = '<none>'

  if layer.controller then
    old = layer.controller.class.name
    layer.controller:delete()
    layer.controller = nil
    layer:removeAllChildren()
    collectgarbage()
  end
  return old
end

local function switch(layer, controller, ...)
  local old = clear_layer(layer)

  print(old..'->'..controller)

  local c = Controller:load(controller, ...)
  layer:addChild(c.view)
  layer.controller = c

  return c
end

local layers = {
  'primary',
  'ui',
  'top',
}

local function init(self)
  --cc.Director:getInstance():setDisplayStats(true)

  self.scene = cc.Scene:create()

  self.layers = {}
  for i, v in ipairs(layers) do
    local l = cc.Layer:create()
    l.switch = switch
    self.scene:addChild(l, i * 100)
    self.layers[v] = l
  end

  local locale = require('locale')
  locale.set('zh-Hans')
  display.runScene(self.scene)
end

local function exit(self)
  if not self.layers then return end
  for _, v in ipairs(self.layers) do
    clear_layer(v)
  end
end

function Application:initialize()
  assert(false, "Don't instance me!")
end

function Application:run(controller, ...)
  init(self)
  self:switch(controller, ...)
end

function Application:restart(controller, ...)
  exit(self)
  print('Restart to:', controller)

  -- clean fullpath cache
  cc.FileUtils:getInstance():purgeCachedEntries()

  -- clean package cache
  for k in pairs(package.loaded) do
    if k ~= 'socket' then
      package.loaded[k] = nil
    end
  end

  -- now loads a new app.App instance and run
  local app = require('app.App'):instance()
  app:run(controller, ...)
end

function Application:switch(controller, ...)
  self.layers.primary:switch(controller, ...)
end

function Application:setNextSwitchParam(controllerName, param)
  if not self.tabSwitchParam then
    self.tabSwitchParam = {}
  end
  self.tabSwitchParam[controllerName] = param --{subCtrl = 'xxx', ...}
end

function Application:delNextSwitchParam(controllerName)
  if self.tabSwitchParam and self.tabSwitchParam[controllerName] then
    self.tabSwitchParam[controllerName] = nil
  end 
end

function Application:getNextSwitchParam(controllerName)
  if self.tabSwitchParam and self.tabSwitchParam[controllerName] then
    return self.tabSwitchParam[controllerName]
  end 
end

return Application
