local ShopView = {}

function ShopView:initialize()
end

local buy_gem_rmd_map = {
  {
    1,1
  },
  {
    10,12
  },
  {
    100,150
  },
  {
    300,480
  },
  {
    500,850
  },
  {
    1000,2000
  },
}

function ShopView:layout()
  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setPosition(display.cx,display.cy)

  local black = self.ui:getChildByName('black')
  black:setContentSize(cc.size(display.width,display.height))

  local list = self.MainPanel:getChildByName('list')
  local items = list:getItems()

  for i = 1,#items do
    local item = items[i]
    local buy = item:getChildByName('buy')

    local mul = 1
    buy:addClickEventListener(function()
      self.emitter:emit('buy',buy_gem_rmd_map[i],mul)
    end)

    if i == 1 then
      local add = item:getChildByName('add')
      local sub = item:getChildByName('sub')

      local rmb = item:getChildByName('rmb')
      local nunber = item:getChildByName('gem'):getChildByName('number')
      add:addClickEventListener(function()
        mul = mul + 1
        if mul > 9 then mul = 9 end

        rmb:setString(mul..'元')
        nunber:setString(mul)
      end)

      sub:addClickEventListener(function()
        mul = mul - 1
        if mul < 1 then
          mul = 1
        end

        rmb:setString(mul..'元')
        nunber:setString(mul)
      end)
    end
  end
end


return ShopView
