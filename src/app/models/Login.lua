local class = require('middleclass')
local HasSignals = require('HasSignals')
local Login = class('Login'):include(HasSignals)
local tools = require('app.helpers.tools')


function Login:initialize()
  HasSignals.initialize(self)
end

function Login:getUid(rcall)
  local app = require("app.App"):instance()

  app.conn:once('genUid',function(data)
    app.LocalSettings:set('uid',data.uid)
    rcall()
  end)

  local msg = {
    msgID = 'genUid',
  }
  app.conn:send(msg)
end

function Login:login(uid,avatar,nickName, sex)
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = 'signin',
    uid = uid,
    avatar = avatar,
    nickName = nickName,
    sex = sex
  }
  app.localSettings:set('uid',uid)
 
  conn:send(msg)
  --ShowWaiting.show()

  conn:once('signinResult',function(data)
    if data.errorMsg then
      print(data.errorMsg)
      tools.showRemind(data.errorMsg)
    else
      app.session.user:initFromNet(data.package.user)
      self.emitter:emit('loginSuccess')
    end

    --ShowWaiting.delete()
  end)
end

return Login
