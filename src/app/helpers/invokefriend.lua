local SocialShare = {}

if device.platform ~= "windows" then
    SocialShare = require("app.helpers.SocialShare")
end

local GameLogic = require("app.libs.niuniu.NNGameLogic")

local invokefriend = {}

function invokefriend.invoke(deskId, deskInfo,groupInfo)
	if not deskId then return end
	if not deskInfo then return end

  --支付方式
  local roomprice = GameLogic.getPayModeText(deskInfo) .. '支付'
  -- 玩法
  local gameplayStr = GameLogic.getGameplayText(deskInfo)
  -- 底分
  local baseStr = GameLogic.getBaseText(deskInfo)
  -- 翻倍规则
  local mulStr = GameLogic.getNiuNiuMulText(deskInfo)
  -- 房间规则
  local advanceStr = GameLogic.getAdvanceText(deskInfo)
  -- 特殊牌
  local spStr = GameLogic.getSpecialText(deskInfo, 3, true)

	
  local share_url = 'http://nnstart.qiaozishan.com/download'
  local image_url = 'http://192.168.1.5/icon.png'
	

	-- 分享标题
	local title = "快乐牛牛启航版【房间号：" .. deskId .. "】"

	-- 分享详情 
	local text = string.format(" 底分：%s, %d局, %s, %s, %s", 
		baseStr, 
    	deskInfo.round,
    	roomprice,
		gameplayStr,
		spStr
	)
	if groupInfo then
		text = string.format("俱乐部：%d, 底分：%s, %d局, %s, %s, %s", 
		groupInfo.id,
		baseStr, 
    	deskInfo.round,
    	roomprice,
		gameplayStr,
		spStr
	)
	end
	if device.platform ~= "windows" then
		SocialShare.share(
			1,
			function(platform, stCode, errorMsg)
				print("platform,stCode,errorMsg", platform, stCode, errorMsg)
			end,
			share_url,
			image_url,
			text,
			title
		)
	end
end

return invokefriend
