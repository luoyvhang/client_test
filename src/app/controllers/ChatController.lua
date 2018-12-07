local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local TranslateView = require('app.helpers.TranslateView')
local ChatController = class("ChatController", Controller):include(HasSignals)

function ChatController:initialize()
  Controller.initialize(self)
  HasSignals.initialize(self)
end

function ChatController:viewDidLoad()
  self.view:layout()
  self.view:on("choosed", function(i)
    self.emitter:emit('back')
    local app = require("app.App"):instance()

    local tmsg = {
      msgID = 'chatInGame',
      type = 0,
      msg = i
    }
    app.conn:send(tmsg)
  end)

  self.view:on("back", function()
    TranslateView.moveCtrl(self.view, 1, function()
      self.view:hide()
    end)
  end)
end

function ChatController:clickSend()
  local text = self.view:getSendText()
  if #text == 0 then
    return
  end

  local app = require("app.App"):instance()

  local tmsg = {
    msgID = 'chatInGame',
    type = 2,
    msg = text
  }
  app.conn:send(tmsg)

  self:clickBack()
end

function ChatController:clickBack()
  self.emitter:emit('back')
end

function ChatController:sendText()
end

function ChatController:finalize()-- luacheck: ignore
end

return ChatController
