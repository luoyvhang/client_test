local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local cjson = require('cjson')
local SoundMng = require('app.helpers.SoundMng')
local CreateRoomController = class("CreateRoomController", Controller):include(HasSignals)

function CreateRoomController:initialize(groupInfo, createmode,paymode)
    Controller.initialize(self)
    HasSignals.initialize(self)
    self.groupInfo = groupInfo
    self.createmode = createmode
    self.paymode = 1
    if paymode then 
        self.paymode = paymode.payMode 
    end
end

function CreateRoomController:viewDidLoad()
    local app = require("app.App"):instance()
    self.view:layout(self.groupInfo, self.createmode,self.paymode)
    self.listener = {
        app.session.room:on('createRoom', function(msg)
            if msg.errorCode then
                self:delShowWaiting()
            end
            if msg.enterOnCreate and msg.enterOnCreate == 1 then
                -- self:clickBack()
                self:delShowWaiting()
            end
        end),

        app.session.room:on('Group_setRoomConfigResult', function(msg)
            self:clickBack()
        end),    

        app.session.room:on('roomConfigFlag', function(msg)
            self.view:freshHasSave(msg.data)
        end)            
    }

    if self.groupInfo then
        app.session.room:roomConfigFlag(self.groupInfo)
    end
end

function CreateRoomController:finalize()-- luacheck: ignore
    for i = 1, #self.listener do
        self.listener[i]:dispose()
    end
end

function CreateRoomController:clickCreate()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    local gameIdx
    local gameplay = options.gameplay
    if gameplay == 4 or gameplay == 6 or gameplay == 7 or gameplay == 8 then
        gameIdx = app.session.niumowangqz.gameIdx
    else
        gameIdx = app.session.niumowang.gameIdx
    end

    self.view:showWaiting()

    app.session.room:createRoom(gameIdx, options, self.groupInfo)
end

function CreateRoomController:clickQuickStart()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    local gameIdx
    local gameplay = options.gameplay
    if gameplay == 4 or gameplay == 6 or gameplay == 7 or gameplay == 8 then
        gameIdx = app.session.niumowangqz.gameIdx
    else
        gameIdx = app.session.niumowang.gameIdx
    end 

    self.view:showWaiting()

    app.session.room:quickStart(self.groupInfo, gameplay, gameIdx)
end

function CreateRoomController:clickSureBtn()
    local app = require("app.App"):instance()
    local options = self.view:getOptions()

    local gameIdx
    local gameplay = options.gameplay
    if gameplay == 4 or gameplay == 6 or gameplay == 7 or gameplay == 8 then
        gameIdx = app.session.niumowangqz.gameIdx
    else
        gameIdx = app.session.niumowang.gameIdx
    end
    app.session.room:roomConfig(gameplay, options, self.groupInfo)
end

function CreateRoomController:clickBack()
    self.emitter:emit('back')
end

------------------------------------------------------------------------------------------
--三个问号提示的点击事件
function CreateRoomController:clickRoomPriceLayer()
    self.view:freshPriceLayer(false) 
end
function CreateRoomController:clickPriceWhy()
    self.view:freshPriceLayer(true) 
end

function CreateRoomController:clickTuiZhuLayer()
    self.view:freshTuiZhuLayer(false) 
end
function CreateRoomController:clickTuiZhuWhy()
    self.view:freshTuiZhuLayer(true) 
end

function CreateRoomController:clickXiaZhuLayer()
    self.view:freshXiaZhuLayer(false) 
end
function CreateRoomController:clickXiaZhuWhy()
    self.view:freshXiaZhuLayer(true) 
end

function CreateRoomController:clickquickLayer()
    self.view:freshquickLayer(false) 
end
function CreateRoomController:clickquickWhy()
    self.view:freshquickLayer(true) 
end

function CreateRoomController:clickWangLaiLayer()
    self.view:freshWangLaiLayer(false) 
end
function CreateRoomController:clickWangLaiWhy(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshWangLaiLayer(true, data) 
end

--两个模式的点击事件
function CreateRoomController:clickSpecialLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshSpecialLayer(false,body) 
end
function CreateRoomController:clickSpecialSelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshSpecialLayer(true,body) 
end

function CreateRoomController:clickMultiplyLayer(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshMultiplyLayer(false,body) 
end
function CreateRoomController:clickMultiplySelect(sender)
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    local body = cjson.decode(data)
    self.view:freshMultiplyLayer(true,body) 
end
--------------------------------------------------------------------------------------------

function CreateRoomController:clickNotOpen()
    local tools = require('app.helpers.tools')
    tools.showRemind('暂未开放，敬请期待')
end

--------------------------------------------------------------------------------------------
--左边选择模式点击事件
function CreateRoomController:clickchangetype(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshTab(data)
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--各模式的刷新事件
function CreateRoomController:clickBase(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshbase(data,sender)
end

function CreateRoomController:clickRound(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshround(data,sender)
end

function CreateRoomController:clickroomPrice(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshroomPrice(data,sender)
end

function CreateRoomController:clickMultiply(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshmultiply(data,sender)
end

function CreateRoomController:clickSpecial(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshspecialnow(data,sender)
end

function CreateRoomController:clickqzMax(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshqzMax(data,sender)
end

function CreateRoomController:clickstartMode(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshstartMode(data,sender)
end

function CreateRoomController:clickputMoney(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshputmoney(data,sender)
end

function CreateRoomController:clickAdvanced(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshadvancednow(data,sender)
end

function CreateRoomController:clickWanglai(sender)
    SoundMng.playEft('btn_click.mp3')
    local data = sender:getComponent("ComExtensionData"):getCustomProperty()
    self.view:freshwanglai(data,sender)
end

-------------------------------------------------------------------------------------

return CreateRoomController
