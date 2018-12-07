local AddUiTop = {}
local Controller = require('mvc.Controller')
local App = require('app.App')

local _suitop
function AddUiTop.show(type_, callBack_)
  type_ = type_ or 1
  if not _suitop then
    _suitop = Controller.loadController('UiTopController');
    --App.topLayer:addChild(_suitop.view)
  end

  _suitop:switch(type_, callBack_)

  _suitop.view:setVisible(true)
  _suitop:enabledSetting(true)
end

function AddUiTop.enableSetting(b)
  _suitop:enabledSetting(b)
end

function AddUiTop.hide()
  if _suitop then
    _suitop.view:setVisible(false)
  end
end

return AddUiTop
