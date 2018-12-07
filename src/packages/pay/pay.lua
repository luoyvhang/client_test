local Pay = {}
--local handle

function Pay.go(rmb,callback)
  --local app = require("app.App"):instance()
  if device.platform ~= 'ios' and device.platform ~= 'android' then
    if callback then
      callback(true)
    end
    return
  end

  local function logic(order)
    local invoke = require('invoke')

    if order then
      invoke('com.shininggames.pay.Bankpay', 'setOrder',order)
    end

    invoke('com.shininggames.pay.Bankpay', 'pay',tostring(rmb * 100),function(success)
      if type(success) == 'string' then
        local flg = success == 'success'

        if callback then
          callback(flg)
        end
      else
        if success then
          if callback then
            callback(success)
          end
        end
      end
    end)
  end

  logic()


  --[[if handle then
    handle:dispose()
    handle = nil
  end

  handle = app.session.user:once('queryPayOrder',function(order)
    logic(order)
  end)
  app.session.user:queryPayOrder()]]
end

return Pay
