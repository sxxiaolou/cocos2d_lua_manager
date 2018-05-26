-- 同步玩家管理类
-- Author: Jing
-- Date: 2017-08-08
--

local SyncPosManager = class("SyncPosManager", BaseManager)

SyncPosManager.SYNC_ENTER_SCENE = "SyncPosManager.SYNC_ENTER_SCENE"
SyncPosManager.SYNC_EXIT_SCENE 	= "SyncPosManager.SYNC_EXIT_SCENE"
SyncPosManager.SYNC_POS 		= "SyncPosManager.SYNC_POS"
SyncPosManager.SYNC_EMOJI  		= "SyncPosManager.SYNC_EMOJI"
SyncPosManager.SYNC_UPDATE_HEAD = "SyncPosManager.SYNC_UPDATE_HEAD"
SyncPosManager.SYNC_CHALLENG    = "SyncPosManager.SYNC_CHALLENG"
SyncPosManager.SYNC_CLEAN_PLAYER= "SyncPosManager.SYNC_CLEAN_PLAYER"

--玩家同步组队信息变更   
SyncPosManager.SYNC_TEAM_UPDATE = "SyncPosManager.SYNC_TEAM_UPDATE"
SyncPosManager.SYNC_TEAM_MEMBER_UPDATE = "SyncPosManager.SYNC_TEAM_MEMBER_UPDATE"

--增加或刷新队伍
-- message SceneTeamInfo{
-- 	required string teamId = 1;			//队伍id
-- 	required string leaderId = 2;		//队长id
-- 	repeated string members = 3;		//成员id
-- }

function SyncPosManager:ctor()
	self.super.ctor(self)
end

function SyncPosManager:init()
	self.super.init(self)

	self.players = {}
	self.emojis = {}
	self.sceneTeamList = {}   --场景中战队成员关系
	TFDirector:addProto(s2c.SYNC_IN_SCENE, self, self.onSyncInScene)
	TFDirector:addProto(s2c.SYNC_EXIT_SCENE, self, self.onSyncExitScene)
	TFDirector:addProto(s2c.SYNC_IN_SCENE_LIST, self, self.onSyncInSceneList)
	TFDirector:addProto(s2c.SYNC_EMOJI, self, self.onSyncEmoji)
	TFDirector:addProto(s2c.SET_POS_RESULT, self, self.onSyncPos)
	TFDirector:addProto(s2c.SYNC_UPDATE_HEAD, self, self.onSyncUpdateHead)
	TFDirector:addProto(s2c.ENTER_SCENE_SUCCESS, self, self.onEnterSceneSuccess)
	TFDirector:addProto(s2c.SCENE_TEAM_INFO, self, self.onSceneTeamInfo)
	TFDirector:addProto(s2c.SCENE_EXIT_TEAM, self, self.sceneExitTeam)
	TFDirector:addProto(s2c.SCENE_JOIN_TEAM, self, self.sceneJoinTeam)
	TFDirector:addProto(s2c.LEADER_LEAVE_FIGHT_RESULT, self, self.leaderLeaveFight)

	self.onEnterSceneFinish = function(events)
		self.isChangeScene = false
		if self.nextSceneData then
			self:changeScene(self.nextSceneData)
		end
	end
	TFDirector:addMEGlobalListener(AlertManager.ENTER_SCENE_FINISH, self.onEnterSceneFinish)
end

function SyncPosManager:restart()
	self.players = {}
	self.emojis = {}

	self.scene = 0
	self.chapterId = 0
	self:resetSceneTeamList()	
end

function SyncPosManager:resetSceneTeamList()
	if self.sceneTeamList then
		for k,v in pairs(self.sceneTeamList) do
			v.members = nil
			v.path:clear()
			v.path = nil
		end
		self.sceneTeamList = {}
	end
end

--=========================  send ===========================
--请求进入场景 返回0x5006或错误码 给新场景的玩家转发0x5000
--队员发送时忽略 队长发送时转发全队0x5006
function SyncPosManager:sendCheckEnterScene(scene, chapterId, pos)
	pos = pos or 0
	chapterId = chapterId or 0
	-- print("============================================")
	-- print("============================================")
    -- print("==== sendCheckEnterScene:", scene, chapterId, pos)
	self:send(c2s.CHECK_ENTER_SCENE, scene, chapterId, pos)
end

--控制一下设置的频率  
function SyncPosManager:sendSetPos(scene, list)
	if not list then return end
	self:send(c2s.SET_POS, list, scene)
end

function SyncPosManager:SendEmoji(targetId, idx)
	self:send(c2s.SEND_EMOJI, targetId, idx)
end

--队长退出战斗
function SyncPosManager:SendLeaderLeaveFight()
	print("SyncPosManager:SendLeaderLeaveFight")
	self:send(c2s.LEADER_LEAVE_FIGHT, true)
end

--response
function SyncPosManager:onSyncInSceneList(event)
	local data = event.data

	--断线重连清除当前场景中的所有玩家(除自己外)    
	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_CLEAN_PLAYER)
	
	-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
	-- print("== Sync List ================", data)
	self.players = {}
	self:resetSceneTeamList()
	local playerList = data.playerList or {}
	local teamList = data.teamList or {}

	for k,v in pairs(teamList) do
		self:addSceneTeamInfo(v)
	end

	for _,data in pairs(playerList) do
		self:enterScene(data)
	end
end

function SyncPosManager:onSyncInScene(event)
	-- print("SyncPosManager:onSyncInScene", event.data)
	local data = event.data
	local playerInfo = self.players[data.playerId]

	-- self.targetId = data.playerId
	if playerInfo == nil or playerInfo.scene ~= data.scene then
		self:enterScene(data)
	end
end

function SyncPosManager:onSyncExitScene(event)
	local data = event.data
	local playerInfo = self.players[data.playerId]
	if playerInfo == nil then
		return
	end

	if playerInfo.scene == data.scene then
		playerInfo.scene = 0
	end

	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_EXIT_SCENE, playerInfo)
end

function SyncPosManager:onSyncEmoji(event)
	local data = event.data
	if not data then return end
	-- print("========== onSyncEmoji === ", data)
	self.emojis[#self.emojis + 1] = data
	NewChatManager:addEmojiChatMsg(data)
	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_EMOJI, data)
end

function SyncPosManager:onSyncPos(event)
	local data = event.data

	self:syncPos(data)
end

function SyncPosManager:onSyncUpdateHead( event )
	local data = event.data
	local playerInfo = self.players[data.playerId]
	if playerInfo then
		playerInfo.showId = data.showId
		playerInfo.cardId = data.cardId
		playerInfo.godPetView = data.godPetView
		playerInfo.titleId = data.titleId
		playerInfo.guildName = data.guildName
		TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_UPDATE_HEAD, playerInfo)
	end
end

-- 通知进入   
function SyncPosManager:onEnterSceneSuccess(event)
	hideLoading()
	local data = event.data		 
	
	--服务器通知进入 场景和对应的章节     
	self.scene = data.scene  		
	self.chapterId = data.chapterId

	if self.isChangeScene then
		self.nextSceneData = data
		return
	end
	self:changeScene(data)
end

--通知退出战斗
function SyncPosManager:leaderLeaveFight(event)
	-- print("@@@@@@@@@  SyncPosManager:leaderLeaveFight")
	local currentScene = Public:currentScene()
	if currentScene.__cname == "BattleScene" then
		-- print("@@@@@@@@@  FightManager Quit!!!")
		FightManager:popBattleScene()
	end
end

--切换场景     
function SyncPosManager:changeScene(data)
	local scene = data.scene  		
	local chapterId = data.chapterId
	self.isChangeScene = true
	self.nextSceneData = nil
	if MainPlayer:quickInMissionWorld() then
		AlertManager:changeScene(SceneType.MISSION, {chapterId = 1001})
		return
	end

	AlertManager:changeScene(GetSceneTypeBySceneId(scene, chapterId), data) 
end

--增加或刷新队伍  
function SyncPosManager:onSceneTeamInfo(event)
	local data = event.data

	self:addSceneTeamInfo(data)

	-- print("=== SyncPosManager:onSceneTeamInfo")
	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_TEAM_UPDATE, data.teamId)
end

--退队      
function SyncPosManager:sceneExitTeam(event)
	local data = event.data
	local teamId = data.teamId
	local playerId = data.playerId

	local teamInfo = self.sceneTeamList[teamId]
	if teamInfo then
		if playerId == teamInfo.leaderId then
			teamInfo.leaderId = nil
		else
			for k,v in pairs(teamInfo.members) do
				if v == playerId then
					table.remove(teamInfo.members, k)
					break
				end
			end
		end
	end
	if teamInfo and not teamInfo.leaderId and #teamInfo.members == 0 then
		teamInfo.path:clear()
		teamInfo.path = nil
		self.sceneTeamList[teamId] = nil
	end

	print("=== SyncPosManager:sceneExitTeam")
	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_TEAM_MEMBER_UPDATE, teamId)
end

--加入队伍     
function SyncPosManager:sceneJoinTeam(event)
	local data = event.data
	local teamId = data.teamId
	local playerId = data.playerId

	local teamInfo = self.sceneTeamList[teamId]
	if teamInfo and teamInfo.members then
		teamInfo.members[#teamInfo.members + 1] = playerId
	end

	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_TEAM_MEMBER_UPDATE, teamId)
end

function SyncPosManager:addSceneTeamInfo(data)
	local teamId = data.teamId
	data.members = data.members or {}
	data.path = TFArray:new()
	self.sceneTeamList[teamId] = data
	-- print("= addSceneTeamInfo =", self.sceneTeamList)
end

function SyncPosManager:enterScene(data)
	local playerInfo = self.players[data.playerId]

	if playerInfo == nil then
		playerInfo = {playerId = data.playerId}
		self.players[data.playerId] = playerInfo
	end

	playerInfo.showId = data.showId
	playerInfo.cardId = data.cardId
	playerInfo.scene = data.scene
	playerInfo.x = data.x
	playerInfo.y = data.y
	playerInfo.pos = data.pos
	playerInfo.name = data.name 
	playerInfo.quality = data.quality 
	playerInfo.level = data.level
	playerInfo.power = data.power
	playerInfo.vipLevel = data.vipLevel
	playerInfo.retinue = data.retinue
	playerInfo.guildId = data.guildId or ""
	playerInfo.guildName = data.guildName or ""
	playerInfo.godPetView = data.godPetView or ""
	playerInfo.titleId = data.titleId or 0

	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_ENTER_SCENE, playerInfo)
end

function SyncPosManager:syncPos(data)
	-- print("玩家位置更新", data)

	local playerInfo = self.players[data.playerId]
	if playerInfo == nil or playerInfo.scene == 0 then
		return
	end
	-- playerInfo.x = data.x
	-- playerInfo.y = data.y
	playerInfo.posList = data.list
	
	TFDirector:dispatchGlobalEventWith(SyncPosManager.SYNC_POS, playerInfo)
end

function SyncPosManager:getSyncEmoji()
	return self.emojis or {}
end

--玩家是否在组队中    
function SyncPosManager:checkInTeamByPlayerId(playerId)
	if not playerId or not self.sceneTeamList then return false end

	for k,v in pairs(self.sceneTeamList) do
		if v.leaderId == playerId then
			return true
		else
			for m, n in pairs(v.members) do
				if n == playerId then
					return true
				end
			end
		end
	end
	return false
end

function SyncPosManager:getTeamMembersByLeaderId(playerId)
	local teamInfo = self:getTeamInfoByLeaderId(playerId)
	if teamInfo then
		return teamInfo.members
	end
	return nil
end

function SyncPosManager:getTeamInfoByLeaderId(playerId)
	if not playerId or not self.sceneTeamList then return nil end
	
	for k,v in pairs(self.sceneTeamList) do
		if v.leaderId == playerId then
			return v
		end
	end
	return nil
end

--队伍信息、是否为队长      
function SyncPosManager:getTeamInfoByPlayerId(playerId)
	if not playerId or not self.sceneTeamList then return nil end

	for k,v in pairs(self.sceneTeamList) do
		if v.leaderId == playerId then
			return v, true
		end
		for m,n in pairs(v.members) do
			if n == playerId then
				return v, false
			end
		end
	end
	return nil
end

function SyncPosManager:isInTeamByTeamIdAndPlayerId(teamId, playerId)
	local teamInfo = self:getTeamInfoByTeamId(teamId)
	if teamInfo then
		if teamInfo.leaderId == playerId then return true end
		for _, id in pairs(teamInfo.members) do
			if id == playerId then return true end
		end
	end
	return false
end

function SyncPosManager:getSceneTeamList()
	return self.sceneTeamList
end

function SyncPosManager:getTeamInfoByTeamId(teamId)
	return self.sceneTeamList[teamId]
end

function SyncPosManager:inScene(playerId)
	local currentScene = Public:currentScene()
	local sceneId = GetSceneIdBySceneName(currentScene.__cname)
	for k,v in pairs(self.players) do
		if v.playerId == playerId and sceneId and v.scene == sceneId then
			return true
		end
	end
	return false
end

function SyncPosManager:getSceneByPlayerId(playerId)
	return self.players[playerId]
end

--当出现没有玩家自己数据时， 在当前场景中添加玩家对象
function SyncPosManager:appendPlayer(scene, pos)
	local playerId = MainPlayer:getPlayerId()
	local player = self.players[playerId]
	if player then return end

	player = {}
	player.playerId = playerId
	player.showId = MainPlayer:getShowId()
	player.cardId = MainPlayer:getMainRole().id
	player.scene = scene
	player.x = 0
	player.y = 0
	player.pos = pos or 0
	player.name = MainPlayer:getName() 
	player.quality = MainPlayer:getQuality() or QualityType.Red
	player.level = MainPlayer:getLevel()
	player.power = MainPlayer:getPower()
	player.vipLevel = MainPlayer:getVipLevel()
	player.retinue = nil
	player.guildId = GuildManager:getGuildId() or ""
	player.guildName = GuildManager:getGuildName() or ""
	player.godPetView = PetRoleManager:getIsShowGodPetViewData() or ""
	player.titleId = TitleManager:useTitleId() or 0

	self:enterScene(player)
	return player
end

return SyncPosManager:new()