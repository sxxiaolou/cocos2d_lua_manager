--[[
******PVE推图管理类*******

	-- by Tony
	-- 2016/8/11
]]

local BaseManager = require('lua.gamedata.BaseManager')
local MissionManager = class("MissionManager", BaseManager)

MissionManager.UpdateMission 		= "MissionManager.UpdateMission"
MissionManager.UnlockMission 		= "MissionManager.UnlockMission"
MissionManager.UpdateBox     		= "MissionManager.UpdateBox"
MissionManager.UpdateNotDestoryBox 	= "MissionManager.UpdateNotDestoryBox"
MissionManager.UpdateEyeBox 		= "MissionManager.UpdateEyeBox"
MissionManager.QuickPassResult 		= "MissionManager.QuickPassResult"
MissionManager.BattleRecordResult 	= "MissionManager.BattleRecordResult"
MissionManager.NextChapter 			= "MissionManager.NextChapter"
MissionManager.GetReward 			= "MissionManager.GetReward"
MissionManager.WantPerfect			= "MissionManager.WantPerfect"
MissionManager.TeamUpLevel 			= "MissionManager.TeamUpLevel"
MissionManager.MissionChapterJump 	= "MissionManager.MissionChapterJump"
MissionManager.MissionChapterUpdate	= "MissionManager.MissionChapterUpdate"


MissionManager.MissionJumpToScene 	= "MissionManager.MissionJumpToScene"
MissionManager.MissionJumpMain 		= "MissionManager.MissionJumpMain"
MissionManager.MissionJumpWorld		= "MissionManager.MissionJumpWorld"
MissionManager.MissionChapterLayer	= "MissionManager.MissionChapterLayer"
MissionManager.MissionChapterGuid	= "MissionManager.MissionChapterGuid"
MissionManager.ChapterNoOpen 		= "MissionManager.ChapterNoOpen"

-- data struct：
-- chapterInfo = TFMapArray (contains chapter)
-- chapter = {
-- 	id, 
-- 	template,
-- 	missionList = {} (contains mission)
-- 	openBoxList = {1, 2, ..}
-- }
-- mission = {
-- 	id,
-- 	template,
-- 	challengeCount,
-- 	starLevel,
-- 	resetCount,
-- }
function MissionManager:ctor(data)
	self.super.ctor(self)
end

function MissionManager:init()
	self.super.init(self)

	self.chapterInfo = TFMapArray:new()
	self.unlockMission = nil


	self:registerEvents()
end

function MissionManager:restart()
	for chapterInfo in self.chapterInfo:iterator() do
		chapterInfo = nil
	end
	self.chapterInfo:clear()
	self.unlockMission = nil

	self:endOneKey()
end

function MissionManager:registerEvents()
	TFDirector:addProto(s2c.MISSION_LIST, self, self.onMissionListHandle)
	TFDirector:addProto(s2c.MISSION_ITEM, self, self.onMissionItemHandle)
	TFDirector:addProto(s2c.UNLOCK_MISSION, self, self.onUnlockMissionHandle)
	TFDirector:addProto(s2c.CHAPTER_BOX_OPEN, self, self.onChapterBoxOpenHandle)
	TFDirector:addProto(s2c.QUICK_PASS_RESULT, self, self.onQuickPassResultHandle)

	TFDirector:addProto(s2c.RESET_CHALLENGE_COUNT_RESULT, self, self.onResetChallengeCountResultHandle)
	TFDirector:addProto(s2c.CHALLENGE_RECORD_UPDATE, self, self.updateChallengeRecord)
	TFDirector:addProto(s2c.BATTLE_RECORD_RESULT, self, self.onBattleRecordResultHandle)

	TFDirector:addProto(s2c.DAILY_MISSION_LIST, self, self.onDailyMissionListHandle)
	TFDirector:addProto(s2c.DAILY_MISSION_ITEM, self, self.updateDailyMissionHandle)
	TFDirector:addProto(s2c.UNLOCK_DAILY_MISSION, self, self.updateDailyMissionHandle)
	TFDirector:addProto(s2c.CHAPTER_BOX_OPEN_ALL, self, self.onChapterBoxOpenAllHandle)

	TFDirector:addProto(s2c.NOT_DESTORY_BOX_OPEN, self, self.onChapterDestoryBoxHandle)
	TFDirector:addProto(s2c.CHAPTER_EYE_BOX_OPEN, self, self.onChapterEyeBoxHandle)
	TFDirector:addProto(s2c.CHAPTER_NO_OPEN, self, self.onChapterNoOpenHandle)

	self.JumpToSceneHead = function(events) self:onJumpToSceneHead(events) end
	TFDirector:addMEGlobalListener(MissionManager.MissionJumpToScene, self.JumpToSceneHead)
end

function MissionManager:removeEvents()
	TFDirector:removeProto(s2c.MISSION_LIST, self, self.onMissionListHandle)
	TFDirector:removeProto(s2c.MISSION_ITEM, self, self.onMissionItemHandle)
	TFDirector:removeProto(s2c.UNLOCK_MISSION, self, self.onUnlockMissionHandle)
	TFDirector:removeProto(s2c.CHAPTER_BOX_OPEN, self, self.onChapterBoxOpenHandle)
	TFDirector:removeProto(s2c.QUICK_PASS_RESULT, self, self.onQuickPassResultHandle)
	TFDirector:removeProto(s2c.CHALLENGE_RECORD_UPDATE, self, self.updateChallengeRecord)
	TFDirector:removeProto(s2c.CHAPTER_BOX_OPEN_ALL, self, self.onChapterBoxOpenAllHandle)
	TFDirector:removeProto(s2c.BATTLE_RECORD_RESULT, self, self.onBattleRecordResultHandle)


	TFDirector:removeMEGlobalListener(MissionManager.MissionJumpToScene, self.JumpToSceneHead)
    self.JumpToSceneHead = nil
end

function MissionManager:dispose()
	self:removeEvents()
end

function MissionManager:onBattleRecordResultHandle(event)
	hideLoading()
	local data = event.data
	if data == nil then return end

	--print("+@@@@@@@@@@@@", data.records)
	data.records = data.records or {}
	local mission = self:findMission(data.missionId)
	if mission == nil then return end
	for k,record in pairs(data.records) do
		if record.isTop == true then
			mission.topRecord= record
		else
			mission.lowRecord= record
		end
	end

	if data.records and #data.records == 0 then
		toastMessage(localizable.mission_strategy_no)
	else
		local topLayer = nil
		local currentScene = Public:currentScene()
		if currentScene and currentScene.getTopLayer then
			topLayer = currentScene:getTopLayer()
		end
		if topLayer.__cname == "MissionRecordLayer" then
			TFDirector:dispatchGlobalEventWith(MissionManager.BattleRecordResult, nil)
		else
			self:openMissionRecordLayer(mission.id)
		end
	end
end

function MissionManager:onMissionListHandle(event)
	local data = event.data
	 -- print("----onMissionListHandle---", data)

	for _, missionInfo in pairs(data.missionlist) do
		self:updateMission(missionInfo)
	end

	print("=====  box ==", data.openBoxIdList, data.destoryBoxIdList)
	if data.openBoxIdList then
		for _, boxId in pairs(data.openBoxIdList) do
			self:addOpenBoxId(boxId)
		end
	end

	if data.destoryBoxIdList then
		for _,boxId in pairs(data.destoryBoxIdList) do
			self:addDestoryBoxId(boxId)
		end
	end

	if data.eyeBoxIdList then
		for _, boxId in pairs(data.eyeBoxIdList) do
			self:addEyeBoxId(boxId)
		end
	end

	self:updateMainStar()

	local chapterId =  self:currentMissionByType(EnumMissionType.Main).template.chapter
	TaskMainManager:addMainTaskData(EnumMainTask.MAIN_LINE,chapterId)
end

function MissionManager:onDailyMissionListHandle(event)
	local data = event.data or {}

	-- print("onDailyMissionListHandle====", data)

	for _, dailyInfo in pairs(data.missionlist) do
		self:updateDailyMission(dailyInfo)
	end

	--self:sortDailyMission()
	-- print("onDailyMissionListHandle====", chapterList)
end

function MissionManager:updateDailyMissionHandle(event)
	local data = event.data

	-- print("updateDailyMissionHandle====", data)

	self:updateDailyMission(data)

	--self:sortDailyMission()
	-- print("updateDailyMissionHandle====", chapterList)
end

function MissionManager:sortDailyMission()
	local function sortDaily(c1, c2)
		if c1.isLock ~= c2.isLock then
			return c2.isLock and true or false
		end
		if c1.isCheckOpen ~= c2.isCheckOpen then
			return c1.isCheckOpen and true or false
		end
		return false
	end

	local chapterList = self.chapterInfo:objectByID(EnumMissionType.Daily)

	local weekday = tonumber(os.date("%w", os.time()))
	for _, daily in pairs(chapterList) do
		local stageDaily = DailyMissionData:getDailyData(daily.template.id)
		local open_time = stageDaily:getOpenTime()
		local function checkOpen()
			for k,v in pairs(open_time) do
				if v == weekday then
					return true
				end
			end
			return false
		end

		daily.isLock = MainPlayer:getLevel() < daily.template.level_limit
		daily.isCheckOpen = checkOpen()
		daily.week = Utils:getWeekString(open_time)
	end
	table.sort(chapterList, sortDaily)
end

function MissionManager:updateDailyMission(dailyData)
	local chapterList = self.chapterInfo:objectByID(EnumMissionType.Daily)
	if not chapterList then 
		chapterList = {}
		self.chapterInfo:pushbyid(EnumMissionType.Daily, chapterList)
	end

	local mission = {}
	local missionData = MissionData:objectByID(dailyData.missionId)
	mission.id = missionData.chapter
	mission.template = missionData
	mission.challengeCount = dailyData.challengeCount
	mission.starLevel = 0
	mission.resetCount = 0
	mission.type = dailyData.type
	mission.hard = dailyData.hard
	mission.missionId = dailyData.missionId

	local idx = self:getDailyMissionIdx(dailyData.type)
	if idx > 0 then
		chapterList[idx] = mission
	else
		chapterList[#chapterList + 1] = mission
	end
end

function MissionManager:getDailyMissionIdx(type)
	local chapterList = self.chapterInfo:objectByID(EnumMissionType.Daily)
	if chapterList then
		for k, dailyInfo in pairs(chapterList) do
			if dailyInfo.type == type then
				return k
			end
		end
	end
	return 0
end

function MissionManager:getDailyByID(id)
	local chapterList = self.chapterInfo:objectByID(EnumMissionType.Daily)
	if chapterList then
		for k, dailyInfo in pairs(chapterList) do
			if dailyInfo.id == id then
				return dailyInfo
			end
		end
	end
	return nil
end

function MissionManager:getDailyByMissionID(missionId)
	local chapterList = self.chapterInfo:objectByID(EnumMissionType.Daily)
	if chapterList then
		for k, dailyInfo in pairs(chapterList) do
			if dailyInfo.missionId == missionId then
				return dailyInfo
			end
		end
	end
	return nil
end

function MissionManager:onMissionItemHandle(event)
	local missionInfo = event.data

	print("MissionManager:onMissionItemhandle")
	self:updateMission(missionInfo)
	self:updateMainStar()
    --
	local chapterId =  self:currentMissionByType(EnumMissionType.Main).template.chapter
	TaskMainManager:addMainTaskData(EnumMainTask.MAIN_LINE,chapterId)
	
	TFDirector:dispatchGlobalEventWith(MissionManager.UpdateMission, missionInfo.missionId)
end

function MissionManager:onUnlockMissionHandle(event)
	local missionInfo = event.data
	
	self:updateMission(missionInfo)
	local info = self:findMission(missionInfo.missionId)
	self:setUnlockMission(info)
end

function MissionManager:onChapterBoxOpenHandle(event)
	local data = event.data
	
	hideLoading()
	self:addOpenBoxId(data.boxId)

	TFDirector:dispatchGlobalEventWith(MissionManager.UpdateBox, data.boxId)
end

function MissionManager:onChapterDestoryBoxHandle(event)
	local data = event.data

	hideLoading()
	self:addDestoryBoxId(data.boxId)

	TFDirector:dispatchGlobalEventWith(MissionManager.UpdateNotDestoryBox, data.boxId)
end

function MissionManager:onChapterEyeBoxHandle(event)
	hideLoading()

	local data = event.data
	self:addEyeBoxId(data.boxId)
	TFDirector:dispatchGlobalEventWith(MissionManager.UpdateEyeBox, data.boxId)
end

function MissionManager:onChapterBoxOpenAllHandle(event)
	local data = event.data
	hideLoading()

	if data == nil then
		return
	end

	data.boxId = data.boxId or {}
	for _,v in pairs(data.boxId) do
		self:addOpenBoxId(v)
	end
	TFDirector:dispatchGlobalEventWith(MissionManager.UpdateBox, nil)
end

function MissionManager:onQuickPassResultHandle(event)
	local data = event.data
	
	local mission = self:findMission(data.missionId)
	if mission then mission.challengeCount = data.challengeCount end
	TFDirector:dispatchGlobalEventWith(MissionManager.QuickPassResult, data.itemlist[1])
end

function MissionManager:onResetChallengeCountResultHandle(event)
	local data = event.data

	hideLoading()
end

function MissionManager:onChapterNoOpenHandle(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(MissionManager.ChapterNoOpen)
end

-------------------------- send --------------------------------

function MissionManager:sendChallengeLevel(missionId)
	self:sendWithLoading(c2s.CHALLENGE_LEVEL, missionId)
end

function MissionManager:sendChallengeRecord(otherPlayerId, missionId, isTop)
	self:sendWithLoading(c2s.CHALLENGE_RECORD, otherPlayerId, missionId, isTop)
end

function MissionManager:sendOpenTreasureBoxRequest(boxId)
	self:sendWithLoading(c2s.OPEN_TREASURE_BOX_REQUEST, boxId)
end

function MissionManager:sendOpenTreasureBoxAllRequest(chapterId)
	self:sendWithLoading(c2s.OPEN_ALL_TREASURE_BOX_REQUEST, chapterId)
end

function MissionManager:sendResetChallengeCountRequest(missionId)
	self:sendWithLoading(c2s.RESET_CHALLENGE_COUNT_REQUEST, missionId)
end

function MissionManager:sendSingleSweepSection(missionId)
	self:send(c2s.SINGLE_SWEEP_SECTION, missionId)
end

function MissionManager:sendSweepSection(missionId, times)
	self:sendWithLoading(c2s.SWEEP_SECTION, missionId, times)
end

function MissionManager:sendChallengeLevelTest(levelId)
	self:sendWithLoading(c2s.CHALLENGE_LEVEL_BATTLE_TEST, levelId)
end

function MissionManager:sendGuideBattle(index)
	self:sendWithLoading(c2s.REQUEST_GUIDE_BATTLE, index)
end

function MissionManager:sendBattleRecordResult(missionId)
	self:sendWithLoading(c2s.BATTLE_RECORD_REQUEST, missionId)
end

function MissionManager:sendOpenDestoryRequest(boxId)
	self:send(c2s.DESTORY_BOX_REQUEST, boxId)
end

function MissionManager:sendOpenEyeBoxRequest(boxId)
	self:sendWithLoading(c2s.OPEN_EYE_BOX_REQUEST, boxId)
end

-------------------------- end ---------------------------------
function MissionManager:createChapter(chapterId)
	local chapter = {}
	chapter.id = chapterId
	chapter.template = ChapterData:objectByID(chapterId)
	chapter.missionList = {}
	chapter.openBoxList = {}
	chapter.notDestoryBoxList = {}
	chapter.eyeBoxIdList = {}
	return chapter
end

-- 更新关卡信息
function MissionManager:updateMission(missionInfo)
	local missionTemplate = MissionData:objectByID(missionInfo.missionId)
	if not missionTemplate then return end

	local chapterList = self.chapterInfo:objectByID(missionTemplate.type)
	local chapter = self:findChapter(chapterList, missionTemplate.chapter)
	if not chapter then 
		chapter = self:createChapter(missionTemplate.chapter)
		if not chapterList then 
			chapterList = {}
			self.chapterInfo:pushbyid(missionTemplate.type, chapterList)
		end
		chapterList[#chapterList + 1] = chapter
	end

	self:updateMissionWithChapter(chapter, missionInfo)

	table.sort(chapterList, function(c1, c2) return c1.id < c2.id end)
end

function MissionManager:updateMainStar()
	self.mainStar = self:getStarFromMainStage()
end

function MissionManager.updateChallengeRecord(event)

	print("mission " .. event.data.missionId .. " updateChallengeRecord!")
end

function MissionManager:updateMissionWithChapter(chapter, missionInfo)
	local mission = self:findMissionWithChapter(chapter, missionInfo.missionId)
	if not mission then
		mission = {}
		mission.id = missionInfo.missionId
		mission.template = MissionData:objectByID(missionInfo.missionId)
		mission.topRecord = nil
		mission.lowRecord = nil
		chapter.missionList[#chapter.missionList + 1] = mission
	end
	mission.challengeCount = missionInfo.challengeCount
	mission.starLevel = missionInfo.starLevel
	mission.resetCount = missionInfo.resetCount
	mission.totalChallengeCount = missionInfo.totalChallengeCount or 0
	missionInfo.records = missionInfo.records or {}
	for k,record in pairs(missionInfo.records) do
		if record.isTop == true then
			mission.topRecord= record
		else
			mission.lowRecord= record
		end
	end

	table.sort(chapter.missionList, function(m1, m2) return m1.id < m2.id end)
end

-- 获取章节信息
function MissionManager:findChapterWithId(chapterId)
	local chapterTemplate = ChapterData:objectByID(chapterId)
	if not chapterTemplate then return nil end


	return self:findChapterWithType(chapterTemplate.type, chapterId)
end


function MissionManager:findChapterWithType(type, chapterId)
	local chapterList = self.chapterInfo:objectByID(type)
	return self:findChapter(chapterList, chapterId)
end

-- chapterList = {}
function MissionManager:findChapter(chapterList, chapterId)
	if not chapterList then return nil end

	for _, chapter in pairs(chapterList) do
		if chapter.id == chapterId then
			return chapter
		end
	end

	return nil
end

function MissionManager:getChallengeCountByMissionId(missionId)
	local mission = self:findMission(missionId)
	if mission then
		return mission.challengeCount
	end
	return 0
end

function MissionManager:getStarLevelByMissionId(missionId)
	local mission = self:findMission(missionId)
	if mission then
		return mission.starLevel
	end
	return 0
end

function MissionManager:isNeedSendReport(missionId, curPower)
	local mission = self:findMission(missionId)
	if mission then
		return mission.topRecord == nil or 
			mission.lowRecord == nil or 
			mission.topRecord.power < curPower or 
			mission.lowRecord.power > curPower
	end
	return true
end

-- 获取关卡信息
function MissionManager:findMission(missionId)
	local mission = MissionData:objectByID(missionId)
	if not mission then return nil end

	local chapter = self:findChapterWithType(mission.type, mission.chapter)
	return self:findMissionWithChapter(chapter, missionId)
end

function MissionManager:findMissionWithChapter(chapter, missionId)
	if not chapter or not chapter.missionList then return nil end

	for _, mission in pairs(chapter.missionList) do
		if mission.id == missionId then
			return mission
		end
	end
	
	return nil
end

--检测章节是否通关   
function MissionManager:checkChapterPass(chapterId)
	local chapter = ChapterData:objectByID(chapterId)
	if not chapter then
		return false
	end
	local curMission = self:currentMissionByType(chapter.type)
	if not curMission then
		return false
	end
	if curMission.template.chapter > chapterId or (curMission.template.chapter == chapterId and curMission.starLevel ~= 0) then
		return true
	end
	return false
end

-- 添加已开过的宝箱id
function MissionManager:addOpenBoxId(boxId)
	local chapterReward = ChapterRewardData:objectByID(boxId)
	if not chapterReward then return end

	local chapterTemplate = ChapterData:objectByID(chapterReward.chapter)
	if not chapterTemplate then return end
	
	local chapter = self:findChapterWithType(chapterTemplate.type, chapterReward.chapter)
	if not chapter then return end

	chapter.openBoxList[#chapter.openBoxList + 1] = boxId
	
end

-- 添加已开过的宝箱id
function MissionManager:addDestoryBoxId(boxId)
	local chapterReward = ChapterRewardData:objectByID(boxId)
	if not chapterReward then return end

	local chapterTemplate = ChapterData:objectByID(chapterReward.chapter)
	if not chapterTemplate then return end
	
	local chapter = self:findChapterWithType(chapterTemplate.type, chapterReward.chapter)
	if not chapter then return end

	chapter.notDestoryBoxList[#chapter.notDestoryBoxList + 1] = boxId
	
end

function MissionManager:addEyeBoxId(boxId)
	local chapterReward = ChapterRewardData:objectByID(boxId)
	if not chapterReward then return end

	local chapterTemplate = ChapterData:objectByID(chapterReward.chapter)
	if not chapterTemplate then return end
	
	local chapter = self:findChapterWithType(chapterTemplate.type, chapterReward.chapter)
	if not chapter then return end

	chapter.eyeBoxIdList[#chapter.eyeBoxIdList + 1] = boxId
end

--判断章节宝箱状况
function MissionManager:checkBoxReward(chapterId)
	-- 先判断星级宝箱
	local starNum, temp = self:getStarAndPassedMission(chapterId)

	local rewards = ChapterRewardData:getRewardBox(chapterId, EnumMissionBoxRewardType.Star)
	if rewards then
		for k, reward in pairs(rewards) do
			if not self:findOpenBoxId(reward.id, chapterId) then
				if starNum >= reward.value then
					return true
				end
			end
		end
	end
	
	rewards = ChapterRewardData:getRewardBox(chapterId, EnumMissionBoxRewardType.Mission)
	if not rewards then
		return false
	end
	for k,reward in pairs(rewards) do
		if not self:findOpenBoxId(reward.id, chapterId) then
			local mission = self:findMission(reward.value)
			if mission and mission.starLevel > 0 then
				return true
			end
		end
	end

	return false
end

function MissionManager:getLastStarBoxByChapter(chapterId)
	local rewards = ChapterRewardData:getRewardBox(chapterId, EnumMissionBoxRewardType.Star)
	local boxId = nil
	if rewards then
		local maxValue = 0
		for k, reward in pairs(rewards) do
			if reward.value > maxValue then
				maxValue = reward.value
				boxId = reward.id
			end
		end
	end
	return boxId
end

function MissionManager:findOpenBoxId(boxId, chapterId)
	if chapterId == nil then
		local chapterReward = ChapterRewardData:objectByID(boxId)
		if not chapterReward then return false end
		chapterId = chapterReward.chapter
	end

	local chapterTemplate = ChapterData:objectByID(chapterId)
	if not chapterTemplate then return false end
	
	local chapter = self:findChapterWithType(chapterTemplate.type, chapterId)
	if not chapter then return false end
	
	for _,box_id in pairs(chapter.openBoxList) do
		if box_id == boxId then
			return true
		end
	end
	return false
end

function MissionManager:findNotRestoryBoxId(boxId, chapterId)
	if chapterId == nil then
		local chapterReward = ChapterRewardData:objectByID(boxId)
		if not chapterReward then return false end
		chapterId = chapterReward.chapter
	end

	local chapterTemplate = ChapterData:objectByID(chapterId)
	if not chapterTemplate then return false end
	
	local chapter = self:findChapterWithType(chapterTemplate.type, chapterId)
	if not chapter then return false end
	
	for _,box_id in pairs(chapter.notDestoryBoxList) do
		if box_id == boxId then
			return true
		end
	end
	return false
end

function MissionManager:findEyeBoxByBoxId(boxId, chapterId)
	if chapterId == nil then
		local chapterReward = ChapterRewardData:objectByID(boxId)
		if not chapterReward then return false end
		chapterId = chapterReward.chapter
	end
	local chapterTemplate = ChapterData:objectByID(chapterId)
	if not chapterTemplate then return false end
	
	local chapter = self:findChapterWithType(chapterTemplate.type, chapterId)
	if not chapter then return false end
	
	for _,box_id in pairs(chapter.eyeBoxIdList) do
		if box_id == boxId then
			return true
		end
	end
	return false
end

-- 获取主线关卡获得的星数
function MissionManager:getStarFromMainStage()
	local star = 0
	local chapterList = self.chapterInfo:objectByID(EnumMissionType.Main)
	if chapterList == nil then return 0 end
	for _, chapter in pairs(chapterList) do
		for _, mission in pairs(chapter.missionList) do
			star = star + mission.starLevel
		end
	end

	chapterList = self.chapterInfo:objectByID(EnumMissionType.Elite)
	if chapterList then
		for _, chapter in pairs(chapterList) do
			for _, mission in pairs(chapter.missionList) do
				star = star + mission.starLevel
			end
		end
	end
	return star
end

-- 获取章节获得的星数和通过的关卡数
function MissionManager:getStarAndPassedMission(chapterId)
	local chapter = self:findChapterWithId(chapterId)

	local star = 0
	local total = 0
	if chapter then
		for _, mission in pairs(chapter.missionList) do
			star = star + mission.starLevel
			if mission.starLevel > 0 then 
				total = total + 1
			end
		end
	end

	return star, total
end

-- 获取章节的总星数，总章节数
function MissionManager:getChapterStarsAndStagesWithId(chapterId)
	local missionTotal = MissionData:getMaxIndexByChapterId(chapterId)
	return missionTotal*3,missionTotal
end


-- 获取当前章节进度
function MissionManager:currentChapterByType(type)
	local chapterList = self.chapterInfo:objectByID(type)
	if not chapterList then 
		return nil 
	end

	if type == EnumMissionType.Daily then
		return chapterList[1]
	end
	return chapterList[#chapterList]
end

-- 获取当前关卡进度
function MissionManager:currentMissionByType(type)
	local curChapter = self:currentChapterByType(type)
	if not curChapter then return nil end

	return curChapter.missionList[#curChapter.missionList]
end

-- 获取最后通过关卡进度
function MissionManager:currentLastMissionByType(type)
	local curChapter = self:currentChapterByType(type)
	if not curChapter then return nil end

	if #curChapter.missionList == 1 then
		return curChapter.missionList[#curChapter.missionList]
	else
		return curChapter.missionList[#curChapter.missionList - 1]
	end
end

--是否在首章 
function MissionManager:isInFirstChapter()
	local mission = self:currentMissionByType(EnumMissionType.Main)
	if mission.template.chapter == 1001 then
		return true
	end
	return false
end

-- lbx 根据ID获取上一个章节信息
function MissionManager:getPrevChaterId(chapterId)
	if not chapterId then
		return nil
	end
	local thisChapterTemp = ChapterData:objectByID(chapterId)
	if not thisChapterTemp then
		return nil
	end

	if thisChapterTemp.type == EnumMissionType.Daily then
		local dailyData = self:getDailyByID(chapterId)
		local idx = self:getDailyMissionIdx(dailyData.type)
		prevId = idx - 1
		local chapterList = self.chapterInfo:objectByID(EnumMissionType.Daily)
		dailyData = chapterList[prevId]
		if dailyData and dailyData.template.type == EnumMissionType.Daily then
			return dailyData.id
		end
		return nil
	end

	local prevId = chapterId - 1
	local chapterTemp = ChapterData:objectByID(prevId)
	if chapterTemp and chapterTemp.type == thisChapterTemp.type then
		return chapterTemp.id
	end
	return nil
end
function MissionManager:getNextChaterId(chapterId)
	if not chapterId then
		return nil
	end
	local thisChapterTemp = ChapterData:objectByID(chapterId)
	if not thisChapterTemp then
		return nil
	end

	if thisChapterTemp.type == EnumMissionType.Daily then
		local dailyData = self:getDailyByID(chapterId)
		local idx = self:getDailyMissionIdx(dailyData.type)
		prevId = idx + 1
		local chapterList = self.chapterInfo:objectByID(EnumMissionType.Daily)
		dailyData = chapterList[prevId]
		if dailyData and dailyData.template.type == EnumMissionType.Daily then
			return dailyData.id
		end
		return nil
	end

	local nextId = chapterId + 1
	local chapterTemp = ChapterData:objectByID(nextId)
	if chapterTemp and chapterTemp.type == thisChapterTemp.type then
		return chapterTemp.id
	end
	return nil
end


function MissionManager:nextChapter(chapterId)
	local chapterTemplate = ChapterData:objectByID(chapterId)
	if not chapterTemplate then return nil end

	local chapterList = self.chapterInfo:objectByID(chapterTemplate.type)
	if not chapterList then return nil end
	print("chaterListSize"..(#chapterList))
	local curChapter = nil
	for _, chapter in pairs(chapterList) do
		if curChapter then 
			return chapter 
		end

		if chapter.id == chapterId then
			curChapter = chapter
		end
	end

	return nil
end

function MissionManager:prevChapter(chapterId)
	local chapterTemplate = ChapterData:objectByID(chapterId)
	
	if not chapterTemplate then return nil end
	
	local chapterList = self.chapterInfo:objectByID(chapterTemplate.type)
	if not chapterList then return nil end
	
	local prevChapter = nil
	for _, chapter in pairs(chapterList) do
		if chapter.id == chapterId then
			if prevChapter then
				print("chapterId="..chapterId.."prevIdis:"..prevChapter.id)
			end
			return prevChapter
		end
		prevChapter = chapter
	end

	return nil
end

function MissionManager:getCountByMissionId(missionId)
	local curMission = self:currentMissionByType(EnumMissionType.Main)
	local targetMission = MissionData:objectByID(missionId)
	if curMission == nil or targetMission == nil then return 0 end
	if missionId < curMission.template.id then return 0 end

	local count = 0
	if curMission.template.chapter == targetMission.chapter then
		count = targetMission.index - curMission.template.index + 1
	else
		local maxIndex = MissionData:getMaxIndexByChapterId(curMission.template.chapter)
		count = maxIndex - curMission.template.index + 1
	end
	for i=curMission.template.chapter + 1 ,targetMission.chapter do
		maxIndex = MissionData:getMaxIndexByChapterId(i)
		if i ~= targetMission.chapter then
			count = count + maxIndex
		else
			count = count + targetMission.index
		end
	end
	return count
end

function MissionManager:getChapterCount()
	local curMission = self:currentMissionByType(EnumMissionType.Main)
	local maxIndex = MissionData:getMaxIndexByChapterId(curMission.template.chapter)
	local count = maxIndex - curMission.template.index + 1
	return count, curMission.template.chapter
end

function MissionManager:CheckHaveReward(chapterId)
	
	local rewards = ChapterRewardData:getRewardBox(chapterId, EnumMissionBoxRewardType.Star)
	local star = self:getStarAndPassedMission(chapterId)
	if star > 0 then
		for k, reward in pairs(rewards) do
			if not self:findOpenBoxId(reward.id, chapterId) then
				if star >= reward.value then
					return true
				end
			end
		end
	end

	rewards = ChapterRewardData:getRewardBox(chapterId, EnumMissionBoxRewardType.Mission)
	for k,reward in pairs(rewards) do
		if not self:findOpenBoxId(reward.id, chapterId) then
			local mission = self:findMission(reward.value)
			if mission and mission.starLevel > 0 then
				return true
			end
		end
	end
	return false
end

function MissionManager:getMissionFullName(missionId)
	local template = MissionData:objectByID(missionId)
	local chapter = ChapterData:objectByID(template.chapter)
	if chapter and template then
		return chapter.name .. template.npc_name
	end
	return ""
end

function MissionManager:getPassIdByChapterId(chapterId, pass)
	local chapterData = ChapterData:objectByID(chapterId)
	local chapterPosData = ChapterPosData:objectByID(pass and chapterData.unlock or chapterData.lock)
	local pathId = chapterPosData:getBirthPos()
	return pathId
end

--当前章节是否是异色之瞳默认开启章节          
function MissionManager:checkMissionInChapter(chapterId)
	local mission = self:currentMissionByType(1)
	if not mission then return end

	local curCId = mission.template.chapter
	local qty = ConstantData:getValue("Eye.Special.Chapter.Qty")
	for i=1, qty do
		local cId = ConstantData:getValue("Eye.Special.Chapter." .. i)
		if cId == chapterId and curCId == cId then
			return true
		end
	end
	return false
end

--=======================================  红点系统 =================

function MissionManager:isHaveBox()
	if self:isHaveBoxMain() then return true end
	if self:isHaveBoxElite() then return true end
	return false
end

function MissionManager:isHaveBoxMain()
	return self:isHaveBoxByType(EnumMissionType.Main)
end

function MissionManager:isHaveBoxElite()
	return self:isHaveBoxByType(EnumMissionType.Elite)
end

function MissionManager:isHaveBoxByType(type)
	local chapter = self:currentChapterByType(type)
	if chapter == nil then return false end

	local chapter_list = ChapterData:getChapterIdByType(type) or {}
	local chapterId = chapter.id
	for i=1, #chapter_list do
		local chapter_id = chapter_list[i].id
		if chapter_id <= chapterId and self:CheckHaveReward(chapter_id) then
			return true
		end
	end
	return false
end

--===================================================================

-- function MissionManager:createMission(data)
-- 	if data == nil then
-- 		return
-- 	end
function MissionManager:getUnlockMission()
	return self.unlockMission
end

function MissionManager:setUnlockMission(mission)
	self.unlockMission = mission
end

function MissionManager:openChapterLayer()
	-- local chapterLayer = require("lua.logic.mission.ChapterLayer"):new()
 --    AlertManager:addLayer(chapterLayer, AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
 --    AlertManager:show()
end

function MissionManager:showCurrentChapterMissionLayer(type)
	type = type or EnumMissionType.Main
 	local curCharpter = self:currentChapterByType(type)
	local missionLayer = require("lua.logic.mission.MissionLayer"):new()
	missionLayer:loadData(curCharpter.id)
	AlertManager:addLayer(missionLayer)
	AlertManager:show()
end

function MissionManager:showMissionLayer(chapterId, customId)
	chapterId = chapterId or 1001
	customId = customId or nil
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionLayer")
    layer:loadData(chapterId, customId)
    AlertManager:show()
end

function MissionManager:openMissionDayLayer()
	-- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionDayLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	-- AlertManager:show()
end

function MissionManager:openMissionReceiveLayer(chapterId)
	local detailLayer = require("lua.logic.mission.MissionReceiveLayer"):new()
	detailLayer:loadData(chapterId)
    AlertManager:addLayer(detailLayer, AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    AlertManager:show()
end

function MissionManager:openMissionDetailLayer(mission, materialId, num)
	local level_limit = mission and mission.template.level_limit or 0
	if level_limit > MainPlayer:getLevel() then
		toastMessage(stringUtils.format(localizable.mission_level_limit, level_limit))
		return
	end

	local detailLayer = require("lua.logic.mission.MissionDetailLayer"):new()
	detailLayer:loadData(mission, materialId, num)
    AlertManager:addLayer(detailLayer, AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

function MissionManager:openMissionHaveLayer(chapterId)
	local haveLayer = require("lua.logic.mission.MissionHaveLayer"):new()
	haveLayer:loadData(chapterId)
	AlertManager:addLayer(haveLayer, AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    AlertManager:show()
end

function MissionManager:showMissionPassLayerByMissionId(missionId, num, vitality)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionPassLayer")
    layer:loadData(missionId, num, vitality)
    AlertManager:show()
end

function MissionManager:showMissionPassLayer(passList, vitality, reset)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionPassLayer")
    layer:loadPassData(passList, vitality, reset)
    AlertManager:show()
end

function MissionManager:openChapterAndCurMissionLayer(type)
	local mission = self:currentMissionByType(type)
	if mission and mission.template.chapter then
		-- self:openChapterLayer()
		self:showMissionLayer(mission.template.chapter)
		self:openMissionDetailLayer(mission)
	end
end

function MissionManager:openMissionRecordLayer(missionId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionRecordLayer", AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData(missionId)
    AlertManager:show()
end

function MissionManager:openTeamUpLevelLayer(data)	
	local layer = AlertManager:getLayerByName("lua.logic.mission.MissionTeamUpLayer")
	if layer then
		layer:loadData(data)
	else
		local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionTeamUpLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
	    layer:loadData(data)
	    AlertManager:show()
	end
end

function MissionManager:openMainMissionLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.MainMissionLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_NONE)
    AlertManager:show()
end

function MissionManager:openMissionWorldLayer()
	CommonManager:requestEnterInScene(EnumSceneType.BigWorld)
end

function MissionManager:openMissionChapterLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionChapterLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_NONE)
    AlertManager:show()
end


-------------------------------------  一键托管 ----------------------------------------------------

MissionManager.OneKeyEnter = "MissionManager.OneKeyEnter"
MissionManager.OneKeyBegin = "MissionManager.OneKeyBegin"
MissionManager.OneKeyEnd = "MissionManager.OneKeyEnd"
MissionManager.OneKeyClean = "MissionManager.OneKeyClean"

function MissionManager:isOneKey()
	return self.oneKeyType ~= nil
end

function MissionManager:beginOneKey(type)
	if PlayerGuideManager:isPlayGuide() then
		PlayerGuideManager:reset()
	end

	local function callFunction(_, cb_state)
		-- 处理屏幕唤醒
		-- TFDeviceInfo:acquirePowerLock()
		-- Public:setKeepScreenOn(true)

		self.oneKeyType = type
		self.oneKeyState = cb_state
		self:registerOneKeyEvents()
		self:createOneKeyLayer()
		
		self:addOneKeyLayer()
		MovieManager:resetMovie()
		TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyBegin)
    end

	self.oneKeyLayer = nil
    CardRoleManager:showRoleVitalityLayer(callFunction)
end

function MissionManager:endOneKey()
	print("=== MissionManager:endOneKey() -==============")
	-- 取消唤醒
    -- TFDeviceInfo:releasePowerLock()
	-- if self.oneKeyType then	Public:setKeepScreenOn(false) end

	self.oneKeyType = nil
	self.oneKeyState = nil
	self:removeOneKeyEvents()
	self:removeOneKeyLayer()

	TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyClean)
end

function MissionManager:registerOneKeyEvents()
	self.oneKeyEnterListener = function(events)
		if self and self.addOneKeyLayer then
			self:addOneKeyLayer(events.data[1])
		end
	end
	TFDirector:addMEGlobalListener(MissionManager.OneKeyEnter, self.oneKeyEnterListener)

	self.oneKeyEndListener = function(events)
		if self and self.endOneKey then
			self:endOneKey()
		end
	end
	TFDirector:addMEGlobalListener(MissionManager.OneKeyEnd, self.oneKeyEndListener)
end

function MissionManager:removeOneKeyEvents()
	TFDirector:removeMEGlobalListener(MissionManager.OneKeyEnter, self.oneKeyEnterListener)
	self.oneKeyEnterListener = nil

	TFDirector:removeMEGlobalListener(MissionManager.OneKeyEnd, self.oneKeyEndListener)
	self.oneKeyEndListener = nil
end

function MissionManager:createOneKeyLayer()
	if self.oneKeyLayer == nil then
		local oneKeyLayer = require("lua.logic.mission.MissionTGLayer"):new()
		oneKeyLayer:retain()
		oneKeyLayer:setName("MissionTGLayer")
		self.oneKeyLayer = oneKeyLayer
	end
end

function MissionManager:addOneKeyLayer(layer)
	if self.oneKeyLayer == nil then return end
	if PlayerGuideManager:isPlayGuide() then
		self:endOneKey()
		return
	end
	local topLayer = layer or self:getTopLayer()
	if topLayer == nil then return end
	
	if self.oneKeyLayer.InLayer ~= topLayer then
		self.oneKeyLayer:removeFromParent()

		self.oneKeyLayer:setZOrder(99999)
        topLayer:addChild(self.oneKeyLayer)
        self.oneKeyLayer.InLayer = topLayer
        self.oneKeyLayer:loadData(topLayer)
	end
end

function MissionManager:removeOneKeyLayer()
	if self.oneKeyLayer == nil then return end

	self.oneKeyLayer:dispose()
	self.oneKeyLayer:release()
	if self.oneKeyLayer and not tolua.isnull(self.oneKeyLayer) and self.oneKeyLayer:getParent() then
		print("================= removeOneKeyLayer ")
		self.oneKeyLayer:removeFromParent()
	end
	self.oneKeyLayer = nil
end

function MissionManager:useVitality(missionId)
	local mission = MissionData:objectByID(missionId)
	local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.Vitality)
	if mission and times and times:getLeftValue() < mission.consume then
		local tplId = ConstantData:getResID("Strengh.Pill.itemid")
		local item = BagManager:getGoodsByTypeAndTplId(3, tplId)
		if item and item.num > 0 then
		    self.consumeVitality = true
		    BagManager:sendUseItem(item.id, tplId, 1)
		    return true
		end
	end
	return false
end

function MissionManager:getTopLayer()
	local currentScene = Public:currentScene()
	if currentScene and currentScene.getTopLayer then
		return currentScene:getTopLayer()
	end
	return nil
end

function MissionManager:getMissionsweep()
	return self.is_sweep
end

function MissionManager:setMissionsweep(is_bool)
	self.is_sweep = is_bool
end
---

function MissionManager:onJumpToSceneHead(events)
	local chapterId = events.data[1]
	if not chapterId then return end
	local chapterdata =  ChapterData:objectByID(chapterId)
	local chapterType = EnumMissionType.Main
	if chapterdata.type == 2 then
		chapterType = EnumMissionType.Elite
	end

	local currentScene = Public:currentScene()
	local cityMission = CitadelData:getPanelNameByChapterId(chapterId, chapterType)
	if cityMission then
		if currentScene.__cname ~= "HomeScene" then
			CommonManager:requestEnterInScene(EnumSceneType.Home)
		end
		-- TFDirector:dispatchGlobalEventWith(MissionManager.MissionJumpMain, cityMission)	
	else
		if currentScene.__cname ~= "BigWorldScene" then
			CommonManager:requestEnterInScene(EnumSceneType.BigWorld)
		end
		-- TFDirector:dispatchGlobalEventWith(MissionManager.MissionJumpWorld, chapterId)
	end
end

function MissionManager:setReceivBigWorldRoleType(types)
	self.roleType = types
end

function MissionManager:getReceivBigWorldRoleType()
	return self.roleType or 1
end

function MissionManager:judgeElteIsOpen()
	local config 	= FunctionOpenConfigure:objectByID(602)
	if not config then return false end

	local mission = self:findMission(config.mission_id)
	if mission and mission.starLevel > 0 then
		return true
	end
	return false
end
----------------data{bool,chapterId}
function MissionManager:setIsJumpChapter( data )
	self.is_jump = {}
	self.is_jump.is_jump = data.bool or false
	self.is_jump.chapterId = data.chapterId 
end

function MissionManager:getIsJumpChapter()
	return self.is_jump or {}
end

function MissionManager:inBigWorld(chapterId)
	local chapterdata = ChapterData:objectByID(chapterId)
	if not chapterdata then return false end

	local name = CitadelData:getPanelNameByChapterId(chapterId, chapterdata.type)
	return name == nil
end

function MissionManager:setLocalChapterId(chapterId)
	self.localChapterId = chapterId
end

function MissionManager:getLocalChapterId()
	return self.localChapterId or 0
end

return MissionManager:new()