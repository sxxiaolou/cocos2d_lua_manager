--[[
******游戏数据角色管理类*******

	-- by Tony
	-- 2016/6/28
]]

local BaseManager = require('lua.gamedata.BaseManager')
local CardRoleManager = class("CardRoleManager", BaseManager)

local CardRole = require('lua.gamedata.base.CardRole')

CardRoleManager.RESET_LEVEL_UP 			= "CardRoleManager.RESET_LEVEL_UP"
CardRoleManager.UPDATE_SKILL_INFO 		= "CardRoleManager.UPDATE_SKILL_INFO"
CardRoleManager.DESTINY_LIGHT_UP		= "CardRoleManager.DESTINY_LIGHT_UP" 		--点亮天命
CardRoleManager.CardStarUpStep 			= "CardRoleManager.CardStarUpStep"
CardRoleManager.CardStarUp 				= "CardRoleManager.CardStarUp"
CardRoleManager.REFRESH_ROLE_LIST 		= "CardRoleManager.REFRESH_ROLE_LIST"
CardRoleManager.REMOVE_SKILL_LAYER 		= "CardRoleManager.REMOVE_SKILL_LAYER"   	--删除角色技能界面
CardRoleManager.UPDATE_CARD_FATE        = "CardRoleManager.UPDATE_CARD_FATE"   		--角色缘分更新
CardRoleManager.UPDATE_CARD_INFO 		= "CardRoleManager.UPDATE_CARD_INFO" 		--卡牌信息更新


CardRoleManager.ROLE_CHUAN_GONG_BEGIN	= "CardRoleManager.ROLE_CHUAN_GONG_BEGIN"	--角色传功前信息
CardRoleManager.ROLE_CHUAN_GONG_END		= "CardRoleManager.ROLE_CHUAN_GONG_END" 	--角色传功后 
CardRoleManager.ROLE_POWER_BEGIN		= "CardRoleManager.ROLE_POWER_BEGIN"		--角色战斗力前信息
CardRoleManager.ROLE_POWER_END			= "CardRoleManager.ROLE_POWER_END" 			--角色战斗力后信息  

CardRoleManager.UPDATE_HAND_BOOK_ROLE   = "CardRoleManager.UPDATE_HAND_BOOK_ROLE"   --角色形象ui更新
CardRoleManager.UPDATE_ROLE_FASHION 	= "CardRoleManager.UPDATE_ROLE_FASHION" 	--更新主角形象



function CardRoleManager:ctor()
	self.super.ctor(self)
end

function CardRoleManager:init()
	self.super.init(self)

	self.destinyLevel = 0
	self.destinyPhase = 0
	self.cardRoleList = TFArray:new()
	self.othersCardRoleList = TFArray:new()
	self.totalCardRoleList = TFArray:new()
	self.cardFateList = {}
	self.cardInfoIdx = 0


	TFDirector:addProto(s2c.GET_ROLE_CARD_LIST, self, self.onReceiveRoleInfo)
	TFDirector:addProto(s2c.UPDATE_ROLE_CARD, self, self.onUpdateRoleCard)
	TFDirector:addProto(s2c.LEVEL_INFO, self, self.onReceiveLevelInfo)
	TFDirector:addProto(s2c.UPDATE_SKILL_INFO, self, self.onReceiveUpdateSkillInfo)
	TFDirector:addProto(s2c.CARD_STAR_UP_STEP_SUC, self, self.onReceiveCardStarUpStep)
	TFDirector:addProto(s2c.CARD_STAR_UP_SUC, self, self.onReceiveUpdateCardStarUp)
	TFDirector:addProto(s2c.REMOVE_ROLE_CARD, self, self.onRemoveRoleCard)
	TFDirector:addProto(s2c.DESTINY_INFO, self, self.onReceiveDestinyInfo)
	TFDirector:addProto(s2c.LIGHT_UP_THE_STAR_SUCCESS, self, self.onReceiveLightUpSuccess)
	TFDirector:addProto(s2c.BESTIARY, self, self.onReceiveHandBookList)

	TFDirector:addProto(s2c.GET_FATES, self, self.onReceiveGetFates)
	TFDirector:addProto(s2c.UPDATE_FATES, self, self.onReceiveUpdateFates)

    TFDirector:addProto(s2c.HAND_BOOK_INFO, self, self.onReceiveHandBookInfo)
	TFDirector:addProto(s2c.UPDATE_HAND_BOOK, self, self.onReceiveUpdateHandBook)

	TFDirector:addProto(s2c.GET_OTHERS_ROLE_CARD_LIST, self, self.onReceiveOthersRoleInfo)
	TFDirector:addProto(s2c.UPDATE_OTHERS_ROLE_CARD, self, self.onUpdateOthersRoleCard)
	self.ChouKaRoleList = {}
	self.unLockIdList = {}
	self.canUnlockIdList = {}


end

function CardRoleManager:restart()
	for cardRole in self.cardRoleList:iterator() do
		cardRole:dispose()
	end
	self.cardRoleList:clear()
	for cardRole in self.othersCardRoleList:iterator() do
		cardRole:dispose()
	end
	self.othersCardRoleList:clear()
	self.totalCardRoleList:clear()

	for k,v in pairs(self.cardFateList) do
		v = nil
	end
	self.cardFateList = {}
	self.ChouKaRoleList = {}
	self.destinyLevel = 0
	self.destinyPhase = 0
	self.cardInfoIdx = 0

	self.selectedRole = nil

	self.handBookCurSelTab = 1
	self.handBookPageType = 1
	self.handBookCurPageIndex = 1
	self.mainRole = nil
	
	self.unLockIdList = {}
	self.canUnlockIdList = {}
end

-- protocol
function CardRoleManager:sendCardLevelUp(id, materials)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_CHUAN_GONG_BEGIN, 0)
	self:sendWithLoading(c2s.CARD_LEVEL_UP, materials, id)
end

function CardRoleManager:sendAutoCardLevelUp(id)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_CHUAN_GONG_BEGIN, 0)
	self:sendWithLoading(c2s.AUTO_CARD_LEVEL_UP, id)
end

function CardRoleManager:sendSkillLevelUp(roleId, skillId)
	self:send(c2s.SKILL_LEVEL_UP, roleId, skillId)
end

function CardRoleManager:sendLightDestiny(level, phase)
	self:sendWithLoading(c2s.LIGHT_UP_THE_STAR, level, phase)
end

--解锁立绘id
function CardRoleManager:sendUnlockHandBookId( id )
	self:sendWithLoading(c2s.UNLOCK_HAND_BOOK_ID,id)
end

function CardRoleManager:onReceiveDestinyInfo(event)
	local data = event.data
	self.destinyLevel = data.level
	self.destinyPhase = data.phase
	
	print("===========  天命：：：", data)
	if self.mainRole then
		self.mainRole:updateDestinyAttrs()
		self.mainRole:updateTotalAttr()
	end
end

function CardRoleManager:sendSkillLevelUp(roleId, skillId)
	self:sendWithLoading(c2s.SKILL_LEVEL_UP, roleId, skillId)
end

function CardRoleManager:sendCardStarUpStep(roleId, onekey)
	self:sendWithLoading(c2s.CARD_STAR_UP_STEP, roleId, onekey)
end

function CardRoleManager:sendCardStarUp(roleId)
	self:sendWithLoading(c2s.CARD_STAR_UP, roleId)
end

function CardRoleManager:onReceiveLightUpSuccess(event)
	hideLoading()
	local data = event.data
	self.destinyLevel = data.level
	self.destinyPhase = data.phase

	print("===========  天命：：：", data)
	if self.mainRole then
		self.mainRole:updateDestinyAttrs()
		self.mainRole:updateTotalAttr()
	end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.DESTINY_LIGHT_UP, 0)
end

function CardRoleManager:onReceiveHandBookList( event )
	-- body
	self.handbooklist = {}
	local data = event.data
	for k,v in pairs(data.tplId) do
		self.handbooklist[#self.handbooklist + 1] = v
	end
end

function CardRoleManager:isHaveRoleHandBook( tplId )
	local is_have = false

	if self.handbooklist ~= nil then
		for k,v in pairs(self.handbooklist) do
			if tplId == v then
				is_have = true
				break
			end
		end
	end
	return is_have
end

--轩辕剑系列排序1.有无2.品质3.战斗力
function CardRoleManager:sortHandBookByHaveAndQuality( type )
	local cardDataByType = CardData.handBookType[type]
	if cardDataByType then
	    local haveCardData = TFArray:new()
		local notHaveCardData = TFArray:new()
	    local newCardData = TFArray:new()
		for roleData in cardDataByType:iterator() do
			   if self:isHaveRoleHandBook(roleData.id) then
				   haveCardData:push(roleData)
				else 
				   notHaveCardData:push(roleData)
			   end
		end
		local haveCardDataByQuality = self:sortHandBookByQuality(haveCardData)
		local nothaveCardDataByQuality = self:sortHandBookByQuality(notHaveCardData)
        if  nothaveCardDataByQuality ~= nil then
			for roleData in haveCardDataByQuality:iterator() do
		        newCardData:push(roleData)
		    end
		end
		if nothaveCardDataByQuality ~= nil then
			for roleData in nothaveCardDataByQuality:iterator() do
		        newCardData:push(roleData)
		    end
		end
		return newCardData
	else 
	    return nil
	end
end

--轩辕剑系列某代集齐
function CardRoleManager:collecAlltByType( type )
	local collectAll = true
	local cardDataByType = CardData.handBookType[type]
	if cardDataByType then
		for roleData in cardDataByType:iterator() do
	      if not self:isHaveRoleHandBook(roleData.id) then
		        collectAll = false
			    break
		  end
	end
	else
	    collectAll = false
	end
	return collectAll
end

function CardRoleManager:sortHandBookByQuality( roleArr )
	if roleArr == nil then
		return nil
	end
	local newRoleArr = TFArray:new()
	for role in roleArr:iterator() do
		newRoleArr:push(role)
	end
	local sortFun = function ( a,b )
		return a.quality > b.quality
	end
	newRoleArr:sort(sortFun)
	return newRoleArr
end

--策划需求待定
function CardRoleManager:sortHandBookBypower( ... )
	-- body
end

function CardRoleManager:setRoleId( roleId )
	self.roleId = roleId
end

function CardRoleManager:getRoleId()
	return self.roleId
end

function CardRoleManager:getVersionNameByCardId( id )
	local versionData = HandBookDrawingData.versionByCardId[id]
	local nameArr = TFArray:new()
	for data in versionData:iterator() do
	       nameArr:push(data.version_name)
	end
	return nameArr
end

function CardRoleManager:getVersionDrawingByCardId( id )
	local versionData = HandBookDrawingData.versionByCardId[id]
	local drawingArr = TFArray:new()
	for data in versionData:iterator() do
	      drawingArr:push(data.pic_id)
	end
	return drawingArr
end

function CardRoleManager:getVersionDescByCardId( id )
	local versionData = HandBookDrawingData.versionByCardId[id]
	local descArr = TFArray:new()
	for data in versionData:iterator() do
	       descArr:push(data.desc)
	end
	return descArr
end

function CardRoleManager:getVersionIdByCardId( id )
	local versionData = HandBookDrawingData.versionByCardId[id]
	local versionIdArr = TFArray:new()
	for data in versionData:iterator() do
	       versionIdArr:push(data.id)
	end
	return versionIdArr
end

function CardRoleManager:setHandBookCurSelTab(index)
	self.handBookCurSelTab = index
end

function CardRoleManager:setHandBookPageType(index)
	self.handBookPageType = index
end

function CardRoleManager:setHandBookCurPageIndex(index)
	self.handBookCurPageIndex = index
end
function CardRoleManager:getHandBookCurSelTab()
	return self.handBookCurSelTab	
end

function CardRoleManager:getHandBookPageType()
	return self.handBookPageType
end

function CardRoleManager:getHandBookCurPageIndex()
	return self.handBookCurPageIndex
end

function CardRoleManager:onReceiveRoleInfo(event)
	hideLoading()
	local data = event.data
	for _,role in pairs(data.roleCard) do
		local cardRole = self:addCardRole(role)
		-- 设置主角
		if cardRole:getIsMainRole() then
			self.mainRole = cardRole
		end
	end
	-- print("======= role card ===============", data.roleCard)
	self:sortCardRoleList()
	for cardRole in self.cardRoleList:iterator() do
		table.insert(self.ChouKaRoleList,cardRole.id)
	end	
end

function CardRoleManager:onReceiveOthersRoleInfo( event )
	hideLoading()
	local data = event.data
	-- print('CardRoleManager:onReceiveOthersRoleInfo',data)
	for _,role in pairs(data.roleCard or {}) do
		local cardRole = self:addOthersCardRole(role)
	end
	--得到所有玩家卡牌
	self:getTotalCardRoleList()
end

function CardRoleManager:setSelectedCardRole(role)
	self.selectedRole = role
end

function CardRoleManager:getSelectedCardRole()
	if not self.selectedRole then
		self.selectedRole = self.mainRole
	end
	return self.selectedRole
end

function CardRoleManager:onUpdateRoleCard(event)
	local data = event.data
	self:updateCardRole(data.roleCard)
	-- TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)

	if data.roleCard and data.roleCard.cardId and data.roleCard.showId then
		local tbl = {cardId = data.roleCard.cardId, showId = data.roleCard.showId}
		TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_ROLE_FASHION, tbl)
	end
end

function CardRoleManager:onUpdateOthersRoleCard( event )
	local data = event.data
	self:updateOthersCardRole(data.roleCard)
end

function CardRoleManager:onReceiveLevelInfo(event)
	hideLoading()
	local data = event.data
	local cardRole = self:getRoleByGmId(data.roleId)
	if cardRole then
		if data.currentLevel > cardRole.level then
			-- JIN TODO 显示升级效果
		end
		-- print(string.format("====onReceiveLevelInfo====id : %d prev : %d, %d cur : %d, %d",cardRole.id, cardRole.level, cardRole.curExp, data.currentLevel, data.currentExp))
		cardRole.level = data.currentLevel
		cardRole.curExp = data.currentExp
		-- TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_CHUAN_GONG_BEGIN, 0)
		cardRole:updateTotalAttr()
		TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_CHUAN_GONG_END, 0)
	end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.RESET_LEVEL_UP, {})
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)
end

function CardRoleManager:onReceiveUpdateSkillInfo(event)
	hideLoading()
	local data = event.data
	if not data or not data.roleId then return end

	local gmId = data.roleId
	local cardRole = self:getRoleByGmId(gmId)
	if not cardRole then return end

	cardRole:updateSkill(data.skillType, data.skillIndex, data.level)

	TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_SKILL_INFO, {})
end

--获取缘分
function CardRoleManager:onReceiveGetFates(event)
	local data = event.data

	self.cardFateList = {}
	self:updateCardFate(data.fate)
end

function CardRoleManager:onReceiveUpdateFates(event)
	local data = event.data
	self.newFateData = data
	self:updateCardFate(data.fate)
	
	TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_CARD_FATE, 0)
end

function CardRoleManager:onReceiveHandBookInfo( event )
	hideLoading()
	local data = event.data
	self.unLockIdList = data.unlockId or {}
	self.canUnlockIdList = data.canUnlockId or {}
	-- print('444444444444444444444444444444444',self.unLockIdList,self.canUnlockIdList)
end

function CardRoleManager:onReceiveUpdateHandBook( event )
	hideLoading()
	print('CardRoleManager:onReceiveUpdateHandBook:',event.data)
	local updateUnlockIdList = event.data.unlockId or {}
	local updateCanUnlockIdList = event.data.canUnlockId or {}
    for _,id in pairs(updateUnlockIdList) do
		table.uniqueAdd(self.unLockIdList,id)
	end	
	for _,id in pairs(updateCanUnlockIdList) do
	    table.uniqueAdd(self.canUnlockIdList,id)
	end
	-- if #updateUnlockIdList > 0 and self.hand_book_effect_func then
    --     TFFunction.call(self.hand_book_effect_func)
	-- end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_HAND_BOOK_ROLE)
end

--可以解锁
function CardRoleManager:canUnlock( versionId )
	local canUnlock = false
	if self.canUnlockIdList then
		for _,v in pairs(self.canUnlockIdList) do
		  if versionId == v then
			canUnlock = true
			 break
		  end
	   end
	end
	return canUnlock
end
--已经解锁
function CardRoleManager:isUnlock( versionId )
	local isUnlock = false
	-- print('eeeeeeeeeeeeeeeeeeeeee',versionId,self.unLockIdList)
	if self.unLockIdList then
		for _,v in pairs(self.unLockIdList) do
		  if versionId == v then
			isUnlock = true
			 break
		  end
	   end
	end
	return isUnlock
end

function CardRoleManager:setVersionId( id )
	self.versionId =  id
end

function CardRoleManager:getVersionId(  )
	return self.versionId
end

function CardRoleManager:showOpenNewFateWindow()

	local fateData = self.newFateData
	self.newFateData = nil
	if fateData then
		local value = 1
		local toastTimeId = TFDirector:addTimer(700, #fateData.fate, function ()
			TFDirector:removeTimer(toastTimeId)
			toastTimeId = nil
		end, function ()
			local fate = CardFateData:objectByID(fateData.fate[value])
			if fate then
				fateLayer(fate)
			end
			value = value + 1
		end)
	end

end

function CardRoleManager:onRemoveRoleCard(event)
	local data = event.data
	for _,v in pairs(data.cardId) do
		self:removeRoleByGmId(v)
	end
end

function CardRoleManager:onReceiveCardStarUpStep(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(CardRoleManager.CardStarUpStep, nil)
end

function CardRoleManager:onReceiveUpdateCardStarUp(event)
	hideLoading()

	local roleId = event.data.cardId
	self:showStarShowLayer(roleId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.CardStarUp, nil)
end

function CardRoleManager:refreshRoleList()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.REFRESH_ROLE_LIST, nil)
end

-- function
function CardRoleManager:addCardRole(role)
	local cardRole = self:getRoleByGmId(role.id)
	if not cardRole then
		cardRole = CardRole:new(role)
		self.cardRoleList:push(cardRole)
	end
	return cardRole
end

function CardRoleManager:addOthersCardRole( role )
	local cardRole = self:getRoleByGmId(role.id)
	if not cardRole then
		cardRole = CardRole:new(role)
		self.othersCardRoleList:push(cardRole)
	end
	return cardRole
end

function CardRoleManager:updateCardRole(role)
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.gmId == role.id then
			cardRole:updateInfo(role)
			return
		end
	end
	local cardRole = self:addCardRole(role)
	--assert(false, "can not find cardRole " .. role.id)
	cardRole:updateAllCardRoleAttribute()
	self:sortCardRoleList()
end

function CardRoleManager:updateOthersCardRole( role )
	for cardRole in self.othersCardRoleList:iterator() do
		if cardRole.gmId == role.id then
			cardRole:updateInfo(role)
			return
		end
	end
	self:addOthersCardRole(role)
end

--得到所有玩家卡牌
function CardRoleManager:getTotalCardRoleList( ... )
	self.totalCardRoleList:clear()
	for cardRole in self.cardRoleList:iterator() do
		self.totalCardRoleList:push(cardRole)
	end
	for othersCardRole in self.othersCardRoleList:iterator() do
		self.totalCardRoleList:push(othersCardRole)
	end
	return self.totalCardRoleList
end

--得到玩家列表的卡牌
function CardRoleManager:getCardRoleListByPlayerList( playerIdList )
	self:getTotalCardRoleList()
	local cardRoleList = TFArray:new()
	if type(playerIdList) ~= 'table' then return nil end
	for cardRole in self.totalCardRoleList:iterator() do
		local role =  table.findOne(playerIdList,function ( playerId )
			if cardRole.playerId == playerId then
				return true
			else
				return false
			end
		end)
		if role ~= nil then cardRoleList:push(cardRole)  end
	end
	return cardRoleList
end

--更新缘分
function CardRoleManager:updateCardFate(fates)
	fates = fates or {}
	local roles = {}
	for k,v in pairs(fates) do
		self.cardFateList[v] = true

		local fate = CardFateData:objectByID(v)
		if fate then
			roles[fate.role_id] = fate.role_id
		end
	end

	for k,v in pairs(roles) do
		self:updateRoleFateAttr(v)
	end
	-- print("================ fates  ===========", fates)
end

function CardRoleManager:getRoleNum()
	return self.cardRoleList:length()
end

--动态id
function CardRoleManager:getRoleByGmId(gmId)
	
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.gmId == gmId then
			return cardRole
		end
	end
	for cardRole in self.othersCardRoleList:iterator() do
		if cardRole.gmId == gmId then
			return cardRole
		end
	end
	return nil
end

--是否拥有卡牌
function CardRoleManager:isHaveRole(id)
	local cardRole = self:getRoleById(id)
	return cardRole ~= nil
end
function CardRoleManager:resertChauKaRoleList()
	self.ChouKaRoleList = {}
	for cardRole in self.cardRoleList:iterator() do
		table.insert(self.ChouKaRoleList,cardRole.id)
	end
	-- print("isHaveRoleChouKa",self.ChouKaRoleList)			
end
function CardRoleManager:isHaveRoleChouKa(id)
	--print("isHaveRoleChouKa",id)	
	for k,v in pairs(self.ChouKaRoleList) do
		if v == id then
			return true
		end
	end

	return false
end
--卡牌id
function CardRoleManager:getRoleById(id)
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.id == id then
			return cardRole
		end
	end
	return nil
end

--卡牌id——>动态id
function CardRoleManager:getRoleGmIdById( id )
	local cardRole = self:getRoleById(id)
	if cardRole ~= nil then
	    return cardRole.gmId
	end
	return nil
end
--动态id--->卡牌id
function CardRoleManager:getRoleIdByGmId( gmId )
	local cardRole = self:getRoleByGmId(gmId)
	if cardRole ~= nil then
	    return cardRole.id
	end
	return nil
end

--是否能合成卡牌
function CardRoleManager:canRecruit(id, num)
	local template = CardData:objectByID(id)
	if not template then return false end
	return template.recruit_num <= num
end

function CardRoleManager:getRecruitNum(roleId)
	local template = CardData:objectByID(roleId)
	if not template then return 0 end
	return template.recruit_num
end

--通过位置获得角色牌
function CardRoleManager:getRoleByPos(pos)
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.pos == pos then
			return cardRole
		end
	end
	return nil
end

--通过id获得卡牌在列表中的顺序
function CardRoleManager:getIndexByGmId( gmId )
    local role = self:getRoleByGmId(gmId)
    return  self.cardRoleList:indexOf(role)
end

function CardRoleManager:getNext(cardRole)
	if not cardRole then return nil end

	local index = self.cardRoleList:indexOf(cardRole)
	return self.cardRoleList:getObjectAt(index + 1)
end

function CardRoleManager:getNextByGmId(gmId)
	local cardRole = self:getRoleByGmId(id)
	return self:getNext(cardRole)
end

function CardRoleManager:getPrev(cardRole)
	if not cardRole then return nil end

	local index = self.cardRoleList:indexOf(cardRole)
	return self.cardRoleList:getObjectAt(index - 1)
end

function CardRoleManager:getPrevByGmId(gmId)
	local cardRole = self:getRoleByGmId(gmId)
	return self:getPrev(cardRole)
end

--通过id从列表中删除卡牌 
function CardRoleManager:removeRoleByGmId( gmId )
	local cardRole = self:getRoleByGmId(gmId)
	self.cardRoleList:removeObject(cardRole)
end

--可以重生的角色
function CardRoleManager:getRoleListToRebirth()
	local roleList = TFArray:new()
	for cardRole in self.cardRoleList:iterator() do
		-- if cardRole:hasTrain() and  not cardRole:isAnyFormation() and not cardRole:getIsMainRole() then
		if cardRole:hasTrain() and not cardRole:getIsMainRole() then
			roleList:push(cardRole)
		end
	end
	return roleList
end

--可以分解的角色
function CardRoleManager:getRoleListToDiscard()
	local roleList = TFArray:new()
	for cardRole in self.cardRoleList:iterator() do
		-- if not cardRole:isAnyFormation() then
			roleList:push(cardRole)
		-- end
	end
	return roleList
end

function CardRoleManager:getRoleListByCareer( career )
	local roleList = TFArray:new()
	local function checkRole(id)
		for role in roleList:iterator() do
			if role.id == id then
				return true
			end
		end
		return false
	end

	for cardRole in self.cardRoleList:iterator() do
		if cardRole:getCareer() == career or career == EnumCareerType.All then
			if not checkRole(cardRole.id) then
				roleList:push(cardRole)
			end
		end
	end
	return roleList
end

function CardRoleManager:isFateActive(fateId)
	if self.cardFateList[fateId] and self.cardFateList[fateId] == true then
		return true
	end
	return false
end

function CardRoleManager:openRoleInfoLayer(cardRole, otherRoleInfo)
    -- local layer = require("lua.logic.role.RoleInfoLayer"):new(cardRole)
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleInfoLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    -- AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    layer:loadData(otherRoleInfo)
    AlertManager:show()
end

-- Destiny
function CardRoleManager:openDestinyLayer(level)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleDestinyLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    layer:loadData(level)
    AlertManager:show()
end

--角色详情界面
function CardRoleManager:openNewHandBookRoleLayer( ... )
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.handbook.NewHandBookRoleLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

function CardRoleManager:openLiHuiLayer( ... )
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.LiHuiLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

--更新装备属性
function CardRoleManager:updateAllRoleEquipAttr()
	for role in self.cardRoleList:iterator() do
		role:updateEquipAtteribute()
	end
end

function CardRoleManager:updateRoleEquipAttrByGmId(gmId)
	local role = self:getRoleByGmId(gmId)
	if role then
		role:updateEquipAtteribute()
		role:updateSuitAtteribute()
	end
end

--更新缘分属性
function CardRoleManager:updateRoleFateAttr(roleId)
	local role = self:getRoleById(roleId)
	if role then
		role:updateFateAttrs()
	end
end

function CardRoleManager:updateArtifactAttr()
	local infos = ArtifactManager:getArtifactEquipInfo()
	for gmId,_ in pairs(infos) do
		self:updateRoleArtifactAttr(gmId)
	end
end

function CardRoleManager:updateRoleArtifactAttr(gmId)
	local role = self:getRoleByGmId(gmId)
	if role then
		role:updateArtifactAttrs()
		role:updateTotalAttr()
	end
end

--大师属性
function CardRoleManager:updateMasterAttr()
	local roles = EquipmentManager:getEquipMasterList()
	if roles then
		for gmId, _ in pairs(roles) do
			self:updateRoleMasterAttr(gmId)
		end
	end
end

function CardRoleManager:updateRoleMasterAttr(gmId)
	local role = self:getRoleByGmId(gmId)
	if role then
		role:updateMasterAttrs()
		role:updateTotalAttr()
	end
end

--更新宠物属性
function CardRoleManager:updateAllRolePetAttr()
	for role in self.cardRoleList:iterator() do
		role:updatePetAttr()
	end
end

function CardRoleManager:updateRolePetAttr(gmId)
	local role = self:getRoleByGmId(gmId)
	if role then
		role:updatePetAttr()
	end
end

function CardRoleManager:updateNewArtifactAttr()
	for role in self.cardRoleList:iterator() do
		role:updateNewArtifactAttrs()
	end
end

function CardRoleManager:updateYuekaAttr( )
	-- print('updateYuekaAttr:',PayManager.yueKaAttribute,self.mainRole)

	for role in self.cardRoleList:iterator() do
		role:updateYuekaAttribute()
	end
end

function CardRoleManager:updateTitleAttr( ... )
	print('CardRoleManager:updateTitleAttr')
	for role in self.cardRoleList:iterator() do
		role:updateTitleAttribute()
	end
end

function CardRoleManager:getMaxPower()
	local power = 0
	for role in self.cardRoleList:iterator() do
		if role:getPower() > power then
			power = role:getPower()
		end
	end
	return power
end

function CardRoleManager:sortCardRoleList(type)
	type = type or EnumSortType.Quality

	local function sameFun(role1, role2)
		if type == EnumSortType.Quality then
        	if role1:getQuality() ~= role2:getQuality() then
        		return role1:getQuality() > role2:getQuality()
        	elseif role1:getPower() ~= role2:getPower() then
        		return role1:getPower() > role2:getPower()
        	end
        else
        	if role1:getPower() ~= role2:getPower() then
        		return role1:getPower() > role2:getPower()
        	elseif role1:getQuality() ~= role2:getQuality() then
        		return role1:getQuality() > role2:getQuality()
        	end
        end
        return role1:getLevel() > role2:getLevel()
	end

	local function sortFun(role1, role2)
		if role1:getIsMainRole() then
			return true
		end
		if role2:getIsMainRole() then
			return false
		end

        local isF1 = role1:isFormation()
        local isF2 = role2:isFormation()
        if isF1 and not isF2 then
        	return true
        elseif not isF1 and isF2 then
        	return false
        else
        	return sameFun(role1, role2)
        end
    end
    self.cardRoleList:sort(sortFun)
end

--返回在pve阵容角色排序后，装备有红点的第一个角色，没有红点默认主角
function CardRoleManager:getRoleHaveEquipmentRedPoint( ... )
	self:sortCardRoleList(EnumSortType.Quality)
	local curRoleList = self:getRoleListByCareer(0)
	for cardRole in curRoleList:iterator() do
		--阵容角色装备红点
		if cardRole:isFormation() and EquipmentManager:isHavePosIdRedPoint(cardRole.gmId) then
			return cardRole
		end
	end
	return self.mainRole
end

----================================================ check ===============================

--是否有卡牌可以进阶
function CardRoleManager:isHaveRoleBookAll()
	for cardRole in self.cardRoleList:iterator() do
		local advanceData  = CardAdvanceData:getObjectByTypeAndLevel(cardRole.template.promote_type, cardRole.promoteLv+1)
    	local bookList      = advanceData:getMartialTable()
    	local num	  	= #bookList
		local bool = true
		local cardLv = cardRole:getLevel()
		for i=1,num do
			if cardRole.promoteBook[i] == nil then
				local bookStatus = MaterialManager:getBookStatus(bookList[i], cardLv)
				if bookStatus ~= 1 and bookStatus ~= 3 then
					bool = false
				end
			end
		end
		if bool == true then
			return true
		end
	end
	return false
end

--是否有卡牌可以突破
function CardRoleManager:isHaveRoleStarAll()
	for cardRole in self.cardRoleList:iterator() do
		local maxLimit = getCardStarLimit(cardRole.quality)
		local up = CardStarUpData:objectByRoleIdAndStar(cardRole.id, cardRole.starLv+1)
		if up and up.role_need_level <= cardRole:getLevel() and cardRole:getStarLv() < maxLimit then
			local items = stringToNumberTable(up.items_num,'_')
			local num = BagManager:getGoodsNumByTypeAndTplId(items[1], items[2])
			if num >= items[3] then
				local soul = CardSoulData:objectByID(cardRole.template.card_id)
				local num = BagManager:getGoodsNumByTypeAndTplId(soul.type, soul.id)
				if num >= up.role_frag_num then
					return true
				end
			end
		end
	end
	return false
end

--======================================   redPoint  ---======================

function CardRoleManager:getPveFormationRole()
	local formation = FormationManager:getFormationByType(EnumFormationType.PVE)
	if not formation then return nil end

	local roles = {}
	for _, cell in pairs(formation.cells) do
		roles[#roles + 1] = self:getRoleByGmId(cell.gmId)
	end
	return roles
end

function CardRoleManager:isHaveRedPoint()
	--进阶
	local book_canJump = JumpToManager:isCanJump(FunctionManager.RoleInfoBook)
	if book_canJump then
		if self:isHaveBook() then return true end
	end
	--升星
	local star_canJump = JumpToManager:isCanJump(FunctionManager.RoleInfoStar)
	if star_canJump then
		if self:isHaveStar() then return true end
	end
	--升级/传功
	local transfer_canJump = JumpToManager:isCanJump(FunctionManager.RoleInfoTransfer)
	if transfer_canJump then
		if self:isHaveTransfer() then return true end
	end
	--天命
	local destiny_canJump = JumpToManager:isCanJump(FunctionManager.RoleDestiny)
	if destiny_canJump then
		if self.mainRole and self:isHaveRoleDestiny(self.mainRole) then return true end
	end
	-- if self:isHaveEquipmen() then return true end
	--if self:isHaveSkill() then return true end
	
	--人物炼体
	RoleRefineManager:RefreshRedTipHero()
	if RoleRefineManager:IsRefineNeedRedTip() then
		return true
	end

	return false
end

function CardRoleManager:isHaveRoleRedPoint(role)
	-- print('4444444444444',self:isHaveRoleBook(role),self:isHaveRoleStar(role),self:isHaveRoleTransfer(role)
	-- ,EquipmentManager:isHavePosIdRedPoint(role.posId),self:isHaveRoleDestiny(role))
	--进阶
	local book_canJump = JumpToManager:isCanJump(FunctionManager.RoleInfoBook)
	if book_canJump then
		if self:isHaveRoleBook(role) then return true end
	end
	--升星
	local star_canJump = JumpToManager:isCanJump(FunctionManager.RoleInfoStar)
	if star_canJump then
		if self:isHaveRoleStar(role) then return true end
	end
	--升级/传功
	local transfer_canJump = JumpToManager:isCanJump(FunctionManager.RoleInfoTransfer)
	if transfer_canJump then
		if self:isHaveRoleTransfer(role) then return true end
	end
	--if self:isHaveRoleSkill(role) then return true end
	--角色红点不包括装备
	-- if role:isFormation() and EquipmentManager:isHavePosIdRedPoint(role.gmId) then return true end
	--zzteng 加天命开放的条件
	local canJump = JumpToManager:isCanJump(FunctionManager.RoleDestiny)
	if canJump then
		if self:isHaveRoleDestiny(role) then return true end
	end
	
	--炼体	
	-- print('+++++role+++',role)
	if  RoleRefineManager:JudgeHeroCanRedTip(role.gmId) then
		return true
	end
	return false
end

--是否有角色可以装备秘籍
function CardRoleManager:isHaveBook()
	local roles = self:getPveFormationRole()
	for _, role in pairs(roles) do
		if self:isHaveRoleBook(role) then
			return true
		end
	end
	return false
end

--是否有角色可以突破
function CardRoleManager:isHaveStar()
	local roles = self:getPveFormationRole() or {}
	for _, role in pairs(roles) do
		if self:isHaveRoleStar(role) then
			return true
		end
	end
	return false
end

--是否有装备红点
function CardRoleManager:isHaveEquipmen()
	local roles = self:getPveFormationRole() or {}
	for _, role in pairs(roles) do
		if EquipmentManager:isHavePosIdRedPoint(role.gmId) then
			return true
		end
	end
	return false
end


--是否有角色可以升级
function CardRoleManager:isHaveTransfer()
	local roles = self:getPveFormationRole() or {}
	for _, role in pairs(roles) do
		if not role:getIsMainRole() and self:isHaveRoleTransfer(role) then
			return true
		end
	end
	return false
end

function CardRoleManager:isHaveSkill()
	local skillPointInfo = RecoverableResManager:getRecoverParamsInfo(2)
	local value = skillPointInfo:getLeftValue()
	local coin = MainPlayer:getCoin()
	if value <= 0 or coin <= 0 then
		return false
	end

	for role in self.cardRoleList:iterator() do
		if self:isHaveRoleSkill(role) then
			return true
		end
	end
	return false
end

function CardRoleManager:isHaveRoleBook(role)
	if not role:isFormation() then return false end
	local isCan = JumpToManager:isCanJump(FunctionManager.RoleInfoBook)
	if not isCan then return false end
	return MaterialManager:isHaveBook(role)
end

function CardRoleManager:isHaveRoleStar(role)
	if not role:isFormation() then return false end
	local isCan = JumpToManager:isCanJump(FunctionManager.RoleInfoStar)
	if not isCan then return false end
	local up = CardStarUpData:objectByRoleIdAndStar(role.id, role.starLv+1)
	local maxLimit = getCardStarLimit(role.quality)
	if up == nil or up.role_need_level > role:getLevel() or role:getStarLv() >= maxLimit then
		return false
	end

	local items = stringToNumberTable(up.items_num,'_')
	local num = BagManager:getGoodsNumByTypeAndTplId(items[1], items[2])
	if num < items[3] then
		return false
	end

	local soul = CardSoulData:objectByID(role.template.card_id)
	if not soul then return false end
	num = BagManager:getGoodsNumByTypeAndTplId(soul.type, soul.id)
	if num < up.role_frag_num then
		return false
	end
	return true
end

function CardRoleManager:isHaveRoleTransfer(role)
	if not role:isFormation() then return false end
	local pillTable = {30001, 30002, 30003, 30004}
	local level = MainPlayer:getLevel()
	if role:getLevel() < level then
		local curExp = 0
		for _,v in pairs(pillTable) do
			local data = BagManager:getGoodsByTplId(v)
			if data then
				curExp = curExp + tonumber(data.template.value) * data.num
				if curExp >= role:getMaxExp() then
					return true
				end
			end
		end
	end
	return false
end

function CardRoleManager:isHaveRoleSkill(role)
	if not role:isFormation() then return false end
	local skillPointInfo = RecoverableResManager:getRecoverParamsInfo(2)
	local value = skillPointInfo:getLeftValue()

	local coin = MainPlayer:getCoin()
end

function CardRoleManager:isHaveSoulRedPoint( ... )
	local can_jump = JumpToManager:isCanJump(FunctionManager.RoleListSoul)
	if can_jump then
		return self:isHaveSoul()
	end
	return false
end

function CardRoleManager:isHaveSoul()
    local soulList = BagManager:getGoodsMapByType(EnumGoodsType.RoleFrag)
    if soulList and soulList:length() ~= 0 then
        for soul in soulList:iterator() do
            if self:isHaveRoleSoul(soul) then
            	return true
            end
        end
    end
    return false
end

function CardRoleManager:isHaveRoleSoul(soul)
	local role = CardData:objectByID(soul.template.role_id)
	if role and soul.num >= role.recruit_num and not self:isHaveRole(role.id) then
       return true
    end
    return false
end

function CardRoleManager:isHaveRoleDestiny(role)
	if not role:isFormation() then return false end
	if role.gmId ~= self.mainRole.gmId then return false end
	local totalStar = MissionManager.mainStar
	local star = DestinyData:getDestinyStar(self.destinyLevel, 7)
	return totalStar >= star
end

--==================================== redPoint end=================================

--==================================== FormationMaster ================================= 
function CardRoleManager:updateFormationMasterAttrs(type, gmId)
	local cardRole = self:getRoleByGmId(gmId)
	if cardRole then
		cardRole:updateFormationMasterAttrs(type)
	end
end


function CardRoleManager:showStarShowLayer(roleId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleStarShowLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    layer:loadData(roleId)
    AlertManager:show()
end

function CardRoleManager:showRoleVitalityLayer(callFunc, target, title)
	-- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleVitalityLayer")
 --    layer:loadData(callFunc, target, title)
 --    AlertManager:show()
 	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.CommonAutoUseLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadData(callFunc, target, EnumResourceType.Strengh, title)
    AlertManager:show()
end

function CardRoleManager:openRoleListLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleListLayer")
    AlertManager:show()
end

function CardRoleManager:openRoleStoryLayer(roleId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleStoryLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    layer:loadData(roleId)
    AlertManager:show()
end

function CardRoleManager:openRoleDescribeLayer(roleId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleDescribeLayer")
   layer:SetCardID(roleId)
   AlertManager:show()
end

function CardRoleManager:openRoleGainLayer(roleId,qianNo,isHave,pinZhi)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleGainLayer")
    layer:loadData(roleId,qianNo,isHave,pinZhi)
    AlertManager:show()
end

function CardRoleManager:openRoleQualityLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleQualityLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    AlertManager:show()
end

function CardRoleManager:openRoleTransferLayer(roldData)
	local layers = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleTransferLayer", AlertManager.BLOCK_AND_GRAY)
	layers:setCardRole(roldData)
	AlertManager:show()
end

function CardRoleManager:openHandBookDetailedLayer( roleData )
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.handbook.HandBookDetailedLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(roleData)
	AlertManager:show()
end

function CardRoleManager:openRoleZhenrongLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleZhenrongLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end
--type --1、属性 2、传功 3、进阶 4、技能 5、突破
function CardRoleManager:showRoleInfoLayer(roleId, type)
	local cardRole = self:getRoleById(roleId)
	if cardRole == nil then
		return
	end
	self:openRoleListLayer()
	self:openRoleInfoLayer(cardRole)

	local currentScene = Public:currentScene()
	if currentScene and currentScene.getTopLayer then
		local topLayer = currentScene:getTopLayer()
		if topLayer and topLayer.__cname == "RoleInfoLayer" then
			topLayer:changeType(type)
		end
	end
end

function CardRoleManager:setCardRoleInfoBtn( value )
	self.cardInfoIdx = value
end

function CardRoleManager:getCardRoleInfoBtn()
	return self.cardInfoIdx
end

return CardRoleManager:new()