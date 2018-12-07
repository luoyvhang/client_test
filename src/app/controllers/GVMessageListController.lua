local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local GVMessageListController = class("GVMessageListController", Controller):include(HasSignals)

function GVMessageListController:initialize(group)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.group = group
end

function GVMessageListController:viewDidLoad()
    self.view:layout(self.group)
    local group = self.group

    self.listener = {
        self.group:on('Group_adminMsgResult',function(msg)     
            self.view:reloadTableView()
            local msgCnt = table.nums(msg.data)
            if msgCnt ~= 0 then
                self.view:freshTips(false)
            else
                self.view:freshTips(true)
            end
        end),  

        self.view:on('messageListOperate',function(optApply)
            dump(optApply)
            local groupInfo = group:getCurGroup()
            local groupId = groupInfo.id
            local playerId = optApply[1]
            local operate = optApply[2]
            group:acceptJoin(groupId, playerId, operate)
        end),           
    } 

    local groupInfo = group:getCurGroup()
    local groupId = groupInfo.id
    group:adminMsgList(groupId) 
end

function GVMessageListController:clickBack()
    self.emitter:emit('back')
end

function GVMessageListController:finalize()
    for i = 1,#self.listener do
      self.listener[i]:dispose()
    end
end

return GVMessageListController
