-- 背包管理类
-- Author: Jin
-- Date: 2016-08-02
--

local BagManager = class("BagManager", BaseManager)

local CardEquipment = require("lua.gamedata.base.CardEquipment")

BagManager.UPDATE_BAG 			= "BagManager.UPDATE_BAG"
BagManager.ITEM_USED_RESULT 	= "BagManager.ITEM_USED_RESULT"
BagManager.ITEM_USE_TURN_TABLE_RESULT 	= "BagManager.ITEM_USE_TURN_TABLE_RESULT"

-- 物品结构:{
-- type=1, 类型
-- 	id=2, 实例id
-- 	tplId=3, 模板id
-- 	num=4, 数量
-- 	template={}, 模板数据
--  cardEquip = {}, 装备数据
-- }
function BagManager:ctor()
	self.super.ctor(self)
end

function BagManager:init()
	self.super.init(self)

	self.goodsTemplateTable = {
		[1] = GoodsMaterialData,
		[2] = GoodsMaterialFragData,
		[3] = GoodsItemData,
		[4] = CardSoulData,
		[5] = EquipData,
		[6] = EquipFragData,
		[7] = EquipGemData,
		[8] = GoodsTalismanData,
		[9] = GoodsTalismanFragData,
		[11] = PetFragData,
		[12] = PetSpellBookData,
		[13] = PetSpellBookFragData,
		[15] = GoodsArtifactFragData,
		[17] = GoodsFashionFragData,
		[18] = GoodPetEggFragData,
		[19] = SpecialEquipData,
		[20] = SpecialEquipFragData,
	}
	
	self.bagGoods = TFMapArray:new()
	for k,v in pairs(EnumGoodsType) do
		self.bagGoods:pushbyid(v, TFMapArray:new())
	end

	TFDirector:addProto(s2c.GET_BAG, self, self.onReceiveBagInfo)
	TFDirector:addProto(s2c.UPDATE_BAG, self, self.onReceiveUpdateBag)
	-- TFDirector:addProto(s2c.GET_PET_BAG, self, self.onReceiveGetPetBag)
	-- TFDirector:addProto(s2c.UPDATE_PET_BAG, self, self.onReceiveUpdatePetBag)
	TFDirector:addProto(s2c.ITEM_USED_RESULT, self, self.onReceiveItemUsedResult)

	TFDirector:addProto(s2c.USE_TURN_TABLE_RESULT, self, self.onUseTurnTableResult)	
end

function BagManager:restart()
	self:clearBagGoods()
end

function BagManager:clearBagGoods()
	local bagGoods = self.bagGoods
	for goods in bagGoods:iterator() do
		goods:clear()
	end
end

-- protocol
function BagManager:sendUseItem(itemId, tplId, num)
	-- print("sendUseItem === itemId:", itemId, " tplId:", tplId, " num:", num)
	self:send(c2s.ITEM_USED, itemId, tplId, num)
end

function BagManager:onReceiveBagInfo(event)
	self:clearBagGoods()

	local data = event.data
	--print("====onReceiveBagInfo good equip List ====", equipList)

	self:addGoodsInfo(data)
end

function BagManager:onReceiveUpdateBag(event)
	hideLoading()
	local data = event.data
	-- print("====onReceiveUpdateBag goodsList equipList ====", data)

	self:addGoodsInfo(data)
	TFDirector:dispatchGlobalEventWith(BagManager.UPDATE_BAG, 0)
end

function BagManager:onReceiveGetPetBag(event)
	local data = event.data
	local goodsList = data.goods

	-- print("====onReceiveGetPetBag====", data)

	if goodsList == nil then return end

	for _, goods in pairs(goodsList) do
		if goods.id then
			self:updateGoods(goods)
		end
	end
end

function BagManager:onReceiveUpdatePetBag(event)
	-- print("====onReceiveUpdatePetBag====")
	local data = event.data
	local goodsList = data.goods

	if goodsList == nil then return end
	
	for _, goods in pairs(goodsList) do
		if goods.id then
			self:updateGoods(goods)
		end
	end
	TFDirector:dispatchGlobalEventWith(BagManager.UPDATE_BAG, 0)
end

function BagManager:onReceiveItemUsedResult(event)
	hideLoading()
	local data = event.data
	--print("============  onReceiveItemUsedResult ==== ", data)
	TFDirector:dispatchGlobalEventWith(BagManager.ITEM_USED_RESULT, data)
end

function BagManager:onUseTurnTableResult( event )
	local data = event.data

	TFDirector:dispatchGlobalEventWith(BagManager.ITEM_USE_TURN_TABLE_RESULT, data)
end

-- api
function BagManager:openBagLayer(tabType)
	if not tabType then tabType = EnumGoodsType.Prop end

	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bag.BagLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setTabType(tabType)
	AlertManager:show()
end

function BagManager:openUseLayer(goods)
	local layer = require("lua.logic.bag.GoodsUseLayer"):new(goods)
	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

function BagManager:openChooseLayer(goods)
	local layer = require("lua.logic.bag.GoodsChooseLayer"):new(goods)
	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY_CLOSE)
	AlertManager:show()
end

function BagManager:addGoodsInfo(data)
	local goodsList = data.goods or {}
	local equipList = data.equips or {}

	local types = {}
	for _, goods in pairs(goodsList) do
		if goods.id then
			types[goods.type] = true
			self:updateGoods(goods)
		end
	end
	for _, equips in pairs(equipList) do
		if equips.id then
			types[equips.type] = true
			self:updateGoods(equips)
		end
	end

	self:sortBagGoods(types)
end

-- 更新物品 goods = {type=1, id=2, tplId=3, num=4, level=5, exp=6, quality=7, star=8}, num为当前数量
function BagManager:updateGoods(goods)
	if goods.num <= 0 then
		self:removeGoodsByIdAndType(goods.id, goods.type)
	else
		self:setGoods(goods)
	end
end

-- 获取某一个类型的物品
-- return a mapArray
function BagManager:getGoodsMapByType(type)
	return self.bagGoods:objectByID(type)
end

function BagManager:getGoodsMapByTypes(...)
	local types = type(...) == 'table' and ... or {...}
	local itemMap = TFMapArray:new()
	for i, gType in pairs(types) do
		local map = self.bagGoods:objectByID(gType)
		if map then
			for item in map:iterator() do
				itemMap:push(item)
			end
		end
	end
	return itemMap
end


-- 通过类型和模板ID获取某一个物品
function BagManager:getGoodsByTypeAndTplId(type, tplId)
	local map = self:getGoodsMapByType(type)
	if map then
		for item in map:iterator() do
			if item.tplId == tplId then
				return item
			end
  		end
	end
	return nil
end

-- 通过类型和实例id获取某一个物品
function BagManager:getGoodsByTypeAndId(type, id)
	local map = self.bagGoods:objectByID(type)
	if map then 
		return map:objectByID(id)
	end
	return nil
end

function BagManager:getGoodsNumByTypeAndTplId(type, tplId)
	local item = self:getGoodsByTypeAndTplId(type, tplId)
	if item then
		return item.num
	end
	return 0
end

--通过类型和实例id获取没有加锁没有培养过的装备
function BagManager:getNoLockEquipNumByTypeAndTplId(type, tplId)
	local number = 0
	local item = self:getGoodsMapByType(type)
	
	local map = self:getGoodsMapByType(type)
	if map then
		for item in map:iterator() do	
			if item.tplId == tplId and not item.lock and item.level == 1 and item.star == 0 then
				local is_book = true
				for k,v in pairs(item.cardEquip.gemPos) do
					if v.id ~= 0 then is_book = false end
				end
				
				for k,v in pairs(item.cardEquip.refineAttr) do
					if v.attrValue ~= 0 then is_book = false end
				end
				if is_book then
					number = number + 1
				end	
			end
  		end
	end
	return number
end

--通过类型和实例id获取装备数量
function BagManager:getEquipNumByTypeAndTplId(type, tplId)
	local number = 0
	local map = self:getGoodsMapByType(type)
	if map then
		for item in map:iterator() do	
			if item.tplId == tplId then
				number = number + 1
			end
  		end
	end
	return number
end

-- 通过物品模板Id获取物品类型
function BagManager:getGoodsTypeByTplId(tplId)
	local str_id = tostring(tplId)
    local offset = #str_id > 5 and 2 or 1
    local goodsType = string.sub(str_id, 1, offset)
    return tonumber(goodsType)
end

-- 通过模板ID获取某一物品(物品编码第一位为物品类型)
function BagManager:getGoodsByTplId(tplId)
    local numType = self:getGoodsTypeByTplId(tplId)
    if numType then
    	return self:getGoodsByTypeAndTplId(numType, tplId)
    end

    return nil
end

function BagManager:getGoodsNumByTplId(tplId)
	local goods = self:getGoodsByTplId(tplId)
	if goods then
		return goods.num
	end
	return 0
end

-- 获取物品的模板数据
function BagManager:getGoodsTemplateByTplId(tplId)
	local numType = self:getGoodsTypeByTplId(tplId)
    return self:getGoodsTemplate(numType, tplId)
end

function BagManager:getGoodsTemplate(type, tplId)
	local goodsList = self.goodsTemplateTable[type]
	local goods = nil
	if goodsList then
		goods = goodsList:objectByID(tplId)
	end
	return goods
end

-- 获取道具列表(默认按品质排序)
function BagManager:getItemsBySubType(subType)
	local items = {}
	local map = self:getGoodsMapByType(EnumGoodsType.Prop)
	if map then
		for item in map:iterator() do
			if item.template.kind == subType then
				items[#items + 1] = item
			end
  		end
	end
	table.sort(items, function(item1, item2) return item1.template.quality < item2.template.quality end)
	return items
end

-- 获取经验法宝
function BagManager:getExpTalisman()
	local expTalismans = {}
	local map = self:getGoodsMapByType(EnumGoodsType.Talisman)
	if map then
		for talisman in map:iterator() do
			if talisman.template.kind == EnumTailsmanType.Exp then
				expTalismans[#expTalismans + 1] = talisman
			end
  		end
	end
	table.sort(expTalismans, function(t1, t2) return t1.template.quality > t2.template.quality end)
	return expTalismans
end

local useType = ExchangeEnumTable({EnumGoodsType.Prop})
local composeType = ExchangeEnumTable({EnumGoodsType.MaterialFrag, EnumGoodsType.RoleFrag, EnumGoodsType.PetFrag, 
     EnumGoodsType.PetSkillFrag, EnumGoodsType.EquipFrag,EnumGoodsType.FashionFrag, EnumGoodsType.PetEggFrag})

function BagManager:getIsUseType(goods)
	if not goods then return false end

	local template = goods.template
	if not template then return false end
	return useType[template.type] and template.usable and template.usable ~= 0
end

function BagManager:getIsComposeType(goods)
	if not goods then return false end

	local template = goods.template
	if not template then return false end
	return composeType[template.type] and template.usable and template.usable ~= 0
end

function BagManager:getItemUseTypeByTplId(tplId, level)
	local goods = self:getGoodsByTplId(tplId)
	return self:getItemUseType(goods, level)
end

function BagManager:getItemUseType(goods, level)
	if not goods then return EnumItemUseType.None end

	local template = goods.template
	local needLevel = template.level or 0
	if not template then return EnumItemUseType.None end
	if template.type == EnumGoodsType.EquipMaterial then return EnumItemUseType.None end
	if level < needLevel then return EnumItemUseType.None end
	if template.usable and template.usable == 0 then return EnumItemUseType.None end

	local itemUseType = EnumItemUseType.None
	if useType[template.type] then itemUseType = EnumItemUseType.Use end
	if composeType[template.type] then itemUseType = EnumItemUseType.Compose end

	if goods.type == EnumGoodsType.RoleFrag then
		if CardRoleManager:isHaveRole(template.id) then 
			itemUseType = EnumItemUseType.None
		elseif not CardRoleManager:canRecruit(template.role_id, goods.num) then
			itemUseType = EnumItemUseType.None
		end
	elseif goods.type == EnumGoodsType.MaterialFrag then
		local composeGoods = self:getGoodsTemplateByTplId(template.value)
		if composeGoods then
			local tbl = string.split(composeGoods.need_frags, '_')
			if not tbl or #tbl ~= 2 or goods.num < tonumber(tbl[2]) then
				itemUseType = EnumItemUseType.None
			end
		else
			itemUseType = EnumItemUseType.None
		end
	elseif goods.type == EnumGoodsType.EquipFrag then
		local equip = EquipData:objectByID(template.equip_id) 
		if equip == nil or equip.frag_num == nil or goods.num < equip.frag_num then
			itemUseType = EnumItemUseType.None
		end
	elseif goods.type == EnumGoodsType.PetEggFrag then
		local petEgg = GoodsItemData:objectByID(template.equip_id)
		if petEgg == nil or petEgg.frag_num == nil or goods.num < petEgg.frag_num then
			itemUseType = EnumItemUseType.None
		end
	end

	return itemUseType
end

function BagManager:getItemComposeNeedNum(goods)
	if not goods then return 0 end

	local template = goods.template
	if not template then return 0 end
	if goods.type == EnumGoodsType.RoleFrag then
		return CardRoleManager:getRecruitNum(template.role_id)
	elseif goods.type == EnumGoodsType.MaterialFrag then
		local composeGoods = self:getGoodsTemplateByTplId(template.value)
		if composeGoods then
			local tbl = string.split(composeGoods.need_frags, '_')
			if tbl and #tbl > 1 then
				return tonumber(tbl[2])
			end
		end
	elseif goods.type == EnumGoodsType.EquipFrag then
		local equip = EquipData:objectByID(template.equip_id) 
		if equip and equip.frag_num then
			return equip.frag_num
		end
	elseif goods.type == EnumGoodsType.FashionFrag then
		local fashion = FashionData:objectByID(template.fashion_id)
		if fashion and fashion.frag_num then
			return fashion.frag_num
		end
	elseif goods.type == EnumGoodsType.PetEggFrag then
		local petEgg = GoodsItemData:objectByID(template.equip_id)
		if petEgg and petEgg.frag_num then
			return petEgg.frag_num
		end
	end
	return 0
end

-- function BagManager:checkItemUse(goods, level)
-- 	local template = goods.template
-- 	local useType = self:getItemUseType(template)
-- 	if useType == EnumItemUseType.None or level < template.level then
-- 		return useType, EnumBtnType.Disable
-- 	end

-- 	local btnStatus = EnumBtnType.Normal
-- 	if goods.type == EnumGoodsType.RoleFrag then
-- 		if CardRoleManager:isHaveRole(template.id) then 
-- 			btnStatus = EnumBtnType.Disable 
-- 		elseif not CardRoleManager:canRecruit(template.role_id, goods.num) then
-- 			btnStatus = EnumBtnType.Disable
-- 		end
-- 	elseif goods.type == EnumGoodsType.MaterialFrag then
-- 		local composeGoods = self:getGoodsTemplateByTplId(template.value)
-- 		if composeGoods then
-- 			local tbl = string.split(composeGoods.need_frags, '_')
-- 			if not tbl or #tbl ~= 2 or goods.num < tonumber(tbl[2]) then
-- 				btnStatus = EnumBtnType.Disable
-- 			end
-- 		else
-- 			btnStatus = EnumBtnType.Disable
-- 		end
-- 	end
-- 	return useType, btnStatus
-- end

-- local
function BagManager:removeGoodsByIdAndType(id, type)
	local map = self.bagGoods:objectByID(type)
	if map then 
		map:removeById(id)
		if map:length() == 0 then
			self.bagGoods:removeById(type)
		end
	end
end

function BagManager:setGoods(goods)
	local map = self.bagGoods:objectByID(goods.type)
	if not map then 
		map = TFMapArray:new()
		self.bagGoods:pushbyid(goods.type, map)
	end

	local curGoods = map:objectByID(goods.id)
	if curGoods then
		goods.template = curGoods.template
		goods.uuid 	   = curGoods.uuid
		goods.cardEquip = curGoods.cardEquip
		if goods.cardEquip then
			goods.cardEquip:updateInfo(goods)
		end
		map:removeById(curGoods.id)
		map:push(goods)
		-- curGoods.num = goods.num
		-- if goods.level then curGoods.level = goods.level end
		-- if goods.exp then curGoods.exp = goods.exp end
		-- if goods.quality then curGoods.quality = goods.quality end
		-- if goods.star then curGoods.star = goods.star end
	else
		goods.template = self:getGoodsTemplate(goods.type, goods.tplId)
		goods.uuid = goods.id	--唯一id
		if goods.type == EnumGoodsType.Equipment then
			goods.cardEquip = CardEquipment:new(goods)
		end
		if goods.template~=nil then
			map:push(goods)
		end
		-- assert(goods.template~=nil, goods.type .. "->" .. goods.tplId)
		-- goods.uuid = goods.id	--唯一id
		-- map:push(goods)
	end
end

--背包物品排序
function BagManager:sortBagGoods(types)
	local function _sortProp(a1, a2)
		if a1.template.kind == a2.template.kind then
			local a1_usable = a1.template.usable
			local a2_usable = a2.template.usable
			if a1_usable == a2_usable then
				return a1.template.id > a2.template.id
			else
				return a1_usable > a2_usable
			end
		end
		return a1.template.kind > a2.template.kind
	end
	local function _sortEquipFrag(a1, a2)
		local a1_can = a1.num >= a1.template:getFragNum() and 1 or 0
		local a2_can = a2.num >= a2.template:getFragNum() and 1 or 0
		if a1_can == a2_can then
			return a1.template.id < a2.template.id
		else
			return a1_can > a2_can
		end
	end
	local function _sortMaterial(a1, a2)
		return a1.template.id > a2.template.id
	end
	local function _sortMaterialFrag(a1, a2)
		local a1_can = a1.num >= a1.template:getFragNum() and 1 or 0
		local a2_can = a2.num >= a2.template:getFragNum() and 1 or 0
		if a1_can and a2_can then
			return a1.template.id > a2.template.id
		else
			return a1_can > a2_can
		end
	end
	local function _sortGem(a1, a2)
		if a1.template.level == a2.template.level then
			return a1.template.id < a2.template.id
		end
		return a1.template.level > a2.template.level
	end

	local sortFunction = {
		[1] = _sortMaterial,
		[2] = _sortMaterialFrag,
		[3] = _sortProp,
		[6] = _sortEquipFrag,
		[7] = _sortGem
	}

	for type,_ in pairs(types) do
		local map = self.bagGoods:objectByID(type)
		local cmp = sortFunction[type]
		if map and cmp then
			map:sort(cmp)
		end
	end
end

--===============================  红点 ============================

function BagManager:isHaveBagRed()
	if self:isHaveEquipFrag() then
		return true
	end

	if self:isHavePropRed() then
		return true
	end

	return false
end

function BagManager:isHaveEquipFrag()
	local map = self:getGoodsMapByType(EnumGoodsType.EquipFrag)
	if map then
		local equip = nil
		for item in map:iterator() do
			equip = EquipData:objectByID(item.template.equip_id)
			if equip and equip.frag_num and item.num >= equip.frag_num then
				return true
			end
  		end
	end
	return false
end


function BagManager:isHavePropRed()
	local props = self:getGoodsMapByType(EnumGoodsType.Prop)
	if props then
		local showKinds = { 51,52,53,54,55,99 }
		local showKindMap = {}
		local leven = MainPlayer:getLevel()
		for i,v in ipairs(showKinds) do
			showKindMap[v] = true
		end

		local equip = nil
		for item in props:iterator() do
			if showKindMap[item.template.kind] and leven >= item.template.level then
				return true
			end
  		end
	end
	if self:isHaveRedPetEggFrag() then return true end
	return false
end

function BagManager:isHaveRedPetEggFrag()
	local props = self:getGoodsMapByType(EnumGoodsType.PetEggFrag)
	if props then
		for item in props:iterator() do
			local petEgg = GoodsItemData:objectByID(item.template.equip_id)
			if petEgg and petEgg.frag_num and item.num >= petEgg.frag_num then
				return true
			end
  		end
	end
end

--===============================转盘物品使用===================================
function BagManager:openUseTurntableItemLayer(itemInfo)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bag.UseTurntableItemLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(itemInfo)
	AlertManager:show()
end

return BagManager:new()