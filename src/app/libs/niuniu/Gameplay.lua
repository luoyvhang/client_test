local class = require('middleclass')
local Gameplay = class("Gameplay")

function Gameplay:initialize(pack)
    self:initWithPack(pack)
end

function Gameplay:initWithPack(pack)
    self.played = pack.played
    self.isPlaying = pack.isPlaying
    self.state = pack.state
    self.tick = pack.tick

    self.gamePack = pack.gamePack

    self.qiangData = false -- 抢庄数据
end

-- //////////////////////////////////////////////////////////////
-- gamePack
function Gameplay:initGamePack(pack)
    self.gamePack = pack
end

function Gameplay:setBankerUID(bankerUID)
    if not self.gamePack then return end
    self.gamePack.banker = bankerUID
end

function Gameplay:getBankerUID()
    if not self.gamePack then return end
    return self.gamePack.banker
end

function Gameplay:setFlagFindBanker(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isFindBanker = bool
end

function Gameplay:getFlagFindBanker()
    if not self.gamePack then return end
    return self.gamePack.isFindBanker
end

function Gameplay:setFlagDealAllPlayer(bool)
    bool = bool or false
    if not self.gamePack then return end
    self.gamePack.isDealAllPlayer = bool
end

function Gameplay:getFlagDealAllPlayer()
    if not self.gamePack then return end
    return self.gamePack.isDealAllPlayer
end


-- //////////////////////////////////////////////////////////////
-- gameplay

function Gameplay:setState(state, tick)
    tick = tick or 0
    self.state = state
    self.tick = tick
end

function Gameplay:getState()
    return self.state
end

function Gameplay:getTick()
    self.tick = self.tick or 0
    local second = math.floor(self.tick/1000)
    local millisecond = self.tick
    return second, millisecond
end

function Gameplay:setQiangData(data)
    self.qiangData = data
end


return Gameplay