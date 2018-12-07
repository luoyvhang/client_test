local geo = {}
local display = require('cocos.framework.display')

function geo.abs(node, x, y)
  assert(node)
  assert(type(x) == 'number')
  assert(type(y) == 'number')

  local parent = node:getParent()
  assert(parent)
  node:setPosition(parent:convertToNodeSpace(cc.p(x, y)))
end

function geo.fullscreen(node)
  local vsz = node:getContentSize()
  local scale = math.max(display.height / vsz.height, display.width / vsz.width)
  node:setScale(scale)
end

function geo.fitscreen(node)
  local vsz = node:getContentSize()
  local scale = math.min(display.height / vsz.height, display.width / vsz.width)
  node:setScale(scale)
end

return geo
