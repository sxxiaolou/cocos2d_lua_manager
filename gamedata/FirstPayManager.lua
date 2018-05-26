-- 首充管理类
-- zzteng
-- Date: 2017-12-18
--

local FirstPayManager = class("FirstPayManager", BaseManager)

FirstPayManager.UPDATE_FIRST_PAY_INFO = "FirstPayManager.UPDATE_FIRST_PAY_INFO"

function FirstPayManager:ctor()
	self.super.ctor(self)
end

function FirstPayManager:init()
	self.super.init(self)

	self:restart()

    TFDirector:addProto(s2c.GET_FIRST_PAY_RECORD, self, self.onReceiveFirstPayInfo)
    TFDirector:addProto(s2c.RECEIVE_FIRST_PAY_REWARD_SUCCESS, self, self.onGetReward)
end

function FirstPayManager:restart()
	-- self.guildAllInfo = {}
	-- self.jumpLayerFlag = {}
	-- self.guildListReqInfo = {}

	-- self.appleList = nil
	-- self.guildMemberList = nil
end

function FirstPayManager:onReceiveFirstPayInfo( event )
    self.data = event.data
	-- print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",  event.data )
	TFDirector:dispatchGlobalEventWith(FirstPayManager.UPDATE_FIRST_PAY_INFO, self.data)

	-- MainPlayer:addActivityIcon(4, nil, 1)  --首充
	-- CommonUiManager:addActivityIcon(EnumActivityType.FirstPay,not ServerSwitchManager:isPayOpen(),1)
end

function FirstPayManager:isHaveRedPointSign()
	for _, item in pairs(self.data.items) do
		if item.status == 1 then
			return true
		end
	end
	return false
end

function FirstPayManager:sendGetReward(id)
	self:sendWithLoading(c2s.RECEIVED_FIRST_PAY_REWARD , id)
end

function FirstPayManager:onGetReward( event )
	hideLoading()
    print(event.data)
end

function FirstPayManager:getData()
	return self.data
end

function FirstPayManager:openFirstPayLayer(on_completed)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.FirstPayActivityLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setData(self.data, on_completed)
	AlertManager:show()
end

function FirstPayManager:isFirstPay()
	for _, item in pairs(self.data.items) do
		if item.status ~= 2 then
			return true
		end
	end
	return false
end

return FirstPayManager:new()