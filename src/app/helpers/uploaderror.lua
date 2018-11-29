local UploadError = {}

local isChangeTraceback = false
local all = {}


function UploadError.upload2server(error)
  local config = require('config')
  print('#error is ',#error)
  error = config.update..'\r\n'..error

  local http = require('http')
  local opt = {
    host = config.host..':1991',
    path = '',
    method = 'POST'
  }

  local req = http.request(opt, function(response)
    local cjson = require('cjson')
    local body = response.body
    body = cjson.decode(body)
    if body then
      if body.success then
        print('upload client error success')
      end

      if #all > 0 then
        local last = all[#all]
        table.remove(all,#all)
        UploadError.upload2server(last)
      end
    end
  end)
  req:write(error)
  req:done()
end

function UploadError.changeTraceback()
  if isChangeTraceback then return end
  isChangeTraceback = true

  local traceback = _G.debug.traceback

  local function new_traceback(...)
    local ret = traceback(...)
    if (...) and #(...) > 0 then
      if #all == 0 then
        UploadError.upload2server(ret)
      else
        all[#all+1] = ret
      end
    end
    return ret
  end

  _G.debug.traceback = new_traceback
end

return UploadError
