--
-- 组队副本管理类
-- Author: sjj
-- Date: 2017-1-8
--
local BaseManager = require('lua.gamedata.BaseManager')
local TeamMissionManager = class("TeamMissionManager", BaseManager)

print("++++++++++++sjj+++++TeamMissionManager+++++")

function TeamMissionManager:ctor()
	self.super.ctor(self)
end

function TeamMissionManager:init()
	self.super.init(self)
	--TFDirector:addProto(s2c.ARENA_MATCH_RES, self, self.onReceiveArenaMatchRes)--1311
	TeamMissionManager.isOpenTeamMission=true
	TeamMissionManager.teamType=1
end

function TeamMissionManager:restart()--切换账号	
	self:InitVar()		
end

function TeamMissionManager:InitVar()	--变量释放
	--TeamMissionManager.typeMission=nil
	TeamMissionManager.teamType=nil
	TeamMissionManager.curChoiceData=nil--当前选择的表的数据
	--TeamMissionManager.isOpenTeamMission=nil
	
end

--在打开界面前需要知道我当前开启了那些副本
--根据当前的等级或通过的篇章来查看我开了那些副本

-- protocol
function TeamMissionManager:openLayer()
	local Layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.teamMission.TeamMissionMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function TeamMissionManager:openBossLayer()	
	local Layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.teamMission.TeamMissionBZLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()	
end

function TeamMissionManager:OpenTeamInFBLayer(openType)		
	local Layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.teamMission.TeamInFBLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	Layer:loadData(openType)
	AlertManager:show()	
end

return TeamMissionManager:new()

