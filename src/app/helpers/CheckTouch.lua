local CheckTouch = {}

function CheckTouch.check(node,x,y,size)
  if not size then
    size = node:getContentSize()
  end

  local nodePos = cc.p(x,y)
  nodePos = node:convertToNodeSpace(nodePos)
  local rect = cc.rect(0,0,size.width,size.height)
  local flag = cc.rectContainsPoint(rect,nodePos)
  return flag
end

return CheckTouch