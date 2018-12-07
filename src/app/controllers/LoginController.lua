local class = require('middleclass')
local Controller = require('mvc.Controller')
local LoginController = class("LoginController", Controller)
local ShowWaiting = require('app.helpers.ShowWaiting')
local uploaderror = require('app.helpers.uploaderror')
local SoundMng = require('app.helpers.SoundMng')

function LoginController:initialize(version)
  Controller.initialize(self)
  self.version = version
  SoundMng.load()
  
  if device.platform == 'ios' or device.platform == 'android' then
    uploaderror.changeTraceback()
  end
end

function LoginController:sendPingMsg()
  local app = require("app.App"):instance()
  app.conn:send(-1,1,{
    receive = 'hello'
  })
end

function LoginController:clickLogin()
  if not self.view:getIsAgree() then
    tools.showRemind("请确认并同意协议")
    return 
  end
  if self.logining then return end
  self.logining = true
  SoundMng.playEft('sound/common/audio_card_out.mp3')
  --audio.playSound('sound/common/audio_card_out.mp3')
  local app = require("app.App"):instance()
  local login = app.session.login

  local function ios_login(uid,avatar,username, sex)
    login:login(uid,avatar,username, sex)

    app.localSettings:set('avatar', avatar,true)
    app.localSettings:set('logintime', os.time(),true)
    app.localSettings:set('username', username)
  end

  if device.platform == 'android' or device.platform == 'ios' then
  --if device.platform == 'ios' then
    local need_try = true
    if device.platform == 'ios' then
      local expired = 7200
      local uid = app.localSettings:get('uid')
      local avatar = app.localSettings:get('avatar')
      local username = app.localSettings:get('username')
      local logintime = app.localSettings:get('logintime')
      if uid and avatar and username and logintime then
        local diff = os.time() - logintime
        if diff < expired then
          need_try = false
          ios_login(uid,avatar,username)
        end
      end
    end

    local platform = 'wechat'
    -- 加载umeng的只是为了初始化
    local social_umeng = require('social')

    local social
    if device.platform == 'android' then
      social = social_umeng
    else
      social = require('socialex')
    end

    if need_try then
      ShowWaiting.show()
      social.authorize(platform, function(stcode,user)
        print('stcode is ',stcode)
        self.logining = false
        if stcode == 100 then return end

        if stcode == 200 then
          dump(user)
          if device.platform == 'ios' then
            if user.sex and user.sex - 1 < 0 then user.sex = 1 end
            ios_login(user.uid,user.avatar,user.username, user.sex - 1)
          else
            if user.sex and user.sex - 1 < 0 then user.sex = 1 end
            login:login(user.unionid,user.headimgurl,user.nickname, user.sex - 1)
          end

          if device.platform == 'ios' then
            social.switch2umeng()
          end
        end
        ShowWaiting.delete()
      end)
    end
  else
    print(app.localSettings:get('uid'))
    local uid = app.localSettings:get('uid')
    if not uid then
      app.localSettings:set('uid', tostring(os.time()))
    end
    login:login(app.localSettings:get('uid'))
  end

  --停止播放动画
  self.view:stopAllCsdAnimation()
end

function LoginController:viewDidLoad()
  local app = require("app.App"):instance()

  cc.Director:getInstance():setClearColor(cc.c4f(1,1,1,1))

  if app.session then
    app.conn:reset()
    app.session = nil
  end

  app:createSession()

  local login = app.session.login
  local net = app.session.net

  net:connect()

  -- windows平台自动登录
  net:once('connect',function()
    if false and cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
      self:clickLogin()
      print("auto login")
    else
      if app.localSettings:get('uid') then
        self:clickLogin()
      end
    end
  end)

  self.listens = {
    login:on('loginSuccess',function()
      print("login success")
      app:switch('LobbyController')
    end)
  }

  self.view:layout(self.version)
end

function LoginController:clickShowXieyi()
  self.view:freshXieyiLayer(true)
end

function LoginController:clickCloseXieyi()
  self.view:freshXieyiLayer(false)
end

function LoginController:clickAgree()
  self.view:freshIsAgree()
end

function LoginController:finalize()-- luacheck: ignore
  for i = 1,#self.listens do
    self.listens[i]:dispose()
  end
end

return LoginController
