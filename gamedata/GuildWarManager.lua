-- Created by ZZTENG on 2018/04/16.
--公会战管理

local GuildWarManager = class("GuildWarManager", BaseManager)
GuildWarManager.UPDATE_GUILD_WAR_OPEN = 'GuildWarManager.UPDATE_GUILD_WAR_OPEN'
GuildWarManager.UPDATE_GUILD_WAR_STATUS = "GuildWarManager.UPDATE_GUILD_WAR_STATUS"
GuildWarManager.UPDATE_GUILD_WAR_FORMATION = "GuildWarManager.UPDATE_GUILD_WAR_FORMATION"
GuildWarManager.UPDATE_GUILD_WAR_RECORD = "GuildWarManager.UPDATE_GUILD_WAR_RECORD"
GuildWarManager.UPDATE_GUILD_WAR_REWARD = 'GuildWarManager.UPDATE_GUILD_WAR_REWARD'

function GuildWarManager:ctor()
	self.super.ctor(self)
end

function GuildWarManager:init()
    self.super.init(self)
    self:reset()
    
    TFDirector:addProto(s2c.GUILD_BATTLE_OPEN, self, self.onGuildBattleOpen)
    TFDirector:addProto(s2c.GUILD_BATTLE_STATUS_INFO, self, self.onGuildBattleStatusInfo)
    TFDirector:addProto(s2c.GUILD_ALL_ARRAY_INFO, self, self.onGuildAllArrayInfo)
    TFDirector:addProto(s2c.UPDATE_GUILD_ARRAY_INFO, self, self.onUpdateGuildArrayInfo)
    TFDirector:addProto(s2c.GUILD_BATTLE_REVIEW_INFO, self, self.onGuildBattleReviewInfo)
    TFDirector:addProto(s2c.GUILD_BATTLE_REWARD, self, self.onGuildBattleReward)
    TFDirector:addProto(s2c.GUILD_BATTLE_HONOR_LIST, self, self.onGuildBattleHonorList)
    TFDirector:addProto(s2c.GUILD_BATTLE_ARR_LIST, self, self.onGuildBattleArrList)
    TFDirector:addProto(s2c.JOIN_GUILD_BATTLE_SUC, self, self.onJoinGuildBattleSuc)
    TFDirector:addProto(s2c.CANCEL_GUILD_BATTLE_SUC, self, self.onCancelGuildBattleSuc)

    

    -- self.updateTeamTaskListen =  function ( event )
    --     self:updateTeamTask(event)
    -- end
    -- TFDirector:addMEGlobalListener(GuildWarManager.UPDATE_TEAM_TASK, self.updateTeamTaskListen)
end

function GuildWarManager:restart()
    -- 清除数据
    self:reset()
end

function GuildWarManager:reset( ... )
    -- body
    self.isOpen = false
    self.statusInfo = {}           --帮会战信息状态列表
    self.formationInfo = {}        --帮会战队伍信息
    self.reviewInfo = {}           --帮会战回顾信息
    self.rewardInfo = {}           --帮会奖励信息
    self.honorInfo = {}            --帮会荣誉榜信息
    self.recordInfo = {}           --帮会阵列记录信息
    self.joinState = 0             --报名状态
    self.openLayerList = {}
    -- self:endRemainTimer()
end

--receive proto
function GuildWarManager:onGuildBattleOpen( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onGuildBattleOpen:',data)
    self.isOpen = data.isOpen
    TFDirector:dispatchGlobalEventWith(GuildWarManager.UPDATE_GUILD_WAR_OPEN, 0)
end

function GuildWarManager:onGuildBattleStatusInfo( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onGuildBattleStatusInfo:',data)
    self.statusInfo = data or {}
    self.statusInfo.primaryInfo.activityRank = self.statusInfo.primaryInfo.activityRank  or {}
    -- self:startRemainTimer()
    if self.openLayerList['mainLayer'] then
        self.openLayerList['mainLayer'] = false
        GuildWarManager:openGuildWarMainLayer()
    end
    TFDirector:dispatchGlobalEventWith(GuildWarManager.UPDATE_GUILD_WAR_STATUS, 0)
end

function GuildWarManager:onGuildAllArrayInfo( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onGuildAllArrayInfo:',data)
    self.formationInfo = data.GuildAllArrary or {}
    for i,v in ipairs(self.formationInfo) do
        self.formationInfo[i].GuildArrary = self.formationInfo[i].GuildArrary or {}
    end
    self.joinState = data.status
    if self.openLayerList['formation'] then
        self.openLayerList['formation'] = false
        GuildWarManager:openGuildWarFormaionLayer()
    end
end

function GuildWarManager:onUpdateGuildArrayInfo( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onUpdateGuildArrayInfo:',data)
    local index_list = stringToNumberTable(data.index,'_')
    local formation_list = data.GuildArrary
    local function getFormationByIndex( index )
        for k,v in pairs(formation_list) do
            if v.index == index then
                return v
            end
        end
        return nil
    end
    for i,v in ipairs(index_list) do
        local formationInfo = getFormationByIndex(v)
        if formationInfo == nil then  break end
        self:updateFormationInfoByIndex(v,formationInfo)
    end
    TFDirector:dispatchGlobalEventWith(GuildWarManager.UPDATE_GUILD_WAR_FORMATION, 0)
end

function GuildWarManager:onGuildBattleReviewInfo( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onGuildBattleReviewInfo:',data)
    self.reviewInfo = data or {}
    self.reviewInfo.primaryInfo.activityRank = self.reviewInfo.primaryInfo.activityRank or {}
    if self.reviewInfo.seasonTime and self.reviewInfo.seasonTime == '' then
        toastMessage(localizable.guild_war_no_review)
        return
    end
    if self.openLayerList['review'] then
        self.openLayerList['review'] = false
        GuildWarManager:openGuildWarReviewLayer()
    end
end

function GuildWarManager:onGuildBattleReward( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onGuildBattleReward:',data)
    data.rewardArr = stringToNumberTable(data.rewardArr,'_')
    self.rewardInfo = data or {}
    if self.openLayerList['reward'] then
        self.openLayerList['reward'] = false
        GuildWarManager:openGuildWarRewardLayer()
    end
    TFDirector:dispatchGlobalEventWith(GuildWarManager.UPDATE_GUILD_WAR_REWARD, 0)
end

function GuildWarManager:onGuildBattleHonorList( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onGuildBattleHonorList:',data)
    self.honorInfo = data.guildHonorList or {}
    if #self.honorInfo == 0 then
        toastMessage(localizable.guild_war_no_honor)
        return
    end
    if self.openLayerList['honor'] then
        self.openLayerList['honor'] = false
        GuildWarManager:openGuildWarHonorLayer()
    end
end

function GuildWarManager:onGuildBattleArrList( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onGuildBattleArrList:',data)
    self.recordInfo = data or {}
    self.recordInfo.guildBattleList = self.recordInfo.guildBattleList or {}
    for i,v in ipairs(self.recordInfo.guildBattleList) do
        self.recordInfo.guildBattleList[i].guildBPlayer = self.recordInfo.guildBattleList[i].guildBPlayer or {}
    end
    self.recordInfo.recordInfoList = self.recordInfo.recordInfoList or {}
    if self.openLayerList['record'] then
        self.openLayerList['record'] = false
        self:openGuildWarRecordLayer()
    end
    TFDirector:dispatchGlobalEventWith(GuildWarManager.UPDATE_GUILD_WAR_RECORD, 0)
end

function GuildWarManager:onJoinGuildBattleSuc( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onJoinGuildBattleSuc:',data)
    local index = data.index or 0
    if index == 1 or index == 2 or index == 3 then
        self.joinState = 2
        toastMessage(localizable.guild_war_join_sucess)
        local layer = AlertManager:getLayerByName('lua.logic.guild.GuildWarChooseLayer')
        if layer then
            AlertManager:closeLayer(layer)
        end
    end
end

function GuildWarManager:onCancelGuildBattleSuc( event )
    hideLoading()
    local data = event.data
    print('GuildWarManager:onCancelGuildBattleSuc:',data)
    self.joinState = 1
end

--send proto
function GuildWarManager:sendGetGuildBattleStatusInfo( ... )
    self:sendWithLoading(c2s.GET_GUILD_BATTLE_STATUS_INFO,true)
end

function GuildWarManager:sendGetGuildArrayInfo( ... )
    self:sendWithLoading(c2s.GET_GUILD_ARRAY_INFO,true)
end

function GuildWarManager:sendUpdateGuildArrayInfo( status,newIndex,newPos,oldIndex,oldPos,newPlayerId,oldPlayerId )
    self:sendWithLoading(c2s.UPDATE_GUILD_ARRAY_INFO,status,newIndex,newPos,oldIndex,oldPos,newPlayerId,oldPlayerId)
end

function GuildWarManager:sendGetGuildBattleReviewInfo( ... )
    self:sendWithLoading(c2s.GET_GUILD_BATTLE_REVIEW_INFO,true)
end

function GuildWarManager:sendGetGuildBattleReward( status )
    self:sendWithLoading(c2s.GET_GUILD_BATTLE_REWARD,status)
end

function GuildWarManager:sendGetGuildBattleHonorList( ... )
    self:sendWithLoading(c2s.GET_GUILD_BATTLE_HONOR_LIST,true)
end

function GuildWarManager:sendGuildBattleArrList( seasonTime,guildArr,index )
    self:sendWithLoading(c2s.GUILD_BATTLE_ARR_LIST,seasonTime,guildArr,index)
end

function GuildWarManager:sendJoinGuildBattle( index )
    self:sendWithLoading(c2s.JOIN_GUILD_BATTLE,index)
end

function GuildWarManager:sendWatchGuildBattle( reportId )
    self:sendWithLoading(c2s.WATCH_GUILD_BATTLE,reportId)
end

function GuildWarManager:sendCancelGuildBattle( index,playerId )
    self:sendWithLoading(c2s.CANCEL_GUILD_BATTLE,index,playerId)
end

--util func
--帮会战能否开启
function GuildWarManager:canGuildWarOpen( ... )
    return self.isOpen
end
--得到阵列状态信息
function GuildWarManager:getStatusInfo( ... )
    return self.statusInfo
end
--自己帮会是否在帮会战中
function GuildWarManager:isInGuildWar( ... )
    if GuildManager:hasGuild() then
        local info = self.statusInfo.primaryInfo.myActivityRank
        if not info then return false end
        if info.rank >= 1 and info.rank <= 8 then
            return true
        end
    end
    return false
end
--自己帮会是否存活
function GuildWarManager:isLiveInGuildWar( ... )
    if self:isInGuildWar() then
        local info = self.statusInfo.primaryInfo.myActivityRank
        return info.isWin == 1 or info.isWin == 0
    end
    return false
end
--得到某个阵列的阵容信息
function GuildWarManager:getGuildWarFormationInfoByIndex( index )
    for k,info in pairs(self.formationInfo) do
        if info.index == index then
            return info
        end    
    end
    return nil
end

--开始剩余时间倒计时
function GuildWarManager:startRemainTimer( ... )
    local time = self.statusInfo.times or 0
    if time <= 0 or self.remain_time_id then return end 
    local  function callback( ... )
        print('kkkkkkkkkkkkkkkkkkkkk')
        self:endRemainTimer()
        self:sendGetGuildBattleStatusInfo()
    end
    self.remain_time_id = TFDirector:addTimer(time,1,callback)
end
--结束剩余时间倒计时
function GuildWarManager:endRemainTimer( ... )
    if not self.remain_time_id then return end
    TFDirector:removeTimer(self.remain_time_id)
    self.remain_time_id = nil
end

--更新某个阵列阵容信息
function GuildWarManager:updateFormationInfoByIndex( index,formationInfo )
    for k,v in pairs(self.formationInfo) do
        if v.index == index then
            self.formationInfo[k] = formationInfo
            self.formationInfo[k].GuildArrary = self.formationInfo[k].GuildArrary or {}
        end
    end
end

--得到某个阵列战力
function GuildWarManager:getPowerByIndex( index )
    local power = 0
    local formation = self:getGuildWarFormationInfoByIndex(index)
    if formation == nil then return power end
    for k,v in pairs(formation.GuildArrary or {}) do
        power = power + v.power
    end
    return power
end
--某个阵列人员是否已满
function GuildWarManager:isPlayersOverByIndex( ... )
    local formation = self:getGuildWarFormationInfoByIndex(index)
    if formation == nil then return true end
    if #formation.GuildArrary < 10 then
        return false
    end
end
--阵列人员人数
function GuildWarManager:countInFormation( ... )
    local count = 0
    for i=1,3 do
        local formation = self:getGuildWarFormationInfoByIndex(i)
        if not formation then break end
        count = count + #formation.GuildArrary
    end
    return count
end
--得到报名状态，0：表示报名结束，1：未报名，2：已报名
function GuildWarManager:getJoinState( ... )
    return self.joinState
end
--奖励信息
function GuildWarManager:getRewardInfo( ... )
    return self.rewardInfo
end
--荣誉榜信息
function GuildWarManager:getHonorInfo( ... )
    return self.honorInfo
end
--得到上阵中自己的信息
function GuildWarManager:getOwnInfoInFormation( ... )
    for _,info in pairs(self.formationInfo) do
        for _,playerInfo in pairs(info.GuildArrary or {}) do
            if playerInfo.id == MainPlayer:getPlayerId() then
                return playerInfo
            end
        end
    end
    return nil
end
--记录信息
function GuildWarManager:getRecordInfo( ... )
    return self.recordInfo
end
--回顾信息
function GuildWarManager:getReviewInfo( ... )
    return self.reviewInfo
end

--赛季格式转化
--[[
   2018-05-10~2018-05-17   ————>>>  2018.05.10至2018.05.17
]]
function GuildWarManager:seasonTransform( season )
    local tb = stringToTable(season,'~')
    if tb[1] and tb[2] then
        local head = string.gsub(tb[1],'-','.')
        local tail = string.gsub( tb[2],'-','.')
        return head .. localizable.guild_war_to .. tail
    end
    return ''
end

--open layer
function GuildWarManager:openGuildWarFormaionLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildWarFormationLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildWarManager:openGuildWarChooseLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildWarChooseLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildWarManager:openGuildWarRewardLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildWarRewardLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildWarManager:openGuildWarHonorLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildWarHonorLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildWarManager:openGuildWarMainLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildWarMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildWarManager:openGuildWarReviewLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildWarReviewLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildWarManager:openGuildWarRecordLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildWarRecordLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

--red point

return GuildWarManager:new()