--[[
******福利管理类*******

根据策划需求,重新整理规划[福利]管理类
福利包含：  EnumFuLiType
1、签到
2、吃包子
3、等级礼包
4、资源回购

]]

local BaseManager = require("lua.gamedata.BaseManager")
local FuliManager = class("FuliManager", BaseManager)

FuliManager.ROLE_EAT_TILI = "FuliManager.ROLE_EAT_TILI"			--吃包子
FuliManager.FRESH_LEVELUP = 'FuliManager.FRESH_LEVELUP'         --等级礼包
FuliManager.DAILY_WELLFARE_UPDATE = 'FuliManager.DAILY_WELLFARE_UPDATE'         --每日福利
FuliManager.GROWTH_FUND_UPDATE = 'FuliManager.GROWTH_FUND_UPDATE'         --每日福利
FuliManager.REDPACKET_BULLET_UPDATE = 'FuliManager.REDPACKET_BULLET_UPDATE'         --每日福利
FuliManager.REDPACKET_START = 'FuliManager.REDPACKET_START'         --每日福利
FuliManager.REDPACKET_END = 'FuliManager.REDPACKET_END'         --每日福利
FuliManager.REDPACKET_STATE_UPDATE = 'FuliManager.REDPACKET_STATE_UPDATE'         --每日福利

function FuliManager:ctor(data)
	self.super.ctor(self)

	--福利按钮图片
	self.normalImgs = 
	{
		[EnumFuLiType.Sign] = "ui/activity_theme/0_1.png",
		[EnumFuLiType.EatBaozi] = "ui/activity_theme/5_1.png",
		[EnumFuLiType.LevelGift] = "ui/activity_theme/15_1.png",
		[EnumFuLiType.Repurchase] = "ui/activity_theme/14_1.png",
	}
	self.selectImgs = 
	{
		[EnumFuLiType.Sign] = "ui/activity_theme/0_0.png",
		[EnumFuLiType.EatBaozi] = "ui/activity_theme/5_0.png",
		[EnumFuLiType.LevelGift] = "ui/activity_theme/15_0.png",
		[EnumFuLiType.Repurchase] = "ui/activity_theme/14_0.png",
	}
end

function FuliManager:init()
	self.super.init(self)
    --福利模块枚举表
	self.fuliTypeList = {2,3,4, 5, 6}
	--签到
	TFDirector:addProto(s2c.GET_SIGN,    self, self.onReceiveSignStatus)
    TFDirector:addProto(s2c.SIGN_RESULT, self, self.onReceiveSignResult)

    --吃包子
	TFDirector:addProto(s2c.GET_DINING, self, self.onReceiveGetDiningList)


    --等级礼包
	TFDirector:addProto(s2c.LEVELUP_RES, self, self.onReceiveLevelupRes)
	TFDirector:addProto(s2c.LEVELUP_REWARD_RES, self, self.onReceiveLevelupRewardRes)


    --签到开关监听
	self.serverSwitch = function ( events )
		-- if events.data[1] == ServerSwitchType.Sign then
		     if ServerSwitchManager:isSignOpen() then
			     self:openFuliType(EnumFuLiType.Sign)
			 else
			     self:closeFuliType(EnumFuLiType.Sign)
			 end
			 -- TFDirector:dispatchGlobalEventWith("refresh_fuli")
		-- elseif events.data[1] == ServerSwitchType.RedPacketRain then

			if ServerSwitchManager:isLuckyRainOpen() then
			    self:openFuliType(EnumFuLiType.RedPacketRain)
			else
			 	self:closeFuliType(EnumFuLiType.RedPacketRain)
			end
			TFDirector:dispatchGlobalEventWith("refresh_fuli")
		-- end
	end
	TFDirector:addMEGlobalListener(ServerSwitchManager.AllServerSwitchChange, self.serverSwitch)

	--每日福利
	TFDirector:addProto(s2c.GET_DAILY_WELLFARE, self, self.onGetDailyWellfareRes)
	TFDirector:addProto(s2c.GET_FREE_WELLFARE_RESULT, self, self.onGetFreeWellfareRes)

	--成长基金
	TFDirector:addProto(s2c.GROWTH_FUND_INFO, self, self.onGrowthFundInfo)
	TFDirector:addProto(s2c.RECEIVE_GROWTH_FUND_RESULT, self, self.onReceiveGrowthFundResult)
	TFDirector:addProto(s2c.BUY_GROWTH_FUND_RESULT, self, self.onBuyGrowthFundResult)

	--红包雨相关
	TFDirector:addProto(s2c.RAIN_OPEN_TIME, self, self.onRainOpenTime)
	TFDirector:addProto(s2c.RAIN_INFO, self, self.onRainInfo)
	TFDirector:addProto(s2c.RAIN_START_RESULT, self, self.onRainStartResult)
	TFDirector:addProto(s2c.RAIN_BACK_RESULT, self, self.onRainBackResult)
	TFDirector:addProto(s2c.RAIN_CIRT_INFO, self, self.onRainCirtInfo)
	TFDirector:addProto(s2c.RAIN_LIST_RESULT, self, self.onRainListResult)

	self:restart()
end

function FuliManager:restart()
	-- body
	self.levelupInfo = nil
	self.diningData = nil
	self.GetSignRequest = nil

	self.requests = {}
	self.openLayer = false

	self.growthFundInfo = {}

	self.redPacketRainInfos = {}

	self:startRainTimer()
end

function FuliManager:setOpenFuliType( type )
	self.fuliType = type
end

function FuliManager:startOpenFuliLayer( type )
	self.fuliType = type
	self.requests = {}
	self.openLayer = true
	self.requests['sendLevelupReq'] = true
	self.requests['sendGetDailyWellfareReq'] = true

	self:sendLevelupReq()
	self:sendGetDailyWellfareReq()
end

function FuliManager:autoOpenFuliLayer( )
	if not self.openLayer then return end
	for i,v in pairs(self.requests) do
		if v then
			return
		end
	end
	self.requests = {}
	self.openLayer = false
	if self.fuliType ~= nil then
	     self:openFuliLayer(self.fuliType)
		 self.fuliType = nil
	end
end

--打开福利界面(指定显示的福利类型,默认是签到)
function FuliManager:openFuliLayer(fuLiType)
	-- if fuLiType == nil then fuLiType = EnumFuLiType.Sign end

	local fuliLayer  = require("lua.logic.fuli.FuliMainLayer"):new()
    AlertManager:addLayer(fuliLayer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    fuliLayer:loadData(fuLiType)
    AlertManager:show()
end

function FuliManager:openFuliType( fuliType )
    if fuliType == nil then return end
	for i,v in ipairs(self.fuliTypeList) do
		if v > fuliType then 
		   table.insert( self.fuliTypeList, i , fuliType )
		   return
		end
		if v == fuliType then 
			return 
		end
	end
	self.fuliTypeList[#self.fuliTypeList + 1] = fuliType
end

function FuliManager:closeFuliType( fuLiType )
	if fuLiType == nil then return end
	for i,v in ipairs(self.fuliTypeList) do
		if v == fuLiType then
		   table.remove( self.fuliTypeList, i )
		   return
		end
	end
end

function FuliManager:onReceiveGetDiningList( event )
	-- body
	local data = event.data
	table.sort( data.info, function ( t1, t2 ) return t1.type < t2.type end)
	self.diningData = {}
	self.diningData = data.info
	TFDirector:dispatchGlobalEventWith(FuliManager.ROLE_EAT_TILI, 0)
end


function FuliManager:onReceiveSignStatus(event)
	hideLoading()
	self.GetSignRequest = event.data

	-- print("=====================  sign status", event.data)
	TFDirector:dispatchGlobalEventWith("getSignRequest")
end

function FuliManager:onReceiveSignResult(event)
	hideLoading()

	self.GetSignRequest.isSign = true --已签到

	TFDirector:dispatchGlobalEventWith("signResult")
end

function FuliManager:IsSignToday()
	if self.GetSignRequest == nil or self.GetSignRequest.isSign == nil then
		return false
	end

	return (not self.GetSignRequest.isSign)
end

function FuliManager:onReceiveLevelupRes( event )
	local data = event.data
	hideLoading()
	print('onReceiveLevelupRes:',data.info)
	self.levelupInfo = data.info or {}
	for data in LevelRewardData:iterator() do
		local canAdd = true
		for i,v in pairs(self.levelupInfo) do
			if v.id == data.id then
				canAdd = false
				break
			end
		end
		if canAdd then
			self.levelupInfo[#self.levelupInfo + 1] = {id = data.id,state = 0, subState = 0,level = data.level}
		end
	end

	local checkState = function ( info )
		return (info.state == 1) or (info.subState == 1)
	end

	local getOverNum = function ( info )
		local num = 0
		if info.state == 2 then
			num = num + 1
		end
		if info.subState == 2 then
			num = num + 1
		end
		return num
	end
	table.sort( self.levelupInfo, function ( a,b )
		local s1 = checkState(a)
		local s2 = checkState(b)

		if s1 and s2 then
			return a.id < b.id
		elseif s1 and not s2 then
			return true
		elseif not s1 and s2 then
			return false
		else
			local n1 = getOverNum(a)
			local n2 = getOverNum(b)
			if n1 ~= n2 then
				return n1 < n2
			end
		end
		
		return a.id < b.id
	end )
	print('onReceiveLevelupRes:',data.info)
	-- if self.fuliType ~= nil then
	--      self:openFuliLayer(self.fuliType)
	-- 	 self.fuliType = nil
	-- end
	TFDirector:dispatchGlobalEventWith(FuliManager.FRESH_LEVELUP, 0)
	self.requests['sendLevelupReq'] = false
	self:autoOpenFuliLayer()
end

function FuliManager:onReceiveLevelupRewardRes( event )
	hideLoading()
	local data = event.data
	-- print('onReceiveLevelupRewardRes:',data)

end

function FuliManager:getILevelupInfoById( id )
	for k,info in pairs(self.levelupInfo) do
		if info.id == id then
		    return info
		end
	end
	return nil
end

function FuliManager:onGetDailyWellfareRes( event )
	hideLoading()
	if event.data then
		self.fuliEveryDayInfo = {}
		local itemInfos = {}
		local freeInfo = {}
		for i,v in ipairs(event.data.list) do
			local info = DailyWellfareData:objectByID(v.id)
			
			if info.recharge_id ~= 0 then
				local itemInfo = {}
				itemInfo.payInfo = PayManager:getRechargeById(info.recharge_id)
				itemInfo.rewards = {}

				local rewards = RewardGroupData:getRewardTableByID(itemInfo.payInfo.reward_group)
				for _, id in pairs(rewards) do
					local reward = RewardData:getGoodsById(id)
			        local rewardInfo = BaseDataManager:getReward(reward)
					itemInfo.rewards[#itemInfo.rewards + 1] = rewardInfo
			    end
			    itemInfo.status = v.status
				itemInfos[#itemInfos + 1] = itemInfo
			else
				freeInfo.rewards = {}
				freeInfo.id = v.id
				freeInfo.status = v.status
				local rewards = RewardGroupData:getRewardTableByID(info.reward_group)
				for _, id in pairs(rewards) do
					local reward = RewardData:getGoodsById(id)
			        local rewardInfo = BaseDataManager:getReward(reward)
					freeInfo.rewards[#freeInfo.rewards + 1] = rewardInfo
			    end
			end
		end

		self.fuliEveryDayInfo.itemInfos = itemInfos
		self.fuliEveryDayInfo.freeInfo = freeInfo
	end
	TFDirector:dispatchGlobalEventWith(FuliManager.DAILY_WELLFARE_UPDATE, 0)
	TFDirector:dispatchGlobalEventWith("refresh_fuli", 0)
	self.requests['sendGetDailyWellfareReq'] = false
	self:autoOpenFuliLayer()
end

function FuliManager:onGetFreeWellfareRes( )
	hideLoading()
end
--==================================  proto  ===========================

function FuliManager:GetSignStatus()
	--请求当前状态
	showLoading()
    TFDirector:send(c2s.GET_SIGN_REQUEST, {false} )
end

function FuliManager:SignRequest()
	showLoading()
	TFDirector:send(c2s.SIGN_REQUEST, {false})
end

function FuliManager:sendDiningRequest( ... )
	self:sendWithLoading(c2s.DINING_REQUEST,false)
end

function FuliManager:sendLevelupReq( ... )
	self:sendWithLoading(c2s.LEVELUP_REQ,false)
end

function FuliManager:sendLevelupRewardReq( id )
	self:sendWithLoading(c2s.LEVELUP_REWARD_REQ,id)
end

function FuliManager:sendLevelupSubRewardReq( id )
	self:sendWithLoading(c2s.LEVELUP_SUB_REWARD_REQ,id)
end

--发送获取每日福利请求
function FuliManager:sendGetDailyWellfareReq( )
	self:sendWithLoading(c2s.GET_DAILY_WELLFARE_REQUEST, "")
end

function FuliManager:sendGetFreeWellfareReq( id )
	self:sendWithLoading(c2s.GET_FREE_WELLFARE_REQUEST, id)
end


--=================================  end =================================

--================================= redpoint =============================

--主城福利红点
function FuliManager:isMainRedPoint()
	if self:isHaveRedPointSign() then return true end
	if self:isHaveRedPointDining() then return true end
	if self:isHaveRedPointLevelup() then return true end
	if self:isHaveRedPointReBuy() then return true end
	if self:isHaveDailyWellfareRed() then return true end
	if self:hasGrowthFundRedPoint() then return true end
	if self:isRedpacketRedPoint() then return true end

	return false
end

--签到红点
function FuliManager:isHaveRedPointSign()
	if not ServerSwitchManager:isSignOpen() then return false end
	if self.GetSignRequest == nil then
		return false
	end

	return not self.GetSignRequest.isSign
end

--领取体力红点
function FuliManager:isHaveRedPointDining( ... )
	local data = DietData:getDietList()
    if not data then return false end 
    local times = os.date("%H",GetGameTime())
    -- local diningData = MainPlayer.diningData
    --zzteng  change
    local diningData = self.diningData
    if diningData then
        for k,v in pairs(data) do
            local item = diningData[k]
            if not item then return end
            if v.beginT <= tonumber(times) and tonumber(times) < v.endT and item.status ~= 3 then
                return true
            end
        end
    end
    return false
end

--等级礼包red
function FuliManager:isHaveRedPointLevelup( ... )
	if type(self.levelupInfo) ~= 'table' then return false end 
	for k,v in pairs(self.levelupInfo) do
	    if v.state == 1 then
		   return true
		end
		if v.subState == 1 then
			return true
		end
	end
	return false
end

--回购红点
function FuliManager:isHaveRedPointReBuy()
	return RebuyManager:isRedPoint()
end

function FuliManager:isHaveDailyWellfareRed( )
	if self.fuliEveryDayInfo and self.fuliEveryDayInfo.freeInfo then
		return self.fuliEveryDayInfo.freeInfo.status == 1
	end
	return false
end

--========================================================================

function FuliManager:openSignLayer()
	local layer  = require("lua.logic.sign.NewSignLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function FuliManager:openSignRuleLayer()
	local layer  = require("lua.logic.sign.SignRuleLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

--------------成长基金------------
--获取成长基金详情
function FuliManager:sendGetGrowthFundInfo()
	self:send(c2s.GET_GROWTH_FUND_INFO, "")
end

--领取成长基金请求
function FuliManager:sendReceiveGrowthFundRequest(id)
	self:sendWithLoading(c2s.RECEIVE_GROWTH_FUND_REQUEST, id)
end

--购买成长基金请求
function FuliManager:sendBuyGrowthFundRequest()
	self:sendWithLoading(c2s.BUY_GROWTH_FUND_REQUEST, "")	
end

function FuliManager:onGrowthFundInfo( event )
	local data = event.data

	self.growthFundInfo = {}
	self.growthFundInfo.state = data.state
	self.growthFundInfo.items = {}

	for info in GrowthFund:iterator() do
		local item = {}
		item.id = info.id
		item.level = info.level
		item.sycee = info.sycee
		item.state = 0
		for _,id in ipairs(data.id or {}) do
			if info.id == id then
				item.state = 2
				break
			end
		end
		self.growthFundInfo.items[#self.growthFundInfo.items + 1] = item
	end

	self:updateGrowthFundItemsState()

	TFDirector:dispatchGlobalEventWith(FuliManager.GROWTH_FUND_UPDATE, 0)
	TFDirector:dispatchGlobalEventWith("refresh_fuli", 0)
end

function FuliManager:updateGrowthFundItemsState()
	if not self.growthFundInfo or not self.growthFundInfo.items then return false end
	local cur_level = MainPlayer:getLevel()
	local state = self.growthFundInfo.state
	local has_red_point = false
	for i,item in ipairs(self.growthFundInfo.items) do
		if 	item.state ~= 2 and state == 1 then
			if item.level <= cur_level then
				item.state = 1
				has_red_point = true
			else
				item.state = 0
			end
		end
	end
	return has_red_point
end

function FuliManager:onReceiveGrowthFundResult( event )
	hideLoading()
end

function FuliManager:onBuyGrowthFundResult( event )
	hideLoading()
end

function FuliManager:hasGrowthFundRedPoint( )
	return self:updateGrowthFundItemsState()
end

----------------------红包雨--------------------------------
function FuliManager:openRedPacketRainLayer(rainInfo, bullets)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.RedPacketRainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(rainInfo, bullets)
	AlertManager:show()
end

function FuliManager:getRedPacketRainData()
	return {
		money = 200,
		size = 10,
		cirt = 1,
		cirt_money = 1000,
	}
end

--进入红包雨请求
function FuliManager:sendRainRequest(id)
	self:sendWithLoading(c2s.RAIN_REQUEST, id)
end

function FuliManager:sendRainStart( id )
	self:sendWithLoading(c2s.RAIN_START, id)
end

function FuliManager:sendRainBack( id, num )
	self:sendWithLoading(c2s.RAIN_BACK, id, num)
end

--红包雨相关时间
function FuliManager:onRainOpenTime( event )
	hideLoading()
end

--进入红包雨响应
function FuliManager:onRainInfo( event )
	hideLoading()
	local data = event.data
	local rainInfo = self:getRedPacketRainById(data.id)
	self:openRedPacketRainLayer(rainInfo, data.infos)
end

--红包雨开始响应
function FuliManager:onRainStartResult( event )
	hideLoading()
	TFDirector:dispatchGlobalEventWith(FuliManager.REDPACKET_START, event.data)
end

--红包雨结束响应
function FuliManager:onRainBackResult( event )
	hideLoading()

	TFDirector:dispatchGlobalEventWith(FuliManager.REDPACKET_END, event.data)
end

--红包雨弹幕响应
function FuliManager:onRainCirtInfo( event )
	hideLoading()

	TFDirector:dispatchGlobalEventWith(FuliManager.REDPACKET_BULLET_UPDATE, event.data)
end

--红包雨列表响应
function FuliManager:onRainListResult( event )
	hideLoading()

	local data = event.data

	table.sort(data.rainInfos, function( t1, t2 )
		return t1.startTime < t2.startTime
	end)

	self.redPacketRainInfos = {}
	-- for i,rainInfo in ipairs(data.rainInfos or {}) do
	-- 	self.redPacketRainInfos[rainInfo.id] = rainInfo
	-- end
	self.redPacketRainInfos = data.rainInfos or {}
	TFDirector:dispatchGlobalEventWith(FuliManager.REDPACKET_STATE_UPDATE, 0)
end

function FuliManager:getRedPacketRainById(id)
	for i,v in ipairs(self.redPacketRainInfos) do
		if v.id == id then
			return v 
		end
	end
	return nil
end

function FuliManager:startRainTimer( )
	self:removeRainTimer()

	local states = {
		WILL_OPEN = 1,
		OPENED = 2,
		STARTED = 3,
		END = 4,
	}

	self.activityTimer = TFDirector:addTimer(1000, -1, nil,
	function ()
		local cur_time = GetGameTime()
		local is_change = false

		for i,v in ipairs(self.redPacketRainInfos) do
			local state = 0
			if cur_time < v.openTime then
				state = states.WILL_OPEN
			elseif cur_time < v.startTime then
				state = states.OPENED
			elseif cur_time < v.endTime then
				state = states.STARTED
			else
				state = states.END
			end

			if v.old_state ~= state then
				v.old_state = state
				is_change = true
			end

			if v.old_get ~= v.state then
				v.old_get = v.state
				is_change = true
			end
		end

		if is_change then
			TFDirector:dispatchGlobalEventWith(FuliManager.REDPACKET_STATE_UPDATE, 0)
		end
	end)
end

function FuliManager:removeRainTimer( )
	if self.activityTimer then
		TFDirector:removeTimer(self.activityTimer)
		self.activityTimer = nil
	end
end

function FuliManager:dispose()
	self:removeRainTimer()
end

--主界面获取红包雨图标状态
function FuliManager:getOpenRainInfo()
	if not ServerSwitchManager:isLuckyRainOpen() then return nil end
	local game_time = GetGameTime()
	for i,rainInfo in ipairs(self.redPacketRainInfos) do
		if not rainInfo.state and (game_time >= rainInfo.openTime or game_time >= rainInfo.startTime) and game_time < rainInfo.endTime
			and MainPlayer:getLevel() >= rainInfo.level then
			return rainInfo
		end
	end
	return nil
end

function FuliManager:isRedpacketRedPoint()
	if not ServerSwitchManager:isLuckyRainOpen() then return nil end
	local game_time = GetGameTime()
	for i,rainInfo in ipairs(self.redPacketRainInfos) do
		if not rainInfo.state and game_time >= rainInfo.startTime and game_time < rainInfo.endTime
			and MainPlayer:getLevel() >= rainInfo.level then
			return true
		end
	end
	return false
end

return FuliManager:new()