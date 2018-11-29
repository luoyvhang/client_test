local ShakeAction = {}

function ShakeAction.create(node,call,is)
  local ts = 1.05
  if is then
    ts = is
  end
  
  local os = node:getScale()
  local s0 = cc.ScaleTo:create(0.05,os * ts)
  local s1 = cc.ScaleTo:create(0.1,os)
  local action
  if call then
    action = cc.Sequence:create(s0,s1,cc.CallFunc:create(call))
  else
    action = cc.Sequence:create(s0,s1)
  end

  return action
end

return ShakeAction
