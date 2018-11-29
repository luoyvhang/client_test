local CreateAttribute = {}
local CreateTip = require('app.helpers.CreateTip')
local EnableNodeTouch = require('app.helpers.EnableNodeTouch')

function CreateAttribute.create(attribute, heightDis)
  local nodeForInfo = cc.Node:create()
  nodeForInfo.dic = {}
  local y = 0
  local function destroyTip()
    if nodeForInfo.tip then
      local parent = nodeForInfo.tip:getParent()
      if parent then
        nodeForInfo.tip:removeFromParent()
      end
      nodeForInfo.tip:release()
      nodeForInfo.tip = nil
    end
  end

  nodeForInfo:enableNodeEvents()
  nodeForInfo.onExit = function()
    destroyTip()
    print('nodeForInfo.onExit ....')
  end

  for i = 1,#attribute do
    local dis = attribute[i].dis or 20
    local entry = attribute[i]
    local fontSize = attribute[i].fontSize or 32
    local title = cc.Label:createWithTTF(entry.title,'views/font/FZXIANGLJW.ttf',fontSize)
    local titleSize = title:getContentSize()
    title:setAnchorPoint(cc.p(1,0.5))
    nodeForInfo:addChild(title)
    title:setPosition(cc.p(0,y))
    title:setColor(cc.c3b(0,0,0))

    local icon = ccui.Button:create(entry.icon)
    icon:ignoreContentAdaptWithSize(false)
    icon:setContentSize(cc.size(fontSize + 4,fontSize + 4))
    local iconSize = icon:getContentSize()
    nodeForInfo:addChild(icon)
    local iconX, iconY = dis + iconSize.width / 2, y
    icon:setPosition(cc.p(iconX,iconY))
    local function onClickIcon(node)
      destroyTip()

      nodeForInfo.tip = CreateTip.create(entry.content)
      icon:addChild(nodeForInfo.tip)
      nodeForInfo.tip:retain()
      nodeForInfo.tip:setPosition(cc.p(iconSize.width / 2,iconSize.height / 2))
      EnableNodeTouch.enable(nodeForInfo.tip,function(pos)
        local npos = nodeForInfo.tip:convertToNodeSpace(pos)
        local size = nodeForInfo.tip:getContentSize()
        local rect = cc.rect(0,0,size.width,size.height)
        local flag = cc.rectContainsPoint(rect,npos)
        if not flag then
          destroyTip()
        end

        return flag
      end,nil,nil,true)
    end
    icon:addClickEventListener(onClickIcon)

    local num = cc.Label:createWithTTF(entry.value,'views/font/FZXIANGLJW.ttf',fontSize)
    num:setAnchorPoint(cc.p(0,0.5))
    local numSize = num:getContentSize()
    nodeForInfo:addChild(num)

    local numX, numY = iconX + iconSize.width / 2 + dis, y
    num:setPosition(cc.p(numX, numY))
    num:setColor(cc.c3b(0,0,0))
    if entry.key then
      nodeForInfo.dic[entry.key] = num
    end

    if entry.add then
      local add = cc.Label:createWithTTF('+' .. entry.add,'views/font/FZXIANGLJW.ttf',fontSize)
      add:setAnchorPoint(cc.p(0,0.5))
      local addSize = add:getContentSize()
      nodeForInfo:addChild(add)
      local addX, addY = numX + numSize.width + dis, y
      add:setPosition(cc.p(addX,addY))
      add:setColor(cc.c3b(255,0,0))
    end

    y = y - (heightDis or 56)
  end

  return nodeForInfo
end

function CreateAttribute.getNumLabel(node,k)
  return node.dic[k]
end

return CreateAttribute
