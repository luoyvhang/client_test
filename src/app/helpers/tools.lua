--local proto = require('app.net.proto')

local tools = {}
local display = require('cocos.framework.display')
local transition = require('cocos.framework.transition')

function tools.flyAction(path, sPos, ePos, func)
  local app = require("app.App"):instance()
  local loop =  20
  if loop <= 0 then
    loop = 1
  end

  for i = 1,loop do
    local spr = cc.Sprite:create(path)
    app.layers.ui:addChild(spr)
    spr:setPosition(sPos)

    local delay = 0.2 + math.random(5) * 0.1
    local mv = cc.MoveTo:create(delay,ePos)

    spr:runAction(cc.Sequence:create(mv,cc.CallFunc:create(function()
      if func and i == 1 then
        func()
      end
    end),cc.RemoveSelf:create()))

    spr:setScale(0.1)
    local sc = cc.ScaleTo:create(delay * 0.9,1.0)
    spr:runAction(sc)
  end
end

function tools.showRemind(text, delay)
  delay = delay or 1.9
  local layer = cc.Layer:create()
  layer:ignoreAnchorPointForPosition(false)
  layer:setAnchorPoint(cc.p(0.5, 0.5))
  local label = cc.Label:createWithTTF(text,'views/font/fangzheng.ttf',35, cc.size(620,0),cc.TEXT_ALIGNMENT_CENTER)
  label:setOpacity(0)
  local size = label:getContentSize()
  layer:setContentSize(cc.size(size.width + 10, size.height + 10))
  layer:setPosition(cc.p(display.cx, display.cy + 50))
  local image = ccui.ImageView:create('views/public/123.png')
  label:setPosition(cc.p((size.width + 10) / 2, (size.height + 10) / 2))
  image:setPosition(cc.p((size.width + 10) / 2, (size.height + 10) / 2))
  layer:addChild(image)
  layer:addChild(label)
  layer:runAction(cc.Sequence:create({
    cc.CallFunc:create(function()
      layer:runAction(cc.FadeTo:create(0.4, 190))
      label:runAction(cc.FadeIn:create(0.4))
    end),
    -- cc.DelayTime:create(0.4),
    cc.DelayTime:create(delay),
    -- cc.CallFunc:create(function()
    --   layer:runAction(cc.MoveTo:create(0.4, cc.p(display.cx, display.height + 20)))
    -- end),
    cc.CallFunc:create(function()
      layer:runAction(cc.FadeOut:create(0.2))
      label:runAction(cc.FadeOut:create(0.2))
    end),
    cc.DelayTime:create(0.2),
    cc.RemoveSelf:create()
  }))


  require('app.App'):instance().layers.top:addChild(layer)
  return label
end

function tools.showMsgBox(title, content, btnCount)
  return require('app.App'):instance().layers.top:switch('MsgBoxController', title or '', content or '', btnCount)
end

function tools.hideMsgBox()
  return require('app.App'):instance().layers.top:switch('MsgBoxController')
end


function tools.numberChangeTo(label, org, dis,time)
    tools.schedule(label, function()
        label:setString(org)
        org = org + 1
        if org > dis then
            label:stopAllActions()
        end
    end, time)
end

function tools.labelChange(label, string)
    label:setString(string)
    label:stopAllActions()
    label:runAction(transition.sequence({
        cc.ScaleTo:create(0.1, 1.5),
        cc.ScaleTo:create(0.1, 1.0),
    }))
end

function tools.nodeScaleAction(node)
    node:stopAllActions()
    node:runAction(cc.RepeatForever:create(transition.sequence({
        cc.ScaleTo:create(0.3, 1.3),
        cc.ScaleTo:create(0.3, 1.0),
    })))
end

function tools.schedule(node,callback,interval)
    local seq = transition.sequence({
        cc.DelayTime:create(interval),
        cc.CallFunc:create(callback),
    })
    local action = cc.RepeatForever:create(seq)
    node:runAction(action)
    return action
end

function tools.tableInclude(tb, value)
    for _, v in pairs(tb) do
        if v == value then
            return true
        end
    end
    return false
end

function tools.tableRemove(tbl, key)
  for i = 1,#tbl do
    if tbl[i] == key then
      table.remove(tbl,i)
      break
    end
  end
end

function tools.actionRestore(rcall)
    local function began(_)
      return true
    end
    local function ended(_)
      if rcall then rcall() end
    end
    local winSize = cc.Director:getInstance():getWinSize()
    local cancel = cc.LayerColor:create(cc.c4b(0,0,0,200),winSize.width,winSize.height)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(ended,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(began,cc.Handler.EVENT_TOUCH_BEGAN )

    local eventDispatcher = cancel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, cancel)
    return cancel
end

function tools.gcnode(func)
    local node = display.newNode():hide()
    node:registerScriptHandler(function(event)
        if "exit" == event then
            func()
        end
    end)

    return node
end

function tools.androidBackKey(runner)
        -- avoid unmeant back
    runner:setKeypadEnabled(true)
    runner:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
        if event.key == "back" then
            print("press back")
            if not runner.__is_open then
                local window = require('app.views.MessageBoxShowView').new():show()
                runner.__is_open = true

                local ok = tools.scaleButton({
                    img = "public/Button/GreenButtonShort.png",
                    text = TEXT.YES,
                    size = 30
                }):onButtonClicked(function()
                    --audio.playSound("Audio/Effect/BtnClick.mp3", false)
                    window:close()
                end )

                local cancel = tools.scaleButton({
                    img = "public/Button/RedButtonShort.png",
                    text = TEXT.NO,
                    size = 30
                }):onButtonClicked(function()
                    --cc.Director:getInstance():endToLua()
                    --audio.stopAllSounds()
                    --audio.stopMusic(true)
                    app:exit()
                end )

                window:onClose(function()
                    runner.__is_open = false
                end)
                window:setString( TEXT.PLAYAGAIN )
                window:setDown({cancel,{x=100,y=0}, ok})
            end
        end
    end)
end

function tools.numberToStander(num)
    local result = ""
    local needSign = false
    while num / 1000 >= 1 do
        needSign = true
        if result == "" then
            result = string.format("%03d", (num % 1000))
        else
            result = string.format("%03d", (num % 1000))..","..result
        end
        num = math.floor(num / 1000)
    end
    if needSign then
        result = (num % 1000)..","..result
    else
        result = (num % 1000)..result
    end
    return result
end

local function loadCsb(csb)
  print('Loading "'..csb..'"...')
  if not cc.FileUtils:getInstance():isFileExist(csb) then
    print('Not exists. Skippd.')
    return cc.Node:create()
  end

  local node = cc.CSLoader:createLocalizedNode(csb)
  if not node then
    print(string.format('Failed to load View node from "%s" ', csb))
    return cc.Node:create()
  end

  return node
end

function tools.loadChatNode(func, noOpacity)
  local node = loadCsb("views/teach/ChatNode.csb")
  node:setPositionX(display.cx)
  local layer = node:getChildByName("layer")
  layer:setVisible(true)
  layer:addClickEventListener(function()
    func()
  end)
  layer:setContentSize(cc.size(display.width, display.height))
  if noOpacity then
    layer:setOpacity(0)
  end
  require('app.App'):instance().layers.top:addChild(node)
  return node
end

function tools.loadChatContent(chatNode, cfg)
  local app = require("app.App"):instance()
  local user = app.session.user
  local left = chatNode:getChildByName("left")
  local right = chatNode:getChildByName("right")
  if cfg.l == "" then cfg.l = "mainhero_"..(user:getMainHeroIndex() - 1).."_0" end
  if cfg.r == "" then cfg.r = "mainhero_"..(user:getMainHeroIndex() - 1).."_0" end
  left:loadTexture("heros/"..cfg.l..".png")
  left:setColor(cfg.pos == 1 and cc.c3b(255,255,255) or cc.c3b(88,88,88))
  right:loadTexture("heros/"..cfg.r..".png")
  right:setColor(cfg.pos == 2 and cc.c3b(255,255,255) or cc.c3b(88,88,88))
  if cfg.name == "" then
    chatNode:getChildByName("name"):setString(user.name..":")
  else
    chatNode:getChildByName("name"):setString(cfg.name..":")
  end
  chatNode:getChildByName("content"):setString(cfg.ct)
end

function tools.loadArrow(pos, func)
  local node = loadCsb("views/teach/DownArrow.csb")
  local layer = node:getChildByName("layer")
  local arrow = node:getChildByName("arrow")
  arrow:setPosition(pos)
  layer:setVisible(true)
  layer:addClickEventListener(function()
    func()
  end)
  layer:setPosition(cc.p(display.cx,display.cy))
  layer:setContentSize(cc.size(display.width, display.height))

  arrow:runAction(cc.RepeatForever:create(
    cc.Sequence:create(
      cc.MoveTo:create(0.4,cc.p(pos.x, pos.y + 20)),
      cc.MoveTo:create(0.4,cc.p(pos.x, pos.y))
    )
  ))
  require('app.App'):instance().layers.top:addChild(node)
  return node
end

function tools.createEditBox(sprite,param,inputSprite,scaleRect)
  if not param then
    param = {}
  end

  if not inputSprite then
    inputSprite = 'views/public/shurukuang.png'--'views/exchange/kuang.png'
  end

  local sprSize = sprite:getContentSize()

  local rect = cc.rect(11,11,20,30)
  if scaleRect then
    rect = scaleRect
  end

  local s9pr = ccui.Scale9Sprite:create(rect,inputSprite)
  local editbox = ccui.EditBox:create(sprSize, s9pr)

  editbox:setPosition(cc.p(sprite:getPosition()))
  editbox:setPlaceHolder(param.defaultString or "")
  editbox:setPlaceholderFontSize(param.holderSize or 30)
  editbox:setPlaceholderFontColor(param.holderColor or cc.c3b(255,255,255))
  editbox:setFontColor(param.fontColor or cc.c3b(0,0,0))
  editbox:setFontSize(param.size or 30)
  editbox:setMaxLength(param.maxCout or 20)
  editbox:setInputMode(param.inputMode or cc.EDITBOX_INPUT_MODE_SINGLELINE)
  editbox:setInputFlag(param.inputFlag or cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS)
  if param.fontType then
    editbox:setFontName(param.fontType)
  end
  if param.holderfontType then
    editbox:setPlaceholderFontName(param.holderfontType)
  end
  editbox:setAnchorPoint(sprite:getAnchorPoint())
  sprite:getParent():addChild(editbox)
  sprite:removeSelf()

  return editbox
end

return tools
