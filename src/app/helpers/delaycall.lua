local DelayCall = {}

function DelayCall.call(time,callback)
  local delay = cc.DelayTime:create(time)
  local action = cc.Sequence:create(delay,cc.CallFunc:create(callback))
  local app = require("app.App"):instance()
  app.layers.ui:runAction(action)
end

return DelayCall
