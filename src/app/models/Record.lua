local class = require('middleclass')
local HasSignals = require('HasSignals')
local Record = class('Record'):include(HasSignals)

function Record:initialize()
  HasSignals.initialize(self)

  self.records = {}


  -- 开始接受战绩列表
  local app = require("app.App"):instance()
  app.conn:on("beganlistRecords",function(msg)
    self.records = {}
  end)

  -- 单局战绩
  app.conn:on("listRecords",function(msg)
    print("getlistRecord")
    table.insert( self.records, msg.record)
    self.emitter:emit('newRecord', self.records)
  end)

  -- 结算接受战绩列表
  app.conn:on("endlistRecords",function(msg)
    self.emitter:emit('listRecords', self.records)
  end)

  -- 没有战绩
  app.conn:on("nonelistRecords",function(msg)
    self.records = {}
    self.emitter:emit('nonelistRecords', self.records)
  end)

end

function Record:listRecords()--luacheck:ignore
  local app = require("app.App"):instance()

  local msg = {
    msgID = 'listRecords',
  }
  app.conn:send(msg)
end

return Record
