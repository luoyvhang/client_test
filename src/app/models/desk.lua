local class = require('middleclass')
local HasSignals = require('HasSignals')
local Desk = class("Desk"):include(HasSignals)
local ShowWaiting = require('app.helpers.ShowWaiting')
local cardHelper = require('app.helpers.card')

function Desk:initialize()
  HasSignals.initialize(self)

  self.playerCount = 3
  self.players = {}
  self.gameIdx = 16

  self.deskName = 'qidong1'
  self:listen()
end

function Desk:clearPlayers()
  self.players = {}
end

function Desk:getPlayersCount()
  local total = 0
  for i = 1,4 do
    if self.players[i] then
      total = total + 1
    end
  end

  return total
end

function Desk:disposeListens()
  if self.listens then
    for i = 1,#self.listens do
      self.listens[i]:dispose()
    end

    self.listens = nil
  end
end

function Desk:bindMsgHandles()
  local app = require("app.App"):instance()
  self:disposeListens()

  self.listens = {
    app.conn:on(self.deskName..'.dropLine',function(msg)
      local key = self:getPlayerPosKey(msg.uid)
      local _,player = self:getPlayerPos(msg.uid)
      if player and player.actor then
        player.actor.isLeaved = true
      end

      self.emitter:emit('dropLine',key)
    end),
    app.conn:on(self.deskName..'.enterHorse',function(msg)
      self.info.horse = msg.horse
      self.emitter:emit('enterHorse')
    end),
    app.conn:on(self.deskName..".somebodyPrepare",function(msg)
      print('call somebodyPrepare')

      local pos = self:getPlayerPos(msg.uid)
      local player = self:getPlayerByPos(pos)
      if player then
        player.actor.isPrepare = true
        self.emitter:emit('somebodyPrepare', pos)
      end
    end),
    app.conn:on(self.deskName..".somebodyLeave",function(msg)
      if not self.gameStart then
        local pos = self:getPlayerPos(msg.uid)
        if pos then
          self.players[pos] = nil
          self.emitter:emit('somebodyLeave')
        else
          local flg = self:isHorsePlayer(msg.uid)
          if flg then
            self.info.horse = nil
            self.emitter:emit('horseLeave')
          end
        end
      end
    end),
    app.conn:on('cancelTrusteeship',function()
      local me = self:getMe()
      me.hand.trusteeship = false

      print('&&&&&&& call response cancelTrusteeship')
    end),
    app.conn:on(self.deskName..".broke", function(msg)
      msg.pos = self:getPlayerPos(msg.uid)
      self.emitter:emit('broke', msg)
    end),
    app.conn:on(self.deskName..".youBaojiao", function(msg)
      self:youBaojiao(msg)
    end),
    app.conn:on(self.deskName..".somebodySitdown",function(msg)
      local pos

      local dif = msg.userData.chairIdx - self.players[1].chairIdx
      pos = dif < 0 and dif + self:getSitdownMode() or dif + 1
      self.players[pos] = self:initPlayer(msg.userData)

      self.emitter:emit('somebodySitdown',{pos = pos, userInfo = self.players[pos]})
      local key = self:getPlayerPosKey(msg.userData.actor.uid)
      local _,player = self:getPlayerPos(msg.userData.actor.uid)
      if player and player.actor then
        player.actor.isLeaved = false
      end

      self.emitter:emit('somebodyOnline',key)
    end),
    app.conn:on(self.deskName..'.played', function(msg)
      self:onPlaySuccess(msg)
    end),
    app.conn:on(self.deskName..'.someoneBaojiao',function(msg)
      self:someoneBaojiao(msg)
    end),
    app.conn:on(self.deskName..'.start', function(msg)
      self.gameStart = true
      self.dealted = nil
      self.info.banker = msg.banker
      self.info.played = true

      local key = self:getPlayerPosKey(msg.banker)
      self.emitter:emit('start',key)
    end),
    app.conn:on(self.deskName..'.horseBuy',function(msg)
      self.info.hBuy = msg.uid
      local key = self:getPlayerPosKey(msg.uid)
      self.emitter:emit('horseBuy',key)
    end),
    app.conn:on(self.deskName..'.deal', function(msg)
      self.emitter:emit('startDeal',msg)
    end),
    app.conn:on(self.deskName..'.allMiss', function(msg)
      self.emitter:emit('allMiss',msg)
    end),
    app.conn:on(self.deskName..'.turn', function(msg)
      --dump(msg)
      self.info.cardsCount = msg.cardsCount
      self:onMyTurn(msg)

      print('call onMyTurn&&&&&&&&')
    end),
    app.conn:on(self.deskName..'.current', function(msg)
      --dump(msg)
      self.info.cardsCount = msg.cardsCount
      self:onCurrent(msg)
    end),
    app.conn:on(self.deskName..'.dealt', function(msg)
      self:onDealt(msg)
    end),
    app.conn:on(self.deskName..'.peng',function(msg)
      self:onSomebodyPeng(msg)
    end),
    app.conn:on(self.deskName..'.gang',function(msg)
      self:onSomebodyGang(msg)
    end),
    app.conn:on(self.deskName..'.hu',function(msg)
      self:onSomebodyHu(msg)
    end),
    app.conn:on(self.deskName..'.exchange',function(msg)
      self:startExchange(msg)
    end),
    app.conn:on(self.deskName..'.exchangert',function(msg)
      self:somebodyExchange(msg)
    end),
    app.conn:on(self.deskName..'.getexchange',function(msg)
      self:onGetexchange(msg)
    end),
    app.conn:on(self.deskName..".missing", function(msg)--luacheck:ignore
      self.emitter:emit('missing')
    end),
    app.conn:on(self.deskName..'.miss',function(msg)
      self:freshMissSuit(msg)
    end),
    app.conn:on(self.deskName..'.action',function(msg)
      self:onAction(msg)
    end),
    app.conn:on(self.deskName..'.summary',function(msg)
      self:onSummary(msg)
    end),
    --app.conn:on(self.deskName..'.finalSummary',function(msg)
    --  self.emitter:emit(self.deskName..'.finalSummary',msg)
    --end),
    app.conn:on(self.deskName..'.overgame',function(msg)
      self:onSomebodyOvergame(msg)
    end),
    app.conn:on(self.deskName..'.overgameResult',function(msg)
      self.emitter:emit('overgameResult',msg)
    end),
    app.conn:on(self.deskName..'.qiangganghu',function(msg)
      dump(msg)
      self.emitter:emit('qiangganghu',msg)
    end),
    app.conn:on(self.deskName..'.beqianggang',function(msg)
      self:somebodyBeQiangGang(msg)
    end),
    app.conn:on(self.deskName..'.somebodyTrusteeship',function(msg)
      print('call somebodyTrusteeship &&&&& **** &&&& ')
      self:somebodyTrusteeship(msg)
    end)
  }

end

function Desk:initPlayer(data)
  local player = {}
  player.actor = data.actor
  self:initHand(player,data.hand)
  player.putCount = 0
  player.chairIdx = data.chairIdx
  return player
end

function Desk:listen()
  local app = require("app.App"):instance()

  if self.onSynDeskHandle then
    self.onSynDeskHandle:dispose()
    self.onSynDeskHandle = nil
  end

  self.onSynDeskHandle = app.conn:on(self.deskName..".synDeskData",function(msg)
      ShowWaiting.delete()
      self.info = msg.info
      dump(self.info)
      if self.info.state and self.info.state ~= 'prepare' then
        self.gameStart = true
      end

      if msg.myData then
        self.players[1] = self:initPlayer(msg.myData,true)
        dump(self.players[1])
        for _, v in pairs(msg.allUsers) do
          local dif = v.chairIdx - self.players[1].chairIdx
          local pos = dif < 0 and dif + self:getSitdownMode() or dif + 1
          self.players[pos] = self:initPlayer(v)
        end
      else
        for _, v in pairs(msg.allUsers) do
          self.players[v.chairIdx] = self:initPlayer(v)
        end
      end

      if self.onSyndeskCall then
        self.onSyndeskCall()
      else
        if self.customSwitch then
          self.customSwitch(self)
        else
          app:switch('DeskController',self.deskName)
        end
      end

      self:bindMsgHandles()
    end)
end

function Desk:setOnSyndeskHandel(call)
  self.onSyndeskCall = call
end

function Desk:somebodyTrusteeship(msg)
  if self:isMe(msg.uid) then
    local me = self:getMe()
    me.hand.trusteeship = true

    self.emitter:emit('trusteeship')
  end
end

function Desk:isHorsePlayer(uid)
  if self.info.horse then
    if self.info.horse.uid == uid then
      return true
    end
  end
end

function Desk:getPlayerByKey(key)
  if key == 'down' then
    return self:getMe()--self.players[1]
  elseif key == 'right' then
    return self:getRight()--self.players[2]
  elseif key == 'top' then
    return self:getTop()--self.players[3]
  elseif key == 'left' then
    return self:getLeft()--self.players[4]
  end
end

function Desk:getPlayerPosKey(uid)
  local maxPeople = self.info.deskInfo.maxPeople
  local pos = self:getPlayerPos(uid)

  if maxPeople == 4 then
    if pos == 1 then
      return 'down'
    elseif pos == 2 then
      return 'right'
    elseif pos == 3 then
      return 'top'
    elseif pos == 4 then
      return 'left'
    end
  else
    if pos == 1 then
      return 'down'
    elseif pos == 2 then
      return 'right'
    elseif pos == 3 then
      return 'left'
    end
  end
end

function Desk:getMe()
  return self.players[1]
end

function Desk:getRight()
  return self.players[2]
end

function Desk:getTop()
  local maxPeople = self.info.deskInfo.maxPeople
  if maxPeople == 4 then
    return self.players[3]
  end
end

function Desk:getLeft()
  local maxPeople = self.info.deskInfo.maxPeople
  if maxPeople == 4 then
    return self.players[4]
  else
    return self.players[3]
  end
end

function Desk:getPlayerByPos(pos)
  return self.players[pos]
end

function Desk:getInfo()
  return self.info
end


function Desk:getPlayerPos(uid)
  for i = 1,self.playerCount do
    local v = self.players[i]
    if v then
      if uid == v.actor.uid then
        return i,v
      end
    end
  end
end

function Desk:clear()
  self:disposeListens()
end

local suitweight = {
  ['筒'] = 0x10,
  ['条'] = 0x20,
  ['万'] = 0x30
}

local misswight = 0x30

function Desk:getCardTotalValue(value)
  local me = self:getMe()
  local misssuit = me.hand.misssuit

  local suit = cardHelper.suit(value)
  local point = cardHelper.rank(value)

  local total = suitweight[suit] + point

  if misssuit and misssuit == suit then
    total = total + misswight
  end

  return total
end

function Desk:setMeMissSuit(suit)
  local me = self:getMe()
  me.hand.misssuit = suit
end

function Desk:getMisssuit()
  local me = self:getMe()
  return me.hand.misssuit
end


function Desk:skip()--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.skip'
  }
  conn:send(msg)
end

function Desk:answer(answer)--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.overAction',
    result = answer
  }
  conn:send(msg)
end

function Desk:cancelTrusteeship()
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.cancelTrusteeship',
  }
  conn:send(msg)
end

function Desk:doExchange(cards)
  local me = self:getMe()
  local hand = me.hand.hand

  for r = 1,#cards do
    for i = 1,#hand do
      if hand[i] == cards[r] then
        table.remove(hand,i)
        break
      end
    end
  end

  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.exchange',
    cards = cards
  }
  dump(msg)
  conn:send(msg)
end


function Desk:doHu(card)--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.hu',
    card = card
  }
  conn:send(msg)
end

function Desk:pushVoiceCache(data)
  if not self.info.voiceList then
    self.info.voiceList = {}
  end

  self.info.voiceList[#self.info.voiceList+1] = data
end

function Desk:play(card)
  local me = self:getMe()
  local actor = me.actor
  local cacheMsg = actor.cacheMsg
  if cacheMsg.msgID == self.deskName..'.current' then
    actor.cacheMsg = nil
  end

  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.play',
    card = card
  }

  conn:send(msg)
end

function Desk:doGang(card)--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.gang',
    card = card
  }
  conn:send(msg)
end

function Desk:doPeng(card)--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.peng',
    card = card
  }
  conn:send(msg)
end

function Desk:startGame()--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.prepare',
  }

  conn:send(msg)
end

function Desk:missSuit(suit)--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.miss',
    suit = suit
  }

  conn:send(msg)
end

function Desk:prepare()--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.prepare'
  }

  conn:send(msg)
end

function Desk:quit()--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.leaveRoom'
  }
  conn:send(msg)
end

function Desk:onDealt(msg)
  if self.dealted then return end
  self.dealted = true

  local me = self:getMe()

  if msg.hand then
    me.hand = msg.hand
  end

  local others = msg.other
  for i = 1,#others do
    local other = others[i]
    local uid = other.uid

    local _,player = self:getPlayerPos(uid)
    if player then
      self:initHand(player,other)
    end
  end

  self.info.cardsCount = msg.cardsCount
  self.emitter:emit('dealt')
end

function Desk:initHand(player,hand)--luacheck:ignore
  player.hand = hand
  if player.hand and player.hand.total then
    if hand.new then
      player.hand.total = player.hand.total - 1
    end
  end
end

function Desk:sitDown(deskId, buyHorse)--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.sitdown',
    gameIdx = self.gameIdx,
    deskId = deskId,
    buyHorse = buyHorse,
  }

  dump(msg)

  conn:send(msg)
end

function Desk:onCanPeng(msg)
  self.emitter:emit('canpeng',msg)
end

function Desk:onAction(msg)
  self.emitter:emit('action',msg)
end

function Desk:onSomebodyHu(msg)
  local key = self:getPlayerPosKey(msg.uid)

  local targetKey
  if msg.tuid then
    targetKey = self:rmLastOfPutList(msg.tuid)
  end

  self.emitter:emit('somebodyHu',key,msg,targetKey)
end

function Desk:haveNew()
  local me = self:getMe()
  return me.hand.new ~= nil
end

function Desk:getLeftCardCount(card)
  local total = 0

  for i = 1,#self.players do
    local player = self.players[i]
    local putlist = player.hand.putlist

    for p = 1,#putlist do
      if putlist[p] == card then
        total = total + 1
      end
    end

    local pg = player.hand.pg
    for g = 1,#pg do
      local  group = pg[g]

      for c = 1,#group do
        if group[c] == card then
          total = total + 1
        end
      end
    end
  end

  local me = self:getMe()
  local hand = me.hand.hand

  -- 遍历手牌
  for i = 1,#hand do
    if hand[i] == card then
      total = total + 1
    end
  end

  if me.hand.new and me.hand.new == card then
    total = total + 1
  end

  return 4 - total
end

function Desk:somebodyBeQiangGang(msg)
  local card = msg.card
  local _,player = self:getPlayerPos(msg.uid)
  if player then
    local pg = player.hand.pg
    local pgMeta = player.hand.pgMeta

    for i = 1,#pg do
      local group = pg[i]
      local meta = pgMeta[i]
      local match = false

      if meta.type == 'gang' then
        local find = -1
        for g = 1,#group do
          if group[g] == card then
            find = g
            match = true
            break
          end
        end

        if find ~= -1 then
          meta.type = 'peng'
          table.remove(group,find)
        end
      end

      if match then
        break
      end
    end
  end

  local key = self:getPlayerPosKey(msg.uid)
  local isMe = self:isMe(msg.uid)
  self.emitter:emit('beqianggang',msg,key,isMe,player)
end

function Desk:onSomebodyGang(msg)
  local uid = msg.uid
  local _,player = self:getPlayerPos(uid)
  local isMe = self:isMe(uid)
  local isInPG = false
  local targetKey = self:rmLastOfPutList(msg.tuid)
  local newcard
  local backs = {}

  if player then
    local find = false
    -- 杠的是手中已经有的碰过的牌了
    for i = 1,#player.hand.pg do
      local meta = player.hand.pgMeta[i]
      if meta.type == 'peng' then
        local tfind = false
        for c = 1,#player.hand.pg[i] do
          if player.hand.pg[i][c] == msg.hit then
            tfind = true
            break
          end
        end

        if tfind then
          player.hand.pg[i][#player.hand.pg[i]+1] = msg.hit
          find = true
          isInPG = true
          -- 把类型变成杠，同时设置明杠为真
          meta.type = 'gang'
          meta.mg = true
          meta.isNew = true
          break
        end
      end
    end

    if not find then
      local meta = self:pushPG(player,msg.tb.cards,'gang',msg.tb.mg)
      meta.isNew = true
    end
  end

  if isMe then
    if player.hand.new then
      -- add this to hand
      player.hand.hand[#player.hand.hand+1] = player.hand.new
      newcard = player.hand.new
      player.hand.new = nil
    end

    -- 删除所有的杠牌
    for i = 1,#msg.tb.cards do
      backs[#backs+1] = msg.tb.cards[i]
    end

    self:rmCardsFromHand(player.hand.hand,msg.tb.cards)
  else
    player.hand.total = player.hand.total + 1
    dump(msg)
  end

  local key = self:getPlayerPosKey(uid)
  self.emitter:emit('somebodyGang',player,key,isMe,backs,isInPG,targetKey,newcard)
end

function Desk:rmLastOfPutList(uid)
  local _,target = self:getPlayerPos(uid)
  local targetKey = self:getPlayerPosKey(uid)
  if target then
    table.remove(target.hand.putlist,#target.hand.putlist)
  end

  return targetKey
end

function Desk:rmCardsFromHand(hand,cards)--luacheck:ignore
  for d = #cards,1,-1 do
    for i = #hand,1,-1 do
      if hand[i] == cards[d] then
        table.remove(hand,i)
        table.remove(cards,d)
        break
      end
    end
  end
end

function Desk:pushPG(player,cards,type,mg)--luacheck:ignore
  player.hand.pg[#player.hand.pg+1] = cards

  local meta = {
    type = type,
    mg = mg
  }

  if not player.hand.pgMeta then player.hand.pgMeta = {} end
  player.hand.pgMeta[#player.hand.pgMeta+1] = meta
  return meta
end

function Desk:onSomebodyPeng(msg)
  local uid = msg.uid
  local _,player = self:getPlayerPos(uid)
  local isMe = self:isMe(uid)
  local targetKey = self:rmLastOfPutList(msg.tuid)

  if player then
    local meta = self:pushPG(player,msg.tb.cards,'peng')
    meta.isNew = true
  end

  local backs = {}
  if isMe then
    local hand = player.hand.hand

    -- 删除命中的牌
    for i = 1,#msg.tb.cards do
      if msg.tb.cards[i] == msg.hit then
        table.remove(msg.tb.cards,i)
        break
      end
    end

    for i = 1,#msg.tb.cards do
      backs[#backs+1] = msg.tb.cards[i]
    end

    --从手牌中删除当前碰出去的牌
    self:rmCardsFromHand(hand,msg.tb.cards)
  end

  local key = self:getPlayerPosKey(uid)
  self.emitter:emit('somebodyPeng',player,key,isMe,backs,targetKey)
end


function Desk:onCurrent(msg)
  local key = self:getPlayerPosKey(msg.uid)
  if key then
    if self:isMe(msg.uid) then
      local me = self:getMe()
      me.actor.cacheMsg = msg
    end

    self.emitter:emit('chgCurrent',msg)
  end
end

--[[
function Desk:onMyTurn(msg)
  local me = self:getMe()
  me.actor.cacheMsg = msg
  --dump(me.actor.cacheMsg)

  if msg.card then
    me.hand.new = msg.card
  end
  self.emitter:emit('yourturn',msg)
end]]

function Desk:isMe(uid)
  --if self:isHorse() then return false end
  return self.players[1].actor.uid == uid
end

function Desk:someoneBaojiao(msg)
  dump(msg)

  if self:isMe(msg.uid) then
    local me = self:getMe()
    me.hand.cacheBaojiaoAct = msg.act
    print('me.hand.cacheBaojiaoAct is ',me.hand.cacheBaojiaoAct)
  end
end

function Desk:onPlaySuccess(msg)
  local _,data = self:getPlayerPos(msg.uid)
  if not data then return end

  data.hand.putlist[#data.hand.putlist+1] = msg.card

  if self:isMe(msg.uid) then
    local me = self:getMe()
    if me.actor.cacheMsg and me.actor.cacheMsg.msgID == self.deskName..'.current' then
      me.actor.cacheMsg = nil
    end

    self.emitter:emit('onPlaySuccess',msg)
  else
    local uid = msg.uid
    local key = self:getPlayerPosKey(uid)
    self.emitter:emit('otherPlayed',key,msg.card)
  end
end

function Desk:doBaoJiao(baoAct)
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.baojiao',
    baoAct = baoAct
  }
  dump(msg)
  conn:send(msg)

  self.waitBaoJiaoResult = true
end

function Desk:youBaojiao(msg)
  local me = self:getMe()
  me.hand.limitPuts = msg.limitPuts
  dump(me.hand.limitPuts)
  self.emitter:emit('limitPuts',me.hand.limitPuts)
  self.waitBaoJiaoResult = nil
end

function Desk:isCanPutCard()
  local me = self:getMe()
  local actor = me.actor
  local cacheMsg = actor.cacheMsg
  if cacheMsg and cacheMsg.msgID == self.deskName..'.current' and cacheMsg.card == nil then
    return true
  end

  return false
end


function Desk:isGamestart()
  return self.gameStart
end

function Desk:onSummary(msg)
  self.gameStart = nil

  if self.info.number then
    self.info.number = self.info.number + 1
  end

  self.dealted = nil

  for i = 1,4 do
    local player = self.players[i]
    if player then
      if player.actor then
        player.actor.isPrepare = false
        player.actor.cacheMsg = nil
      end

      player.hand = nil
    end
  end
  self.emitter:emit('summary',msg)

  for k,v in pairs(msg.data) do
    local uid = k
    local _,player = self:getPlayerPos(uid)
    if player then
      player.actor.money = v.money
    end
  end
end

function Desk:dismiss()--luacheck:ignore
  local app = require("app.App"):instance()
  local conn = app.conn
  local msg = {
    msgID = self.deskName..'.overgame'
  }
  conn:send(msg)
end

function Desk:getSitdownMode()
  return self.info.deskInfo.maxPeople + 1
end

function Desk:onSomebodyOvergame(msg)
  self.info.apply = msg.data
  self.emitter:emit('overgame',msg)
end

return Desk
