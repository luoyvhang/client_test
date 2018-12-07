local invoke = require('invoke')
local tool = {}

function tool.getExternalStorageDirectory()
  return invoke('com.shininggames.tool.Tool', 'getExternalStorageDirectory','not')
end

return tool
