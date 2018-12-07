local AddWindowTitle = {}
local winSize = cc.Director:getInstance():getWinSize()

function AddWindowTitle.add(title,createBackButton,layer)
  local bg = cc.Sprite:create("res/views/public/bg.jpg")
  layer:addChild(bg,-1)
  bg:setPosition(cc.p(winSize.width / 2,winSize.height / 2))


  local title = cc.LabelTTF:create(title,"fonts/arial.ttf",60)
  layer:addChild(title)
  title:setColor(cc.c3b(0,0,0))
  layer._startY = winSize.height - 240
  title:setPosition(cc.p(winSize.width / 2,layer._startY))

  if createBackButton then
    local menu = cc.Menu:create()
    menu:setPosition(cc.p(0,0))
    layer:addChild(menu)
    layer.mainMenu = menu

    do
      local item = cc.MenuItemImage:create("res/views/Lobby/cancel.png","res/views/Lobby/cancel.png")
      local itemSize = item:getContentSize()
      menu:addChild(item)
      item:setPosition(cc.p(40 + itemSize.width / 2,layer._startY))

      local selectImg = item:getSelectedImage()
      selectImg:setColor(cc.c3b(100,0,0))

      local function onBack()
        layer.signals:emit("clickBack")
      end
      item:registerScriptTapHandler(onBack)
    end
  end
end

return AddWindowTitle