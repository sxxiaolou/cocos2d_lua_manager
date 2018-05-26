--
-- Author: Jing
-- Date: 2016-05-26
--

local LogicWorld = require("lua.logic.battle.world.LogicWorld")
local LogicWorldCopy = require("lua.logic.battle.render.LogicWorldCopy")
local ActorViewMgr = require("lua.logic.battle.render.ActorViewMgr")
local BattleCoreMgr = require("lua.logic.battle.core.BattleCoreMgr")
local BattleAI = require("lua.logic.battle.ai.BattleAI")
local BattleCount = require("lua.logic.battle.util.BattleCount")

local BaseManager = require('lua.gamedata.BaseManager')
local FightManager = class("FightManager", BaseManager)

FightManager.FIGHT_DISPOSE = "FightManager.FIGHT_DISPOSE"

function FightManager:ctor()
	self.fightSpeed = BattleSpeed.LEVEL_A
	self.fightSpeedBp = self.fightSpeed
	self.isAutoFight = false
	self.isMissionFight = false
	self.shapeShiftPos = nil
	self.maxTurnNum = 10
	self.nCurrTurn = 0
	self.nCurrMove = 0
	self.ispause = false
	self.battleReport = {}
	self.fightBeginInfo = require('lua.logic.battle.attr.FightBeginMsg')
	self.fightResultMsg = require('lua.logic.battle.attr.FightResultMsg')
	self:reset()
	self:resetGenerateId()
	self:registerEvents()
end

function FightManager:registerEvents()
	TFDirector:addProto(s2c.FIGHT_BEGIN, self, self.onFightBegin)
	TFDirector:addProto(s2c.FIGHT_REPLAY, self, self.onFightReport)
	TFDirector:addProto(s2c.FIGHT_RESULT, self, self.onFightResult)
	TFDirector:addProto(s2c.FIGHT_SELECT, self, self.onFightTurn)
end

function FightManager:showFight(data)
	self.fightBeginInfo:setBeginMsg(data)
	self:fightBeginMsgHandle(data)
	--test for check attributes
	Lua_writeFile("FightReport/FightBeginInfo_",true,self.fightBeginInfo)
end

function FightManager:onFightBegin(event)
	hideLoading()
	self:makeSureFightClear()
	
	-- self.fightBeginInfo:setBeginMsg(event.data)
	-- self:fightBeginMsgHandle(event.data)
	self:showFight(event.data)
	--use to send to server
	self.fightBeginMsgDataBak = event.data
end

function FightManager:onFightReport(event)
	hideLoading()
	self:makeSureFightClear()

	self.fightBeginInfo:setBeginMsg(event.data.beginInfo)
	self.battleReport = event.data.report
	self.fightResultInfo = event.data.result

	--test
	Lua_writeFile("FightReport/sFightBeginInfo_",true,self.fightBeginInfo)
	Lua_writeFile("FightReport/sFightReport_",true,self.battleReport)
	self:beginReplayFight(self)

end

function FightManager:onFightResult(event)
	hideLoading()

	if self.bWaitResultMsg then
		self.bWaitResultMsg = false

		self.fightResultInfo = event.data
		-- print("onFightResult:", self.fightResultInfo)

		-- TFDirector:changeScene(SceneType.BATTLERESULT)
		self:showBattleResult()

	end

	-- self.fightResultInfo = event.data
	-- print("onFightResult:", self.fightResultInfo)

	-- -- TFDirector:changeScene(SceneType.BATTLERESULT)
	-- self:showBattleResult()
end

function FightManager:onFightTurn(event)
	hideLoading()

	self.fightTurnInfo = {}
	local data = event.data
	self.fightTurnInfo.selectlist = data.selectlist
	self.fightTurnInfo.selectindex = data.selectindex

	-- print("onFightTurn -=====", event.data)
end

function FightManager:sendFightResult()
	if EBattleType.EFTDEBUG == self.battleType then return end
	-- print("sendFightResult:",self.fightBeginInfo.missionId)
	self.fightResultMsg:reset()

	local livelist = {}
	local actors = LogicWorld:getALiveActors()
	for k,v in pairs(actors) do
		local live = {v.pos,v.realAttr[1]}
		livelist[#livelist + 1] = live
	end
	-- print("livelist:", livelist)
	showLoading()

	local fighttype = self.fightBeginInfo.fighttype
	local missionId = self.fightBeginInfo.missionId
	local win = self.battleReport.win and true or false
	local power = 1000
	local angerSelf = LogicWorld:getAnger(true)
	local angerEnemy = LogicWorld:getAnger(false)
	local msg = nil
	local playerId = nil

	local sendReport = false
	if fighttype ~= EBattleType.DAILY then
		sendReport = MissionManager:isNeedSendReport(self.fightBeginInfo.missionId, power)
	end

	if win and fighttype then
		msg = {
			fighttype,
			self.fightResultMsg:transBeginMsg(self.fightBeginMsgDataBak),
			self.fightResultMsg:setBattleReport(self.battleReport),
			missionId,
			win,
			power,
			livelist,
			angerSelf,
			angerEnemy,
			-- playerId or NULL
		}
	else
		msg = {
			fighttype,
			NULL,
			NULL,
			missionId,
			win,
			power,
			livelist,
			angerSelf,
			angerEnemy,
			-- playerId or NULL
		}
	end

	if fighttype == EBattleType.PVP then
		msg[#msg + 1] = ArenaManager.playerId
		msg[2] = self.fightResultMsg:transBeginMsg(self.fightBeginMsgDataBak)
		msg[3] = self.fightResultMsg:setBattleReport(self.battleReport)
	elseif fighttype == EBattleType.SCOREMATCH3 then
		msg[2] = self.fightResultMsg:transBeginMsg(self.fightBeginMsgDataBak)
		msg[3] = self.fightResultMsg:setBattleReport(self.battleReport)
		msg[#msg + 1] = playerId or NULL
	else
		msg[#msg + 1] = playerId or NULL
	end

	--战斗数据统计
	msg[#msg + 1] = {BattleCount.skilledMonsters, BattleCount.useHealSpell}

	self.lastEndFightMsg = msg --重连后重发
	self.bWaitResultMsg = true

	-- print("msg:", msg)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	CCTextureCache:sharedTextureCache():addImage("effect/battlewin.png")
	TFDirector:send(c2s.BATTLE_RESULT, msg)
end

--设置战斗速度
function FightManager:setSpeed(speed)
	if self.fightSpeed == speed then
		return
	end
	self.fightSpeed = speed
	me.Scheduler:setTimeScale(speed)
end

--战斗速度相应的声音速度
function FightManager:getSoundSpeed()
	local soundSpeed = BattleSoundSpeed.LEVEL_A
	if self.fightSpeed == BattleSpeed.LEVEL_B then
		soundSpeed = BattleSoundSpeed.LEVEL_B
	elseif self.fightSpeed == BattleSpeed.LEVEL_C then
		soundSpeed = BattleSoundSpeed.LEVEL_C
	end
	return soundSpeed
end

--暂停战斗
function FightManager:pause(notShowPL)
	local currentScene = Public:currentScene()
	notShowPL = notShowPL or false
	if currentScene.__cname == "BattleScene" then
		self:logicPause() 
		TFDirector:pause()
		if not notShowPL then
			self:createPauseLayer()
		end
	end
end

--战斗逻辑暂停,用于展现表现层东西
function FightManager:logicPause()
	local currentScene = Public:currentScene()
	if currentScene.__cname == "BattleScene" then
		self.ispause = true
	end
end


--恢复战斗
function FightManager:resume(notRemovePL)
	local currentScene = Public:currentScene()
	notRemovePL = notRemovePL or false
	if currentScene.__cname == "BattleScene" then
		self:logicResume()
		TFDirector:resume()
		if not notRemovePL then
			local topLayer = currentScene:getTopLayer()
			topLayer:removeFromParent()
		end
	end
end

--战斗逻辑恢复
function FightManager:logicResume()
	local currentScene = Public:currentScene()
	if currentScene.__cname == "BattleScene" then
		self.ispause = false
	end
end

function FightManager:isLogicPause()
	return self.ispause
end


--跳过战斗
function FightManager:skip()
	if self.toSkip == true or self.skiping == true then
		return
	end
	self.toSkip = true
	self.skipPassTime = 0
end

function FightManager:onReConnect()
	print("战斗断线重连成功")
	if self.lastEndFightMsg ~= nil and self.isFighting == false then
		self.bWaitResultMsg = true
		-- print("resend battle result after reconnect success:",self.lastEndFightMsg)
		TFDirector:send(c2s.BATTLE_RESULT, self.lastEndFightMsg)
	end
end

--收到战斗开始信息 开始战斗
function FightManager:fightBeginMsgHandle(data)
	--print("fightBeginMsgHandle", event.data)
	--self.fightBeginInfo = event.data

	if self.isFighting then
		return
	end

	self:beginFight(data.fighttype)
end

function FightManager:recordBattleReport(data)
	BattleCoreMgr:recordBattleReport(data)
end

function FightManager:battleActorDead(actorDead)
	--角色死亡 剧情
	MovieManager:triggerBattleDeadMovie(self:getMissionId(), actorDead)
end

--准备开始战斗 切换到战斗场景
function FightManager:beginFight(battleType)
	print("FightManager:beginFight")
	self.isReplayFight = false
	self.battleReport = {}
	self.battleReport.start = {}
	self.battleReport.start.events = {}
	self.battleReport.rounds = {}
	self.maxTurnNum = 10
	self.nCurrTurn = 0
	self.nCurrMove = 0
	self:createBattleCore(battleType)
	self.fightSpeed = 1
	self:setSpeed(self.fightSpeedBp)

	--self.fightBeginInfo = require('lua.logic.battle.attr.FightBeginMsg')
	
	LogicWorld:updateAnger(self.fightBeginInfo.angerSelf, self.fightBeginInfo.angerEnemy)
	-- self:setSpeed(BattleSpeed.LEVEL_A)
	-- if self.fightBeginInfo.bGuideFight then
	-- 	AlertManager:changeScene(SceneType.battle)
	-- else
		local currentScene = Public:currentScene()
	    if currentScene.__cname == "BattleResultScene" or currentScene.__cname == "BattleScene" then
			AlertManager:changeScene(SceneType.BATTLE)
	    else
			AlertManager:changeScene(SceneType.BATTLE, nil, TFSceneChangeType_PushBack)
	    end
	-- end
	self.isFighting = true

	DeviceAdpter.skipMemoryWarning = true
end

--准备开始战斗 切换到战斗场景
function FightManager:beginReplayFight(self)
	print("FightManager:beginReplayFight")
	self.isFighting = false
	if self.battleReport == nil then
		return
	end

	-- self.nCurrTurn = 0
	-- self:createBattleCore(EBattleType.REPLAY)
	-- self:setSpeed(self.fightSpeedBp)

	-- self:setSpeed(BattleSpeed.LEVEL_B)
	-- if self.fightBeginInfo.bGuideFight then
	-- 	AlertManager:changeScene(SceneType.battle)
	-- else
	self.isReplayFight = true
	
		local currentScene = Public:currentScene()
	    if currentScene.__cname == "BattleResultScene" or currentScene.__cname == "BattleScene" then
			AlertManager:changeScene(SceneType.BATTLE)
	    else
			AlertManager:changeScene(SceneType.BATTLE, nil, TFSceneChangeType_PushBack)
	    end
	-- end
	

	self.nCurrTurn = 0
	self:createBattleCore(EBattleType.REPLAY)
	self.fightSpeed = 1
	self:setSpeed(self.fightSpeedBp)


	DeviceAdpter.skipMemoryWarning = true
end

-- 根据战斗类型 创建BattleCore
function FightManager:createBattleCore(etype)
	self.battleType = etype
	BattleCoreMgr:createBattleCore(etype)
end

-- 创建战斗单位
function FightManager:createUnit(unitInfo)
	BattleCoreMgr:createUnit(unitInfo)
end

-- 开始战斗
function FightManager:startBattle()
	print("FightManager:startBattle")
	BattleCoreMgr:start()
end

--结束战斗
function FightManager:endFight(win)
	self.battleResult = win
	self.battleReport.win = win
	if win then
		print("fight win !!!")
	else
		print("fight lose !!!")
	end
	--跳过战斗
	self.toSkip = false
	self.skiping = false

	--战斗结束延迟时间
	local delayTime = BattleConstData.BattleFinishDelayTime
	if TFDirector:currentScene().isBigBossBattle then
		delayTime = BattleConstData.BossBattleFinishDelayTime
	end
	
	if self.isFighting then
		self.isFighting = false

		DeviceAdpter.skipMemoryWarning = false
		if self.end_timerID then
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
		end
		self.end_timerID = TFDirector:addTimer(delayTime * 1000, 1, nil,
		function() 
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
			local function _endFight()
				if MainPlayer.playerId == "" then
					self:changeCreatePlayer()
				else
					self:sendFightResult()
				end
				-- self:dispose()
			end
			if win then
				MovieManager:triggerBattleEndMovie(self:getMissionId(), self, _endFight)
			else
				_endFight()
			end
		end)

		Lua_writeFile("FightReport/FightReport_",true,self.battleReport)
		if VERSION_DEBUG == true then
			-- require("lua.public.PrintBattleReport").print(self.battleReport)
		end
	end

	if self.isReplayFight then
		self.isReplayFight = false
		
		DeviceAdpter.skipMemoryWarning = false
		if self.end_timerID then
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
		end
		self.end_timerID = TFDirector:addTimer(delayTime * 1000, 1, nil,
		function() 
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
			-- self:dispose()
			-- TFDirector:changeScene(SceneType.BATTLERESULT)
			self:showBattleResult()
		end)
	end
end

function FightManager:createPauseLayer()
	local currentScene = Public:currentScene()
	if currentScene.__cname == "BattleScene" then
		local fightPauseLayer = require("lua.logic.battle.BattlePauseLayer"):new()
		currentScene:addLayer(fightPauseLayer)
	end
	print('BattleScene:createPauseLayer')
end

function FightManager:showBattleResult()
	LogicWorldCopy:showBattleResult(self.fightResultInfo.result)
	self:dispose()
	me.Scheduler:setTimeScale(1)
	TFDirector:currentScene():createResultLayer()
end

--[[
mover.actor
mover.skillType
mover.isCasting
]]
function FightManager:getMoveList()
	return BattleCoreMgr:getMoveList()
end

function FightManager:generateBuffId()
	self.generateId = self.generateId + 1
	return self.generateId
end

function FightManager:resetGenerateId()
	self.generateId = 0
end

function FightManager:getMissionId()
	return self.fightBeginInfo.missionId
end

function FightManager:isShowSkip()
	if EBattleType.PVE == self.battleType then
		if MissionManager:getStarLevelByMissionId(self.fightBeginInfo.missionId) > 0 then
        	return true
		end
	elseif EBattleType.PVP == self.battleType then
		return true
	elseif EBattleType.REPLAY == self.battleType then
		return true
	elseif EBattleType.DAILY == self.battleType then
		return true
	elseif EBattleType.SCOREMATCH1 == self.battleType or EBattleType.SCOREMATCH3 == self.battleType then
		return true
	end
	return false
end

function FightManager:isPvp()
	if EBattleType.PVP == self.battleType then
		return true
	end
	if EBattleType.FRIEND == self.battleType then
		return true
	end
	if EBattleType.BLOODY == self.battleType then
		return true
	end
	if EBattleType.ARENAMATCH == self.battleType then
		return true
	end
	return false
end

function FightManager:changeCreatePlayer()
	--首战结束 创角
	self.isFighting = false
	self:dispose()
	TFDirector:changeScene(SceneType.CREATEPLAYER)
end

function FightManager:isSkipResetCamera()
	-- print("isBigBossBattle", TFDirector:currentScene().isBigBossBattle)
	-- print("hasLastHit", LogicWorldCopy.hasLastHit)

	return TFDirector:currentScene().isBigBossBattle and LogicWorldCopy.hasLastHit
end

--大Boss战
function FightManager:isBigBossBattle()
	return self:isWorldBossBattle() or self:isGuildBossBattle()
end

--世界Boss
function FightManager:isWorldBossBattle()
	return self.fightBeginInfo.fighttype == EBattleType.BOSS
end

--公会Boss
function FightManager:isGuildBossBattle()
	return self.fightBeginInfo.fighttype == EBattleType.GUILDBOSS
end

--是否正在出手中...
function FightManager:isProcessing()
	return LogicWorldCopy.processing
end


--////////////////////////////////////////////////////////////离开战斗/////////////////////////////////////////////

--如果是当前战斗中,确保战场打扫干净,重新开始
function FightManager:makeSureFightClear()
	local currentScene = Public:currentScene()
	if currentScene.__cname == "BattleScene" then
		self:cleanFight(true)
	end
end

--FightManager Restart
function FightManager:restart()
	self:cleanFight(true)
end

--离开战斗场景
function FightManager:popBattleScene(battleType)
	self:cleanFight(true)
	TFDirector:resume()
	self:resetSpeed()
	--AlertManager:changeScene(SceneType.HOME)
	AlertManager:changeScene(SceneType.HOME,nil,TFSceneChangeType_PopBack)
end

--清除战斗内容
function FightManager:cleanFight(withData)
	self:reset()
	self:dispose()
	if withData then 
		self:resetData() 
	end
end

--dispose所有组件等
function FightManager:dispose()
	print("FightManager:dispose")
	--清除逻辑世界对象
    LogicWorld:dispose()
	--清除逻辑世界副本对象
    LogicWorldCopy:dispose()
    --清除显示对象
    ActorViewMgr:dispose()
    --清除战斗模式
    BattleCoreMgr:dispose()
    --清除AI数据
    BattleAI:dispose()
	--跳过战斗
	self.toSkip = false
	self.skiping = false

	-- self:setSpeed(BattleSpeed.LEVEL_A)

	if self.end_timerID then
		TFDirector:removeTimer(self.end_timerID)
		self.end_timerID = nil
	end
	--重置战斗统计  
	BattleCount.reset()
	TFDirector:dispatchGlobalEventWith(FightManager.FIGHT_DISPOSE, nil)
end

--重置战斗变量
function FightManager:reset()
	self.bWaitResultMsg = false
	self.isFighting = false
	self.ispause = false
	self.isBattle = false
	self.maxTurnNum = 10
	self.nCurrTurn = 0
	self.nCurrMove = 0
	DeviceAdpter.skipMemoryWarning = false
	--重置状态id产生器   
	self:resetGenerateId()
	--跳过战斗
	self.toSkip = false
	self.skiping = false
	--变身
	self.shapeShiftPos = nil
	--速度
	-- self:setSpeed(self.fightSpeedBp)

	--战斗翻卡
	self.fightTurnInfo = nil
end

--重置数据信息
function FightManager:resetData()
	--战斗初始数据备份
	self.fightBeginMsgDataBak = nil
	--战报数据备份
	self.lastEndFightMsg = nil
	--战斗开始信息
	self.fightBeginInfo:reset()
	--战斗结果信息
	self.fightResultInfo = nil
	--战斗上传信息备份
	self.lastEndFightMsg = nil
	--战斗过程记录
	self.battleReport = nil
end

--重置战斗速度相关
function FightManager:resetSpeed()
	self.fightSpeedBp = self.fightSpeed
	me.Scheduler:setTimeScale(1)	--make sure
	self.fightSpeed = BattleSpeed.LEVEL_A
end

return FightManager:new()