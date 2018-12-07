local tools = require('app.helpers.tools')
local SoundMng = require('app.helpers.SoundMng')
local app = require("app.App"):instance()

local SettingView = {}

function SettingView:initialize()
  self.deskView = nil
end

function SettingView:layout(data)
  self.ui:setPosition(display.cx, display.cy)
  local MainPanel = self.ui:getChildByName('MainPanel')
  MainPanel:setContentSize(cc.size(display.width, display.height))
  self.MainPanel = MainPanel

  local bg = MainPanel:getChildByName('bg')
  local bgGame = MainPanel:getChildByName('bgGame')
  local zhuomian = bgGame:getChildByName('zhuomian')  
  local paibei = bgGame:getChildByName('paibei') 
  local qumu = bgGame:getChildByName('qumu') 
  self.zhuomian = zhuomian 
  self.paibei = paibei      
  self.qumu = qumu      
  self.bg = nil
  local function freshBgGame(deskView)  
    local idx = deskView:getCurDesktop()
    self:freshDesktopSelect(idx)

    for i = 1, 4 do
        local yanse = zhuomian:getChildByName('yanse'..i)
        yanse:addClickEventListener(function()
          self:changeDesktop(i, deskView)
        end)
    end  
  end
  local function freshPbGame()  
    local idx = self:getCurCuoPai()
    self:freshPaibeiSelect(idx) 
    for i = 1, 4 do
        local yanse = paibei:getChildByName('yanse'..(i+4))
        yanse:addClickEventListener(function()
          self:changePaibei(i)
        end)
    end 
  end
  if data and data[1] == 'gameSetting' then
    self.deskView = data[2]
    bgGame:setVisible(true)
    bg:setVisible(false)
    self.bg = bgGame
    freshBgGame(data[2])
    freshPbGame()
  else
    bgGame:setVisible(false)
    bg:setVisible(true)
    self.bg = bg
  end

  local bgm, sfx = SoundMng.getVol()

  local sound = self.bg:getChildByName('sound')
  local progress = sound:getChildByName('progress')
  progress:addEventListener(function(_, eventType)
    if eventType == 2 then
        local per = progress:getPercent()
        SoundMng.setSfxVol(per / 100)

        if per == 0 then
          SoundMng.setEftFlag(false)
        else
          SoundMng.setEftFlag(true)
        end
    end
  end)
  progress:setPercent(sfx * 100)

  local music = self.bg:getChildByName('music')
  local bgmprogress = music:getChildByName('progress')
  bgmprogress:addEventListener(function(_, eventType)
    if eventType == 2 then
        local per = bgmprogress:getPercent()
        SoundMng.setBgmVol(per / 100)

        if per == 0 then
          SoundMng.setBgmFlag(false)
        else
          SoundMng.setBgmFlag(true)
        end
    end
  end)
  bgmprogress:setPercent(bgm * 100)
end

function SettingView:changeTexiao()
	local texiao = self.bg:getChildByName("texiao")
	local on = texiao:getChildByName('on')
  local off = texiao:getChildByName('off')
  on:setVisible(not on:isVisible())
  off:setVisible(not off:isVisible())
end

function SettingView:changeMusic(b)
	local music = self.bg:getChildByName("music")
	
	music:getChildByName("on"):setVisible(not b)
	music:getChildByName("off"):setVisible(b)
end

function SettingView:changeSound(b)
	local sound = self.bg:getChildByName("sound")
	sound:getChildByName("on"):setVisible(not b)
	sound:getChildByName("off"):setVisible(b)
end

function SettingView:changeDesktop(idx, deskView)
  deskView:changeDesktop(idx)
  self:freshDesktopSelect(idx)
end

function SettingView:changePaibei(idx)
  self:setCurCuoPai(idx)
  self:freshPaibeiSelect(idx)
  self.deskView:changeCardBack()
end

function SettingView:freshQumuSelect(data)
  local opt = self.qumu:getChildByName('opt')
  for i = 1, 6 do
    opt:getChildByName('' .. i):getChildByName('active'):setVisible(false)
  end
  opt:getChildByName('' .. data):getChildByName('active'):setVisible(true)
  SoundMng.setPlaying(false)
  SoundMng.playBgm('table_bgm' .. data .. '.mp3')
end

function SettingView:freshQumuOpt(bool)
  local on = self.qumu:getChildByName('on')
  local opt = self.qumu:getChildByName('opt')
  on:getChildByName('active'):setVisible(bool)
  opt:setVisible(bool)
end

function SettingView:freshDesktopSelect(idx)
  idx = idx or 1
  for i = 1, 4 do
    if i == idx then
      self.zhuomian:getChildByName('yanse'..i):getChildByName('gouxuan'..i):setVisible(true) 
    else
      self.zhuomian:getChildByName('yanse'..i):getChildByName('gouxuan'..i):setVisible(false) 
    end
  end
end

function SettingView:freshPaibeiSelect(idx)
  idx = idx or 1
  for i = 1, 4 do
    if i == idx then
      self.paibei:getChildByName('yanse'..(i+4)):getChildByName('gouxuan'..(i+4)):setVisible(true) 
    else
      self.paibei:getChildByName('yanse'..(i+4)):getChildByName('gouxuan'..(i+4)):setVisible(false) 
    end
  end
end

function SettingView:setCurCuoPai(idx)
  local app = require("app.App"):instance()
  app.localSettings:set('cuoPai', idx)
end

function SettingView:getCurCuoPai()
  local app = require("app.App"):instance()
  local idx = app.localSettings:get('cuoPai')
  idx = idx or 1
  return idx
end

return SettingView
