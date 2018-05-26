-- 运营活动
-- Author: Jing
-- Date: 2016-11-07
--

local OnlineActivitiesManager = class('OnlineActivitiesManager',  BaseManager)

OnlineActivitiesManager.MSG_ACTIVITY_UPDATE = "OnlineActivitiesManager.MSG_ACTIVITY_UPDATE"
OnlineActivitiesManager.MSG_ACTIVITY_GET_REWARD = "OnlineActivitiesManager.MSG_ACTIVITY_GET_REWARD"
OnlineActivitiesManager.MSG_ACTIVITY_TURNTABLE_REWARD = "OnlineActivitiesManager.MSG_ACTIVITY_TURNTABLE_REWARD"
OnlineActivitiesManager.MSG_MAMMON_RECORD_UPDATE = "OnlineActivitiesManager.MSG_MAMMON_RECORD_UPDATE"
OnlineActivitiesManager.MSG_MAMMON_RESULT = "OnlineActivitiesManager.MSG_MAMMON_RESULT"
OnlineActivitiesManager.MSG_LIMIT_GENERAL_UPDATE = "OnlineActivitiesManager.MSG_LIMIT_GENERAL_UPDATE"
OnlineActivitiesManager.MSG_MINI_SEVEN_UPDATE = "OnlineActivitiesManager.MSG_MINI_SEVEN_UPDATE"
OnlineActivitiesManager.MSG_YEAR_MONSTER_UPDATE = "OnlineActivitiesManager.MSG_YEAR_MONSTER_UPDATE"
OnlineActivitiesManager.UES_YEAR_MONSTER_PROP_RESULT = "OnlineActivitiesManager.UES_YEAR_MONSTER_PROP_RESULT"
OnlineActivitiesManager.RECEIVE_YEAR_MONSTER_REWARD_RESULT = "OnlineActivitiesManager.RECEIVE_YEAR_MONSTER_REWARD_RESULT"
OnlineActivitiesManager.MSG_LANTERN_UPDATE = "OnlineActivitiesManager.MSG_LANTERN_UPDATE"
OnlineActivitiesManager.MSG_MAKE_LANTERN_RESULT = "OnlineActivitiesManager.MSG_MAKE_LANTERN_RESULT"
OnlineActivitiesManager.MSG_SALVAGE_LANTERN_RESULT = "OnlineActivitiesManager.MSG_SALVAGE_LANTERN_RESULT"
OnlineActivitiesManager.MSG_HUNTRESULT_INFO = "OnlineActivitiesManager.MSG_HUNTRESULT_INFO"
OnlineActivitiesManager.MSG_GET_ACTIVITY_RANK = "OnlineActivitiesManager.MSG_GET_ACTIVITY_RANK"
OnlineActivitiesManager.MSG_GET_Hunt_BOX_REWARD = "OnlineActivitiesManager.MSG_GET_Hunt_BOX_REWARD"


OnlineActivitiesManager.DailyOnline 		= 1	--每日在线
OnlineActivitiesManager.ContinuousLogin 	= 2	--连续登陆
OnlineActivitiesManager.LevelUpSycee 		= 3	--升级送元宝
OnlineActivitiesManager.PowerUp 			= 4	--升战力得奖励
-- OnlineActivitiesManager.Dining 				= 5 --吃包子(根据策划需求,活动砍掉吃包子)
OnlineActivitiesManager.DailyPay       		= 6 --单日累计充值
OnlineActivitiesManager.ContinuousPay       = 7 --活动期间连续充值
OnlineActivitiesManager.TotalPay			= 8 --活动期间累计充值
OnlineActivitiesManager.DailySyceeCost		= 9 --活动期间每日消耗  或者 累计消耗
OnlineActivitiesManager.DailyPaySingle      = 10--活动期间每日单笔充值
OnlineActivitiesManager.TurnTable           = 11--转盘抽奖
OnlineActivitiesManager.RewardExchange      = 12--兑换奖励
OnlineActivitiesManager.MammonReward        = 13--乾坤一掷
OnlineActivitiesManager.DiscountSelling     = 14--限时打折
OnlineActivitiesManager.LotteryCountRebate  	= 15--抽签次数返利
OnlineActivitiesManager.TenLotteryCountExtra	= 16--十连抽额外奖励
OnlineActivitiesManager.LotteryScoreRank		= 17--抽签积分排行
OnlineActivitiesManager.LotteryScoreExchange	= 18--抽签积分兑换
OnlineActivitiesManager.CoinCost 				= 19--活动期间每日消耗元宝  或者 累计消耗元宝
OnlineActivitiesManager.TotalLogin 				= 20--累计登录
OnlineActivitiesManager.LimitGeneral 			= 22--限时神将
OnlineActivitiesManager.StaminaBuy 			= 23--体力购买次数
OnlineActivitiesManager.ArenaScore 			= 24--封神演武积分
OnlineActivitiesManager.CoinBuy  			= 25--日常铜币购买
OnlineActivitiesManager.DrawLottery 		= 26--仙灵宝镜次数
OnlineActivitiesManager.Adventure 			= 27--山海奇遇次数
OnlineActivitiesManager.PetCatch 			= 28--宠物捕捉次数
OnlineActivitiesManager.SpiritBuy 			= 29--精力购买
OnlineActivitiesManager.DailyCourtesy 		= 30--新版合成活动
OnlineActivitiesManager.MiniSeven 			= 31--缩略版七天
OnlineActivitiesManager.NewYearHit 			= 32--新年打年兽
OnlineActivitiesManager.LanternAct 			= 33--元宵活动
OnlineActivitiesManager.TreasureHunt 		= 34--寻宝活动

OnlineActivitiesManager.CombosActivity      = 99		--组合活动
OnlineActivitiesManager.OpenRedPacket 		= 200		--开服红包
OnlineActivitiesManager.OpenCompetition 	= 201		--开服大比拼
OnlineActivitiesManager.LimitSell 			= 202		--超值返利

--[[
	temTitle 	每个物品项显示的标题	localizable.activity_desc_type
	isExchange	是否为兑换
	isRank		是否为排行
	isScore		是否为排行积分
	targetType	进度图标类型
	targetImg	左上显示图片
--]]
OnlineActivitiesManager.ActCustomInfo = {
	[OnlineActivitiesManager.DailyOnline] 			= {itemTitle = 8},
	[OnlineActivitiesManager.LevelUpSycee] 			= {itemTitle = 9},
	[OnlineActivitiesManager.ContinuousLogin] 		= {itemTitle = 10, targetImg = "danglutianshuzi.png"},
	[OnlineActivitiesManager.PowerUp] 				= {itemTitle = 11, targetImg = "zhandoulizi.png"},
	[OnlineActivitiesManager.DailyPay] 				= {itemTitle = 1, targetType = HeadResType.Sycee, targetImg = "img_yichongzhi.png"},
	[OnlineActivitiesManager.ContinuousPay] 		= {itemTitle = 2},
	[OnlineActivitiesManager.TotalPay] 				= {itemTitle = 13, targetType = HeadResType.Sycee, targetImg = "img_yichongzhi.png"},
	[OnlineActivitiesManager.DailySyceeCost] 		= {itemTitle = 4, targetType = HeadResType.Sycee, targetImg = "img_leijixiaohao.png"},
	[OnlineActivitiesManager.DailyPaySingle] 		= {itemTitle = 3},
	[OnlineActivitiesManager.LotteryCountRebate] 	= {itemTitle = 6, targetImg = "chouqiancishuzi.png"},
	[OnlineActivitiesManager.CombosActivity] 		= {itemTitle = 14},
	[OnlineActivitiesManager.DailyCourtesy] 		= {itemTitle = 14},
	[OnlineActivitiesManager.RewardExchange] 		= {isExchange = true},
	[OnlineActivitiesManager.LotteryScoreExchange] 	= {isExchange = true, isScore = true},
	[OnlineActivitiesManager.CoinCost] 				= {itemTitle = 5, targetType = HeadResType.Coin, targetImg = "img_leijixiaohao.png"},
	[OnlineActivitiesManager.LotteryScoreRank] 		= {isRank = true},
	[OnlineActivitiesManager.TotalLogin] 			= {itemTitle = 12, targetImg = "danglutianshuzi.png"},
	[OnlineActivitiesManager.StaminaBuy] 			= {itemTitle = 15, targetImg = "img_yiwancheng.png"},
	[OnlineActivitiesManager.ArenaScore] 			= {itemTitle = 16, targetImg = "img_yiwancheng.png"},
	[OnlineActivitiesManager.CoinBuy] 				= {itemTitle = 17, targetImg = "img_yiwancheng.png"},
	[OnlineActivitiesManager.DrawLottery] 			= {itemTitle = 18, targetImg = "img_yiwancheng.png"},
	[OnlineActivitiesManager.Adventure] 			= {itemTitle = 19, targetImg = "img_yiwancheng.png"},
	[OnlineActivitiesManager.PetCatch] 				= {itemTitle = 20, targetImg = "img_yiwancheng.png"},
	[OnlineActivitiesManager.SpiritBuy] 			= {itemTitle = 21, targetImg = "img_yiwancheng.png"},
}

--[[
	panel_0 : 右上  活动时间和活动内容
	panel_1 : 左上  文字图片，活动进度值，进度值icon
	panel_2 : 左上  两个文字图片，活动进度值，进度值icon
	panel_3 : 左上  排行榜，积分和排行
	panel_4 : 左上  宝箱图标
	panel_theme2 : 组合活动专用
	panel_xiangou : 限时打折活动专用
	panel_right1 : 单页活动 显示内容---活动时间和内容，奖励物品，跳转物品和背景图片  需要特别配置---跳转，背景图片
]]
OnlineActivitiesManager.ActCustomShowInfo = {
	[OnlineActivitiesManager.DailyOnline] 				= {panel_0 = true, panel_4 = true},
	[OnlineActivitiesManager.DiscountSelling] 			= {panel_xiangou = true},
	[OnlineActivitiesManager.CombosActivity] 			= {panel_theme2 = true},
	[OnlineActivitiesManager.DailyCourtesy] 			= {panel_theme2 = true},
	[OnlineActivitiesManager.RewardExchange] 			= {panel_0 = true, panel_2 = true},
	[OnlineActivitiesManager.TenLotteryCountExtra] 		= {panel_right1 = true},
	[OnlineActivitiesManager.LotteryScoreExchange] 		= {panel_0 = true, panel_2 = true},
	[OnlineActivitiesManager.LotteryScoreRank] 			= {panel_0 = true, panel_3 = true},
	[OnlineActivitiesManager.DailyPaySingle] 			= {panel_0 = true, panel_4 = true},
	[OnlineActivitiesManager.OpenCompetition] 			= {panel_vs = true},
	[OnlineActivitiesManager.OpenRedPacket] 			= {panel_hongbao = true},
	[OnlineActivitiesManager.LimitSell] 				= {panel_pay_back = true},
}

--1 为前往充值 默认
--2 为领取置灰
OnlineActivitiesManager.BtnDefaultStatus = {
	-- [1] = 2,
	-- [2] = 2,
	-- [3] = 2,
	-- [4] = 2,
	-- [9] = 2,
}

function OnlineActivitiesManager:ctor()

	self.is_first = false
    -- 更新活动列表
    TFDirector:addProto(s2c.ACTIVITY_INFO_LIST, self, self.updateActivityListEvent)

    -- 更新单个的活动
    TFDirector:addProto(s2c.ACTIVITY_INFO, self, self.updateSingleActivityEvent)

    -- 参加／兑换活动结果回调
	TFDirector:addProto(s2c.GOT_ACTIVITY_REWARD_RESULT, self, self.recvActivityRewardResultEvent)
	
	--交换活动
	TFDirector:addProto(s2c.GET_EXCHANGE, self, self.onGetExchangeInfo)

	TFDirector:addProto(s2c.EXCHANGE_RESULT, self, self.onExchangeResultEvent)

	TFDirector:addProto(s2c.GET_TURN_TABLE, self, self.onGetTurntableInfo)
	TFDirector:addProto(s2c.TURN_TABLE_RESULT, self, self.onTurnTableResponse)

	TFDirector:addProto(s2c.GET_SELLING, self, self.onDiscountSellingInfo)
	TFDirector:addProto(s2c.BUY_SELLING_RESULT, self, self.onBuySellingResult)
	TFDirector:addProto(s2c.GET_ACTIVITY_RANK, self, self.onGetActRankResult)

	--开服红包
	TFDirector:addProto(s2c.GET_OPEN_RED_PACKET, self, self.onGetOpenRedPacket)
	TFDirector:addProto(s2c.RECEIVE_OPEN_RED_PACKET_RESULT, self, self.onReceiveOpenRedPacketResult)

	--开服大比拼
	TFDirector:addProto(s2c.GET_OPEN_COMPETITION, self, self.onGetOpenCompetition)
	TFDirector:addProto(s2c.RECEIVE_OPEN_COMPETITION_REWARD_RESULT, self, self.onReceiveOpenCompetitionRewardResult)

	--乾坤一掷
	TFDirector:addProto(s2c.GET_MAMMON, self, self.onGetMammon)
	TFDirector:addProto(s2c.MAMMON_RESULT, self, self.onMammonResult)
	TFDirector:addProto(s2c.MAMMON_RECORD_UPDATE, self, self.onMammonRecordUpdate)

	--限时神将
	TFDirector:addProto(s2c.TIME_LIMIT_GENERAL, self, self.onTimeLimitGeneral)
	TFDirector:addProto(s2c.DRAW_GENERAL_RESULT, self, self.onDrawGeneralResult)

	--新年活动
	TFDirector:addProto(s2c.GET_MINI_SEVEN, self, self.onGetMiniSeven)
	TFDirector:addProto(s2c.RECEIVE_MINI_SEVEN_RESULT, self, self.onReceiveMiniSevenResult)

	--年兽活动
	TFDirector:addProto(s2c.GET_YEAR_MONSTER_INFO, self, self.onGetYearMonsterInfo)
	TFDirector:addProto(s2c.USE_YEAR_MONSTER_PROP_RESULT, self, self.onUseYearMonsterPropResult)
	TFDirector:addProto(s2c.RECEIVE_YEAR_MONSTER_REWARD_RESULT, self, self.onReceiveYearMonsterRewardResult)

	--元宵活动
	TFDirector:addProto(s2c.GET_LANTERN_INFO, self, self.onGetLanternInfo)
	TFDirector:addProto(s2c.MAKE_LANTERN_RESULT, self, self.onMakeLanternResult)
	TFDirector:addProto(s2c.SALVAGE_LANTERN_RESULT, self, self.onSalvageLanternResult)

	--寻宝活动
	TFDirector:addProto(s2c.TREASURE_HUNT, self, self.onTreasureHuntInfo)
	TFDirector:addProto(s2c.HUNT_RESULT, self, self.onHuntResultInfo)
	TFDirector:addProto(s2c.HUNT_RECORDS, self, self.onHuntRecordsInfo)


    -- 记录活动列表（活动的相关信息 id 名字 type ）
    self.ActivityInfoList 	= TFMapArray:new()
    self.turntableActivity = {}

    -- 可领取在线奖励
    self.canGetReward = false
    self.fullActInfoFlag = {}
    self.fullCustomActInfos = {}

  	self.OnlineRewardData = {}
  	self.OnlineRewardData.hasGetReward          		= 0    -- 已领奖的次数
  	self.OnlineRewardData.nextRewardTime				= 0	   -- 在线奖励倒计时
end

-- 重新清除数据
function OnlineActivitiesManager:restart()
	
    -- 可领取在线奖励
	self.canGetReward = false

	   -- 在线奖励
  	self.OnlineRewardData = {}
  	self.OnlineRewardData.hasGetReward          		= 0    -- 已领奖的次数
  	self.OnlineRewardData.nextRewardTime				= 0	   -- 在线奖励倒计时

	self.ActivityInfoList:clear()
	self.turntableActivity = {}

	self.autoPush = false

	self.fullActInfoFlag = {}

	self.CustomActInfos = {}
	self.fullCustomActInfos = {}

	self.mammonRewardActInfo = {} -- 乾坤一掷活动
end

function OnlineActivitiesManager:reset()

end

function OnlineActivitiesManager:updateActivityListEvent(event)
	-- print('updateActivityListEvent:',event.data.info)
	print('updateActivityListEvent:',event.data)
	if event.data == nil or event.data.info == nil then
		return
	end
	self.fullActInfoFlag = {}
	self.CustomActInfos = {}
	self.ActivityInfoList:clear()

	for i,v in pairs(event.data.info) do
		-- if v.type ~= OnlineActivitiesManager.OpenCompetition and v.type ~= OnlineActivitiesManager.LimitSell then
			local sinleActivityInfo = self:updateSingleActivityData(v)
			if sinleActivityInfo.actCustomInfo.isExchange then
				self.fullActInfoFlag[v.id] = false
				self:sendGetExchangeInfo(v.id)
			elseif v.type == OnlineActivitiesManager.DiscountSelling then
				self.fullActInfoFlag[v.id] = false
				self:sendGetDiscountSellingInfo(v.id)
			elseif sinleActivityInfo.actCustomInfo.isRank then
				self.fullActInfoFlag[v.id] = false
				self:sendGetActRankRequest(v.id)
			elseif sinleActivityInfo.type == OnlineActivitiesManager.OpenRedPacket then
				self.fullActInfoFlag[v.id] = false
				self:sendGetOpenRedPacket(v.id)
			elseif sinleActivityInfo.type == OnlineActivitiesManager.OpenCompetition then
				self.fullActInfoFlag[v.id] = false
				self:sendGetOpenCompetitionRequest(v.id)
			elseif sinleActivityInfo.type == OnlineActivitiesManager.LimitSell then
				sinleActivityInfo.name = localizable.activity_some_names[3]
			elseif sinleActivityInfo.type == OnlineActivitiesManager.MammonReward then
				self.ActivityInfoList:removeById(v.id)
				self.CustomActInfos[OnlineActivitiesManager.MammonReward] = sinleActivityInfo
			elseif sinleActivityInfo.type == OnlineActivitiesManager.LimitGeneral then
				self.ActivityInfoList:removeById(v.id)
				self.CustomActInfos[OnlineActivitiesManager.LimitGeneral] = sinleActivityInfo
				self:sendGetTimeLimitGeneralRequest()
			elseif sinleActivityInfo.type == OnlineActivitiesManager.MiniSeven then
				self.ActivityInfoList:removeById(v.id)
				self.CustomActInfos[OnlineActivitiesManager.MiniSeven] = sinleActivityInfo
				self:sendGetMiniSevenRequest()
			elseif sinleActivityInfo.type == OnlineActivitiesManager.NewYearHit then
				self.ActivityInfoList:removeById(v.id)
				self.CustomActInfos[OnlineActivitiesManager.NewYearHit] = sinleActivityInfo
				self:sendGetYearMonsterInfoRequest()
			elseif sinleActivityInfo.type == OnlineActivitiesManager.LanternAct then
				self.ActivityInfoList:removeById(v.id)
				self.CustomActInfos[OnlineActivitiesManager.LanternAct] = sinleActivityInfo
				self:sendGetLanternInfoRequest()
			elseif sinleActivityInfo.type == OnlineActivitiesManager.TreasureHunt then
				self.ActivityInfoList:removeById(v.id)
				self.CustomActInfos[OnlineActivitiesManager.TreasureHunt] = sinleActivityInfo
				self:sendTreasureHuntInfoRequest()
			end
		-- end
	end

	for i,v in ipairs(event.data.complexInfo or {}) do
		v.type = OnlineActivitiesManager.CombosActivity
		local sinleActivityInfo = self:updateSingleActivityData(v)
		
		sinleActivityInfo.activityList = {}
		for i,actId in ipairs(v.idList) do
			local actInfo = self.ActivityInfoList:objectByID(actId)
			self.ActivityInfoList:removeById(actId)
			if actInfo then
				sinleActivityInfo.activityList[#sinleActivityInfo.activityList + 1] = actInfo
				if i == 2 then
					sinleActivityInfo.items = actInfo.items
					sinleActivityInfo.itemActId = actInfo.id
				end
			else
				assert(false, string.format("complexInfo %s not find in single ", actId))
			end
		end
	end

	-- if self.autoPush and self:isFullActComplete() then
	-- 	self.autoPush = false
	-- 	self:openActivitiesLayer()
	-- end
	self:autoOpenActivitiesLayer()

	-- MainPlayer:addActivityIcon(EnumActivityType.OnlineActivity)
	-- CommonUiManager:addActivityIcon(EnumActivityType.OnlineActivity)
end

function OnlineActivitiesManager:isFullActComplete()
	for i,flag in pairs(self.fullActInfoFlag) do
		if not flag then
			return false
		end
	end
	return true
end

function OnlineActivitiesManager:autoOpenActivitiesLayer(  )
	if not self:isFullActComplete() then return end
	TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_UPDATE)

	if self.autoPush then
		self.autoPush = false
		self:openActivitiesLayer()
	end
end

function OnlineActivitiesManager:updateSingleActivityEvent(event)
	if event.data then
		local sinleActivityInfo = self:updateSingleActivityData(event.data)

		for actInfo in self.ActivityInfoList:iterator() do
			if actInfo.type == OnlineActivitiesManager.CombosActivity and actInfo.activityList then
				for i,info in ipairs(actInfo.activityList) do
					if info.id == sinleActivityInfo.id then
						actInfo.activityList[i] = sinleActivityInfo
						self.ActivityInfoList:removeById(sinleActivityInfo.id)
						if i == 2 then
							actInfo.items = sinleActivityInfo.items
							actInfo.itemActId = sinleActivityInfo.id
						end
						break
					end
				end
			end
		end

		if not sinleActivityInfo.actCustomInfo.isExchange then
			TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_UPDATE)
		end
	end
end

function OnlineActivitiesManager:sendGetExchangeInfo(id)
	TFDirector:send(c2s.GET_EXCHANGE_REQUEST, {id})
end

function OnlineActivitiesManager:sendGetDiscountSellingInfo(id)
	self.discountSellingId = id
	TFDirector:send(c2s.GET_SELLING_REQUEST, {id})
end

function OnlineActivitiesManager:sendBuyDiscountSellingRequest(id, itemId)
	self:sendWithLoading(c2s.BUY_SELLING_REQUEST, id, itemId)
end

function OnlineActivitiesManager:sendGetActRankRequest(id)
	self:send(c2s.GET_ACTIVITY_RANK_REQUEST, id)
end


function OnlineActivitiesManager:buyDiscountSelling()
	local sinleActivityInfo = self.ActivityInfoList:objectByID(self.discountSellingId)
	self:sendBuyDiscountSellingRequest(self.discountSellingId, sinleActivityInfo.sellinges[1][1].id)
end

function OnlineActivitiesManager:onGetExchangeInfo(event)
	-- event.data.id = "35"
	if event.data then
		local sinleActivityInfo = self.ActivityInfoList:objectByID(event.data.id)
		sinleActivityInfo.items = event.data.item
		-- self:updateSingleActivityData(event.data)
		table.sort(sinleActivityInfo.items, function (a, b)
			local sub1 = a.maxTimes - a.times
			local sub2 = b.maxTimes - b.times
			if sub1 == 0 and sub2 ~= 0 then 
				return false
			elseif sub1 ~= 0 and sub2 == 0 then 
				return true
			end
			return a.id < b.id
		end)
		self.fullActInfoFlag[event.data.id] = true
		self:autoOpenActivitiesLayer()
	end
	-- self.is_first = false
	-- print("~~~~~~~~~~~~~~~~~~~~~~~~~!!!!!!!!", event.data.item)
end

function OnlineActivitiesManager:onDiscountSellingInfo(event)
	if event.data then
		local sinleActivityInfo = self.ActivityInfoList:objectByID(event.data.id)
		sinleActivityInfo.curDay = event.data.days

		local selling = event.data.selling
		local items = {}
		for i,v in ipairs(selling) do
			items[v.days] = v.item
		end

		sinleActivityInfo.sellinges = items
		sinleActivityInfo.items = nil

		self.fullActInfoFlag[event.data.id] = true
		self:autoOpenActivitiesLayer()
	end
end

function OnlineActivitiesManager:onBuySellingResult( event )
	hideLoading()
end

function OnlineActivitiesManager:onGetActRankResult( event )
	hideLoading()
	local data = event.data
	-- print("=======onGetActRankResult=========",data)
	if data then
		local sinleActivityInfo = self.ActivityInfoList:objectByID(data.id)
		if not sinleActivityInfo then
			for k,v in pairs(self.CustomActInfos) do
				if v.id==data.id then
					sinleActivityInfo = v
					break
				end
			end
		end
		if not sinleActivityInfo then
			print("error!!! sinleActivityInfo is nil", data.id)
			return
		end
		data.rank = data.rank or {}
		sinleActivityInfo.actRankInfo = data

		local roleInfos = {}
		for i,v in ipairs(data.rank or {}) do
			roleInfos[v.rank] = v
		end

		local items = {}
		for i,reward in ipairs(data.rankReward or {}) do
			items[i] = reward
			items[i].minScore = data.minScore
			-- if data.rank then
			-- 	items[i].roleInfo = data.rank[i]
			-- end
			items[i].minRoleInfo = roleInfos[reward.rankMin]
			items[i].maxRoleInfo = roleInfos[reward.rankMax]
		end
		sinleActivityInfo.items = items
		self.fullActInfoFlag[data.id] = true
		self:autoOpenActivitiesLayer()
	end

	TFDirector:dispatchGlobalEventWith(OnlineActivitiesManager.MSG_GET_ACTIVITY_RANK)
end

function OnlineActivitiesManager:sendGetTurntableInfo(open)
	self.openTurntableLayer = open
	if self.turntableActivity.id then
		TFDirector:send(c2s.GET_TURN_TABLE_REQUEST, {self.turntableActivity.id})
	end
end

function OnlineActivitiesManager:onGetTurntableInfo(event)
	if self.openTurntableLayer then
		self.openTurntableLayer = false
		self.turntableActivity.ActInfo = event.data
		local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.TurntableActivityLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
		AlertManager:show()
	end
end

function OnlineActivitiesManager:sendTurnTableRequest(times)
	if self.turntableActivity.id then
		TFDirector:send(c2s.TURN_TABLE_REQUEST, {self.turntableActivity.id, times})
	end
end

function OnlineActivitiesManager:onTurnTableResponse(event)
	TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_TURNTABLE_REWARD, event.data)
end

function OnlineActivitiesManager:sendExchangeReward(id, itemId)
	TFDirector:send(c2s.EXCHANGE_REQUEST, {id, itemId})
end


function OnlineActivitiesManager:onExchangeResultEvent( event )
	print(event.data)
end

-----开服红包-----------------------
function OnlineActivitiesManager:sendGetOpenRedPacket(id )
	self:send(c2s.GET_OPEN_RED_PACKET_REQUEST, "")
end

function OnlineActivitiesManager:onGetOpenRedPacket( event )
	local sinleActivityInfo = self.ActivityInfoList:objectByID(event.data.id)
	sinleActivityInfo.name = localizable.activity_some_names[1]
	sinleActivityInfo.ActDetailInfo = event.data

	TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_UPDATE)
	self.fullActInfoFlag[event.data.id] = true
	self:autoOpenActivitiesLayer()
end

function OnlineActivitiesManager:sendReceiveOpenRedPacket(id )
	self:sendWithLoading(c2s.RECEIVE_OPEN_RED_PACKET_REQUEST, "")
end

function OnlineActivitiesManager:onReceiveOpenRedPacketResult( event )
	hideLoading()
end

-----开服大比拼-------------------
function OnlineActivitiesManager:sendGetOpenCompetitionRequest(id )
	self:send(c2s.GET_OPEN_COMPETITION_REQUEST, "")
end

function OnlineActivitiesManager:onGetOpenCompetition( event )
	local sinleActivityInfo = self.ActivityInfoList:objectByID(event.data.id)
	sinleActivityInfo.name = localizable.activity_some_names[2]
	sinleActivityInfo.ActDetailInfo = {}
	for i = 1, 3 do
		local OneRankActInfo = {}
		local rankInfos = event.data.rank or {}
		local rewards = event.data.reward or {}
		for _,rankInfo in ipairs(rankInfos) do
			if rankInfo.type == i then
				-- OneRankActInfo.rankInfo = rankInfo

				OneRankActInfo.roleInfos = {}
				for i,v in ipairs(rankInfo.rank or {}) do
					OneRankActInfo.roleInfos[v.rank] = v
				end
				OneRankActInfo.myRank = rankInfo.myRank
				OneRankActInfo.myScore = rankInfo.myScore
			end
		end

		OneRankActInfo.rankInfos = ServerOpenCompetition:getInfoListByType( i, 1 )

		OneRankActInfo.rewards = {}
		for _,reward in ipairs(rewards) do
			if reward.type == i then
				OneRankActInfo.rewards[#OneRankActInfo.rewards + 1] = reward
			end
		end
		sinleActivityInfo.ActDetailInfo[i] = OneRankActInfo
	end
	self.fullActInfoFlag[event.data.id] = true
	self:autoOpenActivitiesLayer()
end

function OnlineActivitiesManager:sendReceiveOpenCompetitionReward(id )
	self:sendWithLoading(c2s.RECEIVE_OPEN_COMPETITION_REWARD, id)
end

function OnlineActivitiesManager:onReceiveOpenCompetitionRewardResult( event )
	hideLoading()

end

--更新活动信息
function OnlineActivitiesManager:updateSingleActivityData(data)
	if data.type == OnlineActivitiesManager.TurnTable then
		sinleActivityInfo = {}

		sinleActivityInfo.id 			= data.id
		sinleActivityInfo.type 			= data.type
		sinleActivityInfo.name  		= data.name
		sinleActivityInfo.title  		= data.title
		sinleActivityInfo.icon  		= data.icon
		sinleActivityInfo.details  		= data.details
		sinleActivityInfo.status  		= data.status

		if data.beginTime ~= nil and data.beginTime ~= "" then
		local beginTime = os.date("%Y-%m-%d %H:%M:%S",tonumber(data.beginTime)/1000)
			sinleActivityInfo.beginTime = getTimeByDate(beginTime)
		end
		if data.endTime ~= nil and data.endTime ~= "" then
			local endTime = os.date("%Y-%m-%d %H:%M:%S",tonumber(data.endTime)/1000)
			sinleActivityInfo.endTime = getTimeByDate(endTime)
		end
		self.turntableActivity = sinleActivityInfo
		return
	end

	local sinleActivityInfo = nil
	local bNewActivity = false
	sinleActivityInfo = self.ActivityInfoList:objectByID(data.id)
	if sinleActivityInfo == nil then
		sinleActivityInfo = {}
		sinleActivityInfo.value 		= 0
		self.ActivityInfoList:pushbyid(data.id, sinleActivityInfo)
	end

	sinleActivityInfo.id 			= data.id
	sinleActivityInfo.type 			= data.type
	sinleActivityInfo.name  		= data.name
	sinleActivityInfo.title  		= data.title
	sinleActivityInfo.icon  		= data.icon
	sinleActivityInfo.details  		= data.details
	 --活动状态：0、活动强制无效，不显示该活动；；1、长期显示该活动 2、自动检测，过期则不显示
	sinleActivityInfo.status  		= data.status

	sinleActivityInfo.actCustomInfo = OnlineActivitiesManager.ActCustomInfo[data.type] or {}
	sinleActivityInfo.actCustomShowInfo = OnlineActivitiesManager.ActCustomShowInfo[data.type] or {panel_0 = true, panel_1 = true}
	if data.beginTime ~= nil and data.beginTime ~= "" then
		local beginTime = os.date("%Y-%m-%d %H:%M:%S",tonumber(data.beginTime)/1000)

		sinleActivityInfo.beginTime = getTimeByDate(beginTime)
	end
	if data.endTime ~= nil and data.endTime ~= "" then
		local endTime = os.date("%Y-%m-%d %H:%M:%S",tonumber(data.endTime)/1000)
		sinleActivityInfo.endTime = getTimeByDate(endTime)
	end

	sinleActivityInfo.show_weight = data.showWeight
	sinleActivityInfo.startTime = sinleActivityInfo.beginTime

	self:parserCommonActivityInfo(sinleActivityInfo, data.common)
	if sinleActivityInfo.type == OnlineActivitiesManager.DailyOnline then
		--在线奖励
		self:refreshOnlineRewardInfo(sinleActivityInfo)
	end

	return sinleActivityInfo
end

--通用活动内容
function OnlineActivitiesManager:parserCommonActivityInfo(sinleActivityInfo, common)
	if common == nil then return end
	sinleActivityInfo.cur = common.cur
	common.items = common.items or {}
	sinleActivityInfo.items = {}

	local weight = {2,3,1}
	local function parserItem(v)
		local item = {}
		item.id = v.id
		item.index = v.index
		-- if type(v.need) == "table" then
		-- 	item.need = v.need[1]
		-- else
			item.need = v.need or {}
		-- end
		
		item.rewards = v.rewardItem or {}
		item.status = v.status
		item.weight = weight[v.status + 1] or 0
		item.times = v.times
		item.maxTimes = v.maxTimes
		return item
	end
	if sinleActivityInfo.type == OnlineActivitiesManager.DailyCourtesy then
		local len = #common.items
		for i = 1, len - 1 do
			sinleActivityInfo.items[i] = parserItem(common.items[i])
		end
		sinleActivityInfo.ex_items = { parserItem(common.items[len]) }
	else
		for k,v in pairs(common.items) do
			sinleActivityInfo.items[#sinleActivityInfo.items + 1] = parserItem(v)
		end
	end

	local function onSort(r1, r2)
		if r1.status == r2.status then
			return r1.index < r2.index
		end
		return r1.weight > r2.weight
	end
	table.sort(sinleActivityInfo.items, onSort)
end

--更新在线奖励信息
function OnlineActivitiesManager:refreshOnlineRewardInfo(sinleActivityInfo)
	if sinleActivityInfo.type ~= OnlineActivitiesManager.DailyOnline then return end
  	self.OnlineRewardData.hasGetReward  = 0    -- 已领奖的次数
  	self.OnlineRewardData.nextRewardTime = 0	   -- 在线奖励倒计时

  	self.canGetReward = false
	for k,item in pairs(sinleActivityInfo.items) do
		if item.status == 2 then
			self.OnlineRewardData.hasGetReward = self.OnlineRewardData.hasGetReward + 1
		end
		local cur = sinleActivityInfo.cur or 0
		if type(cur) == "table" then 
			cur = sinleActivityInfo.cur[1]
		end
		if item.need[1] > cur then
			self.OnlineRewardData.nextRewardTime = (item.need[1] - cur) * 60
			break
		elseif item.status == 0 then
			item.status = 1
		end

		if item.status == 1 then
			self.canGetReward = true
		end
	end
	self:refreshOnlineRewardStatus(sinleActivityInfo)
end

-- 获取活动的相关信息
function OnlineActivitiesManager:getActivityInfo(ActivityId)
	return self.ActivityInfoList:objectByID(ActivityId)
end

--领取活动奖励结果，只有成功领取才会发送到客户端
function OnlineActivitiesManager:recvActivityRewardResultEvent(event)
	local data = event.data

	hideLoading()
	local index = data.index			--奖励索引，从1开始，第几个奖励
	
	local activityId 	= data.id

	local activityInfo  = self:getActivityInfo(activityId)

	TFDirector:dispatchGlobalEventWith(self.MSG_GET_Hunt_BOX_REWARD, {})
	if activityInfo == nil then
		print("recvActivityRewardResultEvent, can't find activityid = ", activityId)
		return
	end
	TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_GET_REWARD, {})
end

function OnlineActivitiesManager:sendRequestAllActivityInfo(auto_push)
	if auto_push then
		self.autoPush = true
	end
	TFDirector:send(c2s.REQUEST_ALL_ACTIVITY_INFO, {false})
end

--打开活动界面
function OnlineActivitiesManager:openActivitiesLayer(id)
	if self.ActivityInfoList == nil then
		-- toastMessage("还没有开启的活动")
		toastMessage(localizable.GameActivitiesManager_no_acitivty)
		return
	end
	if self.ActivityInfoList:length() < 1 then
		-- toastMessage("还没有开启的活动")
		toastMessage(localizable.GameActivitiesManager_no_acitivty)
		return
	end
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.OnlineActivitiesLayer", AlertManager.BLOCK_AND_GRAY)
    layer:loadData(id)
    AlertManager:show()
end

-- 获取活动的相关信息
function OnlineActivitiesManager:getActivityByType(type)
	for v in self.ActivityInfoList:iterator() do
		if type == v.type then
			return v
		end
	end
	-- return self.ActivityInfoList:objectByID(ActivityId)
	return nil
end

-- 获取活动的相关信息
function OnlineActivitiesManager:getActivityById(id)
	for v in self.ActivityInfoList:iterator() do
		if id == v.id then
			return v
		end
	end
	-- return self.ActivityInfoList:objectByID(ActivityId)
	return nil
end

-- 获取活动的相关信息
function OnlineActivitiesManager:getFirstActivityId()
	for v in self.ActivityInfoList:iterator() do
		return v.id
	end
	return nil
end

function OnlineActivitiesManager:sendGetAcivityReward( type, itemId )
	TFDirector:send(c2s.GOT_ACTIVITY_REWARD, {tostring(type), itemId})
end

--================================  redPoint =======================

function OnlineActivitiesManager:isHaveActivities()
	if self.canGetReward then return true end
	for data in self.ActivityInfoList:iterator() do
		if self:isHaveActivitiesId(data.id, data) then return true end
	end
	-- if Utils:isDining() then return true end
	return false
end

--是否有该活动ID的红点
function OnlineActivitiesManager:isHaveActivitiesId(id, activityContainer)
	local activityContainer = activityContainer or self:getActivityById(id)
	if activityContainer == nil then return false end
	if activityContainer.type == OnlineActivitiesManager.OpenRedPacket then
		if not activityContainer.ActDetailInfo then
			return false
		end
		return activityContainer.ActDetailInfo.day > 7 and activityContainer.ActDetailInfo.receive == 0
	elseif activityContainer.type == OnlineActivitiesManager.OpenCompetition then
		if not activityContainer.ActDetailInfo then
			return false
		end
		for _,v in ipairs(activityContainer.ActDetailInfo) do
			for _,reward in ipairs(v.rewards) do
				if reward.state == 1 then
					return true
				end
			end
		end
		return false
	end

	local items = activityContainer.items or {}
	for k,v in pairs(items) do
		if v.status == 1 then
			return true
		end
	end

	if activityContainer.ex_items then
		for k,v in pairs(activityContainer.ex_items) do
			if v.status == 1 then
				return true
			end
		end
	end

	if activityContainer.type == OnlineActivitiesManager.CombosActivity then
		local act = activityContainer.activityList[1];
		if act and self:isHaveActivitiesId(act.id,act) then
			return true
		end
	end
	return false
end

--是否有该活动类型的红点
function OnlineActivitiesManager:isHaveActivitiesType(type, activityContainer)
	local activityContainer = activityContainer or self:getActivityByType(type)
	return self:isHaveActivitiesId(nil, activityContainer)
	-- if activityContainer == nil then return false end
	-- if activityContainer.type == OnlineActivitiesManager.OpenRedPacket then
	-- 	return activityContainer.ActDetailInfo.day > 7 and activityContainer.ActDetailInfo.receive == 0
	-- end
	-- local items = activityContainer.items or {}
	-- for k,v in pairs(items) do
	-- 	if v.status == 1 then
	-- 		return true
	-- 	end
	-- end

	-- if activityContainer.type == OnlineActivitiesManager.CombosActivity then
	-- 	local act = activityContainer.activityList[1];
	-- 	if self:isHaveActivitiesType(act.type,act) then
	-- 		return true
	-- 	end
	-- end
	-- return false
end

--================================   end ===========================


-- 1 每日在线
-- 2 连续登陆
-- 3 升级送元宝
-- 4 升战力得奖励
function OnlineActivitiesManager:setActivitySelectBtnImg( type )

	if type == OnlineActivitiesManager.DailyOnline then
		return "ui/activity/img_zaixian_red.png"
	elseif type == OnlineActivitiesManager.ContinuousLogin then
		return "ui/activity/img_lianxu_red.png"
	elseif type == OnlineActivitiesManager.LevelUpSycee then
		return "ui/activity/img_lvup_red.png"
	elseif type == OnlineActivitiesManager.PowerUp then
		return "ui/activity/img_zhanliup_red.png"
	end
	return "ui/activity/img_zaixian_red.png"
end

function OnlineActivitiesManager:setActivityNormalBtnImg( type )
	if type == OnlineActivitiesManager.DailyOnline then
		return "ui/activity/img_zaixian_white.png"
	elseif type == OnlineActivitiesManager.ContinuousLogin then
		return "ui/activity/img_lianxu_white.png"
	elseif type == OnlineActivitiesManager.LevelUpSycee then
		return "ui/activity/img_lvup_white.png"
	elseif type == OnlineActivitiesManager.PowerUp then
		return "ui/activity/img_zhanliup_white.png"
	end 
	return "ui/activity/img_zaixian_white.png"
end

function OnlineActivitiesManager:setActivityTitleNeed( type )
	if type == OnlineActivitiesManager.DailyOnline then
		return localizable.activity_set_long_time
	elseif type == OnlineActivitiesManager.ContinuousLogin then
		return localizable.activity_set_long_day
	elseif type == OnlineActivitiesManager.LevelUpSycee then
		return localizable.activity_set_long_level
	elseif type == OnlineActivitiesManager.PowerUp then
		return localizable.activity_set_long_power
	end 
	return localizable.activity_set_long_time
end

function OnlineActivitiesManager:setActivityTiaomuNeedString( type, value )
	local string = value
	if type == OnlineActivitiesManager.DailyOnline then
		string = math.floor(value / 60) .. localizable.time_minute_txt
	elseif type == OnlineActivitiesManager.ContinuousLogin then
		string = value .. localizable.time_day_txt
	elseif type == OnlineActivitiesManager.LevelUpSycee then
		string = value .. localizable.role_level
	elseif type == OnlineActivitiesManager.PowerUp then
		string = value
	end 
	return string
end

--=================================================================================
--在线领取自动刷新
function OnlineActivitiesManager:refreshOnlineRewardStatus(sinleActivityInfo)
	local function resetTimer()
		if self.onlineTimer then
			TFDirector:removeTimer(self.onlineTimer)
			self.onlineTimer = nil
		end
	end

	resetTimer()
	if self.OnlineRewardData.hasGetReward >= #sinleActivityInfo.items then
		self.canGetReward = false
		return
	end

	self.onlineTimer = TFDirector:addTimer(1000, -1, nil,
	function ()
		self.OnlineRewardData.nextRewardTime = self.OnlineRewardData.nextRewardTime - 1
		if self.OnlineRewardData.nextRewardTime < 0 then
			self.OnlineRewardData.nextRewardTime = 0
		end
		-- 倒计时奖励可领
		if self.OnlineRewardData.nextRewardTime <= 0 then
			self.canGetReward = true
			resetTimer()
		end
	end)
end

function OnlineActivitiesManager:actIsOver( activity )
	if not activity then return true end

	if activity and activity.endTime then
		return activity.endTime <= GetGameTime()
	end

	return true
end

function OnlineActivitiesManager:refreshYunYingIcon()
	CommonUiManager:addActivityIcon(EnumActivityType.Kenkonitteki, self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.MammonReward]))
	CommonUiManager:addActivityIcon(EnumActivityType.LimitGeneral, self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.LimitGeneral]))
	CommonUiManager:addActivityIcon(EnumActivityType.NewYearActivity, self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.MiniSeven]))
	CommonUiManager:addActivityIcon(EnumActivityType.NewYearHit, self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.NewYearHit]))
	CommonUiManager:addActivityIcon(EnumActivityType.LanternAct, self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.LanternAct]))
	local is_bool = true
	if not self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.TreasureHunt]) and ServerSwitchManager:isTreasureHuntOpen() then
		is_bool = false
	end
	CommonUiManager:addActivityIcon(EnumActivityType.TreasureHunt, is_bool)
end

------------------------乾坤一掷--------------------------
--获取财神送礼活动信息
function OnlineActivitiesManager:sendGetMammonRequest( )
	self:send(c2s.GET_MAMMON_REQUEST, self.mammonRewardActInfo.id)
end

--财神送礼活动抽奖
function OnlineActivitiesManager:sendMammonRequest( )
	self:send(c2s.MAMMON_REQUEST, self.mammonRewardActInfo.id)
end

--获取财神送礼活动信息响应
function OnlineActivitiesManager:onGetMammon( event )
	local actInfo = self.mammonRewardActInfo --self.CustomActInfos[OnlineActivitiesManager.MammonReward]
	actInfo.ActDetailInfo = event.data
	local reward_list = actInfo.ActDetailInfo.list or {}
	table.sort(reward_list, function (t1, t2)
		return t1.weight < t2.weight
	end)
	actInfo.ActDetailInfo.list = reward_list

	if self.autoOpenKenkonittekiActivityLayer then
		self.autoOpenKenkonittekiActivityLayer = false
		self:openKenkonittekiActivityLayer(actInfo)
	end
end

--财神送礼抽奖结果
function OnlineActivitiesManager:onMammonResult( event )
	TFDirector:dispatchGlobalEventWith(self.MSG_MAMMON_RESULT, event.data)
end

function OnlineActivitiesManager:onMammonRecordUpdate( event )
	TFDirector:dispatchGlobalEventWith(self.MSG_MAMMON_RECORD_UPDATE, event.data)
end

function OnlineActivitiesManager:startOpenKenkonittekiActivityLayer()
	if self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.MammonReward]) then
		toastMessage(localizable.treasureMain_tiemout)
		TFDirector:dispatchGlobalEventWith("refresh_yunyin")
		return
	end
	self.mammonRewardActInfo = self.CustomActInfos[OnlineActivitiesManager.MammonReward]
	self.autoOpenKenkonittekiActivityLayer = true
	self:sendGetMammonRequest()
end

--打开乾坤一掷界面
function OnlineActivitiesManager:openKenkonittekiActivityLayer(activity)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.KenkonittekiActivityLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(activity)
	AlertManager:show()
end

-------------------------------限时红将-----------------------------------
function OnlineActivitiesManager:startOpenLimitGeneralActivityLayer( )
	if self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.LimitGeneral]) then
		toastMessage(localizable.treasureMain_tiemout)
		TFDirector:dispatchGlobalEventWith("refresh_yunyin")
		return
	end
	self.autoOpenLimitGeneralActivityLayer = true
	self:sendGetTimeLimitGeneralRequest()
end

function OnlineActivitiesManager:sendGetTimeLimitGeneralRequest()
	self.limitGeneralActInfo = self.CustomActInfos[OnlineActivitiesManager.LimitGeneral]
	self:sendWithLoading(c2s.GET_TIME_LIMIT_GENERAL_REQUEST, self.limitGeneralActInfo.id)
end

function OnlineActivitiesManager:sendDrawGeneralRequest(times)
	self:sendWithLoading(c2s.DRAW_GENERAL_REQUEST, self.limitGeneralActInfo.id, times)
end

function OnlineActivitiesManager:onTimeLimitGeneral( event )
	hideLoading()
	table.sort(event.data.items, function(a, b)
		return a.need[1] < b.need[1]
	end)

	self.limitGeneralActInfo.ActDetailInfo = event.data

	local rankReward =  self.limitGeneralActInfo.ActDetailInfo.rankReward or {}
	table.sort(rankReward, function ( a, b )
		return a.rankMin < b.rankMin
	end)
	if self.autoOpenLimitGeneralActivityLayer then
		self.autoOpenLimitGeneralActivityLayer = false
		self:openLimitGeneralActivityLayer(self.limitGeneralActInfo)
	else
		TFDirector:dispatchGlobalEventWith("refresh_yunyin")
		TFDirector:dispatchGlobalEventWith(self.MSG_LIMIT_GENERAL_UPDATE)
	end
	-- self:sendDrawGeneralRequest(1)
end

function OnlineActivitiesManager:onDrawGeneralResult( event )
	hideLoading()
end

function OnlineActivitiesManager:openLimitGeneralActivityLayer( activity )

	if MainPlayer:isSubPackageDownLoad(EnumSubPackageType.Role) then
		TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_LAYER, {EnumSubPackageType.Role})
		return
	end

	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.LimitGeneralActivityLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(activity)
	AlertManager:show()
end

function OnlineActivitiesManager:openActivityRewardLayer( data )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.ActivityRewardLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function OnlineActivitiesManager:openActivityRuleShowLayer( data )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.ActivityRuleShowLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function OnlineActivitiesManager:isHaveLimitGeneralRedPacket( )
	local activityContainer = self.CustomActInfos[OnlineActivitiesManager.LimitGeneral]
	if not self.limitGeneralActInfo or not self.limitGeneralActInfo.ActDetailInfo then return false end

	if self.limitGeneralActInfo.ActDetailInfo.freeState == 1 then return true end
	local items = self.limitGeneralActInfo.ActDetailInfo.items or {}
	for k,v in pairs(items) do
		if v.status == 1 then
			return true
		end
	end
end

-----------------------新年活动-------------------------
function OnlineActivitiesManager:startOpenNewYearActivityLayer( data )
	if self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.MiniSeven]) then
		toastMessage(localizable.treasureMain_tiemout)
		TFDirector:dispatchGlobalEventWith("refresh_yunyin")
		return
	end
	self.autoOpenNewYearActivityLayer = true
	self:sendGetMiniSevenRequest()
end

function OnlineActivitiesManager:openNewYearActivityLayer( data )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.NewYearActivityLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function OnlineActivitiesManager:sendGetMiniSevenRequest()
	self.newYearActInfo = self.CustomActInfos[OnlineActivitiesManager.MiniSeven]
	self:sendWithLoading(c2s.GET_MINI_SEVEN_REQUEST, self.newYearActInfo.id)
end

function OnlineActivitiesManager:sendReceiveMiniSevenReward(itemId)
	self:sendWithLoading(c2s.RECEIVE_MINI_SEVEN_REWARD, self.newYearActInfo.id, itemId)
end

function OnlineActivitiesManager:onGetMiniSeven(event)
	hideLoading()
	local data = event.data
	local ActDetailInfo = {}
	ActDetailInfo.day = data.day

	ActDetailInfo.day_list = {}
	for i,v in ipairs(data.list) do
		if not ActDetailInfo.day_list[v.day] then
			ActDetailInfo.day_list[v.day] = {}
		end

		local task_list = nil
		for i,list in ipairs(ActDetailInfo.day_list[v.day]) do
			if list[1].type == v.type then
				task_list = list
				break
			end
		end

		if not task_list then
			local len = #ActDetailInfo.day_list[v.day]
			task_list = {}
			ActDetailInfo.day_list[v.day][len + 1] = task_list
		end
		task_list[#task_list + 1] = v

		-- if not ActDetailInfo.day_list[v.day][v.type] then
		-- 	ActDetailInfo.day_list[v.day][v.type] = {}
		-- end
		-- local len = #ActDetailInfo.day_list[v.day][v.type]

		-- ActDetailInfo.day_list[v.day][v.type][len + 1] = v
	end

	for i,day_task in ipairs(ActDetailInfo.day_list) do
		for i,task_list in ipairs(day_task) do
			table.sort(task_list, function(a, b)
				if a.state ~= b.state then
					if a.state == 2 then
						return false
					elseif b.state == 2 then
						return true
					end
					return a.state > b.state
				end
				
				return a.need < b.need
				-- return a.itemId < b.itemId
			end)
		end
	end
	self.newYearActInfo.ActDetailInfo = ActDetailInfo
	if self.autoOpenNewYearActivityLayer then
		self.autoOpenNewYearActivityLayer = false
		self:openNewYearActivityLayer(self.newYearActInfo)
	else
		TFDirector:dispatchGlobalEventWith("refresh_yunyin_red")
		TFDirector:dispatchGlobalEventWith(self.MSG_MINI_SEVEN_UPDATE)
	end
end

function OnlineActivitiesManager:onReceiveMiniSevenResult(event)
	hideLoading()
end

function OnlineActivitiesManager:isHaveMiniSevenRedPointByTab(day, tab)
	if not self.newYearActInfo or not self.newYearActInfo.ActDetailInfo then return false end
	local ActDetailInfo = self.newYearActInfo.ActDetailInfo
	local cur_day = ActDetailInfo.day
	if cur_day < day then return false end

	local tab_list = ActDetailInfo.day_list[day]
	if not tab_list then return false end
	local tasks = tab_list[tab] or {}

	for i,task in ipairs(tasks) do
		if task.state == 1 then
			return true
		end
	end
	return false
end

function OnlineActivitiesManager:isHaveMiniSevenRedPointByDay(day)
	if not self.newYearActInfo or not self.newYearActInfo.ActDetailInfo then return false end
	local ActDetailInfo = self.newYearActInfo.ActDetailInfo
	local cur_day = ActDetailInfo.day
	if cur_day < day then return false end

	local tab_list = ActDetailInfo.day_list[day] or {}
	for i,v in ipairs(tab_list) do
		if self:isHaveMiniSevenRedPointByTab(day, i) then return true end
	end
	return false
end

function OnlineActivitiesManager:isHaveMiniSevenRedPoint()
	if not self.newYearActInfo or not self.newYearActInfo.ActDetailInfo then return false end
	local ActDetailInfo = self.newYearActInfo.ActDetailInfo
	local cur_day = ActDetailInfo.day

	for i,task_list in ipairs(ActDetailInfo.day_list) do
		if i > cur_day then
			break
		end
		if self:isHaveMiniSevenRedPointByDay(i) then return true end
	end

	return false
end

------------------年兽活动--------------------------
function OnlineActivitiesManager:startOpenNewYearHitLayer( ... )
	if self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.NewYearHit]) then
		toastMessage(localizable.treasureMain_tiemout)
		TFDirector:dispatchGlobalEventWith("refresh_yunyin")
		return
	end
	self.autoOpenNewYearHitActivityLayer = true
	self:sendGetYearMonsterInfoRequest()
end

function OnlineActivitiesManager:openNewYearHitLayer( ... )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.NewYearHitLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function OnlineActivitiesManager:sendGetYearMonsterInfoRequest( )
	self.newYearHitActInfo = self.CustomActInfos[OnlineActivitiesManager.NewYearHit]
	self:send(c2s.GET_YEAR_MONSTER_INFO_REQUEST, self.newYearHitActInfo.id)
end

function OnlineActivitiesManager:sendUseYearMonsterPropRequest( item_id, num )
	self:send(c2s.USE_YEAR_MONSTER_PROP_REQUEST, self.newYearHitActInfo.id, item_id, num)
end

function OnlineActivitiesManager:sendReceiveYearMonsterRewardRequest( )
	self:sendWithLoading(c2s.RECEIVE_YEAR_MONSTER_REWARD_REQUEST, self.newYearHitActInfo.id)
end

function OnlineActivitiesManager:onGetYearMonsterInfo( event )
	local ActDetailInfo = {}
	ActDetailInfo = event.data
	self.newYearHitActInfo.ActDetailInfo = ActDetailInfo

	table.sort(ActDetailInfo.items, function(a, b)
		return a.need[1] < b.need[1]
	end)
	if self.autoOpenNewYearHitActivityLayer then
		self.autoOpenNewYearHitActivityLayer = false
		self.openNewYearHitLayer()
	else
		TFDirector:dispatchGlobalEventWith("refresh_yunyin_red")
		TFDirector:dispatchGlobalEventWith(self.MSG_YEAR_MONSTER_UPDATE)
	end
end

function OnlineActivitiesManager:onUseYearMonsterPropResult( event )
	hideLoading()
	TFDirector:dispatchGlobalEventWith(self.UES_YEAR_MONSTER_PROP_RESULT)
end

function OnlineActivitiesManager:onReceiveYearMonsterRewardResult( event )
	hideLoading()
	TFDirector:dispatchGlobalEventWith(self.RECEIVE_YEAR_MONSTER_REWARD_RESULT)
end

function OnlineActivitiesManager:isHaveYearMonsterRedPoint( )
	if not self.newYearHitActInfo or not self.newYearHitActInfo.ActDetailInfo then return false end

	if self.newYearHitActInfo.ActDetailInfo.state == 1 then return true end

	for i,v in ipairs(self.newYearHitActInfo.ActDetailInfo.items or {}) do
		if v.status == 1 then return true end
	end
	return false
end

--------------------元宵活动--------------------
--获取活动详情
function OnlineActivitiesManager:sendGetLanternInfoRequest( )
	self.fullCustomActInfos[OnlineActivitiesManager.LanternAct] = self.CustomActInfos[OnlineActivitiesManager.LanternAct]
	self:send(c2s.GET_LANTERN_INFO_REQUEST, self.fullCustomActInfos[OnlineActivitiesManager.LanternAct].id)
end

--制作元宵请求
function OnlineActivitiesManager:sendMakeLanternRequest( )
	self:send(c2s.MAKE_LANTERN_REQUEST, self.fullCustomActInfos[OnlineActivitiesManager.LanternAct].id)
end

--捞元宵请求
function OnlineActivitiesManager:sendSalvageLanternRequest( times )
	self:send(c2s.SALVAGE_LANTERN_REQUEST, self.fullCustomActInfos[OnlineActivitiesManager.LanternAct].id, times)
end

--元宵活动响应
function OnlineActivitiesManager:onGetLanternInfo( event )
	local activity = self.fullCustomActInfos[OnlineActivitiesManager.LanternAct]
	local ActDetailInfo = {}
	ActDetailInfo = event.data
	activity.ActDetailInfo = ActDetailInfo

	table.sort(ActDetailInfo.items, function ( a, b )
		return a.need[1] < b.need[1]
	end)
	if self.autoOpenLanternFestivalLayer then
		self.autoOpenLanternFestivalLayer = false
		self:openLanternFestivalLayer(activity)
	else
		TFDirector:dispatchGlobalEventWith("refresh_yunyin_red")
		TFDirector:dispatchGlobalEventWith(self.MSG_LANTERN_UPDATE)
	end
end

--制作元宵响应
function OnlineActivitiesManager:onMakeLanternResult( event )
	hideLoading()
	TFDirector:dispatchGlobalEventWith(self.MSG_MAKE_LANTERN_RESULT)
end

function OnlineActivitiesManager:onSalvageLanternResult( event )
	hideLoading()
	TFDirector:dispatchGlobalEventWith(self.MSG_SALVAGE_LANTERN_RESULT)
end

function OnlineActivitiesManager:startOpenLanternFestivalLayer( )
	if self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.LanternAct]) then
		toastMessage(localizable.treasureMain_tiemout)
		TFDirector:dispatchGlobalEventWith("refresh_yunyin")
		return
	end
	self.autoOpenLanternFestivalLayer = true
	self:sendGetLanternInfoRequest()
end

function OnlineActivitiesManager:openLanternFestivalLayer(activity)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.ActivityLanternFestival", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(activity)
	AlertManager:show()
end

function OnlineActivitiesManager:isHaveLanternFestivalRedPoint()
	local activity = self.fullCustomActInfos[OnlineActivitiesManager.LanternAct]
	if not activity or not activity.ActDetailInfo then return false end

	if activity.ActDetailInfo.myTimes >= 1 then return true end

	for i,v in ipairs(activity.ActDetailInfo.items) do
		if v.status == 1 then
			return true
		end
	end

	return false
	-- local flag = true
	-- for i,item in ipairs(activity.ActDetailInfo.item) do
	-- 	local item_info = BagManager:getGoodsByTypeAndTplId(item.type, item.tplId)
	-- 	if item_info and item_info.num >= item.num then
	-- 	else
	-- 		flag = false
	-- 	end
	-- end
	-- return flag
end


--寻宝详情
function OnlineActivitiesManager:sendTreasureHuntInfoRequest()
	self:sendWithLoading(c2s.TREASURE_HUNT_REQUEST, self.CustomActInfos[OnlineActivitiesManager.TreasureHunt].id)
end

-- 寻宝
function OnlineActivitiesManager:sendHuntResultInfo(type)
	self:sendWithLoading(c2s.HUNT_REQUEST, type, self.CustomActInfos[OnlineActivitiesManager.TreasureHunt].id)
end

--寻宝记录
function OnlineActivitiesManager:sendHuntRecordsRequest()
	self:sendWithLoading(c2s.HUNT_RECORDS_REQUEST, self.CustomActInfos[OnlineActivitiesManager.TreasureHunt].id)
end

--领取宝箱
function OnlineActivitiesManager:sendGotActivityReward(itemId)
	self:sendGetAcivityReward( self.CustomActInfos[OnlineActivitiesManager.TreasureHunt].id, itemId)
end


--排行榜
function OnlineActivitiesManager:sendGetActivityRankRequest()
	self:sendGetActRankRequest(self.CustomActInfos[OnlineActivitiesManager.TreasureHunt].id)
end

--寻宝活动
function OnlineActivitiesManager:onTreasureHuntInfo( event )

	hideLoading()

	local data = event.data
	self.huntResluInfo = data
	-- print("=======onTreasureHuntInfo==========", data)

	if self.autoOpenTreasureHuntLayer then
		self.autoOpenTreasureHuntLayer = false
		self:openTreasureHuntLayer()
	end
end

function OnlineActivitiesManager:onHuntResultInfo( event )
	hideLoading()

	local data = event.data or {}	
	-- print("=======onHuntResultInfo==========", data)
	TFDirector:dispatchGlobalEventWith(OnlineActivitiesManager.MSG_HUNTRESULT_INFO, data)
end

function OnlineActivitiesManager:onHuntRecordsInfo( event )
	hideLoading()

	local data = event.data
	-- print("=======onHuntRecordsInfo==========", data)
	self:openXunbaoConfirmLayer( data )
end

function OnlineActivitiesManager:startOpenTreasureHuntLayer( )
	if self:actIsOver(self.CustomActInfos[OnlineActivitiesManager.TreasureHunt]) then
		toastMessage(localizable.treasureMain_tiemout)
		TFDirector:dispatchGlobalEventWith("refresh_yunyin")
		return
	end

	self.autoOpenTreasureHuntLayer = true
	self:sendGetActivityRankRequest()
	self:sendTreasureHuntInfoRequest()
end

function OnlineActivitiesManager:openTreasureHuntLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.XunbaoLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData()
	AlertManager:show()
end

function OnlineActivitiesManager:openXunbaoConfirmLayer( data )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.XunbaoConfirmLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function OnlineActivitiesManager:openXunbaoJumpLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.XunbaoJumpLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData()
	AlertManager:show()
end

function OnlineActivitiesManager:openXunbaoBoxReward(data)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.XunbaoBoxReward", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end



return OnlineActivitiesManager:new()