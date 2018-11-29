local display = require('cocos.framework.display')

--[[
不支持换行
args={
    text={
        {"hello",color={r=255,g=222,b=123}},
        {"wahahhasd"},
        {"c喔喔",color={r=255,g=222,b=123}}
        },


    font='Microsoft YaHei',
    size=23
}

str = [r,g,b]hello[r,g,b]world
]]

local RichLabel  = class('RichLabel', function()
    return display.newNode()
end)

function RichLabel:ctor(args)
    if args then
        self.font = args.font
        self.size = args.size
        self:setString(args.text)
    end
end

function RichLabel:setString(str)
    RichLabel.setStringToNode(self, {text=str,font=self.font,size=self.size})
end

function RichLabel.whatNode(str)
    local node  = display.newNode()

    display.newTTFLabel({text = str, font = "Microsoft YaHei", color = cc.c3b(126,155,255),dimensions = cc.size(280,0),size = 21})
        :addTo(node):setAnchorPoint(cc.p(0,1))


    return node
end

--for the fucking tableview
function RichLabel.setStringToNode(node, args)

    node:removeAllChildren()

    local normal = {
        font  = args.font,
        size  = args.size,
        align = cc.TEXT_ALIGN_LEFT,
        valign= cc.TEXT_VALIGN_TOP
    }

    local str = args.text
    local tp = type(str)
    local offx = 0

    if tp == 'table' then

        local default_color = {r=255,g=255,b=255}

        for i, v in ipairs(str) do
            local c = v.color and v.color or default_color
            normal.text = v[1]
            normal.color = cc.c3b(c.r, c.g, c.b)

            local label = display.newTTFLabel(normal):addTo(node, 0):pos(offx, 0)
            offx = offx + label:getTexture():getContentSize().width
        end
    elseif tp == 'string' then
        for color, text in string.gmatch(str, "(%[%d+%,%d+%,%d+%])([^%]%[\n]*)") do
            local r,g,b = string.match(color, "%[(%d+)%,(%d+)%,(%d+)%]")
            normal.color = cc.c3b(r, g, b) or cc.c3b(0,0,0)
            normal.text = text or ""
            local label = display.newTTFLabel(normal):addTo(node, 0):pos(offx, 0)
            label:setAnchorPoint(cc.p(0,0.5))
            --offx = offx + label:getTexture():getContentSize().width
            offx = offx + label:getCascadeBoundingBox().width
        end
    end
    return offx
end

function RichLabel.parse(str)
    if type(str) == 'string' then
        local color, retstr = string.match(str, "(%[%d+%,%d+%,%d+%])([^%]%[\n]*)")

        local r,g,b =255,255,255
        if type(color) == 'string' then
            r, g, b = string.match(color, "%[(%d+)%,(%d+)%,(%d+)%]")
        else
            --print('RichLabel:parse color failed', str)
            return str, cc.c3b(255, 255, 255)
        end

        return retstr, cc.c3b(r, g, b)
    else
        print('RichLabel:parse failed', str)
        return "", cc.c3b(255, 255, 255)
    end
end

return RichLabel
