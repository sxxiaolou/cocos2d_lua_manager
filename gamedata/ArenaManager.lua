-- 竞技场管理类
-- Author: Jin
-- Date: 2016-09-26
--

local ArenaManager = class("ArenaManager", BaseManager)

ArenaManager.ARENA_PLAYER_LIST     		= "ArenaManager.ARENA_PLAYER_LIST"
ArenaManager.ARENA_HOME_INFO     		= "ArenaManager.ARENA_HOME_INFO"
ArenaManager.ARENA_TOP_RECORD_LIST  	= "ArenaManager.ARENA_TOP_RECORD_LIST"
ArenaManager.ARENA_GET_PLAYER_RECORD	= "ArenaManager.ARENA_GET_PLAYER_RECORD"
ArenaManager.ARENA_REFRESH_SCORE        = 'ArenaManager.ARENA_REFRESH_SCORE'

function ArenaManager:ctor()
	self.super.ctor(self)
	self:reset()
end

function ArenaManager:init()
	self.super.init(self)

	TFDirector:addProto(s2c.ARENA_PLAYER_LIST, self, self.onReceivePlayerList)
	TFDirector:addProto(s2c.ARENA_HOME_INFO, self, self.onReceiveArenaInfo)
	TFDirector:addProto(s2c.ARENA_CHALLENGE_RESULT, self, self.onReceiveChallengeResult)
	TFDirector:addProto(s2c.ARENA_TOP_RECORD_LIST, self, self.onReceiveArenaTopRecordList)
	TFDirector:addProto(s2c.ARENA_GET_PLAYER_RECORD, self, self.onReceiveArenaGetPlayerRecord)
	TFDirector:addProto(s2c.ARENA_SCORE_RES, self, self.onReceiveArenaScoreRes)
	TFDirector:addProto(s2c.ARENA_SCORE_REWARD_RES, self, self.onReceiveArenaScoreRewardRes)
end

function ArenaManager:reset()
	self.opponents = {}
	self.arenaInfo = {}
	self.topRecords = {}
	self.playerRecords = {}
	self.rankData = nil
	self.score = 0
	self.usedScore = {}
	self.openArenaPlayerListLayerState = nil
end

function ArenaManager:restart()
	self:reset()
end

-- protocol
--[[
	oppopent = {
	rank = 1,  	      		  	//排行
	playerId = 2,              	//玩家ID
	playerName = 3,  	      	//玩家昵称
	playerLevel = 4,  	     	//玩家等级
	fightPower = 5,    		  	//战力
	challengeTotalCount = 6,  	//总挑战次数
	challengeWinCount = 7,    	//胜利次数
	vipLevel = 8,  	          	//VIP等级
	prevRank = 9,				//昨日排名
	bestRank = 10,				//最佳排名
	totalScore = 11,			//一共获得多少群豪谱积分
	activeChallenge = 12,		//主动挑战次数
	activeWin=13,				//主动挑战胜利次数
	continuityWin=14,			//当前连胜次数
	maxContinuityWin=15,		//最大连胜次数
	formation = 16,				//阵容 id,id 第9个是宠物
	roleTplId = 17,				//主角模板id
	}
]]
function ArenaManager:onReceivePlayerList(event)
	hideLoading()
	local data = event.data
	if not data.playerList then return end

	print("onReceivePlayerList===", data)

	self:loadOpponentInfos(data.playerList)
    
	if not layer and self.openArenaPlayerListLayerState then
	       self.openArenaPlayerListLayerState = false
		   local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.arena.ArenaPlayerListLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	       AlertManager:show()
	else 
	      TFDirector:dispatchGlobalEventWith(ArenaManager.ARENA_PLAYER_LIST, 1)
	end
end

--[[
	arenaInfo = {
		myRank = 1, 				//当前排名
		fightPower = 2,	 			//战力
		challengeTotalCount = 3, 	//总挑战次数
		challengeWinCount = 4, 		//胜利次数
		bestRank = 5,				//最佳排名
		activeChallenge = 6,		//主动挑战次数
		activeWin=7,				//主动挑战胜利次数
		continuityWin=8,			//当前连胜次数
		maxContinuityWin=9,			//最大连胜次数
	}
]]
function ArenaManager:onReceiveArenaInfo(event)
	hideLoading()
	local data = event.data
	-- print("onReceiveArenaInfo===", data)
	local arenaInfo = self.arenaInfo
	if not arenaInfo.playerId then
		local mainRole = CardRoleManager.mainRole
		arenaInfo.playerId = mainRole.gmId
		arenaInfo.playerName = mainRole.name
		arenaInfo.roleTplId = mainRole.id
	end
	arenaInfo.rank = data.myRank
	arenaInfo.fightPower = data.fightPower
	arenaInfo.challengeTotalCount = data.challengeTotalCount
	arenaInfo.challengeWinCount = data.challengeWinCount
	arenaInfo.prevRank = 0
	arenaInfo.bestRank = data.bestRank
	arenaInfo.activeChallenge = data.activeChallenge
	arenaInfo.activeWin = data.activeWin
	arenaInfo.continuityWin = data.continuityWin
	arenaInfo.maxContinuityWin = data.maxContinuityWin

	TFDirector:dispatchGlobalEventWith(ArenaManager.ARENA_HOME_INFO, 0)
end

function ArenaManager:onReceiveChallengeResult(event)
	hideLoading()
	local data = event.data
	if not data then return end
	self.rankData = data

	-- win = 1; //挑战是否胜利
 -- 	myRank = 2; //当前排名
 -- 	oldRank = 3; 	//旧的排名
	-- sycee = 4;		//获得的元宝数量
end

function ArenaManager:onReceiveArenaTopRecordList(event)
	hideLoading()
	local data = event.data
	if not data.records then return end
	self.topRecords = data.records
	table.sort(self.topRecords, function (r1, r2) return r1.time > r2.time end)

	-- print("onReceiveArenaTopRecordList====", self.topRecords)
	
	TFDirector:dispatchGlobalEventWith(ArenaManager.ARENA_TOP_RECORD_LIST, 0)
end

function ArenaManager:onReceiveArenaGetPlayerRecord(event)
	hideLoading()

	local data = event.data
	 -- print("onReceiveArenaGetPlayerRecord====", data)
	if not data.records then return end
	self.playerRecords = data.records
	table.sort(self.playerRecords, function (r1, r2) return r1.time > r2.time end)

	TFDirector:dispatchGlobalEventWith(ArenaManager.ARENA_GET_PLAYER_RECORD, 0)
end

function ArenaManager:onReceiveArenaScoreRes( event )
	hideLoading()
	-- print('onReceiveArenaScoreRes:',event.data)
	-- local layer = AlertManager:getLayerByName('lua.logic.arena.ArenaRewardLayer')
	local data = event.data
	self.score = data.score or 0
	self.usedScore = data.usedReward or {}
	-- if not layer then
	-- else
	TFDirector:dispatchGlobalEventWith(ArenaManager.ARENA_REFRESH_SCORE, 0)
	-- end
end

function ArenaManager:onReceiveArenaScoreRewardRes( event )
	hideLoading()
	-- print('onReceiveArenaScoreRewardRes:',event.data)
    self:sendArenaScoreReq()
end

function ArenaManager:sendArenaGetPlayerList()
	self:sendWithLoading(c2s.ARENA_GET_PLAYER_LIST, true)
end

function ArenaManager:sendArenaChallengePlayer(playerId)
	self.playerId = playerId
	self:sendWithLoading(c2s.ARENA_CHALLENGE_PLAYER, playerId)
end

function ArenaManager:sendArenaGetArenaInfo()
	self:sendWithLoading(c2s.ARENA_GET_HOME_INFO, true)
end

function ArenaManager:sendArenaTopRecord()
	self:sendWithLoading(c2s.ARENA_TOP_RECORD, true)
end

function ArenaManager:sendArenaGetPlayerRecord()
	self:sendWithLoading(c2s.ARENA_GET_PLAYER_RECORD, true)
end

function ArenaManager:sendArenaGetBattleRecord(reportId)
	-- print(reportId)
	self:sendWithLoading(c2s.ARENA_GET_BATTLE_RECORD, reportId)
end

function ArenaManager:sendArenaScoreReq( ... )
	self:sendWithLoading(c2s.ARENA_SCORE_REQ,0)
end

function ArenaManager:sendArenaScoreRewardReq( score )
	self:sendWithLoading(c2s.ARENA_SCORE_REWARD_REQ,score)
end

-- api
function ArenaManager:openArenaPlayerListLayer()
	-- JIN TODO
	-- if MainPlayer.level < 20 then
	-- 	toastMessage(localizable.equipOutLayer_qunhao)
	-- 	return 
	-- end 

	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.arena.ArenaPlayerListLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function ArenaManager:openArenaReportLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.arena.ArenaFightReport", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function ArenaManager:openArenaSearchLayer( ... )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.arena.ArenaSearchLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function ArenaManager:getOwnerArenaInfo()
	local arenaInfo = self.arenaInfo
	local mainRole = CardRoleManager.mainRole
	arenaInfo.playerLevel = mainRole:getLevel()
	arenaInfo.vipLevel = MainPlayer.vipLevel
	arenaInfo.petId = PetRoleManager.battlePet and PetRoleManager.battlePet.id or 0
	return arenaInfo
end

-- local 
function ArenaManager:loadOpponentInfos(opponents)
	self.opponents = {}
	for i=1,3 do
		local opponent = opponents[i]
		if opponent then
			local formation = stringToNumberTable(opponent.formation, ',')
			local formationLevel = stringToNumberTable(opponent.formationLevel,',')
			local showId = stringToNumberTable(opponent.showId, ",")
			opponent.formation = formation
			opponent.formationLevel = formationLevel
			opponent.showId = showId
			opponent.petId = formation[10]
			formation[10] = nil
			self.opponents[#self.opponents + 1] = opponent
		end
	end

	table.sort(self.opponents, function(o1, o2) return o1.rank < o2.rank end)
end

--card排序通过品质
function ArenaManager:sortCardByQuality( ... )
	local iconListData = {}
	for i,v in ipairs(self.opponents) do
		iconListData[i] = {}
		for j,v in ipairs(self.opponents[i].formation) do
			if v ~= 0 and self.opponents[i].formationLevel[j] ~= 0 then
			   local data = {}
               data.cardId = v
			   data.level = self.opponents[i].formationLevel[j]
			   table.insert(iconListData[i],data)
			end
		end
        local cpm = function(a,b)
		  local roleA = CardData:objectByID(a.cardId)
		  local roleB = CardData:objectByID(b.cardId)
          return roleA.quality > roleB.quality
	    end
	    table.sort(iconListData[i],cpm)
	end
	
	return iconListData
end

function ArenaManager:choseOpponentInfo( index )
	if index <= #self.opponents then
	     return self.opponents[index]
	end
	print('not exist opponent')
end

--pve的阵容formation table,pack newformation
function ArenaManager:formationByPVE( ... )
	local newFormation = {}
	local formation = FormationManager:getFormationByType(EnumFormationType.PVE)
	if type(formation.cells) ~= 'table' then end 
	--formation.cell是0~8
	for i=0,8 do
		if formation.cells[i] == nil then
		    newFormation[i + 1] = 0
		else
			local cardRole = CardRoleManager:getRoleByGmId(formation.cells[i].gmId)
			local pic_id = cardRole.showId or cardRole.pic_id 
			newFormation[i + 1] = pic_id
		end
	end
	return newFormation
end

--积分红点
function ArenaManager:isHaveGradeRedPoint( ... )
	for unitData in  ArenaScoreData:iterator() do
		if self.score >= unitData.score then
			local index = table.indexOf(self.usedScore,tostring(unitData.score))
			if index == -1 then
				return true
			end
		end
	end
	return false
end

function ArenaManager:isHaveRedPoint()
	local is_can = JumpToManager:isCanJump(FunctionManager.ChallengeArena)
	local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.ArenaPoint)	
	if is_can and times:getLeftValue() > 0 or self:isHaveGradeRedPoint() 
	   or ShopManager:isHaveRedPoint(EnumShopType.ArenaShop) then return true end
	return false
end
return ArenaManager:new()