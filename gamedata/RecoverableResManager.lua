-- 时间回复资源管理类
-- Author: Jing
-- Date: 2016-08-11
--

local BaseManager = require('lua.gamedata.BaseManager')
local RecoverableResManager = class("RecoverableResManager", BaseManager)

RecoverableResManager.RecoverableResChange	= "RecoverableResManager.RecoverableResChange"

function RecoverableResManager:ctor()
	self.super.ctor(self)
end

function RecoverableResManager:init()
	self.super.init(self)

	self.pushTime = {}
	self.recoverParamsInfo = {}
	self:registerEvents()
end

function RecoverableResManager:restart()
	self.pushTime = {}
	self.recoverParamsInfo = {}
	if self.timeId then
		TFDirector:removeTimer(self.timeId)
		self.timeId = nil
	end
end

function RecoverableResManager:registerEvents()
	TFDirector:addProto(s2c.TIME_RECOVER_PARAMS_LIST, self, self.timeRecoverParams)
	TFDirector:addProto(s2c.TIME_RECOVER_INFO, self, self.timeRecoverInfo)
end

function RecoverableResManager:removeEvents()
	TFDirector:removeProto(s2c.TIME_RECOVER_PARAMS_LIST, self, self.timeRecoverParams)
	TFDirector:removeProto(s2c.TIME_RECOVER_INFO, self, self.timeRecoverInfo)
end

function RecoverableResManager:dispose()
	self:removeEvents()
end

function RecoverableResManager:sendBuyTimeRecover(type)
	self:sendWithLoading(c2s.BUY_TIME_RECOVER_VALUE, type)
end

function RecoverableResManager:getRecoverParamsInfo()
	print(self.recoverParamsInfo)
end
function RecoverableResManager:getRecoverParamsInfo(type)
	if self.recoverParamsInfo == nil then
		return nil
	end
	if self.recoverParamsInfo[type] then
		return self.recoverParamsInfo[type]
	end
	
	--防止restart 后报错问题   
	return {maxValue = 0, getLeftValue = function () return 0 end}
end

function RecoverableResManager:isEnoughValue( type ,num , needToast ,isCanAdd)
	local timesInfo = self:getRecoverParamsInfo(type);
	if timesInfo:getLeftValue() >= num and not isCanAdd then 
		return true
	end
	if needToast then 
		-- VipRuleManager:showReplyLayer(type,false);
	end
	return false
end

function RecoverableResManager:isRecoverableValueFull( type )
	local pointInfo =  self:getRecoverParamsInfo(type);
	if pointInfo == nil then
		return false
	end
	local leftChallengeTimes = pointInfo:getLeftValue();
	return leftChallengeTimes  >= pointInfo.maxValue
end

function RecoverableResManager:timeRecoverParams(event)
	hideLoading()
	self.recoverParamsInfo = {}
	local count = #event.data.params
	for i=1,count do
	    local timesInfo =  event.data.params[i]
		self:setRecoverableRes(timesInfo)
	end

	TFDirector:dispatchGlobalEventWith(RecoverableResManager.RecoverableResChange , 0)
end

function RecoverableResManager:timeRecoverInfo(event)
	hideLoading()
    local timesInfo =  event.data
	self:setRecoverableRes(timesInfo)
	TFDirector:dispatchGlobalEventWith(RecoverableResManager.RecoverableResChange , 0)
end

function RecoverableResManager:timeCountDown(type)
end

function RecoverableResManager:setRecoverableRes(info)
	print("RecoverableResManager:setRecoverableRes(info)")
	info.timestamp = os.time()
	local resType = info.type
	local configure = PlayerResConfigure:objectByID(resType)
	if configure == nil then
		print("resType 找不到配置 == ",resType)
		return
	end
	-- print("recoverable res ", configure.name)
	-- print("currentValue ", info.currentValue)
	-- print("cooldownRemain ", info.cooldownRemain)

	local coolTime = configure.recover_time * 1000
	--自动恢复定时器
	if coolTime > 0  and info.maxValue > info.currentValue then
		local leftCoolTimeSum = (info.maxValue - info.currentValue)*coolTime
		local cdLeaveTimeOjb = TimeRecoverProperty:create(math.ceil(leftCoolTimeSum/1000), math.ceil((coolTime - info.cooldownRemain)/1000),math.ceil(coolTime/1000))
		info.cdLeaveTimeOjb = cdLeaveTimeOjb
		self:setRecoverParamsPush(resType ,math.ceil(leftCoolTimeSum/1000),configure.recover_time )
		function info:getLeftValue()
			return self.currentValue + self.cdLeaveTimeOjb:getCurValue()
		end
	else
		--local cdLeaveTimeOjb = TimeRecoverProperty:create(0, 0,0)
		--info.cdLeaveTimeOjb = cdLeaveTimeOjb
		self:setRecoverParamsPush(resType)
		function info:getLeftValue()
			return self.currentValue
		end
	end

	-- print("self.timestamp : ",self.timestamp,self.waitTimeRemain)
	--等待方法绑定
	--[[
	获取剩余多少等待时间，单位/秒
	@return 剩余等待时间，单位/秒
	]]
	function info:getWaitRemaining()
		-- if not configure.cooldown_time then
		-- 	return 0
		-- end

		-- if configure.cooldown_time <= 0 then
		-- 	return 0
		-- end

		if not self.waitTimeRemain then
			return 0
		end

		if self.waitTimeRemain <= 0 then
			return 0
		end
		
		--过去了多长时间，单位/秒
		local timePassed = os.time() - self.timestamp
		local remaining = math.max(0,self.waitTimeRemain/1000 - timePassed)
		return remaining
	end
	
	--[[
	获取剩余时间表达式
	@delim 分割符，默认':'
	@return 时间表达式，格式：小时:分钟:秒
	]]
	function info:getWaitTimeExpression(delim)
		local remaining = self:getWaitRemaining()
		if remaining <= 0 then
			return ""
		end
		
		if not delim then
			delim = ':'
		end
		
		local seconds = math.floor(remaining % 60)
		local minutes = math.floor(remaining / 60 % 60)
		local hours = math.floor(remaining / 60 / 60)

		local expression = ''
		if hours < 10 then
			expression = 0 .. hours .. delim
		else
			expression = hours .. delim
		end

		if minutes < 10 then
			expression = expression .. 0 .. minutes .. delim
		else
			expression = expression .. minutes .. delim
		end

		if seconds < 10 then
			expression = expression .. 0 .. seconds
		else
			expression = expression .. seconds
		end

		return expression
	end
	
	self.recoverParamsInfo[resType] = info
	local configure = PlayerResConfigure:objectByID(resType)
	self.timeId = TFDirector:addTimer(1000, -1, nil, function() 
		info.cooldownRemain = info.cooldownRemain - 1000
		if info.cooldownRemain <= 0 then
			info.cooldownRemain = configure.recover_time
		end
	end)
end

function RecoverableResManager:setRecoverParamsPush(resType , time , coolTime)
	if resType ~= 1 then
		return
	end
	
	if resType == 1 then
		return
	end--先关闭掉.

	local nowTime = os.time()
	if self.pushTime[resType] ~= nil then
		if self.pushTime[resType].time >= nowTime then
			TFPushServer.cancelLocalTimer(self.pushTime[resType].time , self.pushTime[resType].notifyText,self.pushTime[resType].key)
		end
		self.pushTime[resType] = nil
	end
	if time == nil then
		return
	end
	self.pushTime[resType] = {}
	self.pushTime[resType].time = time + nowTime
	if resType == EnumTimeRecoverType.Vitality then
		self.pushTime[resType].notifyText = localizable.push_tili_tixing
		self.pushTime[resType].key = localizable.push_tili_name
	end
	-- print("self.pushTime[resType].time",self.pushTime[resType].time)
	-- print("time",time)
	-- print("nowTime",nowTime)
	-- print("os.time = ",os.time())
	TFPushServer.setLocalTimer(self.pushTime[resType].time , self.pushTime[resType].notifyText,self.pushTime[resType].key)
end

return RecoverableResManager:new()