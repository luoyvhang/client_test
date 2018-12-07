local class = require('middleclass')
local Controller = require('mvc.Controller')
local UpdateController = class("UpdateController", Controller)
local tools = require('app.helpers.tools')


local Updater = require('Updater')
local L -- lazy load locales


function UpdateController:initialize() -- luacheck: ignore self
  L = require('locale').get()
end

function UpdateController:finalize() -- luacheck: ignore self
  print('finalized....')
end


function UpdateController:viewDidLoad()
  local app = require("app.App"):instance()
  local config = require('config')

  self.view:showMessage(L['检查更新…'])
  local errors = {
    v = L['获取版本失败。'],
    index = L['获取列表失败。'],
    download = L['下载更新文件失败。']
  }

  local updater = Updater:new(config.update)
  updater:on('error', function(info)
    local message = errors[info] or L['未知错误。']
    tools.showMsgBox(L['更新错误'],message..L['请检查网络']):next(function(key)
      if key == 'enter' then
        app:restart('UpdateController')
      end
    end)
  end)
  updater:once('major', function()
    -- tools.showMsgBox(L['好消息'],L['发现新版本，请在应用商店里面更新以便进入游戏。'])
    tools.showMsgBox("好消息", "发现新版本，请在应用商店里面更新以便进入游戏。",2):next(function(btn)
      if btn == 'enter' then
          cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
          local config = require('config')
          if device.platform == 'ios' then
            local luaoc = require('cocos.cocos2d.luaoc')
            if luaoc then
                luaoc.callStaticMethod("AppController", "openURL",{url=config.download})
            end
          elseif device.platform == 'android' then
            local luaj = require("cocos.cocos2d.luaj") --引入luaj
            local className="org.cocos2dx.lua.AppActivity"  
            local args = {config.download}  
            local sigs = "(Ljava/lang/String;)V"
            luaj.callStaticMethod(className,"openURL",args,sigs)  
          end
      end
      if device.platform == 'ios' then
          local luaoc = nil
          luaoc = require('cocos.cocos2d.luaoc')
          if luaoc then
              luaoc.callStaticMethod("AppController", "clickExit",{ww='luidan19999188'})
          end
      else
          cc.Director:getInstance():endToLua()
      end
    end)
  end)
  updater:once('nothing', function()
    print('nothing')
    app.version = updater.current.version
    app:restart('LoginController',updater.current.version)
  end)
  updater:once('update', function()
    self.view:showMessage(L['正在更新…'])
    self.view:showProgress(0)
  end)
  updater:on('progress', function(rate)
    self.view:showProgress(rate*100)
  end)
  updater:on('done', function()
    print('done')
    self.view:showMessage(L['更新成功'])
    print('update OK')
    app.version = updater.remote
    app:restart('LoginController',updater.remote)
  end)

  updater:run()
end


return UpdateController
