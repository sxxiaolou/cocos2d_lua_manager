--
-- 七日奖励管理类
-- Author: Jin
-- Date: 2016-11-03
--

local BaseManager = require('lua.gamedata.BaseManager')
local SevenDaysManager = class("SevenDaysManager", BaseManager)

SevenDaysManager.RefreshTasks = "SevenDaysManager.RefreshTasks"
SevenDaysManager.updateSevenDayLogin = "SevenDaysManager.updateSevenDayLogin"

function SevenDaysManager:ctor()
	self.super.ctor(self)
end

function SevenDaysManager:init()
	self.super.init(self)

	TFDirector:addProto(s2c.SEVEN_DAYS_GOAL_TASK_LIST, self, self.onReceiveSevenDaysGoalTaskList)
	TFDirector:addProto(s2c.NOTIFY_NEW_SEVEN_DAYS_GOAL_TASK, self, self.onReceiveNotifyNewSevenDaysGoalTask)
	TFDirector:addProto(s2c.NOTIFY_SEVEN_DAYS_GOAL_TASK_STEP, self, self.onReceiveNotifySevenDaysGoalTaskStep)
	TFDirector:addProto(s2c.GET_SEVEN_DAYS_GOAL_TASK_REWARD_RESULT, self, self.onReceiveGetSevenDaysGoalTaskRewardResult)

	TFDirector:addProto(s2c.LOGIN_SEVEN_DAYS_GOAL_TASK_LIST, self, self.onReceiveLoginSevenDaysGoalTaskList)
	TFDirector:addProto(s2c.GET_LOGIN_SEVEN_DAYS_GOAL_TASK_REWARD_RESULT, self, self.onReceiveGetLoginSevenDaysGoalTaskRewardResult)

	self:reset()
end

function SevenDaysManager:restart()
	self:reset()
end

function SevenDaysManager:reset()
	self.openDays = 1
	self.sevenDayTasks = {}
	self.allTasks = {}

	self.loginSevenDaysTaskList = {}

	self.isCheckXianGou = {}

	self.isOpenSevenDaysLoginLay = false
end

-- protocol
function SevenDaysManager:sendGetSevenDaysGoalTaskReward(taskid)
	self:sendWithLoading(c2s.GET_SEVEN_DAYS_GOAL_TASK_REWARD, taskid)
end

function SevenDaysManager:sendQuerySevenDaysGoalTask( ... )
	self:sendWithLoading(c2s.QUERY_SEVEN_DAYS_GOAL_TASK,false)
end

function SevenDaysManager:onReceiveSevenDaysGoalTaskList(event)
	hideLoading()
	local data = event.data
	self.sevenDayTasks = data.tasklist or {}
	self.openDays = data.days or 1
	print("onReceiveSevenDaysGoalTaskList===", self.openDays)
	-- print("---", data)
	table.sort(self.sevenDayTasks, function(t1, t2) return t1.days < t2.days end)

	for k, sevenDaysTask in pairs(self.sevenDayTasks) do
		sevenDaysTask.tasks = {}
		sevenDaysTask.tasklist = sevenDaysTask.tasklist or {}
		for i, taskInfo in pairs(sevenDaysTask.tasklist) do
			self:groupTaskInfo(sevenDaysTask, taskInfo)
		end
		sevenDaysTask.tasklist = nil

		self:sortDayTask(sevenDaysTask)
		-- for k,tasks in pairs(sevenDaysTask.tasks) do
		-- 	-- table.sort(tasks, function(t1, t2) return t1.taskid < t2.taskid end)
		-- 	self:sortTask(tasks)
		-- end
	end

	if self.openDays <= 8 then
		CommonUiManager:addActivityIcon(EnumActivityType.SevenDays)
	end
	if self.canOpen then
	    self.canOpen = nil
	    self:openSevenDaysLayer()
	end
end

function SevenDaysManager:onReceiveNotifyNewSevenDaysGoalTask(event)
	local data = event.data

	-- print("onReceiveNotifyNewSevenDaysGoalTask===", data)
	local sevenDaysTask = data.task
	sevenDaysTask.tasklist = sevenDaysTask.tasklist and sevenDaysTask.tasklist or {}
	self.openDays = sevenDaysTask.days
	self.sevenDayTasks[self.openDays] = sevenDaysTask
	sevenDaysTask.tasks = {}
	for i, taskInfo in pairs(sevenDaysTask.tasklist) do
		self:groupTaskInfo(sevenDaysTask, taskInfo)
	end

	self:sortDayTask(sevenDaysTask)
	-- for k,tasks in pairs(sevenDaysTask.tasks) do
	-- 	--table.sort(tasks, function(t1, t2) return t1.taskid < t2.taskid end)
	-- 	self:sortTask(tasks)
	-- end
	sevenDaysTask.tasklist = nil
	
	CommonUiManager:addActivityIcon(EnumActivityType.SevenDays, self.openDays > 8)
	TFDirector:dispatchGlobalEventWith(SevenDaysManager.RefreshTasks)
end

function SevenDaysManager:sortDayTask(sevenDaysTask)
	sevenDaysTask = sevenDaysTask or {}
	for k,tasks in pairs(sevenDaysTask.tasks) do
		self:sortTask(tasks)
	end
end

function SevenDaysManager:sortTask(tasks)
	local weight = {2,3,1}

	local function sortFunc(t1, t2)
		if t1.state == t2.state then
			return t1.taskid < t2.taskid
		end

		t1.weight = weight[t1.state + 1] or 0
		t2.weight = weight[t2.state + 1] or 0
		return t1.weight > t2.weight
	end
	table.sort(tasks, sortFunc)
end

function SevenDaysManager:onReceiveNotifySevenDaysGoalTaskStep(event)
	local data = event.data

	-- print("onReceiveNotifyNewSevenDaysGoalTask===", data)

	local taskInfo = self.allTasks[data.taskid]
	if taskInfo then
		taskInfo.currstep = data.currstep
		taskInfo.goal = data.goal
		-- if taskInfo.currstep >= taskInfo.goal then
		taskInfo.state = data.state
		-- end

		local sevenDaysTask = self.sevenDayTasks[taskInfo.template.day] or {}
		self:sortDayTask(sevenDaysTask)
	end
end

function SevenDaysManager:onReceiveGetSevenDaysGoalTaskRewardResult(event)
	local data = event.data

	-- print("onReceiveGetSevenDaysGoalTaskRewardResult===", data)

	if not data.taskid then return end

	local taskInfo = self.allTasks[data.taskid[1]]
	if taskInfo then
		taskInfo.state = 2

		local sevenDaysTask = self.sevenDayTasks[taskInfo.template.day] or {}
		self:sortDayTask(sevenDaysTask)
		TFDirector:dispatchGlobalEventWith(SevenDaysManager.RefreshTasks, taskInfo)
	end
end

-- api
function SevenDaysManager:openSevenDaysLayer()
	if self.sevenDayTasks == nil then return end
	print("++++++++==- ", #self.sevenDayTasks)
	if #self.sevenDayTasks == 0 then return end
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.sevendays.SevenDaysLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

-- local
function SevenDaysManager:groupTaskInfo(sevenDaysTask, taskInfo)
	local taskData = SevenDayTaskData:objectByID(taskInfo.taskid)
	if taskData then
		local groupTasks = self:groupExist(sevenDaysTask, taskData.tab)
		if not groupTasks then
			groupTasks = {}
			sevenDaysTask.tasks[#sevenDaysTask.tasks + 1] = groupTasks
		end
		taskInfo.template = taskData
		groupTasks[#groupTasks + 1] = taskInfo

		self.allTasks[taskInfo.taskid] = taskInfo
	end
end

function SevenDaysManager:groupExist(sevenDaysTask, tab)
	for k, groupTasks in pairs(sevenDaysTask.tasks) do
		local taskInfo = groupTasks[1]
		if taskInfo.template.tab == tab then
			return groupTasks
		end
	end
	return nil
end

--===========================   have =============================

function SevenDaysManager:isHaveSevenDay()
	for i=1, self.openDays do
		if self:isHaveDay(i) then return true end
	end
	return false
end

function SevenDaysManager:isHaveDay(day)
	local daysTask = self.sevenDayTasks[day]
	if daysTask == nil then return false end

	local tabs = daysTask.tasks
	-- table.sort(tabs, function(t1, t2) return t1[1].template.tab < t2[1].template.tab end)
	for k,v in pairs(tabs) do
		if self:isHaveTabs(day, k) then return true end
	end
	return false
end

function SevenDaysManager:isHaveTabs(day, tab)
	-- if tab == EnumSevenDaysButtonType.XianGou then return false end
	local daysTask = self.sevenDayTasks[day]
	if daysTask == nil then return false end
	local tabs = daysTask.tasks
	-- table.sort(tabs, function(t1, t2) return t1[1].template.tab < t2[1].template.tab end)
	local taskInfos = tabs[tab]

	local flag = false 
	for k,v in pairs(taskInfos) do
		if v and v.state == 1 then
			if v.template.tab ~= EnumSevenDaysButtonType.XianGou then
				return true
			else
				if self.isCheckXianGou[day] then 	-- 为限购时 ： 没有查看过,有剩余,且能买 才会有红点
					return false
				end

				flag = flag or v.currstep ~= 0
			end
		end
	end

	return flag
end

function SevenDaysManager:checkXianGou(day)
	local old = self.isCheckXianGou[day]
	self.isCheckXianGou[day] = true
	return old == nil
end

-- 七天活动按钮类型
-- EnumSevenDaysButtonType = 
-- {
-- 	FuLi		 	 = 1,    --每日福利
-- 	ZhuXian		 	 = 2,    --主线副本
-- 	JinJie  		 = 3, 	 --进阶
-- 	FengShenYanWu 	 = 4, 	 --封神演武
-- 	ShenQi 		 	 = 5, 	 --神器
-- 	JingYing		 = 6,    --精英副本
-- 	ZhuangBei 		 = 7,    --装备
-- 	JianMu 			 = 8, 	 --建木通天
-- 	JingLian 		 = 9, 	 --装备精炼
-- 	GuiShen 		 = 10, 	 --鬼神之塔
-- 	ShengXing 		 = 11, 	 --装备升星
-- 	XiangQian 		 = 12, 	 --装备镶嵌
-- 	BaoShi 			 = 13,   --装备宝石
-- 	ChouQian 		 = 14, 	 --抽签
-- 	TuPo 			 = 15,   --突破
-- 	YueKa			 = 16,   --月卡
-- 	XianGou 		 = 17,	 --限购
-- }

function SevenDaysManager:getButtonNormalImgByType( type )
	local imgType = {}
	if type == EnumSevenDaysButtonType.FuLi then 
		imgType[3] = "ui/activity/img_1_01.png"
		imgType[4] = "ui/activity/img_1_02.png"
	elseif type == EnumSevenDaysButtonType.ZhuXian then
		imgType[3] = "ui/activity/img_2_01.png"
		imgType[4] = "ui/activity/img_2_02.png"
	elseif type == EnumSevenDaysButtonType.JinJie then
		imgType[3] = "ui/activity/img_3_01.png"
		imgType[4] = "ui/activity/img_3_02.png"
	elseif type == EnumSevenDaysButtonType.FengShenYanWu then
		imgType[3] = "ui/activity/img_4_01.png"
		imgType[4] = "ui/activity/img_4_02.png"
	elseif type == EnumSevenDaysButtonType.ShenQi then
		imgType[3] = "ui/activity/img_5_01.png"
		imgType[4] = "ui/activity/img_5_02.png"
	elseif type == EnumSevenDaysButtonType.JingYing then
		imgType[3] = "ui/activity/img_6_01.png"
		imgType[4] = "ui/activity/img_6_02.png"
	elseif type == EnumSevenDaysButtonType.ZhuangBei then
		imgType[3] = "ui/activity/img_7_01.png"
		imgType[4] = "ui/activity/img_7_02.png"
	elseif type == EnumSevenDaysButtonType.JianMu then
		imgType[3] = "ui/activity/img_8_01.png"
		imgType[4] = "ui/activity/img_8_02.png"
	elseif type == EnumSevenDaysButtonType.JingLian then
		imgType[3] = "ui/activity/img_9_01.png"
		imgType[4] = "ui/activity/img_9_02.png"
	elseif type == EnumSevenDaysButtonType.GuiShen then
		imgType[3] = "ui/activity/img_10_01.png"
		imgType[4] = "ui/activity/img_10_02.png"
	elseif type == EnumSevenDaysButtonType.ShengXing then
		imgType[3] = "ui/activity/img_11_01.png"
		imgType[4] = "ui/activity/img_11_02.png"
	elseif type == EnumSevenDaysButtonType.XiangQian then
		imgType[3] = "ui/activity/img_12_01.png"
		imgType[4] = "ui/activity/img_12_02.png"
	elseif type == EnumSevenDaysButtonType.BaoShi then
		imgType[3] = "ui/activity/img_13_01.png"
		imgType[4] = "ui/activity/img_13_02.png"
	elseif type == EnumSevenDaysButtonType.ChouQian then
		imgType[3] = "ui/activity/img_14_01.png"
		imgType[4] = "ui/activity/img_14_02.png"
	elseif type == EnumSevenDaysButtonType.TuPo then
		imgType[3] = "ui/activity/img_15_01.png"
		imgType[4] = "ui/activity/img_15_02.png"
	elseif type == EnumSevenDaysButtonType.YueKa then
		imgType[3] = "ui/activity/img_16_01.png"
		imgType[4] = "ui/activity/img_16_02.png"
	elseif type == EnumSevenDaysButtonType.XianGou then
		imgType[3] = "ui/activity/img_17_01.png"
		imgType[4] = "ui/activity/img_17_02.png"
	else
		imgType[3] = "ui/activity/img_fy_fl01.png"
		imgType[4] = "ui/activity/img_fy_fl02.png"
	end
	imgType[1] = 'ui/common/btn_fy01.png'
	imgType[2] = 'ui/common/btn_fy02.png'
	return imgType
end

function SevenDaysManager:sendQUeryLoginSevenDaysGoalTask(  )
	self.isOpenSevenDaysLoginLay = true
	self:sendWithLoading(c2s.QUERY_LOGIN_SEVEN_DAYS_GOAL_TASK, true)
end

function SevenDaysManager:sendGetLoginSevenDayReward( taskid, day )
	if not taskid then
		taskid = self.loginSevenDaysTaskList[day].taskid
	end
	self:sendWithLoading(c2s.GET_LOGIN_SEVEN_DAYS_GOAL_TASK_REWARD, taskid)
end

function SevenDaysManager:openSevenDaysLoginLayer( on_completed )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.sevendays.SevenDaysLoginLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(on_completed)
	AlertManager:show()
end 

function SevenDaysManager:isHaveSevenDayLogin()
	return self.loginSevenDaysTaskList[1] ~= nil
end

function SevenDaysManager:onReceiveLoginSevenDaysGoalTaskList( event )
	hideLoading()
	self.loginSevenDaysTaskList = {}
	if event.data then
		-- self.loginDay = event.data.days
		for i,task in ipairs(event.data.tasklist) do
			local taskInfo = task.taskInfo
			taskInfo.name = task.name
			taskInfo.taskInfo = SevenDayLoginData:objectByID(taskInfo.taskid)

			self.loginSevenDaysTaskList[task.days] = taskInfo
		end
		CommonUiManager:addActivityIcon(EnumActivityType.LoginSevenDay)

		if self.isOpenSevenDaysLoginLay then
			self.isOpenSevenDaysLoginLay = false
			self:openSevenDaysLoginLayer()
		end
	end
end

function SevenDaysManager:onReceiveGetLoginSevenDaysGoalTaskRewardResult( event )
	if event.data then
		local tasks = event.data.taskid
		local taskMap = {}
		for i,v in ipairs(tasks) do
			taskMap[v] = true
		end

		local isComplete = true
		for i,task in ipairs(self.loginSevenDaysTaskList) do
			if taskMap[task.taskid] then
				task.state = 2
			elseif task.state ~= 2 then
				isComplete = false
			end
		end

		if isComplete then
			CommonUiManager:addActivityIcon(EnumActivityType.LoginSevenDay, true)
		end
		TFDirector:dispatchGlobalEventWith(SevenDaysManager.updateSevenDayLogin, {isComplete = isComplete})
	end
end

function SevenDaysManager:isHaveSevenDayLoginRed(  )
	for i,task in ipairs(self.loginSevenDaysTaskList or {}) do
		if task.state == 1 then
			return true
		end
	end
	return false
end

return SevenDaysManager:new()
