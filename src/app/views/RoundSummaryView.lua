local RoundSummaryView = {}
function RoundSummaryView:initialize()
end

function RoundSummaryView:layout()
  self.MainPanel = self.ui:getChildByName('MainPanel')
  self.MainPanel:setPosition(display.cx,display.cy)
end

return RoundSummaryView
