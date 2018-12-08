local GameLogic = {}

GameLogic.SPECIAL_LONG_TEXT= {
	SFLUSH = '快乐牛',
	WUXIAO = '五小牛',
	BOOM = '炸弹牛',
	HULU = '葫芦牛',
	TONGHUA = '同花牛',
	WUHUA_J = '五花牛',
	-- WUHUA_Y = '银牛',
	STRAIGHT = '顺子牛',
	BIYI = '比翼牛',
}

GameLogic.SPECIAL_SHORT_TEXT = {
	SFLUSH = '快乐牛',
	WUXIAO = '五小',
	BOOM = '炸弹',
	HULU = '葫芦',
	TONGHUA = '同花',
	WUHUA_J = '五花',
	-- WUHUA_Y = '银牛',
	STRAIGHT = '顺子',
	BIYI = '比翼',
}

GameLogic.SPECIAL_MUL_TEXT = {
	SFLUSH = "快乐牛(10倍) ",
	WUXIAO = "五小牛(9倍) ",
	BOOM = "炸弹牛(8倍) ",
	HULU = "葫芦牛(7倍) ",
	TONGHUA = "同花牛(6倍) ",
	WUHUA_J = "五花牛(5倍) ",
	STRAIGHT = "顺子牛(5倍) ",
	BIYI = "比翼牛(4倍)",
}

GameLogic.SPECIAL_MUL_TEXT7 = {
	SFLUSH = "快乐牛(10倍) ",
	WUXIAO = "五小牛(10倍) ",
	BOOM = "炸弹牛(10倍) ",
	HULU = "葫芦牛(10倍) ",
	TONGHUA = "同花牛(10倍) ",
	WUHUA_J = "五花牛(10倍) ",
	STRAIGHT = "顺子牛(10倍) ",
	BIYI = "比翼牛(10倍)",
}

GameLogic.NIUMUL_1 = '牛牛x4 牛九x3 牛八x2 牛七x2'
GameLogic.NIUMUL_2 = '牛牛x3 牛九x2 牛八x2'
GameLogic.NIUMUL_FK = '牛1~牛牛    1~10倍'

GameLogic.GAMEPLAY = {
  '牛牛上庄',
  '固定庄家',
  '自由抢庄',
  '明牌抢庄',
  '通比牛牛',
  '疯狂加倍',
  '八人明牌',
  '十人明牌',
}

GameLogic.STARTMODE = {
	'手动开始',
	'满4人开',
	'满5人开',
	'满6人开',
}

GameLogic.STARTMODE_BM = {
	'手动开始',
	'满6人开',
	'满7人开',
	'满8人开',
}

GameLogic.STARTMODE_SM = {
	'手动开始',
	'满8人开',
	'满9人开',
	'满10人开',
}

GameLogic.PUTMONEY = {
	'无推注',
	'5倍封顶',
	'10倍封顶',
	'15倍封顶',
}

GameLogic.PUTMONEY_ORDER = {
	'无',
	'5倍',
	'10倍',
	'15倍',
}

GameLogic.QZMAX = {
	'1倍',
	'2倍',
	'3倍',
	'4倍',
}

GameLogic.QZMAXINFO = {
	{1},
	{1,2},
	{1,2,3},
	{1,2,3,4},
}

GameLogic.BASE = {
	['1/2'] = '1/2',
	['2/4'] = '2/4',
	['3/6'] = '3/6',
	['4/8'] = '4/8',
	['5/10'] = '5/10',
}

GameLogic.BASEORDER = {
	[1] = '1/2',
	[2] = '2/4',
	[3] = '3/6',
	[4] = '4/8',
	[5] = '5/10',
}

GameLogic.BASEINFO = {
	['1/2'] = {1,2},
	['2/4'] = {2,4},
	['3/6'] = {3,6},
	['4/8'] = {4,8},
	['5/10'] = {5,10},
}

GameLogic.SPECIAL_EMUN = {
	SFLUSH = 8,
	WUXIAO = 7,
	BOOM = 6,
	HULU = 5,
	TONGHUA = 4,
	WUHUA_J = 3,
	STRAIGHT = 2,
	BIYI = 1,
	WUHUA_Y = - 1,
}

GameLogic.SPECIAL_EMUN7 = {
	SFLUSH = 8,
	WUXIAO = 7,
	BOOM = 6,
	HULU = 5,
	TONGHUA = 4,
	WUHUA_J = 3,
	STRAIGHT = 2,
	BIYI = 1,
	WUHUA_Y = - 1,
}

GameLogic.CLIENT_SETTING = {
	SFLUSH = 8,
	WUXIAO = 7,
	BOOM = 6,
	HULU = 5,
	TONGHUA = 4,
	WUHUA_J = 3,
	STRAIGHT = 2,
	BIYI = 1,
	WUHUA_Y = - 1,
}

GameLogic.CLIENT_SETTING7 = {
	SFLUSH = 8,
	WUXIAO = 7,
	BOOM = 6,
	HULU = 5,
	TONGHUA = 4,
	WUHUA_J = 3,
	STRAIGHT = 2,
	BIYI = 1,
	WUHUA_Y = - 1,
}


GameLogic.NIU_MULNUM = {
	[6] = {
		{[2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [10] = 10},
		{[2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [10] = 10},
	},
	default = {
		{[10] = 4, [9] = 3, [8] = 2, [7] = 2},
		{[10] = 3, [9] = 2, [8] = 2},
	}
}

GameLogic.SPECIAL_MULNUM = {
	[6] = {
		SFLUSH = 10,
		WUHUA_Y = 10,
		BOOM = 10,
		HULU = 10,
		WUHUA_J = 10,
		TONGHUA = 10,
		STRAIGHT = 10,
		BIYI = 10,
		WUXIAO = -1,
	},
	default = {
		SFLUSH = 10,
		WUXIAO = 9,
		BOOM = 8,
		HULU = 7,
		TONGHUA = 6,
		WUHUA_J = 5,
		STRAIGHT = 5,
		BIYI = 4,
		WUHUA_Y = - 1,
	}
}

GameLogic.CARDS = {
	['♠A'] = 1, ['♠2'] = 2, ['♠3'] = 3, ['♠4'] = 4, ['♠5'] = 5,
	['♠6'] = 6, ['♠7'] = 7, ['♠8'] = 8, ['♠9'] = 9,
	['♠T'] = 10, ['♠J'] = 10, ['♠Q'] = 10, ['♠K'] = 10,
	
	['♥A'] = 1, ['♥2'] = 2, ['♥3'] = 3, ['♥4'] = 4, ['♥5'] = 5,
	['♥6'] = 6, ['♥7'] = 7, ['♥8'] = 8, ['♥9'] = 9,
	['♥T'] = 10, ['♥J'] = 10, ['♥Q'] = 10, ['♥K'] = 10,
	
	['♣A'] = 1, ['♣2'] = 2, ['♣3'] = 3, ['♣4'] = 4, ['♣5'] = 5,
	['♣6'] = 6, ['♣7'] = 7, ['♣8'] = 8, ['♣9'] = 9,
	['♣T'] = 10, ['♣J'] = 10, ['♣Q'] = 10, ['♣K'] = 10,
	
	['♦A'] = 1, ['♦2'] = 2, ['♦3'] = 3, ['♦4'] = 4, ['♦5'] = 5,
	['♦6'] = 6, ['♦7'] = 7, ['♦8'] = 8, ['♦9'] = 9,
	['♦T'] = 10, ['♦J'] = 10, ['♦Q'] = 10, ['♦K'] = 10,
	['☆'] = 10, ['★'] = 10,

	['☆A'] = 1, ['☆2'] = 2, ['☆3'] = 3, ['☆4'] = 4, ['☆5'] = 5, 
	['☆6'] = 6,['☆7'] = 7, ['☆8'] = 8, ['☆9'] = 9, 
	['☆T'] = 10, ['☆J'] = 10, ['☆Q'] = 10, ['☆K'] = 10,

	['★A'] = 1, ['★2'] = 2, ['★3'] = 3, ['★4'] = 4, ['★5'] = 5, 
	['★6'] = 6,['★7'] = 7, ['★8'] = 8, ['★9'] = 9, 
	['★T'] = 10, ['★J'] = 10, ['★Q'] = 10, ['★K'] = 10
}


GameLogic.CARDS_LOGICE_VALUE = {
	['A'] = 1, ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5,
	['6'] = 6, ['7'] = 7, ['8'] = 8, ['9'] = 9,
	['T'] = 10, ['J'] = 11, ['Q'] = 12, ['K'] = 13,
	['☆'] = 14, ['★'] = 15,
}

GameLogic.HEX_CARDS_DATA = {
	['♠A'] = 0x51, ['♠2'] = 0x52, ['♠3'] = 0x53, ['♠4'] = 0x54, ['♠5'] = 0x55,
	['♠6'] = 0x56, ['♠7'] = 0x57, ['♠8'] = 0x58, ['♠9'] = 0x59,
	['♠T'] = 0x5A, ['♠J'] = 0x5B, ['♠Q'] = 0x5C, ['♠K'] = 0x5D,
	
	['♥A'] = 0x41, ['♥2'] = 0x42, ['♥3'] = 0x43, ['♥4'] = 0x44, ['♥5'] = 0x45,
	['♥6'] = 0x46, ['♥7'] = 0x47, ['♥8'] = 0x48, ['♥9'] = 0x49,
	['♥T'] = 0x4A, ['♥J'] = 0x4B, ['♥Q'] = 0x4C, ['♥K'] = 0x4D,
	
	['♣A'] = 0x31, ['♣2'] = 0x32, ['♣3'] = 0x33, ['♣4'] = 0x34, ['♣5'] = 0x35,
	['♣6'] = 0x36, ['♣7'] = 0x37, ['♣8'] = 0x38, ['♣9'] = 0x39,
	['♣T'] = 0x3A, ['♣J'] = 0x3B, ['♣Q'] = 0x3C, ['♣K'] = 0x3D,
	
	['♦A'] = 0x21, ['♦2'] = 0x22, ['♦3'] = 0x23, ['♦4'] = 0x24, ['♦5'] = 0x25,
	['♦6'] = 0x26, ['♦7'] = 0x27, ['♦8'] = 0x28, ['♦9'] = 0x29,
	['♦T'] = 0x2A, ['♦J'] = 0x2B, ['♦Q'] = 0x2C, ['♦K'] = 0x2D,

	['★A'] = 0x11, ['★2'] = 0x12, ['★3'] = 0x13, ['★4'] = 0x14, ['★5'] = 0x15, 
	['★6'] = 0x16,['★7'] = 0x17, ['★8'] = 0x18, ['★9'] = 0x19, 
	['★T'] = 0x1A, ['★J'] = 0x1B, ['★Q'] = 0x1C, ['★K'] = 0x1D,

	['☆A'] = 0x01, ['☆2'] = 0x02, ['☆3'] = 0x03, ['☆4'] = 0x04, ['☆5'] = 0x05, 
	['☆6'] = 0x06,['☆7'] = 0x07, ['☆8'] = 0x08, ['☆9'] = 0x09, 
	['☆T'] = 0x0A, ['☆J'] = 0x0B, ['☆Q'] = 0x0C, ['☆K'] = 0x0D,

	['☆'] = 0x61, ['★'] = 0x62
}

local SUIT_UTF8_LENGTH = 3

local function card_suit(c)
	if not c then print(debug.traceback()) end
	if c == '☆' or c == '★' then
		return c
	else
		return #c > SUIT_UTF8_LENGTH and c:sub(1, SUIT_UTF8_LENGTH) or nil
	end
end

local function card_rank(c)
	if c == '☆' or c == '★' then
		return c
	else
		return #c > SUIT_UTF8_LENGTH and c:sub(SUIT_UTF8_LENGTH + 1, #c) or nil
	end
end

function GameLogic.card_rank_out(c)
	return c:sub(1, SUIT_UTF8_LENGTH)
end

function GameLogic.transformCards(serverCardData)
	local retCards = {}
	table.insert(retCards, serverCardData[5])
	return retCards
end

function GameLogic.getSpecialTypeByVal(gameplay, spVal)
	local tabEmun = GameLogic.SPECIAL_EMUN
	if gameplay == 6 then
		tabEmun = GameLogic.SPECIAL_EMUN7
	end
	if spVal and spVal > 0 then
		for key, val in pairs(tabEmun) do
			if val == spVal then
				return key
			end
		end
	end
end

function GameLogic.getSpecialType(cards, gameplay, setting, wanglai, laizinum, niucnt)

	-- 分析撲克
	local value = GameLogic.CARDS_LOGICE_VALUE
	
	local tabHandSort = {}
	local tabHandVal = {} -- 牌值数组
	local tabHandSuit = {}
	
	local sum = 0   -- 牌值和  
	local isWUXIAO = true
	local isWUHUA_J = true
	local isWUHUA_Y = true
	local isTONGHUA = true
	
	local prevCard = {- 1, ""}

	for k, v in pairs(cards) do
		local cardVal = value[card_rank(v)]
		local cardSuit = card_suit(v)
		--{ [1]=val, [2]=suit}
		table.insert(tabHandSort, {cardVal, cardSuit})
		if cardVal < 14 then 
			sum = sum + cardVal
			if cardVal > value['4'] then
				isWUXIAO = false
			end
			if cardVal < value['T'] then
				isWUHUA_J = false
			end
			if cardVal < value['T'] then
				isWUHUA_Y = false
			end
			if prevCard[2] ~= "" and prevCard[2] ~= cardSuit then
				isTONGHUA = false
			end
			prevCard = {cardVal, cardSuit}
		end
	end
	
	for k, v in pairs(tabHandSort) do
		table.insert(tabHandVal, v[1])
		table.insert(tabHandSuit, v[2])
	end
	
	local set = GameLogic.CLIENT_SETTING
	local spEmun = GameLogic.SPECIAL_EMUN
	if gameplay and gameplay == 6 then
		spEmun = GameLogic.SPECIAL_EMUN7
		set = GameLogic.CLIENT_SETTING7
	end

	-- 特殊牌逻辑
	-- 没有癞子-------------------------------------------------------------------------------
	local function isEnabled(type)
		if type > 0 then
			if setting[type] and setting[type] > 0 then
				return true
			end
		end
		return false
	end
	
	local function aSflush()
		-- 同花顺
		local t = tabHandVal
		if t[1] == t[2] + 1 and
		t[2] == t[3] + 1 and
		t[3] == t[4] + 1 and
		t[4] == t[5] + 1 and
		isTONGHUA and
		isEnabled(set.SFLUSH)
		then
			return true, spEmun.SFLUSH
		end
	end

	local function aBoom()
		-- 炸弹牛
		if(tabHandVal[1] == tabHandVal[4] or
		tabHandVal[2] == tabHandVal[5]) and
		isEnabled(set.BOOM)
		then
			return true, spEmun.BOOM
		end
	end

	local function aWuHuaJ()
		-- 五花牛 金牛
		if isWUHUA_J and
		isEnabled(set.WUHUA_J)
		then
			return true, spEmun.WUHUA_J
		end
	end

	local function aWuXiao()
		-- 五小牛
		if isWUXIAO and sum <= 10 and
		isEnabled(set.WUXIAO)
		then
			return true, spEmun.WUXIAO
		end
	end

	local function aHuLu()
		-- 葫芦牛
		if((tabHandVal[1] == tabHandVal[3] and tabHandVal[4] == tabHandVal[5]) or
		(tabHandVal[1] == tabHandVal[2] and tabHandVal[3] == tabHandVal[5])) and
		isEnabled(set.HULU)
		then
			return true, spEmun.HULU
		end
	end

	local function aTongHua()
		-- 同花
		if isTONGHUA and
		isEnabled(set.TONGHUA)
		then
			return true, spEmun.TONGHUA
		end
	end

	local function aStraight()
		-- 顺子
		local t = tabHandVal
		if t[1] == t[2] + 1 and
		t[2] == t[3] + 1 and
		t[3] == t[4] + 1 and
		t[4] == t[5] + 1 and
		isEnabled(set.STRAIGHT)
		then
			return true, spEmun.STRAIGHT
		elseif t[1] == 13 and
		t[2] == 12 and
		t[3] == 11 and
		t[4] == 10 and
		t[5] == 1 and
		isEnabled(set.STRAIGHT)
		then
			return true, spEmun.STRAIGHT
		end
	end

	local function aBiyi()
		-- 比翼牛
		local t = tabHandVal
		if niucnt == 10 and 
		((t[1] == t[2] and t[3] == t[4]) or
		(t[1] == t[2] and t[4] == t[5]) or
		(t[2] == t[3] and t[4] == t[5])) and  
		isEnabled(set.BIYI)
		then
			return true, spEmun.BIYI
		end
	end

	local function aWuHuaY()
		-- 金牛
		if isWUHUA_Y and
		isEnabled(set.WUHUA_Y)
		then
			return true, spEmun.WUHUA_Y
		end
	end
	-------------------------------------------------------------------------------
	-- 一个癞子---------------------------------------------------------------------

	local function wlSflush()
		-- 同花顺
		local t = tabHandVal
		if t[2] - t[5] <= 4 and
		t[2] ~= t[3] and
		t[3] ~= t[4] and
		t[4] ~= t[5] and
		isTONGHUA and
		isEnabled(set.SFLUSH)
		then
			return true, spEmun.SFLUSH
		end
	end

	local function wlBoom()
		-- 炸弹牛
		if (tabHandVal[2] == tabHandVal[4] or
		tabHandVal[3] == tabHandVal[5]) and
		isEnabled(set.BOOM)
		then
			return true, spEmun.BOOM
		end
	end

	local function wlWuXiao()
		-- 五小牛
		if isWUXIAO and sum <= 9 and
		isEnabled(set.WUXIAO)
		then
			return true, spEmun.WUXIAO
		end
	end

	local function wlHuLu()
		-- 葫芦牛
		if(tabHandVal[2] == tabHandVal[4] or
		(tabHandVal[2] == tabHandVal[3] and tabHandVal[4] == tabHandVal[5]) or
		tabHandVal[3] == tabHandVal[5]) and
		isEnabled(set.HULU)
		then
			return true, spEmun.HULU
		end
	end

	local function wlStraight()
		-- 顺子
		local t = tabHandVal
		if t[2] - t[5] <= 4 and
		t[2] ~= t[3] and
		t[3] ~= t[4] and
		t[4] ~= t[5] and
		isEnabled(set.STRAIGHT)
		then
			return true, spEmun.STRAIGHT
		end
	end

	local function wlBiyi()
		-- 比翼牛
		local t = tabHandVal
		local sum1 = ((t[2] + t[2] + t[3] + t[4] + t[5]) % 10) == 0
		local sum2 = ((t[3] + t[2] + t[3] + t[4] + t[5]) % 10) == 0
		local sum3 = ((t[4] + t[2] + t[3] + t[4] + t[5]) % 10) == 0
		local sum4 = ((t[5] + t[2] + t[3] + t[4] + t[5]) % 10) == 0
		if niucnt == 10 and 
		((t[2] == t[3] and (sum3 or sum4)) or
		(t[3] == t[4] and (sum1 or sum4)) or 
		(t[4] == t[5] and (sum1 or sum2))) and  
		isEnabled(set.BIYI)
		then
			return true, spEmun.BIYI
		end
	end

	-- local function aWuHuaY()
	-- 	-- 银牛
	-- 	if isWUHUA_Y and
	-- 	isEnabled(set.WUHUA_Y)
	-- 	then
	-- 		return true, spEmun.WUHUA_Y
	-- 	end
	-- end                       --未实现

	-------------------------------------------------------------------------------
	-- 两个癞子---------------------------------------------------------------------	

	local function wl2Sflush()
		-- 同花顺
		local t = tabHandVal
		if t[3] - t[5] <= 4 and
		t[3] ~= t[4] and
		t[4] ~= t[5] and
		isTONGHUA and
		isEnabled(set.SFLUSH)
		then
			return true, spEmun.SFLUSH
		end
	end

	local function wl2Boom()
		-- 炸弹牛
		if(tabHandVal[3] == tabHandVal[4] or
		tabHandVal[4] == tabHandVal[5]) and
		isEnabled(set.BOOM)
		then
			return true, spEmun.BOOM
		end
	end

	local function wl2WuXiao()
		-- 五小牛
		if isWUXIAO and sum <= 8 and
		isEnabled(set.WUXIAO)
		then
			return true, spEmun.WUXIAO
		end
	end

	local function wl2HuLu()
		-- 葫芦牛
		if(tabHandVal[3] == tabHandVal[4] or
		tabHandVal[4] == tabHandVal[5]) and
		isEnabled(set.HULU)
		then
			return true, spEmun.HULU
		end
	end

	local function wl2Straight()
		-- 顺子
		local t = tabHandVal
		if t[3] - t[5] <= 4 and
		t[3] ~= t[4] and
		t[4] ~= t[5] and
		isEnabled(set.STRAIGHT)
		then
			return true, spEmun.STRAIGHT
		end
	end

	local function wl2Biyi()
		-- 比翼牛
		local t = tabHandVal
		local sum1 = ((t[3] + t[4] + t[3] + t[4] + t[5]) % 10) == 0
		local sum2 = ((t[3] + t[5] + t[3] + t[4] + t[5]) % 10) == 0
		local sum3 = ((t[4] + t[5] + t[3] + t[4] + t[5]) % 10) == 0
		if niucnt == 10 and 
		(sum1 or sum2 or sum3) and  
		isEnabled(set.BIYI)
		then
			return true, spEmun.BIYI
		end
	end

	-- local function aWuHuaY()
	-- 	-- 银牛
	-- 	if isWUHUA_Y and
	-- 	isEnabled(set.WUHUA_Y)
	-- 	then
	-- 		return true, spEmun.WUHUA_Y
	-- 	end
	-- end                 --未实现

	-------------------------------------------------------------------------------

	-- 优先级
	local tabFunc = {aSflush, aWuXiao, aBoom, aHuLu, aTongHua, aWuHuaJ, aStraight, aBiyi} -- 普通模式
	if gameplay == 6 then -- 疯狂加倍模式
		tabFunc = {aSflush, aWuXiao, aBoom, aHuLu, aTongHua, aWuHuaJ, aStraight, aBiyi}
	end

	if wanglai and wanglai > 0 then -- 王癞模式
		if laizinum == 1 then
			tabFunc = {wlSflush, wlWuXiao, wlBoom, wlHuLu, aTongHua, aWuHuaJ, wlStraight, wlBiyi}
		elseif laizinum == 2 then
			tabFunc = {wl2Sflush, wl2WuXiao, wl2Boom, wl2HuLu, aTongHua, aWuHuaJ, wl2Straight, wl2Biyi}
		end
		if gameplay == 6 then -- 疯狂加倍模式
			if laizinum == 1 then
				tabFunc = {wlSflush, wlWuXiao, wlBoom, wlHuLu, aTongHua, aWuHuaJ, wlStraight, wlBiyi}
			elseif laizinum == 2 then
				tabFunc = {wl2Sflush, wl2WuXiao, wl2Boom, wl2HuLu, aTongHua, aWuHuaJ, wl2Straight, wl2Biyi}
			end
		end
	end

	local type = 0
	for i,v in ipairs(tabFunc) do
		local bool, val = v()
		if bool then
			type = val
			break
		end
	end

	return type, GameLogic.getSpecialTypeByVal(gameplay, type)
end


function GameLogic.findNiuniuByData(cards, laizinum)
	local niuniusP = {}
	local keyMap = {}
	local niuniusT = {}
	local cnt = #cards
	local niucnt = 0
	local breakflag = false
	laizinum = laizinum or 0
	for i = 1, cnt - 2 do
		for j = i + 1, cnt - 1 do
			for x = j + 1, cnt do
				if GameLogic.CARDS_LOGICE_VALUE[card_rank(cards[i])] > 13 or 
				GameLogic.CARDS_LOGICE_VALUE[card_rank(cards[j])] > 13 or 
				GameLogic.CARDS_LOGICE_VALUE[card_rank(cards[x])] > 13 then
					break
				end 
				local val1 = GameLogic.CARDS[cards[i]]
				local val2 = GameLogic.CARDS[cards[j]]
				local val3 = GameLogic.CARDS[cards[x]]
				local sum = val1 + val2 + val3
				if(sum % 10) == 0 then
					table.insert(niuniusP, {cards[i], cards[j], cards[x]})
					keyMap[i] = i
					keyMap[j] = j
					keyMap[x] = x
					local right = {}
					for idx = 1, cnt do
						if not keyMap[idx] then
							table.insert(right, idx)
						end
					end
					table.insert(niuniusT, {
						cards[right[1]],
						cards[right[2]],
					})
					niucnt = (GameLogic.CARDS[cards[right[1]]] + GameLogic.CARDS[cards[right[2]]] - 1) % 10 + 1
					breakflag = true
				end
				if breakflag then break end
			end
			if breakflag then break end
		end
		if breakflag then break end
	end

	local function addTwoCards()
		local sum = 0
		for i = 2, cnt - 1 do
			for j = i + 1, cnt do
				local val1 = GameLogic.CARDS[cards[i]]
				local val2 = GameLogic.CARDS[cards[j]]
				if (val1 + val2 - 1 ) % 10 + 1  > sum then
					niuniusT = {}
					niuniusP = {}
					keyMap = {}
					sum = (val1 + val2 - 1 ) % 10 + 1
					table.insert(niuniusT, {cards[i], cards[j]})
					keyMap[i] = i
					keyMap[j] = j
					local left = {}
					for idx = 1, cnt do
						if not keyMap[idx] then
							table.insert(left, idx)
						end
					end
					table.insert(niuniusP, {cards[left[1]], cards[left[2]], cards[left[3]]})
				end
			end
		end
		return niuniusP, niuniusT, sum
	end

	local function groupLaizi()
		table.insert(niuniusP,{cards[1], cards[3], cards[4]}) 
		table.insert(niuniusT,{cards[2], cards[5]}) 
		return niuniusP, niuniusT, 10
	end
	
	if laizinum == 0 then
		if next(niuniusP) == nil then
			return nil
		else
			return niuniusP, niuniusT, niucnt
		end
	elseif laizinum == 1 then
		if next(niuniusP) == nil then
			return addTwoCards()
		else
			return niuniusP, niuniusT, 10
		end
	elseif laizinum == 2 then
		if next(niuniusP) == nil then
			return groupLaizi()
		else
			return niuniusP, niuniusT, 10
		end
	end
end

function GameLogic.setLaiziData(cardsdata, specialType, gameplay, wanglai)
	local cards, laizinum = GameLogic.sortCards(cardsdata)
	if laizinum == 0 then return cards end
	local cardsvalue = {}
	local cardbiaomian = {}

	for k, v in pairs(cards) do
		table.insert(cardsvalue, GameLogic.CARDS_LOGICE_VALUE[card_rank(v)])
	end

	for k, v in pairs(cards) do
		table.insert(cardbiaomian, card_rank(v))
	end

	local function getcard_rank(value)
		for k, v in pairs(GameLogic.CARDS_LOGICE_VALUE) do
			if v == value then
				return k
			end
		end
	end

	local sum = 0
	local temp = 0

	local function WUXIAO()
		sum = cardsvalue[3] + cardsvalue[4] + cardsvalue[5]
		if laizinum == 1 then
			sum = sum + cardsvalue[2]
			temp = 10 - sum 
			cards[1] =  cards[1] .. getcard_rank(temp)
		elseif laizinum == 2 then
			temp = 10 - sum - 1
			cards[1] =  cards[1] .. getcard_rank(temp)
			cards[2] =  cards[2] .. 'A'
		end
	end

	local function BOOM()
		if laizinum == 1 then
			cards[1] = cards[1] .. cardbiaomian[4]
		elseif laizinum == 2 then
			cards[1] = cards[1] .. cardbiaomian[4]
			cards[2] = cards[2] .. cardbiaomian[4]
		end
	end

	local function HULU()
		if laizinum == 1 then
			if (cardsvalue[2] == cardsvalue[3] and cardsvalue[4] == cardsvalue[5]) or
			(cardsvalue[3] == cardsvalue[4] and cardsvalue[4] == cardsvalue[5])
			then
				cards[1] = cards[1] .. cardbiaomian[2]
			end

			if cardsvalue[2] == cardsvalue[3] and cardsvalue[3] == cardsvalue[4] then
				cards[1] = cards[1] .. cardbiaomian[5]
			end
		elseif laizinum == 2 then
			cards[1] = cards[1] .. cardbiaomian[3]
			cards[2] = cards[2] .. cardbiaomian[5]
		end
	end

	local function TONGHUA()
		if laizinum == 1 then
			cards[1] = cards[1] .. 'K'
		elseif laizinum == 2 then
			cards[1] = cards[1] .. 'K'
			cards[2] = cards[2] .. 'K'
		end
	end

	local function WUHUA()
		if laizinum == 1 then
			cards[1] = cards[1] .. 'K'
		elseif laizinum == 2 then
			cards[1] = cards[1] .. 'K'
			cards[2] = cards[2] .. 'K'
		end
	end

	local function STRAIGHT()
		local flag = true
		if laizinum == 1 then
			for i = 2, 4 do
				if cardsvalue[i] - cardsvalue[i + 1] ~= 1 and flag then
					cards[1] = cards[1] .. getcard_rank(cardsvalue[i] - 1)
					flag = false
				end
			end
			if flag then
				if cardbiaomian[2] == 'K' then
					cards[1] = cards[1] .. '9'
				else 
					cards[1] = cards[1] .. getcard_rank(cardsvalue[2] + 1)
				end
			end
		elseif laizinum == 2 then
			for i = 3, 4 do
				if cardsvalue[i] - cardsvalue[i + 1] ~= 1 and flag then
					cards[2] = cards[2] .. getcard_rank(cardsvalue[i] - 1)
					flag = false
				end
			end
			if flag then
				if cardbiaomian[3] == 'K' then
					cards[2] = cards[2] .. 'T'
				else 
					cards[2] = cards[2] .. getcard_rank(cardsvalue[3] + 1)
				end
			end

			-- 再次排序
			cards, laizinum = GameLogic.sortCards(cards)
			flag = true
			cardsvalue = {}
			cardbiaomian = {}

			-- 再次获得牌值
			for k, v in pairs(cards) do
				table.insert(cardsvalue, GameLogic.CARDS_LOGICE_VALUE[card_rank(v)])
			end
		
			for k, v in pairs(cards) do
				table.insert(cardbiaomian, card_rank(v))
			end

			for i = 2, 4 do
				if cardsvalue[i] - cardsvalue[i + 1] ~= 1 and flag then
					cards[1] = cards[1] .. getcard_rank(cardsvalue[i] - 1)
					flag = false
				end
			end
			if flag then
				if cardbiaomian[2] == 'K' then
					cards[1] = cards[1] .. '9'
				else 
					cards[1] = cards[1] .. getcard_rank(cardsvalue[2] + 1)
				end
			end
		end
	end

	local function SFLUSH()
		STRAIGHT()
	end

	local function BIYI()
		if laizinum == 1 then
			local sum1 = (cardsvalue[2] + cardsvalue[2] + cardsvalue[3] + cardsvalue[4] + cardsvalue[5]) % 10 == 0
			local sum2 = (cardsvalue[3] + cardsvalue[2] + cardsvalue[3] + cardsvalue[4] + cardsvalue[5]) % 10 == 0
			local sum3 = (cardsvalue[4] + cardsvalue[2] + cardsvalue[3] + cardsvalue[4] + cardsvalue[5]) % 10 == 0
			local sum4 = (cardsvalue[5] + cardsvalue[2] + cardsvalue[3] + cardsvalue[4] + cardsvalue[5]) % 10 == 0
			local sum = {sum1, sum2, sum3, sum4}

			for i, v in pairs(sum) do
				if v then
					cards[1] = cards[1] .. getcard_rank(cardsvalue[i + 1])
				end
			end
			
		elseif laizinum == 2 then
			local sum1 = ((cardsvalue[3] + cardsvalue[4] + cardsvalue[3] + cardsvalue[4] + cardsvalue[5]) % 10) == 0
			local sum2 = ((cardsvalue[3] + cardsvalue[5] + cardsvalue[3] + cardsvalue[4] + cardsvalue[5]) % 10) == 0
			local sum3 = ((cardsvalue[4] + cardsvalue[5] + cardsvalue[3] + cardsvalue[4] + cardsvalue[5]) % 10) == 0

			if sum1 then
				cards[1] = cards[1] .. getcard_rank(cardsvalue[3])
				cards[2] = cards[2] .. getcard_rank(cardsvalue[4])
			elseif sum2 then
				cards[1] = cards[1] .. getcard_rank(cardsvalue[3])
				cards[2] = cards[2] .. getcard_rank(cardsvalue[5])
			elseif sum3 then
				cards[1] = cards[1] .. getcard_rank(cardsvalue[4])
				cards[2] = cards[2] .. getcard_rank(cardsvalue[5])
			end
		end
	end

	local function addTwoCards(laizinum)
		local cnt = #cards
		local t_sum = 0
		local p_sum = 0
		local t_temp = 0
		local p_temp = {}
		for i = laizinum + 1, cnt - 1 do
			for j = i + 1, cnt do
				local val1 = GameLogic.CARDS[cards[i]]
				local val2 = GameLogic.CARDS[cards[j]]
				if (val1 + val2 - 1 ) % 10 + 1  > t_sum then
					t_sum = (val1 + val2 - 1 ) % 10 + 1
					t_temp = 0
					p_temp = {}
					for x = laizinum + 1, cnt do
						if x ~= i and x ~= j then
							t_temp = (t_temp + GameLogic.CARDS[cards[x]] - 1) % 10 + 1
						end
					end
					if t_temp ~= 10 then
						p_temp[laizinum] = cards[laizinum] .. ((10 - t_temp) ~= 1 and  (10 - t_temp) or 'A')
					else
						p_temp[laizinum] = cards[laizinum] .. 'K'
					end
					if laizinum == 2 then
						if t_sum ~= 10 then
							p_temp[1] = cards[1] .. ((10 - t_sum) ~= 1 and  (10 - t_sum) or 'A')
						else
							p_temp[1] = cards[1] .. 'K'
						end
					end
				end
			end
			p_sum = p_sum + GameLogic.CARDS[cards[i]]
		end
		p_sum = p_sum + GameLogic.CARDS[cards[cnt]]
		if p_sum % 10 == 0 then
			for i = 1, laizinum do
				p_temp[i] = cards[i] .. 'K'
			end
		end
		if laizinum == 1 then
			cards[1] = p_temp[1]
		else
			cards[1] = p_temp[1]
			cards[2] = p_temp[2]
		end
	end

	local typelist = {BIYI, STRAIGHT, WUHUA, TONGHUA, HULU, BOOM, WUXIAO, SFLUSH}
	if specialType and specialType > 0 then
		-- 特殊牌
		for k, v in pairs(typelist) do
			if k == specialType then
				v()
			end
		end
	else
		-- 普通牌
		addTwoCards(laizinum)
	end
	cards, laizinum = GameLogic.sortCards(cards)
	return cards
end

function GameLogic.groupingCardData(cards, specialType, gameplay, wanglai)
	local retGroup = {}
	
	local cards, laizinum = GameLogic.sortCards(cards)

	if laizinum > 0 then
		cards = GameLogic.setLaiziData(cards, specialType, gameplay, wanglai)
	end
	
	local function getVal(card)
		return GameLogic.CARDS_LOGICE_VALUE[card_rank(card)]
	end
	local val1 = getVal(cards[1])
	local val3 = getVal(cards[3])
	local val4 = getVal(cards[4])
	
	retGroup = {cards, {}}
	if specialType and specialType > 0 then
		-- 特殊牌
		local typename = GameLogic.getSpecialTypeByVal(gameplay, specialType)
		if typename == "BOOM" then
			if(val1 == val4) then
				retGroup = {{cards[1], cards[2], cards[3], cards[4]}, {cards[5]}}
			else
				retGroup = {{cards[2], cards[3], cards[4], cards[5]}, {cards[1]}}
			end
		end
		if typename == "HULU" then
			if(val1 == val3) then
				retGroup = {{cards[1], cards[2], cards[3]}, {cards[4], cards[5]}}
			else
				retGroup = {{cards[3], cards[4], cards[5]}, {cards[1], cards[2]}}
			end
		end
		
	else
		-- 普通牛
		local niuniusP, niuniuT = GameLogic.findNiuniuByData(cards, laizinum)
		if niuniusP then
			retGroup = {niuniusP[1], niuniuT[1]}
		end
	end
	
	local retCards = {}
	for groupIdx = 1, 2 do
		if retGroup[groupIdx] then
			for i1 = 1, #retGroup[groupIdx] do
				table.insert(retCards, retGroup[groupIdx] [i1])
			end
		end
	end
	return retCards, retGroup
end

function GameLogic.getMul(gamePlay, setting, niuCnt, specialType)
	setting = setting or 1
	
	if specialType and specialType > 0 then
		local type = GameLogic.getSpecialTypeByVal(gamePlay, specialType)
		local mulTab = GameLogic.SPECIAL_MULNUM.default
		if GameLogic.SPECIAL_MULNUM[gamePlay] then
			mulTab = GameLogic.SPECIAL_MULNUM[gamePlay]
		end
		return mulTab[type]
	end
	
	if niuCnt then
		local mulTab = GameLogic.NIU_MULNUM.default
		if GameLogic.NIU_MULNUM[gamePlay] then
			mulTab = GameLogic.NIU_MULNUM[gamePlay]
		end
		return mulTab[setting] [niuCnt]
	end
	
end

function GameLogic.getSetting(gameplay, setNum)
	local tabSetting = GameLogic.CLIENT_SETTING
	if gameplay == 6 then
		tabSetting = GameLogic.CLIENT_SETTING7
	end
	for name, v in pairs(tabSetting) do
		if v > 0 and setNum and v == setNum then
			return name
		end
	end
end

-- 哈希表转数组
function GameLogic.hashCountsToArray(hash)
    local a = {}
    for k, v in pairs(hash) do
        for _ = 1, v do
          a[#a + 1] = k
        end
    end
    return a
end


-- mode: 1:五小牛。。。 | 2:五小  |  3:五小牛（8倍） 
function GameLogic.getSpecialText(deskInfo, mode, oneLine)
	mode = mode or 3

	local gameplay = deskInfo.gameplay
	local tabRule
	if mode == 1 then -- 长文本
		tabRule = GameLogic.SPECIAL_LONG_TEXT
	elseif mode == 2 then	-- 短文本
		tabRule = GameLogic.SPECIAL_SHORT_TEXT
	elseif mode == 3 then -- 带倍数
		tabRule = GameLogic.SPECIAL_MUL_TEXT
		if gameplay == 6 then
			tabRule = GameLogic.SPECIAL_MUL_TEXT7
		end
	else
		tabRule = GameLogic.SPECIAL_LONG_TEXT
	end

	local special = deskInfo.special
	local ruleText = ""
	local addCnt = 0
    for i, v in pairs(special) do 
        if v > 0 then
            local spName = GameLogic.getSetting(gameplay, v)
            if spName then
                addCnt = addCnt + 1
				local r = addCnt == 3 and "\r\n" or ""
				if oneLine then r = '' end
                ruleText = ruleText .. ' ' .. tabRule[spName] .. r
            end
        end
	end
	
	return ruleText
end

-- 禁止搓牌 | 中途禁止加入 | 
function GameLogic.getAdvanceText(deskInfo)
	local setting = {
		-- '闲家推注',
		'',
		'游戏开始后禁止加入',
		'禁止搓牌',
		'下注限制',
		'王癞玩法',
	}
	local wanglai = {
		'',
		'经典王癞',
		'疯狂王癞',
	}
	local retStr = ''
	for k,v in pairs(deskInfo.advanced) do
		if v > 0 then
			local text = setting[k] or ''
			retStr = retStr .. text .. ' '
		end
	end
	retStr = retStr .. wanglai[deskInfo.wanglai]
	return retStr
end

-- 2/4 。。。
function GameLogic.getBaseText(deskInfo)
	local base = deskInfo.base
	return GameLogic.BASE[base] or base
end

function GameLogic.getBaseOrder(idx)
	return GameLogic.BASEORDER[idx]
end

--2/4——{2,4}
function GameLogic.getBaseInfoText(deskInfo)
	local base = deskInfo.base
	return GameLogic.BASEINFO[base]
end

-- 牛9X5 。。。
function GameLogic.getNiuNiuMulText(deskInfo, mode)
	local mul = deskInfo.multiply
	local gameplay = deskInfo.gameplay
	if mode then
		if gameplay == 6 then
			return '牛牛X10倍'
		elseif mul == 1 then
			return '牛牛X4倍'
		else 
			return '牛牛X3倍'
		end
	end

	if gameplay == 6 then
		return GameLogic.NIUMUL_FK
	elseif mul == 1 then
		return GameLogic.NIUMUL_1
	else 
		return GameLogic.NIUMUL_2
	end

end

-- 牛牛玩法
function GameLogic.getGameplayText(deskInfo)
	local idx = deskInfo.gameplay
	return GameLogic.GAMEPLAY[idx] or ''
end

-- 支付方式
function GameLogic.getPayModeText(deskInfo)
	local idx = deskInfo.roomPrice
	local payText = "房主"
	if idx == 1 then
	  payText = "房主"
	else
	  payText = "AA"
	end
	return payText
end

-- 推注选项
function GameLogic.getPutMoneyText(deskInfo)
	local idx = deskInfo.putmoney
	return GameLogic.PUTMONEY[idx] or ''
end

-- 推注选项
function GameLogic.getPutMoneyOrder(idx)
	return GameLogic.PUTMONEY_ORDER[idx] or ''
end

-- 最大抢庄
function GameLogic.getQzMaxText(deskInfo)
	local idx = deskInfo.qzMax
	return GameLogic.QZMAX[idx] or ''
end

-- 最大抢庄具体数目
function GameLogic.getQzMaxInfoText(deskInfo)
	local idx = deskInfo.qzMax
	return GameLogic.QZMAXINFO[idx]
end

-- 自动开始
function GameLogic.getStartModeText(deskInfo)
	local idx = deskInfo.startMode
	local str = GameLogic.STARTMODE
	if deskInfo.gameplay == 7 then
		str = GameLogic.STARTMODE_BM
	elseif deskInfo.gameplay == 8 then
		str = GameLogic.STARTMODE_SM
	end
	return str[idx] or ''
end

-- 自动开始
function GameLogic.getStartModeOrder(idx, focus)
	local mode = GameLogic.STARTMODE 
	if focus == 'bm' then
		mode = GameLogic.STARTMODE_BM 
	elseif focus == 'sm' then
		mode = GameLogic.STARTMODE_SM 
	end
	return mode[idx] or ''
end

-- 房间限制
function GameLogic.getRoomLimitText(deskInfo)
    local text = '无'
    if deskInfo.roomMode == 'bisai' and deskInfo.scoreOption then
        local options = deskInfo.scoreOption
        text = '入场:' .. options.join .. '  抢庄:' .. options.qiang .. '  推注:' .. options.tui 
            .. '  抽水:' .. options.choushui .. '%  ' .. ( options.rule == 1 and '大赢家抽水' or '赢家抽水')
    end
    return text
end

function GameLogic.isQzGame(deskInfo)
	local idx = deskInfo.gameplay
	local tab = {
		[4] = 4,
		[7] = 7,
		[6] = 6,
		[8] = 8,
		[9] = 9,
	}
	return tab[idx] or false
end

function GameLogic.isSzGame(deskInfo)
	local idx = deskInfo.gameplay
	local tab = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[5] = 5,
	}
	return tab[idx] or false
end

-- 房间规则
function GameLogic.getRoomRuleText(deskInfo)
	local roomRuleText = ""
	roomRuleText = GameLogic.getPayModeText(deskInfo).."支付"
	roomRuleText = roomRuleText .. " 推注" ..GameLogic.getPutMoneyText(deskInfo)
	if GameLogic.isQzGame(deskInfo) then
		roomRuleText = roomRuleText .. " 最大抢庄" ..GameLogic.getQzMaxText(deskInfo)
	end
	roomRuleText = roomRuleText .. " " ..GameLogic.getStartModeText(deskInfo)
	return roomRuleText
end

function GameLogic.isEnableCuoPai(deskInfo)
	if deskInfo.advanced and deskInfo.advanced[3] > 0 then
		return false
	end
	return true
end

-- 已弃用
function GameLogic.findNiuniuCnt(cards)
    local niuCnt = 0

    if cards then
        local max = 0
        for _, v in ipairs(cards) do
            max = max + GameLogic.CARDS[v]
        end

        max = max % 10
        niuCnt = max

        if niuCnt == 0 then
            niuCnt = 10
        end
    end

    return niuCnt
end

function GameLogic.sortCards(cards)

	local value = GameLogic.CARDS_LOGICE_VALUE
	local cardcolor = GameLogic.HEX_CARDS_DATA
	local laizinum = 0

	for i, v in pairs(cards) do
		if value[card_rank(v)] > 13 then
			laizinum = laizinum + 1
		end
	end

	-- 按大到小排序
	table.sort(cards, function(a, b)
		local A = value[card_rank(a)]
		local B = value[card_rank(b)]

		if A > B then return true end
		if A < B then return false end
		if A == B then 
			local C = cardcolor[a]
			local D = cardcolor[b]
			return (C > D)
		end

		return false
	end)
	return cards, laizinum
end

function GameLogic.getLocalCardType(cardsdata, gameplay, setting, wanglai)
	local cards, laizinum = GameLogic.sortCards(cardsdata)
	local left, right, cnt = GameLogic.findNiuniuByData(cards, laizinum)
	cnt = cnt or 0
	local spType, spKey = GameLogic.getSpecialType(cards, gameplay, setting, wanglai, laizinum, cnt)
	return cnt, spType, spKey
end

return GameLogic 