local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local ShopController = class("ShopController", Controller):include(HasSignals)

function ShopController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function ShopController:viewDidLoad()
  self.view:layout()

  self.view:on('buy',function(entry,mul)
    local rmb = entry[1]
    local gem = entry[2]

    local Pay = require('pay.pay')
    Pay.go(rmb*mul,function(success)
      if success then
        local app = require("app.App"):instance()
        app.session.user:paySuccess(gem*mul,rmb*mul)
      end
    end)

    self.emitter:emit('back')
  end)
end

function ShopController:clickBack()
  self.emitter:emit('back')
end

function ShopController:finalize()-- luacheck: ignore
end

return ShopController
