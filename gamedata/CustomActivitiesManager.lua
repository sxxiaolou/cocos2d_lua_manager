--[[
******定制活动管理类*******

	-- by Zhuc
	-- 2018/01/04
]]

local BaseManager = require("lua.gamedata.BaseManager")
local CustomActivitiesManager = class("CustomActivitiesManager", BaseManager)

CustomActivitiesManager.WECHAT_RED_PACKET_INFO_UPDATE = "CustomActivitiesManager.WECHAT_RED_PACKET_INFO_UPDATE"

function CustomActivitiesManager:ctor(data)
	self.super.ctor(self)
end

function CustomActivitiesManager:init()
	self.super.init(self)

	self:restart()
	--客服
	TFDirector:addProto(s2c.GUEST_MESSAGE_RESULT, self, self.onGuestMessageRes)

	--资讯页
	TFDirector:addProto(s2c.GET_INFO_MATION, self, self.onGetInfomationRes)

	--百万红包
	TFDirector:addProto(s2c.WE_CHAT_RED_PACKET_INFO, self, self.onWeChatRedPacketInfo)
	TFDirector:addProto(s2c.RECEIVE_WE_CHAT_CODE_RESULT, self, self.onReceiveWeChatCodeResult)
end

function CustomActivitiesManager:restart()
	self.informations = {}
	self.information_index = 0

	self.show_million_red_packet = false
	self:removeWechatRedTimer()
end

function CustomActivitiesManager:dispose()
	self:removeWechatRedTimer()
end

----------------------------------客服---------
function CustomActivitiesManager:openCustomerServicesLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activities.CustomerServicesLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function CustomActivitiesManager:sendGuestMessageReq( qq, platform)
	self:sendWithLoading(c2s.GUEST_MESSAGE_REQUEST, qq, platform)
end

function CustomActivitiesManager:onGuestMessageRes( event )
	hideLoading()
	toastMessage(localizable.activity_customer_services_tip3)
end


----------------------------------资讯---------
function CustomActivitiesManager:openInformationLayer(on_completed)
    self.information_index = self.information_index + 1
    if self.information_index > #self.informations then
        return
    end
    local file_name = "ui/information/"..self.informations[self.information_index]
    if TFFileUtil:existFile(file_name) then
	    local layer = AlertManager:addLayerByFile("lua.logic.login.InformationLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_0);
	    layer:loadData(file_name, on_completed)
	    AlertManager:show()
	else
		TFFunction.call(on_completed)
	end
end

function CustomActivitiesManager:onGetInfomationRes( event )
	if event.data then
		self.informations = event.data.name or {}
		self.information_index = 0
	end
end

function CustomActivitiesManager:getInformationNum()
	return #self.informations
end


----------------------------------百万红包---------
function CustomActivitiesManager:openMillionRedBagActivityLayer(beginTime, endTime)
	local layer = AlertManager:addLayerByFile("lua.logic.activities.MillionRedBagActivityLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_0);
	layer:loadData(beginTime, endTime)
    AlertManager:show()
end

function CustomActivitiesManager:onWeChatRedPacketInfo(event)
	self.weChatRedPacketInfo = {}
	table.sort( event.data.common, function ( t1, t2 )
		if t1.recharge ~= t2.recharge then
			return t1.recharge < t2.recharge
		end
		return t1.id < t2.id
	end )

	local index = 0
	local last_recharge = 0
	for i,v in ipairs(event.data.common or {}) do
		if v.recharge ~= last_recharge then
			index = index + 1
			last_recharge = v.recharge
			self.weChatRedPacketInfo[index] = {}
		end

		self.weChatRedPacketInfo[index][#self.weChatRedPacketInfo[index] + 1] = v
	end

	local beginTime = tonumber(event.data.beginTime) / 1000
	local endTime = tonumber(event.data.endTime) / 1000
	local closeTime = endTime + ConstantData:getValue("Wechat.Redpacket.prolong") * 24 * 60 * 60
	self:addWechatRedTimer(beginTime, closeTime)
	if self.openWechatRedpacketLayer then
		self.openWechatRedpacketLayer = false
		self:openMillionRedBagActivityLayer(beginTime, endTime)
	else
		TFDirector:dispatchGlobalEventWith(self.WECHAT_RED_PACKET_INFO_UPDATE)
	end
end

function CustomActivitiesManager:updateWeChatRedPacketItem()
	local cur_power = MainPlayer:getPower()

	local old_have_red = false		--之前是否有红点
	local new_have_red = false		--之后是否有红点

	for i,infos in ipairs(self.weChatRedPacketInfo or {}) do
		for i,info in ipairs(infos) do
			if info.rechargeState == 1 and info.state == 1 then
				old_have_red = true
			elseif info.rechargeState == 1 and info.state == 0 and info.force <= cur_power then
				info.state = 1
				new_have_red = true
			end
		end
	end

	if old_have_red then return false end
	return  new_have_red
end

function CustomActivitiesManager:isHaveWeChatRedPacketTabRedPoint(index)
	if self.weChatRedPacketInfo and self.weChatRedPacketInfo[index] then
		for i,v in ipairs(self.weChatRedPacketInfo[index]) do
			if v.rechargeState == 1 and v.state == 1 then
				return true
			end
		end
	end
	return false
end

function CustomActivitiesManager:isHaveWeChatRedPacketRedPoint()
	for i,infos in ipairs(self.weChatRedPacketInfo or {}) do
		if self:isHaveWeChatRedPacketTabRedPoint(i) then return true end
	end
	return false
end

function CustomActivitiesManager:onReceiveWeChatCodeResult(event)
	hideLoading()
end

function CustomActivitiesManager:sendGetWechatRedpacketInfo()
	self.openWechatRedpacketLayer = true
	self:send(c2s.GET_WECHAT_REDPACKET_INFO, "")
end

function CustomActivitiesManager:sendReceiveWechatRedpacket(id)
	self:sendWithLoading(c2s.RECEIVE_WECHAT_REDPACKET, id)
end

function CustomActivitiesManager:addWechatRedTimer(beginTime, endTime)
	if self.activityTimer then return end

	local weChatRedPacketInfoState = 1 -- 1.活动还未开始  2.活动正在进行 3.活动已经结束
	if GetGameTime() > beginTime and GetGameTime() < endTime then
		self.show_million_red_packet = true
		weChatRedPacketInfoState = 2
	end

	local old_power = MainPlayer:getPower()

	self.activityTimer = TFDirector:addTimer(1000, -1, nil,
	function ()
		local cur_time = GetGameTime()
		if cur_time < beginTime then
			weChatRedPacketInfoState = 1
		elseif cur_time <= endTime and weChatRedPacketInfoState ~= 2 then
			self.show_million_red_packet = true
			weChatRedPacketInfoState = 2

		elseif cur_time > endTime then
			self.show_million_red_packet = false
			self:removeWechatRedTimer()
			return
		end

		local new_power = MainPlayer:getPower()
		if old_power < new_power then
			old_power = new_power
			if self:updateWeChatRedPacketItem() then
				TFDirector:dispatchGlobalEventWith("refresh_yunyin")
			end
		end
	end)
end

function CustomActivitiesManager:removeWechatRedTimer( )
	if self.activityTimer then
		TFDirector:removeTimer(self.activityTimer)
		self.activityTimer = nil
	end
end

return CustomActivitiesManager:new()