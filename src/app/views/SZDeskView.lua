local XYDeskView = require('app.views.XYDeskView')
local SZDeskView = {}

local function mixin(self, script)
    for k, v in pairs(script) do
        -- added by hthuang: onExit can not be used
        -- assert(self[k] == nil, 'Your script "app/views/'..self.name..'.lua" should not have a member named: ' .. k)
        self[k] = v
    end
end

mixin(SZDeskView, XYDeskView)

function SZDeskView:initialize()
    XYDeskView.initialize(self)

    if self.ui then
        self.ui:removeFromParent()
        self.ui = nil
    end

    local View = require('mvc.View')
    self.ui = View.loadUI('views/XYDeskView.csb')
    self:addChild(self.ui)
end

function SZDeskView:layout(desk)
    XYDeskView.layout(self, desk)
end

function SZDeskView:freshCuoPaiDisplay(bool, data)
    local cpBg = self.MainPanel:getChildByName('cpBg')
    if not cpBg:isVisible() and data then
        local angle = 4
        cpBg.flag = 0

        for i = 1, 5 do
            local card = cpBg:getChildByName('card' .. i)
            if card.oriX and card.oriY  then
                card:setPosition(cc.p(card.oriX, card.oriY))
            end
            card:setRotation(0)
        end

        for i, v in ipairs(data) do
            local card = cpBg:getChildByName('card' .. i)
            local suit = self.suit_2_path[self:card_suit(v)]
            local rnk = self:card_rank(v)

            local path
            if suit == 'j1' or suit == 'j2' then
                path = 'views/xydesk/shuffle/' .. suit .. '.png'
            else
                -- print(" -> suit : ", suit, "rnk : ", rnk)
                path = 'views/xydesk/shuffle/' .. suit .. rnk .. '.png'
            end
            card:loadTexture(path)
            card.state = 'origin'
            if not card.oriX and not card.oriY then
                card.oriX, card.oriY = card:getPosition()
            end

            local rot = cc.RotateTo:create(0.3, angle)
            card:runAction(rot)
            angle = angle - 2

            card:addTouchEventListener(function(sender, type)
                if type == 0 then
                    -- began
                    self.starpos = sender:getTouchBeganPosition()
                    local x, y = card:getPosition()
                    self.orgPos = {x = x, y = y}
                elseif type == 1 then
                    -- move
                    card.state = card.state ~= 'moved' and 'move' or 'moved'

                    local pos = sender:getTouchMovePosition()
                    local difX = self.starpos.x - pos.x
                    local difY = self.starpos.y - pos.y
                    card:setPosition(cc.p(self.orgPos.x - difX, self.orgPos.y - difY))
                else
                    -- ended
                    for i = 1, 5 do
                        local card = cpBg:getChildByName('card' .. i)
                        if card.state == 'move' then
                            card.state = 'moved'
                            cpBg.flag = cpBg.flag + 1
                        end
                    end

                    if cpBg.flag == 4 then
                        local newAngle = 16
                        for i = 1, 5 do
                            local card = cpBg:getChildByName('card' .. i)
                            card:setRotation(newAngle)
                            newAngle = newAngle - 8

                            local delay = cc.DelayTime:create(1.5)
                            local dest = cc.p(card.oriX, card.oriY)
                            local moveTo = cc.MoveTo:create(0.3, dest)

                            local callback = function()
                                -- 搓牌回调
                                self.emitter:emit('cpBack', {msgID = 'cpBack'})
                                card.oriX, card.oriY = nil, nil
                            end
                            local sequence = cc.Sequence:create(moveTo, delay, cc.CallFunc:create(callback))
                            card:runAction(sequence)
                        end
                    end
                end
            end)
        end
    else
        for i = 1, 5 do
            local card = cpBg:getChildByName('card' .. i)
            card.state = 'origin'
            card:cleanup()
        end
    end
    cpBg:setVisible(bool)
end

function SZDeskView:freshSQZBar(bool)
    local sqzbar = self.MainPanel:getChildByName('sqzbar')
    sqzbar:setVisible(bool)
end

-- 替换 freshSQZBar方法
function SZDeskView:freshQiangZhuangBar(bool)
    local sqzbar = self.MainPanel:getChildByName('sqzbar')
    sqzbar:setVisible(bool)
end

return SZDeskView
