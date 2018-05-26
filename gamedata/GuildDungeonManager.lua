--
-- 公会幻境管理类
--
local GuildDungeonManager = class("GuildDungeonManager", BaseManager)

--更新幻境信息
GuildDungeonManager.UPDATE_DUNGEON_RESULT = "GuildDungeonManager.UPDATE_DUNGEON_RESULT"
--更新幻境副本信息
GuildDungeonManager.UPDATE_DUNGEON_INFO = "GuildDungeonManager.UPDATE_DUNGEON_INFO"
--更新排行信息
GuildDungeonManager.UPDATE_RANK_INFO = "GuildDungeonManager.UPDATE_RANK_INFO"
--更新复活CD信息
GuildDungeonManager.UPDATE_REVIVE_INFO = "GuildDungeonManager.UPDATE_REVIVE_INFO"

function GuildDungeonManager:ctor()
	self.super.ctor(self)
end

function GuildDungeonManager:init()
	self.super.init(self)
	
	self:restart()
	
	--幻境开启的信息
	TFDirector:addProto(s2c.GUILD_OPEN_DUNGEON_RESULT, self, self.onOpenDungeonResult)
	--幻境副本信息
	TFDirector:addProto(s2c.GUILD_DUNGEON_BOSS_LIST, self, self.onDungeonInfo)
	--妖气排行信息
	TFDirector:addProto(s2c.RANKING_LIST_GUILD_DUNGEON_PESONAL, self, self.onDungeonRankInfo)
	--复活CD信息
	TFDirector:addProto(s2c.GUILD_REVIVE_INFO, self, self.onReviveInfo)
	--战斗boss结果信息
	TFDirector:addProto(s2c.GUILD_DUNGEON_BATTLE_RESULT, self, self.onBattleResult)
end

function GuildDungeonManager:restart()
	self.dungeonResult = nil
	self.dungeonInfo = nil
	self.dungeonRankInfo = nil
	self.reviveInfo = nil
	
	self.lastScene = nil
end

--打开幻境界面
function GuildDungeonManager:openGuildDungeonLayer()
	local isServerOpen = ServerSwitchManager:isGuildCopyOpen()
	if isServerOpen then
		local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildDungeonLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
		layer:loadData()
		AlertManager:show()
	else
		toastMessage(localizable.commom_no_open)
	end
end    

--开启幻境
function GuildDungeonManager:sendOpenDungeonReq(dungeonId)
	self:sendWithLoading(c2s.GUILD_OPEN_DUNGEON, dungeonId)
end

--进入幻境
function GuildDungeonManager:sendEnterDungeonReq(openDungeonId)
	local currentScene = Public:currentScene()
	self.lastScene = GetSceneIdBySceneName(currentScene.__cname)
	
	local data = GuildDungeonData:objectAt(openDungeonId)

	if data then
		local scene = data.scene_id
		local chapterId = data.chapter

		SyncPosManager:sendCheckEnterScene(scene, chapterId)
	end
end 

--排行信息请求
function GuildDungeonManager:sendQueryRankingInfo(type, startIndex, length)
	self:sendWithLoading(c2s.QUERY_RANKING_BASE_INFO, type, startIndex, length)
end	

--战斗请求
function GuildDungeonManager:sendGuildBattleReq(stageId)
	self:sendWithLoading(c2s.GUILD_BATTLE_REQ, stageId)
end

--复活
function GuildDungeonManager:sendGuildReviveReq()
	self:sendWithLoading(c2s.GUILD_REVIVE, "")
end

--离开幻境
function GuildDungeonManager:sendExitDungeonReq()
	if self.lastScene then
		CommonManager:requestEnterInScene(self.lastScene)
	else
		CommonManager:requestEnterInScene(EnumSceneType.Guild)
	end	
end

function GuildDungeonManager:onOpenDungeonResult(event)
	print("onOpenDungeonResult data:", event.data)

	hideLoading()
	
	self.dungeonResult = event.data

	if GuildManager:hasGuild() then
		GuildManager:updateAssetValue(event.data.guildMoney)
	end

	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_RED_POINT, 0)
	TFDirector:dispatchGlobalEventWith(GuildDungeonManager.UPDATE_DUNGEON_RESULT, 0)
end

function GuildDungeonManager:onDungeonInfo(event)
	print("onDungeonInfo data:", event.data)

	hideLoading()
	
	self.dungeonInfo = event.data
	
	TFDirector:dispatchGlobalEventWith(GuildDungeonManager.UPDATE_DUNGEON_INFO, 0)
end

function GuildDungeonManager:onDungeonRankInfo(event)
	print("onDungeonRankInfo data:", event.data)

	self.dungeonRankInfo = event.data

	TFDirector:dispatchGlobalEventWith(GuildDungeonManager.UPDATE_RANK_INFO, 0)
end

function GuildDungeonManager:onReviveInfo(event)
	print("onReviveInfo data:", event.data)

	hideLoading()
	
	self.reviveInfo = event.data
	self.reviveInfo.refreshTime = self.reviveInfo.waitSecond + MainPlayer:getNowtime()
	
	TFDirector:dispatchGlobalEventWith(GuildDungeonManager.UPDATE_REVIVE_INFO, 0)
end

function GuildDungeonManager:onBattleResult(event)
	print("onBattleResult data:", event.data)

	self.battleResult = event.data
end

--幻境开启信息(openType 0:未开启 1:开启 2:完成)
function GuildDungeonManager:getDungeonResult()
	return self.dungeonResult
end 

function GuildDungeonManager:getDungeonInfo()
	return self.dungeonInfo
end

function GuildDungeonManager:getDungeonRankInfo()
	return self.dungeonRankInfo
end

function GuildDungeonManager:getBattleResult()
	return self.battleResult
end

--当前幻境阶段信息
function GuildDungeonManager:getDungeonBossInfo(dungeon_id, evilGuild)
	local dungeonIdList = GuildDungeonBossData:getDungeonByDungeonId(dungeon_id)
	
	local dungeonBossInfo = dungeonIdList[#dungeonIdList]
	
	for k, v in pairs(dungeonIdList) do
		if self.dungeonInfo and self.dungeonInfo.boss then
			if tonumber(v.required_evil) >= evilGuild then
				dungeonBossInfo = v
				break
			end
		else
			if tonumber(v.required_evil) > evilGuild then
				dungeonBossInfo = v
				break
			end		
		end
	end
	
	--当前阶段拥有与出现boss需要的妖气值
	if dungeonBossInfo.phase == 1 then
		dungeonBossInfo.haveEvil = evilGuild
		dungeonBossInfo.needEvil = dungeonBossInfo.required_evil
	else
		local index = dungeonBossInfo.phase - 1
		
		dungeonBossInfo.haveEvil = evilGuild - dungeonIdList[index].required_evil
		dungeonBossInfo.needEvil = dungeonBossInfo.required_evil - dungeonIdList[index].required_evil
	end
	
	return dungeonBossInfo
end 

--幻境倒计时
function GuildDungeonManager:getDungeonTimeString()
	local nowTime = MainPlayer:getNowtime()
	local openTime = self.dungeonResult.openTime or 0
	local dungeonTime = ConstantData:getValue("Guild.Dungeon.Duration")

	local refreshTime = dungeonTime -(nowTime - openTime / 1000) 
	
	if refreshTime <= 0 then
		return "00:00:00"
	end
	
	return Utils:timeFormatHM(refreshTime)
end 

--复活倒计时
function GuildDungeonManager:getDungeonReviveTime()
	local nowTime = MainPlayer:getNowtime()
	local refreshTime = self.reviveInfo.refreshTime

	local waitSecond = refreshTime - nowTime
	
	if waitSecond <= 0 then
		waitSecond = 0
	end
	
	return waitSecond
end 

--帮派资金
function GuildDungeonManager:getGuildMoney()
	local guildInfo = GuildManager:getGuildInfo()
	
	if guildInfo and guildInfo.money then
		return tonumber(guildInfo.money)
	end
	
	return 0
end

-----------------------帮会幻境红点-----------------------
function GuildDungeonManager:isHaveRedPoint()
	if self.dungeonResult and self.dungeonResult.openType == 1 then
		return true
	end
	
	return false
end 	

return GuildDungeonManager:new() 