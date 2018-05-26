-- 山海奇遇管理类
-- Author: 孙云鹏
-- Date: 2017-04-05
--

local AdventureManager = class("AdventureManager", BaseManager)

AdventureManager.ADVENTURE_UPDATE_MOSTER		= "AdventureManager.ADVENTURE_UPDATE_MOSTER"
AdventureManager.ADVENTURE_HIT_MONSTER			= "AdventureManager.ADVENTURE_HIT_MONSTER"
AdventureManager.ADVENTURE_HIT_MONSTER_BEGIN	= "AdventureManager.ADVENTURE_HIT_MONSTER_BEGIN"
AdventureManager.ADVENTURE_HIT_REWARD			= "AdventureManager.ADVENTURE_HIT_REWARD"
AdventureManager.ADVENTURE_NOTIFY_ACTIVITY		= "AdventureManager.ADVENTURE_NOTIFY_ACTIVITY"
AdventureManager.ADVENTURE_UPDATE_ACTIVITY		= "AdventureManager.ADVENTURE_UPDATE_ACTIVITY"
AdventureManager.ADVENTURE_BOSS_ACTIVITY		= "AdventureManager.ADVENTURE_BOSS_ACTIVITY"
AdventureManager.ADVENTURE_CLOSE_LAYER			= "AdventureManager.ADVENTURE_CLOSE_LAYER"
AdventureManager.ADVENTURE_BATTLE_END			= "AdventureManager.ADVENTURE_BATTLE_END"

AdventureManager.ADVENTURE_CLOSE_AUTO			= "AdventureManager.ADVENTURE_CLOSE_AUTO"


function AdventureManager:ctor()
	self:init()

	self:reset()
end

function AdventureManager:init()
	self.super.init(self)

	self.DestroyBanditInfo = nil

	self.WalkDealerInfo = TFArray:new()
	self.KnowLedgeDiscussInfo = TFArray:new()
	self.MysteryBoxInfo = TFArray:new()
	self.adventure_auto = false
	self.is_open = false
	TFDirector:addProto(s2c.DESTROY_BANDIT_INFO, self, self.onReceiveDestroyBanditInfo)
	TFDirector:addProto(s2c.BEAT_MONSTER_RESPONSE, self, self.onReceiveBeatMonsterResponse)
	TFDirector:addProto(s2c.BUY_WALK_DEALER_RESPONSE, self, self.onReceiveBuyWalkDealerResponse)
	TFDirector:addProto(s2c.ANSWERQUESTION_RESPONSE, self, self.onReceiveAnswequestionResopnse)
	TFDirector:addProto(s2c.RECEIVE_BOX_RESPONSE, self, self.onReceiveReceiveBoxResponse)
	TFDirector:addProto(s2c.NOTIFY_ACTIVITY, self, self.onReceiveNotifyActivity)
	TFDirector:addProto(s2c.NOTIFY_BOSS_APPEAR, self, self.onReceiveNotifyBossAppear)
	TFDirector:addProto(s2c.NOTIFY_NEW_MONSTER_APPEAR, self, self.onReceiveArenaGetPlayerRecord)
end

function AdventureManager:reset()
	self.WalkDealerInfo:clear()
	self.KnowLedgeDiscussInfo:clear()
	self.MysteryBoxInfo:clear()

	self.DestroyBanditInfo = nil

	self.adventure_auto = false
	self.is_open = false
end

function AdventureManager:restart()
	self:reset()
end

-- 剿匪信息
function AdventureManager:onReceiveDestroyBanditInfo( event )
	hideLoading()
	local data = event.data
	-- print("===========AdventureManager=========",data)
	self.DestroyBanditInfo = data

	self.DestroyBanditInfo.curStep = data.curStep and data.curStep or 0--当前进度
	self.DestroyBanditInfo.monsterId = data.monsterId and data.monsterId or 0--小怪的ID
	self.DestroyBanditInfo.totalHp = data.totalHp and data.totalHp or 0--//总血量
	self.DestroyBanditInfo.curHp = data.curHp and data.curHp or 0--当前血量
	self.DestroyBanditInfo.bossId = data.bossId and data.bossId or 0--bossID


	self.WalkDealerInfo:clear()
	self.KnowLedgeDiscussInfo:clear()
	self.MysteryBoxInfo:clear()

	if self.DestroyBanditInfo.walkDealerInfos then
		for i,v in pairs(data.walkDealerInfos) do
			self:setWalkDealerInfo(v)
		end
	end
	
	if self.DestroyBanditInfo.mysteryBoxInfos then
		for i,v in pairs(data.mysteryBoxInfos) do
			self:setMysteryBoxInfo(v)
		end
	end

	
	if self.DestroyBanditInfo.knowLedgeDiscussInfos then 
		for i,v in pairs(data.knowLedgeDiscussInfos) do
			self:setKnowLedgeDiscussInfo(v)
		end
	end
	
end

function AdventureManager:setWalkDealerInfo( data )
	if data then 
		for item in self.WalkDealerInfo:iterator() do
			if item.shopId == data.shopId and item.startTime == data.startTime then
				-- print("setWalkDealerInfo-----------------have notify")
				-- assert(false)
				return
			end
		end
		self.WalkDealerInfo:push(data)
	end
end

function AdventureManager:setKnowLedgeDiscussInfo( data )
	if data then 
		for item in self.KnowLedgeDiscussInfo:iterator() do
			if item.shopId == data.shopId and item.startTime == data.startTime then
				-- print("setKnowLedgeDiscussInfo-----------------have notify")
				-- assert(false)
				return
			end
		end
		self.KnowLedgeDiscussInfo:push(data)
	end
end

function AdventureManager:setMysteryBoxInfo( data )
	if data then 
		for item in self.MysteryBoxInfo:iterator() do
			if item.shopId == data.shopId and item.startTime == data.startTime then
				-- print("setMysteryBoxInfo-----------------have notify")
				-- assert(false)
				return
			end
		end
		self.MysteryBoxInfo:push(data)
	end
end

-- 击打小怪
function AdventureManager:onReceiveBeatMonsterResponse( event )
	hideLoading()
	local data = event.data
	if self.DestroyBanditInfo.curHp then
		self.DestroyBanditInfo.curHp = data.curHp
	end
	print("########################回来打小怪")
	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_HIT_MONSTER, 0)
end

-- 购买云游商品
function AdventureManager:onReceiveBuyWalkDealerResponse( event )
	hideLoading()
	local data = event.data
	for item in self.WalkDealerInfo:iterator() do
		if item.shopId == data.shopId and item.startTime == data.startTime then
			self.WalkDealerInfo:removeObject(item)
			break
		end
	end
	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_UPDATE_ACTIVITY, 0)
end

-- 回答煮酒论道
function AdventureManager:onReceiveAnswequestionResopnse( event )
	hideLoading()
	local data = event.data
	for item in self.KnowLedgeDiscussInfo:iterator() do
		if item.questionId == data.questionId and item.startTime == data.startTime then
			self.KnowLedgeDiscussInfo:removeObject(item)
			break
		end
	end
	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_UPDATE_ACTIVITY, 0)
end

-- 领取神秘宝箱
function AdventureManager:onReceiveReceiveBoxResponse( event )
	hideLoading()
	local data = event.data
	local is_remove = false
	local boxData = AdventureBoxData:objectByID(data.boxId)
	if boxData then
		local item = boxData:getSycee()
		if not item[(data.receiveTimes + 1)] then
			is_remove = true
		end
	end

	for item in self.MysteryBoxInfo:iterator() do
		if item.boxId == data.boxId and item.startTime == data.startTime and is_remove then
			self.MysteryBoxInfo:removeObject(item)
			break
		elseif item.boxId == data.boxId and item.startTime == data.startTime and not is_remove then
			item.receiveTimes = data.receiveTimes
		end
	end
	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_UPDATE_ACTIVITY, 0)
end

-- 通知新的奇遇出现
function AdventureManager:onReceiveNotifyActivity( event )
	hideLoading()
	local data = event.data
	print("========onReceiveNotifyActivity========",data)

	if data.walkDealerInfo then
		self:setWalkDealerInfo( data.walkDealerInfo )
	end

	if data.mysteryBoxInfo then
		self:setMysteryBoxInfo(data.mysteryBoxInfo)
	end

	if data.knowLedgeDiscussInfo then
		self:setKnowLedgeDiscussInfo(data.knowLedgeDiscussInfo)
	end

	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_NOTIFY_ACTIVITY, 0)
end

-- boss出现通知
function AdventureManager:onReceiveNotifyBossAppear( event )
	hideLoading()
	local data = event.data	
	
	self.DestroyBanditInfo.bossId = data.bossId
	self.DestroyBanditInfo.curStep = self.DestroyBanditInfo.curStep + 1
	if self.DestroyBanditInfo.curStep > 10 then
		self.DestroyBanditInfo.curStep = 0
	end
	print("------------------boss出现通知",data,self.DestroyBanditInfo)
	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_BOSS_ACTIVITY, 0)
end
-- 新怪出现通知
function AdventureManager:onReceiveArenaGetPlayerRecord( event )
	hideLoading()
	local data = event.data
	self.DestroyBanditInfo.curHp = data.totalHp
	self.DestroyBanditInfo.totalHp = data.totalHp
	self.DestroyBanditInfo.monsterId = data.monsterId
	self.DestroyBanditInfo.bossId = 0
	self.DestroyBanditInfo.curStep = self.DestroyBanditInfo.curStep + 1
	if self.DestroyBanditInfo.curStep > 10 then
		self.DestroyBanditInfo.curStep = 0
	end
	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_UPDATE_MOSTER, 0)
end


--------------------------send--------------------------
-- 击打小怪
function AdventureManager:sendBeatMonsterRequest()
	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_HIT_MONSTER_BEGIN, 0)
	self:send(c2s.BEAT_MONSTER_REQUEST, true)
end

-- 购买云游商品
function AdventureManager:sendBuyWalkDealerRequest(id, startTime)
	self:sendWithLoading(c2s.BUY_WALK_DEALER_REQUEST, id, startTime)
end

-- 回答煮酒论道
function AdventureManager:sendAnswerQuestionRequest(id, answer)
	self:sendWithLoading(c2s.ANSWER_QUESTION_REQUEST,id, answer)
end

-- 领取神秘宝箱
function AdventureManager:sendReceiveBoxRequest(id, startTime)
	self:sendWithLoading(c2s.RECEIVE_BOX_REQUEST, id, startTime)
end

-- 挑战剿匪boss请求
function AdventureManager:sendChallengeDestroyBanditBossRequest()
	self:send(c2s.CHALLENGE_DESTROY_BANDIT_BOSS_REQUEST, true)
end

function AdventureManager:getDestroyBanditInfo()
	return self.DestroyBanditInfo
end

function AdventureManager:setAdventureReward(rewards )
	self.hitReward = rewards

	TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_HIT_REWARD, 0)
end

function AdventureManager:getAdventureReward()
	return self.hitReward
end

function AdventureManager:getNotifyActivity()
	local is_bool = false
	if self:getAllNotifyActivity():length() > 0 then
		is_bool = true
	end
	return is_bool
end

function AdventureManager:getAllNotifyActivity()
	local allNotify = TFArray:new()

	--商店
	for item in self.WalkDealerInfo:iterator() do
		item.type = EnumAllNotityType.WalkDealer
		if item.startTime > MainPlayer:getNowtime() then
			allNotify:push(item)
		end
	end

	--答题
	for item in self.KnowLedgeDiscussInfo:iterator() do
		item.type = EnumAllNotityType.KnowLedgeDiscuss
		if item.startTime > MainPlayer:getNowtime() then
			allNotify:push(item)
		end	
	end

	--宝箱
	for item in self.MysteryBoxInfo:iterator() do
		item.type = EnumAllNotityType.MysteryBox
		if item.startTime > MainPlayer:getNowtime() then
			allNotify:push(item)
		end	
	end

	table.sort( allNotify.m_list, function ( t1, t2 ) return t1.startTime < t2.startTime end )

	return allNotify
end

function AdventureManager:setAdventureIsBool( is_bool )
	self.is_adventure = is_bool
end

function AdventureManager:getAdventureIsBool()
	return self.is_adventure
end

function AdventureManager:setAdventureAutoBattle( is_bool )
	self.adventure_auto = is_bool
end

function AdventureManager:getAdventureAutoBattle()
	return self.adventure_auto
end

function AdventureManager:setAdventureIsOpen( is_bool )
	self.is_open = is_bool
end

function AdventureManager:getAdventureIsOpen()
	return self.is_open
end

function AdventureManager:openJiaoMainLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.jiaofei.JiaoMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function AdventureManager:openJiaoSuijiMainLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.jiaofei.JiaoSuijiLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function AdventureManager:openBuyJingliLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.jiaofei.JingliBuyLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function AdventureManager:openUseJingliLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.jiaofei.JingliUseLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function AdventureManager:isHaveRedPoint()
	local is_can = JumpToManager:isCanJump(FunctionManager.ChallengeAdventure)
	local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.SpiritPoint)
	if is_can and times:getLeftValue() > 50 then return true end
	return false
end
return AdventureManager:new()
