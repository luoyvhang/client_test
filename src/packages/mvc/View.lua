local View = class("View", cc.Node)
local HasSignals = require('HasSignals')



local function mixin(self, script)
    for k, v in pairs(script) do
        -- added by hthuang: onExit can not be used
        -- assert(self[k] == nil, 'Your script "app/views/'..self.name..'.lua" should not have a member named: ' .. k)
        self[k] = v
    end
end

-- return node on success
-- return emptynode, true on error
local function loadUI(csb)
    print('Loading "'..csb..'"...')
    if not cc.FileUtils:getInstance():isFileExist(csb) then
        print('Not exists. Skippd.')
        return cc.Node:create()
    end


    local node = cc.CSLoader:createLocalizedNode(csb)
    if not node then
        print(string.format('Failed to load View node from "%s" ', csb))
        return cc.Node:create()
    end

    return node
end
View.loadUI = loadUI

View.loadUI = loadUI

function View:ctor(name, ...)
  self:enableNodeEvents()
  self.name = name
  for _, v in ipairs {'on', 'once'} do
    self[v] = HasSignals[v]
  end
  HasSignals.initialize(self)


  self.ui = loadUI('views/'..name..'.csb')
  self:addChild(self.ui)

  -- load lua script and event view callbacks...
  local ok, script = pcall(require, 'app.views.'..name)
  if ok then
    mixin(self, script)
  else
    print('not found the view script file',name)
  end


  if self.initialize then
    self:initialize(...)
  end
end

return View
