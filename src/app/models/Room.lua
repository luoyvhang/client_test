local class = require('middleclass')
local HasSignals = require('HasSignals')
local Room = class('Room'):include(HasSignals)
local Scheduler = require('app.helpers.Scheduler')
local tools = require('app.helpers.tools')

function Room:initialize()
  HasSignals.initialize(self)
  local app = require("app.App"):instance()

  app.conn:on("listRooms",function(msg)
    self.emitter:emit('listRooms', msg.rooms)
  end)

  --普通房间
  app.conn:on("createRoom",function(msg)
    -- self.emitter:emit("createRoom", msg)
    if msg.errorCode then
      if msg.errorCode == 1 then
        tools.showRemind("钻石不足，无法开启房间")
      end
    else
      if msg.enterOnCreate == 1 then
        self:enterRoom(msg.deskId)
      end
    end
  end)

  --俱乐部房间
  app.conn:on("Group_createRoomResult",function(msg)
    if msg.code == -100 then
      tools.showRemind('管理员未开启群员创建房间功能')
    elseif msg.code == -2 then
      tools.showRemind('钻石不足，无法开启房间')
    elseif msg.code == -1 then
      tools.showRemind('群内钻石不足，无法开启房间')
    elseif msg.code == 1 then
      self:enterRoom(msg.roomInfo.deskId)
    end
  end)

  app.conn:on("Group_setRoomConfigResult",function(msg)
    dump(msg)
    self.emitter:emit('Group_setRoomConfigResult')
  end)

  app.conn:on("roomConfigFlag",function(msg)
    self.emitter:emit('roomConfigFlag',msg)
  end)

  app.conn:on("enterRoom",function(msg)
    if msg.errorCode then
      if msg.errorCode == 1 then
        tools.showRemind("房间人已满")
      elseif msg.errorCode == 3 then
        tools.showRemind("此房间不是买马房间")
      elseif msg.errorCode == 4 then
        tools.showRemind("您不庄房间所属的牛友群中")
      elseif msg.errorCode == 5 then
        local text = '您已在房间:'..msg.deskId..'\n 您之前参与的游戏尚未结束, 不能加入新的游戏'
        tools.showMsgBox("提示", text,1):next(function(btn)
	        if msg.deskId then
            local app = require("app.App"):instance()
		        local deskId = tostring(msg.deskId)
		        app.session.room:enterRoom(deskId)
	        end
        end)
      else
        tools.showRemind("房间号不存在")
      end
    else
      tools.showRemind("进入牌局")
      if msg.gameIdx == 16 then
        local qidong1 = app.session.qidong1
        qidong1:sitDown(msg.deskId, msg.buyHorse)
      elseif msg.gameIdx == 21 then
        local xiaoyao = app.session.xiaoyao
        xiaoyao:sitDown(msg.deskId, msg.buyHorse)
      elseif msg.gameIdx == 29 then
        local niumowang = app.session.niumowang
        niumowang:sitDown(msg.deskId, msg.buyHorse)
      elseif msg.gameIdx == 30 then
        print(' -> [ QZ ] niumowangqz ...')
        local niumowangqz = app.session.niumowangqz
        niumowangqz:sitDown(msg.deskId, msg.buyHorse)
      end
    end
  end)

  Scheduler.new(function(dt)
    self:update(dt)
  end)

  self.delay = 0
end

function Room:update(dt)
  self.delay = self.delay + dt

  if self.delay > 5 then
    self.delay = 0

    --self:doSync()
  end
end

function Room:doSync()
  local app = require("app.App"):instance()
  local msg = {
    msgID = 'checkGame'
  }

  print('&&&&&&&&& app.conn:send(msg) checkGame')
  app.conn:send(msg)
end

function Room:enterRoom(deskId, buyHorse)--luacheck:ignore
  local app = require("app.App"):instance()
  local msg = {
    msgID = 'enterRoom',
    deskId = deskId,
    buyHorse = buyHorse
  }
  app.conn:send(msg)
end

function Room:listRooms()--luacheck:ignore
  local app = require("app.App"):instance()

  local msg = {
    msgID = 'listRooms',
  }
  app.conn:send(msg)
end

function Room:createRoom(gameIdx, options, groupInfo)--luacheck:ignore
  local app = require("app.App"):instance()
  options.roomMode = 'normal'
  if groupInfo then
    local groupId = groupInfo.id
    if groupId then
      options.roomMode = groupInfo.roomMode
      options.scoreOption = groupInfo.scoreOption
      dump(options)
      local msg = {
        msgID = 'Group_createRoom',
        gameIdx = gameIdx,
        options = options,
        groupId = groupId,
      }
      app.conn:send(msg)
    end
  else
    local msg = {
      msgID = 'createRoom',
      gameIdx = gameIdx,
      options = options
    }
    -- dump(options)
    app.conn:send(msg)
  end
end

function Room:roomConfig(gameplay, options, groupInfo)
  local app = require("app.App"):instance()
  if groupInfo then
    local groupId = groupInfo.id
    if groupId then
      local msg = {
        msgID = 'Group_setRoomConfig',
        gameplay = gameplay,
        options = options,
        groupId = groupId,
      }
      app.conn:send(msg)
    end 
  end 
end

function Room:roomConfigFlag(groupInfo)
  local app = require("app.App"):instance()
  if groupInfo then
    local groupId = groupInfo.id
    if groupId then
      local msg = {
        msgID = 'Group_getRoomConfigFlag',
        groupId = groupId,
      }
      app.conn:send(msg)
    end 
  end 
end

function Room:quickStart(groupInfo, gameplay, gameIdx)
  local app = require("app.App"):instance()
  if groupInfo then
    local groupId = groupInfo.id
    if groupId then
      local roomMode = groupInfo.roomMode
      local scoreOption = groupInfo.scoreOption
      local msg = {
        msgID = 'Group_quickStart',
        groupId = groupId,
        gameplay = gameplay,
        gameIdx = gameIdx,
        roomMode = roomMode,
        scoreOption = scoreOption,
      }
      app.conn:send(msg)
    end 
  end 
end

function Room:enterGoldRoom()
  local app = require("app.App"):instance()

  local msg = {
    msgID = 'enterGoldRoom',
    gameIdx = 3
  }
  app.conn:send(msg)
end


return Room
