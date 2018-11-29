local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local SettingController = class("SettingController", Controller):include(HasSignals)
local SoundMng = require('app.helpers.SoundMng')

function SettingController:initialize(data)
  Controller.initialize(self)
  HasSignals.initialize(self)
  self.data = data
end

function SettingController:viewDidLoad()
  self.view:layout(self.data)
  self.view:changeMusic(SoundMng.getEftFlag(SoundMng.type[1]))
  self.view:changeSound(SoundMng.getEftFlag(SoundMng.type[2]))
end

function SettingController:clickBack()
  SoundMng.playEft('btn_click.mp3')
  self.emitter:emit('back')
end

function SettingController:clickChange()
  SoundMng.playEft('btn_click.mp3')
  self.emitter:emit('loginSuccess')
end

function SettingController:clickTexiao()
  SoundMng.playEft('btn_click.mp3')
  self.view:changeTexiao()
end 

function SettingController:clickSound()
	local b = not SoundMng.getEftFlag(SoundMng.type[2])
	
	SoundMng.setEftFlag(b)
	self.view:changeSound(b)
end

function SettingController:clickMusic()
	local b = not SoundMng.getEftFlag(SoundMng.type[1])
	
	SoundMng.setBgmFlag(b)
	self.view:changeMusic(b)
end 

function SettingController:clickQumu(sender)
  local data = sender:getComponent("ComExtensionData"):getCustomProperty()
  self.view:freshQumuSelect(data)
end 

function SettingController:clickShowQumu()
  self.view:freshQumuOpt(true)
end 

function SettingController:clickHideQumu()
  self.view:freshQumuOpt(false)
end 

function SettingController:finalize()-- luacheck: ignore
end

function SettingController:clickButton()
  SoundMng.playEft('btn_click.mp3')
  self.emitter:emit('clickBtn')
end

function SettingController:clickHide()
  SoundMng.playEft('btn_click.mp3')
  self.emitter:emit('back')
end

function SettingController:clickChange()
  SoundMng.playEft('btn_click.mp3')
  if device.platform == 'android' or device.platform == 'ios' then
    local social_umeng = require('social')
    social_umeng.deauthorize('wechat', function()end)
  end

  local app = require("app.App"):instance()
  app.localSettings:set('uid', nil)
  app.session.net:setHookClose(function()
    app.session.net:setHookClose(nil)
    app:switch('LoginController')
  end)
  app.conn:close()
end

function SettingController:clickConfirm()
  self:delete()
end

return SettingController
