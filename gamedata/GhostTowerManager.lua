--
-- 鬼神之塔管理类
-- Author: Jin
-- Date: 2016-10-13
--
local BaseManager = require('lua.gamedata.BaseManager')
local GhostTowerManager = class("GhostTowerManager", BaseManager)

GhostTowerManager.RefreshSweepLog		= "GhostTowerManager.RefreshSweepLog"
GhostTowerManager.RefreshAttribLayer	= "GhostTowerManager.RefreshAttribLayer"	--属性界面刷新
GhostTowerManager.RefreshFrendIcon		= "GhostTowerManager.RefreshFrendIcon" 	 	--关卡好友ICON刷新
GhostTowerManager.SweepStageCount		= "GhostTowerManager.SweepStageCount" 		--
GhostTowerManager.GetRewardBox			= "GhostTowerManager.GetRewardBox" 			--鬼神之塔领取宝箱
GhostTowerManager.ClimbFloorRewards		= "GhostTowerManager.ClimbFloorRewards" 	--领取通关宝箱结果
GhostTowerManager.CloseRewardLayer		= "GhostTowerManager.CloseRewardLayer" 		--关闭鬼神之塔结算界面
GhostTowerManager.ClimbBuyTimesRes		= "GhostTowerManager.ClimbBuyTimesRes"		--购买次数结果
GhostTowerManager.RecordRes				= "GhostTowerManager.RecordRes"				--更新战斗记录
GhostTowerManager.SweepStageNum = 0

-- towerData = 
-- {
-- 	floorInfos = {}			//层信息
-- 	conditionId, 			//当前胜利条件id
-- 	attributes = {}, 		//当前属性
-- 	curId,					//当前关卡id
--  finishStages = {},		//已完成的关卡信息
-- 	restStar,				//剩余的星数
-- }
function GhostTowerManager:ctor()
	self.super.ctor(self)
end

function GhostTowerManager:init()
	self.super.init(self)
	
	self:reset()
	
	--所有层信息
	TFDirector:addProto(s2c.FLOOR_INFO_LIST, self, self.onReceiveFloorInfoList)
	--更新单个层信息
	TFDirector:addProto(s2c.UPDATE_FLOOR_INFO, self, self.onReceiveUpdateFloorInfo)
	--更新层战斗记录
	TFDirector:addProto(s2c.CLIMB_RECORD_RES, self, self.onReceiveRecordRes)
	--更新当前关卡信息
	TFDirector:addProto(s2c.UPDATE_CURRENT_PROGRESS, self, self.onReceiveUpdateCurrentProgress)	
	--选择层
	TFDirector:addProto(s2c.CHOOSE_FLOOR, self, self.onReceiveChooseFloor)
	--领取通关层宝箱结果
	TFDirector:addProto(s2c.CLIMB_FLOOR_AWARD_RESULT, self, self.onReceiveClimbFloorRewards)
	--挑战关卡结果
	TFDirector:addProto(s2c.CLIMB_CHALLENGE_RESULT, self, self.onReceiveClimbChallengeResult)
	--扫荡结果
	TFDirector:addProto(s2c.CLIMB_SWEEP_RESULT, self, self.onReceiveClimbSweepResult)
	--结算当前层结果信息
	TFDirector:addProto(s2c.CLIMB_RESULT, self, self.onReceiveClimbResultInfo)
	--购购买次数结果
	TFDirector:addProto(s2c.CLIMB_BUY_TIMES_RES, self, self.onReceiveClimbBuyTimesRes)

	TFDirector:addProto(s2c.CLIMB_CURRENT_FLOOR_INFO, self, self.onReceiveClimbCurrentFloorInfo)
	TFDirector:addProto(s2c.CLIMB_FRIEND_STAGE, self, self.onReceiveClimbFriendStage)
	TFDirector:addProto(s2c.CLIMB_SWEEP_STAGE_COUNT, self, self.onReceiveClimbSweepStageCount)
	TFDirector:addProto(s2c.RESET_CLIMB_RESULT, self, self.onReceiveResetClimbResult)
	TFDirector:addProto(s2c.CLIMB_BOX_INFO_LIST, self, self.onReceiveClimbBoxInfoList)
	TFDirector:addProto(s2c.CLIMB_BOX_RESULT, self, self.onReceiveClimbBoxInfo)
	TFDirector:addProto(s2c.CHOOSE_ATTRIBUTE_LIST, self, self.onReceiveChooseAttributeList)
	

	self.FriendIconList = nil
	self.is_Sweep = false --是否是扫荡导致的退出stage界面
	self.is_bool = false
	self.customsData = nil
	--是否打开结算界面
	self.is_open = true
	--扫荡奖励	
	self.sweepReward = nil
	--记录挑战的次数
	self.recordChallengeCount = nil
	--首通+1提示 
	self.isFirstPassPrompt = nil
	--刷新到指定挑战层(主动设置)
	self.refreshCell = 0
end

function GhostTowerManager:restart()
	self:reset()
end

function GhostTowerManager:reset()
	local towerData = {}
	self.towerData = towerData
	towerData.floorInfos = {}
	towerData.condition = 0
	towerData.attributes = {}
	towerData.curId = 0
	towerData.finishStages = {}
	towerData.passStageIds = {}
	towerData.restStar = 0
	
	self.towerRecord = {}
	self.chooseIds = {}
	
	local sweepData = {}
	self.sweepData = sweepData
	sweepData.cnt = 0
	sweepData.nextId = 0
	sweepData.logs = {}
	self.autoChoose = false
	self.sweep = false
	
	self.last = false
	
	self.FriendIconList = nil
	self.is_Sweep = false
	self.is_bool = false
	self.is_open = true
	self.customsData = nil
	self.sweepReward = nil
	self.recordChallengeCount = nil
	self.isFirstPassPrompt = nil
	self.refreshCell = nil	
end

-- protocol
function GhostTowerManager:sendClimbRecordReq()
	self:send(c2s.CLIMB_RECORD_REQ, true)
end

function GhostTowerManager:sendClimbFloorAward(floor)
	self.index = index
	self:sendWithLoading(c2s.CLIMB_FLOOR_AWARD, floor)
end

function GhostTowerManager:sendGetClimbBigBox(towerId)
	self.index = index
	self:sendWithLoading(c2s.CLIMB_GET_BIG_BOX, towerId, 0, 0)
end

function GhostTowerManager:sendGetClimbBigBoxList(stageId)
	self:sendWithLoading(c2s.CLIMB_BIG_BOX_LIST, stageId)
end

function GhostTowerManager:sendGetCurrentProgress()
	self:sendWithLoading(c2s.CLIMB_GET_CURRENT_PROGRESS, true)
end

function GhostTowerManager:sendChooseFloor(floorId)
	self:sendWithLoading(c2s.CHOOSE_FLOOR, floorId)
end

function GhostTowerManager:sendResetClimbState()
	self:sendWithLoading(c2s.RESET_CLIMB_STATE, true)
end

function GhostTowerManager:sendClimbChallengeTower(id, hardType)
	self:sendWithLoading(c2s.CLIMB_CHALLENGE_TOWER, id, hardType)
end  

function GhostTowerManager:sendChooseAttribute(id)
	self:sendWithLoading(c2s.CHOOSE_ATTRIBUTE, id)
end

function GhostTowerManager:sendClimbSweepStageCount(auto)
	self.autoChoose = auto
	self:sendWithLoading(c2s.CLIMB_SWEEP_STAGE_COUNT, auto)
end

function GhostTowerManager:sendClimbSweepRequest(towerId, sweepTimes) 
	self:send(c2s.CLIMB_SWEEP_REQUEST, self.autoChoose, towerId, sweepTimes) 
end

function GhostTowerManager:sendArenaGetBattleRecord(reportId)
	self:sendWithLoading(c2s.ARENA_GET_BATTLE_RECORD, reportId)
end

function GhostTowerManager:sendClimbBuyTimesReq(buyCount)
	self:sendWithLoading(c2s.CLIMB_BUY_TIMES_REQ, buyCount) 
end

function GhostTowerManager:onReceiveFloorInfoList(event)
	local data = event.data
	
	if not data or not data.info then return end
	
	local towerData = self.towerData
	for k, info in pairs(data.info) do
		towerData.floorInfos[info.id] = info
	end
end

function GhostTowerManager:onReceiveUpdateFloorInfo(event)
	local data = event.data
	local towerData = self.towerData

	towerData.floorInfos[data.info.id] = data.info
end

function GhostTowerManager:onReceiveRecordRes(event)
	hideLoading()

	local data = event.data
	local towerRecord = self.towerRecord

	for k, v in pairs(data.records) do
		towerRecord[v.towerId] = v
	end

	TFDirector:dispatchGlobalEventWith(GhostTowerManager.RecordRes, 0)
end  

function GhostTowerManager:onReceiveUpdateCurrentProgress(event)
	hideLoading()
	local data = event.data
	
	local towerData = self.towerData
	towerData.conditionId = data.conditionId
	self:setAttributeData(data.attId)
	towerData.curId = data.curId
	towerData.restStar = data.curStar
	towerData.maxLevel = data.maxStageId
	
	TFDirector:dispatchGlobalEventWith(GhostTowerManager.RefreshAttribLayer, 0)
	
	--放弃,通关关卡 的时候不打开结算界面,直接回到层界面
	if not self.is_open then
		TFDirector:dispatchGlobalEventWith(GhostTowerManager.CloseRewardLayer, 0)
	end
end

function GhostTowerManager:onReceiveClimbCurrentFloorInfo(event)
	local data = event.data
	
	if not data then return end
	
	local towerData = self.towerData
	if data.StageList then
		for k, stageInfo in pairs(data.StageList) do
			towerData.finishStages[stageInfo.id] = stageInfo
		end
	else
		towerData.finishStages = {}
	end
	towerData.passStageIds = data.passStageId or {}
	towerData.restStar = data.curStar
	
	local pass_all = 0
	for k, v in pairs(towerData.finishStages) do
		local pass = v.star > 0
		if pass == true then
			pass_all = pass_all + 1
		end
	end
	
	local cur_floor_id, cur_f = math.modf(towerData.curId / 100)
	if TowerData.floorList ~= nil and #TowerData.floorList > 0 and cur_floor_id > 0 then
		local stages_num = #TowerData.floorList[cur_floor_id]
		if pass_all == stages_num then
			print("pass all....................")
		end
	end
end

function GhostTowerManager:onReceiveChooseFloor(event)
	hideLoading()
	local data = event.data
	self:openGhostTowerStageLayer(data.floor)
end

function GhostTowerManager:onReceiveChooseAttributeList(event)
	local data = event.data
	
	self.chooseIds = data.attId
end

function GhostTowerManager:onReceiveClimbBuyTimesRes(enent)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(GhostTowerManager.ClimbBuyTimesRes, 0)
end

function GhostTowerManager:onReceiveClimbChallengeResult(event)
	local data = event.data
	
	self.last = data.last
	if data.last == true and data.win == true then
	end
	
	self.customsData = data
end

function GhostTowerManager:onReceiveResetClimbResult(event)
	hideLoading()
	local data = event.data
end

function GhostTowerManager:onReceiveClimbSweepStageCount(event)
	hideLoading()
	local data = event.data
	
	GhostTowerManager.SweepStageNum = data.sweepNum
	local sweepData = self.sweepData
	sweepData.logs = {}
	sweepData.cnt = data.sweepNum
	sweepData.nextId = data.nextId
	
	TFDirector:dispatchGlobalEventWith(GhostTowerManager.SweepStageCount, 0)
end

function GhostTowerManager:onReceiveClimbBoxInfo(event)
	hideLoading()
	local boxInfo = event.data
	local towerData = self.towerData
	if towerData.finishStages[boxInfo.towerId] ~= nil then
		towerData.finishStages[boxInfo.towerId].state = boxInfo.state
	end
	TFDirector:dispatchGlobalEventWith(GhostTowerManager.GetRewardBox, boxInfo)
end

function GhostTowerManager:onReceiveClimbResultInfo(event)
	hideLoading()
	local data = event.data
	if not data then return end
	
	print("---onReceiveClimbResultInfo---data:", data)
	
	--扫荡关卡打开结算界面
	if self.is_open then
		--扫荡特殊处理(把扫荡的结果直接赋予重置关卡的结果)
		-- local sweepReward = self.sweepReward
		
		-- if sweepReward and(not data.item) then
		-- 	data.item = sweepReward
		-- 	self.sweepReward = nil
		-- end
		
		-- self:openGhostTowerClimbJieSuanLayer(data)

		RewardManager:showRewardList(self.sweepReward)
	end
	
	--默认首通+1不提示
	self:setFirstPassPrompt(false)
	
	local timesInfo = RecoverableResManager:getRecoverParamsInfo(EnumTimeRecoverType.GhostTower)
	if timesInfo and self.recordChallengeCount then
		local maxValue = timesInfo.maxValue
		local challengeCount = timesInfo:getLeftValue()
		
		--正常情况
		if challengeCount == self.recordChallengeCount + 1 then
			self:setFirstPassPrompt(true)
		else
			--如果挑战是12点之前，挑战出来后是12点以后的情况
			if challengeCount == timesInfo.maxValue + 1 then
				self:setFirstPassPrompt(true)
			end
		end
	end
	
	self:setRecordChallengeCount(nil)	
end      

function GhostTowerManager:onReceiveClimbBoxInfoList(event)
	hideLoading()
	local data = event.data
	local boxInfo = data.boxInfo
	if boxInfo.state == 0 then
		boxInfo.canRecive = false
	end
	BloodyWarManager:openBloodyWarChooseLayer(boxInfo)
end

function GhostTowerManager:onReceiveClimbFloorRewards(event)
	hideLoading()
	local data = event.data
	
	local rewardType = data.type
	local rewards = data.selectList or {}
	
	TFDirector:dispatchGlobalEventWith(GhostTowerManager.ClimbFloorRewards, 0)
end

function GhostTowerManager:onReceiveClimbFriendStage(event)
	hideLoading()
	local data = event.data
	-- print("==onReceiveClimbFriendStage==", data)
	self.FriendIconList = data
	TFDirector:dispatchGlobalEventWith(GhostTowerManager.RefreshFrendIcon, 0)
end

--扫荡结果
function GhostTowerManager:onReceiveClimbSweepResult(event)
	hideLoading()
	local data = event.data
	
	print("---onReceiveClimbSweepResult---data:", data)
	
	--logType 1:reward 2:attr
	local sweepData = self.sweepData

	sweepData.logs[#sweepData.logs + 1] = {log_type = 1, id = sweepData.nextId, reward_list = data.selectList}
	if data.type == 2 then
		if self.autoChoose then
			sweepData.logs[#sweepData.logs + 1] = {log_type = 2, attr_id = data.attId}
		else
			--GhostTowerManager:openGhostTowerAttributeChoiceLayer()
		end
	end
	
	sweepData.nextId = data.nextId
	self.last = data.last
	
	if data.type ~= 2 or self.autoChoose then
		TFDirector:dispatchGlobalEventWith(GhostTowerManager.RefreshSweepLog, 0)
	end
	
	self:setGhostTowerIsBool(true)
	
	local rewardType = data.type
	local rewards = data.selectList or {}
	
	--保存扫荡奖励，在结算层信息后的结算界面显示
	self.sweepReward = rewards
	self:setChostTowerIsOpen(true)
	self:setRecordChallengeCount(nil)
	self:sendResetClimbState()
end

--打开宝箱
function GhostTowerManager:openRewardShowLayer(isReceive, group_id, callFunc, privateData)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.RewardShowLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData1(isReceive, group_id, callFunc, privateData)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerTipsLayer(data, confirmFunc)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerTipsBoxLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setData(data, confirmFunc)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerFloorLayer()
	local towerData = self.towerData
	
	if towerData.curId == 0 then
		self:openGhostTowerMainLayer()
	else
		local stageData = TowerData:objectByID(towerData.curId)
		self:openGhostTowerStageLayer(stageData.floor)
	end
end

function GhostTowerManager:openGhostTowerMainLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerFloorLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerStageLayer(floorId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerStageLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setData(floorId)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerHardChoiceLayer(stage)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerHardChoiceLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setData(stage)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerAttributeChoiceLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerAttrChoiceLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerAutoConfirmLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerAutoConfirmLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerSweepLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerSweepLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerClimbJieSuanLayer(data)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerClimbJieSuanLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function GhostTowerManager:openGhostTowerClimbSdLayer(towerId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerClimbSdLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(towerId)
	AlertManager:show()
end 

function GhostTowerManager:isPass(id)
	for k, passId in pairs(self.towerData.passStageIds) do
		if passId == id then
			return true
		end
	end
	return false
end

function GhostTowerManager:getSweepAllRewards()
	local rewards = {}
	
	local getRewardByTplId = function(tplId)
		for k, reward in pairs(rewards) do
			if reward.tplId == tplId then
				return reward
			end
		end
		return nil
	end
	
	for k, log in pairs(self.sweepData.logs) do
		if log.log_type == 1 then
			if log.reward_list then
				for i, rewardData in pairs(log.reward_list) do
					local reward = getRewardByTplId(rewardData.tplId)
					if reward then
						reward.num = reward.num + rewardData.num
					else
						rewards[#rewards + 1] = rewardData
					end
				end
			end
		end
	end
	return rewards
end

function GhostTowerManager:getTotalStar()
	local towerData = self.towerData
	local totalStar = 0
	for k, floor in pairs(towerData.floorInfos) do
		totalStar = totalStar + floor.star
	end
	return totalStar
end

function GhostTowerManager:getMaxFloor()
	local towerData = self.towerData
	if towerData.maxLevel == nil or towerData.maxLevel == 0 then
		return 0, 0
	end
	local maxFloor, maxStage = math.modf(towerData.maxLevel / 100)
	maxStage = towerData.maxLevel % 100
	return maxFloor, maxStage
end

function GhostTowerManager:getOpenFloors()
	local towerData = self.towerData
	local floors = {}
	
	for k, v in pairs(TowerData.floorList) do
		floors[k] = {}
		floors[k].isFinish = false
		floors[k].star = 0
		floors[k].isReward = false
		floors[k].id = k
		floors[k].chapterId = 100 * k + 1
		floors[k].isOpen = false
		--直接关闭箱子,优先级最高
		floors[k].isCloseChest = false
		
		local data = towerData.floorInfos[k]
		if data then
			floors[k].isFinish = data.isFinish
			floors[k].star = data.star
			floors[k].isReward = data.isReward
			floors[k].isOpen = true
		end
	end
	
	if towerData and #towerData.floorInfos < #TowerData.floorList then
		floors[#towerData.floorInfos + 1].isOpen = true
	end
	
	--额外增加2层
	for i = 1, 2 do
		local index = #TowerData.floorList
		
		floors[index + i] = {}
		floors[index + i].isFinish = false
		floors[index + i].star = 0
		floors[index + i].isReward = false
		floors[index + i].id = index + i
		floors[index + i].chapterId = 100 *(index + 1) + 1
		floors[index + i].isOpen = false
		--直接关闭箱子,优先级最高
		floors[index + i].isCloseChest = true
	end
	
	return floors
end

function GhostTowerManager:getRecordRes(towerId)
	if self.towerRecord then
		return self.towerRecord[towerId]
	else
		return nil
	end
end 

-- local
function GhostTowerManager:setAttributeData(attrId)
	local towerData = self.towerData
	towerData.attributes = {}
	
	if #attrId < 1 then return end
	
	local attrIds = string.split(attrId, ",")
	for _, id in pairs(attrIds) do
		local towerAttrData = TowerAttData:objectByID(tonumber(id))
		if towerAttrData then
			local attr = towerData.attributes[towerAttrData.buff_type]
			if not attr then
				attr = {
					attrID = id,
					buff_name = towerAttrData.buff_name,
					value = towerAttrData.value
				}
				towerData.attributes[towerAttrData.buff_type] = attr
			else
				attr.value = attr.value + towerAttrData.value
			end
		end
	end
end

function GhostTowerManager:isRandomShopOpen()
	local shops = ShopManager:getShopByType(EnumShopType.TowerRandomShop)
	return #shops > 0
end

function GhostTowerManager:getGhostTowerIsSweep()
	return self.is_Sweep
end

function GhostTowerManager:setGhostTowerIsSweep(is_bool)
	self.is_Sweep = is_bool
end

function GhostTowerManager:getGhostTowerIsBool()
	return self.is_bool
end

function GhostTowerManager:setGhostTowerIsBool(is_b)
	self.is_bool = is_b
end

--设置结算界面开关
function GhostTowerManager:setChostTowerIsOpen(is_open)
	self.is_open = is_open
end	

--保存挑战次数
function GhostTowerManager:setRecordChallengeCount(recordChallengeCount)
	self.recordChallengeCount = recordChallengeCount
end

function GhostTowerManager:getFirstPassPrompt(is_firstPassPrompt)
	return self.isFirstPassPrompt
end

function GhostTowerManager:setFirstPassPrompt(is_firstPassPrompt)
	self.isFirstPassPrompt = is_firstPassPrompt
end

function GhostTowerManager:getGhostTowerRefreshCell()
	return self.refreshCell
end 

function GhostTowerManager:setGhostTowerRefreshCell(refreshCell)
	self.refreshCell = refreshCell
end

function GhostTowerManager:isHaveRedPoint()
	local is_can = JumpToManager:isCanJump(FunctionManager.ChallengeGhost)
	local timesInfo = RecoverableResManager:getRecoverParamsInfo(EnumTimeRecoverType.GhostTower)
	if is_can and timesInfo:getLeftValue() > 0 then return true end
	return false
end

return GhostTowerManager:new() 