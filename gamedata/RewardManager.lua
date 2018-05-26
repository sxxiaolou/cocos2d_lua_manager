-- 背包管理类
-- Author: Jin
-- Date: 2016-08-12
--

local RewardManager = class("RewardManager", BaseManager)

RewardManager.RECEIVE_REWARD 			= "RewardManager.RECEIVE_REWARD"

function RewardManager:ctor()
	self.super.ctor(self)
end

function RewardManager:init()
	self.super.init(self)

	TFDirector:addProto(s2c.REWARD_INFO, self, self.onReceiveRewards)
end

function RewardManager:restart()
	-- body
end

-- protocol
-- 奖励结构 : {
-- 	type = 1, 资源类型
-- 	tplId = 2, 对应静态表id
-- 	num = 3, 数量
-- }
function RewardManager:onReceiveRewards(event)
	hideLoading()

	local data = event.data
	-- print("====onReceiveRewards====",data)
	local rewardType = data.type
	local rewards = data.items or {}
	self:showRewards(rewardType, rewards)

	TFDirector:dispatchGlobalEventWith(RewardManager.RECEIVE_REWARD, #rewards)
end

-- function
function RewardManager:showRewards(rewardType, rewards)
	local length = #rewards
	if length == 0 then return end
	
	local fun = self:getCallbackFun(rewardType, length)
	if length == 1 then
		play_huodewupin()
		self:showSingleReward(rewards[1], fun)
		MainPlayer:openTeamUpLevelLayer()
	else
		play_dakaibaoxiang()
		if rewardType == EnumRewardSourceType.Bloody then
			self:showBloodyRewardList(rewards, fun)
		elseif rewardType == EnumRewardSourceType.Adventure_Monster then
			AdventureManager:setAdventureReward(rewards)
		else
			--------------山海奇遇------------------
			AdventureManager:setAdventureIsBool(true)
			-----------------------------------------
			self:showRewardList(rewards, fun)
		end	
	end
end

function RewardManager:getCallbackFun(rewardType,length)
	if rewardType == EnumRewardSourceType.Tower then
		local callback = function() 
			--GhostTowerManager:openGhostTowerAttributeChoiceLayer()
		end
		return nil
	elseif rewardType == EnumRewardSourceType.UseProp then
		local topLayer = Public:currentScene():getTopLayer()
		if topLayer.__cname == "RoleListLayer" then
			-- 合成卡牌
			CardRoleManager:refreshRoleList()
		end
	elseif rewardType == EnumRewardSourceType.Bloody then
		--建木通天托管
		if BloodyWarManager.autoWar then
			BloodyWarManager:setAutoState(5)
		end

		local callback = function() 
			BloodyWarManager:refershBloodyWarLayer()
		end
		return callback
	elseif rewardType == EnumRewardSourceType.Adventure then
		
		local allNotify = AdventureManager:getAllNotifyActivity()
		if allNotify:length() <= 0 then
			if length == 1 then
				TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_CLOSE_LAYER, 0)
			else
				local callback = function() 
					TFDirector:dispatchGlobalEventWith(AdventureManager.ADVENTURE_CLOSE_LAYER, 0)
				end
				return callback
			end
		end
	end
	return nil
end

function RewardManager:showSingleReward(reward, fun)
	play_lingqu()
	--获得卡牌
	if reward.type == EnumResourceType.RoleCard then
		local rewardX = BaseDataManager:getReward(reward)
		CardRoleManager:openRoleGainLayer(reward.tplId,0,0,rewardX.quality)
		return
	elseif reward.type == EnumResourceType.PetCard then
		
		-- PetRoleManager:openPetGetLayer(pet)
		return
	elseif reward.type == EnumResourceType.Fashion then
		print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr时装获得s')
		--时装获得面板
--todo 时装获得
		ShiZhuangManager:openHuoDeNewShiZhuangLayer(reward.tplId)
		return
	end

    local toastMessageLayer = ToastMessage:new('lua.uiconfig.common.RewardSingleMessage')
    toastMessageLayer:setPosition(ToastMessage.DEFUALT_POSITION)

	local bg				= TFDirector:getChildByName(toastMessageLayer,"bg")	
    local bg_icon 			= TFDirector:getChildByPath(toastMessageLayer, "bg_icon")
    local img_icon 			= TFDirector:getChildByPath(toastMessageLayer, 'img_icon')
    local img_quality 		= TFDirector:getChildByPath(toastMessageLayer, 'img_kuang')
    local text 				= TFDirector:getChildByPath(toastMessageLayer, 'txt_name')
    reward = BaseDataManager:getReward(reward)
    if not reward.path then
   		img_icon:setVisible(false)
    	img_quality:setVisible(false)
    	bg_icon:setVisible(false)
    	-- text:setText(stringUtils.format(reward.name, reward.num))
    	text:setText(reward.name .. "+" .. reward.num)
    else
	 	-- if reward.pieceBox then
	 	-- 	img_quality:setTexture(reward.pieceBox)
	 	-- else
	 	-- 	img_quality:setTexture(GetColorIconByQuality(reward.quality))
	 	-- end

    	text:setColor(GetColorByQuality(reward.quality))
	 	bg_icon:setTexture(GetColorBottomByQuality(reward.quality))
	    img_icon:setTexture(reward.path)

	    -- if getIsFragByResType(reward.type) then
	    	img_quality:setTexture(Public:getIconKuangByData(reward))
	    -- else
	    -- 	img_quality:setTexture(Public:getIconKuangByData(reward))
	    -- end

	    if reward.num > 0 then
	    	text:setText(reward.name .."+".. Utils:getSystemShowText(reward.num))
	    else
	    	text:setText(reward.name)
	    end
	end
	local b_scale = bg_icon:getScale()
	local icon_width = bg_icon:getContentSize().width * b_scale
	local text_width = text:getContentSize().width
	local b_width = icon_width + text_width + 130 + 30
	local b_height = bg:getContentSize().height
	bg:setContentSize(CCSize(b_width,b_height))
	bg_icon:setPositionX( - math.abs(b_width / 2 - 65 - icon_width / 2))
	text:setPositionX(bg_icon:getPositionX() + icon_width / 2 + 30)
	-- if reward.type == EnumDropType.ROLE then
	-- 	local layer = require("lua.logic.shop.GetHeroResultLayer"):new(reward.itemid)
 --            layer:setReturnFun(function ()
 --                    AlertManager:close()
 --                end)
 --        AlertManager:addLayer(layer, AlertManager.BLOCK)
 --        AlertManager:show()
	-- end

    toastMessageLayer:beginToast()
    if fun then
    	fun()
    	print("showSingleReward---")
	end
    return toastMessageLayer
end

function RewardManager:showRewardList(rewards, fun)
	play_lingqu()
   	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.RewardListMessage", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    layer:loadData(rewards, fun)
    AlertManager:show()
end

function RewardManager:showBloodyRewardList(rewards, fun)
	play_lingqu()
   	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bloodywar.BloodyWarReward", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    layer:loadData(rewards, fun)
    AlertManager:show()
end

return RewardManager:new()

