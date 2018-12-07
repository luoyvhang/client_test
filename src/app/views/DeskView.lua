local Scheduler = require('app.helpers.Scheduler')
local HeartbeatCheck = require('app.helpers.HeartbeatCheck')
local cardHelper = require('app.helpers.card')

local DeskView = {}
local enable_debug = false
local MAX_COLS = 10

local all_side_keys = {
  'down',
  'right',
  'left',
  'top'
}

function DeskView:initialize()--luacheck: ignore
  self.state = 'none'
  self:enableNodeEvents()

  self.heartbeatCheck = HeartbeatCheck()

  self.updateF = Scheduler.new(function(dt)
    self:update(dt)
  end)
end

function DeskView:onExit()
  if self.updateF then
    Scheduler.delete(self.updateF)
    self.updateF = nil
  end
end

function DeskView:update(dt)
  self:checkState()

  if self.state and self['update'..self.state] then
    self['update'..self.state](self,dt)
  end

  self:sendHeartbeatMsg(dt)
end

function DeskView:onPing()
  self.heartbeatCheck:onPing()
end

function DeskView:sendHeartbeatMsg(dt)
  if not self.pauseHeartbeat then
    self.heartbeatCheck:update(dt)
  end
end

function DeskView:setState(state)
  self.next = state
end

function DeskView:checkState()
  if self.next ~= self.state then
      if self['onOut'..self.state] then
        self['onOut'..self.state](self,self.state)
      end

      self.state = self.next

      if self.state and self['onEnter'..self.state] then
        self['onEnter'..self.state](self,self.state)
      end
    end
end

function DeskView:layout(desk)
  self.desk = desk

  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setPosition(display.cx,display.cy)
  self.MainPanel:setContentSize(cc.size(display.width,display.height))

  self.bg = self.MainPanel:getChildByName('bg')
  self.bg:setPosition(display.cx,display.cy)
  self.bg:setContentSize(cc.size(display.width,display.height))

  local logo = self.bg:getChildByName('logo')
  logo:setPosition(display.cx,display.cy)

  local LeftCardPanel = self.MainPanel:getChildByName('LeftCardPanel')
  LeftCardPanel:setPosition(display.cx,display.height-200)
  self.LeftCardPanel = LeftCardPanel

  self.preparePanel = self.MainPanel:getChildByName('preparePanel')
  self.preparePanel:setPosition(display.cx,display.cy)

  self.ActionPanel = self.MainPanel:getChildByName('ActionPanel')
  self.ActionPanel:setPosition(display.cx,display.cy)
  self.ActionPanel:hide()
  self.ActionPanel:setItemModel(self.ActionPanel:getItem(0))
  self.ActionPanel:removeAllItems()

  self.HintPanel = self.MainPanel:getChildByName('HintPanel')
  self.HintPanel:setPosition(display.cx,display.cy+50)
  self.HintPanel:setItemModel(self.HintPanel:getItem(0))
  self.HintPanel:removeAllItems()
  self.HintPanel:setScrollBarEnabled(false)
  self.HintPanel:hide()

  self:layoutSides()

  self:initLeftCards()
  self:createHandGrids()
end

function DeskView:showHintPanle(action,data,callback)
  dump(action)
  dump(data)

  self.HintPanel:removeAllItems()
  self.HintPanel:show()
  for i = 1,#action do
    self.HintPanel:pushBackDefaultItem()
    local item = self.HintPanel:getItem(i-1)
    local model = item:getChildByName('model')
    local group = action[i]
    for g = 1,#group do
      local card
      if g == 1 then
        card = model
      else
        card = model:clone()
        item:addChild(card)
        card:setPositionY((g-1)*50)
      end

      local path = self:getPathByValue(group[g])
      card:loadTexture(path)

      if group[g] == data then
        card:setColor(cc.c3b(200,200,200))
      end
    end

    item:addClickEventListener(function()
      if callback then
        callback(action[i],i)
      end
    end)
  end
end

function DeskView:showActionPanel(msg)
  dump(msg.action)

  self.ActionPanel:removeAllItems()
  self.ActionPanel:show()

  local idx = 0
  local function push()
    self.ActionPanel:pushBackDefaultItem()
    local item = self.ActionPanel:getItem(idx)
    idx = idx + 1

    return item
  end

  for k,v in pairs(msg.action) do
    if k == 'pList' then
      local item = push()
      local icon = item:getChildByName('icon')
      icon:loadTexture('views/desk/peng.png')
    elseif k == 'cList' then
      local item = push()
      local icon = item:getChildByName('icon')
      icon:loadTexture('views/desk/chi.png')

      item:addClickEventListener(function()
        self:showHintPanle(v,msg.action.cCard,function(action,index)
          print('action is ')
          dump(action)
          print('index is ',index)
        end)
      end)
    elseif k == 'hList' then
      local item = push()
      local icon = item:getChildByName('icon')
      icon:loadTexture('views/desk/hu.png')
    end
  end

  local skip = push()
  skip:addClickEventListener(function()
    self.emitter:emit('skip')
  end)

  self.ActionPanel:visit()
  local inner = self.ActionPanel:getInnerContainerSize()
  self.ActionPanel:setContentSize(inner)
end

function DeskView:hideActionPanel()
  self.ActionPanel:hide()
  self.ActionPanel:setContentSize(cc.size(118,118))
end

function DeskView:layoutSides()
  for i = 1,#all_side_keys do
    local key = all_side_keys[i]
    local panel = self.MainPanel:getChildByName(key)

    if panel then
      local head = panel:getChildByName('head')
      head.pos = cc.p(head:getPosition())

      local pg = panel:getChildByName('pg')
      pg.model = pg:getChildByName('item')
      pg.model:hide()

      local put = panel:getChildByName('put')
      put.model = put:getChildByName('card')
      put.model:hide()
    end
  end
end

local head_pos_in_prepare_state = {
  ['left'] = cc.p(100,display.cy+80),
  ['right'] = cc.p(display.width-100,display.cy+80),
  ['down'] = cc.p(display.cx,150),
  ['top'] = cc.p(display.cx,display.height-100),
}

function DeskView:onEnterrunning()
  for i = 1,#all_side_keys do
    local key = all_side_keys[i]

    local panel = self.MainPanel:getChildByName(key)
    if panel then
      panel:getChildByName('pg'):show()
      panel:getChildByName('put'):show()
      panel:getChildByName('t0'):show()
      panel:getChildByName('huxi'):show()
      panel:getChildByName('t1'):show()

      if key == 'down' then
        local hand = panel:getChildByName('checkArea'):getChildByName('hand')
        if hand then
          hand:show()
        end
      end

      local head = panel:getChildByName('head')
      head:setPosition(head.pos)
      head:show()

      head:getChildByName('state'):hide()
    end
  end

  self.LeftCardPanel:show()
  self.preparePanel:hide()
end

function DeskView:onEnterprepare()
  for i = 1,#all_side_keys do
    local key = all_side_keys[i]

    local panel = self.MainPanel:getChildByName(key)
    if panel then
      panel:getChildByName('pg'):hide()
      panel:getChildByName('put'):hide()
      panel:getChildByName('t0'):hide()
      panel:getChildByName('huxi'):hide()
      panel:getChildByName('t1'):hide()

      if key == 'down' then
        local hand = panel:getChildByName('checkArea'):getChildByName('hand')
        if hand then
          hand:hide()
        end
      end

      local head = panel:getChildByName('head')
      local world = head_pos_in_prepare_state[key]
      local pos = head:getParent():convertToNodeSpace(world)
      head:setPosition(pos)
      head:show()
    end
  end

  local down = self.MainPanel:getChildByName('down')
  down:getChildByName('clock'):hide()

  self.LeftCardPanel:hide()
  self:freshPrepareUI()
end

local ROWS = 4
local COLS = MAX_COLS

function DeskView:calcPosByXY(col,row)
  local x = (col - 1) * self.cw
  local y = (row - 1) * self.ch

  return x,y
end

function DeskView:createHandGrids()
  local down = self.MainPanel:getChildByName('down')
  local hand = down:getChildByName('checkArea'):getChildByName('hand')
  local size = hand:getContentSize()

  local cw = size.width / COLS
  local ch = size.height / ROWS

  self.cw = cw
  self.ch = ch

  down.grids = {}

  -- 默认创建10列
  for x = 1,MAX_COLS do
    down.grids[x] = {}
  end

  for x = 1,COLS do
    for y = 1,ROWS do
      local layer
      if enable_debug then
        layer = cc.LayerColor:create(cc.c4b(100,0,0,128),cw,ch)
      else
        layer = cc.Layer:create()
        layer:setContentSize(cc.size(cw,ch))
      end

      hand:addChild(layer)
      layer:setPosition(self:calcPosByXY(x,y))
      layer:setLocalZOrder(-y)

      layer.x = x
      layer.y = y
      layer.cw = cw
      layer.ch = ch
      layer.zorder = -y
      layer.pos = cc.p(layer:getPosition())

      down.grids[x][#down.grids[x]+1] = layer

      if enable_debug then
        local label = cc.Label:createWithTTF('['..x..':'..y..']','views/font/fangzheng.ttf',28, cc.size(620,0),cc.TEXT_ALIGNMENT_CENTER)
        layer:addChild(label)
        label:setPosition(cw/2,10)
        label:setColor(cc.c3b(0,0,0))
        label:setLocalZOrder(1)

        layer.label = label
      end
    end
  end

  hand:addTouchEventListener(function(sender,type)
    self:onTouchHandPanle(sender,type)
  end)
end

function DeskView:dump()
  local down = self.MainPanel:getChildByName('down')
  for x = 1,COLS do
    for y = 1,ROWS do
      local grid = down.grids[x][y]
      if grid.card then
        print('------',x,y)
        print(grid.card.ref.x,grid.card.ref.y)
      end
    end
  end
end

function DeskView:changeCard(grid,value)--luacheck:ignore
  if grid.card then
    grid.card:release()
    grid.card = nil
  end

  grid.card = value

  if grid.card then
    local world = grid.card:getParent():convertToWorldSpace(cc.p(grid.card:getPosition()))
    grid.card:retain()

    grid.card:removeFromParent()
    grid:addChild(grid.card)
    grid.card:setPosition(grid:convertToNodeSpace(world))

    grid.card.ref = grid
  end
end

function DeskView:clearDesk()
  local down = self.MainPanel:getChildByName('down')

  for x = 1,COLS do
    for y = 1,ROWS do
      local grid = down.grids[x][y]
      if grid.card then
        grid.card:removeFromParent()
        grid.card:release()
      end

      grid.card = nil
    end
  end

  self:setFocus(nil)
end

function DeskView:bindCard(grid,value)
  local path = self:getPathByValue(value)
  local card = cc.Sprite:create(path)
  grid:addChild(card)
  card:setPosition(self.cw/2,self.ch/2)
  card:setScale(0.8)
  grid.card = card
  grid.card:retain()

  -- 引用的是哪张卡
  card.ref = grid
  card.path = path
  card.value = value
end

function DeskView:checkColIsEmpty(cols)--luacheck:ignore
  for i = 1,#cols do
    if cols[i].card ~= nil then
      return false
    end
  end

  return true
end

function DeskView:getColsCount(cols)--luacheck:ignore
  local total = 0
  for i = 1,#cols do
    if cols[i].card ~= nil then
      total = total + 1
    end
  end

  return total
end

function DeskView:getRightEmptyCol()
  local down = self.MainPanel:getChildByName('down')

  local ret_col
  for c = MAX_COLS,1,-1 do
    local cols = down.grids[c]
    local flg = self:checkColIsEmpty(cols)
    if flg then
      ret_col = c
    else
      break
    end
  end

  return ret_col
end

function DeskView:checkSwapOrBack2OrgPos(world)
  local down = self.MainPanel:getChildByName('down')
  if not down.focus then return end

  local checkArea = down:getChildByName('checkArea')
  local hand = checkArea:getChildByName('hand')
  local handSize = hand:getContentSize()
  local hand_x = hand:getPositionX()

  local size = checkArea:getContentSize()
  local rect = cc.rect(0,0,size.width,size.height)
  local pos = checkArea:convertToNodeSpace(world)
  local in_checkArea = false

  if cc.rectContainsPoint(rect,pos) then
    in_checkArea = true
  end

  local processed = false
  local hand_left_x = hand_x - handSize.width / 2
  local hand_right_x = hand_left_x + handSize.width
  local right_empty_col = self:getRightEmptyCol()
  local is_put_card_action = pos.y > checkArea:getContentSize().height

  local pgrid = self:pickCard(world)
  if pgrid then
    print('pgrid.x is ',pgrid.x)
  end
  print('right_empty_col is ',right_empty_col)
  local cur_col_idx = down.focus.ref.x
  local cur_col = down.grids[cur_col_idx]
  local cur_col_cnt = self:getColsCount(cur_col)

  local function move2FillGap()
    if not right_empty_col then
      right_empty_col = MAX_COLS
    end

    for i = cur_col_idx,right_empty_col do
      local cols = down.grids[i]
      local next_cols = down.grids[i + 1]
      if next_cols then
        for r = 1,#cols do
          local grid = cols[r]
          local next_grid = next_cols[r]

          self:changeCard(grid,next_grid.card)
          self:changeCard(next_grid,nil)
        end
      end
    end
  end

  local function checkNeedDrop(tcur_col)
    for r = 1,#tcur_col do
      local grid = tcur_col[r]
      local pre = tcur_col[r - 1]
      if grid.card then
        if pre and pre.card == nil then
          self:changeCard(pre,grid.card)
          self:changeCard(grid,nil)
        end
      end
    end
  end

  if in_checkArea then
    if pos.x < hand_left_x and down.focus.ref.x > 1 then
      local last = down.grids[MAX_COLS]
      local flg1 = self:checkColIsEmpty(last)

      if cur_col_cnt == 1 or flg1 then
        -- 清除当前位置的card
        self:changeCard(down.focus.ref,nil)

        -- 当前这一列是否需要落下来
        checkNeedDrop(cur_col)

        local last_col = MAX_COLS-1
        if cur_col_cnt == 1 then
          last_col = down.focus.ref.x-1
        end

        for i = last_col,1,-1 do
          local cols = down.grids[i]
          local next_cols = down.grids[i + 1]

          for r = 1,#cols do
            local grid = cols[r]
            local next_grid = next_cols[r]

            self:changeCard(next_grid,grid.card)
            self:changeCard(grid,nil)
          end
        end

        self:changeCard(down.grids[1][1],down.focus)

        self:dump()
        self:freshGridsPos()
        processed = true
      end
    elseif right_empty_col and (pos.x > hand_right_x or (pgrid and pgrid.x >= right_empty_col)) then
      print('click right side')

      if right_empty_col <= MAX_COLS then
        -- 清除当前位置的card
        self:changeCard(down.focus.ref,nil)
        self:changeCard(down.grids[right_empty_col][1],down.focus)
        -- 当前这一列是否需要落下来
        checkNeedDrop(cur_col)

        -- 有缺口
        if cur_col_cnt == 1 then
          move2FillGap()
        end

        self:freshGridsPos()

        processed = true
      end
    end
  end

  local function restore()
    if down.focus then
      local tworld = down.focus:getParent():convertToWorldSpace(cc.p(down.focus:getPosition()))
      down.focus:removeFromParent()
      down.focus.ref:addChild(down.focus)
      down.focus:setPosition(down.focus.ref:convertToNodeSpace(tworld))

      local nodepos = cc.p(self.cw/2,self.ch/2)
      local mv = cc.MoveTo:create(0.1,nodepos)
      down.focus:runAction(mv)
    end
  end

  if not processed then
    if not pgrid then
      local ok = false
      if is_put_card_action then
        if self.desk:isCanPutCard() then
          ok = true

          local ref = down.focus.ref
          local put_card = down.focus
          local value = down.focus.value
          self.emitter:emit('play',value,function(msg)--luacheck:ignore
            -- 清除当前位置的card
            self:changeCard(ref,nil)

            -- 当前这一列是否需要落下来
            checkNeedDrop(cur_col)

            -- 有缺口
            if cur_col_cnt == 1 then
              move2FillGap()
            end

            self:freshGridsPos()
            put_card:removeFromParent()
            self:onSidePlayed('down')
          end)
        end
      end

      if not ok then
        restore()
      end
    else
      if pgrid.x ~= down.focus.ref.x then
        local col = down.grids[pgrid.x]
        local cnt = self:getColsCount(col)
        if cnt >= 3 then
          restore()
        else
          self:changeCard(down.focus.ref,nil)

          -- 当前这一列是否需要落下来
          checkNeedDrop(cur_col)

          local find
          for r = ROWS,1,-1 do
            local grid = col[r]
            if grid.card == nil then
              find = r
            else
              break
            end
          end

          self:changeCard(col[find],down.focus)
          if cur_col_cnt == 1 then
            move2FillGap()
          end

          self:freshGridsPos()
        end
      elseif math.abs(pgrid.y - down.focus.ref.y) == 1 then
        -- swap
        local ref = down.focus.ref
        local pCard = pgrid.card

        self:changeCard(pgrid,down.focus)
        self:changeCard(ref,pCard)

        self:freshGridsPos()
      else
        restore()
      end
    end
  end

  self:setFocus(nil)
end

function DeskView:onSidePlayed(side)
  local panel = self.MainPanel:getChildByName(side)
  local put = panel:getChildByName('put')
  local player = self.desk:getPlayerByKey(side)
  if player then
    local putlist = player.hand.putlist
    if #putlist > 0 then
      local index = #putlist

      local last = putlist[index]
      local card = put.model:clone()
      card:show()
      put:addChild(card)

      local size = put:getContentSize()

      local cardSize = card:getContentSize()
      card:setPosition(cardSize.width/2 + (index-1) * cardSize.width,size.height/2)
      local path = self:getPathByValue(last)
      card:loadTexture(path)
    end
  end
end

function DeskView:freshGridsPos()
  local down = self.MainPanel:getChildByName('down')

  for x = 1,COLS do
    for y = 1,ROWS do
      local grid = down.grids[x][y]
      if grid and grid.card then
        grid.card:stopAllActions()

        local mv = cc.MoveTo:create(0.2,cc.p(self.cw/2,self.ch/2))
        grid.card:runAction(cc.Sequence:create(mv,cc.CallFunc:create(function()
          if enable_debug then
            grid.label:setString('['..grid.x..':'..grid.y..']')
          end

          grid:setLocalZOrder(grid.zorder)
        end)))
      end
    end
  end
end

function DeskView:moveCard(world)
  local down = self.MainPanel:getChildByName('down')
  if down.focus == nil then
    return
  end

  local pos = down.focus:getParent():convertToNodeSpace(world)
  down.focus:setPosition(pos)
end

function DeskView:findFocus(world)
  local layer = self:pickCard(world)
  if layer and layer.card then
    self:setFocus(layer.card)
  end
end

function DeskView:freshPrepareUI()
  self:freshSidesInfo()
end

function DeskView:freshSidesInfo()
  for i = 1,#all_side_keys do
    local key = all_side_keys[i]

    local panel = self.MainPanel:getChildByName(key)
    if panel then
      local player = self.desk:getPlayerByKey(key)

      local head = panel:getChildByName('head')
      local state = head:getChildByName('state')
      local icon = head:getChildByName('icon')
      local frame = head:getChildByName('frame')
      local nickName = frame:getChildByName('nickName')
      local score = frame:getChildByName('score')

      score:hide()
      icon:hide()
      state:hide()

      if player then
        if player.actor.isPrepare then
          state:show()
        end
        score:show()

        score:setString('积分: '..player.actor.money)
        nickName:setString(player.actor.nickName)
      else
        nickName:setString('等待中...')
      end
    end
  end
end

function DeskView:pickCard(world,exclude)
  local down = self.MainPanel:getChildByName('down')

  for x = 1,COLS do
    for y = 1,ROWS do
      local grid = down.grids[x][y]
      if grid ~= exclude then
        local size = grid:getContentSize()
        local rect = cc.rect(0,0,size.width,size.height)

        local pos = grid:convertToNodeSpace(world)
        if cc.rectContainsPoint(rect,pos) then
          print('click ',x,y)
          return grid
        end
      end
    end
  end
end

function DeskView:setFocus(focus)
  local down = self.MainPanel:getChildByName('down')
  if down.focus == focus then
    return
  end

  if down.focus then
    down.focus:release()
    down.focus = nil
  end

  down.focus = focus

  if down.focus then
    down.focus:retain()
    local world = down.focus:getParent():convertToWorldSpace(cc.p(down.focus:getPosition()))

    down.focus:removeFromParent()
    down:addChild(down.focus)
    down.focus:setPosition(down:convertToNodeSpace(world))
  end
end

function DeskView:onTouchHandPanle(sender,type)
  if type == 0 then
    -- began
    local pos = sender:getTouchBeganPosition()
    self:findFocus(pos)
  elseif type == 1 then
    -- move
    local pos = sender:getTouchMovePosition()
    self:moveCard(pos)
  else
    -- ended
    local pos = sender:getTouchEndPosition()
    self:checkSwapOrBack2OrgPos(pos)
  end
end

function DeskView:initLeftCards(leftCard)
  if not leftCard then
    leftCard = 20
  end

  local box = self.LeftCardPanel:getChildByName('box')
  local boxSize = box:getContentSize()

  local title = self.LeftCardPanel:getChildByName('title')

  local y = 28
  for _ = 1,leftCard do
    local spr = cc.Sprite:create('views/desk/fapai.png')
    spr:setPosition(boxSize.width/2,y)
    box:addChild(spr)

    y = y + 2
  end

  title:setPositionY(y-30)
end

function DeskView:load()
  self:freshSidesInfo()

  if self.desk.info.state == nil then
    self:setState('prepare')
  else
    self:setState('running')
    self:freshDesk()

    local me = self.desk:getMe()
    local actor = me.actor
    local cacheMsg = actor.cacheMsg
    if cacheMsg then
      if cacheMsg.msgID == self.desk.deskName..'.current' then
        self:freshFlipCardByCurrent(cacheMsg)
      end

      if cacheMsg.msgID == self.desk.deskName..'.action' then
        self:showActionPanel(cacheMsg)
      end
    end
  end
end

function DeskView:freshFlipCardByCurrent(msg)
  for i = 1,#all_side_keys do
    local key = all_side_keys[i]
    local panel = self.MainPanel:getChildByName(key)
    if panel then
      local player = self.desk:getPlayerByKey(key)

      local new = panel:getChildByName('new')
      new:hide()

      if msg.card ~= nil then
        if player.actor.uid == msg.uid then
          new:show()
          local path = self:getPathByValue(msg.card,'chang')
          new:loadTexture(path)
          new:setContentSize(cc.size(76,226))
        end
      end
    end
  end
end

local SUIT_MAP = {
  ['大'] = 'd',
  ['小'] = 'x',
}

function DeskView:getPathByValue(value,prefix)--luacheck:ignore
  if not prefix then
    prefix = 'small'
  end

  local rank = cardHelper.rank(value)
  local suit = cardHelper.suit(value)

  local path = 'cards/'..prefix..'/'..SUIT_MAP[suit]..rank..'.png'
  return path,rank,suit
end

function DeskView:freshDesk()
  local me = self.desk:getMe()
  if me and me.hand then
    if me.hand.hand then
      local tbl = {}

      for k,v in pairs(me.hand.hand) do
        local entry = {}
        for _ = 1,v do
          entry[#entry+1] = k
        end

        tbl[#tbl+1] = entry
      end

      table.sort(tbl,function(a,b)
        --[[if #a == #b then
          local pa = cardHelper.rank(a)
          local sa = cardHelper.suit(a)

          local pb = cardHelper.rank(b)
          local sb = cardHelper.suit(b)

          if sa == sb then
          else

          end
        else]]
          return #a < #b
        --end
      end)

      --dump(tbl)

      local down = self.MainPanel:getChildByName('down')
      local point
      local col = 1
      -- 先排相同的牌
      for i = #tbl,1,-1 do
        local group = tbl[i]
        if #group == 1 then
          point = i
          break
        end

        local cards = down.grids[col]
        for c = 1,#group do
          local value = group[c]
          self:bindCard(cards[c],value)
        end
        col = col + 1
      end

      print('point is ',point)
      local singles = {}


      for i = point,1,-1 do
        local group = tbl[i]

        singles[#singles+1] = group[1]
      end

      --dump(singles)
      local suit_tabls = {
        ['大'] = {},
        ['小'] = {},
      }

      for i = 1,#singles do
        local value = singles[i]
        local suit = cardHelper.suit(value)
        suit_tabls[suit][#suit_tabls[suit]+1] = value
      end

      for _,suittbl in pairs(suit_tabls) do
        table.sort(suittbl,function(a,b)
          local ra = cardHelper.rank(a)
          local rb = cardHelper.rank(b)
          return ra < rb
        end)
      end

      --dump(suit_tabls)

      local straights = {}
      for _,suittbl in pairs(suit_tabls) do
        local index = 1

        while index < #suittbl do
          local cur = suittbl[index]
          local next = suittbl[index+1]
          local next_next = suittbl[index+1+1]

          if next and next_next then
            local p0 = cardHelper.rank(cur)
            local p1 = cardHelper.rank(next)
            local p2 = cardHelper.rank(next_next)

            if p1 == p0 + 1 and p2 == p0 + 2 then
              straights[#straights+1] = cur
              straights[#straights+1] = next
              straights[#straights+1] = next_next

              index = index + 3
            else
              index = index + 1
            end
          else
            break
          end
        end
      end



      --dump(straights)
      -- 从单张里面删除连的
      for i = 1,#straights do
        for k = #singles,1,-1 do
          if singles[k] == straights[i] then
            table.remove(singles,k)
            break
          end
        end
      end

      --排顺子
      local cnt = #straights / 3
      for i = 1,cnt do
        for r = 1,3 do
          local grid = down.grids[col+i-1][r]
          local value = straights[(i-1)*3+r]
          if value then
            self:bindCard(grid,value)
          end
        end
      end

      col = col + cnt
      --dump(singles)

      -- 在排单张
      local index = 1
      for r = 1,ROWS do
        for c = col,MAX_COLS do
          local grid = down.grids[c][r]
          local value = singles[index]
          if value then
            self:bindCard(grid,value)
            index = index + 1
          end
        end
      end
    end
  end
end

function DeskView:freshBanker(banker)
  for i = 1,#all_side_keys do
    local key = all_side_keys[i]

    local panel = self.MainPanel:getChildByName(key)
    if panel then
      local head = panel:getChildByName('head')
      local zhuang = head:getChildByName('zhuang')
      zhuang:setVisible(key == banker)
    end
  end
end

function DeskView:playBeginAnimation()
  self:setState('running')
end

return DeskView
