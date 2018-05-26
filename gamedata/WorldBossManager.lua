-- 世界Boss管理类
-- Author: Jing
-- Date: 2017-05-03
--

local WorldBossManager = class("WorldBossManager", BaseManager)

WorldBossManager.REFRESH_HURT_RANK 	= "WorldBossManager.REFRESH_HURT_RANK"
WorldBossManager.REFRESH_BOSS_HP 	= "WorldBossManager.REFRESH_BOSS_HP"
WorldBossManager.OTHER_ENTER_BOSS 	= "WorldBossManager.OTHER_ENTER_BOSS"
WorldBossManager.REFRESH_GUWU_UI 	= "WorldBossManager.REFRESH_GUWU_UI"
WorldBossManager.REFRESH_BOSS_TIME 	= "WorldBossManager.REFRESH_BOSS_TIME"

WorldBossManager.BOSS_WAR    = 'WorldBossManager.BOSS_WAR'
WorldBossManager.bossIconShowTime = 5 * 60
--state 0.boss关闭 1.boss倒计时，2 .boss 开启 3. boss结束
WorldBossManager.bossState = 0
function WorldBossManager:ctor()
	self.super.ctor(self)
end

function WorldBossManager:init()
	self.super.init(self)

	self.refreshHpTime = ConstantData:getValue("WorldBoss.Refresh.Hp") * 1000
	self.refreshRankTime = ConstantData:getValue("WorldBoss.Refresh.Rank") * 1000
	
	self.autoWar = false
	--boss托管中状态 1：去挑战 2：去复活 3：等待复活
	self.autoWarState = 1
	--是否自动购买复活
	self.autoReborn = true

	TFDirector:addProto(s2c.ENTER_BOSS_RESULT, self, self.onEnterBoss)
	TFDirector:addProto(s2c.OTHER_ENTER_BOSS, self, self.onOtherEnterBoss)
	TFDirector:addProto(s2c.REFRESH_HURT_RANK_RESULT, self, self.onRefreshHurtRank)
	TFDirector:addProto(s2c.REFRESH_BOSS_HP_RESULT, self, self.onRefreshBossHp)
	TFDirector:addProto(s2c.INSPIRE_BOSS_RESULT, self, self.onInspire)
	TFDirector:addProto(s2c.REBORN_RESULT, self, self.onReborn)
	TFDirector:addProto(s2c.BOSS_BATTLE_RESULT, self, self.onBossBattleResult)
	TFDirector:addProto(s2c.BOSS_OPENT_TIME, self, self.onBossOpenTimeResult)
	TFDirector:addProto(s2c.BOSS_LAST_HIT_PLAYER_INFO, self, self.onBossLastHitPlayerInfo)
end

function WorldBossManager:restart()
	self:stopRefreshInfo()

	self.openTime = nil
	self.endTime = nil
	self.bossId = nil

	self.rankList = {}
	self.guildRankList = {}
	self.myHurt = 0
	self.myRank = 0
	self.myGuildHurt = 0
	self.myGuilRank = 0

	self.bossHp = nil
	self.bossMaxHp = nil

	self.addAttLevel = nil
	self.inspireSycee = nil

	self.sycee = nil
	self.waitSecond = nil

	self.playersInScene = nil
	self.alreadyChallenge =  nil     --登录游戏是否挑战过boos

	TFDirector:removeTimer(self.bossTimerId)
	self.bossTimerId = nil
	self.lastHitPlayerInfo = {}
	self.autoWar = false
	self.isAutoIng = nil
	self.autoReborn = true
	self:stopAutoWarTimer()
end


function WorldBossManager:enter()
	self:sendEnterBoss(true, true)
end

function WorldBossManager:exit()
	self:sendEnterBoss(false, false)
end

--refresh
function WorldBossManager:startRefreshInfo( ... )
	self.hpTimerId = TFDirector:addTimer(self.refreshHpTime, -1, nil, function ( ... )
		self:sendRefreshBossHp()
	end)
	self.rankTimerId = TFDirector:addTimer(self.refreshRankTime, -1, nil, function ( ... )
		-- self:sendRefreshHurtRank()
	end)
	self.countdownId = TFDirector:addTimer(1000, -1, nil, function ( ... )
		if self.openTime and self.openTime > 0 then
			self.openTime = self.openTime - 1
			if self.openTime <= 0 then	--倒计时结束请求服务器确认boss战开始
				self.openTime = 0
				print("openTime==0")
				self:sendEnterBoss(true)
			end
		end
		if self.endTime and self.endTime > 0 then
			self.endTime = self.endTime - 1
			if self.endTime <= 0 then	--倒计时结束请求服务器确认boss战结束
				self.endTime = 0
				print("endTime==0")
				self:sendEnterBoss(true)
			end
		end
		if self.waitSecond and self.waitSecond > 0 then
			self.waitSecond = self.waitSecond - 1
		end
	end)
end

function WorldBossManager:bossStartAndEndTimer( ... )
	if self.bossOpenData == nil or self.bossTimerId then
	    return
	else
	     self:recordBossState()
	end
	self.bossTimerId = TFDirector:addTimer(1000,-1,nil,function ( ... )
		--    print('22222222222222222222222')
		   self:recordBossState()
	end,...)
end

function WorldBossManager:recordBossState( ... )
    -- print('recordBossState:',self.bossOpenData)
	if self.bossOpenData.startTime > 0 and self.bossOpenData.endTime == 0 then
		    self.bossOpenData.startTime = self.bossOpenData.startTime - 1
			--boss活动中，提前击杀
			if WorldBossManager.bossState == 2 then
				WorldBossManager.bossState = 3
				--防止倒计时状态覆盖，没有结束消息
				TFDirector:dispatchGlobalEventWith(WorldBossManager.BOSS_WAR, 0)				
			end
			--未到开启倒计时
			if self.bossOpenData.startTime > WorldBossManager.bossIconShowTime then
				WorldBossManager.bossState = 0
			end
			--boss开启倒计时提示
			if self.bossOpenData.startTime <= WorldBossManager.bossIconShowTime and WorldBossManager.bossState ~= 1 then
			    WorldBossManager.bossState = 1
				self:sendBossOpenTime()
			end
			TFDirector:dispatchGlobalEventWith(WorldBossManager.BOSS_WAR, 0)
		
	elseif self.bossOpenData.startTime <= 0 then
			if self.bossOpenData.endTime > 0 then
			    --boss开启
				self.bossOpenData.endTime = self.bossOpenData.endTime - 1
				if WorldBossManager.bossState ~= 2 then
					WorldBossManager.bossState = 2
					self:sendBossOpenTime()
				end
				TFDirector:dispatchGlobalEventWith(WorldBossManager.BOSS_WAR, 0)
			elseif self.bossOpenData.endTime == 0 then
				 --开启倒计时结束，获取endtime
				 WorldBossManager.bossState = 3
				 self:sendBossOpenTime()
			else
				-- self.bossOpenData.startTime = 0 
				-- self.bossOpenData.endTime = 0
				--boss结束
				if WorldBossManager.bossState ~= 3 then
				      WorldBossManager.bossState = 3
				      self:sendBossOpenTime()
				end
				TFDirector:dispatchGlobalEventWith(WorldBossManager.BOSS_WAR, 0)
			end
	end 
end

function WorldBossManager:stopRefreshInfo()
	TFDirector:removeTimer(self.hpTimerId)
	self.hpTimerId = nil
	TFDirector:removeTimer(self.rankTimerId)
	self.rankTimerId = nil
	TFDirector:removeTimer(self.countdownId)
	self.countdownId = nil

end

--设置是否托管
function WorldBossManager:setAutoWarState( state )
	local layer = AlertManager:getLayerByName('lua.logic.boss.BossMainLayer')
	if state then
		self.autoWar = true
		if layer and layer.panel_tg then
			layer.panel_tg:setVisible(true)
		end
		self:startAutoWarTimer()
	else
		self.autoWar = false
		self.isAutoIng = false
		self.autoReborn = true
		if layer and layer.panel_tg then
			layer.panel_tg:setVisible(false)
		end
		self:stopAutoWarTimer()
	end
end

--开始托管计时
function WorldBossManager:startAutoWarTimer( ... )
	if self.autoTimer then return end
	
	self.autoWarState = 1
	self.autoTimer = TFDirector:addTimer(500, -1, nil, function() self:autoWarCallback() end)
end
--停止托管计时
function WorldBossManager:stopAutoWarTimer( ... )
	if self.autoTimer then
		TFDirector:removeTimer(self.autoTimer)
		self.autoTimer = nil
	end
	if self.autoChallengeTimer then
		TFDirector:removeTimer(self.autoChallengeTimer)
		self.autoChallengeTimer = nil
	end
	if self.autoRebornTimer then
		TFDirector:removeTimer(self.autoRebornTimer)
		self.autoRebornTimer = nil
	end
end
--托管执行各个托管状态逻辑
function WorldBossManager:autoWarCallback( ... )
	if self.isAutoIng then return end
	if self.autoWarState == 1 then
		--自动挑战
		self.isAutoIng = true
		self.autoChallengeTimer = TFDirector:addTimer(1000 * 2,1,function ( ... )
			TFDirector:removeTimer(self.autoChallengeTimer)
			self.autoChallengeTimer = nil 

			self.autoWarState = 2
			
			self.alreadyChallenge = true
			self:sendChallengeBoss()
		end)
	elseif self.autoWarState == 2 then
		--自动复活
		self.isAutoIng = true
		self.autoRebornTimer = TFDirector:addTimer(1000 * 2,1,function ( ... )
			TFDirector:removeTimer(self.autoRebornTimer)
			self.autoRebornTimer = nil
			
			self.isAutoIng = false

			if MainPlayer:getSycee() >= self.sycee and self.autoReborn then
				self:sendReborn()
				self.autoWarState = 1
			else
				self.autoWarState = 3
			end
		end)
	elseif self.autoWarState == 3 then
		--等待复活
		if self.waitSecond <= 0 then
			self.autoWarState = 1
		end
	end
end

-- protocol
function WorldBossManager:sendEnterBoss(isEnter, withLoading)
	if withLoading then
		self.enterCallback = function ( ... )
			self:startRefreshInfo()
			hideLoading()
			local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.boss.BossMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
			AlertManager:show()
		end
		self:sendWithLoading(c2s.ENTER_BOSS, isEnter)
	else
		self.enterCallback = nil
		self:send(c2s.ENTER_BOSS, isEnter)
	end
end

function WorldBossManager:sendRefreshBossHp()
	if self.isPause then return end
	self:send(c2s.REFRESH_BOSS_HP, true)
end

function WorldBossManager:sendRefreshHurtRank()
	if self.isPause then return end
	self:send(c2s.REFRESH_HURT_RANK, true)
end

function WorldBossManager:sendInspire()
	self:sendWithLoading(c2s.INSPIRE_BOSS, true)
end

function WorldBossManager:sendChallengeBoss()
	self:sendWithLoading(c2s.CHALLENGE_BOSS, true)
end


function WorldBossManager:sendReborn()
	self:sendWithLoading(c2s.REBORN, true)
end

function WorldBossManager:sendBossOpenTime()
	self:sendWithLoading(c2s.WORLD_BOSS_OPENT_TIME, true)
end
--response
function WorldBossManager:onEnterBoss(event)
	local data = event.data

	self.openTime = data.openTime or 0
	self.endTime = data.endTime or 0
	self.bossId = data.bossId

	self.openTime = self.openTime/1000
	self.endTime = self.endTime/1000

	print("====================================")
	print("onEnterBoss: openTime", self.openTime, "endTime", self.endTime)
	print("====================================")
	
	TFFunction.call(self.enterCallback)

	--活动结束，强制托管结束
	if self.openTime > 0 then
		self:setAutoWarState(false)
	end
end

function WorldBossManager:onOtherEnterBoss(event)
	local data = event.data
	print('WorldBossManager:onOtherEnterBoss:',data)
	self.playersInScene = self.playersInScene or {}

	local playerId = data.playerId
	self.playersInScene[playerId] = data
	-- if self.playersInScene[playerId] then
	-- 	self.playersInScene[playerId].isEnter = data.isEnter
	-- else
	-- 	self.playersInScene[playerId] = {
	-- 		playerId = data.playerId, 
	-- 		name = data.name, 
	-- 		templateId = data.templateId, 
	-- 		isEnter = data.isEnter,
	-- 		guildName = data.guildName,
	-- 		showId = data.showId}
	-- end

	TFDirector:dispatchGlobalEventWith(WorldBossManager.OTHER_ENTER_BOSS, 0)
end

function WorldBossManager:onRefreshHurtRank(event)
	print("排行榜刷新",event.data)
	local data = event.data

	self.rankList = {}
	if data.rankList and #data.rankList > 0 then
		for k,v in pairs(data.rankList) do
			self.rankList[#self.rankList+1] = v
		end
	end
	self.guildRankList = data.guildRankList or {}
	self.myHurt = data.myHurt or 0
	self.myRank = data.myRank or 0
	self.myGuildHurt = data.myGuildHurt or 0
	self.myGuildRank = data.myGuildRank or 0

	TFDirector:dispatchGlobalEventWith(WorldBossManager.REFRESH_HURT_RANK, 0)
end

function WorldBossManager:onRefreshBossHp(event)
	local data = event.data

	self.bossHp = data.bossHp
	self.bossMaxHp = data.bossMaxHp

	-- print("Boss血量刷新:bossHp", self.bossHp, "bossMaxHp", self.bossMaxHp)

	TFDirector:dispatchGlobalEventWith(WorldBossManager.REFRESH_BOSS_HP, 0)
end

function WorldBossManager:onInspire(event)
	hideLoading()
	local data = event.data

	self.addAttLevel = data.addAttLevel
	self.inspireSycee = data.inspireSycee

	TFDirector:dispatchGlobalEventWith(WorldBossManager.REFRESH_GUWU_UI, 0)
end

function WorldBossManager:onReborn(event)
	hideLoading()
	local data = event.data

	self.sycee = data.sycee
	self.waitSecond = data.waitSecond
    
	-- print("复活等待时间:", self.waitSecond, "复活花费:", self.sycee)
end

function WorldBossManager:onBossBattleResult(event)
	local data = event.data

	self.hurt = data.hurt
	self.isLastHit = data.isLastHit
	self.isDead = data.isDead

	if self.isDead then
		self:sendEnterBoss(true)
		self:sendBossOpenTime()
	end
end

function WorldBossManager:onBossOpenTimeResult(event)
	local data = event.data
	hideLoading()
	self.bossOpenData = data or nil
	-- print('onBossOpenTimeResult:',self.bossOpenData)
	if self.bossOpenData then
		self.bossOpenData.startTime = self.bossOpenData.startTime / 1000
		self.bossOpenData.endTime = self.bossOpenData.endTime / 1000
		self:bossStartAndEndTimer()
	end
	TFDirector:dispatchGlobalEventWith(WorldBossManager.REFRESH_BOSS_TIME, 0)
end

function WorldBossManager:onBossLastHitPlayerInfo( event )
	local data = event.data
	print('WorldBossManager:onBossLastHitPlayerInfo:',data)
	self.lastHitPlayerInfo = data.info or {}
	TFDirector:dispatchGlobalEventWith(WorldBossManager.REFRESH_HURT_RANK, 0)
end

--还能继续鼓舞吗
function WorldBossManager:canInspire( ... )
	local addAttLevel = self.addAttLevel and self.addAttLevel + 1 or 1
	local inspireData = BossInspireData:objectByID(addAttLevel)
	if inspireData==nil then return false end
	return true
end

function WorldBossManager:showBuyInspireLayer( ... )
	if self:canInspire() then
		local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.boss.BuyGuwuLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
		AlertManager:show()
	else 
	    toastMessage(localizable.inspire_up_count)
	end
end

function WorldBossManager:openBossJSLayer( ... )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.boss.BossJSLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function WorldBossManager:openBossTGLayer( ... )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.boss.BossTGLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

--红点API
function WorldBossManager:isHaveRedPoint()
	local is_can = JumpToManager:isCanJump(FunctionManager.ChallengeWorldBoss)
	if is_can and self.bossState == 2 and  not self.alreadyChallenge then return true end

	return false
end
return WorldBossManager:new()