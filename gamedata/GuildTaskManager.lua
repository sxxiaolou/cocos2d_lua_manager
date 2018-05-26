-- Created by ZZTENG on 2017/03/23.
--公会任务管理

local GuildTaskManager = class("GuildTaskManager", BaseManager)
GuildTaskManager.UPDATE_GUILD_TASK_INFO = 'GuildTaskManager.UPDATE_GUILD_TASK_INFO'
GuildTaskManager.UPDATE_GUILD_TASK_LIST = "GuildTaskManager.UPDATE_GUILD_TASK_LIST"
GuildTaskManager.UPDATE_GUILD_SUB_TASK = "GuildTaskManager.UPDATE_GUILD_SUB_TASK"

function GuildTaskManager:ctor()
	self.super.ctor(self)
end

function GuildTaskManager:init()
    self.super.init(self)
    self:reset()
    
    TFDirector:addProto(s2c.GUILD_TASK_INFO, self, self.onGuildTaskInfo)
    TFDirector:addProto(s2c.GUILD_TASK_LIST, self, self.onGuildTaskList)
    TFDirector:addProto(s2c.UPDATE_GUILD_TASK_LIST, self, self.onUpdateGuildTaskList)
    TFDirector:addProto(s2c.GUILD_SUB_TASK_INFO, self, self.onGuildSubTaskInfo)
    TFDirector:addProto(s2c.ACCEPT_GUILD_TASK_SUC, self, self.onAcceptGuildTaskSuc)
    TFDirector:addProto(s2c.COMPLETE_GUILD_TASK_SUC, self, self.onCompleteGuildTaskSuc)
    TFDirector:addProto(s2c.DROP_GUILD_TASK_SUC, self, self.onDropGuildTaskSuc)

    

    -- self.updateTeamTaskListen =  function ( event )
    --     self:updateTeamTask(event)
    -- end
    -- TFDirector:addMEGlobalListener(GuildTaskManager.UPDATE_TEAM_TASK, self.updateTeamTaskListen)
end

function GuildTaskManager:restart()
    -- 清除数据
    self:reset()
end

function GuildTaskManager:reset( ... )
    -- body
    self.guildTaskInfo = {}
    self.guildTaskList = {}
    self.isOpenTask = nil
end

--receive proto
function GuildTaskManager:onGuildTaskInfo( event )
    hideLoading()
    local data = event.data
    print('GuildTaskManager:onGuildTaskInfo:',data)
    for k,v in pairs(data) do
        self.guildTaskInfo[k] = v
    end
    --已领取奖励id，除去分隔符：，
    if self.guildTaskInfo.rewardGetId and type(self.guildTaskInfo.rewardGetId) == 'string' then
        self.guildTaskInfo.rewardGetId = stringToNumberTable(self.guildTaskInfo.rewardGetId,',')
    end

    if self.isOpenTask then
        self.isOpenTask = false
        local layer = AlertManager:getLayerByName('lua.logic.guild.GuildTaskLayer')
        if not layer then 
            self:openGuildTaskLayer()
        end
    end
    local id = self:getCurTaskId()
    TaskMainManager:addMainTaskData(EnumMainTask.GUILD_TASK,id)
    TFDirector:dispatchGlobalEventWith(GuildTaskManager.UPDATE_GUILD_TASK_INFO, 0)
end

function GuildTaskManager:onGuildTaskList( event )
    hideLoading()
    local data = event.data
    print('GuildTaskManager:onGuildTaskList:',data)
    self.guildTaskList = data.info or {}
    table.sort(self.guildTaskList,function ( t1,t2 )
        return t1.index < t2.index
    end)
end

function GuildTaskManager:onUpdateGuildTaskList( event )
    hideLoading()
    local data = event.data
    print('GuildTaskManager:onUpdateGuildTaskList:',data)
    for k,v in pairs(data.info) do
        self:updateTaskInfo(v)
    end
    TFDirector:dispatchGlobalEventWith(GuildTaskManager.UPDATE_GUILD_TASK_LIST, 0)
end

function GuildTaskManager:onGuildSubTaskInfo( event )
    hideLoading()
    local data = event.data
    print('GuildTaskManager:onGuildSubTaskInfo:',data)
    self:updateTaskInfo(data)
    TFDirector:dispatchGlobalEventWith(GuildTaskManager.UPDATE_GUILD_SUB_TASK, 0)
end

function GuildTaskManager:onAcceptGuildTaskSuc( event )
    hideLoading()
    local data = event.data
    print('GuildTaskManager:onAcceptGuildTaskSuc:',data)
end

function GuildTaskManager:onCompleteGuildTaskSuc( event )
    hideLoading()
    local data = event.data
    print('GuildTaskManager:onCompleteGuildTaskSuc:',data)
end

function GuildTaskManager:onDropGuildTaskSuc( event )
    hideLoading()
    local data = event.data
    print('GuildTaskManager:onDropGuildTaskSuc:',data)
end

--send proto
function GuildTaskManager:sendRefreshGuildTaskReq( ... )
    self:sendWithLoading(c2s.REFRESH_GUILD_TASK_REQ,true)
end

function GuildTaskManager:sendRefreshGuildTask( ... )
    self:sendWithLoading(c2s.REFRESH_GUILD_TASK,true)
end

function GuildTaskManager:sendAcceptGuildTask( id )
    self:sendWithLoading(c2s.ACCEPT_GUILD_TASK,id)
end

function GuildTaskManager:sendCompleteGuildTask( id )
    self:sendWithLoading(c2s.COMPLETE_GUILD_TASK,id)
end

function GuildTaskManager:sendDropGuildTask( id )
    self:sendWithLoading(c2s.DROP_GUILD_TASK,id)
end

function GuildTaskManager:sendGetGuildTaskReward( id )
    self:sendWithLoading(c2s.GET_GUILD_TASK_REWARD,id)
end

--util
function GuildTaskManager:updateTaskInfo( taskInfo )
    for k,v in pairs(self.guildTaskList) do
        if v.index == taskInfo.index then
            self.guildTaskList[k] = taskInfo
            return
        end
    end
end
--当前执行任务id(0:没有执行任务)
function GuildTaskManager:getCurTaskId( ... )
    return self.guildTaskInfo.curTaskId or 0
end
--今日任务完成次数
function GuildTaskManager:getCompleteCount( ... )
    return self.guildTaskInfo.completeCount or 0
end
--下次刷新所需元宝
function GuildTaskManager:getRefreshNeedSycee( ... )
    return self.guildTaskInfo.refreshNeedSycee or 0
end
--今日刷新完成次数
function GuildTaskManager:getRefreshOunt( ... )
    return self.guildTaskInfo.refreshCount or 0
end
--得到自己帮会任务活跃度
function GuildTaskManager:getOwnActive( ... )
    return self.guildTaskInfo.ownActive or 0
end

--得到帮会活跃度
function GuildTaskManager:getGuildActive( ... )
    return self.guildTaskInfo.guildActive or 0
end

--查看活跃奖励index，是否达到要求活跃积分能够领取
function GuildTaskManager:canRewardByIndex( index )
    local active_data = GuildTaskActiveData:objectByID(index)
    if not active_data then return end
    local point = active_data.active_point or 0
    local curPoint = self:getGuildActive()
    if point ~= 0 and curPoint >= point then
        return true
    else
        return false
    end
end

--查看帮会活跃奖励id状态,true:已领取奖励
function GuildTaskManager:getRewardStateById( id )
    for k,v in pairs(self.guildTaskInfo.rewardGetId or {}) do
        if v == id then
            return true
        end
    end
    return false
end

function GuildTaskManager:getGuildTaskList( ... )
    return self.guildTaskList
end

--通过任务id得到任务当前进度
function GuildTaskManager:getCurProcessById( id )
    for k,v in pairs(self.guildTaskList) do
        if v.id == id then
            return v.process
        end
    end
    return 0
end

--通过任务id得到任务所需进度
function GuildTaskManager:getNeedProcessById( id )
    for k,v in pairs(self.guildTaskList) do
        if v.id == id then
            return v.need
        end
    end
    return 0
end
--通过任务id，是否该任务完成
function GuildTaskManager:isCompletedById( id )
    if id == 0 then return false end
    local curProcess = self:getCurProcessById(id)
    local need = self:getNeedProcessById(id)
    return curProcess >= need
end

--open layer
function GuildTaskManager:openGuildTaskLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildTaskLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

--red point
--该任务是否处于完成状态
function GuildTaskManager:completeTaskRedPoint( ... )
    local curTaskId = self:getCurTaskId()
    return self:isCompletedById(curTaskId)
end

return GuildTaskManager:new()