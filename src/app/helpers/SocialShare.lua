local SocialShare = {}
local social = require('social')
--local fu = cc.FileUtils:getInstance()

local all_platforms = {
    'Wechat',           --  1 微信
    'WechatMoments',    --  2 微信朋友圈
    'QZone',            --  4 QQ空间
    'Weibo',            --  0 新浪微博
    'QQ'                --  6 QQ好友
}

local called = false

function SocialShare.share(
  tag,                     -- 平台
  call,                    -- 分享成功的回调
  share_url,               -- 分享的url
  image_url,               -- 如果设置那么使用此url替代本地图片
  text,                    -- 分享的文本
  title,                    -- 分享的标题
  onlyImage
)
  local url = share_url
  if not onlyImage then onlyImage = false end

  local targetplatform = cc.Application:getInstance():getTargetPlatform()
  if tag == 4 then-- weibo
    if targetplatform == 3 then
      text = text .. url
    end
  end

  called = false

  local options = {
      text = text,
      title = title, -- Optional, and not all platform support title.
      image = image_url,
      ui = false, -- Optional. Wheather to show the share UI. default true. false to share directly without UI.
      platform = all_platforms[tag], -- Needed only when ui is false.
      url = url, -- Optional, and not all platform support title.
      onlyImage = onlyImage
  }
  dump(options)

  local function go()
    social.share(options, function(platform,stCode,errorMsg)
      if stCode == 100 then return end

      if called then return end
      if stCode == 200 then
        called = true
      end

      print('###################stCode errorMsg ',stCode,errorMsg)
      call(platform,stCode,errorMsg)
    end)
  end
  go()
end

return SocialShare
