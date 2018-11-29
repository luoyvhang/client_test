local Activity = class("Activity", function() 
  return display.newNode() 
end)

Activity.ATTACT_START = "Attack.START"
Activity.ATTACT_STOP = "Attack.STOP"
Activity.LIFE_DIED = "Life.DIED"

function Activity:ctor(param)
  self.myEvent = {}
  self:addComponent("Attack", param.acctack)
  self:addComponent("Life", param.life)
  self:addComponent("Skin", param.type)

  --self.addComponent("Skill", param.skill)
  --self.addComponent("Lieytenant", param.Lieytenant)
  self:_listen()
end

function Activity:_listen()
  self:on(Activity.ATTACT_START, function(param)
    self:getComponent("Skin"):Attack()
  end)

  self:on(Activity.LIFE_DIED, function(param)
    self.getComponent("Skin"):died()
  end)

  self:on(Activity.LIFE_HURT, function(param)
    self.getComponent("Skin"):hurt(param.cout)
  end)
end

function Activity:on(type, func)
  if not self.myEvent[type] then
    self.myEvent[type] = {}
  end
  table.insert(self.myEvent[type], func)
end

function Activity:run()

end

function Activity:stop()

end

function Activity:died()

end

function Activity:eventCenter(type, ...)
  print("use type："..type)
  if self.myEvent[type] then
    self.myEvent[type](...)
  end
end

function Activity:beHurt()
  
end
----添加组件
function Activity:addComponent(name, ...)
  self[componentName] = require(string.format("app.component.%s", componentName)).new(...)
  self[componentName]:binding(function(type, ...) self:eventCenter(type, ...) end)
  self:addChild(self[componentName])
end
----获取组件实例
function Activity:getComponent(name)
  return self[componentName]
end

return Activity