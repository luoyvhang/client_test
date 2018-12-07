local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local BuyCardController = class("BuyCardController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')

function BuyCardController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function BuyCardController:viewDidLoad()
  self.view:layout()

  local app = require("app.App"):instance()
  self.listener = {
    app.session.user:on('presentcomplete',function()
      tools.showRemind('赠送成功')
    end)
  }
end

function BuyCardController:clickBack()
  self.emitter:emit('back')
end

function BuyCardController:clickSub()
  self.view:clickSub()
end

function BuyCardController:clickAdd()
  self.view:clickAdd()
end

function BuyCardController:sendCard()
  local app = require("app.App"):instance()
  local targetId = self.view:getTargetPlayerId()
  targetId = tonumber(targetId)

  if targetId == nil then
    tools.showRemind('请输入对方的Id')
    return
  end

  local cnt = self.view:getSendCardCnt()
  if cnt == 0 then
    tools.showRemind('房卡数量为0')
    return
  end

  app.session.user:present(targetId,cnt)
end

function BuyCardController:finalize()-- luacheck: ignore
end

return BuyCardController
