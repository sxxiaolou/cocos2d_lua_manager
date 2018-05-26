-- 法宝管理类
-- Author: Jin
-- Date: 2016-10-08
--

local BaseManager = require('lua.gamedata.BaseManager')
local TalismanManager = class("TalismanManager", BaseManager)
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

TalismanManager.UpdateMagicWeaponSlot = "TalismanManager.UpdateMagicWeaponSlot"
TalismanManager.REFRESH_PLAYER_LIST = "TalismanManager.REFRESH_PLAYER_LIST"
TalismanManager.TALISMAN_COMPOSE 	= "TalismanManager.TALISMAN_COMPOSE"
TalismanManager.GRAB_TALISMAN 		= "TalismanManager.GRAB_TALISMAN"

function TalismanManager:ctor()
	self.super.ctor(self)
end

function TalismanManager:init()
	self.super.init(self)

	self.slotTalismans = {}

	TFDirector:addProto(s2c.GET_MAGIC_WEAPONS, self, self.onReceiveGetMagicWeapons)
	TFDirector:addProto(s2c.UPDATE_MAGIC_WEAPON_SLOT, self, self.onReceiveUpdateMagicWeaponSlot)
	TFDirector:addProto(s2c.MAGIC_WEAPON_LEVEL_UP, self, self.onReceiveMagicWeaponLevelUp)
	TFDirector:addProto(s2c.MAGIC_WEAPON_AUTO_LEVEL_UP, self, self.onReceiveMagicWeaponAutoLevelUp)
	TFDirector:addProto(s2c.MAGIC_WEAPON_STAR_UP, self, self.onReceiveMagicWeaponStarUp)

	TFDirector:addProto(s2c.MAGIC_WEAPON_PLAYER_LIST, self, self.onReceivePlayerList)
	TFDirector:addProto(s2c.GRAB_MAGIC_WEAPON, self, self.onReceiveGrabMagicWeapon)
	TFDirector:addProto(s2c.AUTO_GRAB_MAGIC_WEAPON, self, self.onReceiveAutoGrabMagicWeapon)
	TFDirector:addProto(s2c.MAGIC_WEAPON_COMPOSE, self, self.onReceiveMagicWeaponCompose)
end

function TalismanManager:restart()
	self.slotTalismans = {}
end

-- protocol
function TalismanManager:sendTalismanPlayerList(talismanFragId)
	self:sendWithLoading(c2s.MAGIC_WEAPON_PLAYER_LIST, talismanFragId)
end

--夺宝 进战斗
function TalismanManager:sendGrabTalisman(playerId, isNpc, talismanFragId)
	self:sendWithLoading(c2s.GRAB_MAGIC_WEAPON, playerId, isNpc, talismanFragId)
end

function TalismanManager:sendGrabSweepTalisman(times, talismanFragId)
	self:sendWithLoading(c2s.GRAB_SWEEP_MAGIC_WEAPON, times, talismanFragId)
end

function TalismanManager:sendAutoGrabTalisman(talismanId, isAuto)
	self:sendWithLoading(c2s.AUTO_GRAB_MAGIC_WEAPON, talismanId, isAuto)
end

function TalismanManager:sendTalismanCompose(talismanId)
	self:sendWithLoading(c2s.MAGIC_WEAPON_COMPOSE, talismanId)
end

function TalismanManager:sendEquipWeapon(talismanId, slotId)
	self:sendWithLoading(c2s.EQUIP_WEAPON, talismanId, slotId)
end

function TalismanManager:sendMagicWeaponLevelUp(useIds, talisman)
	-- print("sendMagicWeaponLevelUp===", useIds, " ", talismanId)
	self.baseOldAttribute = TalismanManager:getTalismanAttribute(talisman)
	self:sendWithLoading(c2s.MAGIC_WEAPON_LEVEL_UP, useIds, talisman.id)
end

function TalismanManager:sendMagicWeaponAutoLevelUp(talisman, usePurple)
	-- print("sendMagicWeaponAutoLevelUp===", usePurple, " ", talismanId)
	self.baseOldAttribute = TalismanManager:getTalismanAttribute(talisman)
	self:sendWithLoading(c2s.MAGIC_WEAPON_AUTO_LEVEL_UP, talisman.id, usePurple)
end

function TalismanManager:sendMagicWeaponStarUp(talisman)
	-- print("sendMagicWeaponStarUp===", talismanId)
	self.baseOldAttribute, self.starOldAttribute = TalismanManager:getTalismanAttribute(talisman)
	self:sendWithLoading(c2s.MAGIC_WEAPON_STAR_UP, talisman.id)
end

function TalismanManager:onReceiveGetMagicWeapons(event)
	local data = event.data
	if not data.slots then return end

	for _, talisman in pairs(data.slots) do
		self.slotTalismans[talisman.slotId] = talisman.equipId
	end
	-- print("onReceiveGetMagicWeapons===", data.slots)
end

function TalismanManager:onReceiveUpdateMagicWeaponSlot(event)
	hideLoading()
	local data = event.data
	if not data.slots then return end

	for _, talisman in pairs(data.slots) do
		self.slotTalismans[talisman.slotId] = talisman.equipId
	end
	-- print("onReceiveUpdateMagicWeaponSlot===", data.slots)

	TFDirector:dispatchGlobalEventWith(TalismanManager.UpdateMagicWeaponSlot, 0)
end

function TalismanManager:onReceiveMagicWeaponLevelUp(event)
	hideLoading()
	local data = event.data
	-- print("onReceiveMagicWeaponLevelUp===", data)

	self.baseNewAttribute = self:getTalismanAttributeById(data.magicWeaponId)
	Public:addAttrToast(ccp(-160, -120), self.baseOldAttribute, self.baseNewAttribute)

	TFDirector:dispatchGlobalEventWith(TalismanManager.UpdateMagicWeaponSlot, 0)
end

function TalismanManager:onReceiveMagicWeaponAutoLevelUp(event)
	hideLoading()
	local data = event.data
	-- print("onReceiveMagicWeaponAutoLevelUp===", data)

	self.baseNewAttribute = self:getTalismanAttributeById(data.magicWeaponId)
	Public:addAttrToast(ccp(-160, -120), self.baseOldAttribute, self.baseNewAttribute)

	TFDirector:dispatchGlobalEventWith(TalismanManager.UpdateMagicWeaponSlot, 0)
end

function TalismanManager:onReceiveMagicWeaponStarUp(event)
	hideLoading()
	local data = event.data
	-- print("onReceiveMagicWeaponStarUp===", data)

	self.baseNewAttribute, self.starNewAttribute = self:getTalismanAttributeById(data.magicWeaponId)
	Public:addAttrToast(ccp(-160, -120), self.starOldAttribute, self.starNewAttribute)

	TFDirector:dispatchGlobalEventWith(TalismanManager.UpdateMagicWeaponSlot, 0)
end

function TalismanManager:onReceivePlayerList(event)
	hideLoading()

	local data = event.data
	--playerList = data.players

	print("===============================")
	--print("grab player list", data.players, data.magWeapFragId)

	-- layer:loadData(playerList, talismanFragId)
	-- self:openGrabListLayer(data.players, data.magWeapFragId)
	TFDirector:dispatchGlobalEventWith(TalismanManager.REFRESH_PLAYER_LIST, data)
end

function TalismanManager:onReceiveGrabMagicWeapon(event)
	hideLoading()
	
	local data = event.data
	TFDirector:dispatchGlobalEventWith(TalismanManager.GRAB_TALISMAN, data)
end

function TalismanManager:onReceiveAutoGrabMagicWeapon(event)
	hideLoading()
	
	local data = event.data

end

function TalismanManager:onReceiveMagicWeaponCompose(event)
	hideLoading()

	local data = event.data
	print("compose ", data)
	self:openTalismanComposeResultLayer(data.tplId)
	--TFDirector:dispatchGlobalEventWith(TalismanManager.TALISMAN_COMPOSE, 0)
end


-- api
function TalismanManager:openTalismanLayer(cardRole, slotId, talismanType)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.talisman.TalismanLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setData(cardRole, slotId, talismanType)
	AlertManager:show()
end

function TalismanManager:openTalismanListLayer(talismanType, talisman, slotId)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.talisman.TalismanListLayer", AlertManager.BLOCK_AND_GRAY)
	layer:setData(talismanType, talisman, slotId)
	AlertManager:show()
end

function TalismanManager:openTalismanLevelUpLayer(talisman)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.talisman.TalismanLevelUpLayer", AlertManager.BLOCK_AND_GRAY)
	layer:setData(talisman)
	AlertManager:show()
end

function TalismanManager:openGrabTalismanLayer()
	AlertManager:addLayerToQueueAndCacheByFile("lua.logic.talisman.GrabTalismanLayer")
    AlertManager:show()
end

function TalismanManager:openGrabListLayer()
	AlertManager:addLayerToQueueAndCacheByFile("lua.logic.talisman.GrabListLayer")
    AlertManager:show()
end

function TalismanManager:openTalismanPassLayer(times, fragId, fragList, state)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.talisman.TalismanPassLayer")
    layer:loadData(times, fragId, fragList, state)
    AlertManager:show()
end

function TalismanManager:openTalismanComposeResultLayer(talismanId)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.talisman.TalismanComposeResultLayer")
    layer:loadData(talismanId)
    AlertManager:show()
end

-- 获取升星能使用的法宝数量
function TalismanManager:getStarTalismanNum(tplId)
	local goodsType = BagManager:getGoodsTypeByTplId(tplId)
	local allTalismans = BagManager:getGoodsMapByType(EnumGoodsType.Talisman)
	local num = 0
	for talisman in allTalismans:iterator() do
		if talisman.template.id == tplId and talisman.level < 2 and talisman.star < 1 and self:slotWear(talisman.id) < 1 then
			num = num + 1
		end
	end
	return num
end

-- 根据类型获取所有法宝
function TalismanManager:getAllTalismansByType(talismanType)
	local allTalismans = BagManager:getGoodsMapByType(EnumGoodsType.Talisman)
	local talismans = {}
	for talisman in allTalismans:iterator() do
		if talisman.template.kind == talismanType then
			talismans[#talismans + 1] = talisman
		end
	end
	table.sort(talismans, function(t1, t2) 
			local isWear1 = self:slotWear(t1.id) > 0
			local isWear2 = self:slotWear(t2.id) > 0
			if isWear1 ~= isWear2 and isWear1 then return true end
			if isWear1 ~= isWear2 and isWear2 then return false end
			if t1.quality ~= t2.quality then
				return t1.quality > t2.quality
			else
				if t1.star ~= t2.star then
					return t1.star > t2.star
				else
					return t1.level > t2.level
				end
			end
		end)
	return talismans
end

-- 获取所有能获得经验的法宝
function TalismanManager:getAllExpTalismans()
	local allTalismans = BagManager:getGoodsMapByType(EnumGoodsType.Talisman)
	local talismans = {}
	for talisman in allTalismans:iterator() do
		local isWear = self:slotWear(talisman.id) > 0
		if not isWear and talisman.star < 1 then
			talismans[#talismans + 1] = talisman
		end
	end

	table.sort(talismans, function(t1, t2) return t1.quality < t2.quality end)

	return talismans
end

-- 获取法宝提供的经验
function TalismanManager:getTalismanExp(talisman)
	local level = talisman.level
	local exp = 0
	for i=2,level do
		local levelData = TalismanLevelData:objectByID(i)
		exp = exp + levelData.exp
	end
	return exp + talisman.exp + talisman.template.exp
end

function TalismanManager:slotWear(talismanId)
	for i=1,5 do
		local slotTalisman = self.slotTalismans[i]
		if slotTalisman then
			for k,id in pairs(slotTalisman) do
				if id == talismanId then
					return i
				end
			end
		end
	end
	return 0
end

function TalismanManager:hasTrain(talisman)
	if talisman.level > 1 or talisman.star > 0 then
		return true
	end
	return false
end

function TalismanManager:getWearRoleName(slotId)
	if slotId == 0 then return "" end

	local formation = FormationManager:getFormationByType(EnumFormationType.PVE)
	if formation then
		for _, cell in pairs(formation.cells) do
			if cell.slotId == slotId then
				if cell.gmId ~= "0" then
					local cardRole = CardRoleManager:getRoleByGmId(cell.gmId)
					return cardRole:getName()
				else
					break
				end
			end
		end
	end
	return ""
end

-- 根据槽位获取法宝(attack, defence)
function TalismanManager:getTalismans(slot)
	local talismans = self.slotTalismans[slot]
	local talismanId1 = talismans and talismans[1] or nil
	local talismanId2 = talismans and talismans[2] or nil
	local talisman1 = BagManager:getGoodsByTypeAndId(EnumGoodsType.Talisman, talismanId1)
	local talisman2 = BagManager:getGoodsByTypeAndId(EnumGoodsType.Talisman, talismanId2)
	local kind1 = talisman1 and talisman1.template.kind or nil
	local kind2 = talisman2 and talisman2.template.kind or nil

	if kind1 == EnumTailsmanType.Attack or kind2 == EnumTailsmanType.Defence then
		return talisman1, talisman2
	elseif kind2 == EnumTailsmanType.Attack or kind1 == EnumTailsmanType.Defence then
		return talisman2, talisman1
	end
	return nil, nil
end

-- 获取法宝属性(基本属性，升星属性)
function TalismanManager:getTalismanAttribute(talisman)
    local baseAttributeData = GameAttributeData:new()
    local starAttributeData = GameAttributeData:new()

    local talismanData = GoodsTalismanData:objectByID(talisman.tplId)
    local attribute = talismanData:getAttrByLevel(talisman.level)
    baseAttributeData:initWithAttribute(attribute)

    local starData = TalismanStarData:getTalismanStarData(talisman.tplId, talisman.star)
    starAttributeData:init(starData.attrs)

	return baseAttributeData, starAttributeData
end

function TalismanManager:getTalismanAttributeById(talismanId)
	local talisman = BagManager:getGoodsByTypeAndId(EnumGoodsType.Talisman, talismanId)
	return self:getTalismanAttribute(talisman)
end

-- local
-- function TalismanManager:updateTalisman(slotTalismanData)
-- 	local talismans = {}
-- 	for _, talismanData in pairs(slotTalismanData.equips) do
-- 		local talisman = {}
-- 		talisman.id = talismanData.id
-- 		talisman.tplId = talismanData.tplId
-- 		talisman.level = talismanData.level
-- 		talisman.exp = talismanData.exp
-- 		talisman.quality = talismanData.quality
-- 		talisman.star = talismanData.star
-- 		local template = GoodsTalismanData:objectByID(talismanData.tplId)
-- 		talisman.template = template
-- 		talismans[template.kind] = talisman
-- 	end
-- 	self.slotTalismans[slotTalismanData.slotId] = talismans
-- end

----===============================  redpoint ======================

function TalismanManager:isHaveRedPoint()
	local talismanList = {}
	local residentList = GoodsTalismanData:getResidentTalisman()
	for _,resident in pairs(residentList) do
		talismanList[#talismanList+1] = resident
	end

	local fragList = BagManager:getGoodsMapByType(EnumGoodsType.TalismanFrag)
	if fragList then
		local function haveFrag(id)
			if not id then return true end
			for _,talisman in pairs(talismanList) do
				if talisman.id == id then
					return true
				end
			end
			return false
		end
		for item in fragList:iterator() do
			local talismanId = item.template.talisman_id
			if not haveFrag(talismanId) then
				talismanList[#talismanList + 1] = GoodsTalismanData:objectByID(talismanId)
			end
  		end
	end

	for _,talisman in pairs(talismanList) do
		if self:isHaveTalismanRedPoint(talisman) then return true end
	end
	return TaskManager:isHaveAchievement(EnumAchievementType.Talisman)
end

function TalismanManager:isHaveTalismanRedPoint(talisman)
	if not talisman then return false end
	local fragList = talisman:getMaterialTable()
	if not fragList or #fragList == 0 then return false end
	for _,fragId in pairs(fragList) do
		local frag = GoodsTalismanFragData:objectByID(fragId)
		local haveNum = BagManager:getGoodsNumByTypeAndTplId(EnumGoodsType.TalismanFrag, fragId)
		if haveNum == 0 then return false end
	end
	return true
end

---================================   end ============================

return TalismanManager:new()