local FrameAction = {}

function FrameAction.create(format,cnt,startIdx,delay,loop,restore)
  if not startIdx then
    startIdx = 0
  end

  if not delay then
    delay = 0.1
  end

  if not loop then
    loop = 0xffffffff
  end

  if restore == nil then
    restore = true
  end

  local sprcaceh = cc.SpriteFrameCache:getInstance()
  local animation = cc.Animation:create()

  for i = 1,cnt do
    local path = string.format(format, startIdx + (i - 1))
    local frame = sprcaceh:getSpriteFrame(path)
    if frame then
      animation:addSpriteFrame(frame)
    else
      animation:addSpriteFrameWithFile(path)
    end
  end

  animation:setLoops(loop)
  animation:setDelayPerUnit(delay)
  animation:setRestoreOriginalFrame(restore)

  local frameAction = cc.Animate:create(animation)
  return frameAction
end

function FrameAction.createByRect(cnt,format,width,height,delay)
  local allFrames = cc.Animation:create();

  for i = 1, cnt do
    local buffer = string.format(format,i);
    local rect = cc.rect(0,0,width,height);
    local frame = cc.SpriteFrame:create(buffer,rect);
    allFrames:addSpriteFrame(frame);
  end
  allFrames:setDelayPerUnit(delay)
  return cc.Animate:create(allFrames);
end

return FrameAction
