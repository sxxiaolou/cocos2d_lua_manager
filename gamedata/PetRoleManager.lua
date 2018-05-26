-- 宠物管理类
-- Author: sunyunpeng
-- Date: 2017-09-12
--

local BaseManager = require('lua.gamedata.BaseManager')
local PetRoleManager = class("PetRoleManager", BaseManager)
local PetRole = require('lua.gamedata.base.PetRole')

PetRoleManager.PET_UPDATE			= "PetRoleManager.PET_UPDATE"
PetRoleManager.PET_UP_LEVEL 		= "PetRoleManager.PET_UP_LEVEL"
PetRoleManager.PET_REMOVE 			= "PetRoleManager.PET_REMOVE"
PetRoleManager.PET_BATTLE 			= "PetRoleManager.PET_BATTLE"
PetRoleManager.PET_LOCK 			= "PetRoleManager.PET_LOCK"
PetRoleManager.PET_LEVEL_BEGIN		= "PetRoleManager.PET_LEVEL_BEGIN"
PetRoleManager.PET_MERGE			= "PetRoleManager.PET_MERGE"

PetRoleManager.CHAPTER_PET_UPDATE	= "PetRoleManager.CHAPTER_PET_UPDATE"
PetRoleManager.CHAPTER_PLAYER_NUM	= "PetRoleManager.CHAPTER_PLAYER_NUM"


PetRoleManager.PET_SKILL_UN_LOCK	= "PetRoleManager.PET_SKILL_UN_LOCK"	--宠物技能栏解锁
PetRoleManager.PET_SKILL_LEARN		= "PetRoleManager.PET_SKILL_LEARN"		--宠物技能学习
PetRoleManager.PET_SKILL_UP_LEVEL	= "PetRoleManager.PET_SKILL_UP_LEVEL"	--宠物技能升级
PetRoleManager.PET_SKILL_PROMOTE	= "PetRoleManager.PET_SKILL_PROMOTE"	--宠物技能进阶
PetRoleManager.PET_CHANGE_NAME		= "PetRoleManager.PET_CHANGE_NAME"		--宠物改名	
PetRoleManager.PET_PROMOTE			= "PetRoleManager.PET_PROMOTE"			--宠物进阶

-- //章节宠物信息      
-- message ChapterPetInfo{
-- 	required string id = 1;						//宠物实例id
-- 	required int32 chapterId=2;					//章节id
-- 	required int32 posId=3;						//位置id
-- 	required int32 tplId=4;						//宠物模版id
-- 	required int32 quality=5;					//品质
-- 	required int32 prefix=6;					//资质    PetPrefixType 默认0 待定
-- }

function PetRoleManager:ctor()
	self.super.ctor(self)
end

function PetRoleManager:init()
	self.super.init(self)
	self.is_petbag = false
	self.petRoleList = TFArray:new()
   
	self.chapterPetList = {} 			--已完成章节宠物列表  
	self.chapterPlayerOnlineList = {}
	self:registerEvents()
end

function PetRoleManager:registerEvents()
	TFDirector:addProto(s2c.PET_BAG, self, self.onReceivePetList)
	TFDirector:addProto(s2c.UPDATE_PET_CARD, self, self.onReceiveUpdatePet)
	TFDirector:addProto(s2c.PET_LEVEL_INFO, self, self.onReceivePetLevelUp)	
	TFDirector:addProto(s2c.REMOVE_PET, self, self.onReceiveRemovePet)
	TFDirector:addProto(s2c.PET_IN_BATTLE, self, self.onReceiveBattlePet)
	TFDirector:addProto(s2c.PET_LOCK, self, self.onReceiveLockPet)

	--捉宠物    
	TFDirector:addProto(s2c.CHAPTER_PET_INFO, self, self.onChapterPetInfo)
	TFDirector:addProto(s2c.CHAPTER_PET_LIST, self, self.onChapterPetList)
	TFDirector:addProto(s2c.CHAPTER_PLAYER_ONLINE_LIST, self, self.onChapterPlayerOnlineList)

	--宠物融合
	TFDirector:addProto(s2c.PET_MERGE_INFO, self, self.onPetMergeInfo)
	--宠物技能栏解锁
	TFDirector:addProto(s2c.PET_SKILL_UN_LOCK, self, self.onPetSkillUnLock)
	--宠物技能学习
	TFDirector:addProto(s2c.PET_SKILL_LEARN, self, self.onPetSkillLearn)
	--宠物技能升级
	TFDirector:addProto(s2c.PET_SKILL_UP_LEVEL, self, self.onPetSkillUpLevel)
	--宠物技能进阶
	TFDirector:addProto(s2c.PET_SKILL_PROMOTE, self, self.onPetSkillPromote)
	--宠物改名
	TFDirector:addProto(s2c.PET_CHANGE_NAME, self, self.onPetChangeName)
	--宠物进阶
	TFDirector:addProto(s2c.PET_PROMOTE, self, self.onPetPromote)	
end

function PetRoleManager:restart()
	self.is_petbag = false
	self.petRoleList:clear()

	if self.chapterPetList then
		for k,_ in pairs(self.chapterPetList) do
			self.chapterPetList[k] = nil
		end
		self.chapterPetList = {}
	end
	self.chapterPlayerOnlineList = {}
  end

--宠物升级
function PetRoleManager:sendPetLevelUp(goodsItem, id)
	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_LEVEL_BEGIN, nil)
	self:sendWithLoading(c2s.PET_LEVEL_UP, goodsItem, id)
end

--宠物上阵
function PetRoleManager:sendPetUpBattle(petId, is_bool, roleId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, nil)
	self:sendWithLoading(c2s.PET_IN_BATTLE_REQ, petId, is_bool, roleId)
end

--宠物上锁
function PetRoleManager:sendPetOnLock(petId)
	self:sendWithLoading(c2s.PET_LOCK_REQ, petId)
end

--宠物技能栏解锁
function PetRoleManager:sendPetSkillUnLock(petId)
	self:sendWithLoading(c2s.PET_SKILL_UN_LOCK, petId)
end

--宠物技能学习
function PetRoleManager:sendPetSkillLearn(petId, tplId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, nil)
	self:sendWithLoading(c2s.PET_SKILL_LEARN, petId, tplId)
end

--宠物技能升级
function PetRoleManager:sendPetSkillUpLevel(petId, tplId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, nil)
	self:sendWithLoading(c2s.PET_SKILL_UP_LEVEL, petId, tplId)
end

--宠物技能进阶
function PetRoleManager:sendPetSkillPromote(petId, tplId, pos)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, nil)
	self:sendWithLoading(c2s.PET_SKILL_PROMOTE, petId, tplId, pos)
end

--宠物改名
function PetRoleManager:sendPetChangeName(petId, name)
	self:sendWithLoading(c2s.PET_CHANGE_NAME, petId, name)
end

--宠物进阶
function PetRoleManager:sendPetPromote(petId)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_BEGIN, nil)
	self:sendWithLoading(c2s.PET_PROMOTE, petId)
end

-------------------------------------------------
--抓宠 
function PetRoleManager:sendCatchPet(id, chapterId, lucky)
	self:sendWithLoading(c2s.CATCH_PET , id, chapterId, lucky)
end

--章节人数   
function PetRoleManager:sendPetChapterOnline()
	self:send(c2s.PET_CHAPTER_ONLINE, false)
end

--宠物融合
function PetRoleManager:sendPetMerge(mainId,viceId,type,choiceNew)
	local itemMainPet = self:getPetByGmId(mainId)
	self.mergeMainPet = clone(itemMainPet)
	self:sendWithLoading(c2s.PET_MERGE, mainId, viceId, type, choiceNew)
end


--------------------------------------------

--章节宠物信息  
function PetRoleManager:onChapterPetInfo(event)
	local data = event.data
	self:addChapterPet(data)

	-- print("##################  onChapterPetInfo ", data)
	TFDirector:dispatchGlobalEventWith(PetRoleManager.CHAPTER_PET_UPDATE, nil)
end

--章节宠物列表  
function PetRoleManager:onChapterPetList(event)
	local data = event.data
	local petList = data.petList or {}
	-- print("###################### onChapterPetList", petList)

	for _,v in pairs(petList) do
		self:addChapterPet(v)
	end
	TFDirector:dispatchGlobalEventWith(PetRoleManager.CHAPTER_PET_UPDATE, nil)
end

--章节人数列表   
function PetRoleManager:onChapterPlayerOnlineList(event)
	local data = event.data
	local chapterList = data.chapterList or {}

	for k,v in pairs(chapterList) do
		self.chapterPlayerOnlineList[v.chapterId] = v.onlineNum
	end

	TFDirector:dispatchGlobalEventWith(PetRoleManager.CHAPTER_PLAYER_NUM, nil)
end

function PetRoleManager:getChapterPlayerOnlineNumber(chapterId)

	return self.chapterPlayerOnlineList[chapterId] or 0
end

--宠物融合
function PetRoleManager:onPetMergeInfo(event)
	hideLoading()

	local data = event.data
	if not data then return end
	self.mergePetId = data.id

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_MERGE, nil)
end

--宠物技能栏解锁
function PetRoleManager:onPetSkillUnLock(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_SKILL_UN_LOCK, nil)
end

--宠物技能学习
function PetRoleManager:onPetSkillLearn(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_SKILL_LEARN, nil)
end

--宠物技能升级
function PetRoleManager:onPetSkillUpLevel(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_SKILL_UP_LEVEL, nil)
end

--宠物技能进阶
function PetRoleManager:onPetSkillPromote(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_SKILL_PROMOTE, nil)
end

--宠物改名
function PetRoleManager:onPetChangeName(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_CHANGE_NAME, nil)
end

--宠物进阶
function PetRoleManager:onPetPromote(event)
	hideLoading()

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_PROMOTE, nil)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, nil)
end

--登录下发所有宠物信息
function PetRoleManager:onReceivePetList(event)
	local data = event.data or {}
	if not data.pet then return end
	self.petRoleList:clear()
	
	for _, pet in pairs(data.pet) do
		local petRole = PetRole:new(pet)
		self.petRoleList:push(petRole)
	end
	CardRoleManager:updateAllRolePetAttr()
end

--更新宠物数据
function PetRoleManager:onReceiveUpdatePet(event)
	hideLoading()
	local data = event.data
	if not data.petCard then return end

	for k, petInfo in pairs(data.petCard) do
		local petRole = self:getPetByGmId(petInfo.id)
		if petRole then
			petRole:updatePet(petInfo)	
			if self.mergePetId and self.mergePetId == petInfo.id then
				if self.mergeMainPet and petRole then
					self:openPetLYCGLayer(self.mergeMainPet,petRole)	
					self.mergePetId = nil
					self.mergeMainPet = nil
				end	
			end
		else
			petRole = PetRole:new(petInfo)
			self.petRoleList:push(petRole)
			--展现获取宠物界面 
			if petInfo.petType == 0 then
				if self.mergePetId and self.mergePetId == petInfo.id then
					if self.mergeMainPet and petRole then
						self:openPetLYCGLayer(self.mergeMainPet,petRole)	
						self.mergePetId = nil
						self.mergeMainPet = nil
					end	
				else
					self:openPetGetLayer(petRole)
				end
			end	
		end
	end
	self.is_petbag = false
	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_UPDATE, nil)
end

--宠物升级
function PetRoleManager:onReceivePetLevelUp(event)
	hideLoading()
	local data = event.data
	local petRole = self:getPetByGmId(data.id)
	if petRole then
		petRole:updateLevel(data.currentLevel, data.currentExp)
		CardRoleManager:updateRolePetAttr(petRole.roleId)
		TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_UP_LEVEL, nil)
	end
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, nil)
end

--宠物移除
function PetRoleManager:onReceiveRemovePet(event)
	hideLoading()
	local data = event.data
	for k,v in pairs(data.id) do
		local petRole = self:getPetByGmId(v)
		if petRole then
			self.petRoleList:removeObject(petRole)
		end
		TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_REMOVE, nil)
	end
end

--宠物上阵
function PetRoleManager:onReceiveBattlePet(event)
	hideLoading()
	local data = event.data
	if not data.pet then return end
	for k,v in pairs(data.pet) do
		
	 	local petRole = self:getPetByGmId(v.id)
		if petRole then
			local roleId = v.roleId ~= "0" and v.roleId or petRole.roleId
			-- print("======---------------",v)
			petRole:updateRoleId(v.roleId)

			CardRoleManager:updateRolePetAttr(roleId)

			-----------------宠物红点
			if v.roleId == "0" then 
				self.is_petbag = false
			end
		end
	end 

	TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_BATTLE, nil)
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_POWER_END, nil)
end

--宠物上锁
function PetRoleManager:onReceiveLockPet(event)
	hideLoading()
	local data = event.data

	local petRole = self:getPetByGmId(data.id)
	if petRole then
		petRole:updatelock(data.lock)
		TFDirector:dispatchGlobalEventWith(PetRoleManager.PET_LOCK, petRole)
	end
end

-- ==============================================================
--添加章节宠物   
function PetRoleManager:addChapterPet(data)
	local chapterId = data.chapterId
	if not chapterId then return end

	local chapter = self.chapterPetList[chapterId]
	if not chapter then
		chapter = {}
		self.chapterPetList[chapterId] = chapter
	end

	if data.id == 0 or data.id == "0" then
		chapter[data.posId] = nil
	else
		chapter[data.posId] = data
	end
	-- print("################### addChapterPet ", data)
end

function PetRoleManager:getChapterPetByChapterId(chapterId)
	--宠物开启判断    
	local configure = FunctionOpenConfigure:objectByID(FunctionManager.Pet)
	if configure then
		local starLv = MissionManager:getStarLevelByMissionId(configure.mission_id)
		if starLv == 0 then
			return {}
		end
	end
	return self.chapterPetList[chapterId] or {}
end

--清理已完成章节宠物
function PetRoleManager:cleanChapterPetByChapterId(chapterId)
	self.chapterPetList[chapterId] = {}
end

--通过实例Id获取宠物
function PetRoleManager:getPetByGmId(gmId)
	for petRole in self.petRoleList:iterator() do
		if petRole.gmId == gmId then
			return petRole
		end
	end

	return nil
end

--通过roleId获取宠物
function PetRoleManager:getPetByRoleId(roleId)
	for petRole in self.petRoleList:iterator() do
		if petRole.roleId == roleId then
			return petRole
		end
	end 

	return nil
end

--获取所有宠物
function PetRoleManager:getAllPetRole()
	local petList = {}
	for pet in self.petRoleList:iterator() do
		-- if pet.petType ~= 1 then
			petList[#petList + 1] = pet
		-- end
	end

	return petList
end

--获取所有普通宠物
function PetRoleManager:getAllCommonPetRole()
	local petList = {}
	for pet in self.petRoleList:iterator() do
		if pet.petType ~= 1 then
			petList[#petList + 1] = pet
		end
	end

	return petList
end

--获取所有未上阵普通宠物
function PetRoleManager:getNoBattlePet()
	local pets = {}
	for petRole in self.petRoleList:iterator() do
		if petRole.petType ~= 1 and petRole.roleId == "0" then
			pets[#pets + 1] = petRole
		end
	end

	return pets
end

function PetRoleManager:getGodPetDivitionByPetId(petId)
    for item in self.petRoleList:iterator() do
        if item.petType ~= 1 and item.petId == petId then
			return item.divition
		end
    end
    return nil
end

function PetRoleManager:getIsShowGodPetViewData()
    for item in self.petRoleList:iterator() do
        if item.viewData and item.viewData ~= "" and item.isShow  then
			return item.viewData
		end
    end
    return ""
end

function PetRoleManager:getCanMergePet()
	local pets = {}
	for petRole in self.petRoleList:iterator() do
		if petRole.petType ~= 1 and not petRole.lock and petRole.roleId == "0" then
			pets[#pets + 1] = petRole
		end
	end

	return pets
end

function PetRoleManager:getMergePetList(petIds)
	local petList = {petIds[1]}
	local value = {}
	for item in PetFormulaData:iterator() do
		if item.main_id == petIds[1] and item.sub_id == petIds[2] then
			petList = {item.main_id,item.rebirth_id}
			value = stringToNumberTable(item.formula_mode,",")
			break
		end
	end
	
	return petList,value
end

--是否打开过宠物背包
function PetRoleManager:getisOpenPetBag()
	return self.is_petbag
end

function PetRoleManager:setisOpenPetBag(is_open)
	self.is_petbag = is_open
end

function PetRoleManager:isHaveAllRedPoint()
	-- for role in CardRoleManager.cardRoleList:iterator() do
	-- 	if role:isAllFormation() then
	-- 		local is_can = JumpToManager:isCanJump( FunctionManager.Pet )
	-- 		if is_can and self:isHaveRedPointByRoleAndPos( role ) then return true end
	-- 	end
	-- end
	return false
end

--卡牌宠物红点
function PetRoleManager:isHaveRedPointByRoleAndPos( role )
	-- if not role:isFormation() then return false end
	-- local rolePet = self:getPetByRoleId(role.gmId)
	-- if rolePet then
	-- 	if self:isHaveBetterPetByQuality( rolePet ) then return true end
	-- 	-- if self:isCanLevelByPet( rolePet ) then return true end
	-- else
	-- 	 return self:isFreePet() 
	-- end
	return false
end

--是否有空闲宠物
function PetRoleManager:isFreePet()
	local petList = self:getNoBattlePet()
	if #petList > 0 then return true end
	return false
end

--是否有更好的宠物
function PetRoleManager:isHaveBetterPetByQuality( pet )

	local role = CardRoleManager:getRoleByGmId(pet.roleId)
	if not role then return false end
	if not role:isFormation() then return false end

	for i,v in pairs(self:getNoBattlePet()) do
		if v.quality > pet.quality and not self.is_petbag then
			return true
		end
	end 
	return false
end

--是否可以升级
function PetRoleManager:isCanLevelByPet( pet )
	local role = CardRoleManager:getRoleByGmId(pet.roleId)
	if not role then return false end
	if not role:isFormation() then return false end

	if pet.level >= pet.maxLevel then
		return false
	end
	--是否有可升级的经验宠物
	local petList = self:getNoBattlePet()
	if #petList > 0 then return true end
	--是否有经验丹
	local goodsItems = BagManager:getItemsBySubType(EnumGoodsSubType.PetExpPill)
	if #goodsItems > 0 then return true end
	return false
end

function PetRoleManager:getPetListToRebirth()
	local petList = TFArray:new()
	for v in self.petRoleList:iterator() do
		if v.curExp > 0 or v.level > 1 then
			petList:push(v)			
		end
	end
	return petList
end

-- 炼妖主宠物
function PetRoleManager:setMergeMainPetRole(petRole)
	self.mainPetRole = petRole
end

function PetRoleManager:getMergeMainPetRole()
	return self.mainPetRole
end
-- 炼妖副宠物
function PetRoleManager:setMergeVicePetRole(petRole)
	self.vicePetRole = petRole
end

function PetRoleManager:getMergeVicePetRole()
	return self.vicePetRole
end

-- PetChooseLayer
function PetRoleManager:openPetChooseLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetChooseLayer", AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

function PetRoleManager:openPetRoleLayer(id)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetXiangQingLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(id)
	AlertManager:show()
end

function PetRoleManager:openPetXiangQingLayer(roldId)
	self:openPetRoleLayer(roldId)
end


function PetRoleManager:openPetChoiceLayer(roldId, pos)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetChoiceLayer", AlertManager.BLOCK_AND_GRAY)
	layer:setPetRoleIdData(roldId, pos)
	AlertManager:show()
end

function PetRoleManager:openPetCatchLayer(data)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetCatchLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(data)
	AlertManager:show()
end

function PetRoleManager:openPetGetLayer(pet)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetGetLayer", AlertManager.BLOCK_CLOSE)
	layer:setPetRoleData(pet)
	AlertManager:show()
end

function PetRoleManager:openPetMergeLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetMergeLayer", AlertManager.BLOCK)
	AlertManager:show()
end

function PetRoleManager:openPetMergeShowLayer(petList,choiceType)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetMergeShowLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(petList,choiceType)
	AlertManager:show()
end

function PetRoleManager:openPetNameModify(petId)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetNameModify", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(petId)
	AlertManager:show()
end

function PetRoleManager:openPetSkillLearning(petId)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetSkillLearning", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(petId)
	AlertManager:show()
end

function PetRoleManager:openPetLeveupPop(petId)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetLeveupPop", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(petId)
	AlertManager:show()
end

function PetRoleManager:openPetJinjieLayer(petId)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetJinjieLayer", AlertManager.BLOCK_CLOSE)
	layer:loadData(petId)
	AlertManager:show()
end

function PetRoleManager:openPetHCLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetHCLayer", AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

function PetRoleManager:openPetLYLayer(type, value)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetLYLayer", AlertManager.BLOCK_AND_GRAY)
	layer:loadData(type, value)
	AlertManager:show()
end

function PetRoleManager:openPetLYCGLayer(oldPet,newPet)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetLYCGLayer", AlertManager.BLOCK_CLOSE)
	layer:loadData(oldPet,newPet)
	AlertManager:show()
end

return PetRoleManager:new()