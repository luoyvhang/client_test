local display = require('cocos.framework.display')

local ChineseSize = 3 -- 修正宽度缺陷(范围:3~4)
local RichLabel = class("RichLabel", function()
    return display.newNode()
end)

-- 本地方法
local function tab_addDataTo(tab, src)
    for k,v in pairs(src) do
        tab[k] = v
    end
end

--[[解析16进制颜色rgb值]]
local function GetTextColor(xStr)
    if string.len(xStr) == 6 then
        local tmp = {}
        for i = 0,5 do
            local str =  string.sub(xStr,i+1,i+1)
            if(str >= '0' and str <= '9') then
                tmp[6-i] = str - '0'
            elseif(str == 'A' or str == 'a') then
                tmp[6-i] = 10
            elseif(str == 'B' or str == 'b') then
                tmp[6-i] = 11
            elseif(str == 'C' or str == 'c') then
                tmp[6-i] = 12
            elseif(str == 'D' or str == 'd') then
                tmp[6-i] = 13
            elseif(str == 'E' or str == 'e') then
                tmp[6-i] = 14
            elseif(str == 'F' or str == 'f') then
                tmp[6-i] = 15
            else
                print("Wrong color value.")
                tmp[6-i] = 0
            end
        end
        local r = tmp[6] * 16 + tmp[5]
        local g = tmp[4] * 16 + tmp[3]
        local b = tmp[2] * 16 + tmp[1]
        return cc.c4b(r,g,b,255)
    end
    return cc.c4b(255,255,255,255)
end
-- string.split()
local function strSplit(str, flag)
	local tab = {}
	while true do
		local n = string.find(str, flag)
		if n then
			local first = string.sub(str, 1, n-1)
			str = string.sub(str, n+1, #str)
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

-- 解析输入的文本
local function parseString(str, param)
	local clumpheadTab = {} -- 标签头
	for w in string.gfind(str, "%b[]") do
		if string.sub(w,2,2) ~= "/" then-- 去尾
			table.insert(clumpheadTab, w)
		end
	end
	-- 解析标签
	local totalTab = {}
	for i,ns in ipairs(clumpheadTab) do
		local tab = {}
		local tStr
		-- 第一个等号前为块标签名
		string.gsub(ns, string.sub(ns, 2, #ns-1), function (w)
			local n = string.find(w, "=")
			if n then
				local temTab = strSplit(w, " ") -- 支持标签内嵌
				for k,pstr in pairs(temTab) do
					local temtab1 = strSplit(pstr, "=")

					local pname = temtab1[1]
					if k == 1 then tStr = pname end -- 标签头

					local js = temtab1[2]
					local p = string.find(js, "[^%d.]")
        			if not p then js = tonumber(js) end
					if pname == "color" then
						tab[pname] = GetTextColor(js)
					else
						tab[pname] = js
					end
				end
			end
		end)
		if tStr then
			-- 取出文本
			local beginFind,endFind = string.find(str, "%[%/"..tStr.."%]")
			local endNumber = beginFind-1
			local gs = string.sub(str, #ns+1, endNumber)
			tab.text = gs
			-- 截掉已经解析的字符
			str = string.sub(str, endFind+1, #str)
			if param then
				if not tab.number then param.number = k end -- 未指定number则自动生成
				tab_addDataTo(tab, param)
			end
			table.insert(totalTab, tab)
		end
	end
	-- 普通格式label显示
	if table.nums(clumpheadTab) == 0 then
		local ptab = {}
		ptab.text = str
		if param then
			param.number = 1
			tab_addDataTo(ptab, param)
		end
		table.insert(totalTab, ptab)
	end
	-- dump(totalTab)
	return totalTab
end

-- 初始化数据
local function initData(str, font, fontSize, rowWidth)
    local tab = parseString(str, {font = font, size = fontSize})
    local var = {}
    var.tab = tab         -- 文本字符
    var.width = rowWidth  -- 指定宽度
    return var
end

-- 参数转换
local function paramTranform(param_, needTitle_)
	local CONTENT_FORMAT = "[color=%X]%s[/color]"
	local viewMessage_ = {}
	local content_ = ""
	if needTitle_ == true then
		-- title
		for j, v in ipairs(param_.title) do
			local color_ = v.color.r*256*256+v.color.g*256+v.color.b

			if j == #param_.title then
				content_ = content_..string.format(CONTENT_FORMAT, color_, v.text..":")
			else
				content_ = content_..string.format(CONTENT_FORMAT, color_, v.ext)
			end
		end
	end

	-- content
	for j, v in ipairs(param_.content) do
		local color_ = v.color.r*256*256+v.color.g*256+v.color.b

		content_ = content_..string.format(CONTENT_FORMAT, color_, v.text)
	end
	viewMessage_.str = content_
	viewMessage_.font = "Microsoft YaHei"
	viewMessage_.fontSize = "42"
	viewMessage_.rowWidth = 10000
	viewMessage_.rowSpace = 0
	viewMessage_.typeTag = param_.gameId

	return viewMessage_
end

function RichLabel:ctor(param_, needTitle_, callBack_)
	local param = paramTranform(param_, needTitle_)
	self.clickEventListener = callBack_
	param.str = param.str or "传入的字符为nil"
	param.font = param.font or "Microsoft Yahei"
	param.fontSize = param.fontSize or 14
	param.rowWidth = param.rowWidth or 280
	param.rowSpace = param.rowSpace or -4
	self.tag = param.typeTag
	local textTab = initData(param.str, param.font, param.fontSize, param.rowWidth)
	self:setContentSize(cc.size(1, 1)) -- richlabel统一节点且不影响其它
	local ptab, copyVar = self:tab_addtext(textTab)

	local ocWidth = 0  -- 当前占宽
	local ocRow   = 1  -- 当前行
	local ocHeight = 0 -- 当前高度
	local useWidth,useHeight = 0,0
	self.size = {height=0,width=0}
	for k,v in pairs(copyVar) do
		local params = {}
		tab_addDataTo(params, v)
		params.scene = self
		local maxsize = params.size
		local byteSize = math.floor((maxsize+2)/ChineseSize)
		params.width  = byteSize*params.breadth     -- 控件宽度
		params.height = maxsize                     -- 控件高度
		params.x = ocWidth       					-- 控件x坐标
		params.y = -(ocHeight)                      -- 控件y坐标
		useWidth,useHeight = self:tab_createButton(params)

		-- 计算实际渲染宽度
		if params.row == ocRow then
			ocWidth = ocWidth+useWidth
		else
			ocRow = params.row
			ocWidth = 0
			-- 计算实际渲染高度
			ocHeight = ocHeight + useHeight + param.rowSpace --修正高度间距
		end

		if self.size.width < ocWidth then
			self.size.width = ocWidth
		end
	end

	self.allRow = ocRow
	self.fontSize = param.fontSize
	self.ocWidth = ocWidth
	self.ocHeight = ocHeight
	self.useWidth = useWidth
	self.useHeight = useHeight
	self.size.height = ocHeight
end

function RichLabel:getIHeight(param)
	return param.allRow * (param.fontSize +3)
end

-- 获取一个格式化后的浮点数
local function str_formatToNumber(number, num)
    local s = "%." .. num .. "f"
    return tonumber(string.format(s, number))
end

-- 全角 半角
function RichLabel:accountTextLen(str, tsize)
	local list = self:tab_cutText(str)
	local aLen = 0
	for k,v in pairs(list) do
		local a = string.len(v)
		-- 懒得写解析方法了
        -- local label = cc.LabelTTF:create(v, "Microsoft YaHei", tsize)
        local label = ccui.Text:create(v, "Microsoft YaHei", tsize)
    	a = tsize/(label:getContentSize().width)
    	local b = str_formatToNumber(ChineseSize/a, 4)
		aLen = aLen + b
		--label:release()
	end
	return aLen
end

function RichLabel:addDataToRenderTab(copyVar, tab, text, index, current)
	local tag = #copyVar+1
	copyVar[tag] = {}
	tab_addDataTo(copyVar[tag], tab)
	copyVar[tag].text = text
	copyVar[tag].index = index
	copyVar[tag].row = current
	copyVar[tag].breadth = self:accountTextLen(text, tab.size)
	copyVar[tag].tag = tag	-- 唯一下标
end

function RichLabel:tab_addtext(var)
	local allTab = {}
	-- local endRowUse = 0
	local copyVar = {}
	local useLen = 0
	local str = ""
	local current = 1
	for ktb,tab in ipairs(var.tab) do
		local txtTab, member = self:tab_cutText(tab.text)
		local num = math.floor( (var.width)/ math.ceil((tab.size+2)/ChineseSize) )


		if useLen > 0 then
			local remain = num - useLen
			local txtLen = self:accountTextLen(tab.text, tab.size)--string.len(tab.text)
			if txtLen <= remain then
				allTab[current] = allTab[current] .. tab.text
				self:addDataToRenderTab(copyVar, tab, tab.text, (useLen+1), current)
				useLen = useLen + txtLen
				txtTab = {}
			else
				local cTag = 0
				local mstr = ""
				local sIndex = useLen+1
				for k,element in pairs(txtTab) do
					local sLen = self:accountTextLen(element, tab.size)--string.len(element)
					if (useLen + sLen) <= num then
						useLen = useLen + sLen
						cTag = k
						mstr = mstr .. element
					else
						if string.len(mstr) > 0 then
							allTab[current] = allTab[current] .. mstr
							self:addDataToRenderTab(copyVar, tab, mstr, (sIndex), current)
						end
						current = current+1
						useLen = 0
						str = ""
						break
					end
				end
				for i=1,cTag do
					table.remove(txtTab, 1)
				end
			end
		end
		-- 填充字符
		local maxRow = math.ceil((member/num))
		for k,element in pairs(txtTab) do
			local sLen = self:accountTextLen(element, tab.size)--string.len(element)
			if (useLen + sLen) <= num then
				useLen = useLen + sLen
				str = str .. element
				--print(useLen,str)
			else
				allTab[current] =  str
				self:addDataToRenderTab(copyVar, tab, str, 1, current)
				current = current + 1
				useLen = sLen
				str = element
			end
			if k == #txtTab then
				if useLen <= num then
					allTab[current] = str
					self:addDataToRenderTab(copyVar, tab, str, 1, current)
				end
			end
		end
	end
	return allTab, copyVar
end

-- 拆分出单个字符
function RichLabel:tab_cutText(str)
    local list = {}
    local len = string.len(str)
    local i = 1
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end

	return list, len
end

function RichLabel:tab_createButton(params)
	--ui/texture/
    --[[cc.ui.UIPushButton.new("wsk.png", {scale9 = true})
        :setButtonSize(params.width, params.height)
        :setButtonLabel("normal", display.newTTFLabel({
            text  = params.text,
            size  = params.size,
            color = params.color,
            font  = params.font,
        }))
        :onButtonPressed(function(event)
        	event.target:getButtonLabel("normal"):setPosition(cc.p(0, 0))
        end)
        :onButtonClicked(function(event)
            event.target:getButtonLabel("normal"):setPosition(cc.p(0, 0))
            if self.listener then self.listener(event.target, params) end
        end)
        :onButtonRelease(function(event)
        	event.target:getButtonLabel("normal"):setPosition(cc.p(0, 0))
    	end)]]

	if params.text == "" then
		return 0,0
	end

    --local btn = display.newSprite("wsk.png")
    --    :align(display.LEFT_TOP, params.x, params.y)
    --    :addTo(params.scene)
    -- local normalLab = cc.LabelTTF:create(params.text, params.font, params.size)
    local normalLab = ccui.Text:create(params.text, params.font, params.size)
    if self.clickEventListener then
    	normalLab:setTag(self.tag)
    	normalLab:setTouchEnabled(true)
    	normalLab:addClickEventListener(self.clickEventListener)
    end
    params.scene:addChild(normalLab)
    -- normalLab:setFontFillColor(params.color)
    normalLab:setColor(params.color)    
    normalLab:setAnchorPoint(cc.p(0,1))
    normalLab:setPosition(cc.p(params.x, params.y))

    local useWidth = normalLab:getBoundingBox().width
    local useHeight = normalLab:getBoundingBox().height
    --if params.image then
    --	self:imageManage(btn, params, useWidth)
    --end

    --self.btn = btn
    return useWidth,useHeight
end

function RichLabel:updateButton()
	self.btn:onButtonPressed(function(event)
        	event.target:getButtonLabel("normal"):setPosition(cc.p(0, 0))
        end)
        :onButtonClicked(function(event)
            event.target:getButtonLabel("normal"):setPosition(cc.p(0, 0))
            if self.listener then self.listener(event.target, params) end
        end)
        :onButtonRelease(function(event)
        	event.target:getButtonLabel("normal"):setPosition(cc.p(0, 0))
    	end)
end

-- 图片标签处理
function RichLabel:imageManage(object, params, useWidth)
	local g = display.newSprite(params.image, 0, -4)
    g:setScaleX(useWidth / g:getContentSize().width)
    g:setScaleY(params.size / g:getContentSize().height)
    g:setAnchorPoint(cc.p(0, 1))
	object:addChild(g, 1)
	object:setButtonLabelString("normal", "")
	local move1 = cc.MoveBy:create(0.5, cc.p(0, 2))
    local move2 = cc.MoveBy:create(0.5, cc.p(0, -2))
    g:runAction(cc.RepeatForever:create(cc.Sequence:createWithTwoActions(move1, move2)))
    object.imageSprite = g
end

-- 设置监听函数
function  RichLabel:setClilckEventListener(eventName)
	self.listener = eventName
end

return RichLabel
