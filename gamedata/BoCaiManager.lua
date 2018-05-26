--
-- 博彩管理类
-- Author: Jin
-- Date: 2016-10-13
--

local BaseManager = require('lua.gamedata.BaseManager')
local BoCaiManager = class("BoCaiManager", BaseManager)

BoCaiManager.RefreshRewardItem = "BoCaiManager.RefreshRewardItem"     -- 刷新转盘的奖励
BoCaiManager.RefreshAttribLayer = "BoCaiManager.RefreshAttribLayer" --属性界面刷新

BoCaiManager.InspireResult = "BoCaiManager.InspireResult" -- 祈祷结果返回
BoCaiManager.StartBocaiBtn = "BoCaiManager.StartBocaiBtn" -- 开始博彩


BoCaiManager.RewardList = {}   -- 转盘里的物品
BoCaiManager.RecordLogList = {}   -- 中奖记录
BoCaiManager.YuLanItemList = {}


function BoCaiManager:ctor()
	self.super.ctor(self)
end

function BoCaiManager:init()
	self.super.init(self)
	self.freshLottery = false
	TFDirector:addProto(s2c.GET_LOTTERY, self, self.onReceiveGetLottery)
	TFDirector:addProto(s2c.INSPIRE_RESULT, self, self.onReceiveInspireResult)
	TFDirector:addProto(s2c.GET_RECORD_LIST_RESULT, self, self.onReceiveGetRecordListResult)
	TFDirector:addProto(s2c.GET_REVIEW_ITEM_LIST_RESULT, self, self.onReceiveGetReviewItemListResult)

end

function BoCaiManager:restart()
	self.freshLottery = false

	
end

-- protocol

function BoCaiManager:sendBoCaiRefresh()  -- 请求刷新`
	self.freshLottery = true
	self:sendWithLoading(c2s.REFRESH,1)
end

function BoCaiManager:sendBoCaiInspire(times)  -- 请求祈祷
	self:sendWithLoading(c2s.INSPIRE,times)
end

function BoCaiManager:sendBoCaiGetRecordList()  -- 请求中奖记录
	self:sendWithLoading(c2s.GET_RECORD_LIST,1)
end

function BoCaiManager:sendBoCaiGetReviewItemList()  -- 请求预览奖励
	self:sendWithLoading(c2s.GET_REVIEW_ITEM_LIST,1)
end


function BoCaiManager:onReceiveGetLottery(event)
	local data = event.data
	hideLoading()
	-- print("==onReceiveGetLottery==", data)
	
	-- 收到转盘里有奖励
	BoCaiManager.RewardList = {}
	for k,v in pairs(data.items) do
		local RewardItem = v
		table.insert(BoCaiManager.RewardList,RewardItem)
	end
	if self.freshLottery == true then
		TFDirector:dispatchGlobalEventWith(BoCaiManager.RefreshRewardItem, 0)
		self.freshLottery = false
	end
end

function BoCaiManager:onReceiveInspireResult(event)
	local data = event.data
	hideLoading()
	print("==onReceiveInspireResult==", data)

	local rewardResult = {}
	rewardResult.items = data.items			--祈祷抽中奖品
	rewardResult.index = data.index		    --位置
	rewardResult.lotteryCoin = data.lotteryCoin   --获得仙灵石总数

	TFDirector:dispatchGlobalEventWith(BoCaiManager.InspireResult, rewardResult)


end

function BoCaiManager:onReceiveGetRecordListResult(event)
	hideLoading()
	local data = event.data
	local contents = data.contents or {}
	-- print("==onReceiveGetRecordListResult==", data)
	BoCaiManager.RecordLogList = {}
	for k, v in pairs(contents) do
		table.insert(BoCaiManager.RecordLogList,v)
	end

	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bocai.BoCaiJiLuLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
	
end

function BoCaiManager:onReceiveGetReviewItemListResult(event)
	local data = event.data
	hideLoading()
	print("==onReceiveGetReviewItemListResult==", data)
	BoCaiManager.YuLanItemList = {}

	for k,v in pairs(data.items) do
		local item = {}
		item.type  = v.type
		item.num   = v.num
		item.tplId = v.tplId
		table.insert(BoCaiManager.YuLanItemList,item)
	end

	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bocai.BoCaiYuLanLayer")
    AlertManager:show()


end


return BoCaiManager:new()