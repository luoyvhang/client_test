local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local BuyDiamondsController = class("BuyDiamondsController", Controller):include(HasSignals)
local tools = require('app.helpers.tools')


function BuyDiamondsController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function BuyDiamondsController:viewDidLoad()
  self.view:layout()

end

function BuyDiamondsController:clickBack()
  self.emitter:emit('back')
end

function BuyDiamondsController:clickCopy()
  self.view:onClickCopy()
  -- if testluaj then
  --       print('android 1111111111111111111111111111111111111111111111111111111111') 
  --       -- "getNetInfo"
  --       --local ok netInfo = self.luaj.callStaticMethod(javaClassName, javaMethodName, args, javaMethodSig)
  --       --在这里尝试调用android static代码
  --       local testluajobj = testluaj.new()
  --       local ok, ret1 = testluajobj.callandroidCopy("ADFZ88888");
  --       print("7777777777777".. ret1)
  --       if ok then 
  --         tools.showRemind('已复制')
  --       else
  --         tools.showRemind('未复制')
  --       end
  -- end
end

function BuyDiamondsController:finalize()-- luacheck: ignore
end

return BuyDiamondsController
