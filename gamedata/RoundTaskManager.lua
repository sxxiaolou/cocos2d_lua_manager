 -- 降妖伏魔管理类
-- Author: sunyunpeng
-- Date: 2017-10-19
--

local RoundTaskManager = class("RoundTaskManager", BaseManager)

RoundTaskManager.RoundTaskReset 	= "RoundTaskManager.RoundTaskReset"
RoundTaskManager.GainRoundTask  	= "RoundTaskManager.GainRoundTask"
RoundTaskManager.RoundTaskTimes 	= "RoundTaskManager.RoundTaskTimes"
RoundTaskManager.GetRoundTaskReward = "RoundTaskManager.GetRoundTaskReward"
RoundTaskManager.RoundTaskUpdate 	= "RoundTaskManager.RoundTaskUpdate"
RoundTaskManager.RoundProReset		= "RoundTaskManager.RoundProReset"
RoundTaskManager.RoundLayerUpdate	= "RoundTaskManager.RoundLayerUpdate"
function RoundTaskManager:ctor()
	self.super.ctor(self)

end

function RoundTaskManager:init()
	self.super.init(self)

	self.roundMsg = {}			--信息列表
	self.taskMsg = {}			--环任务
	self.buyBackMsg = {}		--回购信息	
	self.taskPercentMsg = {}  	--任务进度

	self:registerEvents()
end

function RoundTaskManager:registerEvents()
	-- 降妖伏魔信息列表
	TFDirector:addProto(s2c.ROUND_TASK_LIST, self, self.onRoundTaskList)
	-- 重置环任务进度
	TFDirector:addProto(s2c.ROUND_TASK_RESET, self, self.onRoundTaskReset)
	-- 环任务 
	TFDirector:addProto(s2c.GAIN_ROUND_SUB_TASK, self, self.onGainRoundTask)
	-- 回购信息列表
	TFDirector:addProto(s2c.ROUND_TASK_TIMES, self, self.onRoundTaskTimes)
	--任务进度
	TFDirector:addProto(s2c.ROUND_SUB_TASK_PROCESS, self, self.onRoundTaskProcess)
	--环奖励
	TFDirector:addProto(s2c.GAIN_ROUND_REWARD, self, self.onGainRoundReward)
	--领取任务
	TFDirector:addProto(s2c.GAIN_TASK_NOTIFY, self, self.onGainTaskNotify)
	--交还任务
	TFDirector:addProto(s2c.BACK_TASK_NOTIFY, self, self.onBackTaskNotify)
	self.onCreateTeam = function(events)
		local data = events.data[1]
		if data == EnumTeamTask.KILL_DEVIL then
			self:setTaskStatus(EnumRoundTaskStatus.HAVE_TEAM)
		end 
    end
	TFDirector:addMEGlobalListener(TeamManager.CREATE_TEAM, self.onCreateTeam)

	self.onLeaveTeam = function(events)
		print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrr')
		self:setTaskStatus(EnumRoundTaskStatus.NO_TEAM)
		self:initTaskMsg()
    end
	TFDirector:addMEGlobalListener(TeamManager.LEAVE_TEAM, self.onLeaveTeam)

    --在断线重连时,需要处理下数据
    self.reconnectCallback = function ()  self:onNetReconnect()   end
    TFDirector:addMEGlobalListener(CommonManager.TRY_RECONNECT_NET, self.reconnectCallback)
end

function RoundTaskManager:onNetReconnect()
    print("RoundTaskManager:onNetReconnect")
    self:restart()
end

function RoundTaskManager:getTaskInfo()
	local task = {}

	task.target 				= EnumTeamTask.KILL_DEVIL						--组队任务id
	task.taskStatus 			= self:getTaskStatus()							--任务状态
	task.todayRoundTimes 		= self.roundMsg.todayRoundTimes	or 0			--今日完成环次数	
	task.todayTaskTimes 		= self.roundMsg.curTaskTimes	or 0			--今日完成任务次数
	task.curTaskProcess 		= self.taskPercentMsg.curTaskProcess	or 0	--当前任务进度
	task.curTaskTotalProcess	= self.taskPercentMsg.allTaskProcess	or 0	--当前任务总进度
	task.curRoundProcess		= self.roundMsg.curRoundProcess	or 0			--当前环任务进度
	task.content 				= ""											--当前任务描述
	task.is_complete			= false											--是否达标
	local value = self.roundMsg.weekTimes or 0
	if value >= ConstantData:getValue("ghost.weekly.task") then
		task.is_complete = true
	end
	local taskMsg = self:getTaskMsg()
	-- print("-----=====curTaskMsg", taskMsg)
	-- local chapterId = nil
	-- local posMsg = RoundtaskPosData:objectByID(taskMsg.type)
	-- if posMsg then
	-- 	chapterId = math.floor(posMsg.path_id / 100)
	-- end
	local chapterId = nil
	if task.taskStatus == EnumRoundTaskStatus.NO_TEAM then	--未组队
		task.content = localizable.round_task_create_team
	elseif task.taskStatus == EnumRoundTaskStatus.HAVE_TEAM then	--领取环任务
		task.content = localizable.round_task_start_dis
	elseif task.taskStatus == EnumRoundTaskStatus.ROUND_TASK then	--交环任务
		task.content = localizable.round_task_end_dis
	elseif task.taskStatus == EnumRoundTaskStatus.HAVE_TASK then --接任务
		local typeMsg = RoundtaskTypeData:objectByID(7)
		local typeDesc = typeMsg.desc or ""
		local npcMsg = taskMsg.startNpcMsg
		assert(npcMsg.id~=0,"shengbai!startNpcid is 0" .. npcMsg.id)
		local siteMsg = RoundtaskPosData:objectByID(npcMsg.id)
		local card = RoundtaskNpcData:objectByID(npcMsg.tplId)
		task.content = stringUtils.format(typeDesc,siteMsg.path_name,card.name)
		chapterId = math.floor(siteMsg.path_id / 100)
	elseif  task.taskStatus == EnumRoundTaskStatus.COMPLETE_TASK then --交任务
		local typeMsg = RoundtaskTypeData:objectByID(8)
		local typeDesc = typeMsg.desc or ""
		local npcMsg = taskMsg.endNpcMsg
		
		local siteMsg = RoundtaskPosData:objectByID(npcMsg.id)
		assert(npcMsg.id~=0,"shengbai!endNpcid is 0" .. npcMsg.id .. npcMsg.tplId)
		local card = RoundtaskNpcData:objectByID(npcMsg.tplId)
		task.content = stringUtils.format(typeDesc,siteMsg.path_name,card.name)
		chapterId = math.floor(siteMsg.path_id / 100)
	elseif task.taskStatus == EnumRoundTaskStatus.STATUS_TASK then --做任务

		local percentMsg = self:getTaskPercentMsg()
		local index = percentMsg.curTaskIndex + 1
		if index > percentMsg.allTaskIndex then
			index = percentMsg.allTaskIndex
		end
		-- print("task.taskStatus==============",taskMsg,percentMsg)
		local item = taskMsg.task[index]
		assert(item~=nil,"shengbai! have no task")
		-- print("========================taskMsgtaskMsgtaskMsg",taskMsg)
		local typeMsg = RoundtaskTypeData:objectByID(taskMsg.type)
		local typeDesc = typeMsg.desc or ""
		local siteMsg = RoundtaskPosData:objectByID(item.id)
		if taskMsg.type ~= EnumRoundTaskType.GATHER_TASK then --采集
			chapterId = math.floor(siteMsg.path_id / 100) 
		end
		
		if taskMsg.type == EnumRoundTaskType.GATHER_TASK then --采集
			local template = RoundtaskCollectData:objectByID(item.tplId)
			if template then
				task.content = stringUtils.format(typeDesc,template.path_name,self.taskPercentMsg.allTaskProcess, template.name)  
				chapterId = math.floor(template.path_id / 100) 
			end
		elseif taskMsg.type == EnumRoundTaskType.SEEK_TASK then --寻人
			local template = RoundtaskNpcData:objectByID(item.tplId)
			if template then
				task.content = stringUtils.format(typeDesc,siteMsg.path_name,template.name) 	
			end
		elseif taskMsg.type == EnumRoundTaskType.MONSTER_TASK then --打怪
			local template = RoundtaskMonsterData:objectByID(item.tplId)
			if template then
				local monster = CardData:objectByID(template.card_id)
				local name = monster.name or ""
				task.content = stringUtils.format(typeDesc,siteMsg.path_name,self.taskPercentMsg.allTaskProcess, name)
			end
		elseif taskMsg.type == EnumRoundTaskType.GOODS_TASK then --寻物
			local template = RoundtaskSearchData:objectByID(item.tplId)
			if template then
				local monster = CardData:objectByID(template.card_id)
				local name = monster.name or ""
				task.content = stringUtils.format(typeDesc,siteMsg.path_name,name, template.name)
			end
		elseif taskMsg.type == EnumRoundTaskType.PET_TASK then --捉宠
			local template = RoundtaskPetData:objectByID(item.tplId)
			if template then
				local monster = CardData:objectByID(template.pet_id)
				local name = monster.name or ""
				task.content = stringUtils.format(typeDesc,siteMsg.path_name,self.taskPercentMsg.allTaskProcess, name) 
			end	
		elseif taskMsg.type == EnumRoundTaskType.BOOS_TASK then --沙包
			local template = RoundtaskMonsterData:objectByID(item.tplId)
			if template then
				local monster = CardData:objectByID(template.card_id)
				local name = monster.name or ""
				task.content = stringUtils.format(typeDesc,siteMsg.path_name, name)
			end		
		end
		task.content = task.content .. "(" .. self.taskPercentMsg.curTaskProcess .."/" .. self.taskPercentMsg.allTaskProcess .. ")"
	end
	
	local function func()
		local taskStatus = self:getTaskStatus()
		if taskStatus == EnumRoundTaskStatus.NO_TEAM then
			-- print("++++++++++++click callback:==>SendCreateTeam")
			--创建队伍
			TeamManager:sendCreateTeam()
		elseif taskStatus == EnumRoundTaskStatus.HAVE_TEAM or 
				taskStatus == EnumRoundTaskStatus.ROUND_TASK then
			--跳转到指定的场景 
			local currentScene = Public:currentScene()
		 	local topLayer = currentScene:getTopLayer()
			if currentScene.__cname == "ChallengeScene" then
				if topLayer.__cname == "JiGuanFangLayer" then
					-- print("++++++++++++click callback:==>MoveInChallengeScene")
					MissionManager:setIsJumpChapter( {bool = true, chapterId = EnumJiGuanClickType.JiGuanRoundTask} )
					topLayer:setTargetPos()
				end
			else
				-- print("++++++++++++click callback:==>GoToChallengeScene")
				MissionManager:setIsJumpChapter( {bool = true, chapterId = EnumJiGuanClickType.JiGuanRoundTask} )
				JumpToManager:jumpSceneByname("ChallengeScene",topLayer.mainRolePanel)
			end
		else
			-- print("++++++++++++click callback:==>GoToTaskScene", chapterId)
			--跳转到指定的章节 
			local currentScene = Public:currentScene()
			local topLayer = currentScene:getTopLayer()
			JumpToManager:jumpChapterById(chapterId, topLayer.mainRolePanel)
		end
	end
	task.chapterId = chapterId
	task.func = func
	-- print("===@@@@####task",task)
	return task
end

function RoundTaskManager:restartRoleScene()
	local currentScene = Public:currentScene()
	self.restartRoundTask = true
	if currentScene.__cname ~= "HomeScene" then	
		CommonManager:requestEnterInScene(EnumSceneType.Home)
	end
end

function RoundTaskManager:setTaskStatus(status)
	self.status = status
	TFDirector:dispatchGlobalEventWith(TaskMainManager.UPDATE_TEAM_TASK, EnumTeamTask.KILL_DEVIL)
end

function RoundTaskManager:getTaskStatus()

	return self.status or EnumRoundTaskStatus.NO_TEAM
end

function RoundTaskManager:setRoundTaskLittle()
	if not self.littleRoundTask then
		self.littleRoundTask = {}
	end
	
	if not self.taskMsg.task or not self.taskPercentMsg.curTaskIndex then return nil end

	local taskMsg = nil
	local taskStatus = self:getTaskStatus()
	local func = nil
	local task = self.littleRoundTask
	task.movieId = nil
	task.chapterId = nil
	if taskStatus == EnumRoundTaskStatus.HAVE_TASK then --接任务	
		taskMsg = self.taskMsg.startNpcMsg
		func = function ()
			self:sendRoundTaskReq(true)
		end
		local roundNpcData = RoundtaskNpcData:objectByID(taskMsg.tplId)
		if roundNpcData then
			task.movieId = roundNpcData.start_movie_id
		end

		local siteMsg = RoundtaskPosData:objectByID(taskMsg.id)
		task.chapterId = math.floor(siteMsg.path_id / 100) 
	elseif taskStatus == EnumRoundTaskStatus.COMPLETE_TASK then --交任务
		taskMsg = self.taskMsg.endNpcMsg
		func = function ()
			self:sendRoundTaskReq(false)
		end
		local roundNpcData = RoundtaskNpcData:objectByID(taskMsg.tplId)
		if roundNpcData then
			task.movieId = roundNpcData.end_movie_id
		end

		local siteMsg = RoundtaskPosData:objectByID(taskMsg.id)
		task.chapterId = math.floor(siteMsg.path_id / 100)
	else --做任务
		local index = self.taskPercentMsg.curTaskIndex + 1
		if index > self.taskPercentMsg.allTaskIndex then
			index = self.taskPercentMsg.allTaskIndex
		end

		taskMsg = self.taskMsg.task[index]
		func = function ()
			self:sendLittleRoundTaskReq()
		end	
		local roundNpcData = RoundtaskNpcData:objectByID(taskMsg.tplId)
		if roundNpcData and self.taskMsg.type == EnumRoundTaskType.SEEK_TASK then
			task.movieId = roundNpcData.task_movie_id
		end

		local siteMsg = RoundtaskPosData:objectByID(taskMsg.id)
		if self.taskMsg.type ~= EnumRoundTaskType.GATHER_TASK then --非采集
			task.chapterId = math.floor(siteMsg.path_id / 100) 
		else
			local template = RoundtaskCollectData:objectByID(taskMsg.tplId)
			if template then
				task.chapterId = math.floor(template.path_id / 100) 
			end
		end
	end
	
	local siteMsg = RoundtaskPosData:objectByID(taskMsg.id) 
	if self.taskMsg.type == EnumRoundTaskType.GATHER_TASK and taskStatus == EnumRoundTaskStatus.STATUS_TASK then--采集
		siteMsg = RoundtaskCollectData:objectByID(taskMsg.id)
	end 
	assert(siteMsg)
	if not siteMsg then return nil end

	--chapterPosId 章节位置表Id
	--pos 章节位置表中跳转的pos点
	--name 地图名\
	--tplId 模板Id
	--func 回调方法
	--quality 宠物类型
	--type 任务类型
	
	task.chapterPosId = siteMsg.path_id
	task.name = siteMsg.path_name
	task.pos = taskMsg.pos
	task.tplId = taskMsg.tplId
	task.func = func 
	task.type = self.taskMsg.type
	task.status = taskStatus
	----
	task.pathId = self:getTeamPathId(task.chapterPosId, taskMsg.pos)
	----
	task.xMove = taskMsg.xMove
	task.yMove = taskMsg.yMove
	---- 
	if task.type == EnumRoundTaskType.PET_TASK then	
		local percentMsg = self:getTaskPercentMsg()
		local index = self.taskPercentMsg.curTaskIndex + 1
		if index > self.taskPercentMsg.allTaskIndex then
			index = self.taskPercentMsg.allTaskIndex
		end
		local item = self.taskMsg.task[index]
		if item then 
			local template = RoundtaskPetData:objectByID(item.tplId)
			task.quality = template.quality
			task.division = 1
			if taskStatus ~= EnumRoundTaskStatus.HAVE_TASK and
				taskStatus ~= EnumRoundTaskStatus.COMPLETE_TASK  then --接任务	
				task.tplId = template.pet_id
			end	
		end
	end

	if task.type == EnumRoundTaskType.GATHER_TASK and taskStatus == EnumRoundTaskStatus.STATUS_TASK then
	--  (taskStatus ~= EnumRoundTaskStatus.COMPLETE_TASK and taskStatus ~= EnumRoundTaskStatus.HAVE_TASK) then		
		local template = RoundtaskCollectData:objectByID(taskMsg.tplId)
		if template then
			-- task.chapterId = math.floor(template.path_id / 100) 
			task.chapterPosId = template.path_id
			
			task.pathId = self:getTeamPathId(task.chapterPosId, taskMsg.pos)
			task.tplId = template.pic
			print("===)))))RoundTaskManager2",task.tplId)
		end	
	elseif task.type == EnumRoundTaskType.GOODS_TASK and taskStatus == EnumRoundTaskStatus.STATUS_TASK then
		local template = RoundtaskSearchData:objectByID(taskMsg.tplId)
		if template then
			task.tplId = template.card_id
		end
		-- task.chapterId = math.floor(task.chapterPosId / 100)
	else
		-- task.chapterId = math.floor(task.chapterPosId / 100)
	end

	if task.type == EnumRoundTaskType.BOOS_TASK and taskStatus == EnumRoundTaskStatus.ROUND_TASK then
		task.tplId = nil
	end
	TFDirector:dispatchGlobalEventWith(RoundTaskManager.RoundTaskUpdate, 0)
end

function RoundTaskManager:getTeamPathId(chapterPosId, pos)
	local posData = ChapterPosData:objectByID(chapterPosId)
	if not posData then return nil end
	
	local taskPos = GetTwoSpecilDataByString(posData.task_pos)
	for k,v in pairs(taskPos) do
		if v and v[3] and v[3] == pos then
			return v[1]
		end
	end
	return nil
end

function RoundTaskManager:getRoundTaskLittle()
	return self.littleRoundTask
end

function RoundTaskManager:restart()
	self.status = nil
	self.roundMsg = {}
	self.taskMsg = {}
	self.buyBackMsg = {}
	self.taskPercentMsg = {}
end

--重置本环任务进度
function RoundTaskManager:sendRoundTaskReset()
	self:sendWithLoading(c2s.ROUND_TASK_RESET_REQ, false)
end

--领取环任务
function RoundTaskManager:sendRoundTaskGetTask()
	self:sendWithLoading(c2s.GAIN_ROUND_TASK_REQ, false)
end

--领取环奖励
function RoundTaskManager:sendRoundTaskGetReward()
	self:sendWithLoading(c2s.GAIN_ROUND_TASK_REWARD, false)
end

--回购
function RoundTaskManager:sendRoundTaskHuiGou()
	self:sendWithLoading(c2s.ROUND_TASK_BUY_BACK, false)
end

--回购次数
function RoundTaskManager:sendRoundTaskTimes(times)
	self:sendWithLoading(c2s.ROUND_TASK_BUY_BACK_TIMES, times)
end

--交接任务
function RoundTaskManager:sendRoundTaskReq(is_bool)
	self:sendWithLoading(c2s.GET_ROUND_SUB_TASK_REQ, is_bool)
end

--子任务完成
function RoundTaskManager:sendLittleRoundTaskReq()
	self:sendWithLoading(c2s.LITTLE_ROUND_TASK_REQ , false)
end

--
function RoundTaskManager:onRoundTaskReset(event)
	hideLoading()
	local data = event.data or {}
	if not data then return end

	self.roundMsg.curRoundProcess = data.times

	TFDirector:dispatchGlobalEventWith(RoundTaskManager.RoundProReset, nil)
end

function RoundTaskManager:onRoundTaskList(event)
	hideLoading()

	local data = event.data or {}
	if not data then return end
	
	-- print("==onRoundTaskList==",data)
	self.roundMsg.weekTimes 			= data.weekTimes		--本周完成任务次数
	self.roundMsg.weekRoundTimes 		= data.weekRoundTimes	--本周完成环次数
	self.roundMsg.curTaskTimes 			= data.curTaskTimes		--今日完成任务次数
	self.roundMsg.todayRoundTimes 		= data.todayRoundTimes	--今日完成环次数	
	self.roundMsg.curRoundProcess 		= data.curRoundProcess	--当前环任务进度
	if not self.status then
		print('eeeeeeeeeeeeeeeeeeee')
		self:setTaskStatus(EnumRoundTaskStatus.NO_TEAM)
	end

	TFDirector:dispatchGlobalEventWith(RoundTaskManager.RoundLayerUpdate, nil)
end

function RoundTaskManager:onGainRoundTask(event)
	hideLoading()
	local data = event.data or {}
	if not data then return end
	print("-------------当前任务------------------")
	print("-------------当前任务------------------")
	print("-------------当前任务------------------")
	print("==onGainRoundTask==",data)
	print("-------------当前任务------------------")
	print("-------------当前任务------------------")
	print("-------------当前任务------------------")
	self.taskMsg.type			= data.type					--任务类型
	self.taskMsg.startNpcMsg 	= data.startNpcMsg or {}	--接npc
	self.taskMsg.task 			= data.task	or {}			--任务
	self.taskMsg.endNpcMsg   	= data.endNpcMsg or {}		--交npc

	TFDirector:dispatchGlobalEventWith(RoundTaskManager.GainRoundTask, nil)
end

function RoundTaskManager:onRoundTaskProcess(event)
	hideLoading()
	local data = event.data or {}
	if not data then return end
	
	print("==============任务进度====================")
	print("==============任务进度====================")
	print("==============任务进度====================")
	print("==roundTaskProcess==", data)
	print("==============任务进度====================")
	print("==============任务进度====================")
	print("==============任务进度====================")
	self.taskPercentMsg.curTaskIndex 		= data.curTaskIndex			--当前任务序列
	self.taskPercentMsg.allTaskIndex 		= data.allTaskIndex			--当前任务总序列
	self.taskPercentMsg.curTaskProcess 		= data.curTaskProcess		--当前任务进度
	self.taskPercentMsg.allTaskProcess 		= data.allTaskProcess		--当前任务总进度
	self.taskPercentMsg.taskState			= data.taskState			--0未接取 1已接取未完成 2已完成
	self.taskPercentMsg.isReward			= data.isReward
	if self.taskPercentMsg.taskState == 0 then
		self:setTaskStatus(EnumRoundTaskStatus.HAVE_TASK)
	elseif self.taskPercentMsg.taskState == 1 then
		self:setTaskStatus(EnumRoundTaskStatus.STATUS_TASK)
	elseif self.taskPercentMsg.taskState == 2 then
		if self.taskMsg.type == EnumRoundTaskType.BOOS_TASK then
			if self.taskPercentMsg.isReward then
				self:setTaskStatus(EnumRoundTaskStatus.ROUND_TASK)
			else
				self:setTaskStatus(EnumRoundTaskStatus.HAVE_TEAM)
			end
		else
			self:setTaskStatus(EnumRoundTaskStatus.COMPLETE_TASK)
		end	
	end

	self:onTipsTaskProcess()

	self:setRoundTaskLittle()
end

function RoundTaskManager:onTipsTaskProcess()
	if not self.taskPercentMsg.curTaskProcess or self.taskPercentMsg.curTaskProcess == 0 then return end
	local curTaskProcess = self.taskPercentMsg.curTaskProcess
	local allTaskProcess = self.taskPercentMsg.allTaskProcess
	if self.taskMsg.type == EnumRoundTaskType.GATHER_TASK then --采集
		toastMessage(stringUtils.format(localizable.pet_roundTask_tips[3],curTaskProcess,allTaskProcess))
	elseif self.taskMsg.type == EnumRoundTaskType.SEEK_TASK then --寻人
		toastMessage(localizable.pet_roundTask_tips[1])
	elseif self.taskMsg.type == EnumRoundTaskType.PET_TASK then --捉宠
		toastMessage(stringUtils.format(localizable.pet_roundTask_tips[4],curTaskProcess,allTaskProcess))
	-- elseif self.taskMsg.type == EnumRoundTaskType.GOODS_TASK then --寻物
		-- toastMessage(stringUtils.format(localizable.pet_roundTask_tips[2],curTaskProcess,allTaskProcess))
	end
end

function RoundTaskManager:onRoundTaskTimes(event)
	hideLoading()
	local data = event.data or {}
	if not data then return end

	self.buyBackMsg.taskTimes 			= data.taskTimes			--上周未完成任务数
	self.buyBackMsg.roundTimes 			= data.roundTimes			--上周未完成环数
	self.buyBackMsg.completeRoundTimes 	= data.completeRoundTimes	--完成环数
	self.buyBackMsg.completeTaskTimes 	= data.completeTaskTimes	--完成任务数
end

function RoundTaskManager:onGainRoundReward(event)
	hideLoading()
	self:setTaskStatus(EnumRoundTaskStatus.HAVE_TEAM)
	-- self:initTaskMsg()
	TFDirector:dispatchGlobalEventWith(RoundTaskManager.GetRoundTaskReward, nil)
end


function RoundTaskManager:initTaskMsg()
	self.taskPercentMsg.curTaskIndex 		= 0		--当前任务序列
	self.taskPercentMsg.allTaskIndex 		= 0		--当前任务总序列
	self.taskPercentMsg.curTaskProcess 		= 0		--当前任务进度
	self.taskPercentMsg.allTaskProcess 		= 0		--当前任务总进度
	self.taskPercentMsg.taskState			= 0
end

--领取任务
function RoundTaskManager:onGainTaskNotify(event)
	local curTimes = self.roundMsg.curRoundProcess or 0
	local str = stringUtils.format(localizable.round_task_gain_task, curTimes,10)
	toastRichMessage(str)
end

--交还任务
function RoundTaskManager:onBackTaskNotify(event)
	local curTimes = self.roundMsg.curRoundProcess or 0
	local str = stringUtils.format(localizable.round_task_back_task, curTimes,10)
	toastRichMessage(str)
end


--信息列表
function RoundTaskManager:getRoundMsg()
	return self.roundMsg
end

--环任务
function RoundTaskManager:getTaskMsg()
	return self.taskMsg
end

--任务进度
function RoundTaskManager:getTaskPercentMsg()
	return self.taskPercentMsg
end

function RoundTaskManager:openRunMainLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.runtask.RunMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

function RoundTaskManager:openReBuyLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.runtask.ReBuyLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

function RoundTaskManager:isHaveRedPoint()
	local is_can = JumpToManager:isCanJump(FunctionManager.ChallengeAdventure)
	local value = ConstantData:getValue("ghost.everyday.task")
	if is_can and self.roundMsg and self.roundMsg.curTaskTimes and self.roundMsg.curTaskTimes < value then return true end
	return false
end
return RoundTaskManager:new()