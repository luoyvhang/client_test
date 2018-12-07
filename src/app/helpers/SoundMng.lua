local SoundMng = {}
--local audio = require('cocos.framework.audio')

local bgmVol = 0.6
local sfxVol = 0.6
local bgmId = nil

function SoundMng.load()
  local app = require("app.App"):instance()
  local vol = app.localSettings:get('bgmVol')
  if not vol then
    vol = 0.6
  end

  bgmVol = vol
  --audio.setMusicVolume(bgmVol)
  if bgmId then
    ccexp.AudioEngine:setVolume(bgmId, vol)
  end
  vol = app.localSettings:get('sfxVol')
  if not vol then
    vol = 0.6
  end
  sfxVol = vol
  --audio.setSoundsVolume(sfxVol)
end

function SoundMng.setSfxVol(vol)
  sfxVol = vol
  --audio.setSoundsVolume(sfxVol)

  local app = require("app.App"):instance()
  app.localSettings:set('sfxVol',sfxVol)
end

function SoundMng.setBgmVol(vol)
  bgmVol = vol
  --audio.setMusicVolume(bgmVol)
  if bgmId then
    ccexp.AudioEngine:setVolume(bgmId, vol)
  end
  local app = require("app.App"):instance()
  app.localSettings:set('bgmVol',bgmVol)
end

function SoundMng.getVol()
  return bgmVol,sfxVol
end

SoundMng.type = {
  "bgmFlag",
  "eftFlag",
}

local function setEnabled(key, b)
  local app = require("app.App"):instance()
  app.localSettings:set(key, b)
end

function SoundMng.setBgmFlag(flag)
  setEnabled(SoundMng.type[1], flag)
  if flag then
    local cache = SoundMng.cacheFile
    SoundMng.cacheFile = nil
    if cache then
      SoundMng.playBgm(cache)
    end
  else
    SoundMng.playing = false
    --audio.stopMusic()
    if bgmId then
      ccexp.AudioEngine:stop(bgmId)
      bgmId = nil
    end
  end
end

function SoundMng.setEftFlag(b)
  setEnabled(SoundMng.type[2], b)
end

local function getEnabled(key)
  local app = require("app.App"):instance()
  local enable = app.localSettings:get(key)
  if enable == nil then enable = true end
  return enable
end

function SoundMng.getEftFlag(k)
  return getEnabled(k)
end

local function check(path, key)
  if not path then
    return false
  end

  if not getEnabled(key) then
    return false
  end

  if device.platform  == "mac" then
    return true
  end
  return true
end

function SoundMng.playBgm(path)
  SoundMng.cacheFile = path
  if check(path, SoundMng.type[1]) then
    local file = "sound/"..path
    if SoundMng.playing and SoundMng.cacheFile == path then
      return
    end
    SoundMng.playing = true
    --audio.playMusic(file)
    if bgmId then
      ccexp.AudioEngine:stop(bgmId)
    end
    bgmId = ccexp.AudioEngine:play2d(file, true, bgmVol)
  end
end

function SoundMng.playEft(path)
  if check(path, SoundMng.type[2]) then
    --audio.playSound("sound/"..path)
    ccexp.AudioEngine:play2d("sound/"..path, false, sfxVol)
  end
end

function SoundMng.setPlaying(b)
   SoundMng.playing = b
end


function SoundMng.isPauseVol(b)
  local app = require("app.App"):instance()
  if b then
      --audio.setMusicVolume(0)
      --audio.setSoundsVolume(0)
      ccexp.AudioEngine:pauseAll()
  else
      --audio.setMusicVolume(app.localSettings:get('bgmVol'))
      --audio.setSoundsVolume(app.localSettings:get('sfxVol'))
      ccexp.AudioEngine:resumeAll()
  end
end

-- 使用 AudioEngine 播放声音
function SoundMng.playEftEx(path)
  if check(path, SoundMng.type[2]) then
    ccexp.AudioEngine:play2d("sound/"..path, false, sfxVol)
  end
end

function SoundMng.playVoice(path)
  ccexp.AudioEngine:play2d(path, false, 1)
end

return SoundMng
