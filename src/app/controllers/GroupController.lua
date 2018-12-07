local class = require('middleclass')
local Controller = require('mvc.Controller')
local HasSignals = require('HasSignals')
local SoundMng = require "app.helpers.SoundMng"
local tools = require('app.helpers.tools')
local TranslateView = require('app.helpers.TranslateView')
local GroupController = class("GroupController", Controller):include(HasSignals)

function GroupController:initialize(nextSwitchParam)
    Controller.initialize(self)
    HasSignals.initialize(self)

    self.toggleDelView = false
    self.toggleBanView = false

    self.msgListView = nil
    self.initSelectGroupId = nil
    if nextSwitchParam then
        self.initSelectGroupId = nextSwitchParam.groupId
    end
end

function GroupController:viewDidLoad()
  local app = require("app.App"):instance()
  local group = app.session.group
  self.group = group

  self.createRoomCtrl = nil

  self.view:layout()
  self.listener = {
    group:on('listGroup',function(groups)
        local groupsData = self.group:getListGroup()
        self.view:freshListGroups(groupsData, self.initSelectGroupId)
        self.initSelectGroupId = nil
        --根据牛友群列表是否为空去显示或隐藏成员,设置,消息按钮
        local groupCnt = self.view:getGroupsCnt()
        if #groupCnt == 0 then
            self.view:freshAdminMsgBtn(false) 
            self.view:freshNormalMsgBtn(false)   
            self.view:freshSettingBtn(false)
            self.view:freshInviteBtn(false)
            self.view:freshRoomCardBtn(false)
            self.view:freshMemberBtn(false) 
            self.view:freshRightbg(false) 
            self.view:freshCreateBtn() 
            self.view:freshGroupNameAndID(false)  
            self.view:freshNotifyLayer(false)
            self:freshMsgListView(false)
            self.view:freshRoomList(nil, nil, true)
            self.view:freshTopCopyBtn(false)
            self.view:freshRoomCardState(false)       
            self.view:freshQuickJoinBtn(false)          
        else  
            self.view:freshSettingBtn(true)
            self.view:freshInviteBtn(true)
            self.view:freshRoomCardBtn(true)
            self.view:freshMemberBtn(true)   
            self.view:freshRightbg(true)  
            self:freshMsgListView(true)                                      
        end
    end),

    --创建房间结果消息
    group:on('GroupMgr_creatResult',function(groups)
        self:clickCancelCreate()
    end),

    -- 查询牛友群结果消息 0:查询失败 1:查询成功
    group:on('GroupMgr_getGroupResult',function(queryMessage)
        if queryMessage.code == 1 and queryMessage.mode == 1 then
            local info = queryMessage.groupInfo.ownerInfo
            local groupName = queryMessage.groupInfo.name
            local adminName = info.nickname
            local avatar = info.avatar
            self.view:freshQueryResult(true, groupName, adminName, avatar)
            self.view:freshBtnState(false)
        elseif queryMessage.code == 1 and queryMessage.mode == 2 then
            self:updateCurGroupView()
        else
            tools.showRemind("俱乐部不存在")     
        end
    end),   

    -- 新牛友群信息
    group:on('groupInfo',function(msg)
        self:updateCurGroupView()
        local groupsData = self.group:getListGroup()
        self.view:freshListGroups(groupsData)
    end),

    -- 牛友群加入结果消息 -1:已被管理员屏蔽 -2:已在群里 -3:已经申请过了 1:申请成功等待管理员处理
    group:on('joinRequestResult',function(joinMessage)
        if joinMessage.code==1 then
            tools.showRemind("已成功提交,请耐心等待管理批准")
        elseif joinMessage.code==-3 then
            tools.showRemind("您已提交了加入申请,请耐心等待管理员审核")
        end
    end),          

    -- 消息列表结果
    group:on('Group_adminMsgResult',function(msg)
        local msgCnt = table.nums(msg.data)
        self.view:freshNewMessageTips(msgCnt ~= 0, msgCnt)
    end),   

    -- 消息处理结果
    group:on('Group_acceptJoinResult',function(optResult)
    end),  

    group:on('Group_requestResult',function(msg)
        local groupInfo = msg.groupInfo        
        local content = ''
        local result
        if msg.code == 1 then 
            result = '同意'
            content = string.format( "群主%s, 已%s了您的入圈申请\n(群名称:%s,群ID:%s)",
                groupInfo.ownerInfo.nickname,result,groupInfo.name,groupInfo.id )                    
        else
            result = '拒绝'
            content = string.format( "群主%s, 已%s了您的入圈申请\n(群名称:%s,群ID:%s)",         
                groupInfo.ownerInfo.nickname,result,groupInfo.name,groupInfo.id ) 
        end
        tools.showMsgBox("提示", content, 1)
    end),  

    -- 设置改名处理结果
    group:on('onModifyInfoResult',function(modResult)
    end), 

    group:on('onModifyNoticeResult',function(msg)
        self.view:freshSetNotifyLayer(false)      
        -- tools.showRemind('设置成功')
    end), 

    group:on('Group_setRoomConfigResult',function(msg)
        local groupInfo = group:getCurGroup()
        local groupId = groupInfo.id
        self.group:getRoomConfig(groupId)
    end), 

    group:on('getGroupNotice',function(msg)
        local groupInfo = group:getCurGroup()
        local groupId = groupInfo.id        
        local msg = self.group:getNotice(groupId)
        self.view:freshNotifyContent(true, msg)    
    end), 

    -- 解散结果
    group:on('GroupMgr_dismissResult',function(msg)
        if msg.code == -1 then
            tools.showRemind('群内还有未使用的钻石!请取出后再解散.')
        elseif msg.code == -2 then
            tools.showRemind('群内还有未结束的游戏!暂时不能解散.')
        elseif msg.code == 1 then
            local groupInfo = self.group:getCurGroup()
            local groupName = groupInfo.name       
            tools.showRemind('您所在的俱乐部['..groupName..']已被管理解散')
            local groupsData = self.group:getListGroup()
            self.view:freshListGroups(groupsData) --刷新群列表      
        end
  
    end), 

    group:on('groupDismiss',function(disResult)
        local group = self.group
        local groupInfo = self.group:getCurGroup()
        local groupName = groupInfo.name     
        local myPlayerId = group:getPlayerRes("playerId") --自己id
        local ownerId = groupInfo.ownerInfo.playerId --ID   
        if  ownerId ~= myPlayerId then       
            tools.showRemind('您所在的俱乐部['..groupName..']已被管理解散')
            local groupsData = self.group:getListGroup()
            self.view:freshListGroups(groupsData) --刷新群列表    
        end    
    end), 

    -- 退出群结果
    group:on('Group_quitResult',function(msg)
        local groupsData = self.group:getListGroup()
        self.view:freshListGroups(groupsData)        
    end),

    -- 成员信息
    -- group:on('memberList',function(msg)
    --     -- self:updateCurGroupMemberList()
    -- end),

    -- 成员信息
    group:on('newDesk',function(groupId)
        self.view:setViewDataTabNewDeskPoint('add', groupId)
        self.view:freshGroupListPoint()
        if self.view:getGrouopSoundData(groupId) then
            -- TODO:播放声音
            SoundMng.playEft('ring_jlb_room.mp3')
        end
    end),

    -- 房间列表
    group:on('groupRoomList',function(msg)
        local groupInfo = group:getCurGroup()
        local groupId = groupInfo.id
        local roomList = group:getRoomList(groupId)
        local myPlayerId = group:getPlayerRes("playerId") --自己id
        
        if roomList and table.nums(roomList)>0 then
            self.view:freshRoomList(roomList, myPlayerId)
            self.view:freshCreateRoomTips(false)
        else
            self.view:freshRoomList(nil, nil, true)
            self.view:freshCreateRoomTips(true)
        end
    end),


    -- 创建房间结果
    group:on('Group_createRoomResult',function(msg)
        if msg.code == -100 then
            tools.showRemind('管理员未开启群员创建房间功能')
        end
        self:delCreateRoomController()
    end),

    -- 快速开始结果
    group:on('Group_quickStartResult',function(msg)
        if msg and msg.code and msg.code < 0 and msg.desc then
            tools.showRemind(msg.desc)
        end
    end),

    group:on('Group_chargeDiamondResult',function(msg)
        if msg.code == 1 then
            tools.showRemind('充值成功')
        elseif msg.code == -1 then
            tools.showRemind('钻石不足')
        elseif msg.code == -100 then
            tools.showRemind('管理员未开启群员充值功能')
        end
        -- self.view:freshAddRoomCard(false)
    end),

    group:on('Group_recaptionDiamondResult',function(msg)
        if msg.code == 1 then
            tools.showRemind(string.format( "成功取出群内 %s 钻石到个人账号.", msg.cnt))
        elseif msg.code == -1 then
            tools.showRemind('群内钻石不足')
        end
        -- self.view:freshAddRoomCard(false)
    end),


    group:on('Group_createRoom',function(msg)
        if msg.code == -1 then
            tools.showRemind('群内钻石不足')
        end
    end),

    group:on('queryUserInfoResult',function(msg)
        if msg.data then
            msg.data.searchMode = true
            self:setWidgetAction('PersonalPageController', {msg.data})
        end
    end),

    -- 设置机器人建房结果
    group:on('resultSetRobotCreateRoom',function(msg)
        if msg.flag then
            tools.showRemind('开启成功')
        else
            tools.showRemind('关闭成功')
        end
    end),

    -- 房主信息
    self.view:on('ownerinfo',function(playerId) -- 刷新消息
        self.group:queryUserInfo(playerId)
    end),  

    -- 选择群
    self.view:on('selectGroup',function(groupId) -- 刷新消息
        app:setNextSwitchParam('LobbyController', {subCtrl='GroupController', groupId = groupId})
        self.view:setViewDataTabNewDeskPoint('del', groupId)
        self.view:freshGroupListPoint()
        self.group:getGroupById(groupId, 2)
        self.group:getGroupNotice(groupId)
        self.group:queryAdvanceOption(groupId)
        -- self.group:synMsg(groupId, 2)     
    end),  

    -- admin设置改名操作
    self.view:on('settingOperateModify',function()
        local groupInfo = group:getCurGroup()
        local groupName = groupInfo.name       
        self.view:freshAdminSettingLayer(false)  
        self.view:freshNormalSettingLayer(false)         
        self.view:freshModifyGroupName(true, groupName)	        
    end),  

    -- admin设置解散操作
    self.view:on('settingOperateDismiss',function()
        local groupInfo = group:getCurGroup()
        local groupName = groupInfo.name       
        self.view:freshAdminSettingLayer(false) 
        self.view:freshNormalSettingLayer(false)         
        self.view:freshDismissGroup(true, groupName)	         
    end),      

    self.view:on('memberListDelMember',function(playerId)
        if not playerId then return end
        local groupInfo = self.group:getCurGroup()
        local groupId = groupInfo.id 
        group:delUser(groupId, playerId)
    end),  

    self.view:on('memberListBanMember',function(msg)
        if not msg then return end
        local groupInfo = self.group:getCurGroup()
        local groupId = groupInfo.id 
        group:banUser(groupId, msg[1], msg[2])
    end),  

    -- 点击房间
    self.view:on('touchRoomItem',function(data)
        self.view:freshRoomInfo(true, data)
    end),

    -- 发送快捷语
    self.view:on('choosed', function(idx)
        self:clickShortcutListLayer()
        local groupInfo = group:getCurGroup()    
        local groupId = groupInfo.id    
        group:shortcutChat(groupId, idx)
    end),

    -- top复制圈号    
    self.view:on('copyGroupId',function(msg)
        self.view:onClickTopCopyBtn(msg)
    end),

    -- 复制圈公告    
    self.view:on('copyGroupNotice',function(msg)
        local groupInfo = group:getCurGroup()
        local groupId = groupInfo.id
        local notice = group:getNotice(groupId)
        self.view:onClickCopyNotice(notice)
    end),

    -- 加入房间    
    self.view:on('enterRoom',function(roomId)
        group:enterRoom(roomId)
    end),

    self.view:on('chargeDiamond',function(cnt)
        local groupInfo = group:getCurGroup()
        local groupId = groupInfo.id
        group:chargeDiamond(groupId, cnt)
    end),

    self.view:on('recaptionDiamond',function(cnt)
        local groupInfo = group:getCurGroup()
        local groupId = groupInfo.id
        group:recaptionDiamond(groupId, cnt)
    end),

  }
    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID = scheduler:scheduleScriptFunc(function()
        group:groupList()
    end, 5, false)

    group:groupList()


    self.view:freshRoomCardState(false)

end

function GroupController:freshMsgListView(bShow)
    bShow = bShow or false
    if self.msgListView then
        self.msgListView:setVisible(bShow)
    end
end

-- 更新当前牛友群信息
function GroupController:updateCurGroupView()
    local group = self.group
    local myPlayerId = group:getPlayerRes("playerId") --自己id
    local groupInfo = group:getCurGroup()
    local ownerId = groupInfo.ownerInfo.playerId --ID
    local memberNum = groupInfo.memberCnt --组成员数
    local adminMsgCnt = groupInfo.adminMsgCnt --管理员消息数
    local roomNum = groupInfo.roomCnt --房间数
    local groupId = groupInfo.id --群ID
    local groupName = groupInfo.name --群名称
    local isOwner = (ownerId == myPlayerId)
    local diamond = groupInfo.diamond or 0

    self.view:freshGroupNameAndID(true, groupName, groupId)
    self.view:freshTopCopyBtn(isOwner, groupId)
    self.view:freshRoomCardState(true, diamond, isOwner)
    self.view:freshQuickJoinBtn(true)
    self.view:freshNotifyLayer(true)
    if isOwner then
        self.view:freshAdminMsgBtn(true)
        self.view:freshNormalMsgBtn(false) 
        self.view:freshCreateBtn(1)
        self.view:freshNewMessageTips(adminMsgCnt ~= 0, adminMsgCnt)
    else
        self.view:freshAdminMsgBtn(false)
        self.view:freshNormalMsgBtn(true) 
        self.view:freshCreateBtn(0)
    end
end

-- 更新当前牛友群成员列表
function GroupController:updateCurGroupMemberList()
    local group = self.group
    local myPlayerId = group:getPlayerRes("playerId") --自己id
    local groupInfo = group:getCurGroup()
    local groupId = groupInfo.id
    local memberInfo = group:getMemberInfo(groupId)
    local ownerInfo = groupInfo.ownerInfo
    self.view:freshMemberList(memberInfo, ownerInfo, myPlayerId)
    self.toggleDelView = not self.toggleDelView
end

function GroupController:clickSetting()
    SoundMng.playEft('btn_click.mp3')
    local myPlayerId = self.group:getPlayerRes("playerId") 
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id
    local ownerId = groupInfo.ownerInfo.playerId

    if myPlayerId == ownerId then
        self.view:freshAdminSettingLayer(true)  
    else
        self.view:freshNormalSettingLayer(true) 
    end 
end

function GroupController:clickSureModify()  
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id  
	local input = self.view:getModifyEditBoxInfo()
    local inputLength = string.match(input, "%S+")
	if input and inputLength then
		print("getModifyEditBoxInfo", input)
		self.group:modifyGroupName(groupId,input) 
        self.view:freshModifyGroupName(false)         
    elseif not inputLength then
        tools.showRemind("俱乐部名字为空")               
	end      
end

function GroupController:clickCancelModify()
    self.view:freshModifyGroupName(false)    
end

-- 确认解散群
function GroupController:clickSureDismiss()  
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id 
    self.group:dismissGroup(groupId)
    self.view:freshDismissGroup(false)   
end

function GroupController:clickCancelDismiss()
    self.view:freshDismissGroup(false)    
end
--开房声音
function GroupController:clickOpenSoundLayer()
    SoundMng.playEft('btn_click.mp3')
    self.view:freshAdminSettingLayer(false)
    self.view:freshNormalSettingLayer(false)
    self.view:freshRoomSound(true)    
end

function GroupController:clickCloseSoundLayer()
    self.view:freshRoomSound(false)    
end

function GroupController:clickCloseMessageLayer()
    self.view:freshNormalMessage(false)    
end

function GroupController:clickSureSound()
    self.view:saveGroupSoundData() 
    self.view:freshRoomSound(false)    
end

function GroupController:clickSoundOn()
    self.view:freshRoomSoundOpt(false,true)    
end

function GroupController:clickSoundOff()
    self.view:freshRoomSoundOpt(true,false)    
end

--退出群
function GroupController:clickQuitBtn()
    local groupInfo = self.group:getCurGroup()
    local groupName = groupInfo.name   
    self.view:freshNormalSettingLayer(false)   
    self.view:freshQuitGroup(true, groupName)    
end

function GroupController:clickCancelQuit()    
    self.view:freshQuitGroup(false)    
end

function GroupController:clickSureQuit()  
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id 
    self.group:quitGroup(groupId)
    self.view:freshQuitGroup(false)    
end

function GroupController:clickMemberBtn()
    SoundMng.playEft('btn_click.mp3')
    local myPlayerId = self.group:getPlayerRes("playerId") 
    local groupInfo = self.group:getCurGroup()
    if not groupInfo then return end
    local ownerId = groupInfo.ownerInfo.playerId
    local groupId = groupInfo.id

    self.group:memberList(groupId)
    self:setWidgetAction(
        'GVMemberListController', 
        {self.group, (myPlayerId == ownerId)}
    )
end

--删除成员
function GroupController:clickDelMember()
    self:updateCurGroupMemberList()
    if not self.toggleDelView then
        self.view:freshAdminMemberListDelBtn(nil, true)
    end
end

--禁止加入
function GroupController:clickBanPlayer()
    self:updateCurGroupMemberList()
    if not self.toggleDelView then
        self.view:freshAdminMemberListBanBtn(nil, true)
    end
end

--创建牛友群
function GroupController:clickCreateGroup()
    print("creating group...")
    self.view:freshGroupCreateLayer(true)
    self.view:freshAddLayer(false)  
    self.view:freshGroupListVisible(false) 
    
    self.view:freshCreateEditBox("", true)
    self.view:freshGroupJoinLayer(false)
end

--加入牛友群
function GroupController:clickJoinGroup()
    print("joining group...")
    self.view:freshGroupJoinLayer(true)
    self.view:freshAddLayer(false)  
    self.view:freshGroupListVisible(false) 

    self.view:freshJoinEditBox("", true) --------------
    self.view:freshGroupCreateLayer(false)

end

function GroupController:clickJoinRoom()
    self:setWidgetAction('EnterRoomController', self)
end

function GroupController:clickAlterRoomMode()
    local groupInfo = self.group:getCurGroup()
    local advanceOption = self.group:getAdvanceOption(groupInfo.id)
    self.createRoomCtrl = self:setWidgetAction('CreateRoomController', groupInfo, nil, advanceOption)
    self.view:freshAdminSettingLayer(false)
end

function GroupController:clickquickSet()
    local groupInfo = self.group:getCurGroup()
    if not groupInfo then return end
    local advanceOption = self.group:getAdvanceOption(groupInfo.id)
    self.createRoomCtrl = self:setWidgetAction('CreateRoomController', groupInfo, 1, advanceOption)
    self.view:freshAdminSettingLayer(false) 
end

function GroupController:clickCreate()
    local groupInfo = self.group:getCurGroup()
    if not groupInfo then return end
    local advanceOption = self.group:getAdvanceOption(groupInfo.id)
    local roomMode = self.view:getRoomMode()
    groupInfo.roomMode = roomMode
    self.createRoomCtrl = self:setWidgetAction('CreateRoomController', groupInfo, 2, advanceOption)
    self.view:freshAdminSettingLayer(false) 
end

function GroupController:delCreateRoomController()
    if self.createRoomCtrl then
        self.createRoomCtrl:delete()
    end
    self.createRoomCtrl = nil
end

-- 点击成员显示头像
function GroupController:clickMemberInfo()
    -- setWidgetAction('PersonalPageController', self, nil)
end

--牛友群----------------------创建 确定
function GroupController:clickSureCreate()
	local input = self.view:getCreateEditBoxInfo()
    local inputLength = string.match(input, "%S+")
    if input and inputLength then
		print("clickSureCreate", input)
		self.group:creatGroup(input)
    elseif not inputLength then
        tools.showRemind("俱乐部名字为空")
	end    
end

----------------------创建 取消
function GroupController:clickCancelCreate()
    self.view:freshGroupCreateLayer(false) 
    self.view:freshCreateEditBox("", true)
    self.view:freshGroupListVisible(true) 
end

----------------------加入 查询
function GroupController:clickQueryJoin()
	local input = self.view:getJoinEditBoxInfo()
	if input and input~="" then
		print("clickQueryJoin", input)
		self.group:getGroupById(input, 1)
	end    
end

-----------------------加入 取消
function GroupController:clickCancelJoin()
    self.view:freshGroupJoinLayer(false) 
    self.view:freshJoinEditBox("", true)
    self.view:freshGroupListVisible(true) 
end

-----------------------加入       确定
function GroupController:clickJoinBtn()
    self.group:requestJoin()
end

-----------------------加入       放弃
function GroupController:clickBackBtn()
    self.view:freshQueryResult(false)
    self.view:freshBtnState(true) 
end

function GroupController:clickAdd()
    SoundMng.playEft('btn_click.mp3')
    self.view:freshAddLayer(true)        
end

function GroupController:clickMessage()
    SoundMng.playEft('btn_click.mp3')
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id
    self.group:adminMsgList(groupId) 
    self:setWidgetAction('GVMessageListController', self.group)    
end

function GroupController:clickLookMessage()
    SoundMng.playEft('btn_click.mp3')
    self.view:freshNormalMessage(true)
end

-- 修改公告
function GroupController:clickSureModifyNotice()
    SoundMng.playEft('btn_click.mp3')
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id  
	local input = self.view:getNoticeEditBoxInfo()
    local inputLength = string.match(input, "%S+")    
	if input and inputLength then
		self.group:modifyGroupNotice(groupId, input)                      
	end 
end

-- 发送个人信息
function GroupController:clickSureSendPersonalInfo()
    SoundMng.playEft('btn_click.mp3')
    local groupInfo = self.group:getCurGroup()    
    local groupId = groupInfo.id   
	local input = self.view:getPersonalEditBoxInfo()
    local inputLength = string.match(input, "%S+")
	if input and inputLength then
		self.group:shortcutChat(groupId, nil, input)      
        -- self.view:freshPersonalInfoLayer(false)
    else
        tools.showRemind('输入为空,请重新输入')             
	end 
end

function GroupController:clickCloseRobot()
    local groupInfo = self.group:getCurGroup()
    if not groupInfo then return end
    local groupId = groupInfo.id
    self.group:setRobotCreateRoom(groupId, false)
end

function GroupController:clickOpenRobot()
    local groupInfo = self.group:getCurGroup()
    if not groupInfo then return end
    local groupId = groupInfo.id
    local advanceOption = self.group:getAdvanceOption(groupInfo.id)
    if advanceOption.createRoom == 2 and  advanceOption.payMode == 2 then
        self.group:setRobotCreateRoom(groupId, true)
    else
        tools.showRemind('请确保已开启基金支付和只有管理员开房设置')
    end
end

-- 发送公告
function GroupController:clickSendNotice()
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id
    local notice = self.group:getNotice(groupId)    
    local contentLength = string.match(notice, "%S+")
	if notice and contentLength then
		self.group:shortcutChat(groupId, nil, notice)     
	else
		tools.showRemind('还没设置公告信息,快设置下吧!')
		return
	end    
end

-- 触摸隐藏
function GroupController:clickAddLayer()
    self.view:freshAddLayer(false) 
end

function GroupController:clickAdminSettingLayer()
    self.view:freshAdminSettingLayer(false) 
end

function GroupController:clickNormalSettingLayer()
    self.view:freshNormalSettingLayer(false) 
end

function GroupController:clickSetNotifyLayer()
    self.view:freshSetNotifyLayer(false) 
end

function GroupController:clickRoomInfoLayer()
    self.view:freshRoomInfo(false) 
end

function GroupController:clickRoomDetailLayer()
    self.view:freshRoomDetailInfo(false) 
end

function GroupController:clickPersonalInfoLayer()
    -- self.view:freshPersonalInfoLayer(false) 
end

function GroupController:closeAddRoomCard()
    -- self.view:freshAddRoomCard(false)
end

function GroupController:clickCloseWan()
    -- self.view:freshRoomInfo(false) 
end

function GroupController:clickAddRoomCard()
    local group = self.group
    local groupInfo = group:getCurGroup()
    local ownerId = groupInfo.ownerInfo.playerId --ID   
    local myPlayerId = group:getPlayerRes("playerId") --自己id
    local gDiamond = groupInfo.diamond
    if  ownerId == myPlayerId then     
        local diamond = self.group:getPlayerRes('diamond')
        -- self.view:freshAddRoomCard(true, gDiamond, diamond)
    end
end

function GroupController:clickShortcutWords()
    -- self.view:freshShortcutListLayer(true)
end

function GroupController:clickShortcutListLayer()
    -- self.view:freshShortcutListLayer(false)
end

function GroupController:clickQuickStart()
    local groupInfo = self.group:getCurGroup()
    if not groupInfo then return end
    local groupId = groupInfo.id     
    self.group:quickStart(groupId)
end

function GroupController:clickFanshui()
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    self.view:freshAdminSettingLayer(false)
    self:setWidgetAction('GVSetScoreController', {self.group,'fanshui'}) 
end

function GroupController:clickRoomLimit()
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    self.view:freshAdminSettingLayer(false)
    self:setWidgetAction('GVSetScoreController', {self.group,'roomlimit'}) 
end

function GroupController:clickShangfen()
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    self.view:freshAdminSettingLayer(false)
    self:setWidgetAction('GVSetScoreController', {self.group,'shangfen'}) 
end

function GroupController:clickZhuanRang()
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    self.view:freshAdminSettingLayer(false)
    self:setWidgetAction('GVSetScoreController', {self.group,'zhuanrang'}) 
end

function GroupController:clickCloseRecord()
    self.view:freshRecordLayer(false)
end

function GroupController:clickCloseRoomInfo()
    self.view:freshOpenRoomInfoLayer(false)
end

function GroupController:clickRoom()
    
end

function GroupController:clickNoticeInfo()
    SoundMng.playEft('btn_click.mp3')
    self.view:freshAdminSettingLayer(false)
    self.view:freshSetNotifyLayer(true) 
    local groupInfo = self.group:getCurGroup()
    local groupId = groupInfo.id     
    local curNotice = self.group:getNotice(groupId)
    self.view:freshNoticeEditBox(curNotice, true)       
end

function GroupController:clickSpread()
    SoundMng.playEft('btn_click.mp3')
    local app = require("app.App"):instance()
    local groupInfo = self.group:getCurGroup()
    self:setWidgetAction('ShareController', groupInfo)    
end

function GroupController:clickMoneyBtn()
    SoundMng.playEft('btn_click.mp3')
    local groupInfo = self.group:getCurGroup()
    local ownerId = groupInfo.ownerInfo.playerId
    local groupId = groupInfo.id
    local myPlayerId = self.group:getPlayerRes("playerId") --自己id
    self.group:adminMsgList(groupId)  
    self:setWidgetAction(
        'GVRoomCardListController', 
        {self.group, (myPlayerId == ownerId)}
    )
end

function GroupController:clickAdvanced()
    SoundMng.playEft('btn_click.mp3')
    local groupInfo = self.group:getCurGroup()
    local ownerId = groupInfo.ownerInfo.playerId
    local groupId = groupInfo.id
    local myPlayerId = self.group:getPlayerRes("playerId") --自己id
    self.group:adminMsgList(groupId)
    self.view:freshAdminSettingLayer(false)
    self:setWidgetAction(
        'GVAdvancedSettingListController', 
        {self.group, (myPlayerId == ownerId)}
    )
end

function GroupController:clickPersonalInfo()
    SoundMng.playEft('btn_click.mp3')
    self.view:freshNormalSettingLayer(false)
    -- self.view:freshPersonalInfoLayer(true)   
    local content = self.group:getPersonalInfo()   
    self.view:freshPersonalEditBox(content ,true)
end

function GroupController:ClickRoomSelect_bisai()
    self.view:freshRoomSelect_type('bisai')
end

function GroupController:ClickRoomSelect_normal()
    self.view:freshRoomSelect_type('normal')
end

function GroupController:clickBack()
    SoundMng.playEft('btn_click.mp3')
    local app = require('app.App'):instance()
    app:delNextSwitchParam("LobbyController")
    self.emitter:emit('back')
    -- app:switch('LobbyController')
end

function GroupController:finalize()
  for i = 1,#self.listener do
    self.listener[i]:dispose()
  end
  if self.schedulerID then
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
    self.schedulerID = nil
  end
end

function GroupController:setWidgetAction(controllerName, ...)
    local ctrl = Controller:load(controllerName, ...)
    self:add(ctrl)

    local app = require("app.App"):instance()
    app.layers.ui:addChild(ctrl.view)
    ctrl.view:setPositionX(0)

    ctrl:on('back', function()
        ctrl:delete()
    end)
    return ctrl
end



return GroupController
