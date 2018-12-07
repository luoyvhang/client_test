local ShareView = {}

function ShareView:initialize()
end

function ShareView:layout()
	local MainPanel = self.ui:getChildByName('MainPanel')
	MainPanel:setContentSize(cc.size(display.width,display.height))
	MainPanel:setPosition(display.cx,display.cy)
	self.MainPanel = MainPanel

	local middle = MainPanel:getChildByName('middle')
	middle:setPosition(display.cx,display.cy)
end

return ShareView