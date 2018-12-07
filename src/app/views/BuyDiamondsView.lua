local tools = require('app.helpers.tools')
local testluaj = nil
local luaoc = nil 
if device.platform == 'android' then
    testluaj = require('app.models.luajTest')--引入luajTest类
    --print('android luaj 导入成功')
elseif device.platform == 'ios' then
    luaoc = require('cocos.cocos2d.luaoc')
end

local  BuyDiamondsView = {}
function BuyDiamondsView:initialize()
end


function BuyDiamondsView:layout()
  self.ui:setPosition(display.cx,display.cy)
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width,display.height))
  self.ui:getChildByName('MainPanel'):getChildByName('Content'):getChildByName('copy'):setPressedActionEnabled(true)
end

function BuyDiamondsView:onClickCopy()
    if testluaj then
      print('android 1111111111111111111111111111111111111111111111111111111111') 
      -- "getNetInfo"
      --local ok netInfo = self.luaj.callStaticMethod(javaClassName, javaMethodName, args, javaMethodSig)
      --在这里尝试调用android static代码
      local testluajobj = testluaj.new(self)
      local ok, ret1 = testluajobj.callandroidCopy(self, "");
      print("7777777777777".. ret1)
      if ok then 
        tools.showRemind('已复制')
      else
        tools.showRemind('未复制')
      end
  end
  if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "copyToClipboard",{ww=''})
      if ok then 
        tools.showRemind('已复制')
      else
        tools.showRemind('未复制')
      end
  end
end

return BuyDiamondsView
