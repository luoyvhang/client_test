local class = require('middleclass')
local Engine = require('Engine')
local Entity = require('Entity')
local json = require('cjson')
local File = cc.FileUtils:getInstance()

local State = class('State')

function State:initialize()
  self.engine = Engine()

  for _, v in ipairs({'DisplaySystem', ''}) do
    local Sys = require('app.systems.'..v)
    local sys = Sys()
    self.engine:addSystem(sys)
  end

  for _, v in ipairs(conf.entities) do
    local entity = Entity()
    for _, c in ipairs(v.components) do
      local Com = require('app.components.'..c.class)
      local com = Com(c)
      entity:add(com)
    end
    entity.name = v.name
    entity.tag = v.tag
    print('add Entiry: ', v.name)
    self.engine:addEntity(entity)
  end
end


function State:update(dt)
  self.engine:update(dt)
end

function State:draw()
  self.engine:draw()
end


return State
