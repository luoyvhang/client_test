local class = require('middleclass')
local HasSignals = require('HasSignals')
local Connection = class('Connection'):include(HasSignals)
local cjson = require('cjson')
local net = require('net')

function Connection:onConnected(ip,port)
  if not self:isConnected(ip,port) then
    local entry = {}
    entry.ip = ip
    entry.port = port

    self.allConnects[#self.allConnects + 1] = entry
  end

  self.emitter:emit('open',ip,port)

  if self.rcall then
    self.rcall(ip,port)
    self.rcall = nil
  end
end

function Connection:rmConn(ip,port)
  for i = #self.allConnects,1,-1 do
    local conn = self.allConnects[i]
    if conn.ip == ip and conn.port == port then
      print('rmConn',ip,port)
      table.remove(self.allConnects,i)
    end
  end
end

function Connection:onClose(ip,port)
  self:rmConn(ip,port)

  self.emitter:emit('close',self.initiativeClose,ip,port)
  self.initiativeClose = nil
end

function Connection:onMessage(data,mainID,subID)
  if data then
    local msg = cjson.decode(data)
    if msg then
      local msgID = msg.msgID
      self.emitter:emit(msgID, msg)
    else
      print('error by cjson decode data mainid subID',data,mainID,subID)
    end
  end
end

function Connection:initialize(host, port)
  HasSignals.initialize(self)
  self.allConnects = {}
  --self.defaultIp = '127.0.0.1'
  --self.defaultPort = 9999

  local ws = net.Socket(function(code,...)
    if code == 'connect' then

      self:onConnected(...)
    elseif code == 'close' then
      print("close *********************")
      self:onClose(...)
    elseif code == 'error' then
      print("error *********************")
      self:onClose(...)
    elseif code == 'message' then
      self:onMessage(...)
    end
  end)

  self.ws = ws
end

function Connection:changeDefaultIpPort(ip,port)
  self.defaultIp = ip
  self.defaultPort = port
end

function Connection:connect(host, port, rcall)
  self.host = host
  self.port = tonumber(port)
  self.rcall = rcall

  self.ws:connect(host,port)
  self:changeDefaultIpPort(host,port)
end

function Connection:isConnected(ip,port)
  for i = 1,#self.allConnects do
    local conn = self.allConnects[i]
    if conn.ip == ip and conn.port == port then
      return true
    end
  end
end

function Connection:send(msg)
  local main = 99
  local sub = 99
  local ip = self.defaultIp
  local port = self.defaultPort

  if not self:isConnected(ip,port) then
      print("Connection:send() - socket isn't ready")
      return false
  end
  --print("^^^^^^^^^^",ip,port)
  --dump(msg)
  local binary = assert(cjson.encode(msg))
  self.ws:write(binary,main,sub,ip,port)
end

function Connection:close(ip,port)
  if ip == nil or port == nil then
    ip = self.defaultIp
    port = self.defaultPort
  end
  self.initiativeClose = true
  self.ws:done(ip,port)
end


return Connection
