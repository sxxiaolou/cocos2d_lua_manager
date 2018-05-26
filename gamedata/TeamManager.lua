-- Created by ZZTENG on 2017/10/18.
--队伍管理

local TeamManager = class("TeamManager", BaseManager)
TeamManager.UPDATE_TEAM_INFO = "TeamManager.UPDATE_TEAM_INFO"
TeamManager.UPDATE_TEAM_LIST_INFO = "TeamManager.UPDATE_TEAM_LIST_INFO"
TeamManager.UPDATE_TEAM_FRIEND_LIST_STATUS = "TeamManager.UPDATE_TEAM_FRIEND_LIST_STATUS"
--任务状态更新
TeamManager.CREATE_TEAM = "TeamManager.CREATE_TEAM"
TeamManager.LEAVE_TEAM = "TeamManager.LEAVE_TEAM"
--酒馆状态更新
--[[1: 创建队伍
    2: 队伍更新
    3： 离开队伍
]]
TeamManager.UPDATE_TAVERN_TEAM = 'TeamManager.UPDATE_TAVERN_TEAM'
TeamManager.UPDATE_MESSAGE_STATUS = 'TeamManager.UPDATE_MESSAGE_STATUS'
TeamManager.UPDATE_INVITE_INFO = 'TeamManager.UPDATE_INVITE_INFO'

function TeamManager:ctor()
	self.super.ctor(self)
end

function TeamManager:init()
    self.super.init(self)
    
    self.haveTeam = false
    self.isPublic = false
    self.notShowFull = false
    self.GetOnlineFriendTeamType=nil
    self.GetOnlineFriendTeamid=0
    self.teamInfo = {}
    self.inviteTeamInfo = {}
    self.changePower = 0
    self.teamFriendList = {}
    self.teammateInfo = {}
    TFDirector:addProto(s2c.TEAM_PLAYER_INFO, self, self.onReceiveTeamPlayerInfo)
    TFDirector:addProto(s2c.TEAM_INFO, self, self.onReceiveTeamInfo)
    TFDirector:addProto(s2c.TEAMMATE_INFO, self, self.onReceiveTeammateInfo)
    TFDirector:addProto(s2c.INVITE_TEAM, self, self.onReceiveInviteTeam)
    TFDirector:addProto(s2c.EXITE_TEAM_RESULT, self, self.onReceiveExiteTeam)
    TFDirector:addProto(s2c.WILL_TEAM_LEADER, self, self.onReceiveWillTeamLeader)
    TFDirector:addProto(s2c.BECOME_TEAM_LEADER, self, self.onReceiveBecomeTeamLeader)
    TFDirector:addProto(s2c.DISMISS_TEAM, self, self.onReceiveDismissTeam)
    TFDirector:addProto(s2c.TEAM_TABLE_LIST, self, self.onReceiveTeamList)
    TFDirector:addProto(s2c.NOTIFY_ADD_TEAM, self, self.onReceiveNotifyAddTeam)
    TFDirector:addProto(s2c.TEAM_FRIEND_LIST_STATUS, self, self.onReceiveTeamFriendListStatus)
    TFDirector:addProto(s2c.REFRESH_FORMATION_RESULT, self, self.onReceiveRefreshFormationResult)
    TFDirector:addProto(s2c.NOTIFY_TEAM_LEADER_FORMATION, self, self.onReceiveNotifyTeamLeaderFormation) 
    
    --在断线重连时,需要处理下数据
    self.reconnectCallback = function ()  self:onNetReconnect()   end
    TFDirector:addMEGlobalListener(CommonManager.TRY_RECONNECT_NET, self.reconnectCallback)
end

function TeamManager:onNetReconnect()
    print("TeamManager:onNetReconnect")
    self:restart()
end

function TeamManager:restart()
    -- 清除数据
    self.haveTeam = false
    self.isPublic = true
    self.notShowFull = false
    self.inviteTeamInfo = {}
    self.changePower = 0
    self.teamInfo = {}
    self.teamListInfo = {}
    self.teamFriendList = {}
    self.teammateInfo = {}
end

function TeamManager:setIsPublic( isPublic )
    self.isPulic = isPublic
end

function TeamManager:getIsPublic( ... )
    return self.isPublic
end

function TeamManager:setNotShowFull( notShowFull )
    self.notShowFull = notShowFull
end

function TeamManager:getNotShowFull( ... )
    return self.notShowFull
end

function TeamManager:ishaveTeam( ... )
    return self.haveTeam
end

function TeamManager:getTeamTarget( ... )
    if self.teamInfo then
        return self.teamInfo.target
    end
    print('getTeamTarget:team is not exit')
    return nil
end

--创建队伍，自动弹出队伍界面
function TeamManager:setIsAutoOpenTavern( isOpen )
    self.isAutoOpenTavern = isOpen
end

function TeamManager:getIsAutoOpenTavern( ... )
    return self.isAutoOpenTavern
end

--是否有这个队伍类型
function TeamManager:haveTeamByTarget( target )
    local haveTeam = false
    if self:ishaveTeam() then
        if self.teamInfo and self.teamInfo.target and self.teamInfo.target == target then
            haveTeam = true
        end
    end
    return haveTeam
end

function TeamManager:isTeamLeader( ... )
   local isTeamLeader = false
   if self:ishaveTeam() and self.teamInfo.leaderId then
        if MainPlayer:getPlayerId() == self.teamInfo.leaderId then
              isTeamLeader = true
        end
   end
   return isTeamLeader
end

function TeamManager:isTeammate( ... )
    local isTeammate = true
    if self:ishaveTeam() and self.teamInfo.leaderId then
       if MainPlayer:getPlayerId() == self.teamInfo.leaderId then
              isTeammate = false
       end
    else
       isTeammate = false
    end
    return isTeammate
end

function TeamManager:getChangePower( ... )
    return self.changePower
end

function TeamManager:setTeamInfo( info )
    self.teamInfo = info
end

function TeamManager:getTeamInfo( ... )
    return self.teamInfo
end

function TeamManager:setTeammateInfo( info )
    self.teammateInfo = info
end

function TeamManager:getTeammateInfo( ... )
    if self.teammateInfo == nil then local teammateInfo = {} return teammateInfo end
    return self.teammateInfo
end

function TeamManager:setTeamListInfo( info )
    self.teamListInfo = info
end
function TeamManager:getTeamListInfo( ... )
    return self.teamListInfo
end

function TeamManager:getTeamListInfo( ... )
    return self.teamListInfo
end

function TeamManager:setTeamFriendListInfo( info )
    self.teamFriendList = info
end

function TeamManager:getTeamFriendListInfo( ... )
    return self.teamFriendList
end

function TeamManager:getInviteTeamInfo( ... )
    return self.inviteTeamInfo
end

function TeamManager:clearAllInviteTeamInfo( ... )
    self.inviteTeamInfo = {}
end

function TeamManager:removeOneInviteTeamInfo( pos )
    table.remove(self.inviteTeamInfo,pos)
end

function TeamManager:leaveTeam( ... )
    local teamId = self.teamInfo.id
    self.haveTeam = false
    self.teamInfo = {}
    self.teammateInfo = {}
    TFDirector:dispatchGlobalEventWith(TeamManager.LEAVE_TEAM, 0)
    -- print('999999999999999999999999999999',teamId)
    if teamId then
       TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TAVERN_TEAM,teamId,3)
    end
end

function TeamManager:getMateInfoById( id )
    print('getMateInfoById',id,self.teammateInfo)
    if not id then return nil end
    local info
    for k,v in pairs(self.teammateInfo) do
        if v.id == id then
            info = v
            break
        end
    end
    return info
end

--teammateInfo表第一条信息是否队长，不是队长旗帜隐藏，是队长显示
function TeamManager:showFlag( ... )
    local show = false
    if not self.haveTeam or not self.teamInfo or not self.teammateInfo then return show end
    if self.teamInfo.leaderId and self.teammateInfo[1] then
        if self.teamInfo.leaderId == self.teammateInfo[1].id then
            show = true
        end
    end 
    return show
end

function TeamManager:coverTeammateInfo( info )
    for i,v in ipairs(self.teammateInfo) do
        if v.id == info.id then
            for k,v in pairs(info) do
                self.teammateInfo[i][k] = v
            end
            return
        end
    end
end

function TeamManager:onReceiveTeamPlayerInfo( event )
    hideLoading()
    local data = event.data
    print('teamPlayerInfo:',data)
    self:coverTeammateInfo(data)
    TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_INFO, 0)
end

function TeamManager:onReceiveTeamInfo( event )
    hideLoading()
    local data = event.data
    print('teamInfo:',data)
    self.teamInfo.id = data.id
    if self.teamInfo.id then self.haveTeam = true end
    local isUpdate = self.teamInfo.target and data.target and (self.teamInfo.target ~= data.target)
    --队长启用谁的阵容（提示）
    if self.teamInfo.formation and self.teamInfo.formation ~= data.formation then
       local mateInfo = self:getMateInfoById(data.formation)
       if mateInfo ~= nil then 
            toastMessage(stringUtils.format(localizable.team_teamleader_use_formation, mateInfo.name))
       end
    end
    for k,v in pairs(data) do
        self.teamInfo[k] = v
    end
    if not (data.isPublic == nil) then
       self.teamInfo.isPublic = data.isPublic
       self.isPublic = data.isPublic
    end
    --更改队伍target，给任务推消息
    if isUpdate then
        print(' to message TeamManager.CREATE_TEAM')
        TFDirector:dispatchGlobalEventWith(TeamManager.CREATE_TEAM, self.teamInfo.target)
    end
    TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_INFO, self.teamInfo.target)
end

function TeamManager:onReceiveTeammateInfo( event )
    hideLoading()
    local data = event.data
    print('teammateInfo:',data)
    local oldTeammateInfo = self.teammateInfo
    local layer = AlertManager:getLayerByName('lua.logic.team.MyTeamLayer')
    self.teammateInfo = data.infos or {}
    if not layer and self.isOpenMyTeamLayer then
        self.isOpenMyTeamLayer = false
        self:openMyTeamLayer()
    else
        TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_INFO, 0)
    end
    --创建队伍或者加入队伍，给任务推消息
    if type(oldTeammateInfo) == 'table' and #oldTeammateInfo == 0 then
       --创建队伍，给酒馆推消息
       if #self.teammateInfo == 1 then
          print(' to message TeamManager.CREATE_TEAM')
          TFDirector:dispatchGlobalEventWith(TeamManager.CREATE_TEAM, self.teamInfo.target)
          TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TAVERN_TEAM,self.teamInfo.id,1)
       else
           --加入队伍，不用抛消息
        --    TFDirector:dispatchGlobalEventWith(TeamManager.CREATE_TEAM, self.teamInfo.target)
           RoundTaskManager:setTaskStatus(EnumRoundTaskStatus.HAVE_TEAM)
       end
       --加入队伍，不用抛消息
    --    TFDirector:dispatchGlobalEventWith(TeamManager.CREATE_TEAM, self.teamInfo.target)
    else 
       TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_INFO, 0)
    end
    --队伍多人少人，给酒馆信息推送
    TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TAVERN_TEAM,self.teamInfo.id,2)
    
end

function TeamManager:onReceiveInviteTeam( event )
    hideLoading()
    local data = event.data
    print("--------------------------------------------------",data)
    --邀请通知,通知信息调用
    --过滤同个玩家，同个队伍多次邀请
    local findData = table.findOne(self.inviteTeamInfo,function ( info )
        if info.id == data.id and info.teamPlayerInfo.id == data.teamPlayerInfo.id then
             return true
        end
        return false
    end)
    if findData == nil then table.insert(self.inviteTeamInfo,data) end

    --积分赛3v3
    if data.target == 4 then 
        MessageManager:pushTypeInMessageLayer(EnumMessagePushType.TeamScore3v3Match)
    elseif data.target == 1 then
        MessageManager:pushTypeInMessageLayer(EnumMessagePushType.TeamKillDevilInvite)
    end
    

    TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_MESSAGE_STATUS, 0) 
    TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_INVITE_INFO, 0)
end

function TeamManager:onReceiveExiteTeam( event )
    hideLoading()
    local data = event.data
    print('exiteTeam:',data)
    local playerId = event.data.playerId
    if MainPlayer:getPlayerId() == playerId then
        self:leaveTeam()
    else
        --提示谁退出队伍
        local info = self:getMateInfoById(playerId)
        local math = function ( v )
            return v.id == playerId
        end
        if info and info.name then
            toastMessage(stringUtils.format(localizable.team_exite_team, info.name))
        end
        table.removeOne(self.teammateInfo,math)
    end

    TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_INFO, 0)
end

function TeamManager:onReceiveWillTeamLeader( event )
    hideLoading()
    local data = event.data
    print('willTeamLeader:',data)
    --争取当队长界面
    local confirmFunc = function ( leader )
        print('wwwwwwwwwwwwwwwwwwww',leader)
        self:sendIsTeamLeader( self.teamInfo.id, leader)
        AlertManager:close(AlertManager.TWEEN_1)
    end
    local closeFunc = function ( ... )
        self:sendIsTeamLeader( self.teamInfo.id, false)
        AlertManager:close(AlertManager.TWEEN_1)
    end
    local content = localizable.team_leader_content
    CommonManager:openNewConfirmLayer(content, localizable.team_leader_cancel, localizable.team_leader_become, confirmFunc, false,closeFunc)
end

function TeamManager:onReceiveBecomeTeamLeader( event )
    hideLoading()
    local data = event.data
    local id = data.playerId
    print('becomeTeamLeader:',data)
    --谁成为队长提示
    if id then self.teamInfo.leaderId = id end 
    local info = self:getMateInfoById(id)
    toastMessage(stringUtils.format(localizable.team_become_team_leader, info.name))
end

function TeamManager:onReceiveDismissTeam( event )
    hideLoading()
    local data = event.data
    print('dismissTeam:',data)
    --提示队伍解散
    self:leaveTeam()
    toastMessage(localizable.team_dismiss_team)
end

function TeamManager:onReceiveTeamList( event )
    hideLoading()
    local data = event.data
    print('teamList:',data)
    local layer = AlertManager:getLayerByName('lua.logic.team.TeamMainLayer')
	self.teamListInfo = data.info or {}
	if not layer then
		self:openTeamMainLayer()
	else
		TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_LIST_INFO, 0)
	end
end

function TeamManager:onReceiveNotifyAddTeam( event )
    local data = event.data
    print('notifyAddTeam:',data)
    local info = self:getMateInfoById(data.playerId)
    local content = stringUtils.format(localizable.team_myteam_enter, info.name)
    toastMessage(content)
end

function TeamManager:onReceiveTeamFriendListStatus( event )
   hideLoading()
   local data = event.data
   print("----------------------------------------> self.GetOnlineFriendTeamType==", self.GetOnlineFriendTeamType)
   if  self.GetOnlineFriendTeamType=="ScoreMatch3V3" then
        local layer = AlertManager:getLayerByName('lua.logic.ScoreMatch.ScoreMatchInvitationLayer')
        self.teamFriendList.friends = data.friends or {}
        self.teamFriendList.guildMembers = data.guildMembers or {}
        if not layer then
            self:openScoreMatchInvitationLayer()
        else
            TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_FRIEND_LIST_STATUS, 0)
        end
   else
        print('teamFriendListStatus:',data)
        local layer = AlertManager:getLayerByName('lua.logic.team.InvitationLayer')
        self.teamFriendList.friends = data.friends or {}
        self.teamFriendList.guildMembers = data.guildMembers or {}
        if not layer then
            self:openInvitationLayer()
        else
            TFDirector:dispatchGlobalEventWith(TeamManager.UPDATE_TEAM_FRIEND_LIST_STATUS, 0)
        end
   end
end

function TeamManager:onReceiveRefreshFormationResult( event )
    --成功刷新自己的阵容为组队阵容（提示）
    hideLoading()
    print('refreshFormationResult:',event.data)
    if event.data.success then
       toastMessage(localizable.team_refresh_team_formation)
    end
end

function TeamManager:onReceiveNotifyTeamLeaderFormation( event )
    hideLoading()
    local data = event.data
    print('NotifyTeamLeaderFormation:',data)
    self.changePower = event.data.changePower
    self:openChangeFormationPowerLayer()
end

function TeamManager:openTeamMainLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.team.TeamMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function TeamManager:openMyTeamLayer( ... )
   	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.team.MyTeamLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function TeamManager:openInvitationLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.team.InvitationLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end
function TeamManager:openScoreMatchInvitationLayer( )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchInvitationLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end


function TeamManager:openTeamSettingLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.team.TeamSettingLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function TeamManager:openChangeFormationPowerLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ChangeFormationPowerLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

--------------------------send--------------------------
--创建队伍
function TeamManager:sendCreateTeam()
    local content = RoundtaskDefaultNameData:objectByID(1).talk
    self.isOpenMyTeamLayer = true
	self:sendWithLoading(c2s.CREATE_TEAM, EnumTeamTask.KILL_DEVIL,content,true)
end

function TeamManager:sendModifyTeamTarget( id,targetId )
    self:sendWithLoading(c2s.MODIFY_TEAM_TARGET,id,targetId)
end

function TeamManager:sendModifyTeamDesc( id,content )
    self:sendWithLoading(c2s.MODIFY_TEAM_DESC,id,content)
end

function TeamManager:sendTeamShout( ... )
    if not ServerSwitchManager:isTeamShoutOpen() then 
        toastMessage(localizable.team_shout_not_open)
        return
    end
    self:sendWithLoading(c2s.TEAM_SHOUT,true)
end

function TeamManager:sendTeamInfoReq( ... )
    self.isOpenMyTeamLayer = true
    self:sendWithLoading(c2s.TEAM_INFO_REQ,true)
end

function TeamManager:sendModifyTeamPublicState( id,isPublic )
    self:sendWithLoading(c2s.MODIFY_TEAM_PUBLIC_STATE,id,isPublic)
end

function TeamManager:sendModifyTeamFormation( id,playerId )
    self:sendWithLoading(c2s.MODIFY_TEAM_FORMATION,id,playerId)
end

function TeamManager:sendShareTeamFormation( id,playerId,isShare )
    self:sendWithLoading(c2s.SHARE_TEAM_FORMATION,id,playerId,isShare)
end

function TeamManager:sendUseTeamFormation( id,playerId )
    self:sendWithLoading(c2s.USE_TEAM_FORMATION,id,playerId)
end

function TeamManager:sendInviteTeammate( id,playerIds )
    self:send(c2s.INVITE_TEAMMATE,id,playerIds)
end

function TeamManager:sendAcceptTeam( id )
    self:send(c2s.ACCEPT_TEAM,id)
end

function TeamManager:sendJoinTeam( id )
    self.isOpenMyTeamLayer = true
    self:sendWithLoading(c2s.JOIN_TEAM,id)
end

function TeamManager:sendExitTeam( id )
    self:send(c2s.EXIT_TEAM,id)
end

function TeamManager:sendIsTeamLeader( id,leader )
    if id == nil or leader == nil then return end
    self:send(c2s.IS_TEAM_LEADER,id,leader)
end

function TeamManager:sendRefreshTeamList( id,page,noShowFull )
    self:sendWithLoading(c2s.REFRESH_TEAM_LIST,id,page,noShowFull)
end

function TeamManager:sendRefreshFormation( ... )
   self:sendWithLoading(c2s.REFRESH_FORMATION,true)
end

function TeamManager:sendGetOnlineFriendInfo( type ,teamid)
    self.GetOnlineFriendTeamType=type
    self.GetOnlineFriendTeamid=teamid
     self:sendWithLoading(c2s.GET_ONLINE_FRIEND_INFO,false)
end

return TeamManager:new()