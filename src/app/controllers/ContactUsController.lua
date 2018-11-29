local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local tools = require('app.helpers.tools')
local testluaj = nil
local luaoc = nil 
if device.platform == 'android' then
  testluaj = require('app.models.luajTest')--引入luajTest类
  --print('android luaj 导入成功')
elseif device.platform == 'ios' then
  luaoc = require('cocos.cocos2d.luaoc')
end
local ContactUsController = class("ContactUsController", Controller):include(HasSignals)

function ContactUsController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function ContactUsController:viewDidLoad()
  local app = require("app.App"):instance()
  local user = app.session.user
  self.view:layout()

  
end

function ContactUsController:clickBack()
  self.view:stopCsdAnimation()
  self.emitter:emit('back')
end

function ContactUsController:finalize()-- luacheck: ignore
 
end

function ContactUsController:clickCopyQQNum()
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

function ContactUsController:clickCopyGZNum()
  if testluaj then
    print('android 1111111111111111111111111111111111111111111111111111111111') 
    -- "getNetInfo"
    --local ok netInfo = self.luaj.callStaticMethod(javaClassName, javaMethodName, args, javaMethodSig)
    --在这里尝试调用android static代码
    local testluajobj = testluaj.new(self)
    local ok, ret1 = testluajobj.callandroidCopy(self, "Aw587431");
    print("7777777777777".. ret1)
    if ok then 
      tools.showRemind('已复制')
    else
      tools.showRemind('未复制')
    end
  end
  if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "copyToClipboard",{ww='Aw587431'})
      if ok then 
        tools.showRemind('已复制')
      else
        tools.showRemind('未复制')
      end
  end
end

function ContactUsController:clickCopyQQKefu()
  if testluaj then
    print('android 1111111111111111111111111111111111111111111111111111111111') 
    -- "getNetInfo"
    --local ok netInfo = self.luaj.callStaticMethod(javaClassName, javaMethodName, args, javaMethodSig)
    --在这里尝试调用android static代码
    local testluajobj = testluaj.new(self)
    local ok, ret1 = testluajobj.callandroidCopy(self, "1354097688");
    print("7777777777777".. ret1)
    if ok then 
      tools.showRemind('已复制')
    else
      tools.showRemind('未复制')
    end
  end
  if luaoc then
      local ok,ret = luaoc.callStaticMethod("AppController", "copyToClipboard",{ww='1354097688'})
      if ok then 
        tools.showRemind('已复制')
      else
        tools.showRemind('未复制')
      end
  end
end

return ContactUsController
