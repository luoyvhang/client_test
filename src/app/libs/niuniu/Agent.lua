local class = require('middleclass')
local Agent = class("Agent")
local GameLogic = require('app.libs.niuniu.NNGameLogic')

function Agent:initialize(pack)
    -- actor data
    self.actor = {}
    self.actor.uid = pack.actor.uid
    self.actor.avatar = pack.actor.avatar
    self.actor.sex = pack.actor.sex
    self.actor.nickName = pack.actor.nickName
    self.actor.diamond = pack.actor.diamond
    self.actor.playerId = pack.actor.playerId
    self.actor.ip = pack.actor.ip

    self.actor.win = pack.actor.win
    self.actor.lose = pack.actor.lose
    self.actor.cacheMsg = pack.actor.cacheMsg
    self.actor.x = pack.actor.x
    self.actor.y = pack.actor.y
    self.actor.vip = pack.actor.vip
    self.actor.shopRight = pack.actor.shopRight

    -- agent data
    self.chairIdx = pack.chairIdx
    self.isInMatch = pack.isInMatch 
    self.isPrepare = pack.isPrepare
    self.money = pack.money
    self.groupScore = pack.groupScore
    self.isLeaved = pack.isLeaved
    self.isTrusteeship = pack.isTrusteeship
    self.isAway = pack.isEnterBackground
    self.isSmartTrusteeship = pack.isSmartTrusteeship
    self.autoOperation = pack.autoOperation

    -- hand
    self:initHandWithPack(pack.hand)
end

function Agent:initHandWithPack(pack)
    if not pack then
        self.hand = false
        return
    end
    self.hand = pack        
    
    if pack.dealList then
        self:setHandCardData(pack.dealList)
    elseif pack.hand then
        local hand = pack.hand
        self:setHandCardData(hand)
    end

    if pack.summaryHand then
        local hand = pack.summaryHand
        self:setSummaryCardData(hand)
    end
end

function Agent:initHand()
    local hand = {}
    hand.hand = false 
  
    hand.qiangCnt = false
    hand.putScore = false
    hand.putFlag = false
    hand.thisPutOpt = self.thisPutOpt or false
    

    hand.choosed = false
    hand.niuCnt = false
    hand.specialType = false
    hand.summaryHand = false

    hand.oneScore = false
    hand.isBanker = false
    hand.canPutMoney = false

    hand.lastcard = false

    self.hand = hand
end

function Agent:setHand(pack)
    local hand = {}
    hand.hand = false 
    
    if pack.hand then
      hand.hand = pack.hand
    end
  
    hand.qiangCnt = pack.qiangCnt
    hand.putScore = pack.putScore
    hand.putFlag = pack.putFlag
    hand.thisPutOpt = pack.thisPutOpt

    hand.choosed = pack.choosed
    hand.niuCnt = pack.niuCnt
    hand.specialType = pack.specialType
    hand.summaryHand = pack.summaryHand
    
    hand.oneScore = pack.oneScore
    hand.isBanker = pack.isBanker
    hand.canPutMoney = false

    self.hand = hand
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!xydesk
function Agent:setViewInfo(key, pos)
    self.viewKey = key
    self.viewPos = pos
end

function Agent:getViewInfo()
    return self.viewKey, self.viewPos
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!hand

function Agent:setCanPutMoney(bool)
    if not self.hand then return end
    self.hand.canPutMoney = bool or false
end

function Agent:getCanPutMoney()
    if not self.hand then return end
    return self.hand.canPutMoney
end


function Agent:setFlagBanker(bool)
    if not self.hand then return end
    self.hand.isBanker = bool
end

function Agent:getFlagBanker()
    if not self.hand then return end
    return self.hand.isBanker
end

function Agent:setQiang(qiangNum)
    if not self.hand then return end
    self.hand.qiangCnt = qiangNum or 0
end

function Agent:setThisPutOpt(tabOpt)
    if not self.hand then return end
    self.hand.thisPutOpt = tabOpt
end

function Agent:getThisPutOpt()
    if not self.hand then return end
    return self.hand.thisPutOpt
end

function Agent:setHandCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.hand = data
        self:setLastCard(data)
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.hand = arr
    self:setLastCard(arr)
end

function Agent:getHandCardData()
    if not self.hand then return end
    return self.hand.hand
end

function Agent:setChoosed(bool, niuCnt, spcialType)
    if not self.hand then return end
    self.hand.choosed = bool
    if niuCnt then
        self.hand.niuCnt = niuCnt
    end
    if spcialType then
        self.hand.specialType = spcialType
    end
end

function Agent:getChoosed()
    if not self.hand then return end
    local choose = false
    if self.hand.choosed then
        choose = true
    end
    return choose, self.hand.niuCnt, self.hand.specialType
end

function Agent:getQiang()
    if not self.hand then return end
    return self.hand.qiangCnt 
end

function Agent:setPutscore(score)
    if not self.hand then return end
    self.hand.putScore = score
end

function Agent:getPutscore()
    if not self.hand then return end
    return self.hand.putScore
end

function Agent:setPutFlag(bool)
    if not self.hand then return end
    self.hand.putFlag = bool
end

function Agent:setSummaryCardData(data)
    if not self.hand then return end
    if #data > 0 then
        self.hand.summaryHand = data
        return
    end
    local arr = GameLogic.hashCountsToArray(data)
    self.hand.summaryHand = arr
end

function Agent:getSummaryCardData()
    if not self.hand then return end
    return self.hand.summaryHand
end

function Agent:setLastCard(data)
    if not self.hand then return end
    self.hand.lastcard = GameLogic.transformCards(data)
end

function Agent:getLastCard()
    if not self.hand then return end
    return self.hand.lastcard
end

function Agent:setScore(score)
    if not self.hand then return end
    self.hand.score = score
end

function Agent:getScore()
    if not self.hand then return end
    return self.hand.score
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--!agent

function Agent:getActor()
    return self.actor
end

function Agent:getAvatar()
    return self.actor.avatar
end

function Agent:getNickname()
    return self.actor.nickName
end

function Agent:getUID()
    return self.actor.uid
end

function Agent:getChairID()
    return self.chairIdx
end

function Agent:setPrepare(bool)
    self.isPrepare = bool
end

function Agent:isReady()
    return self.isPrepare
end

function Agent:setDropLine(bool)
    self.isLeaved = bool
end

function Agent:isDropLine()
    return self.isLeaved
end

function Agent:setEnterBackground(bool)
    self.isAway = bool
end

function Agent:isEnterBackground()
    return self.isAway
end

function Agent:setTrusteeship(bool)
    self.isTrusteeship = bool
end

function Agent:getTrusteeship()
    return self.isTrusteeship
end

function Agent:setautoOperation(bool)
    self.autoOperation = bool
end

function Agent:getautoOperation()
    return self.autoOperation
end

function Agent:setMoney(money)
    self.money = money
end

function Agent:getMoney()
    return self.money
end

function Agent:setGroupScore(groupScore)
    self.groupScore = groupScore
end

function Agent:getGroupScore()
    return self.groupScore
end

function Agent:getSmartTrusteeship()
    return self.isSmartTrusteeship
end

function Agent:getSex()
    return self.actor.sex
end

function Agent:setInMatch(bool)
    self.isInMatch = bool
end

function Agent:getInMatch()
    return self.isInMatch
end

return Agent