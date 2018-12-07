local SoundMng = require("app.helpers.SoundMng")
local XYDeskView = require('app.views.XYDeskView')
local Scheduler = require('app.helpers.Scheduler')
local app = require("app.App"):instance()
local QZDeskView = {}

local function mixin(self, script)
    for k, v in pairs(script) do
        self[k] = v
    end
end

mixin(QZDeskView, XYDeskView)

function QZDeskView:initialize(ctrl)

    XYDeskView.initialize(self)

    if self.ui then
        self.ui:removeFromParent()
        self.ui = nil
    end

    local View = require('mvc.View')
    local desk = ctrl.desk
    if desk and desk:getGameplayIdx() == 7 then
        self.ui = View.loadUI('views/XYDeskView2.csb')
        self:addChild(self.ui)
    elseif desk:getGameplayIdx() == 8 then
        self.ui = View.loadUI('views/XYDeskView3.csb')
        self:addChild(self.ui)
    else
        self.ui = View.loadUI('views/XYDeskView.csb')
        self:addChild(self.ui)
    end

end

function QZDeskView:layout(desk)
    XYDeskView.layout(self, desk)

    local cpLayer = self.MainPanel:getChildByName('cpLayer')
    self.cpLayer = cpLayer
    self.rubLayer = nil    

end

function QZDeskView:freshQiangZhuangBar(bool, agent)
    local qzbar = self.MainPanel:getChildByName('qzbar')
    if not bool then
        qzbar:setVisible(false)
        return
    end

    local deskInfo = self.desk:getDeskInfo()
    local qzMax = deskInfo.qzMax
    local roomMode = deskInfo.roomMode
    local scoreOption = deskInfo.scoreOption

    qzbar:setScrollBarEnabled(false)
    local noBtn = qzbar:getChildByName('no')
    noBtn:setVisible(true)
    qzbar:getChildByName('one'):setVisible(false)
    qzbar:getChildByName('double'):setVisible(false)
    qzbar:getChildByName('triple'):setVisible(false)
    qzbar:getChildByName('four'):setVisible(false)

    local function show(qzMax)       
        local margin = qzbar:getItemsMargin()
        local cnt = qzMax + 1
        local itemWidth = noBtn:getContentSize().width * noBtn:getScaleX() * qzbar:getScaleX()
        local listWidth = (itemWidth*cnt) + (margin*(cnt-1))
        local posX = display.cx - (listWidth/2)
    
        qzbar:setPositionX(posX)
        qzbar:setVisible(true)
    end

    if roomMode and roomMode == 'bisai' then
        if agent then
            local groupScore = agent:getGroupScore()
            if groupScore < scoreOption.qiang then
                show(0)
                return 
            end
        end
    end

    if qzMax >= 1 then
        qzbar:getChildByName('one'):setVisible(true)
    end
    if qzMax >= 2 then
        qzbar:getChildByName('double'):setVisible(true)
    end
    if qzMax >= 3 then
        qzbar:getChildByName('triple'):setVisible(true)
    end
    if qzMax >= 4 then
        qzbar:getChildByName('four'):setVisible(true)
    end

    show(qzMax)
end


function QZDeskView:showCardsAtCuopai(data)
    local cards = self.cpLayer:getChildByName('cards')
    for i = 1, 4 do
        local card = cards:getChildByName('card' .. i)
        self:freshCardsTextureByNode(card, data[i])
        card:setVisible(true)
    end
end

function QZDeskView:freshCardFlipAction(cardValue)
    if nil ~= self.animation and not self.cardFlip then

        local app = require("app.App"):instance()
        local idx = app.localSettings:get('cuoPai')
        idx = idx or 1

        self.card3d:setTexture('3d/0' .. cardValue .. '.png')
        self.card3d1:setTexture('3d/paibei/paibei_' .. idx .. '.png')
        self.card3d:setCameraMask(cc.CameraFlag.USER1)
        self.card3d1:setCameraMask(cc.CameraFlag.USER1)

        local animate = cc.Animate3D:createWithFrames(self.animation, 51, 80)
        local animate1 = cc.Animate3D:createWithFrames(self.animation1, 51, 80)
        local speed = 1.0
        animate:setSpeed(speed)
        animate:setTag(110)
        animate1:setSpeed(speed)
        animate1:setTag(120)

        local callback = function()
            self.emitter:emit('cpBack', {msgID = 'cpBack'})
        end

        local callback1 = function()
            local animate2 = cc.FadeIn:create(0.5)
            self.scardvalue:runAction(animate2)
        end

        local callback2 = function()
            local animate2 = cc.FadeIn:create(0.5)
            self.scardvalue1:runAction(animate2)
        end

        local delay = cc.DelayTime:create(1.5)
        local showcardvalue = cc.Spawn:create( cc.CallFunc:create(callback1), cc.CallFunc:create(callback2))
        local sequence = cc.Sequence:create(animate, showcardvalue,delay, cc.CallFunc:create(callback))
        local sequence1 = cc.Sequence:create(animate1, showcardvalue,delay, cc.CallFunc:create(callback))

        self.card3d:stopAllActions()
        self.card3d:runAction(sequence)
        self.card3d1:stopAllActions()
        self.card3d1:runAction(sequence1)

        self.cardFlip = true
        self.card:addTouchEventListener(function() end)
    end
end

----------------------------------------------------------------------------------------------------

function QZDeskView:init3dLayer(cardData)
    local suit = self.suit_2_path[self:card_suit(cardData)]
    local rnk = self:card_rank(cardData) or '_joker'

    if not suit then return end
    if not rnk then return end
    
    local fileName = suit .. rnk
    local cardPath = '3d/0' .. suit .. rnk .. '.png'
    local cardIdx = self:getCurCuoPai()
    local backPath = '3d/paibei/paibei_' .. cardIdx .. '.png'

    local function getTextureAndRange(szImage)
        local TextureCache = cc.Director:getInstance():getTextureCache()
        local tex = TextureCache:addImage(szImage)
        
        local rect = tex:getContentSize()
        local id = tex:getName()
        local bigWide = tex:getPixelsWide() 
        local bigHigh = tex:getPixelsHigh()

        local ll = 0
        local rr = 1
        local tt = 0
        local bb = 1
        return id, {ll, rr, tt, bb}, {rect.width, rect.height}
    end

    local function initCardVertex(size, texRange, bFront, valTexTange)
        local nDiv = 50 
        local verts = {} 
        local texs = {} 
        local dh = size.height / nDiv
        local dw = size.width / nDiv

        local valW = 168*0.9
        local valH = 66*0.9
        local valX = size.width - valW -10
        local valY =  7

        local valW1 = valW
        local valH1 = valH
        local valX1 = 10
        local valY1 =  size.height - 66

        local valVer = {}
        local valTex = {}

        local valVer1 = {}
        local valTex1 = {}

        local function isInValRange(x, y)
            local xIn = valX<=x and x<=(valW+valX)
            local yIn = valY<=y and y<=(valH+valY)
            return xIn and yIn
        end

        local function isInValRange1(x, y)
            local xIn = valX1<=x and x<=(valW1+valX1)
            local yIn = valY1<=y and y<=(valH1+valY1)
            return xIn and yIn
        end

        for row = 1, nDiv do
            for line = 1, nDiv do
                local x = (row - 1)* dw
                local y = (line - 1)* dh
                local quad = {}
                if bFront then 
                    quad = {
                        x, y,           x + dw, y,          x, y + dh, 
                        x + dw, y,      x + dw, y + dh,     x, y + dh,
                    }
                else  
                    quad = {
                        x, y,           x, y + dh,          x + dw, y, 
                        x + dw, y,      x, y + dh,          x + dw, y + dh,
                    }
                    if valTexTange then
                        for i=1,#quad,2 do
                            if isInValRange(quad[i], quad[i+1]) then
                                table.insert(valVer, quad[i])
                                table.insert(valVer, quad[i+1])
                            end
                            if isInValRange1(quad[i], quad[i+1]) then
                                table.insert(valVer1, quad[i])
                                table.insert(valVer1, quad[i+1])
                            end
                        end
                    end
                end

                for _, v in ipairs(quad) do
                    table.insert(verts, v)
                end
            end
        end

        local bXTex = true 
        for _, v in ipairs(verts) do
            if bXTex then
                if bFront then
                    table.insert(texs, v / size.width * (texRange[2] - texRange[1]) + texRange[1])
                else
                    table.insert(texs, v / size.width * (texRange[1] - texRange[2]) + texRange[2])
                end
            else
                if bFront then
                    table.insert(texs, (1 - v / size.height) * (texRange[4] - texRange[3]) + texRange[3])
                else
                    table.insert(texs, v / size.height * (texRange[3] - texRange[4]) + texRange[4])
                end
            end
            bXTex = not bXTex
        end

        if valTexTange then
            local bXTex = true 
            for _, v in ipairs(valVer) do
                if bXTex then
                    table.insert(valTex, 1-((v-valX) / valW))
                else
                    table.insert(valTex, 1-((v-valY) / valH))
                end
                bXTex = not bXTex
            end

            local bXTex = true 
            for _, v in ipairs(valVer1) do
                if bXTex then
                    table.insert(valTex1, ((v-valX1) / valW1))
                else
                    table.insert(valTex1, ((v-valY1) / valH1))
                end
                bXTex = not bXTex
            end
        end

        local res = {}
        local tmp = {verts, texs}
        for _, v in ipairs(tmp) do
            local buffid = gl.createBuffer()
            gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
            gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
            gl.bindBuffer(gl.ARRAY_BUFFER, 0)
            table.insert(res, buffid)
        end


        local valRes = {}
        local valRes1 = {}
        if valTexTange then
            for _, v in ipairs({valVer, valTex}) do
                local buffid = gl.createBuffer()
                gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
                gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
                gl.bindBuffer(gl.ARRAY_BUFFER, 0)
                table.insert(valRes, buffid)
            end

            for _, v in ipairs({valVer1, valTex1}) do
                local buffid = gl.createBuffer()
                gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
                gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
                gl.bindBuffer(gl.ARRAY_BUFFER, 0)
                table.insert(valRes1, buffid)
            end
        end
        return res, #verts, valRes, #valVer, valRes1, #valVer1
    end

    local function showValueSpAction(layer, mode)
        local z = -layer.rubRadius*2 + 1

        local wx = layer.cardWidth/2 - 60
        local wy = layer.cardHeight/2 - 20

        local tabPos = {
            [1.0] = {
                cc.vec3(-wx-12,-wy,z),
                cc.vec3(wx-12,wy,z),
                false,
                false,
            },
            [2.0] = {
                false,
                false,
                cc.vec3(-wy-9,wx,z),
                cc.vec3(wy,-wx,z),
            },
            [3.0] = {
                cc.vec3(-wx+3,-wy+11,z),
                cc.vec3(wx,wy+15,z),
                false,
                false,
            },
            [4.0] = {
                cc.vec3(-wx+10,-wy,z),
                cc.vec3(wx+10,wy,z),
                false,
                false,
            },
            [5.0] = {
                false,
                false,
                cc.vec3(-wy,wx,z),
                cc.vec3(wy+8,-wx,z),
            },
        }

        for i = 1, 4 do
            if tabPos[layer.mode][i] then
                local action = cc.FadeIn:create(0.3)
                layer['valSp'..i]:setPosition3D(tabPos[layer.mode][i])
                layer['valSp'..i]:stopAllActions()
                layer['valSp'..i]:runAction(action)
            end
        end
    end

    local function createRubCardEffectLayer(pList, szBack, szFont, scale)
        scale = scale or 1.0

        local Director = cc.Director:getInstance()
        local WinSize = Director:getWinSize()

        local camera = cc.Camera:createPerspective(45, WinSize.width / WinSize.height, 1, 1000)
        camera:setCameraFlag(cc.CameraFlag.USER2)
        camera:setDepth(1)
        camera:setPosition3D(cc.vec3(0, 0, 800))
        camera:lookAt(cc.vec3(0, 0, 0), cc.vec3(0, 1, 0))

        local glNode = gl.glNodeCreate()
        local glProgram = cc.GLProgram:createWithFilenames('3d/card1.c3b', '3d/card2.c3b')
        glProgram:retain()
        glProgram:updateUniforms()

        local layer = cc.Layer:create()
        layer:setCameraMask(cc.CameraFlag.USER2)
        layer:addChild(glNode)
        layer:addChild(camera)

        local function onNodeEvent(event)
            if "exit" == event then
                Scheduler.delete(layer.updateF)
                glProgram:release()
            end
        end
        layer:registerScriptHandler(onNodeEvent)

        --------------------------------------------------------------------------------------------------------------------------------
        local posBegin = cc.p(0,0)
        local initMode = false
        local function touchBegin(touch, event)
            local location = touch:getLocation()
            posBegin = location
            return true
        end

        local function onMoveJ1(dx, dy)
            if initMode == 1.0 then 
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 + layer.halfRubPerimeter
                    if layer.j1 < (layer.cardWidth * 0.4) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.ceil(layer.j1/dx)
                        layer.actionOffX1 = layer.cardWidth+layer.halfRubPerimeter
                        layer.actionOffY1 = 0
                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 - dx
                    layer.j2 = layer.j1 + layer.halfRubPerimeter
                    if layer.j2 < 0 then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 2.0 then 
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(-layer.rubLength)
                    if layer.j1 > -(layer.cardWidth*0.1) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/layer.k1*(-dx)))

                        local len3 = math.cos(math.rad(45))*layer.halfRubPerimeter
                        local len2 = (layer.cardWidth - layer.cardHeight)/2
                        layer.actionOffX1 = len2 + len3 + layer.cardHeight
                        layer.actionOffY1 = -(len3 + layer.cardHeight + len2)

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx*-1)
                    layer.j2 = layer.j1 + layer.k1*(-layer.rubLength)
                    if layer.j2 > (layer.cardHeight/math.tan(math.rad(45))) then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 3.0 then 
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + dy
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j1 > (layer.cardHeight * 0.6) then
                        layer.actionOffY = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/dy))

                        layer.actionOffX1 = 0
                        layer.actionOffY1 = -layer.cardHeight - layer.halfRubPerimeter

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + dy
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j2 > layer.cardHeight then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 4.0 then 
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j1 > (layer.cardWidth * 0.6) then
                        layer.actionOffX = layer.j1
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/dx))

                        layer.actionOffX1 = -layer.cardWidth - layer.halfRubPerimeter
                        layer.actionOffY1 = 0

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + dx
                    layer.j2 = layer.j1 - layer.halfRubPerimeter
                    if layer.j2 > (layer.cardWidth) then
                        layer.actionFlag = 2.0
                    end
                end

            elseif initMode == 5.0 then 
                if layer.actionFlag == 0.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(layer.rubLength)
                    if layer.j1 > (layer.cardWidth*0.9) then
                        layer.actionFrameCnt = math.abs(math.ceil(layer.j1/layer.k1*(-dx)))
                        layer.actionOffX = layer.j1
                        
                        local len3 = math.cos(math.rad(45))*layer.halfRubPerimeter
                        local len2 = (layer.cardWidth - layer.cardHeight)/2
                        layer.actionOffX1 = len2 - (len3 + layer.cardWidth)
                        layer.actionOffY1 = -(len3 + layer.cardHeight + len2)

                        layer.actionFlag = 1.0
                    end
                elseif layer.actionFlag == 1.0 then
                    layer.j1 = layer.j1 + layer.k1*(-dx)
                    layer.j2 = layer.j1 + layer.k1*(layer.rubLength)
                    if layer.j2 > (layer.cardHeight/math.tan(math.rad(45)) + layer.cardWidth) then
                        layer.actionFlag = 2.0
                    end
                end
            end
        end

        local function touchMove(touch, event)
            local location = touch:getLocation()
            local dx = (location.x - posBegin.x)
            local dy = (location.y - posBegin.y)
            dx = dx * 1.3
            dy = dy * 2.0
            if not initMode then
                local dt = math.sqrt(math.pow(dx,2) + math.pow(dy,2))
                if dt > layer.modeThreshold then
                    local angle = math.atan2(dy, dx)/math.pi*180
                    if angle >= -80 and angle < 22.5 then 
                        initMode = 4.0
                        layer.mode = initMode
                        layer.k1 = 0.0
                        layer.j1 = 0.0
                        layer.j2 = layer.j1 - layer.halfRubPerimeter

                    elseif angle >= 22.5 and angle < 67.5 then 
                        initMode = 5.0
                        layer.mode = initMode
                        layer.k1 = -1.0
                        layer.j1 = 0
                        layer.j2 = layer.k1*(-layer.rubLength)

                    elseif angle >= 67.5 and angle < 112.5 then 
                        initMode = 3.0
                        layer.mode = initMode
                        layer.k1 = 0.0
                        layer.j1 = -layer.halfRubPerimeter
                        layer.j2 = layer.j1 - layer.halfRubPerimeter

                    elseif angle >= 112.5 and angle < 157 then 
                        initMode = 2.0
                        layer.mode = initMode
                        layer.k1 = 1.0
                        layer.j1 = layer.k1*(-layer.cardWidth)
                        layer.j2 = layer.k1*(-1*(layer.cardWidth + layer.rubLength))

                    elseif (angle >= 157 and angle <=180) or (-180 <= angle and angle <= -120) then 
                        initMode = 1.0 
                        layer.mode = initMode
                        layer.k1 = 0
                        layer.j1 = layer.cardWidth
                        layer.j2 = layer.j1 + layer.halfRubPerimeter

                    end
                    if initMode then
                        posBegin = location
                    end
                end
            else
                if layer.actionFlag > 0.0 then return end
                posBegin = location
                onMoveJ1(dx, dy)
            end
        end

        local function touchEnd(touch, event)
            if layer.actionFlag == 0.0 then
                initMode = false
                layer.mode = 4.0
                layer.k1 = 0.0
                layer.j1 = 0.0
                layer.j2 = layer.j1 - layer.halfRubPerimeter
                return true
            elseif layer.actionFlag == 1.0 then

            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)


        --------------------------------------------------------------------------------------------------------------------------------
        
        local id1, texRange1, sz1 = getTextureAndRange(szBack)
        local msh1, nVerts1 = initCardVertex(cc.size(sz1[1] * scale, sz1[2] * scale), texRange1, true)

        local id3, texRange3, sz3 = getTextureAndRange('3d/1' .. fileName .. '.png')

        local id2, texRange2, sz2 = getTextureAndRange(szFont)
        local msh2, nVerts2, msh3, nVerts3, msh4, nVerts4= initCardVertex(cc.size(sz2[1] * scale, sz2[2] * scale), texRange2, false, texRange3)
        
        
        --------------------------------------------------------------------------------------------------------------------------------

        layer.cardWidth = sz1[1] * scale
        layer.cardHeight = sz1[2] * scale
        
        layer.modeThreshold = 10.0

        layer.rubRadius = 30.0
        layer.halfRubPerimeter = layer.rubRadius*math.pi
        layer.rubPerimeter = layer.rubRadius*math.pi*2

        layer.rubLength = layer.halfRubPerimeter/math.cos(math.rad(45))

        layer.mode = 1.0
        layer.k1 = 0
        layer.j1 = layer.cardWidth
        layer.j2 = layer.j1 + (math.pi*layer.rubRadius)
    
        layer.actionFlag = 0.0
        layer.actionR = 0.0
        layer.actionStep = 30.0
        layer.actionOffX = 0.0
        layer.actionOffY = 0.0
        layer.actionOffZ = 0.0

        layer.actionOffX1 = 0.0
        layer.actionOffY1 = 0.0
        layer.actionOffZ1 = 0.0

        layer.actionStepZ = 0
        layer.actionStepZ1 = 0
        layer.actionFrameCnt = 0

        layer.offCx = 0
        layer.offCy = 0

        layer.flagShowValueSp = false

        -----------------------------------------------------------------------------
        layer.offX = WinSize.width / 2 - layer.cardWidth/2
        layer.offY = WinSize.height / 2 - layer.cardHeight/2

        local sp1 = cc.Sprite:create('3d/1' .. fileName .. '.png')    
        sp1:setPosition3D(cc.vec3(-layer.cardWidth/2,-layer.cardHeight/2,0))
        sp1:setCameraMask(cc.CameraFlag.USER2)
        sp1:setScale(0.9)
        sp1:setOpacity(0)

        local sp2 = cc.Sprite:create('3d/1' .. fileName .. '.png')    
        sp2:setPosition3D(cc.vec3(layer.cardWidth/2,layer.cardHeight/2,0))
        sp2:setRotation(180)
        sp2:setCameraMask(cc.CameraFlag.USER2)
        sp2:setScale(0.9)
        sp2:setOpacity(0)

        local sp3 = cc.Sprite:create('3d/1' .. fileName .. '.png')    
        sp3:setPosition3D(cc.vec3(-layer.cardHeight/2,layer.cardWidth/2,0))
        sp3:setRotation(90)
        sp3:setCameraMask(cc.CameraFlag.USER2)
        sp3:setScale(0.9)
        sp3:setOpacity(0)

        local sp4 = cc.Sprite:create('3d/1' .. fileName .. '.png')    
        sp4:setPosition3D(cc.vec3(layer.cardHeight/2,-layer.cardWidth/2,0))
        sp4:setRotation(270)
        sp4:setCameraMask(cc.CameraFlag.USER2)
        sp4:setOpacity(0)
        sp4:setScale(0.9)


        layer:addChild(sp1)
        layer:addChild(sp2)
        layer:addChild(sp3)
        layer:addChild(sp4)
        layer.valSp1 = sp1
        layer.valSp2 = sp2
        layer.valSp3 = sp3
        layer.valSp4 = sp4
        

        -----------------------------------------------------------------------------
        layer.finishTick1 = 0
        layer.finishTick2 = 0
        layer.flagHideLayer = false
        layer.updateF = Scheduler.new(function(dt)
            layer.finishTick1 = layer.finishTick1 + dt
            if layer.flagShowValueSp then
                layer.finishTick2 = layer.finishTick2 + dt
            end
            if layer.finishTick1 > 0 then
                if layer.actionFlag == 1.0 then 
                    onMoveJ1(layer.actionStep, layer.actionStep)
                    if layer.actionOffZ < layer.rubRadius*2 then
                        layer.actionOffZ = layer.actionOffZ + layer.actionStepZ
                        layer.actionStepZ = layer.actionStepZ + 0.05
                    end
                end
                if layer.actionFlag == 2.0 then 
                    if layer.actionOffZ >= -layer.rubRadius*2 then
                        layer.actionOffZ = layer.actionOffZ - layer.actionStepZ1
                        layer.actionStepZ1 = layer.actionStepZ1 + 0.6
                    elseif layer.flagShowValueSp == false then
                        layer.flagShowValueSp = true
                    end
                end
                layer.finishTick1 = 0
            end
            if layer.finishTick2 > 1.5 and layer.flagHideLayer == false then
                layer.flagHideLayer = true
                self:freshCuoPaiDisplay(false)
                self:onMessageState({msgID = 'clickFanPai'})
            end
        end)

        --------------------------------------------------------------------------------------------------------------------------------

        local cardMesh = {{id1, msh1, nVerts1}, {id2, msh2, nVerts2}, {id3, msh3, nVerts3}, {id3, msh4, nVerts4}}
        local function draw(transform, transformUpdated)
            gl.enable(gl.CULL_FACE)
            glProgram:use()
            glProgram:setUniformsForBuiltins()

            for idx, v in ipairs(cardMesh) do
                repeat
                    if idx > 2 and not layer.flagShowValueSp then break end
                
                gl.bindTexture(gl.TEXTURE_2D, v[1])--id

                local cardWidth = gl.getUniformLocation(glProgram:getProgram(), "cardWidth")
                glProgram:setUniformLocationF32(cardWidth, layer.cardWidth)
                local cardHeight = gl.getUniformLocation(glProgram:getProgram(), "cardHeight")
                glProgram:setUniformLocationF32(cardWidth, layer.cardHeight)

                local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
                glProgram:setUniformLocationF32(offx, layer.offX)
                local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
                glProgram:setUniformLocationF32(offy, layer.offY)

                local mode = gl.getUniformLocation(glProgram:getProgram(), "mode")
                glProgram:setUniformLocationF32(mode, layer.mode)

                local rubRadius = gl.getUniformLocation(glProgram:getProgram(), "rubRadius")
                glProgram:setUniformLocationF32(rubRadius, layer.rubRadius)

                local k1 = gl.getUniformLocation(glProgram:getProgram(), "k1")
                glProgram:setUniformLocationF32(k1, layer.k1)
                local j1 = gl.getUniformLocation(glProgram:getProgram(), "j1")
                glProgram:setUniformLocationF32(j1, layer.j1)
                local j2 = gl.getUniformLocation(glProgram:getProgram(), "j2")
                glProgram:setUniformLocationF32(j2, layer.j2)

                local actionRad = gl.getUniformLocation(glProgram:getProgram(), "actionRadius")
                glProgram:setUniformLocationF32(actionRad, layer.actionR)
                local actionFlag = gl.getUniformLocation(glProgram:getProgram(), "actionFlag")
                glProgram:setUniformLocationF32(actionFlag, layer.actionFlag)

                local actionOffX = gl.getUniformLocation(glProgram:getProgram(), "actionOffX")
                glProgram:setUniformLocationF32(actionOffX, layer.actionOffX)
                local actionOffY = gl.getUniformLocation(glProgram:getProgram(), "actionOffY")
                glProgram:setUniformLocationF32(actionOffY, layer.actionOffY)
                local actionOffZ = gl.getUniformLocation(glProgram:getProgram(), "actionOffZ")
                glProgram:setUniformLocationF32(actionOffZ, layer.actionOffZ)

                local actionOffX1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffX1")
                glProgram:setUniformLocationF32(actionOffX1, layer.actionOffX1)
                local actionOffY1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffY1")
                glProgram:setUniformLocationF32(actionOffY1, layer.actionOffY1)
                local actionOffZ1 = gl.getUniformLocation(glProgram:getProgram(), "actionOffZ1")
                glProgram:setUniformLocationF32(actionOffZ1, layer.actionOffZ1)
                
                gl.glEnableVertexAttribs(bit._or(cc.VERTEX_ATTRIB_FLAG_TEX_COORDS, cc.VERTEX_ATTRIB_FLAG_POSITION))
                
                gl.bindBuffer(gl.ARRAY_BUFFER, v[2][1]) 
                gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0)
                
                gl.bindBuffer(gl.ARRAY_BUFFER, v[2][2]) 
                gl.vertexAttribPointer(cc.VERTEX_ATTRIB_TEX_COORD, 2, gl.FLOAT, false, 0, 0)
                
                gl.drawArrays(gl.TRIANGLES, 0, v[3]/2) 

                until true
            end
            gl.bindTexture(gl.TEXTURE_2D, 0)
            gl.bindBuffer(gl.ARRAY_BUFFER, 0)
        end

        glNode:registerScriptDrawHandler(draw)
        
        return layer
    end
    local layer = createRubCardEffectLayer("", backPath, cardPath, 0.8)
    self.cpLayer:addChild(layer, 999)
    self.rubLayer = layer
end

function QZDeskView:remove3dLayer()
    if self.rubLayer then
        self.rubLayer:removeFromParent()
        self.rubLayer = nil
    end
end

function QZDeskView:freshCuoPaiDisplay(bool, data)
    if bool then
        self:remove3dLayer()
        self:showCardsAtCuopai(data)
        self:init3dLayer(data[5])
        self.cpLayer:setVisible(true)
    else
        self:remove3dLayer()
        self.cpLayer:setVisible(false)
    end
end

return QZDeskView
