--[[
******装备管理类*******

	-- by Tony
	-- 2016/9/21
]]

local BaseManager = require("lua.gamedata.BaseManager")
local EquipmentManager = class("EquipmentManager", BaseManager)

local CardEquipment = require("lua.gamedata.base.CardEquipment")
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

-- EquipmentManager.EQUIPMENT_UPDATE_BEGIN     = "EquipmentManager.EQUIPMENT_UPDATE_BEGIN"  	--装备变化前
EquipmentManager.EQUIPMENT_UPDATE_END     	= "EquipmentManager.EQUIPMENT_UPDATE_END"
EquipmentManager.EQUIPMENT_UPDATE			= "EquipmentManager.EQUIPMENT_UPDATE"     		--装备更新

EquipmentManager.EQUIPMENT_ALL_BEGIN    	= "EquipmentManager.EQUIPMENT_ALL_BEGIN"
EquipmentManager.EQUIPMENT_ALL_END   		= "EquipmentManager.EQUIPMENT_ALL_END"

EquipmentManager.EQUIPMENT_INTENSIFY 		= "EquipmentManager.EQUIPMENT_INTENSIFY" 	 	--强化
EquipmentManager.EQUIPMENT_ALL_INTENSIFY 	= "EquipmentManager.EQUIPMENT_ALL_INTENSIFY"  	--一键强化
EquipmentManager.EQUIPMENT_STAR 			= "EquipmentManager.EQUIPMENT_STAR"		  		--升星
EquipmentManager.EQUIPMENT_REFINING 		= "EquipmentManager.EQUIPMENT_REFINING"   		--精炼
EquipmentManager.EQUIPMENT_GEM 				= "EquipmentManager.EQUIPMENT_GEM"   	 		--宝石
EquipmentManager.EQUIPMENT_UP_LOCK			= "EquipmentManager.EQUIPMENT_UP_LOCK"	 		--上锁
EquipmentManager.EQUIPMENT_UP_DOWN			= "EquipmentManager.EQUIPMENT_UP_DOWN"	 		--装备穿卸换
EquipmentManager.EQUIPMENT_GEM_INSET_BEGIN	= "EquipmentManager.EQUIPMENT_GEM_INSET_BEGIN"  --宝石镶嵌前
EquipmentManager.EQUIPMENT_GEM_INSET		= "EquipmentManager.EQUIPMENT_GEM_INSET"  		--宝石镶嵌
EquipmentManager.EQUIPMENT_GEM_COMPOSE		= "EquipmentManager.EQUIPMENT_GEM_COMPOSE"		--宝石合成
EquipmentManager.EQUIPMENT_GEM_ALL_COMPOSE	= "EquipmentManager.EQUIPMENT_GEM_ALL_COMPOSE"	--宝石一键合成
EquipmentManager.EQUIPMENT_MASTER			= "EquipmentManager.EQUIPMENT_MASTER"			--装备大师

EquipmentManager.EQUIP_ONE_KEY_UNLOAD		= "EquipmentManager.EQUIP_ONE_KEY_UNLOAD"		--装备一键卸载
EquipmentManager.GEM_ONE_KEY_UNLOAD			= "EquipmentManager.GEM_ONE_KEY_UNLOAD"			--宝石一键卸载

function EquipmentManager:ctor()
	self.super.ctor(self)
end

function EquipmentManager:init()

	self.roleEquipList = TFMapArray:new()
	self.equipMasterList = {}
	TFDirector:addProto(s2c.GET_EQUIPS, self, self.onReceiveGetEquips)
	TFDirector:addProto(s2c.UPDATE_EQUIPS, self, self.onReceiveUpdateEquip)
	TFDirector:addProto(s2c.EQUIP_ROLE_RESULT, self, self.onEquipRoleResult)
	TFDirector:addProto(s2c.AUTO_EQUIP_ROLE_RESULT, self, self.onAutoEquipRoleResult)
	TFDirector:addProto(s2c.EQUIP_INTENSIFY_RESULT, self, self.onReceiveIntensifyResult)  		--强化
	TFDirector:addProto(s2c.EQUIPMENT_INTENSIFY_AUTO_RESULT, self, self.onReceiveIntensifyTop)	--一键强化
	TFDirector:addProto(s2c.EQUIPMENT_STAR_UP_RESULT, self, self.onReceiveStarResult)   		--装备升星
	TFDirector:addProto(s2c.EQUIPMENT_REFINING_RESULT, self, self.onReceiveRefiningResult)    	--装备精炼

	TFDirector:addProto(s2c.ALL_EQUIP_MASTER, self, self.onReceiveAllEquipMasterInfo)
	TFDirector:addProto(s2c.UPDATE_EQUIP_MASTER, self, self.onReceiveUpdateEquipMaster)
	TFDirector:addProto(s2c.EQUIPMENT_LOCK_RESULT, self, self.onEquipLockResult)
	TFDirector:addProto(s2c.GEM_SET, self, self.onGemSet)
	TFDirector:addProto(s2c.GEM_COMPOSE, self, self.onGemCompose)	
	TFDirector:addProto(s2c.ALL_GEM_COMPOSE, self, self.onAllGemCompose)
	-- TFDirector:addProto(s2c.PAY_SIGN_RESULT, self, self.onPaySignResult)
	TFDirector:addProto(s2c.EQUIP_ONE_KEY_UNLOAD_RES, self, self.equipOneKeyUnloadRes)			--装备一键卸载
	TFDirector:addProto(s2c.GEM_ONE_KEY_UNLOAD_RES, self, self.GemOneKeyUnloadRes)				--宝石一键卸载
end

function EquipmentManager:restart()
	for k,v in pairs(self.equipMasterList) do
		v = nil
	end
	self.equipMasterList = {}

	self:resetEquipList()
end

function EquipmentManager:resetEquipList()
	for equipList in self.roleEquipList:iterator() do
		for _,equip in pairs(equipList) do
			equip:dispose()
		end
		equipList = nil
	end
	self.roleEquipList:clear()
end

function EquipmentManager:onReceiveAllEquipMasterInfo(event)
	local data = event.data

	if not data then return end
	self:updateAllEquipMaster(data.masters)
end

function EquipmentManager:onReceiveUpdateEquipMaster(event)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	
	local data = event.data

	if not data then return end
	if data.masterId then
		self:updateEquipMasterIsUpLevel(data)
	end
	self:updateEquipMaster(data)
	CardRoleManager:updateRoleMasterAttr(data.cardId)


	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_MASTER, 0)
end

function EquipmentManager:updateAllEquipMaster(allMaster)
	if not allMaster then return end
	for _, masterData in pairs(allMaster) do
		self:updateEquipMaster(masterData)
	end
	CardRoleManager:updateMasterAttr()
end

function EquipmentManager:updateEquipMaster(masterData)
	local masters = {}	
	if masterData.masterId then
		for k,v in pairs(masterData.masterId) do
			local item = CardMasterData:objectByID(v)
			if item then
				masters[item.type] = item
			end
		end
	end
	self.equipMasterList[masterData.cardId] = masters
end

function EquipmentManager:updateEquipMasterIsUpLevel(masterData)

	local upMaster = {}
	if masterData.masterId then
		for k,v in pairs(masterData.masterId) do
			local item = CardMasterData:objectByID(v)
			local masters = self:getEquipMaster(masterData.cardId, item.type)
			local valueType = {oldValue = 0, newValue = 0}
			if masters then
				if item.condition > masters.condition then
					valueType.oldValue = masters.id
					valueType.newValue = item.id

					upMaster[#upMaster + 1] = valueType
				end
			else
				valueType.oldValue = 0
				valueType.newValue = item.id

				upMaster[#upMaster + 1] = valueType
			end
		end
	end

	if #upMaster > 0 then
		self:openEquipmentMasterUpLayer(upMaster)
	end
end

function EquipmentManager:getEquipMaster(slotId, type)
	local masters = self.equipMasterList[slotId]

	if masters then
		return masters[type]
	end

	return nil
end

function EquipmentManager:getEquipMasterList()
	return self.equipMasterList
end

function EquipmentManager:getEquipMasterById(gmId)
	return self.equipMasterList[gmId]
end

function EquipmentManager:onReceiveGetEquips(event)
	-- print("==================   EquipmentManager   get Equips ==", event.data.equips)

	self:resetEquipList()

	local data = event.data
	self:addEquipments(data.equips)
end

function EquipmentManager:onReceiveUpdateEquip(event)
	hideLoading()

	-- print("===================== EquipmentManager ===  update equip", event.data.equips)
	local data = event.data
	self:addEquipments(data.equips)
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, 0)
end

function EquipmentManager:onEquipRoleResult(event)
	hideLoading()

	-- print("=======  equipRole =====")
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UP_DOWN, 0)
end

--一键装备
function EquipmentManager:onAutoEquipRoleResult(event)
	hideLoading()

	--print("========== auto equip role =============== ")
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UP_DOWN, 0)
end

function EquipmentManager:onReceiveIntensifyResult(event)
	hideLoading()

	local data = event.data
	self.equipIntensifyData = event.data.addLv
	--local equip = self:updateEquipIntensify(data)

	--CardRoleManager:updateRoleEquipAttrBySlot(equip.slotId)
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_INTENSIFY, 0)
end

function EquipmentManager:GetEquipStrengthenData()
	-- body
	return self.equipIntensifyData
end

function EquipmentManager:onReceiveIntensifyTop(event)
	hideLoading()

-- 	local data = event.data
-- 	local res = data.res
-- 	local slotId = data.soltId
-- 	for _, intensify in pairs(res) do
-- 		self:updateEquipIntensify(intensify, slotId)
-- 	end

-- 	--CardRoleManager:updateRoleEquipAttrBySlot(slotId)
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_INTENSIFY, 0)
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_ALL_INTENSIFY, 0)
end

function EquipmentManager:onReceiveStarResult(event)
	hideLoading()

	--local equipId = event.data.equipId
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_STAR, 0)
end

function EquipmentManager:onReceiveRefiningResult(event)
	hideLoading()

	--local equipId = event.data.equipId
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_REFINING, 0)
end

function EquipmentManager:onEquipLockResult(event)
	hideLoading()
	
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UP_LOCK, 0)
end

function EquipmentManager:onAllGemSet(event)
	hideLoading()

	local data = event.data
	local slotId = data.slotId
	local set = data.set

	for _,v in pairs(set) do
		local equip = self:getEquipmentBySlotAndID(slotId, v.equipId)
		if equip then
			equip:updateGemPos(v.gem)
		end
	end

	CardRoleManager:updateRoleEquipAttrBySlot(slotId)
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_ALL_END, 0)
end

function EquipmentManager:onGemSet(event)
	hideLoading()
	
	--local equipId = event.data.equipId
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_GEM_INSET, 0)
end

--宝石合成
function EquipmentManager:onGemCompose(event)
	hideLoading()
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_GEM_COMPOSE, 0)
end
--宝石一键合成
function EquipmentManager:onAllGemCompose(event)
	hideLoading()
	
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_GEM_COMPOSE, 0)
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_GEM_ALL_COMPOSE, 0)
end
--装备一键卸载
function EquipmentManager:equipOneKeyUnloadRes(event)
	hideLoading()
	
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIP_ONE_KEY_UNLOAD, 0)
end
--宝石一键卸载
function EquipmentManager:GemOneKeyUnloadRes(event)
	hideLoading()
	
	TFDirector:dispatchGlobalEventWith(EquipmentManager.GEM_ONE_KEY_UNLOAD, 0)
end


--------装备操作类型--------------------------------
--跳字使用
function EquipmentManager:SetEquipOperate( type )
	self.equipOperateType = type
end

function EquipmentManager:GetEquipOperate()
	return self.equipOperateType 
end

--------proto=--------------------------------------

--装备强化
function EquipmentManager:sendEquipmentIntensify(equipId, times)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:SetEquipOperate(EnumMasterType.EquipIntension)
	self:sendWithLoading(c2s.EQUIPMENT_INTENSIFY, equipId, times)
end

--装备升星
function EquipmentManager:sendEquipmentStar(equipId)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:SetEquipOperate(EnumMasterType.EquipStar)
	self:sendWithLoading(c2s.EQUIPMENT_STAR_UP, equipId)
end

--装备精炼
function EquipmentManager:sendEquipmentRefining(equipId, times)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:SetEquipOperate(EnumMasterType.EquipRefining)
	self:sendWithLoading(c2s.EQUIPMENT_REFINING, equipId, times)
end

--装备加锁   如果是上锁就解锁，如果是没锁就加锁
function EquipmentManager:sendEquipmentLock(equipId, posId)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.EQUIPMENT_LOCK, equipId, posId)
end

--宝石一键镶嵌
function EquipmentManager:sendEquipmentAllGemSet(slotId)
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_ALL_BEGIN, 0)
	self:SetEquipOperate(EnumMasterType.EqupGemComplete)
	self:sendWithLoading(c2s.ALL_GEM_SET, slotId)
end

--装备镶嵌和拆卸  宝石id 为0时表示拆卸
function EquipmentManager:sendEquipmentGemSet(equipId, itemId, pos)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:SetEquipOperate(EnumMasterType.EqupGemComplete)
	self:sendWithLoading(c2s.GEM_SET, equipId, itemId, pos)
end

--宝石合成
function EquipmentManager:sendEquipmentGemCompose(itemId, isAuto)
	self:sendWithLoading(c2s.GEM_COMPOSE, itemId, isAuto)
end

--一键装备
function EquipmentManager:sendAutoEquipmentRole(roleId)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.AUTO_EQUIP_ROLE, roleId)
end

--一键强化
function EquipmentManager:sendAutoEquipmentIntensifyAuto(roleId,equipId)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:SetEquipOperate(EnumMasterType.EquipIntension)
	self:sendWithLoading(c2s.EQUIPMENT_INTENSIFY_AUTO, tostring(roleId), tostring(equipId))
end

--一键合成
function EquipmentManager:sendEquipmentAllGemCompose(level)
	self:sendWithLoading(c2s.ALL_GEM_COMPOSE, level)
end

--角色装备
function EquipmentManager:sendEquipmentRole(roleId, equipId)
	-- TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_BEGIN, 0)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, 0)
	self:sendWithLoading(c2s.EQUIP_ROLE, roleId, equipId)
end

--装备一键卸下
function EquipmentManager:sendEquipOneKeyUnLoad(roleId)
	self:sendWithLoading(c2s.EQUIP_ONE_KEY_UNLOAD, roleId)
end

--宝石一键卸下
function EquipmentManager:sendGemOneKeyUnLoad(roleId)
	self:sendWithLoading(c2s.GEM_ONE_KEY_UNLOAD, roleId)
end
----------------------------  end -----------------

function EquipmentManager:addEquipments(equips)
	local posIds = {}
	equips = equips or {}
	for _, equip in pairs(equips) do
		self:updateEquipment(equip)
		posIds[equip.posId] = equip.posId
	end
	for _, posId in pairs(posIds) do
		CardRoleManager:updateRoleEquipAttrByGmId(posId)
	end

end

function EquipmentManager:updateEquipment(equip)
	local equipList = self.roleEquipList:objectByID(equip.posId)
	if not equipList then
		equipList = {}
		self.roleEquipList:pushbyid(equip.posId, equipList)
	end

	if equip and equip.num and equip.num <= 0 then
		equipList[equip.id] = nil
	else
		self:updateCardEquipment(equip)
	end

end

function EquipmentManager:updateCardEquipment(equip)
	local equipList = self.roleEquipList:objectByID(equip.posId)
	if not equipList then return end
	local cardEquip = equipList[equip.id]
	if cardEquip then
		cardEquip:updateInfo(equip)
	else
		cardEquip = CardEquipment:new(equip)
		equipList[equip.id] = cardEquip
	end
end

--得到角色装备的套装属性
function EquipmentManager:getSuitAttbuteByRoleId( roleId )
	local attr = {}
	local suitsData = self:getSuitsDataByRoleId(roleId)
	for _,data in pairs(suitsData) do
	   for k,v in pairs(data.activeSuitList) do
		  local suitAttrbute = GetAttrByStringForExtra(v.act_attr1_client)
		  for k,v in pairs(suitAttrbute) do
			if not attr[k] then attr[k] = 0 end  
			attr[k] = attr[k] + v
		  end 
	   end
	end
	print('EquipmentManager:getSuitAttbuteByRoleId:',attr)
	return attr
end
--套装的数据封装
--[[
	suit_id:套装id
	count：拥有该套装id数量
	activeSuitList：拥有该套装id，套装表数据列表
]]
function EquipmentManager:getSuitsDataByRoleId( roleId )
	local suitsData = {}         --激活套装
	local suitList = self:getSuitIdAndCountByRoleId(roleId)
	for suit_id,count in pairs(suitList) do
		local suitListData = EquipSuitData:getActiveEquipSuitListData(suit_id,count)
		local unit_data = {}
		unit_data.suit_id = suit_id
		unit_data.count = count
		unit_data.activeSuitList = suitListData
		suitsData[#suitsData + 1] = unit_data
	end
	return suitsData
end
--得到角色装备的套装suit_id和数量count
function EquipmentManager:getSuitIdAndCountByRoleId( roleId )
	local equipList = self:getEquipListByPos(roleId)
	local suitList = {}
	if type(equipList) ~= 'table' then return suitList end
	for _,equip in pairs(equipList) do
		local suit_id = equip.template.suit_id
		if suit_id ~= 0 then
			if suitList[suit_id] then
				 suitList[suit_id] = suitList[suit_id] + 1
			else
				 suitList[suit_id] = 1
			end
		end
	end
	return suitList
end

function EquipmentManager:getEquipmentByPosAndID(posId, id)
	local equipList = self.roleEquipList:objectByID(posId)
	if equipList == nil then return nil end
	return equipList[id]
end

function EquipmentManager:getEquipmentByPosAndType(posId, equipType)
	local equipList = self.roleEquipList:objectByID(posId)
	if equipList == nil then return nil end
	for _, equip in pairs(equipList) do
		if equip.equipType == equipType then
			return equip
		end
	end
	return nil
end

--获得可以重生的装备
function EquipmentManager:getEquipListToRebirth()
	local equipList = TFArray:new()
	local equipContainer = BagManager:getGoodsMapByType(EnumGoodsType.Equipment)
	if equipContainer then
		for v in equipContainer:iterator() do
			if self:isHaveFoster(v) and not v.lock then
				equipList:push(v)
			end
		end
	end

	return equipList
end

--获得不可重生的装备
function EquipmentManager:getEquipListToComposit()
	local equipList = TFArray:new()
	local equipContainer = BagManager:getGoodsMapByType(EnumGoodsType.Equipment)
	local maxQuality = ConstantData:getValue("Equip.Five.To.One.Max.Quality")
	if equipContainer then
		for v in equipContainer:iterator() do
			local is_book = self:isHaveFoster(v)
			if not is_book and not v.lock and v.template.quality <= maxQuality then
				equipList:push(v)
			end
		end
	end

	return equipList
end

--判断装备是否被培养
function EquipmentManager:isHaveFoster(equip)
	local is_book = false
	if equip.level > 1 or equip.star > 0 then
		is_book = true
	end

	for k,v in pairs(equip.cardEquip.gemPos) do
		if v.id ~= 0 then is_book = true end
	end
		
	for k,v in pairs(equip.cardEquip.refineAttr) do
		if v.attrValue ~= 0 then is_book = true end
	end

	return is_book 
end

--通过角色id 获取该角色的所有装备
function EquipmentManager:getEquipListByPos(posId)
	return self.roleEquipList:objectByID(posId)
end

--获取所有角色的装备
function EquipmentManager:getAllRoleEquipList()
	return self.roleEquipList
end

--获取所有类型装备（背包、穿戴）
function EquipmentManager:getEquipTypeByType(type)
	local equipContainer = BagManager:getGoodsMapByType(EnumGoodsType.Equipment)
	if equipContainer then
		for v in equipContainer:iterator() do
			if v.template.kind == type then
				return true
			end
		end
	end

	for item in self.roleEquipList:iterator() do
		for k,v in pairs(item) do
			if v.template.kind == type then
				return true
			end		
		end	
	end

	return false
end

function EquipmentManager:isHaveEquipInRoleEquipByUid(gmId)
	local is_bool = false
	for item in self.roleEquipList:iterator() do
		for k,v in pairs(item) do
			if gmId == v.id then
				is_bool = true
				break
			end		
		end	
	end
	return is_bool
end

function EquipmentManager:getEquipmentByID(id)
	for equipList in self.roleEquipList:iterator() do
		for _, equip in pairs(table_name) do
			if equip.id == id then
				return equip
			end
		end
	end
	return nil
end

function EquipmentManager:updateEquipIntensify(data, slotId)
	local levelUp = data.IntensifyLevelUp
	local equipId = data.equipId
	local level = data.level
	local times = data.times

	local equip = nil

	if slotId then
		equip = self:getEquipmentBySlotAndID(slotId, equipId)
	else
		equip = self:getEquipmentByID(equipId)
	end
	equip:setLevel(level)

	-- for i=1,times do
	-- 	equip:setLevel(equip:getLevel()+levelUp[i])
	-- 	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_UPDATE_END, 0)
	-- end
	-- equip:setLevel(level)
	return equip
end

----------------- redpoint------------------------------

function EquipmentManager:isHaveRedPoint()
	-- local count = FormationManager:countSlot(EnumEquipmentType.PVE) + 1
	-- for i=1,count do
	-- 	if self:isHaveSlotRedPoint(i) then return true end
	-- end
	return false
end

function EquipmentManager:EquipRedPointSystem()
	local is_bool = false
	-- for i=1, 5 do
	-- 	local cell = FormationManager:getEquipSlot(EnumFormationType.PVE, i)
	-- 	if cell and cell.gmId and cell.gmId ~= "0" then
	-- 		if self:isHaveSlotRedPoint(i) then return true end
	-- 	end
	-- end
	return is_bool
end

function EquipmentManager:isHaveGoodEquipRedPoint(equip)
	if self:isHaveGoodEquip(equip) then
		return true
	end

	if self:isHaveEquipRedPoint(equip) then
		return true
	end

	return false
end

function EquipmentManager:isHaveGoodEquip(equip)
	
	local equipContainer = BagManager:getGoodsMapByType(EnumGoodsType.Equipment)
	if equipContainer then
		for v in equipContainer:iterator() do
			if v.template.kind == equip.template.kind and v.template.quality > equip.template.quality then
				return true
			end
		end
	end
	return false
end

function EquipmentManager:isHaveFreeEquipRedPoint(kind, functionId)
	local canJump = JumpToManager:isCanJump(functionId)
	if not canJump then return false end
	-- local configure = FunctionOpenConfigure:objectByID(functionId)
	-- local teamLevel = MainPlayer:getLevel()
	-- if configure.level > teamLevel then return false end

	local equipContainer = BagManager:getGoodsMapByType(EnumGoodsType.Equipment)
	if equipContainer then
		for v in equipContainer:iterator() do
			if v.template.kind == kind then
				return true
			end
		end
	end
	return false
end

--判断卡牌是否有更好的装备、装备是否可以培养
function EquipmentManager:isHavePosIdRedPoint(roleid)
	local equipList = {}
	-- if MainPlayer:getMainRole().gmId ~= roleid then
	-- 	return
	-- end
	local roleEquipList = self:getEquipListByPos(roleid)
	if roleEquipList then
		for k,v in pairs(roleEquipList) do
			equipList[v.equipType] = v
		end
	end

	for i=1,5 do
		if equipList[i] then
			if self:isHaveGoodEquipRedPoint(equipList[i]) then return true end
		else
			if self:isHaveFreeEquipRedPoint(i,FunctionManager.Equipment + i) then return true end
		end
	end
	return false
end

function EquipmentManager:isHaveEquipRedPoint(equip)
	local posId = equip.posId
	if self:isHaveIntensifyRedPoint(equip) then return true end
	if self:isHaveStarRedPoint(equip) then return true end
	-- if self:isHaveQualityRedPoint(equip)  then return true end
	if self:isHaveRefiningRedPoint(equip) then return true end
	if self:isHaveGemRedPoint(equip)  then return true end
	return false
end

function EquipmentManager:isHaveIntensifyRedPoint(equip)
	if not JumpToManager:isCanJump( FunctionManager.EquipmentIntensify ) then return false end
	local level = equip:getLevel()
	local coin = MainPlayer:getCoin()
	if level >= ConstantData:getValue("Equip.Intensify.Level.Limit") then return false end
	local need_coin = EquipIntensifyData:getValue(level+1)
	if coin >= need_coin and level < 2*MainPlayer:getLevel() then
		return true
	end
	return false
end

function EquipmentManager:isHaveStarRedPoint(equip)
	local configure = FunctionOpenConfigure:objectByID(FunctionManager.EquipmentStar)
	local teamLevel = MainPlayer:getLevel()
	if configure.level > teamLevel then return false end

	if not JumpToManager:isCanJump( FunctionManager.EquipmentStar ) then return false end
	local starLv = equip:getStarLv()
	local coin = MainPlayer:getCoin()
	local upStar = EquipStarData:getDataByIdAndStar(equip.tplId, starLv+1)
	if not upStar then return false end
	if coin < upStar.coin then return false end
	if starLv >= ConstantData:getValue("Equip.Star.Limit") then return false end

	local materialTable, indexTable = upStar:getMaterialTable()
	indexTable = indexTable or {}
	for k,v in pairs(indexTable) do
		-- local item = GoodsItemData:objectByID(v)
		-- local num = BagManager:getGoodsNumByTypeAndTplId(item.type, v)
		-- if materialTable[v] > num then return false end

		local types = math.floor( v / 10000)
		local num = 0 
		local item = nil
		if types == 3 then
			item = GoodsItemData:objectByID(v)
			num = BagManager:getGoodsNumByTypeAndTplId(types, v)
		elseif types == 5 then
			item = EquipData:objectByID(v)
			num = BagManager:getNoLockEquipNumByTypeAndTplId(types, v)
		end
		if materialTable[v] > num then return false end
	end

	return true
end

function EquipmentManager:isHaveQualityRedPoint(equip)
	-- local coin = MainPlayer:getCoin()
	-- if coin < equip.template.coin_quality then return false end
	-- local upEquip = EquipData:objectByID(equip.template.up_equip_id)
	-- if not upEquip then return false end
	-- local materialTable, indexTable = equip.template:getMaterialTable()
	-- indexTable = indexTable or {}
	-- for k,v in pairs(indexTable) do
	-- 	local material = EquipFragData:objectByID(v)
	-- 	local num = BagManager:getGoodsNumByTypeAndTplId(material.type, v)
	-- 	if materialTable[v] > num then return false end
	-- end
	return false
end

function EquipmentManager:isHaveRefiningRedPoint(equip)
	local configure = FunctionOpenConfigure:objectByID(FunctionManager.EquipmentRefining)
	local teamLevel = MainPlayer:getLevel()
	if configure.level > teamLevel then return false end
	if not JumpToManager:isCanJump( FunctionManager.EquipmentRefining ) then return false end
	local refineAttr = equip:getRefineAttr()
	if not refineAttr then return false end
	local stone = ConstantData:objectByID("Equip.Refine.Consume.GoodsId.Num")
	local item = GoodsItemData:objectByID(stone.res_id)
	local num = BagManager:getGoodsNumByTypeAndTplId(item.type, item.id)
	if stone.value > num then return false end
	
	local minLevel = ConstantData:getValue("Equip.Refining.Level.Limit")
	for i,v in pairs(refineAttr) do
		local curLevel = v.level + 1
		if minLevel > curLevel then
			minLevel = curLevel
		end
	end
	local refinData = EquipRefiningCoinData:objectByID(minLevel * 100 + equip.template.quality)
	if not refinData then return false end
	if MainPlayer:getCoin() < refinData.coin then return false end
	for k,v in pairs(refineAttr) do
		local maxLv = math.floor(equip:getLevel()/10)
		maxLv = math.max(1, maxLv ) 
		if maxLv > v.level then return true end
	end
	return false
end

function EquipmentManager:isHaveGemRedPoint(equip)
	if not JumpToManager:isCanJump( FunctionManager.EquipmentGem ) then return false end
	local gemPos = equip:getGemPos()
	if not gemPos or #gemPos == 0 then return false end
	local gemMaxLevel = ConstantData:getValue( "Gem.Level.Limit" )
	local function isHighGem(type, gem)
		if not type then return false end
		local types = stringToNumberTable(type, ',')
		local bagList = BagManager:getGoodsMapByType(EnumGoodsType.EquipGem) 
		if not bagList then return false end

		local gemList = TFArray:new()
		if bagList and bagList:length() ~= 0 then
			for item in bagList:iterator() do
				local is_type = false
				if type then
					for k,v in pairs(types) do
						if item.template.kind == v then
							is_type = true
							break
						end
					end
	
					if item and is_type and item.template.level <= gemMaxLevel then
						gemList:push(item)
					end
				else
					if item and item.template.level <= gemMaxLevel then
						gemList:push(item)
					end
				end		
			end
		end

		if gem then
			-- for i,v in pairs(types) do
				for item in gemList:iterator() do
					if item and item.template.kind == gem.kind and 
							item.template.level > gem.level then
						return true
					end
				end	
			-- end	
		else
			for i,v in pairs(types) do
				for item in gemList:iterator() do
					if item and item.template.kind == v then
						return true
					end
				end	
			end	
		end	
  		return false
	end
	for _,gem in pairs(gemPos) do
		local type = EquipGemPosData:getGemTypeByIdAndPos(equip.equipType, gem.pos)
		if isHighGem(type, gem.template) then return true end
	end
	return false
end

--------------------------- end ---------------------------
-- equipType   装备类型
-- fosterType  只有在装备大师里面生效
function EquipmentManager:openEquipmentLayer(equipType, fosterType)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.equipment.EquipmentLayer")
   layer:loadData(equipType, fosterType)
   AlertManager:show()
end

function EquipmentManager:openEquipmentListLayer(data)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.equipment.EquipmentListLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	layer:setCardEquipment(data)
	AlertManager:show()
end

--装备大师界面
function EquipmentManager:openEquipmentMasterLayer(slotId)
	local layer = require("lua.logic.equipment.EquipmentMasterLayer"):new(slotId)
	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end

--装备大师升级界面
function EquipmentManager:openEquipmentMasterUpLayer(data)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.equipment.EquipmentMasterUpLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(data)
	AlertManager:show()
end

function EquipmentManager:openEquipmentGemComposeLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.equipment.EquipmentGemComposeLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData()
	AlertManager:show()
end

function EquipmentManager:openEquipmentGemOneKeyComposeLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.equipment.EquipmentChangeGemLvLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

return EquipmentManager:new()

