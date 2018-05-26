--[[
******抽卡管理类*******

	-- by Tony
	-- 2016/09/06
]]

local BaseManager = require('lua.gamedata.BaseManager')
local LotteryManager = class("LotteryManager", BaseManager)

-- LotteryManager.UpdateTask = "LotteryManager.UpdateTask"
-- LotteryManager.UpdateGift = "LotteryManager.UpdateGift"

LotteryManager.UpdateQianNum = "LotteryManager.UpdateQianNum"			-- 更新签数量
LotteryManager.RefreshQian   = "LotteryManager.RefreshQian"			-- 更新签数量

function LotteryManager:ctor(data)
	self.super.ctor(self, data)

end

function LotteryManager:init()
	self.super.init(self)
	
	TFDirector:addProto(s2c.RECRUIT_RECORD, self, self.onRecruitRecordInfo)
	TFDirector:addProto(s2c.RECRUIT_RESPONSE, self, self.onRecruitResponseInfo)
	-- TFDirector:addProto(s2c.RECRUIT_BOX_RESULT, self, self.onRecruitBoxResultInfo)

	self.remianTimes = 0 -- 高级抽卡剩余几次必出
	self.curProgress = 0 -- 至尊抽卡当前进度

	self.goldNum = 0		-- 金签
	self.silverNum = 0		-- 银签
	self.ironNum = 0		-- 铜签
	self.interRefreshTime = 0	-- 剩余刷新时间
	self.refreshTime = 0   		-- 下次刷新时间
	--self.FirsetEnter = false
end

function LotteryManager:restart()
	self.remianTimes = 0
	self.curProgress = 0

	self.goldNum = 0
	self.silverNum = 0
	self.ironNum = 0
	self.interRefreshTime = 0
	self.refreshTime = 0
end

function LotteryManager:onRecruitRecordInfo(event)
	print("签数同步")
	local data = event.data

	hideLoading()
	--self.remianTimes = data.remianTimes    -- 高级抽卡剩余几次必出
	--self.curProgress = data.curProgress    -- 至尊抽卡当前进度

	self.goldNum = data.goldNum
	self.silverNum = data.silverNum
	self.ironNum = data.ironNum
	self.refreshTime = data.refreshTime
	self.interRefreshTime = self.refreshTime/1000 - os.time()

	TFDirector:dispatchGlobalEventWith(LotteryManager.UpdateQianNum, 0)

	
	if self.goldNum + self.silverNum + self.ironNum == 30 then
		TFDirector:dispatchGlobalEventWith(LotteryManager.RefreshQian, 0)
	end

	--Public:currentScene()
	
end

function LotteryManager:onRecruitResponseInfo(event)
	
	local data = event.data
	print("接收到抽卡结果"..#data.eles.."   铁签"..data.acquiredIron)
	-- print("Eles:",data)
	hideLoading()
	local type = data.recruitType
	local eles = data.eles

	local acquiredGold = 0
	local acquiredSilver = 0
	local acquiredIron = 0
	if data.acquiredGold  then
		acquiredGold = data.acquiredGold
	end

	if data.acquiredSilver  then
		acquiredSilver = data.acquiredSilver
	end

	if data.acquiredIron  then
		acquiredIron = data.acquiredIron
	end
	
	AlertManager:close()
	self:openLotteryResultLayer(eles,acquiredGold,acquiredSilver,acquiredIron)
end

-- function LotteryManager:onRecruitBoxResultInfo(event)
-- 	local data = event.data
-- 	hideLoading()

-- 	AlertManager:close()
-- 	--self:openLotteryShowLayer()
-- end

--===== proto ======== 
--抽签请求
function LotteryManager:sendLottery(num)
	print("抽卡抽"..num.."支请求")
	self:sendWithLoading(c2s.REQUIRE_RECRUIT, num)
end

-- 刷新（换一桶）
function LotteryManager:sendRefreshRequest()
	print("抽卡刷新请求")
	self:sendWithLoading(c2s.REFRESH_RECRUIT, 0)
end

function LotteryManager:sendLotteryBox(boxId, goodTplId)
	self:sendWithLoading(c2s.RECRUIT_BOX, boxId, goodTplId)
end

-- 单抽需要元宝
function LotteryManager:getNeedYuanbaoOne()
	local id = ConstantData:getValue("Ordinary.Card.One")
  	local data = LotteryConsumeData:objectByID(id)
	return data.discount_sycee
end

-- 获取十抽需要的元宝
function LotteryManager:getNeedYuanbaoTen()
	local id = ConstantData:getValue("Ordinary.Card.Ten")
  	local data = LotteryConsumeData:objectByID(id)
	return data.discount_sycee
end

--================= end ================

--通过抽卡消耗数据的id 获取需要的物品或者钻石
function LotteryManager:getGoodByID(id)
	local data = LotteryConsumeData:objectByID(id)
	local num = BagManager:getGoodsNumByTplId(data.goods_id)
	if data.goods_num > num then
		return BaseDataManager:getReward({type=EnumResourceType.Sycee, num=data.sycee})
	else
		return BaseDataManager:getReward(LotteryConsumeData:getGoodsById(id))
	end
end

--=================== redpoint =============================
-- 获取桶内剩余签数
function LotteryManager:getQianNum()
	return self.goldNum,self.silverNum,self.ironNum
end

function LotteryManager:getQianTotal()
	return self.goldNum + self.silverNum + self.ironNum
end

-- 获取桶刷新剩余时间
function LotteryManager:getRefreshTime()
	return self.refreshTime
end

-- 获取免费抽卡CD时间
function LotteryManager:getFreeCDTime()
	local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.NormalRecruit)
	return times:getWaitRemaining() 
end

-- 倒计时转换
function LotteryManager:getLotteryTimeString()
	
	self.interRefreshTime = self.refreshTime/1000 - os.time()

	if self.interRefreshTime <= 0 then
		return "00:00:00"
	end

	return Utils:timeFormatHM(self.interRefreshTime)
end

--============================  红点 ====================================

function LotteryManager:isHaveLottery()
	if self:isHaveLotteryFree() then return true end
	if self:isHaveLotteryTen() then return true end
	if ShopManager:isHaveRedPoint(EnumShopType.LotteryShop) then return true end
	
	return false
end

function LotteryManager:isHaveLotteryFree()
	local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.NormalRecruit)
    if times:getWaitRemaining() == 0 and times:getLeftValue() > 0 then
    	return true
    end
    return false
end

function LotteryManager:isHaveLotteryTen()
	local ten_id = ConstantData:getValue("Ordinary.Card.Ten")
    local ten_data = LotteryConsumeData:objectByID(ten_id)
    local ten_coinNum = BagManager:getGoodsNumByTplId(ten_data.goods_id)
    if ten_coinNum >= 10 then
    	return true
    end
    return false
end

function LotteryManager:isHaveLotteryShopGold()
	if MainPlayer.goldenLotCoin == nil then return false end
	return MainPlayer.goldenLotCoin >= 20
end

function LotteryManager:isHaveLotteryShopSilver()
	if MainPlayer.silverLotCoin == nil then return false end
	return MainPlayer.silverLotCoin >= 5
end

--==============================================================================

function LotteryManager:openLotteryLayer()
	AlertManager:addLayerToQueueAndCacheByFile("lua.logic.lottery.LotteryLayer")
    AlertManager:show()
end

-- 打开准备抽签界面
function LotteryManager:openLotteryChoiceLayer(num)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.lottery.LotteryChoiceLayer")
	layer:loadData(num)
	AlertManager:show()

end

function LotteryManager:openLotteryAniLayer(type)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.lottery.LotteryAniLayer")
    layer:loadData(type)
    AlertManager:show()
end

function LotteryManager:openLotteryResultLayer(eles,acquiredGold,acquiredSilver,acquiredIron)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.lottery.LotteryResultLayer")
    layer:loadData(eles,acquiredGold,acquiredSilver,acquiredIron)
    AlertManager:show()
end

function LotteryManager:openLotteryShowLayer(roleId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.lottery.LotteryYulanLayer")
    layer:loadData(roleId)
    AlertManager:show()
end

function LotteryManager:openLotteryHelpLayer(helpTxt)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.lottery.LotteryHelpLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
	layer:loadData(helpTxt)
    AlertManager:show()
end

function LotteryManager:openLotteryChangeLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.lottery.LotteryChangeLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    AlertManager:show()
end

return LotteryManager:new()