local card = {}
local array = require('array')
local table = require('table.addons')

local CARDS = { -- nature order, used to find tractors
  ['1筒'] = 0x11,['2筒'] = 0x12,['3筒'] = 0x13,['4筒'] = 0x14,['5筒'] = 0x15,
  ['6筒'] = 0x16,['7筒'] = 0x17,['8筒'] = 0x18,['9筒'] = 0x19,
  ['1条'] = 0x31,['2条'] = 0x32,['3条'] = 0x33,['4条'] = 0x34,['5条'] = 0x35,
  ['6条'] = 0x36,['7条'] = 0x37,['8条'] = 0x38,['9条'] = 0x39,
  ['1万'] = 0x51,['2万'] = 0x52,['3万'] = 0x53,['4万'] = 0x54,['5万'] = 0x55,
  ['6万'] = 0x56,['7万'] = 0x57,['8万'] = 0x58,['9万'] = 0x59,
  ['东'] = 0x71,['南'] = 0x74,['西'] = 0x77,['北'] = 0x80,['白'] = 0x83,
  ['中'] = 0x86,['发'] = 0x89
}

local FENGCARDS = {
  '东','南','西','北','白','中','发'
}

function card.hashCountsToArray(hash)
  local a = {}
  for k, v in pairs(hash) do
    for _=1,v do
      a[#a + 1] = k
    end
  end
  return a
end

function card.all()
  return table.keys(CARDS)
end

local SUIT_UTF8_LENGTH = 3 -- length of '大', '小' are all 3 bytes in utf-8.

function card.rank(c)
  return #c > SUIT_UTF8_LENGTH and tonumber(c:sub(SUIT_UTF8_LENGTH + 1, SUIT_UTF8_LENGTH + 3)) or nil
end

function card.suit(c)
  return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
end

function card.newDecks(n)
  return array.dup(table.keys(CARDS), n)
end

function card.getVaule(c)
  return CARDS[c]
end

function card.shuffle(cards)
  array.shuffle(cards)
  return cards
end

function card.getSuitCount(cards)
  local color = {}
  local count = 0
  for c, _ in pairs(cards) do
    local suit = card.suit(c)
    if not color[suit] then
      count = count + 1
      color[suit] = 1
    end
  end

  return count
end

----对对胡 2
local function checkDuiDuiHu(cards)
  for _, v in pairs(cards) do
    if v == 1 or v == 4 then
      return false
    end
  end
  return true
end

----清一色 3
local function checkQingyise(cards)
  return card.getSuitCount(cards) == 1
end

----带幺九 3
local function check19(cards)
  return false
end

----七对 3
local function checkQidui(cards, pgcards)
  if next(pgcards) ~= nil then
    return false
  end
  for _, v in pairs(cards) do
    if v == 1 or v == 3 then
      return false
    end
  end
  return true
end

----天胡 6
local function checkTianHu()
  return false
end

----地 6
local function checkDihu()
  return false
end

----检查有没有杠
local function checkHaveGang(cards)
  for _, v in pairs(cards) do
    if v == 4 then
      return true
    end
  end
  return false
end

----检查有没有268
local function check258(cards)
  for i, _ in pairs(cards) do
    local r = card.rank(i)
    if r ~= '2' and r ~= '5' and r ~= '8' then
      return false
    end
  end
  return true
end

card.tmul = {
  1,2, 3, 3, 3, 4, 4, 5, 5, 5, 6
}
function card.checkSpecialHu(allhand, pghand)
  if next(pghand) ~= nil then
    return false
  end

  if card.getSuitCount(allhand) ~= 4 then
    return false
  end

  for _, v in ipairs(allhand) do
    if v > 1 then
      return false
    end
  end

  local fcount = 0
  for _, v in ipairs(FENGCARDS) do
    if allhand[v] then
      fcount = fcount + 1
    end
  end

  if fcount < 5 then
    return false
  end

-------检查个花色是否满足2,5,8 3,6,6 1,4,7条件
  local sCardsCfg = {{2,5,8}, {3,6,9}, {1,4,7}}
  local classSuit = {}
  for c, _ in pairs(allhand) do
    local suit = card.suit(c)
    local value = card.rank(c)
    if value ~= -1 then
      if not classSuit[suit] then
        classSuit[suit] = {}
      end
      table.insert(classSuit[suit], value)
    end
  end

  local function arrContain(m, s)
    local b = true
    for _, v in pairs(s) do
      if not table.contain(m, v) then
        b = false
      end
    end
    return b
  end

  local b
  for _, v in pairs(classSuit) do
    b = arrContain(sCardsCfg[1], v) or arrContain(sCardsCfg[2], v) or arrContain(sCardsCfg[3], v)
    if not b then
      return false
    end
  end

  if fcount == 7 then
    print("7星乱牌 2翻")
    return true, 13
  else
    print("乱牌 1翻")
    return true, 12
  end
end

function card.getHuKind(allhand, hand, pghand, option)
  if checkQingyise(allhand) then
    if check19(hand) then
      print("清19 5翻")
      return 10
    elseif checkQidui(hand, pghand) then
      if checkHaveGang(hand) then
        print("青龙七对 6翻")
        return 11
      else
        print("清7对 5翻")
        return 9
      end
    elseif checkDuiDuiHu(allhand) then
      print("清对对胡 4翻")
      return 7
    else
      print("清一色 3翻")
      return 5
    end
  else
    if check19(hand) then
      print("19 3翻")
      return 4
    elseif checkQidui(hand) then
      if checkHaveGang(pghand, pghand) then
        print("龙七对 5翻")
        return 8
      else
        print("7对 3翻")
        return 3
      end
    elseif checkDuiDuiHu(allhand) then
      if check258(hand) then
        print("将对 4翻")
        return 6
      else
        print("对对胡 2翻")
        return 2
      end
    else
      print("平胡")
      return 1
    end
  end
end


local function orderTractorLess(a, b)
  return CARDS[a] < CARDS[b]
end

function card.sort(cards)
  --if type(cards) == 'string' then print(debug.traceback()) end
  table.sort(cards, orderTractorLess)
  return cards
end
return card
