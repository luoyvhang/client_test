local MessageBox = {}
local deferred = require('deferred')
local array = require('array')

function MessageBox:show(options) -- luacheck: ignore self
  local d = deferred.new()
  local buttons = options.buttons or {'ok'}
  local callbacks = array.map(buttons, function(name)
    return function() d:resolve(name) end
  end)
  require('app.App'):instance().layers.top:switch('MsgBoxController', options.title or '', options.message or '', unpack(callbacks))
  return d
end

return MessageBox
