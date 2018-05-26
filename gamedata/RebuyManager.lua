-- 回购系统
-- Author: Jing
-- Date: 2016-11-07
--
local RebuyManager = class('RebuyManager', BaseManager)

RebuyManager.MSG_BUY_BACK_LIST_UPDATE = "RebuyManager.MSG_BUY_BACK_LIST_UPDATE"
RebuyManager.MSG_BUY_BACK_RESULT = "RebuyManager.MSG_BUY_BACK_RESULT" 

function RebuyManager:ctor()
	-- 更新回购信息
	TFDirector:addProto(s2c.BUY_BACK_LIST, self, self.onReceiveBuyBackList)
	-- 回购结果
	TFDirector:addProto(s2c.BUY_BACK_RESULT, self, self.onReceiveBuyBackResult)
	
	--回购信息
	self.buyBack = nil
	--回购总价
	self.totalPrice = nil
	--回购结果
	self.buyBackResult = nil
	--付费回购时，只显示一次红点(0:已经显示过了 1:还可以显示)
	self.buyRed = 1
end

-- 重新清除数据
function RebuyManager:restart()
	print("------------RebuyManager:restart ----")
	
	self.buyBack = nil
	self.totalPrice = nil
	self.buyBackResult = nil
	self.buyRed = 1
end

function RebuyManager:reset()
end

--回购是否有红点提示
function RebuyManager:isRedPoint()
	if self.buyBack then
		for i = 1, #self.buyBack do
			if self.buyBack[i].free > 0 then
				return true
			end
		end
	end
	
	if self.buyRed == 1 and self.buyBack then
		return true
	end
	
	return false
end    

--获得回购单条信息
function RebuyManager:getBuyBackByID(buyBackId)
	if self.buyBack then
		for i = 1, #self.buyBack do
			if self.buyBack[i].buyBackId == buyBackId then
				return self.buyBack[i]
			end
		end
	end
	
	return nil
end

--获得下一vip上限
function RebuyManager:getNextVipLimit(buyBackId)
	local maxVipLevel = VipListData:length() - 1

	if MainPlayer.vipLevel >= maxVipLevel then
		return nil
	end
	
	--vip回购上限
	local vipLimit = 0
	
	local curVip = VipRightData:getDataByLevelAndId(MainPlayer.vipLevel, buyBackId)
	if curVip then
		vipLimit = curVip.benefit_value
	end
	
	for i = MainPlayer.vipLevel + 1, maxVipLevel do
		local nextVip = VipRightData:getDataByLevelAndId(i, buyBackId)
		
		if nextVip and nextVip.benefit_value > vipLimit then
			return nextVip
		end
	end
	
	return nil
end
 
--================================proto start==============================--

--请求--回购全部
function RebuyManager:RequestBuyBackAll()
	self:sendWithLoading(c2s.REQUEST_BUY_BACK_ALL, false)
end

--请求--回购
--@buyBackIdid:回购Id
function RebuyManager:RequestBuyBack(isFree, buyBackId)
	self:sendWithLoading(c2s.REQUEST_BUY_BACK, isFree, buyBackId)
end

--回调--回购信息
function RebuyManager:onReceiveBuyBackList(event)
	hideLoading()
	
	if event.data then
		self.buyBack = event.data.buyBack
		self.totalPrice = event.data.totalPrice
		
		if self.buyBack then
			table.sort(self.buyBack, function(t1, t2) return t1.buyBackId < t2.buyBackId end)
		end
		
		TFDirector:dispatchGlobalEventWith(RebuyManager.MSG_BUY_BACK_LIST_UPDATE)
	end
end 

--回调--回购结果
function RebuyManager:onReceiveBuyBackResult(event)
	hideLoading()
	
	if event.data then
		self.buyBackResult = event.data.type
		
		TFDirector:dispatchGlobalEventWith(RebuyManager.MSG_BUY_BACK_RESULT)
	end
end 

--================================proto end==============================--
return RebuyManager:new() 