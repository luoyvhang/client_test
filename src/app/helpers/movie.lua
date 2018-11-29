local movie = {}
local Player = require('video.Player')



function movie.open(path, func)
  local p = Player.new(path)
  p:on('Prepared', function()
    local s = cc.Sprite:createWithTexture(p:texture())
    print(s:getContentSize().width, s:getContentSize().height)
    func(s)
  end)
  p:start()

  return p
end

return movie
