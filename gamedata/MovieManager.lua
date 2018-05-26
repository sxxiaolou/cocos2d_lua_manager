--[[
******剧情管理类*******

	-- by Tony
	-- 2016/11/29
]]

local BaseManager = require('lua.gamedata.BaseManager')
local MovieManager = class("MovieManager", BaseManager)

local LogicWorld = require("lua.logic.battle.world.LogicWorld")
local tGetTriggerFunction = require('lua.gamedata.TriggerFunction')

local MovieScriptData			= require('lua.design.t_s_movie_script') 		--剧情脚本
local MovieStageData 			= require('lua.design.t_s_stage_dial') 			--剧情
local MovieStageStepData 		= require('lua.design.t_s_stage_dial_step') 		--剧情步骤


MovieManager.BATTLE_SATRT 		= "MovieManager.BATTLE_SATRT"
MovieManager.NEXT_MOVE 			= "MovieManager.NEXT_MOVE"
MovieManager.MOVIE_FINISH       = "MovieManager.MOVIE_FINISH"

local tTriggerCondition = 
{
	"start",
	"finish",
	"turn",
	"deadId",
	"move",
}

local tTriggerFunctions = {
	["movieStep"]		= tGetTriggerFunction.getMovieStep,				--当前剧情步骤
	["maxMovieStep"]    = tGetTriggerFunction.getMaxMovieStep,
	["step"]    		= tGetTriggerFunction.getStep, 			--当前新手引导步骤   
	["maxStep"]         = tGetTriggerFunction.getMaxStep,
	["team"] 			= tGetTriggerFunction.getTeam,
}

function MovieManager:ctor(data)
	self.super.ctor(self)
end

function MovieManager:init()
	self.super.init(self)

	self:restart()
end

function MovieManager:restart()
	self:guideRestart()
	self.forbidSkill = false
end

function MovieManager:guideRestart()
	self.action_step = 1
	self.movieActions = nil
	self.movieStageData = nil
	self.inBattle = false
	self.callFun = nil
	self.target = nil
	self.tempUnlock = nil

	self.functionId = nil
	self.dispatchEvent_next = false
end

function MovieManager:initMovie()
	self.movieGuideData = {}
	for movie in MovieStageData:iterator() do
		if movie and not self:isMovieFunctionOpen(movie.id) then
			table.insert(self.movieGuideData, movie)
		end
	end
end

function MovieManager:removeMovie(id)
	local movie = MovieStageData:objectByID(id)
	if movie == nil then
		return
	end
	if self.movieGuideData ~= nil then
		for k, movie in pairs(self.movieGuideData) do
			if movie and movie.missionId == id then
				table.remove(self.movieGuideData, k)
				return
			end
		end
	end
end

function MovieManager:triggerMovieCondition(movie)
	if not movie.conditions then return true end
	
	-- print("movie.conditions  : ", movie.conditions, movie)
	for i,v in pairs(tTriggerFunctions) do
		-- print("triggerGuide i:", i, "-------", TFFunction.call(v, nil, movie.conditions))
		if not TFFunction.call(v, nil, movie.conditions) then
			return false
		end
	end
	return true
end

function MovieManager:triggerMovie(func)
	if self.movieGuideData == nil then self:initMovie() end
	for _, movie in pairs(self.movieGuideData) do
		-- print("########## =----  ", self:isMovieFunctionOpen(movie.id), self:triggerMovieCondition(movie))
		if movie and not self:isMovieFunctionOpen(movie.id) and self:triggerMovieCondition(movie) and func(movie) then
			return movie
		end
	end
end

function MovieManager:guideBattle(missionId)
	if PlayerGuideManager.bOpenGuide == false then return 0 end
	if MissionManager:getStarLevelByMissionId(1001005) ~= 0 then
		return 0
	end
	local guide_missionId = {4003, 0,0,1001003,0,0}
	for k,v in pairs(guide_missionId) do
		if v == missionId then
			local starLevel = MissionManager:getStarLevelByMissionId(missionId)
			if starLevel == 0 then
				return tonumber(k)
			end
			break
		end
	end
	return 0
end

function MovieManager:guideForbidSkill()
	if PlayerGuideManager.bOpenGuide == false then
		return false
	end
	if self.tempUnlock ~= nil and self.tempUnlock == true then
		return false
	end
	return self.forbidSkill
end

function MovieManager:_updateForbidState(forbid)
	if forbid == nil then
		return
	end
	if forbid == 0 then
		self.forbidSkill = false
	else
		self.forbidSkill = true
	end
end

--  新手引导 战斗开始
function MovieManager:battleStart(missionId)
	self:restart()
	self.dispatchEvent_next = true
	self.forbidSkill = MovieManager:guideBattle(missionId) ~= 0 and true or false
	for v in MovieStageData:iterator() do
		if not self:isMovieFunctionOpen(v.id) and v.missionId == missionId and v.turn and 0 == v.turn then
			self.movieStageData = v
			self:_updateForbidState(v.forbid)
			self.functionId = v.id
			self:doDialInit(v.process)
			return
		end
	end
	self:dialFinish()
end

-- 第几次出手结束
function MovieManager:moveEnd(missionId, curMove)
	self.dispatchEvent_next = true
	for v in MovieStageData:iterator() do
		if not self:isMovieFunctionOpen(v.id) and v.missionId == missionId and curMove and v.move and curMove == (v.move - 1) then
			self.movieStageData = v
			self:_updateForbidState(v.forbid)
			self.functionId = v.id
			self:doDialInit(v.process)
			return
		end
	end
	self:dialFinish()
end

--主城对话
--通过某关卡第一次回到主城触发
function MovieManager:triggerMenuMoive()
	if PlayerGuideManager.bOpenGuide == false or self.functionId then return end
	local function menuMovie(movie)
		if movie.trigger_layer == "MenuLayer" and not movie.start and not movie.finish
			and not movie.deadId and not movie.turn and not movie.move then
			local mission = MissionManager:findMission(movie.missionId)
			if mission and mission.starLevel > 0 then
				return true
			end
		end
		return false
	end

	local movie = self:triggerMovie(menuMovie)
	if movie == nil then
		self:dialFinish()
		return
	end

	self.functionId = movie.id
	if movie.script and movie.script == 1 then
		self:doMovie(movie.process)
	else
		self:doDialInit(movie.process)
	end
end

function MovieManager:saveTriggerMissionMoive(chapterId)
	if PlayerGuideManager.bOpenGuide == false or self.functionId then return end
	if FightManager.isReplayFight == true then return end
	if self.target and self.callFun then return end
	local function missionMovie(movie)
		local mChapterId = movie.chapterId
		if mChapterId == nil then
			local mission = MissionData:objectByID(movie.missionId)
			mChapterId = mission and mission.chapter or nil
		end
		if movie.trigger_layer == "MissionLayer" and mChapterId and mChapterId == chapterId and not movie.start and not movie.finish
			and not movie.deadId and not movie.turn and not movie.move then
			local mission = MissionManager:findMission(movie.missionId)
			if mission and mission.starLevel > 0 then
				return true
			end
		end
		return false
	end
	local movie = self:triggerMovie(missionMovie)
	if movie == nil then return end
	self:saveMovieFunctionOpen(movie.id)
end

--关卡对话
--通过某关起第一次回到关卡界面触发
function MovieManager:triggerMissionMoive(chapterId, target, func)
	if PlayerGuideManager.bOpenGuide == false or self.functionId then
		TFFunction.call(func, target)
		return
	end
	if FightManager.isReplayFight == true then return end
	if self.target and self.callFun then return end
	local function missionMovie(movie)
		local mChapterId = movie.chapterId
		if mChapterId == nil then
			local mission = MissionData:objectByID(movie.missionId)
			mChapterId = mission and mission.chapter or nil
		end
		if movie.trigger_layer == "MissionLayer" and mChapterId and mChapterId == chapterId and not movie.start and not movie.finish
			and not movie.deadId and not movie.turn and not movie.move then
			local mission = MissionManager:findMission(movie.missionId)
			if mission and mission.starLevel > 0 then
				return true
			end
		end
		return false
	end

	self.target = target
	self.callFun = func
	local movie = self:triggerMovie(missionMovie)
	if movie == nil then
		self:dialFinish()
		return
	end

	self.functionId = movie.id
	if movie.script and movie.script == 1 then
		self:doMovie(movie.process)
	else
		self:doDialInit(movie.process)
	end
end

--进入某章节触发  
function MovieManager:triggerChapterMoive(chapterId, pathId, target, func)
	if self.target and self.callFun then return end
	if self.functionId then
		TFFunction.call(func, target)	
		return
	end
	local function missionMovie(movie)
		local mChapterId = movie.chapterId
		if mChapterId == nil then
			return false
		end
		if movie.trigger_layer == "MissionLayer" and (not movie.pathId or (pathId and movie.pathId == pathId)) 
			and mChapterId and mChapterId == chapterId and not movie.start and not movie.finish
			and not movie.deadId and not movie.turn and not movie.move then
			return true
		end
		return false
	end

	self.target = target
	self.callFun = func
	local movie = self:triggerMovie(missionMovie)
	if movie == nil then
		self:dialFinish()
		return
	end

	self.functionId = movie.id
	if movie.script and movie.script == 1 then
		self:doMovie(movie.process)
	else
		self:doDialInit(movie.process)
	end
end

function MovieManager:triggerBattleStartMovie(missionId, target, func)
	if PlayerGuideManager.bOpenGuide == false or self.functionId then
		TFFunction.call(func, target)
		return 
	end
	if self.target and self.callFun then return end
	local function startMovie(movie)
		if movie.missionId == missionId and movie.start and movie.start == 1 then
			return true
		end
		return false
	end
	self.target = target
	self.callFun = func
	local movie = self:triggerMovie(startMovie)
	if movie == nil then
		self:dialFinish()
		return
	end
	self.functionId = movie.id
	if movie.script and movie.script == 1 then
		self:doMovie(movie.process)
	else
		self:doDialInit(movie.process)
	end
end

--战斗中对话 0回合
function MovieManager:triggerBattleTurnZeroMovie(missionId, target, func)
	if PlayerGuideManager.bOpenGuide == false or self.functionId then
		TFFunction.call(func, target)
		return
	end

	if self.target and self.callFun then return end
	local function turnZeroMovie(movie)
		if movie.missionId == missionId and movie.turn ~= nil and movie.turn == 0 then
			return true
		end
		return false
	end
	local movie = self:triggerMovie(turnZeroMovie)
	if movie == nil then
		TFFunction.call(func, target)
		return
	end
	
	self.target = target
	self.callFun = func
	--战斗暂停
	FightManager:logicPause()
	self.inBattle = true
	self.functionId = movie.id
	self:doDialInit(movie.process)
end

--战斗中某回合对话
--某战斗关卡ID，第N回合触发  1一回合结束 
function MovieManager:triggerBattleTurnMovie(missionId, turn)
	if PlayerGuideManager.bOpenGuide == false or turn == 0 or self.functionId then
		return
	end

	local function turnMovie(movie)
		if movie.missionId == missionId and turn ~= nil and movie.turn ~= nil and movie.turn == turn then
			return true
		end
		return false
	end

	local movie = self:triggerMovie(turnMovie)
	if movie == nil then
		-- self:dialFinish()
		return
	end

	--战斗暂停
	FightManager:logicPause()
	self.inBattle = true
	self.functionId = movie.id
	self:doDialInit(movie.process)
end

--战后对话
function MovieManager:triggerBattleEndMovie(missionId, target, func)
	if PlayerGuideManager.bOpenGuide == false or self.functionId then
		TFFunction.call(func, target)
		return
	end
	if self.target and self.callFun then return end
	local function endMovie(movie)
		if movie.missionId == missionId and movie.finish and movie.finish == 1 then
			return true
		end
		return false
	end

	self.target = target
	self.callFun = func
	local movie = self:triggerMovie(endMovie)
	if movie == nil then
		self:dialFinish()
		return
	end

	--战斗暂停
	FightManager:logicPause()
	self.inBattle = true
	self.functionId = movie.id
	if movie.script and movie.script == 1 then
		self:doMovie(movie.process)
	else
		self:doDialInit(movie.process)
	end
end

--打死某ID怪物对话
--某战斗关卡ID， 打死某ID怪物触发
function MovieManager:triggerBattleDeadMovie(missionId, actorDead)
	if PlayerGuideManager.bOpenGuide == false or self.functionId then return end
	local deadActor = LogicWorld:getActor(actorDead.deadActorPos)
	if deadActor == nil then return false end
	local deadId = deadActor.actorAttr.baseCard.id
	local function deadMovie(movie)
		if movie.missionId == missionId and movie.deadId and deadId and movie.deadId == deadId then
			return true
		end
		return false
	end

	local movie = self:triggerMovie(deadMovie)
	if movie == nil then
		-- self:dialFinish()
		return
	end

	--战斗暂停
	FightManager:logicPause()
	self.inBattle = true
	self.functionId = movie.id
	self:doDialInit(movie.process)
end

function MovieManager:getMovieStageDataById(id)
	if not id then return nil end
	return MovieStageData:objectByID(id)
end

function MovieManager:setFunctionId(functionId)
	self.functionId = functionId
end

function MovieManager:getFunctionId()
	return self.functionId
end

function MovieManager:doMovie(process)
	print("========== MovieManager:doMovie(process) ============", process)
	local moiveInfo = MovieScriptData:objectByID(process)
	self.moiveLayer = require("lua.logic.movie.MovieLayer"):new(moiveInfo)
	self.moiveLayer:setZOrder(200)

	local curScene = Public:currentScene()
	self.moiveLayer.logic = self
	curScene:addLayer(self.moiveLayer)
	self.moiveLayer:initMovieScript()

	--一键托管
	TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyEnter, nil)
end

function MovieManager:movieEnd()
	if self.moiveLayer then
		self.moiveLayer:stopAllTimer()
		self:removeSceneLayer(self.moiveLayer, true)
		self.moiveLayer = nil
	end

	self:dialFinish()
end

function MovieManager:doDialInit(stepId)
	local movieStep = MovieStageStepData:objectByID(stepId)
	if not movieStep then 
		self:dialFinish()
		return
	end
	self.movieActions = movieStep.actions
	self.action_step = 1
	self:doDial()
end

function MovieManager:doDial()
	print("=== MovieManager:doDial() ===============")
	local curScene = Public:currentScene()
	if self.dial_layer == nil then
		self.dial_layer = require("lua.logic.movie.MovieTipLayer"):new()
		self.dial_layer:setZOrder(1001)
		self.dial_layer.logic = self
		curScene:addLayer(self.dial_layer)
		self.dial_layer:retain()
	else
		self:removeSceneLayer(self.dial_layer, false)
		self.dial_layer:stopAllTimer()
		curScene:addLayer(self.dial_layer)
	end
	local script = self.movieActions[self.action_step]
	self.dial_layer:setVisible(true)
	self.dial_layer:showTip(script)

	--一键托管
    TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyEnter, nil)
end

function MovieManager:dialTouchEnd(isVisible)
	if self.movieActions == nil then return end
	self.action_step = self.action_step + 1

	self.dial_layer:setVisible(isVisible or false)
	self.dial_layer:stopAllTimer()
	self:removeSceneLayer(self.dial_layer, false)
	if self.action_step <= #self.movieActions then
		self:doDial()
	else
		self:dialFinish()
	end
end

function MovieManager:skipSaveStat()
	if self.movieActions == nil or self.action_step >= #self.movieActions then return end
	for i=self.action_step+1, #self.movieActions do
		local script = self.movieActions[i]
		if script and script.stat then
			MainPlayer:skipSaveStatRecord(script.stat)
		end
	end
end

function MovieManager:dialFinish()
	print("==== MovieManager:dialFinish ", self.functionId)
	self:skipSaveStat()
	local functionId = self.functionId
	if functionId then
		self:saveMovieFunctionOpen(self.functionId)
	end

	if self.dial_layer then
		self.dial_layer:setVisible(false)
		self.dial_layer:release()
		self:removeSceneLayer(self.dial_layer, true)
		self.dial_layer = nil
	end

	if self.inBattle then
		FightManager:logicResume()
		--TFDirector:dispatchGlobalEventWith("BattleCoreMgr.FORWARD")
	end

	if self.target and self.callFun then
		TFFunction.call(self.callFun, self.target)
		self.target = nil
		self.callFun = nil
	end

	if self.movieStageData and self.movieStageData.firstEnd and self.movieStageData.firstEnd ~= 0 then
		self:triggerFirstEnd()
	elseif self.movieStageData and self.movieStageData.guideStep and self.movieStageData.guideStep ~= 0 then
		self:triggerGuide()
	elseif self.dispatchEvent_next then
		self:dispatchMoveEvent()
	else
		self:restart()
	end

	if functionId then
		PlayerGuideManager:doGuide()
		--一键托管     
    	TFDirector:dispatchGlobalEventWith(MissionManager.OneKeyEnter, nil)
    	TFDirector:dispatchGlobalEventWith(MovieManager.MOVIE_FINISH, functionId)
	end
end

function MovieManager:triggerFirstEnd()
	if self.movieStageData == nil or (self.movieStageData and self.movieStageData.missionId ~= 4003) then
		return
	end

	local function _endFight()
		self:restart()
		FightManager:changeCreatePlayer()
	end

	MovieManager:triggerBattleEndMovie(4003, self, _endFight)
end

function MovieManager:triggerGuide()
	local guideStepInfo = PlayerGuideStepData:objectByID(self.movieStageData.guideStep)
	if not guideStepInfo then
		self:dispatchMoveEvent(guideStepInfo)
		return
	end
	MainPlayer:saveStatRecord(guideStepInfo.stat)
	if self.dispatchEvent_next then
		if guideStepInfo.force and guideStepInfo.force == 1 then
			self:movieAddForceGuide(guideStepInfo)
		elseif guideStepInfo then
			self:movieAddGuide(guideStepInfo)
		else
			self:dispatchMoveEvent(guideStepInfo)
		end
	end
end

---======================================  剧情中添加强制新手引导部分

function MovieManager:dispatchMoveEvent(guideStepInfo)
	local actor = nil
	if guideStepInfo then
		local targetPos = guideStepInfo.targetPos
		actor = LogicWorld:getUnit(targetPos)
		if actor ~= nil then
			actor:setSkillStatus(ESkillStatus.ACTIVE)
		end
	end

	print("========================== move event")
	self:guideRestart()
	TFDirector:dispatchGlobalEventWith(MovieManager.NEXT_MOVE, actor)
end

function MovieManager:movieAddGuide(guideStepInfo)
	local delay = guideStepInfo.delay or 2

	local topLayer = PlayerGuideManager:getTopLayer()
	if topLayer == nil then
		if self.dispatchEvent_next then
			self:dispatchMoveEvent(guideStepInfo)
		end
		return
	end
	if self.guideTimer then
		TFDirector:removeTimer(self.guideTimer)
		self.guideTimer = nil
	end

	if guideStepInfo.sound and guideStepInfo.sound ~= "" then
		PlayerGuideManager:playEffect(guideStepInfo.sound, guideStepInfo.soundTime*1000)
	end

	if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
		local widget = PlayerGuideManager:getWidgetByName(topLayer, guideStepInfo.widget_name)
		if widget then
			local clickHandleFunction = widget:getMEListener(TFWIDGET_CLICK)
			if clickHandleFunction then
				local function onWidgetClick(sender)
					if topLayer.guidePanel_bg then
						topLayer.guidePanel_bg:removeFromParent()
						topLayer.guidePanel_bg = nil
					end
					if self.guideTimer then
						TFDirector:removeTimer(self.guideTimer)
						self.guideTimer = nil
					end
					FightManager:logicResume()
					widget:addMEListener(TFWIDGET_CLICK, clickHandleFunction)
					TFFunction.call(clickHandleFunction, widget)
				end

				local delay = guideStepInfo.delay or 2
				self.guideTimer = TFDirector:addTimer(delay*1000, 1, nil,
				function ()
					if topLayer.guidePanel_bg then
						topLayer.guidePanel_bg:removeFromParent()
						topLayer.guidePanel_bg = nil
					end
					if self.guideTimer then
						TFDirector:removeTimer(self.guideTimer)
						self.guideTimer = nil
					end
					FightManager:logicResume()
					widget:addMEListener(TFWIDGET_CLICK, clickHandleFunction)
				end)

				local guidePanel_bg = PlayerGuideManager:getGuidePanelBg()
				topLayer:addChild(guidePanel_bg)
				topLayer.guidePanel_bg = guidePanel_bg
				PlayerGuideManager:showEffect(guidePanel_bg, guideStepInfo)
				widget:addMEListener(TFWIDGET_CLICK, onWidgetClick)
			end
		end
	end
	if self.dispatchEvent_next then
		self:dispatchMoveEvent(guideStepInfo)
	end
end

function MovieManager:movieAddForceGuide(guideStepInfo)
	local topLayer = PlayerGuideManager:getTopLayer()
	if topLayer == nil then
		if self.dispatchEvent_next then
			self:dispatchMoveEvent(guideStepInfo)
		end
		return
	end
	local guidePanel_bg = PlayerGuideManager:getGuidePanelBg()
	topLayer:addChild(guidePanel_bg)
	topLayer.guidePanel_bg = guidePanel_bg
	PlayerGuideManager:showForceLayer(guidePanel_bg, guideStepInfo)
	PlayerGuideManager:showEffect(guidePanel_bg, guideStepInfo)

	if guideStepInfo.sound and guideStepInfo.sound ~= "" then
		PlayerGuideManager:playEffect(guideStepInfo.sound, guideStepInfo.soundTime*1000)
	end

	if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
		local widget = PlayerGuideManager:getWidgetByName(topLayer, guideStepInfo.widget_name)
		if widget then
			local clickHandleFunction = widget:getMEListener(TFWIDGET_CLICK)
			if clickHandleFunction and topLayer and topLayer.guidePanel_bg then
				local function onWidgetClick(sender)
					if topLayer.guidePanel_bg then
						topLayer.guidePanel_bg:removeMEListener(TFWIDGET_CLICK)
						topLayer.guidePanel_bg:removeFromParent()
						topLayer.guidePanel_bg = nil
					end
					FightManager:logicResume()
					--widget:addMEListener(TFWIDGET_CLICK, clickHandleFunction)
					TFFunction.call(clickHandleFunction, widget)
					self.tempUnlock = nil
					if self.dispatchEvent_next then
						self:dispatchMoveEvent(guideStepInfo)
					end
				end
				self.tempUnlock = true
				--widget:addMEListener(TFWIDGET_CLICK, onWidgetClick)
				topLayer.guidePanel_bg:addMEListener(TFWIDGET_CLICK, onWidgetClick)
			end
		end
	end
end

function MovieManager:saveMovieFunctionOpen(functionId)
	if self:isMovieFunctionOpen(functionId) then
		return
	end

	self:removeMovie(functionId)

	--发送服务器保存
	MainPlayer:sendRequestGuideRecord(functionId)

	-- CCUserDefault:sharedUserDefault():setStringForKey("player_guide",MainPlayer.guideList)
	-- CCUserDefault:sharedUserDefault():flush()
end

function MovieManager:isMovieFunctionOpen(functionId)
	return MainPlayer:isGuideFunctionOpen(functionId)
end

function MovieManager:isMovie()
	if self.dial_layer then
		return true
	end
	if self.moiveLayer then
		return true
	end
	if self.functionId then
		return true
	end
	return false
end

function MovieManager:resetMovie()
	self:restart()
	if self.moiveLayer and not tolua.isnull(self.moiveLayer) then
		self.moiveLayer:stopAllTimer()
		self:removeSceneLayer(self.moiveLayer, true)
	end
	if self.dial_layer and not tolua.isnull(self.dial_layer) then
		self.dial_layer:setVisible(false)
		self.dial_layer:release()
		self:removeSceneLayer(self.dial_layer, true)
	end
	self.moiveLayer = nil
	self.dial_layer = nil
	self.functionId = nil
end

function MovieManager:getCurGuideStep()
	if self.movieStageData == nil then return 0 end
	return self.movieStageData.guideStep or 0
end

function MovieManager:removeSceneLayer(layer, isDispose)
	local curScene = Public:currentScene()
	if curScene then
		curScene:removeLayer(layer, isDispose)
	end
end

function MovieManager:firstBattleSkipMovie()
	if MainPlayer:getPlayerId() ~= "" or MainPlayer:getName() ~= "" then return end

	local isSkip = false
	local movieIds = {1001,1002,1003,1004,1005,1006,1007}
	for _,v in pairs(movieIds) do
		local stageData = self:getMovieStageDataById(v)
		if stageData and stageData.process and not self:isMovieFunctionOpen(stageData.id) then
			isSkip = true
			self:saveMovieFunctionOpen(stageData.id)
			local stepData = MovieStageStepData:objectByID(stageData.process)
			if stepData and stepData.actions then
				for _, step in pairs(stepData.actions) do
					MainPlayer:skipSaveStatRecord(step.stat)
				end
			end
		end
	end
	if isSkip then
		local uiLayer = TFDirector:currentScene().fightUiLayer
		if uiLayer and uiLayer.firstSkipBtn then uiLayer.firstSkipBtn:setVisible(false) end
		self:resetMovie()
		FightManager:skip()
	end
end

return MovieManager:new()