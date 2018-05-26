--[[
******任务管理类*******

	-- by Tony
	-- 2016/9/03
]]

local BaseManager = require('lua.gamedata.BaseManager')
local TaskManager = class("TaskManager", BaseManager)

TaskManager.UpdateTask 		  = "TaskManager.UpdateTask"
TaskManager.UpdateGift 		  = "TaskManager.UpdateGift"
TaskManager.UpdateAchievement = "TaskManager.UpdateAchievement"

-- message TaskInfo
-- {
-- 	required int32 taskid = 1;    //任务id
-- 	required int32 state = 2;  	  //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
-- 	required int32 currstep = 3;  //当前进度
-- 	required int32 totalstep = 4; //总进度
-- }
-- message AchievementInfo
-- {
-- 	required int32 achievementId = 1;    //任务id
-- 	required int32 state = 2;  	  		 //状态 0：未完成 1:已完成但未领取奖励  2:该类型任务全部完成
-- 	required int32 currstep = 3;  		 //当前进度
-- 	required int32 totalstep = 4; 		 //总进度
-- }
function TaskManager:ctor(data)
	self.super.ctor(self, data)

end

function TaskManager:init()
	self.super.init(self)
	
	TFDirector:addProto(s2c.TASK_LIST, self, self.onReceiveTaskListInfo)
	TFDirector:addProto(s2c.GET_TASK_REWARD_RESULT, self, self.onReceiveTaskResultInfo)
	TFDirector:addProto(s2c.NOTIFY_NEW_TASK, self, self.onReceiveNewInfo)
	TFDirector:addProto(s2c.NOTIFY_TASK_STEP, self, self.onReceiveStepInfo)
	TFDirector:addProto(s2c.APPLY_TASK_GIFT_RESULT, self, self.onReceiveGiftResultInfo)

	TFDirector:addProto(s2c.ACHIEVEMENT_LIST, self, self.onReceiveAchievementList)
	TFDirector:addProto(s2c.GET_ACHIEVEMENT_REWARD_RESULT, self, self.onReceiveRewardResult)
	TFDirector:addProto(s2c.NOTIFY_NEW_ACHIEVEMENT, self, self.onReceiveNewAchievement)
	TFDirector:addProto(s2c.NOTIFY_ACHIEVEMENT_STEP, self, self.onReceiveUpdateAchievement)

	self.giftIndex = {}
	self.taskList = TFArray:new()
	self.achievementList = TFArray:new()

	self.curTaskPoint = 0
	self.totalTaskPoint = 0
end

function TaskManager:restart()
	self.giftIndex = {}

	if self.taskList then
		self.taskList:clear()
	else
		self.taskList = TFArray:new()
	end

	if self.achievementList then
		self.achievementList:clear()
	else
		self.achievementList = TFArray:new()
	end

	self.curTaskPoint = 0
	self.totalTaskPoint = 0
end

function TaskManager:onReceiveTaskListInfo(event)
	hideLoading()

	self.giftIndex = {}
	self.taskList:clear()

	local taskList = event.data.tasklist or {}
	local giftIndex = event.data.giftindex or {}
	for _,v in pairs(taskList) do
		self:addTask(v)
	end
	for _,v in pairs(giftIndex) do
		self.giftIndex[tonumber(v)] = true
	end
	self:sortTaskList()
end

function TaskManager:onReceiveTaskResultInfo(event)
	hideLoading()

	for _,v in pairs(event.data.taskid) do
		local task = self:findTask(v)
		if task then
			task.state = 2
			task.currstep = task.totalstep
		end
	end

	self:sortTaskList()
	TFDirector:dispatchGlobalEventWith(TaskManager.UpdateTask, 0)
end

function TaskManager:onReceiveNewInfo(event)
	hideLoading()

	local taskList = event.data.taskList or {}
	for _,v in pairs(taskList) do
		self:addTask(v)
	end

	self:sortTaskList()
	TFDirector:dispatchGlobalEventWith(TaskManager.UpdateTask, 0)
end

function TaskManager:onReceiveStepInfo(event)
	hideLoading()

	local task = self:findTask(event.data.taskid)
	if task then
		task.currstep = event.data.currstep
		if task.currstep == task.totalstep then
			task.state = 1
		end
	end

	self:sortTaskList()
	TFDirector:dispatchGlobalEventWith(TaskManager.UpdateTask, 0)
end

function TaskManager:onReceiveGiftResultInfo(event)
	hideLoading()

	self.giftIndex[tonumber(event.data.giftindex)] = true

	TFDirector:dispatchGlobalEventWith(TaskManager.UpdateGift, 0)
end

function TaskManager:onReceiveAchievementList(event)
	hideLoading()

	local data = event.data
	data.achievementList = data.achievementList or {}
	--print("achievement ", data.achievementList)
	for _,ach in pairs(data.achievementList) do
		self:addAchievement(ach)
	end
	self:sortAchievementList()
end

function TaskManager:onReceiveRewardResult(event)
	hideLoading()
	local data = event.data
	for _,achId in pairs(data.achievementId) do
		local ach = self:findAchievement(achId)
		if not ach then break end
		local nextAch = {}
		nextAch.state = 0
		nextAch.achievementId = ach.template.next_id
		local template = AchievementData:objectByID(nextAch.achievementId)
		if template then
			if template.is_inherit ~= 0 then
				nextAch.currstep = ach.currstep
			end
			nextAch.totalstep = template.target
			self:addAchievement(nextAch)
		end
		self.achievementList:removeObject(ach)
	end
	self:sortAchievementList()
	TFDirector:dispatchGlobalEventWith(TaskManager.UpdateAchievement, 0)
end

function TaskManager:onReceiveNewAchievement(event)
	hideLoading()
	
	local data = event.data
	if not data.achievementList then return end
	for _,ach in pairs(data.achievementList) do
		self:addAchievement(ach)
	end
	self:sortAchievementList()
	TFDirector:dispatchGlobalEventWith(TaskManager.UpdateAchievement, 0)
end

function TaskManager:onReceiveUpdateAchievement(event)
	hideLoading()
	
	local data = event.data
	local achievementId = data.achievementId
	local currstep = data.currstep
	local ach = self:findAchievement(achievementId)
	if ach then
		ach.currstep = currstep
		ach.state = data.state
	end
	self:sortAchievementList()
	TFDirector:dispatchGlobalEventWith(TaskManager.UpdateAchievement, 0)
end

--proto 
function TaskManager:sendGetTaskReward(taskId)
	self:sendWithLoading(c2s.GET_TASK_REWARD , taskId)
end

function TaskManager:sendApplyTaskGift(index)
	self:sendWithLoading(c2s.APPLY_TASK_GIFT , index)
end

function TaskManager:sendAchievementReward(achievementId)
	self:sendWithLoading(c2s.GET_ACHIEVEMENT_REWARD, achievementId)
end

--=======================

function TaskManager:addTask(task)
	if task == nil or not TaskData:objectByID(task.taskid) or self:findTask(task.taskid) then
		return
	end

	local taskInfo = {}
	taskInfo.taskId = task.taskid
	taskInfo.state = task.state
	taskInfo.currstep = task.currstep
	taskInfo.totalstep = task.totalstep
	taskInfo.template = TaskData:objectByID(task.taskid)
	self.taskList:push(taskInfo)
end

function TaskManager:findTask(taskId)
	for task in self.taskList:iterator() do
		if task.taskId == taskId then
			return task
		end
	end
	return nil
end

local function sortList(a1, a2)
	if a1.state == 1 and a2.state == 1 then
		return a1.template.id < a2.template.id
	end
	if a1.state == 1 then
		return true
	end
	if a2.state == 1 then
		return false
	end
	if a1.state < a2.state then
		return true
	end
	if a1.state > a2.state then
		return false
	end
	return a1.template.id < a2.template.id
end

function TaskManager:sortTaskList()
	self.taskList:sort(sortList)
	self:updateTaskPoint()
end

function TaskManager:getTaskList()
	local achList = TFArray:new()
	for achievement in self.taskList:iterator() do
		if achievement.template.level <= CardRoleManager.mainRole.level then
			achList:push(achievement)
		end
	end
	return achList
	-- return self.taskList
end

function TaskManager:getTaskByIndex(index)
	return self.taskList:objectAt(index)
end

function TaskManager:getTaskListLength()
	return self.taskList:length()
end

function TaskManager:getCurTaskPoint()
	if not self.curTaskPoint or self.curTaskPoint == 0 then
		self:updateTaskPoint()
	end
	return self.curTaskPoint
end

function TaskManager:getTotalTaskPoint()
	if not self.totalTaskPoint or self.totalTaskPoint == 0 then
		self:updateTaskPoint()
	end
	return self.totalTaskPoint
end

function TaskManager:updateTaskPoint()
	self.curTaskPoint = 0
	self.totalTaskPoint = 0
	for task in self.taskList:iterator() do
		local point = TaskData:getPointByID(task.taskId)
		if task.state == 2 then
			self.curTaskPoint = self.curTaskPoint + point
		end
		self.totalTaskPoint = self.totalTaskPoint + point
	end
end

--------------------------------- ach ----------------------------

function TaskManager:addAchievement(achievement)
	if achievement == nil or not AchievementData:objectByID(achievement.achievementId) or self:findAchievement(achievement.achievementId) then
		return
	end

	local achInfo = {}
	achInfo.achievementId = achievement.achievementId
	achInfo.state = achievement.state
	achInfo.currstep = achievement.currstep
	achInfo.totalstep = achievement.totalstep
	achInfo.template = AchievementData:objectByID(achievement.achievementId)
	self.achievementList:push(achInfo)
end

function TaskManager:findAchievement(achievementId)
	for achievement in self.achievementList:iterator() do
		if achievement.achievementId == achievementId then
			return achievement
		end
	end
	return nil
end

function TaskManager:sortAchievementList()
	self.achievementList:sort(sortList)
end

function TaskManager:getAchievementList(type)
	local achList = TFArray:new()
	for achievement in self.achievementList:iterator() do
		if achievement.template.type == type and achievement.template.open_level <= CardRoleManager.mainRole.level then
			achList:push(achievement)
		end
	end
	return achList
end

--================================== redPoint ======================
function TaskManager:taskIsOpen()
	local is_can = JumpToManager:isCanJump(FunctionManager.TaskList)
	return is_can
end

function TaskManager:isHaveTaskAndAch()
	if self:isHaveTask() then return true end

	-- for _,type in pairs(EnumAchievementType) do
	-- 	if self:isHaveAchievement(type) then
	-- 		return true
	-- 	end
	-- end
	--zzteng chage 
	if self:isHaveAchievement(EnumAchievementType.Total) then return true end
	return false
end

function TaskManager:isHaveTask()
	if not self:taskIsOpen() then return false end
	
	local level = MainPlayer:getLevel() or 0
	for task in self.taskList:iterator() do
		if task and task.template and task.template.level and task.template.level <= level and task.state == 1 then
			return true
		end
	end

	local total = TaskPointData:getTotalCount()
	local curPoint = self:getCurTaskPoint()
	for i=1,total do
		local point = TaskPointData:getPointByID(i)
		if not self.giftIndex[i] and curPoint >= point then
			return true
		end
	end
	return false
end

function TaskManager:isHaveundoneTask()
	local level = MainPlayer:getLevel() or 0
	for task in self.taskList:iterator() do
		if task and task.template and task.template.level and task.template.level <= level and task.state == 0 then
			return true
		end
	end
end

function TaskManager:isHaveAchievement(type)
	local level = MainPlayer:getLevel() or 0
	for ach in self.achievementList:iterator() do
		if ach and ach.template and ach.template.type == type and ach.state == 1 and ach.template.open_level <= level then
			return true
		end
	end
	return false
end

-----------------------------  end --------------------------

function TaskManager:showTaskLayer(type)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.task.TaskLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(type)
    AlertManager:show()
end

function TaskManager:openAchevementLayer(type)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.task.AchievementLayer", AlertManager.BLOCK_AND_GRAY)
    layer:loadData(type)
    AlertManager:show()
end

function TaskManager:openTaskGotoLayer( index )
	if index == 2 then
		local data = MissionManager:currentChapterByType( EnumMissionType.Main )
        MissionManager:showMissionLayer( data.template.id )
	elseif index == 3 then
		local data = MissionManager:currentChapterByType( EnumMissionType.Elite )
		if not data then toastMessage(localizable.common_unopened) return end
        MissionManager:showMissionLayer( data.template.id )
	elseif index == 4 then
		LotteryManager:openLotteryLayer()
	elseif index == 5 then
		toastMessage(localizable.common_unopened)
	elseif index == 6 then
		EquipmentManager:openEquipmentLayer(0)
	elseif index == 7 then
		CardRoleManager:openRoleListLayer()
	elseif index == 8 then
		toastMessage(localizable.common_unopened)
	elseif index == 10 then
		toastMessage(localizable.common_unopened)
	elseif index == 12 then
		ArenaManager:openArenaPlayerListLayer()
	elseif index == 13 then
		BloodyWarManager:sendQueryBloodyDetail()
	elseif index == 14 then
		-- toastMessage(localizable.common_unopened)
		MissionManager:openMissionDayLayer()
	elseif index == 15 then
		GhostTowerManager:openGhostTowerFloorLayer()
	elseif index == 18 then

		local data = DietData:getDietList()
		if not data then return end 
		local times = os.date("%H",GetGameTime())
		local b_show = false
		local diningData = MainPlayer.diningData
		if diningData then
			for k,v in pairs(data) do
				local item = diningData[k]
				if not item then return end
				if v.beginT <= tonumber(times) and tonumber(times) < v.endT and item.status ~= 3 then
					b_show = true
					break
				end
			end
		end
		if not b_show then
			toastMessage(stringUtils.format(localizable.task_daily_tili,data[1].beginT,data[2].beginT,data[3].beginT))
		else
			AlertManager:close()
			local currentScene = Public:currentScene()
			if currentScene and currentScene.getTopLayer then
				local topLayer = currentScene:getTopLayer()
				if topLayer then
					topLayer:SetPanelDiPosition(0, topLayer)
				end
			end
		end
	elseif index == 19 then
		FriendManager:openFriendMainLayer()
	elseif index == 23 then
		toastMessage(localizable.common_unopened)
	elseif index == 24 then
		CommonManager:openCommonBuyLayer(EnumResourceType.Strengh)
	elseif index == 25 then
		CommonManager:openCommonBuyLayer(EnumResourceType.Coin)
	elseif index == 26 then
		ShopManager:showShopLayer(EnumShopType.SyceeShop)
	elseif index == 27 then
		toastMessage(localizable.common_unopened)
	elseif index == 28 then
		toastMessage(localizable.common_unopened)
	end
	return

end

function TaskManager:openAchevementGotoLayer( index )
	if index == 1 then
		LotteryManager:openLotteryLayer()
	elseif index == 2 then
		EquipmentManager:openEquipmentLayer(0)
	elseif index == 3 then
		local cardRole = CardRoleManager:getSelectedCardRole()
        CardRoleManager:openRoleInfoLayer(cardRole)
	elseif index == 4 then
		local data = MissionManager:currentChapterByType( EnumMissionType.Main )
        MissionManager:showMissionLayer( data.template.id )
	elseif index == 5 then
		toastMessage(localizable.common_unopened)
	elseif index == 6 then
		toastMessage(localizable.common_unopened)
	elseif index == 7 then
		toastMessage(localizable.common_unopened)
	elseif index == 8 then
		toastMessage(localizable.common_unopened)
	elseif index == 9 then
		ArenaManager:openArenaPlayerListLayer()
	elseif index == 10 then
		BloodyWarManager:sendQueryBloodyDetail()
	elseif index == 11 then
		GhostTowerManager:openGhostTowerFloorLayer()
	elseif index == 12 then
		local data = MissionManager:currentChapterByType( EnumMissionType.Main )
        MissionManager:showMissionLayer( data.template.id )
	elseif index == 13 then
		local data = MissionManager:currentChapterByType( EnumMissionType.Elite )
		if not data then toastMessage(localizable.common_unopened) return end
        MissionManager:showMissionLayer( data.template.id )
	elseif index == 14 then
		toastMessage(localizable.common_unopened)
	elseif index == 15 then
		LotteryManager:openLotteryLayer()
	elseif index == 16 then
		toastMessage(localizable.common_unopened)
	elseif index == 17 then
		toastMessage(localizable.common_unopened)
	end
	return
end

return TaskManager:new()