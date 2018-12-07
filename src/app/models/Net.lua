local class = require('middleclass')
local HasSignals = require('HasSignals')
local config = require('config')
local Net = class('Net'):include(HasSignals)
local tools = require "app.helpers.tools"
local ShowWaiting = require('app.helpers.ShowWaiting')

Net.C_GATE = 1
Net.C_GAME = 2

function Net:initialize()
  HasSignals.initialize(self)

  local app = require("app.App"):instance()
  local conn = app.conn
  conn:on('open',function(ip,port)
    print("open", ip,port)
    if self.hookOpen then
      self.hookOpen()
    else
      if ip == self.host and port == self.port then
        if self.state == Net.C_GATE then
          print('getGateLst')
          local msg = {
            msgID = 'getGateLst'
          }
          conn:send(msg)
        elseif self.state == Net.C_GAME then
          print('Connector connect')
          print('start loginOnGate!!')
          local msg = {
            msgID = 'loginOnGate'
          }

          conn:send(msg)
        end
      end
    end
  end)

  conn:on('waitForRetry',function()
    ShowWaiting.delete()
    tools.showMsgBox('提示', "网络连接失败，请重试")
    :next(function(btnName)
      -- if btnName == "enter" then
        local msg = {
          msgID = 'loginOnGate'
        }

        conn:send(msg)
      -- end
    end)
  end)

  conn:on('close',function()
    if self.hookClose then
      self.hookClose()
    else
      if self.auto then
        self.auto = nil
        app.conn:connect(self.host, self.port)
      else
        print("断开连接,立马尝试重连")
        tools.showMsgBox('提示', "网络连接断开")
        :next(function(btnName)
          print('btnName is ',btnName)
          -- if btnName == "enter" then
            app:switch('LoginController')
          -- end
        end)
      end
    end
  end)

  conn:on('GetGtServer',function(msg)
    dump(msg)
    self.host = msg.ip
    self.port = tonumber(msg.port)
    self.state = Net.C_GAME
    self.auto = true
    print('self.gateIP self.gatePort',self.host,self.port)
    print('gatePort type is ',type(self.gatePort))

    self.gateHost = self.host
    self.gatePort = self.port

    conn:close()
  end)

  conn:on('createPlayerSuccess',function(msg)
    ShowWaiting.delete()
    print('loginOnGate success')
    self.emitter:emit('connect')
  end)
end

function Net:setHookClose(call)
  self.hookClose = call
end

function Net:setHookOpen(call)
  self.hookOpen = call
end

function Net:connect2gate()
  local app = require("app.App"):instance()
  app.conn:connect(self.gateHost, self.gatePort)
end

function Net:connect()
  ShowWaiting.show()

  local app = require("app.App"):instance()
  self.host = config.host
  self.port = config.port
  self.state = Net.C_GATE
  app.conn:connect(config.host, config.port)
end

return Net
