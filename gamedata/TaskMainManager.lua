-- Created by ZZTENG on 2017/10/18.
--任务主界面管理

local TaskMainManager = class("TaskMainManager", BaseManager)
TaskMainManager.UPDATE_TEAM_TASK = "TaskMainManager.UPDATE_TEAM_TASK"
TaskMainManager.UPDATE_TASK_SHOW = "TaskMainManager.UPDATE_TASK_SHOW"

function TaskMainManager:ctor()
	self.super.ctor(self)
end

function TaskMainManager:init()
    self.super.init(self)
    self.add = 0
    self.taskSubTab = EnumMainTaskTab.TASk
    self.tuoguan = false
    self.state = true 
    self.npc_misstion_state = false
    self.taskData = TFArray:new()
    
    self.updateTeamTaskListen =  function ( event )
        self:updateTeamTask(event)
    end
    TFDirector:addMEGlobalListener(TaskMainManager.UPDATE_TEAM_TASK, self.updateTeamTaskListen)
end

function TaskMainManager:restart()
    -- 清除数据
    self.taskSubTab = EnumMainTaskTab.TASk
    self.tuoguan = false
    self.state = true 
    self.taskData:clear()
end

function TaskMainManager:updateTeamTask(event)
    local target = event.data[1]
    local data
    if target == EnumTeamTask.KILL_DEVIL then
        --伏魔降妖
       data =  RoundTaskManager:getTaskInfo()
       self:setTeamTaskItemClick(data.func)
    end
    data.target = target
    print('uuuuuuuuuuuuuuuuuuuuuuu',data.taskStatus)
    self:addMainTaskData( EnumMainTask.TEAM_TASK,data )
    TFDirector:dispatchGlobalEventWith(TaskMainManager.UPDATE_TASK_SHOW, 0)
end

function TaskMainManager:setTeamTaskItemClick( func )
    self.func = func
end

function TaskMainManager:getTeamTaskItemClick( ... )
   return self.func
end

function TaskMainManager:setOpenState( state )
    self.state = state
end

function TaskMainManager:getOpenState( ... )
    return self.state
end

function TaskMainManager:setTaskSubType( type )
    self.taskSubTab = type
end

function TaskMainManager:getTaskSubType( ... )
    return self.taskSubTab
end

function TaskMainManager:setTuoGuan( tuoguan )
    self.tuoguan = tuoguan
end

function TaskMainManager:getTuoGuan( ... )
    return self.tuoguan
end



--taskType：主面板任务类型，data：任务数据
--例子：    EnumMainTask.MAIN_LINE（主线任务），chapterId（章节id）
--         EnumMainTask.TEAM_TASK(组团任务)，{data暂定}
--         EnumMainTask.GUILD_TASK(公会任务)，任务id
--后续添加
function TaskMainManager:addMainTaskData( taskType,data )
    local newTask = true
    for d in self.taskData:iterator() do
        if d.type == taskType then
            d.data = data
            newTask = false
            break
        end
    end
    if newTask then
        self.taskData:push({type = taskType, data = data})
    end
    local sortFun = function ( a,b )
            return a.type < b.type
    end
    self.taskData:sort(sortFun)
    --[[
    -- print('wwwwwwwqqqq',taskType,data)
    -- self.add = self.add + 1
    local td = {}
    local sameTypeData = nil
    td.type = taskType
    td.data = data
    for d in self.taskData:iterator() do
        if d.type == taskType then
            sameTypeData = d
            break
        end
    end
    local index = self.taskData:indexOf(sameTypeData)
    if index ~= -1 then
        self.taskData:setAt(index,td)
    else
        self.taskData:push(td)
    end
    
    local sortFun = function ( a,b )
            return a.type < b.type
    end
    self.taskData:sort(sortFun)
    ]]
end

function TaskMainManager:getTaskData(taskType)
    if taskType==nil then
        return self.taskData
    else
        for data in self.taskData:iterator() do
            if data.type == taskType then
                return data
            end
        end
    end
    return nil
end

return TaskMainManager:new()