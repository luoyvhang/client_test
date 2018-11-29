local CaptureScreen = {}
local SoundMng = require('app.helpers.SoundMng')

function CaptureScreen.capture(filename,callback,layer,scale,preCaptureCall)
  local scene = cc.Director:getInstance():getRunningScene()
  local app = require("app.App"):instance()
  local ly0 = cc.LayerColor:create(cc.c4b(0,0,0,255),display.width,display.height*0.5)
  app.layers.top:addChild(ly0)
  ly0:setPositionY(display.height)

  local ly1 = cc.LayerColor:create(cc.c4b(0,0,0,255),display.width,display.height*0.5)
  app.layers.top:addChild(ly1)
  ly1:setPositionY(-display.height*0.5)

  local time = 0.2

  local mv0 = cc.MoveTo:create(time,cc.p(0,display.height*0.5))
  ly0:runAction(mv0)

  local mv1 = cc.MoveTo:create(time,cc.p(0,0))
  ly1:runAction(cc.Sequence:create(mv1,cc.CallFunc:create(function()
    SoundMng.playEft('common/audio_outpai.mp3')

    if not filename then
      filename = 'screen.jpg'
    end

    if preCaptureCall then
      preCaptureCall()
    end

    local size = cc.Director:getInstance():getWinSize()
    local screen = cc.RenderTexture:create(size.width*scale, size.height*scale,2,0x88F0)

    screen:begin()
    if layer then
      if scale then
        layer:setScale(scale)
      end
      layer:visit()
    else
      scene:visit()
    end
    screen:endToLua()
    --cc.Director:getInstance():render()

    if device.platform == 'android' then
      local tool = require('tool.tool')
      local externalStorageDirectory = tool.getExternalStorageDirectory()
      filename = externalStorageDirectory..filename
    end

    screen:saveToFile(filename, cc.IMAGE_FORMAT_JPEG,function(ok,path)
      print('ok path',ok,path)
      layer:setScale(1)
      if callback then
        callback(ok,path)
      end

      ly0:runAction(cc.RemoveSelf:create())
      ly1:runAction(cc.RemoveSelf:create())
    end)
  end)))
end

return CaptureScreen
