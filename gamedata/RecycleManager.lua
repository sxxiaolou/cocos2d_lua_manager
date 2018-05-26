-- 回收管理类
-- Author: Jing
-- Date: 2016-10-06
--

local BaseManager = require('lua.gamedata.BaseManager')
local RecycleManager = class("RecycleManager", BaseManager)

RecycleManager.Refresh = "RecycleManager.Refresh"
RecycleManager.Composit = "RecycleManager.Composit"

RecycleManager.AddDisacrdEffect = "RecycleManager.AddDisacrdEffect"
RecycleManager.AddRebirthEffect = "RecycleManager.AddRebirthEffect"
RecycleManager.UPDATE_PET_REBIRTH = "RecycleManager.UPDATE_PET_REBIRTH"


function RecycleManager:ctor()
	self.super.ctor(self)
end
 
function RecycleManager:init()
	self.super.init(self)

	self:registerEvents()

	self.compositEquipList = TFArray:new()
end

function RecycleManager:registerEvents()
	TFDirector:addProto(s2c.ROLE_REBIRTH_RESULT, self, self.onRoleRebirthResult)
	-- TFDirector:addProto(s2c.GEM_REBIRTH_RESULT, self, self.onGemRebirthResult)
	TFDirector:addProto(s2c.SELL_ITEM_RESULT, self, self.onSellItemResult)	
	TFDirector:addProto(s2c.ONEKEY_SELL_ITEM_RESULT, self, self.onOnekeySellItemResult)
	TFDirector:addProto(s2c.EQUIP_REBIRTH_RESULT, self, self.onEquipRebirthResult)
	TFDirector:addProto(s2c.EQUIP_FIVE_COMPOSE_RESULT, self, self.onEquipCompositResult)
	TFDirector:addProto(s2c.PET_REBIRTH_RESULT, self, self.onPetRebirthResult)

	TFDirector:addProto(s2c.ARTIFACT_REBIRTH_RESULT, self, self.onArtifactRebirthResult)
	TFDirector:addProto(s2c.ARTIFACT_PREVIEW_INFO, self, self.onArtifactPreviewInfo)
	--卡牌重生预览
	TFDirector:addProto(s2c.PREVIEW_INFO, self, self.onPreviewInfo)
end

function RecycleManager:restart()

	self:restartEquipList()

	self.compositEquipList:clear()
end

--protocol
function RecycleManager:sendRoleRebirth(cardId)
	self:sendWithLoading(c2s.ROLE_REBIRTH, cardId)
end

function RecycleManager:sendEquipEquip( equipId )
	self:sendWithLoading(c2s.EQUIP_REBIRTH, equipId)
end

function RecycleManager:sendGemRebirth(gemId)
	self:sendWithLoading(c2s.GEM_REBIRTH, gemId)
end

function RecycleManager:sendSellItem(items)
	self:sendWithLoading(c2s.SELL_ITEM, items)
end

function RecycleManager:sendOnekeySellItem(levels, resType)
	self:sendWithLoading(c2s.ONEKEY_SELL_ITEM, levels, resType)
end

function RecycleManager:sendEquipComposit(equipIds)
	self:sendWithLoading(c2s.EQUIP_FIVE_COMPOSE, equipIds, true)
end

--宠物重生
function RecycleManager:sendPetRebirth(petId)
	self:send(c2s.PET_REBIRTH, petId)
end

--卡牌重生预览
function RecycleManager:sendPreviewReq(cardId, type)
	self:send(c2s.PREVIEW_REQ, cardId, type)
end

--法宝重生预览
function RecycleManager:sendArtifactPreviewReq(artifactId, type)
	self:send(c2s.ARTIFACT_PREVIEW_REQ, artifactId.."", type)
end

--法宝重生
function RecycleManager:sendArtifactRebirthReq(artifactId)
	self:send(c2s.ARTIFACT_REBIRTH, artifactId.."")
end

--法宝重生预览响应
function RecycleManager:onArtifactPreviewInfo( event )
	-- body
	hideLoading()

	local data = event.data

	print("=======onPreviewInfo========", data)

	local rewards = data.items or {}
	RecycleManager:openRecycleDiscardGetLayer(rewards, EnumRecycleType.ArtifactRebirth)
end

--法宝重生响应
function RecycleManager:onArtifactRebirthResult( event )
	-- body
end

--receive
function RecycleManager:onRoleRebirthResult(event)
	hideLoading()
	-- local data = event.data
	--清掉玩家的炼体等级
	RoleRefineManager:ClearRefineLevel(event.data.cardId)
	TFDirector:dispatchGlobalEventWith(RecycleManager.Refresh, nil)
end

-- function RecycleManager:onGemRebirthResult(event)
-- 	hideLoading()
-- 	-- local data = event.data

-- 	TFDirector:dispatchGlobalEventWith(RecycleManager.Refresh, nil)
-- end

function RecycleManager:onSellItemResult(event)
	hideLoading()
	-- local data = event.data

	if not CardRoleManager:getRoleById(MainPlayer:getHeadId()) then
		MainPlayer:sendChangeHead(MainPlayer:getMainRole().pic_id)
	end
	
	TFDirector:dispatchGlobalEventWith(RecycleManager.Refresh, nil)
end

function RecycleManager:onOnekeySellItemResult(event)
	hideLoading()
	-- local data = event.data

	TFDirector:dispatchGlobalEventWith(RecycleManager.Refresh, nil)
end

function RecycleManager:onEquipRebirthResult( event )
	hideLoading()
	-- local data = event.data

	TFDirector:dispatchGlobalEventWith(RecycleManager.Refresh, nil)
end

function RecycleManager:onEquipCompositResult( event )
	hideLoading()
	local data = event.data
	self:restartEquipList()
	TFDirector:dispatchGlobalEventWith(RecycleManager.Composit, data.equips[1])
end

function RecycleManager:onPetRebirthResult( event )
	hideLoading()

	TFDirector:dispatchGlobalEventWith(RecycleManager.UPDATE_PET_REBIRTH, nil)
end

function RecycleManager:onPreviewInfo( event )
	hideLoading()

	local data = event.data

	print("=======onPreviewInfo========", data)

	local rewards = data.items or {}
	RecycleManager:openRecycleDiscardGetLayer(rewards, EnumRecycleType.RoleRebirth)
end


function RecycleManager:openRecycleLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.recycle.RecycleLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function RecycleManager:openRecycleDiscardGetLayer(rewards, type, callback)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ConfirmItemsLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    layer:show(rewards, type, callback)
    AlertManager:show()
end

--api
function RecycleManager:getRebirthRoleList()
	local roleList = CardRoleManager:getRoleListToRebirth()
    local function sortFun(role1, role2)

    	if role1:isAllFormation() and not role2:isAllFormation() then
    		return false
    	elseif not role1:isAllFormation() and role2:isAllFormation() then
    		return true
    	elseif role1:isAllFormation() and role2:isAllFormation() then
    		local type1 = FormationManager:getInAnyFormationType(role1.uuid)
    		local type2 = FormationManager:getInAnyFormationType(role2.uuid)

    		if type1 ~= type2 then
    			return type1 < type2
    		else
    			return role1.quality > role2.quality
    		end
    	elseif not role1:isAllFormation() and not role2:isAllFormation() then
    		if role1.quality ~= role2.quality then
	            return role1.quality > role2.quality
	        elseif role1.quality == role2.quality then
	        	return role1.power > role2.power
	        end
    	end     
        return true
    end
   	roleList:sort(sortFun)
   	return roleList
end

function RecycleManager:getRebirthArtifactList()
	local list = ArtifactManager:getArtifactListToRebirth()
	local isCanRebirth = function (item)
		return item.curExp == 0 and item.level == 0 and item.skillLevel == 1
	end

	list:sort(function (t1, t2)
		if isCanRebirth(t1) and not isCanRebirth(t2) then
			return false
		elseif not isCanRebirth(t1) and isCanRebirth(t2) then
			return true
		end

		if t1.roleId == "0" and t2.roleId ~= "0" then
			return true
		elseif t1.roleId ~= "0" and t2.roleId == "0" then
			return false
		end

		if t1.template.quality ~= t2.template.quality then
			return t1.template.quality > t2.template.quality
		end

		return t1.tplId < t2.tplId
	end)
	return list --ArtifactManager:getArtifactListToRebirth()
end

function RecycleManager:getRebirthEquipList()

	local equipList = EquipmentManager:getEquipListToRebirth()
    local function sortFun(equip1, equip2)
         if equip1.cardEquip.quality > equip2.cardEquip.quality then
            return true
        elseif equip1.cardEquip.quality < equip2.cardEquip.quality then
        	return false
        elseif equip1.cardEquip.quality == equip2.cardEquip.quality then
        	return equip1.cardEquip.power > equip2.cardEquip.power
        end
        return true
    end
   equipList:sort(sortFun)
   return equipList
end

function RecycleManager:getRebirthPetList()
	
	local petList = TFArray:new()
	local itemList = PetRoleManager:getPetListToRebirth()
	for item in itemList:iterator() do
		if not item.lock then
			petList:push(item)
		end	
	end

	local function sortFun(t1, t2)
		return t1.quality > t2.quality
	end
	petList:sort(sortFun)

	return petList
end

function RecycleManager:getRebirthGemList()
	local bagGoods = BagManager:getGoodsMapByType(EnumResourceType.Talisman)
	local talismanList = TFArray:new()
	if bagGoods ~= nil then
		for good in bagGoods:iterator() do
			if TalismanManager:slotWear(good.id) == 0 and TalismanManager:hasTrain(good) then
				talismanList:push(good)
			end
		end
	end
    local function sortFun(talisman1, talisman2)
        if talisman1.template.quality < talisman2.template.quality then
            return false
        end
        if talisman1.level < talisman2.level then
        	return false
        end
        if talisman1.template.id < talisman2.template.id then
        	return true
        end
        return false
    end
   talismanList:sort(sortFun)
   return talismanList
end

function RecycleManager:getDiscardRoleList()
	local roleList = CardRoleManager:getRoleListToDiscard()
    local function sortFun(role1, role2)

    	-- --天书排在最后（不是阵容惹得）
    	-- local is_book1 = BookWorldManager:inBookWorldIsUseById(role1.gmId)
    	-- local is_book2 = BookWorldManager:inBookWorldIsUseById(role2.gmId)

    	-- if not is_book1 and is_book2 then
    	-- 	return true
    	-- elseif is_book1 and not is_book2 then
    	-- 	return false
    	-- end

    	if role1:isAllFormation() and not role2:isAllFormation() then
    		return false
    	elseif not role1:isAllFormation() and role2:isAllFormation() then
    		return true
    	elseif role1:isAllFormation() and role2:isAllFormation() then
    		local type1 = FormationManager:getInAnyFormationType(role1.uuid)
    		local type2 = FormationManager:getInAnyFormationType(role2.uuid)

    		if type1 ~= type2 then
    			return type1 < type2
    		else
    			return role1.quality < role2.quality
    		end
    	elseif not role1:isAllFormation() and not role2:isAllFormation() then
    		local isF1 = role1:hasTrain()
	        local isF2 = role2:hasTrain()
	        if isF1 and not isF2 then
	            -- return true
	            return false
	        end
	        if not isF1 and isF2 then
	            -- return false
	            return true
	        end
	        if role1:getQuality() < role2:getQuality() then
	            return true
	        end
	        if role1:getLevel() < role2:getLevel() then
	            return true
	        end
	        if role1:getPower() < role2:getPower() then
	            return true
	        end
    	end 

        return false
    end
   roleList:sort(sortFun)
   return roleList
end

function RecycleManager:getDiscardRoleFragList()
	local bagGoods = BagManager:getGoodsMapByType(EnumResourceType.RoleFrag)
	local roleFragList = TFArray:new()
	if bagGoods ~= nil then
		for good in bagGoods:iterator() do
			if good.template.role_id ~= 0 then
				roleFragList:push(good)
			end	
		end
	end
    local function sortFun(roleFrag1, roleFrag2)
        if roleFrag1.template.quality < roleFrag2.template.quality then
            return true
        end
        return false
    end
   roleFragList:sort(sortFun)
   return roleFragList
end

function RecycleManager:getDiscardMaterialList()
	--装备碎片
	local bagGoods = BagManager:getGoodsMapByType(EnumResourceType.EquipFrag)
	local equipMaterials = TFArray:new()
	if bagGoods ~= nil then
		for good in bagGoods:iterator() do
			equipMaterials:push(good)
		end
	end
    local function sortFun(equipMaterial1, equipMaterial2)
        if equipMaterial1.template.quality < equipMaterial2.template.quality then
            return true
        end
        if equipMaterial1.template.id < equipMaterial2.template.id then
        	return true
        end
        return false
    end
   equipMaterials:sort(sortFun)
   return equipMaterials
end

function RecycleManager:getDiscardPetList()
	local pets = PetRoleManager:getIdleList()
	local petList = TFArray:new()
	for k,v in pairs(pets) do
		petList:push(v)
	end
 	local function sortFun(pet1, pet2)
        if pet1.template.quality > pet2.template.quality then
            return false
        end
        if pet1.level > pet2.level then
            return false
        end
        if pet1.id > pet2.id then
            return false
        end
        return true
    end
   petList:sort(sortFun)
   return petList
end

function RecycleManager:getDiscardPetFragList()
	--宠物碎片
	local bagGoods = BagManager:getGoodsMapByType(EnumResourceType.PetFrag)
	local petFrags = TFArray:new()
	if bagGoods ~= nil then
		for good in bagGoods:iterator() do
			petFrags:push(good)
		end
	end
    local function sortFun(petFrag1, petFrag2)
        if petFrag1.template.quality < petFrag2.template.quality then
            return true
        end
        if petFrag1.template.id < petFrag2.template.id then
        	return true
        end
        return false
    end
   petFrags:sort(sortFun)
   return petFrags
end


--calculate
--goods = {type=1, id=2, tplId=3, num=4, level=5, exp=6, quality=7, star=8}, num为当前数量
function RecycleManager:calculateRoleReward(role)
	local rewards = {}
	--神魂
	local cons = ConstantData:getValue("Rebirth.Ratio") / 10000
	--经验丹返还
	local cardExp = self:getExp(role)
	print("cardExp ", cardExp)
	self:getExpDan(cardExp, rewards, cons)
	print("====current count ==== + expdan ", #rewards)

	--星级返还
	self:starRecycle(role, rewards, cons)
	print("====current count ==== + roleflag ", #rewards)

	--进阶返还
	self:promoteRecycle(role, rewards, cons)
	print("====current count ==== + promoteBook ", #rewards)

	--技能返还
	-- self:spellRecycle(role, rewards)
	-- print("====current count ==== + coins ", #rewards)

	--本体
	self:roleTplRecycle(role, rewards)
	print("====current count ==== + roles ", #rewards)


	return rewards
end

function RecycleManager:getExp(role)
	local exp = role.curExp
	local level = role.level
	for i=1,level do
		exp = exp + CardLevelData:objectByID(i).role_exp
	end
	return exp
end

--添加到常量表里面去
--30001 30002 30003 30004
function RecycleManager:getExpDan(exp, dans, cons)
	exp = exp * cons
	local expProps = {}
	expProps[#expProps + 1] = GoodsItemData:objectByID(30004)
	expProps[#expProps + 1] = GoodsItemData:objectByID(30003)
	expProps[#expProps + 1] = GoodsItemData:objectByID(30002)
	expProps[#expProps + 1] = GoodsItemData:objectByID(30001)
	local num = 0
	for k,expProp in pairs(expProps) do
		if exp > expProp.value then
			num = math.floor(exp/expProp.value)
			exp = exp % expProp.value
			dans[#dans + 1] = {type = expProp.type, id=0, tplId = expProp.id, num = num}
			num = 0
		end
	end
end

--碎片
function RecycleManager:starRecycle(role, roleFrags, cons)
	-- body
	local num = 0
	local propNum = 0
	for i=1,role.starLv do
		local starUp = CardStarUpData:objectByRoleIdAndStar(role.id, i)
		num = num + starUp.role_frag_num
		local items = stringToNumberTable(starUp.items_num,'_')
		propNum = propNum + items[3]
	end
	-- if role.starStep > 0 then
	-- 	local starUp = CardStarUpData:objectByRoleIdAndStar(role.id, role.starLv)
	-- 	local starStep = starUp:getStepTable()
	-- 	for i=1,role.starStep do
	-- 		num = num + starStep[i]
	-- 	end
	-- end
	num = math.floor(num * cons)
	if num > 0 then
		local roleFrag = CardSoulData:objectByID(role.template.card_id)
		roleFrags[#roleFrags + 1] = {type = roleFrag.type, id=0, tplId = roleFrag.id, num = num}
	end
	if propNum > 0 then
		local starUp = CardStarUpData:objectByRoleIdAndStar(role.id, 1)
		local items = stringToNumberTable(starUp.items_num,'_')
		roleFrags[#roleFrags + 1] = {type= EnumGoodsType.Prop, id=0, tplId = items[2], num = propNum}
	end
end

--升阶
function RecycleManager:promoteRecycle(role, promoteBooks, cons)
	-- body
	local books = MEMapArray:new()
	local function addBook(martial)
		local tryBook = books:objectByID(martial.id)
		if tryBook then
			tryBook.num = tryBook.num + 1
		else
			books:pushbyid(martial.id, {type = martial.type, id=0, tplId = martial.id, num = 1})
		end
	end

	if role.promoteLv > 0 then
		for i=1,role.promoteLv do
			local advanceData  = CardAdvanceData:getObjectByTypeAndLevel(role.template.promote_type, i)
			assert(advanceData~=nil)
			local martials = advanceData:getMartialTable()
			for k,martialId in pairs(martials) do
				local martial = GoodsMaterialData:objectByID(martialId)
				assert(martial~=nil)
				addBook(martial)
			end
		end
	end

	local advanceDataCur  = CardAdvanceData:getObjectByTypeAndLevel(role.template.promote_type, role.promoteLv + 1)
	assert(advanceDataCur~=nil)
	local martials = advanceDataCur:getMartialTable()
	for i=1,#martials do
		if role.promoteBook[i] ~= nil then
			local martial = GoodsMaterialData:objectByID(martials[i])
			assert(martial~=nil)
			addBook(martial)
		end
	end

	for book in books:iterator() do
		book.num = math.floor(book.num * cons)
		promoteBooks[#promoteBooks + 1] = book
		-- print("book =====> ", book)
	end
end

--技能
-- function RecycleManager:spellRecycle(role, coins)
-- 	local num = 0
-- 	for k,skills in pairs(role.skills) do
-- 		for index, skill in pairs(skills) do
-- 			if skill then
-- 				for i=2,skill.level do
-- 					local skillLvData = SkillLevelData:objectByID(i)
-- 					num = num + skillLvData.comsume
-- 				end
-- 			end
-- 		end
-- 	end
-- 	if num == 0 then return end
-- 	coins[#coins + 1] = {type = EnumResourceType.Coin, id=0, tplId = 0, num = num}
-- 	print("coins =====> ", num)
-- end

------------------------------------分解道具获得---------------------------------------
function RecycleManager:getRoleRecycleReturn(role, type)
	local rewards = {}
	rewards[1] = {type = EnumResourceType.Errantry, id=0, tplId = EnumResourceType.Errantry, num = 0}
	if type == EnumResourceType.RoleCard then
		for k,v in pairs(role) do
			local role = CardRoleManager:getRoleByGmId(v[1])
			if role then
				rewards[1].num = rewards[1].num + role.template.recycle * v[2]
			end	
		end
	elseif type == EnumResourceType.RoleFrag then
		for k,v in pairs(role) do
			local farg = BagManager:getGoodsByTypeAndId(type, v[1])
			if farg then
				rewards[1].num = rewards[1].num + farg.template.recycle * v[2]
			end
		end
	end
	
	return rewards
end


--角色本体
function RecycleManager:roleTplRecycle(role, roles)
	roles[#roles + 1] = {type = EnumResourceType.RoleCard, id=0, tplId = role.template.id, num = 1}
end


function RecycleManager:equipTplRecycle(equip)
	local rewards = {}
	local cons = ConstantData:getValue("Rebirth.Ratio") / 10000
	--强化返还
	local expCoins = self:getEquipCoinReturn(equip) * cons
	
	--精炼返还
	self:getEquipRefineReturn(equip,rewards, cons)

	--升星返还
	local coin = self:getEquipStarReturn(equip, rewards, cons)

	--宝石返还
	self:getEquipGemReturn(equip, rewards)

	self:coinsNumToItem(math.floor(expCoins + coin), rewards)

	return rewards
end

function RecycleManager:getEquipCoinReturn(equip)
	local coins = 0 
	for i=1,equip.level do
		coins = coins + EquipIntensifyData:getValue(i)
	end
	return coins
end

function RecycleManager:getEquipRefineReturn(equip,rewards, cons)
	if equip.cardEquip.refineItemNum > 0 then
		rewards[#rewards + 1] = {type= EnumResourceType.Prop, id=0, tplId = 30701, num = math.floor(equip.cardEquip.refineItemNum * cons)}
	end
end

function RecycleManager:getEquipStarReturn( equip, rewards, cons )
	local coinNumber = 0
	if equip.star < 1 then return coinNumber end
	for i=1,equip.star do
		local starData = EquipStarData:getDataByIdAndStar(equip.tplId, i)
		local materialTable, indexTable = starData:getMaterialTable()

		for k,v in pairs(indexTable) do
			local number = materialTable[v]
			local is_bool = false

			for value,item in pairs(rewards) do
				if item.tplId == v then
					if math.floor(v / 10000) ~= EnumGoodsType.Equipment then
						number = math.floor(number * cons)
					end
					item.num = item.num + number
					is_bool = true
				end	
			end

			if not is_bool then
				if math.floor(v / 10000) ~= EnumGoodsType.Equipment then
					number = math.floor(number * cons)
				end
				rewards[#rewards + 1] = {type= math.floor(v / 10000), id=0, tplId = v, num = number}
			end	
		end
		local equipStar = EquipStarData:getDataByIdAndStar(equip.tplId, i)
		coinNumber = coinNumber + equipStar.coin
	end
	return coinNumber * cons
end

function RecycleManager:getEquipGemReturn(equip,rewards)
	local gemPos = equip.gem
	if not gemPos then return end
	for k,v in pairs(gemPos) do
		if v.id > 0 then
			rewards[#rewards + 1] = {type = EnumResourceType.EquipGem, id=0, tplId = v.id, num = 1}
		end	
	end
	
end

function RecycleManager:petTplRecycle(pet)
	local rewards = {}
	-- local cons = ConstantData:getValue("Rebirth.Ratio") / 10000
	-- --强化返还
	-- local expCoins = self:getEquipCoinReturn(equip) * cons
	
	-- --精炼返还
	-- self:getEquipRefineReturn(equip,rewards, cons)

	-- --升星返还
	-- local coin = self:getEquipStarReturn(equip, rewards) * cons

	-- --宝石返还
	-- self:getEquipGemReturn(equip, rewards)

	-- self:coinsNumToItem(math.floor(expCoins + coin), rewards)

	return rewards
end

function RecycleManager:restartEquipList()
	if self.compositEquipList then
		self.compositEquipList:clear()
	end
end

function RecycleManager:addCompositEquipList( equip )
	if self.compositEquipList:length() < 5 then
		local item =self.compositEquipList:getObjectAt(1)
		if item then
			if item.template.quality == equip.template.quality then
				self.compositEquipList:push(equip)
			else
				toastMessage(localizable.RecycleManager_Equip_Hecheng)
			end
		else
			self.compositEquipList:push(equip)
		end
	end	
end

function RecycleManager:getNewCompositEquipIdx()
	if self.compositEquipList:length() == 0 then return 1 end

	local itemIdx = {}
	for item in self.compositEquipList:iterator() do
		if item.equipIndex then
			itemIdx[item.equipIndex] = true
		end
	end

	for i=1,5 do
		if not itemIdx[i] then return i end
	end
	return 1
end

function RecycleManager:removeCompositEquipList(equip)
	for item in self.compositEquipList:iterator() do
		if equip.id == item.id then
			self.compositEquipList:removeObject(item)
		end
	end
end

function RecycleManager:getCompositEquipList()
	return self.compositEquipList
end

function RecycleManager:calculateTalismanReward(talisman)
	local rewards = {}

	--exp返还
	local exps, expCoins = self:getTalismanExp(talisman)
	print("exps ", exps)
	print("expCoins ", expCoins)
	self:talismanExpDans(exps, rewards)
	print("====current count ==== + expdan ", #rewards)

	--升星返还
	local starCoins = self:talismanStarRecycle(talisman, rewards)
	print("====current count ==== + items ", #rewards)

	--coins
	self:coinsNumToItem(expCoins + starCoins, rewards)
	print("====current count ==== + coins ", #rewards)

	--本体
	self:talismanTplRecycle(talisman, rewards)
	print("====current count ==== + talismans ", #rewards)

	return rewards
end

function RecycleManager:getTalismanExp(talisman)
	local exps, coins = 0,0
	for i=1,talisman.level do
		local talismanLevelData = TalismanLevelData:objectByID(i)
		exps = exps + talismanLevelData.exp
		coins = coins + talismanLevelData.coin
	end
	exps = exps + talisman.exp
	return exps, coins
end

--exp返还
--添加到常量表里面去
--80017 80018 80019 80020 80021 80022
function RecycleManager:talismanExpDans(exp, dans)
	local expTalismans = {}
	expTalismans[#expTalismans + 1] = GoodsTalismanData:objectByID(80022)
	expTalismans[#expTalismans + 1] = GoodsTalismanData:objectByID(80021)
	expTalismans[#expTalismans + 1] = GoodsTalismanData:objectByID(80020)
	expTalismans[#expTalismans + 1] = GoodsTalismanData:objectByID(80019)
	expTalismans[#expTalismans + 1] = GoodsTalismanData:objectByID(80018)
	expTalismans[#expTalismans + 1] = GoodsTalismanData:objectByID(80017)
	local num = 0
	for k,expTalisman in pairs(expTalismans) do
		if exp > expTalisman.exp then
			num = math.floor(exp/expTalisman.exp)
			exp = exp % expTalisman.exp
			dans[#dans + 1] = {type = expTalisman.type, id=0, tplId = expTalisman.id, num = num}
			num = 0
		end
	end
end

--coins
function RecycleManager:coinsNumToItem(num, coins)
	if num < 1 then return end
	coins[#coins + 1] = {type = EnumResourceType.Coin, id=0, tplId = 0, num = num}
	print("coins =====> ", num)
end

--consumes
function RecycleManager:talismanStarRecycle(talisman, rewards)
	local coins = 0
	if talisman.star < 1 then return coins end

	print("talisman.star ", talisman.star)

	local talismans = {}
	local items = {}

	local function addTalismans(id, cnt)
		if talismans[id] ~= nil then 
			talismans[id] = talismans[id] + cnt
		else
			talismans[id] = cnt
		end
	end
	local function addItems(id, cnt)
		if items[id] ~= nil then 
			items[id] = items[id] + cnt 
		else
			items[id] = cnt 
		end
	end

	for i=1,talisman.star do
		local talismanStarData = TalismanStarData:getTalismanStarData(talisman.tplId, i)
		coins = coins + talismanStarData.coin
		local consumes = GetAttrByString(talismanStarData.consumes)
		for id,cnt in pairs(consumes) do
			--temp
			if id > 80000 then
				addTalismans(id, cnt)
			else
				addItems(id, cnt)
			end
		end
	end

	for k,v in pairs(talismans) do
		rewards[#rewards + 1] = {type = EnumResourceType.Talisman, id=0, tplId = k, num = v}
	end
	for k,v in pairs(items) do
		rewards[#rewards + 1] = {type = EnumResourceType.Prop, id=0, tplId = k, num = v}
	end

	return coins
end

--法宝本地
function RecycleManager:talismanTplRecycle(talisman, talismans)
	talismans[#talismans + 1] = {type = EnumResourceType.Talisman, id=0, tplId = talisman.tplId, num = 1}
end

--回收系统按钮类型
function RecycleManager:setRecycleBtnType(type)
	self.recycleBtnType = type
end

function RecycleManager:getRecycleBtnType()
	return self.recycleBtnType
end

return RecycleManager:new()
