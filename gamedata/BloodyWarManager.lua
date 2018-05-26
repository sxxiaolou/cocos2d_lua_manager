--
-- 建木通天管理类
-- Author: Jin
-- Date: 2016-10-22
--

local BaseManager = require('lua.gamedata.BaseManager')
local BloodyWarManager = class("BloodyWarManager", BaseManager)

BloodyWarManager.PrayWeather = "BloodyWarManager.PrayWeather"
BloodyWarManager.knockDoor = "BloodyWarManager.knockDoor"
BloodyWarManager.BloodyWarReset = "BloodyWarManager.BloodyWarReset"
BloodyWarManager.ReAnimate = "BloodyWarManager.ReAnimate"
BloodyWarManager.BoxInfo = "BloodyWarManager.BoxInfo"
BloodyWarManager.TowerBoxInfo = "BloodyWarManager.TowerBoxInfo"
BloodyWarManager.BloodyDoorInfo = "BloodyWarManager.BloodyDoorInfo"

function BloodyWarManager:ctor()
	self.super.ctor(self)
end

function BloodyWarManager:init()
	self.super.init(self)

	self:reset()

	-- 卡牌状态信息
	TFDirector:addProto(s2c.BLOODY_WAR_MATIX_CONF, self, self.onReceiveBloodyWarMatixConf)
	-- 血战信息
	TFDirector:addProto(s2c.BLOODY_ENEMY_DETAIL, self, self.onReceiveBloodyEnemyDetail)
	-- 当前敌人信息
	TFDirector:addProto(s2c.BLOODY_ENEMY_INFO, self, self.onReceiveBloodyEnemyInfo)
	-- 祈祷
	TFDirector:addProto(s2c.BLOODY_INSPIRE, self, self.onReceiveBloodyInspire)
	-- 重置血战
	TFDirector:addProto(s2c.BLOODY_RESET_SUCCESS, self, self.onReceiveBloodyResetSuccess)
	-- 撞天门
	TFDirector:addProto(s2c.KNOCK_DOOR_RESULT, self, self.onReceiveKnockDoorRequest)
	-- 宝箱信息
	TFDirector:addProto(s2c.BLOODY_BOX_INFO, self, self.onReceiveBoxInfo)
	-- 天门信息
	TFDirector:addProto(s2c.DOOR_INFO, self, self.onDoorInfoInfo)
end

function BloodyWarManager:restart()
	self:reset()
end

function BloodyWarManager:reset()
	self.roleStations = {}
	self.warDetail = {}
	self.curEnemy = {}

	self.autoWar = false
	self.state = 0
	self.running = false
	self.doorInfoData = nil
	-- self.warDetail.currSection = 1
	-- self.warDetail.weather = 1011
	-- self.warDetail.isDropBox = false
	-- self.warDetail.currSection = 3

	-- local bloodyBoxList = {}
	-- self.warDetail.BloodyBoxList = bloodyBoxList
	-- local boxInfo = {}
	-- boxInfo.section = 3
	-- boxInfo.index = 0
	-- boxInfo.state = 1
	-- boxInfo.needResType = 1 
	-- boxInfo.needResNum = 300
	-- local items = {}
	-- boxInfo.item = items
	-- bloodyBoxList[1] = boxInfo 

	-- self.warDetail.curValue = 20
	-- self.warDetail.needValue = 50

	-- self.curEnemy.name = "aa"
	-- self.curEnemy.power = "1111111"
	-- self.curEnemy.level = 10
	-- self.curEnemy.tplId = 43
end

--protocol
function BloodyWarManager:sendQueryBloodyInfo()
	self:sendWithLoading(c2s.QUERY_BLOODY_INFO, true)
end

function BloodyWarManager:sendQueryBloodyDetail()
	self:sendWithLoading(c2s.QUERY_BLOODY_INFO, true)
	self:sendWithLoading(c2s.QUERY_BLOODY_DETAIL, true)
	self.isReset = false
end

function BloodyWarManager:sendChallengeBloodyEnemy()
	self:sendWithLoading(c2s.CHALLENGE_BLOODY_ENEMY, self.warDetail.currSection)
end

function BloodyWarManager:sendGetBloodySmallBox()
	self:sendWithLoading(c2s.GET_BLOODY_SMALL_BOX, true)
end

function BloodyWarManager:sendGetBloodyBigBox(section, index, getType)
	self.selectIdx = index
	self:sendWithLoading(c2s.GET_BLOODY_BIG_BOX, section, index, getType)
end

function BloodyWarManager:sendBloodyInspire()
	self:sendWithLoading(c2s.BLOODY_INSPIRE, true)
end

function BloodyWarManager:sendResetBloodyRequest()
	self:sendWithLoading(c2s.RESET_BLOODY_REQUEST, true)
end

function BloodyWarManager:sendKnockDoorRequest(isKnock)
	-- self.isKnock = isKnock
	self:sendWithLoading(c2s.KNOCK_DOOR_REQUEST, isKnock)
end

function BloodyWarManager:sendBloodySweep()
	self:sendWithLoading(c2s.BLOOD_SWEEP_REQ, true) 
end

function BloodyWarManager:onReceiveBloodyWarMatixConf(event)
	hideLoading()
	local data = event.data
	self.roleStations = data.stations or {}
	-- print("==onReceiveBloodyWarMatixConf==", self.roleStations)
end

function BloodyWarManager:onReceiveBloodyEnemyDetail(event)
	hideLoading()
	self.warDetail = event.data or {}
	if self.warDetail.BloodyBoxList then
		table.sort(self.warDetail.BloodyBoxList, function(b1, b2) 
				return b1.section < b2.section
			end)
	end

	-- print("==onReceiveBloodyEnemyDetail==", self.warDetail)

	if not self.isReset then
		BloodyWarManager:openBloodyWarLayer()
		self.isReset = true
	end
end

function BloodyWarManager:onReceiveBloodyEnemyInfo(event)
	hideLoading()
	self.curEnemy = event.data or {}
	-- print("==onReceiveBloodyEnemyInfo==", self.curEnemy)
end

function BloodyWarManager:onReceiveBloodyInspire(event)
	hideLoading()
	local data = event.data
	self.warDetail.weather = data.weather

	-- print("==onReceiveBloodyInspire==", data.weather)
	TFDirector:dispatchGlobalEventWith(BloodyWarManager.PrayWeather, 0)
end

function BloodyWarManager:onReceiveBloodyResetSuccess(event)
	hideLoading()
	local data = event.data
	self.warDetail.remainTimes = data.remainResetTime
	self.roleStations = {}
	TFDirector:dispatchGlobalEventWith(BloodyWarManager.BloodyWarReset, 0)
end

function BloodyWarManager:onReceiveKnockDoorRequest(event)
	hideLoading()
	local data = event.data

	-- print("==onReceiveKnockDoorRequest==", data)
	self.warDetail.curValue = data.curValue
	self.warDetail.needValue = data.needValue
	self.warDetail.isKnock = data.isKnock

	if not data.isKnock then
		BloodyWarManager:openBloodyWarKnockDoorLayer()
	else
		TFDirector:dispatchGlobalEventWith(BloodyWarManager.knockDoor, 0)
	end
end

function BloodyWarManager:onReceiveBoxInfo(event)
	hideLoading()
	local data = event.data
	-- print("==onReceiveBoxInfo==",data)

	local idx = data.section / 3
	local boxInfo = self.warDetail.BloodyBoxList[idx]
	boxInfo.index = data.index
	boxInfo.state = data.state
	boxInfo.item = data.item

	TFDirector:dispatchGlobalEventWith(BloodyWarManager.BoxInfo, self.selectIdx)
end

function BloodyWarManager:onDoorInfoInfo(event)
	hideLoading()
	local data = event.data
	

	self.doorInfoData = event.data
	-- required int32 curValue = 1;			//当前值
	-- required int32 needValue = 2;			//开启所需
	-- required int64 expireTime = 3;			//buff过期日期

	local currentScene = Public:currentScene()
  	if currentScene and currentScene.getTopLayer then
 		local topLayer = currentScene:getTopLayer()
 		if topLayer and topLayer.__cname == "BloodyWarLayer" then
  			TFDirector:dispatchGlobalEventWith(BloodyWarManager.BloodyDoorInfo, 0)
  		end
  	end	
end

--api
function BloodyWarManager:openBloodyWarLayer()
	self:sendQueryBloodyInfo()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bloodywar.BloodyWarLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function BloodyWarManager:openBloodyWarWeatherLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bloodywar.BloodyWarWeatherLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function BloodyWarManager:openBloodyWarChooseLayer(boxInfo)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bloodywar.BloodyWarChooseLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:setData(boxInfo)
	AlertManager:show()
end

function BloodyWarManager:openBloodyWarKnockDoorLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bloodywar.BloodyWarKnockDoorLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function BloodyWarManager:refershBloodyWarLayer()
	self.warDetail.isDropBox = false
	self:ReAnimatie()
end

function BloodyWarManager:ReAnimatie()
	TFDirector:dispatchGlobalEventWith(BloodyWarManager.ReAnimate, 0)
end

function BloodyWarManager:getEnemyByPos(pos)
	if not self.curEnemy.roles then return nil end

	for k,role in pairs(self.curEnemy.roles) do
		if pos == role.index then
			return role
		end
	end

	return nil
end

function BloodyWarManager:getRoleState(id)
	for k,state in pairs(self.roleStations) do
		if state.roleId == id then
			return state
		end
	end
	return nil
end

function BloodyWarManager:isCanSweep(curSection)
	local isSweep = false
	local sweepNum = 0
	local prompt = localizable.bloodyWar_no_num
	
	if self.warDetail and self.warDetail.sweepBattleIndex then
		local sweepData = BloodySweepData:objectAt(self.warDetail.sweepBattleIndex + 1)
		
		if sweepData then
			sweepNum = sweepData.num

			if sweepNum >= curSection then
				isSweep = true
			else
				isSweep = false
				
				if sweepNum ~= 0 then
					prompt = localizable.bloodyWar_no_sweep
				end
			end
		end
	end
	
	return isSweep, sweepNum, prompt
end         

function BloodyWarManager:checkDead(id)
	local state = self:getRoleState(id)
	return state ~= nil and state.currHp <= 0
end

-- 1战斗 2胜利 3失败 4领奖 5关闭领奖界面 6打开天门界面 7撞天门
-- self.running
function BloodyWarManager:setAutoState(state)
	if Public:currentScene():getTopLayer().__cname == "BattleResultLayer" then
		if state == 1 or state == 4 then
			return
		end
	end

	-- print("setAutoState=======", state)

	self.state = state
	self.running = false
end

function BloodyWarManager:resetAutoState()
	self.state = 0
end

function BloodyWarManager:setAutoWar(auto)
	self.autoWar = auto

	-- print("setAutoWar == ", auto)

	if auto then
		self.autoId = TFDirector:addTimer(500, -1, nil, function() self:autoWarCallback() end)
	else
		self:removeAutoTimer()
	end
end

function BloodyWarManager:removeAutoTimer()
	TFDirector:removeTimer(self.autoId)
	self.autoId = nil
	self.autoWar = false
	self.running = false

	-- print("removeAutoTimer==========")
	-- print("AutoWar == ", self.state, " ", self.autoWar, " ", self.running)

	self:removeSubTimer()
end

function BloodyWarManager:removeSubTimer()
	if self.subTimerId then
		TFDirector:removeTimer(self.subTimerId)
		self.subTimerId = nil
	end

	-- print("removeSubTimer==========")
end

function BloodyWarManager:autoWarCallback()
	if self.running then return end

	self:removeSubTimer()
	if self.state == 1 then
		local formationInfo = FormationManager:getFormationByType(EnumFormationType.BloodyWar)
    	if not formationInfo then
    		self:removeAutoTimer()
    		return 
    	end
    	local armyList  = formationInfo.cells
		for _, army in pairs(armyList) do
		 	if army.gmId ~= "0" then
		 		if self:checkDead(army.gmId) then
		 			self:removeAutoTimer()
					return
		 		end
		 	end
	    end
	    self.running = true
		self.subTimerId = TFDirector:addTimer(2000, 1, nil, function() 
			self:sendChallengeBloodyEnemy()
			self:removeSubTimer()
		end)
	elseif self.state == 2 then
		self.running = true
		self.subTimerId = TFDirector:addTimer(4000, 1, nil, function() 
			local topLayer = Public:currentScene():getTopLayer()
			if topLayer.__cname == "BattleResultLayer" then
				topLayer.leaveClickHandle(topLayer.leaveBtn)
			end
			self:removeSubTimer()
		end)
	elseif self.state == 3 then
		self.running = true
		self.subTimerId = TFDirector:addTimer(4000, 1, nil, function() 
			local topLayer = Public:currentScene():getTopLayer()
			if topLayer.__cname == "BattleResultLayer" then
				topLayer.leaveClickHandle(topLayer.leaveBtn)
			end
			self:removeAutoTimer()
			self:setAutoState(1)
		end)
	elseif self.state == 4 then
		self.running = true
		self.subTimerId = TFDirector:addTimer(2000, 1, nil, function() 
			BloodyWarManager:sendGetBloodySmallBox()
			self:removeSubTimer()
		end)
	elseif self.state == 5 then
		self.running = true
		self.subTimerId = TFDirector:addTimer(2000, 1, nil, function() 
			local topLayer = Public:currentScene():getTopLayer()
			if topLayer.__cname == "RewardListMessage" then
				-- AlertManager:close()
				self:refershBloodyWarLayer()
				self:removeSubTimer()
			end
		end)
	elseif self.state == 6 then
		self.running = true
		self.subTimerId = TFDirector:addTimer(2000, 1, nil, function() 
			self:setAutoWar(false)
			-- BloodyWarManager:sendKnockDoorRequest(false)	
			self:removeSubTimer()
		end)
	elseif self.state == 7 then
		self.running = true
		self.subTimerId = TFDirector:addTimer(2000, 1, nil, function() 
			-- BloodyWarManager:sendKnockDoorRequest(true)
			self:removeAutoTimer()
			self.state = 0
		end)
	end
end

function BloodyWarManager:IsHaveDieRole()

	if #self.roleStations == 0 then
		return false
	end

	local formationInfo = FormationManager:getFormationByType(EnumFormationType.BloodyWar)
    if not formationInfo then return end
    local item = formationInfo.cells
    for k,v in pairs(item) do
    	local data = self:getRoleState(v.gmId)
    	if data then
    		if data.currHp == 0 then
    			return true
    		end
    	end	
    end
	return false
end

function BloodyWarManager:isHaveRedPoint()
	local is_can = JumpToManager:isCanJump(FunctionManager.ChallengeBloody)
	local times = RecoverableResManager:getRecoverParamsInfo(EnumTimeRecoverType.BloodyWar)
	if is_can and times:getLeftValue() > 0 then return true end
	return false
end
return BloodyWarManager:new()