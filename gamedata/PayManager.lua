--[[
******充值管理类*******

	-- by Tony
	-- 2016/12/19
]]

local BaseManager = require('lua.gamedata.BaseManager')
local PayManager = class("PayManager", BaseManager)

PayManager.EVENT_PAY_COMPLETE = "PayManager.EVENT_PAY_COMPLETE"
PayManager.GET_VIP_REWARD_RESULT = "PayManager.GET_VIP_REWARD_RESULT"
PayManager.VIP_SIGN_RESULT = "PayManager.VIP_SIGN_RESULT"
PayManager.UPDATE_MONTH_CARD_STATE = 'PayManager.UPDATE_MONTH_CARD_STATE'
PayManager.FIRST_PAY_CHANGE = "PayManager.FIRST_PAY_CHANGE"

function PayManager:ctor()
	self.super.ctor(self)
end

function PayManager:init()
	self.super.init(self)

	self.payRecodeList = {}
	self.vipRewardList = {}
	self.subScriptionList = {}

	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		if GlobalMatch.useAndroidServer and GlobalMatch:useAndroidServer() then
			self.rechargeList = require("lua.table.recharge_s")
		else
			self.rechargeList = require("lua.table.recharge_ios_s")
	        --确保一下策划没有导错,iOS平台不要这三个档位
	        self.rechargeList:removeById(11)
	        self.rechargeList:removeById(12)
	        self.rechargeList:removeById(13)
		end
    else
        self.rechargeList = require("lua.table.recharge_s")
        --连接iOS服务器的不要这三个档位
        if GlobalMatch:useiOSServer() then
	        self.rechargeList:removeById(11)
	        self.rechargeList:removeById(12)
	        self.rechargeList:removeById(13)
		end
    end
    
    self.vipList = require("lua.table.vip_s")
    self.firstRechargeRewardList = require("lua.table.recharge_first_reward_s")

	TFDirector:addProto(s2c.PAY_BILL_NO, self, self.onPayBillNoInfo)
	TFDirector:addProto(s2c.PAY_COMPLETE, self, self.onPayCompleteInfo)
	TFDirector:addProto(s2c.PAY_RECORD_LIST, self, self.onPayRecodeListInfo)
	TFDirector:addProto(s2c.VIP_REWARD_LIST, self, self.onPayRewardListInfo)
	TFDirector:addProto(s2c.GET_VIP_REWARD_RESULT, self, self.onPayGetVipRewardResultInfo)
	TFDirector:addProto(s2c.GET_FIRST_RECHARGE_SUCCESS, self, self.onPayGetFirstRechargeSuccessInfo)
	TFDirector:addProto(s2c.PAY_SIGN_RESULT, self, self.onPaySignResultInfo)
	--TFDirector:addProto(s2c.VIPINFOMATION, self, self.onVipInfomationInfo)
	TFDirector:addProto(s2c.SUBSCRIPTION_LIST, self, self.onPaySubscriptionListInfo)

	---月卡额外奖励
	TFDirector:addProto(s2c.GET_SUBSCRIPTION_EXTRA_REWARD_RESULT, self, self.onGetSubscriptionExtraRewardResult)
end

function PayManager:restart()
	for k,v in pairs(self.payRecodeList) do
		v = nil
	end
	for k,v in pairs(self.vipRewardList) do
		v = nil
	end
	self.payRecodeList = {}
	self.vipRewardList = {}
	self.subScriptionList = {}
	self.yueKaAttribute = nil
end

function PayManagerPaySDKCallBack( result )
    print("PayManagerPaySDKCallBack===",result)
    
    hideLoading()
end

function PayManager:onPayBillNoInfo(event)
	print("onReceiveBillNo000000")
    print(event.data,MainPlayer:getPlayerId(),SaveManager:getUserInfo().currentServer)

    hideLoading()
	local data = event.data
    --月卡id，周卡8，月卡9，终生卡10
	local monthPay = 0 
	--20171130更新 by Jing
	--支付接口中，custom里面的KEY_IS_PAY_MONTH改成KEY_PAY_TYPE。 支付类型(0:普通支付 1:月卡 2:周卡 3:季卡 4:年卡 5:终身卡)
	local rechargeId = event.data.id
    local rechargeItem = self.rechargeList:objectByID(rechargeId)
    if rechargeItem.id == 8 then --周卡
    	monthPay = 2
    elseif rechargeItem.id == 9 then --月卡
    	monthPay = 1
    elseif rechargeItem.id == 10 then --终身卡
    	monthPay = 5
    end

    local userInfo = SaveManager:getUserInfo()
    if HeitaoSdk then
    	local price         = event.data.price
        local rate          = 10
        local count         = 1
        local fixedMoney    = true
        --local unitName      = "元宝"
        local unitName      = localizable.common_resource_type[EnumResourceType.Sycee]
        local productId     = event.data.id
        local serverId      = math.floor(userInfo.currentServer)
        local name          = event.data.goodName
        local callbackUrl   = nil
        local description   = nil
        local cpExtendInfo  = event.data.billNo
        
        local sycee         = MainPlayer:getSycee()
        local level         = MainPlayer:getLevel()
        local viplevel      = MainPlayer:getVipLevel()
        local party         = ""
        local month         = monthPay 

        HeitaoSdk.setPayCallBack(PayManagerPaySDKCallBack)
        HeitaoSdk.pay(price, rate, count, fixedMoney, unitName, productId, serverId, name, callbackUrl, description, cpExtendInfo, sycee, level, viplevel, month, party)
    end
end

function PayManager:onPayCompleteInfo(event)
	print('onPayCompleteInfo',event.data)
	play_chongzhichenggong()

    hideLoading()

	local baseValue,extValue = self:getSyceeNumDetail(event.data.isFirstPay,event.data.id)

	-- if event.data.id == 8 or event.data.id == 9 or event.data.id == 10 then
	-- else
		self:openPayResultLayer(baseValue, extValue)
	-- end
	TFDirector:dispatchGlobalEventWith(PayManager.EVENT_PAY_COMPLETE, nil)
end

function PayManager:onPayRecodeListInfo(event)
	hideLoading()

	self.payRecodeList = {}

	local recordList = event.data.recordList or {}
	for k,v in pairs(recordList) do
		self.payRecodeList[v.id] = v.isHavePay
	end
	TFDirector:dispatchGlobalEventWith(PayManager.FIRST_PAY_CHANGE)
end

function PayManager:onPayRewardListInfo(event)
	hideLoading()

	local rewardList = event.data.rewardList or {}
	for k,v in pairs(rewardList) do
		self.vipRewardList[v.id] = v.isHaveGot
	end
end

function PayManager:onPayGetVipRewardResultInfo(event)
	hideLoading()

	local item = event.data.item
	if item then
		self.vipRewardList[item.id] = item.isHaveGot
	end

	TFDirector:dispatchGlobalEventWith(PayManager.GET_VIP_REWARD_RESULT, nil)
end

function PayManager:onPayGetFirstRechargeSuccessInfo(event)
	hideLoading()
	

end

function PayManager:onPaySignResultInfo(event)
	hideLoading()

	MainPlayer.isVipSign = true
	TFDirector:dispatchGlobalEventWith(PayManager.VIP_SIGN_RESULT, nil)
end

function PayManager:onPaySubscriptionListInfo( event )
	hideLoading()
	local data = event.data
	print('onPaySubscriptionListInfo:',data)
	self.subScriptionList = data.infos or {}
	self.extraStatus = data.extraStatus
	--update属性数据
	local cardCount = 0
	for k,v in pairs(self.subScriptionList) do
	     if v.isActive then
		     cardCount = cardCount + 1
		 end
	end
	self.cardCount = cardCount --开通月卡个数    
	if cardCount > 1 then
		self:updateYuekaAttribute(cardCount - 1)
	end
	TFDirector:dispatchGlobalEventWith(PayManager.UPDATE_MONTH_CARD_STATE, nil)
end

function PayManager:updateYuekaAttribute( type )
    local m = ConstantData:getValue('mouthcard.m' .. type)
    local n = ConstantData:getValue('mouthcard.n' .. type)
    local value = m + MainPlayer:getLevel() * n/10000
    local addtAttr = {}	
    for i=1,4 do
        addtAttr[i] = value
    end
	self.yueKaAttribute = addtAttr
    CardRoleManager:updateYuekaAttr( )
end

function PayManager:onVipInfomationInfo(event)
	hideLoading()

	local data = event.data
	
end

--======================  send ============================================

-- 订单号
function PayManager:sendPayGetBillNo(id)
	self:sendWithLoading(c2s.PAY_GET_BILL_NO, id)
end

--领取vip奖励
function PayManager:sendGetVipReward(id)
	self:sendWithLoading(c2s.GET_VIP_REWARD, id)
end

--领取首充奖励
function PayManager:sendGetFirstRechargeReward()
	self:sendWithLoading(c2s.GET_FIRST_RECHARGE_REWARD, false)
end

function PayManager:sendPaySign()
	self:sendWithLoading(c2s.PAY_SIGN, false)
end

function PayManager:sendGetSubscriptionReward( type )
	self:sendWithLoading(c2s.GET_SUBSCRIPTION_REWARD,type)
end

--================ proto ==================================================

function PayManager:getSyceeNumDetail(isFirstPay,rechargeId)
    local rechargeItem = self.rechargeList:objectByID(rechargeId);

    local baseValue = 0
    local extValue = 0
    if rechargeItem.id == 8 or rechargeItem.id == 9 or rechargeItem.id == 10 then
        baseValue = rechargeItem.sycee
        extValue  = (rechargeItem.first_pay_ratio - 1) * rechargeItem.sycee
    elseif self:isHavePay(rechargeItem.id) then
        baseValue = rechargeItem.sycee
        extValue  = rechargeItem.extra_sycee
    else
        baseValue = rechargeItem.sycee
        extValue  = rechargeItem.sycee
    end


    return baseValue, extValue
end

--月卡类型信息
function PayManager:getSubscriptionInfoByType( type )
	for i,info in ipairs(self.subScriptionList) do
		if info.type == type then
		    return info
		end
	end
	return nil
end

function PayManager:isHaveMonthCardRedPoint()
	if self.extraStatus == 1 then return true end
	for i = 1,3 do
		local info =  self:getSubscriptionInfoByType(i)
		if info and info.isActive then
			if not info.isGet then
				return true
			end
		end
	end

	return false
end

function PayManager:isHavePay(id)
	if not self.payRecodeList then
		return false
	end
	local isHavePay = self.payRecodeList[id]
   	if isHavePay and isHavePay == true then
   		return true
   	end
    return false
end

function PayManager:isHaveGot(id)
	if not self.vipRewardList then
		return false
	end
	local haveGot = self.vipRewardList[id]
	if haveGot and haveGot == true then
		return true
	end
	return false
end

function PayManager:getRechargeById(id)
	return self.rechargeList:objectByID(id)
end

function PayManager:getVipById(id)
	return self.vipList:objectByID(id)
end

function PayManager:getVipByLevel(level)
	for vip in self.vipList:iterator() do
		if vip.level == level then
			return vip
		end
	end
	return nil
end

function PayManager:getMaxVipLevel()
	if not self.maxVipLevel then
		self.maxVipLevel = 0
		for vip in self.vipList:iterator() do
			if vip.level > self.maxVipLevel then
				self.maxVipLevel = vip.level
			end
		end
	end
	return self.maxVipLevel
end

function PayManager:getFirstReward()
	local firstReward = {}
	for first in self.firstRechargeRewardList:iterator() do
		local reward = {tplId = first.res_id, type = first.res_type, num = first.res_num}
		firstReward[#firstReward + 1] = BaseDataManager:getReward(reward)
	end
	return firstReward
end

function PayManager:openPayLayer()
	-- if true then
	-- 	toastMessage(localizable.common_yet_open)
	-- 	return
	-- end
	
	local configure = FunctionOpenConfigure:objectByID(FunctionManager.MenuPay)
	if configure then
		if configure.level and configure.level > MainPlayer:getLevel() then
			toastMessage(stringUtils.format(localizable.common_function_openlevel, configure.level))
			return
		elseif configure.missionId ~= nil and configure.missionId ~= 0 and MissionManager:getStarLevelByMissionId(missionId) == 0 then
			local missionId = configure.missionId
			local mission = MissionData:objectByID(missionId)
            local chapter = ChapterData:objectByID(mission.chapter)

            local str = chapter.name .. mission.npc_name
            toastMessage(stringUtils.format(localizable.commom_function_openmission, str))
			return
		end
	end

	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.PayLayer")
    AlertManager:show()
end

function PayManager:openVipLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.PayLayer")
	layer:loadData(true)
    AlertManager:show()
end

function PayManager:openPayResultLayer(num1, num2)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.PayResultLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
	layer:loadData(num1, num2)
    AlertManager:show()
end

function PayManager:openVipUpgradeLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.VipUpgradeLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    AlertManager:show()
end

function PayManager:openMouthCardLayer( ... )
	AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pay.MonthCardLayer");
    AlertManager:show();
end

-----------月卡额外奖励
function PayManager:sendGetSubscriptionExtraReward( )
    self:sendWithLoading(c2s.GET_SUBSCRIPTION_EXTRA_REWARD, "")
end

function PayManager:onGetSubscriptionExtraRewardResult( )
    hideLoading()
end

return PayManager:new()
