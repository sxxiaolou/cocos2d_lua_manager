-- 排行榜管理类
-- Author: Jin
-- Date: 2016-10-20
--

local BaseManager = require('lua.gamedata.BaseManager')
local RankManager = class("RankManager", BaseManager)

RankManager.PraiseInfo_Refresh	= "RankManager.PraiseInfo_Refresh"
RankManager.Rank_Refresh	    = "RankManager.Rank_Refresh"

-- message MyPraiseInfo{
-- 	required int32 totalCount = 1;					//总使用次数
-- 	required int32 todayCount = 2;					//今日使用次数
-- 	required int32 remaining = 3;					//今日剩余使用次数
-- 	required int64 lastUpdate = 4;					//最后更新时间
-- 	repeated string targetId	= 5;				//今日已经点赞过的玩家ID
-- 	required int32 myPraiseCount = 6;				//我自己拥有的赞数量
-- }

function RankManager:ctor()
	self.super.ctor(self)
end

function RankManager:init()
	self.super.init(self)
	self:restart()
	self:registerEvents()
end

function RankManager:registerEvents()
	TFDirector:addProto(s2c.RANKING_LIST_TOWER, self, self.onReceiveRankList)
	TFDirector:addProto(s2c.RANKING_LIST_ARENA, self, self.onReceiveRankList)
	TFDirector:addProto(s2c.RANKING_LIST_LEVEL, self, self.onReceiveRankList)
	TFDirector:addProto(s2c.RANKING_LIST_TOP_POWER, self, self.onReceiveRankList)
	TFDirector:addProto(s2c.MY_PRAISE_INFO, self, self.onReceiveMyPraiseInfo)
	TFDirector:addProto(s2c.PRAISE_SUCCESS, self, self.onReceivePraiseSuccess)

end

function RankManager:restart()
	self.rankListInfo = nil
	self.myPraiseInfo = nil
end

--protocol
function RankManager:sendQueryRankingBaseInfo(type, startIndex, length)
	self:sendWithLoading(c2s.QUERY_RANKING_BASE_INFO, type, startIndex, length)
end

function RankManager:sendRequestPraise(targetID)
	self:sendWithLoading(c2s.REQUEST_PRAISE, targetID)
end


function RankManager:onReceivePraiseSuccess(event)
	hideLoading()
	local data = event.data
	-- print("onReceive PraiseSuccess  ===", data)
	self.myPraiseInfo.targetId[data.targetId] = data.targetId

	if self.rankListInfo and self.rankListInfo.rankInfo then
		for k,v in pairs(self.rankListInfo.rankInfo) do
			if v.playerId == data.targetId then
				v.praiseCount = v.praiseCount + 1
			end
		end
	end

	TFDirector:dispatchGlobalEventWith(RankManager.Rank_Refresh, 0)

end

function RankManager:onReceiveMyPraiseInfo(event)
	hideLoading()
	local data = event.data
	-- print("onReceive MyPraiseInfo  ===", data)

	self.myPraiseInfo = data
	TFDirector:dispatchGlobalEventWith(RankManager.Rank_Refresh, 0)
end

function RankManager:onReceiveRankList(event)
	hideLoading()

	local data = event.data

	local show = self.rankListInfo == nil
	self.rankListInfo = data
	if show then
		self:openLeaderBoardLayer()
	else
		TFDirector:dispatchGlobalEventWith(RankManager.Rank_Refresh, 0)
	end
end

--最低入榜排名战力
function RankManager:getLastValue()
	if self.rankListInfo then
		return self.rankListInfo.lastValue or self.rankListInfo.lastPower
	end
	return 0
end

--我的最佳排名
function RankManager:getMyRank()
	if self.rankListInfo then
		return self.rankListInfo.myRanking
	end
	return 0
end

-- 我的最佳成绩 或 我的总星星数
function RankManager:getMyBestValue(selectType)
	if self.rankListInfo then
		if not self.rankListInfo.star then
			if selectType == 1 then
				return FormationManager:calcFormationPower(EnumFormationType.PVE)
			elseif selectType == 3 then
				return FormationManager:calcFormationPower(EnumFormationType.PVP)
			end
		end
		
		return self.rankListInfo.star
	end
	return 0
end  

--排行榜排名数据
function RankManager:getRankInfo()
	if self.rankListInfo then
		return self.rankListInfo.rankInfo
	end
	return {}
end

function RankManager:getPraiseByTargetId(id)
	if self.myPraiseInfo == nil then return false end

	local targetId = self.myPraiseInfo.targetId or {}
	for k,v in pairs(targetId) do
		if v == id then
			return true
		end
	end
	return false
end

function RankManager:openLeaderBoardLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.leaderboard.LeaderBoardLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

--api
function RankManager:openGhostTowerRankLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ghosttower.GhostTowerRankLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

--local

return RankManager:new()
