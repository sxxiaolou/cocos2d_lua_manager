--[[
	游戏卡牌数据

	-- Tony
	-- 2016/06/20

--]]

local GameObject    = require('lua.gamedata.base.GameObject')
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

local CardRole = class("CardRole",GameObject)

function CardRole:ctor(role)
	self.super.ctor(self)
	self:init(role)
end

function CardRole:dispose()
	self.super.dispose(self)

	self.baseAttribute:clear()			
	self.attributeUp:clear()			
	self.attribute:clear()
	self.totalAttribute:clear()
	self.skillAttribute:clear()
	self.fateAttribute:clear()
	self.destinyAttribute:clear()
	self.equipAttribute:clear()
	self.suitAttribute:clear()
	self.bookAttribute:clear()
	self.starAttribute:clear()
	self.artifactAttribute:clear()   -- 法宝 
	self.artifactAttribute2:clear()   -- 法宝固定值
	self.masterAttribute:clear()
	self.petAttribute:clear()
	self.newArtifactAttribute:clear()   --神器
	self.yuekaAttribute:clear()         --月卡
	self.fashionAttribute:clear()
	self.titleAttribute:clear()         --称号
	self.refineAttribute:clear()         --称号

	if self.skillFuns then
		for k,v in pairs(self.skillFuns) do
			v = nil
		end
		self.skillFuns = nil
	end

	if self.skills then
		for k,v in pairs(self.skills) do
			v = nil
		end
		self.skills = nil
	end

	if self.promoteBook then
		for k,v in pairs(self.promoteBook) do
			v = nil
		end
		self.promoteBook = nil
	end

	--init(role)
	self.gmId			= nil 						--服务器唯一id
	self.skillFuns  	= nil
	self.playerId       = nil

	self.otherPlayerCard= nil
	self.baseAttribute 	= nil
	self.attributeUp 	= nil
	self.attribute 		= nil
	self.totalAttribute	= nil

	self.skillAttribute = nil
	self.fateAttribute 	= nil
	self.equipAttribute	= nil
	self.suitAttribute = nil
	self.destinyAttribute = nil
	self.bookAttribute = nil
	self.starAttribute = nil
	self.masterAttribute = nil
	self.petAttribute = nil
	self.newArtifactAttribute = nil
	self.yuekaAttribute = nil
	self.fashionAttribute = nil
	self.titleAttribute = nil
	self.refineAttribute = nil
	
	--initConfig()
	self.roleConfig 	= nil
	self.name 			= nil
	self.pic_id 		= nil

	--updateInfo(role)
	self.quality 		= nil  						--卡牌品质
	self.level 			= nil						--等级
	self.curExp  		= nil
	self.starLv 		= nil 		 				--星级
	self.starStep		= nil 						--星级阶段
	self.pos			= nil 						--位置
	self.maxExp 		= nil 						--总经验
	self.getTime 		= nil						--获得时间
	self.power 			= nil						--战力

	self.skills         = nil 						--技能数据   {skillType, skillId, level, index} 

	self.promoteBook	= nil
	self.promoteLv		= nil
	self.isMainRole     = nil

	--???
	-- TFDirector:unRequire('lua.gamedata.base.GameObject')
	-- TFDirector:unRequire('lua.table.RoleData')
end

function CardRole:init(role)
	--self.Type 			= EnumGameObjectType.Role	--类型		
	self.gmId 			= role.id 						--服务器唯一id
	self.uuid			= self.gmId	--唯一id
	self.id				= role.cardId 						--卡牌模板id
	self.playerId       = role.playerId or MainPlayer:getPlayerId() --卡牌所属的玩家id

	-- self.skillFuns = {self.getActiveSkill, self.getPasSkill, self.getPasSkill2, self.getAwakeSkill}
	self.skillFuns = {self.getActiveSkill, self.getPasSkill, self.getPasSkill2}

	self.otherPlayerCard	= false
	if self.playerId ~= MainPlayer:getPlayerId() then
		self.otherPlayerCard = true
		self.power = role.power or 0
	end
	self.baseAttribute 		= GameAttributeData:new() 				
	self.attributeUp 		= GameAttributeData:new() 				
	self.attribute 			= GameAttributeData:new() 
	self.totalAttribute		= GameAttributeData:new()

	self.skillAttribute 	= GameAttributeData:new()
	self.fateAttribute 		= GameAttributeData:new()
	self.destinyAttribute 	= GameAttributeData:new()
	self.equipAttribute		= GameAttributeData:new()
	self.suitAttribute      = GameAttributeData:new()	
	self.bookAttribute  	= GameAttributeData:new()
	self.starAttribute 		= GameAttributeData:new()
	self.artifactAttribute  = GameAttributeData:new()
	self.artifactAttribute2 = GameAttributeData:new()
	self.masterAttribute    = GameAttributeData:new()
	self.petAttribute  		= GameAttributeData:new()
	self.newArtifactAttribute = GameAttributeData:new()
	self.yuekaAttribute     = GameAttributeData:new()
	self.fashionAttribute   = GameAttributeData:new()
	self.titleAttribute     = GameAttributeData:new()
	self.refineAttribute     = GameAttributeData:new()--人物炼体

	local maleId = ConstantData:getValue("Card.Role.Male")
	local femaleId = ConstantData:getValue("Card.Role.Female")
	self.isMainRole			= self.id == maleId or self.id == femaleId

	--self.equipment 		= RoleEquipment:new()		--装备

	self.skills         = {} 						--技能数据   {skillType, skillId, level, index} 
	self:initConfig()

	self:updateInfo(role)

	--自身主角名字
	if self.isMainRole and not self.otherPlayerCard then
		self.name = MainPlayer:getName()
	end
	--别人玩家主角名字
	if self.isMainRole and self.otherPlayerCard then
		if role.name then self.name = role.name end
	end

	self.refineLevel=-1---炼体等级，未炼体过
end

function CardRole:updateInfo(role)
	self.quality 		= role.quality  			--卡牌品质			
	self.curExp  		= role.curexp
	self.starLv 		= role.star 				--星级
	self.starStep		= role.starStep				--星级阶段
	self.pos			= role.position				--位置
	self.maxExp 		= 0 						--总经验
	self.getTime 		= 0 						-- 获得时间
	self.power 			= role.power or 0  						-- 战力
	self.level 			= 0
	self.showId			= role.showId				--形象   
	self.fashionId      = role.fashionId 			--已拥有形象id

	self:setLevel(role.level)						--等级
	local skills = role.skills or {}
	self.skills = {}
	for _,v in pairs(skills) do
		local skill = {}
		skill.skillType = v.skillType
		skill.skillId = v.skillId
		-- skill.level = v.level
		skill.index = v.index
		if self.skills[v.skillType] == nil then
			self.skills[v.skillType] = {}
		end
		self.skills[v.skillType][v.index] = skill
	end

	self.promoteBook	= {}
	role.promoteBook	= role.promoteBook or {}
	for _,v in pairs(role.promoteBook) do
		self.promoteBook[v] = true
	end
	self.promoteLv		= role.promoteLv

	self:updateBookAttr()
	self:updateStarLevelAttr()
	self:updateSkillPower()
	self:updateDestinyAttrs()
	self:updateArtifactAttrs()
	self:updateMasterAttrs()
	self:updateYuekaAttribute()
	self:updateFashionAttribute()
	self:updateTitleAttribute()
	self:updateTotalAttr()

	-- TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_CARD_INFO)
end

function CardRole:initConfig()
	local id = self.id
	local template = CardData:objectByID(id)
	if template == nil then
		toastMessage("角色获取为空(CardData:)-"..id)
		return
	end

	self.template 			= template
	self.name 				= template.name
	self.pic_id 			= template.pic_id
	self.tplId 				= template.id
	self.equip_id           = template.equip_id

	self.skills[EnumSkillType.NormalAttack] = {}
	self.skills[EnumSkillType.NormalAttack][1] = {skillId=template.phy_skill, index = 1, skillType = EnumSkillType.NormalAttack}

	self.baseAttribute:init(template.init_att)
	self.attributeUp:init(template.grow_att)
end

function CardRole:setPos(pos)
	if pos == nil then
		pos = 0
	end
	self.pos = pos
end

function CardRole:setRefineLevel(Level)	
	self.refineLevel=Level
end

function CardRole:getRefineLv()	
	return self.refineLevel
end

function CardRole:getSex()
	return self.template.sex
end

function CardRole:getQuality()
	return self.quality
end

--最大星级
function CardRole:getMaxStar()
	return self.template.max_star
end

--职业
function CardRole:getCareer()
	return self.template.career
end

--描述
function CardRole:getDesc()
	return self.template.desc
end

--对应魂卡id
function CardRole:getSoulId()
	return self.template.card_id
end

--招募所需魂卡数量    
function CardRole:getRecruitSoulNum()
	return self.template.recruit_num
end

--返还魂卡数量
function CardRole:getRefundSoulNum()
	return self.template.refund_num
end

--升星所需魂卡数量
function CardRole:getUpgradeSoulNum()
	return self.template.upgrade_num
end

--全身像
function CardRole:getPic()
	return self.template:getPic()
end

--头像 （圆形）
function CardRole:getHead()
	return self.template:getHead()
end

--图标（方形）
function CardRole:getIcon()
	return self.template:getIcon()
end

function CardRole:getCareerPath()
	return self.template:getCareerPath()
end

function CardRole:getAttr(attrType)
	return self.totalAttribute.attribute[attrType] or 0
end

function CardRole:getSkill(type, index)
	index = index or 1
	if self.skills[type] == nil then
		return nil
	end
	return self.skills[type][index]
end

function CardRole:countSkills()
	local cnt = 0
	for _, fun in pairs(self.skillFuns) do
		local skill = fun(self)
		if skill and skill.skillId ~= 0 then
			cnt = cnt + 1
		end
	end

	return cnt
end

function CardRole:getSkillByIdx(idx)
	idx = idx + 1
	for _, fun in pairs(self.skillFuns) do
		local skill = fun(self)
		if skill and skill.skillId ~= 0 then
			idx = idx - 1
			if idx == 0 then return skill end
		end
	end

	return nil
end

function CardRole:getUnlockedSkill()
	local promoteLv = self.promoteLv
	for k,v in pairs(self.skills) do
		for i=1,#v do
			local skill = SkillData:objectByID(v[i].skillId)
			if skill and skill.open_level == promoteLv then
				return skill
			end
		end
	end
	return nil
end

--普攻id
function CardRole:getNormalSkill()
	return self:getSkill(EnumSkillType.NormalAttack)
end

--技能id
function CardRole:getActiveSkill()
	return self:getSkill(EnumSkillType.ActiveSkill)
end

--被动1的id
function CardRole:getPasSkill()
	return self:getSkill(EnumSkillType.PasSkill)
end

--被动2的id
function CardRole:getPasSkill2()
	return self:getSkill(EnumSkillType.PasSkill, 2)
end

function CardRole:getAwakeSkill()
	return self:getSkill(EnumSkillType.AwakeSkill)
end

function CardRole:getBeatbackSkill()
	return self:getSkill(EnumSkillType.BeatbackSkill)
end

function CardRole:getAcquire()
	return self.template.acquire
end

function CardRole:getNameColor()
	return GetColorByQuality(self.quality)
end

function CardRole:getPower()
	return self.power
end

function CardRole:getIsMainRole()
	return self.isMainRole
end

function CardRole:isFormation()
	return FormationManager:inFormation(EnumFormationType.PVE, self.gmId)
end

function CardRole:isAnyFormation()
	return FormationManager:inAnyFormation(self.gmId)
end

--所有阵容 pve pvp blood bookWorld
function CardRole:isAllFormation()
	return FormationManager:inAnyFormation(self.gmId) or BookWorldManager:inBookWorldIsUseById(self.gmId)
end

-- 获取升级需要的经验，-1为无法升级
function CardRole:getLevelUpExp()
	local cardLevel = CardLevelData:objectByID(self.level + 1)
	if not cardLevel then return -1 end

	if self:getIsMainRole() then
		return cardLevel.group_exp
	else
		return cardLevel.role_exp
	end
	
end

function CardRole:getLevelUpPercent()
	local levelUpExp = self:getLevelUpExp()

	if levelUpExp == -1 then return 100 end

	return self.curExp / levelUpExp * 100
end

function CardRole:setName(name)
	self.name = name
end

function CardRole:setQuality(quality)
	self.quality = quality
end

function CardRole:setLevel(level)
	if self.level == level then
		return
	end

	self.level = level

	local cardLevel = CardLevelData:objectByID(level + 1)
	if not cardLevel then
		cardLevel = CardLevelData:objectByID(level)
	end
	self.maxExp = cardLevel.role_exp
end

function CardRole:getStarLv()
	return self.starLv
end


function CardRole:getLevel()
	return self.level
end

function CardRole:getMaxExp()
	return self.maxExp
end

function CardRole:getName()
	if self.name then
		return self.name
	end
	return self.template.name
end

function CardRole:getEquipAttr()
	return self.equipAttribute.attribute
end

function CardRole:getAllFateCard()
	local tbl = {}
	local fates = CardFateData:getRoleFates(self.id)
	if not fates then return tbl end
	for _,fate in pairs(fates) do
		local card_ids = stringToNumberTable(fate.fate_role_ids, ",")
		for _,id in pairs(card_ids) do
			tbl[id] = id
		end
	end
	return tbl
end

function CardRole:updateTotalAttr()
	if self.otherPlayerCard then
		return
	end

	self.totalAttribute:clear()

	self:refreshRoleBaseAttr()
	self.totalAttribute:clone(self.attribute)

	self.totalAttribute:setAddAttData(self.skillAttribute)
	self.totalAttribute:setAddAttData(self.fateAttribute)
	self.totalAttribute:setAddAttData(self.bookAttribute)
	self.totalAttribute:setAddAttData(self.starAttribute)
	self.totalAttribute:setAddAttData(self.artifactAttribute)
	self.totalAttribute:setAddAttData(self.suitAttribute)
	self.totalAttribute:refreshByPercent()
	
	self.totalAttribute:setAddAttData(self.destinyAttribute)
	self.totalAttribute:setAddAttData(self.equipAttribute)
	self.totalAttribute:setAddAttData(self.newArtifactAttribute)
	self.totalAttribute:setAddAttData(self.yuekaAttribute)
	self.totalAttribute:refreshByPercent()

	self.totalAttribute:setAddAttData(self.artifactAttribute2)
	self.totalAttribute:setAddAttData(self.masterAttribute)
	self.totalAttribute:setAddAttData(self.petAttribute) --宠物属性   
	self.totalAttribute:setAddAttData(self.fashionAttribute)
	self.totalAttribute:setAddAttData(self.titleAttribute)
	self.totalAttribute:setAddAttData(self.refineAttribute)--人物炼体

	self.totalAttribute:attributeToFloor()
	self.totalAttribute:updatePower()
	self:updatePower()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_CARD_INFO)
end

function CardRole:hasTrain()
	if self.level > 1 or self.starLv > 0 or self.promoteLv > 1 or self.refineLevel>0 then
		return true  
	end
	return false
end

--[[
 战斗力
--]]
function CardRole:updatePower()
	--其他玩家过滤
	if self.otherPlayerCard then return end
	self.power = self.totalAttribute:getPower()

	if self.skillPower ~= nil then
		self.power = self.power + self.skillPower
	end
end

function CardRole:updateSkillPower()
	local function skillPower(skillId)
		local skilldata = SkillData:objectByID(skillId)
		if skilldata == nil then
			return
		end

		local attach_att = GetAttrByStringForExtra(skilldata.attach_att)
		for k,v in pairs(attach_att) do
			self.skillAttribute:addAttr(k, v)
		end
		self.skillPower = self.skillPower + skilldata.power_rate/10000
	end
	self.skillPower = 0

	self.skillAttribute:clear()
	for k,skills in pairs(self.skills) do
		for index, skill in pairs(skills) do
			if skill then
				skillPower(skill.skillId)
			end
		end
	end

	self.skillPower = math.floor(self.skillPower)
end

-- function CardRole:updateSkillAttr()
-- 	local function skillAttr(skillId, skillLevel)
-- 		local skilldata = SkillData:objectByID(skillId)
-- 		if skilldata == nil then
-- 			return
-- 		end

-- 		local fix_value = skilldata.fix_value
-- 		local level_value = skilldata.level_value
-- 		local tbl_fix = GetAttrByString(fix_value, '_')
-- 		for k,v in pairs(tbl_fix) do
-- 			self.skillAttribute:addAttr(k, v)
-- 		end

-- 		local tbl_level = GetAttrByString(level_value, "_")
-- 		for k,v in pairs(tbl_level) do
-- 			self.skillAttribute:addAttr(k, v*SkillLevelData:objectByIDAndAttr(skillLevel, k))
-- 		end

-- 		self.skillPower = self.skillPower + skilldata.power_rate/10000 * SkillLevelData:objectByIDAndAttr(skillLevel, "spell_power")
-- 	end

-- 	self.skillPower = self.skillPower or 0
-- 	self.skillAttribute:clear()

-- 	for k,skills in pairs(self.skills) do
-- 		for index, skill in pairs(skills) do
-- 			if skill then
-- 				skillAttr(skill.skillId, skill.level)
-- 			end
-- 		end
-- 	end

-- 	self.skillPower = math.floor(self.skillPower)
-- 	self:updateTotalAttr()
-- end

function CardRole:updateSkill(skillType, index, level)
	local skills = self.skills[skillType]
	if skills and skills[index] then
		local skill = skills[index]
		skill.level = level
		-- self:updateSkillAttr()
	end
end

function CardRole:updateStarLevelAttr()
	self.starAttribute:clear()
	local cardStar = CardStarUpData:objectByRoleIdAndStar(self.id, self.starLv)
	if cardStar then
		local attr = GetAttrByString(cardStar.attrs)
		for k,v in pairs(attr) do
			self.starAttribute:addAttr(k,v)
		end
	end
end

function CardRole:updateBookAttr()
	self.bookAttribute:clear()

	local promoteLv = self.promoteLv
	local promoteBook = self.promoteBook

	local advance1  = CardAdvanceData:getObjectByTypeAndLevel(self.template.promote_type, promoteLv)
   	local advance2  = CardAdvanceData:getObjectByTypeAndLevel(self.template.promote_type, promoteLv+1)
   	if advance1 == nil or advance2 == nil then
   		return
   	end
    self.bookAttribute:init(advance1.attrs)

    local bookList = advance2:getMartialTable()
    for i=1, #bookList do
    	if promoteBook[i] ~= nil then
    		local bookInfo = GoodsMaterialData:objectByID(bookList[i])
    		if bookInfo then
    			local attrTable = bookInfo:getAttrTable()
    			for k,v in pairs(attrTable) do
    				self.bookAttribute:addAttr(k, v)
    			end
    		end
    	end
    end
end

function CardRole:refreshRoleBaseAttr()
	local function cmp( attr , index ,tbl)
		local attributeUp = tbl.attributeUp:getAttribute()
		local temp = attributeUp[index] or 0

		local num = (attr + temp * tbl.level)  * tbl.upgrade_rate/10000
		return num
	end
	self.attribute:clear()

	local cardItem = CardStarData:getDataByQualityAndStar(self.quality,self.starLv)
	local upgrade_rate = cardItem.upgrade_rate
	self.attribute:setAttByMath(self.baseAttribute,cmp,{level = (self.level -1),attributeUp = self.attributeUp, upgrade_rate = upgrade_rate})
end

-- 更新缘分
function CardRole:updateFateAttrs()
	self.fateAttribute:clear()
	local function _fateAttrs(fateData)
		local tblAttrs = fateData:getFateAttrs()
		for k,v in pairs(tblAttrs) do
			self.fateAttribute:addAttr(k, v)
		end
	end

	local roleFates = CardFateData:getRoleFates(self.tplId)
	local equipFates = CardFateData:getEquipFates(self.tplId)
	for _, fate in pairs(roleFates) do
		if self:isFateActive(fate.id) then
			_fateAttrs(fate)
		end
	end
	for _,fate in pairs(equipFates) do
		if self:isFateActive(fate.id) then
			_fateAttrs(fate)
		end
	end
	self:updateTotalAttr()
end

function CardRole:isFateActive(fateId)
	return CardRoleManager:isFateActive(fateId)
end

-- 天命
function CardRole:updateDestinyAttrs()
	self.destinyAttribute:clear()
	if not self:getIsMainRole() then return end

	if CardRoleManager.destinyLevel <= 1 and CardRoleManager.destinyPhase <= 1 then return end

	for i=1, CardRoleManager.destinyLevel do
		local destinyList = DestinyData:getDestinyList(i) or {}
		for k,v in pairs(destinyList) do
			if i < CardRoleManager.destinyLevel or (i == CardRoleManager.destinyLevel and k < CardRoleManager.destinyPhase) then
				self:addDestinyAttrs(v)
			end
		end
	end
	self.destinyAttribute:refreshByPercent()
	self.destinyAttribute:attributeToFloor()
end

function CardRole:addDestinyAttrs(destiny)
	if destiny and #destiny.role_att ~= 0 then
		local tblAttrs = GetAttrByString(destiny.role_att)
		for k,v in pairs(tblAttrs) do
			self.destinyAttribute:addAttr(k, v)
		end
	end
end

--神器属性
function CardRole:updateArtifactAttrs()
	self.artifactAttribute:clear()
	self.artifactAttribute2:clear()
	local artifact = ArtifactManager:findArtifactByRoleID(self.gmId)
	if artifact then

		local envolveData = ArtifactEnvolveData:getArtifactEnvolveByIdAndLevel( artifact.tplId, artifact.level)
		if envolveData then
			local tblAttrs = GetAttrByString(envolveData.attrs_server)
			for k,v in pairs(tblAttrs) do
				self.artifactAttribute:addAttr(k, v)
			end
		end
		
		local item = ArtifactLevelData:getArtifactByQualityAndLevel(artifact.template.quality, artifact.attrLevel)
		if item then
			local tblAttrs = GetAttrByString(item.attrs_server)
			for k,v in pairs(tblAttrs) do
				self.artifactAttribute2:addAttr(k, v)
			end
		end
	end
end

function CardRole:updateEquipAtteribute()
	self.equipAttribute:clear()
	local equipList = EquipmentManager:getEquipListByPos(self.gmId)
	if equipList == nil then
		self:updateTotalAttr()
		return
	end

	--装备属性   装备总属性
	for _, equip in pairs(equipList) do
		self.equipAttribute:setAddAttData(equip.totalAttribute)
	end

	self:updateTotalAttr()
end
--套装属性
function CardRole:updateSuitAtteribute( ... )
	self.suitAttribute:clear()
	local suitAtteribute = EquipmentManager:getSuitAttbuteByRoleId( self.gmId )
    for k,v in pairs(suitAtteribute) do
		self.suitAttribute:addAttr(k,v)
	end
	self:updateTotalAttr()
end

--大师属性 
function CardRole:updateMasterAttrs()
	self.masterAttribute:clear()
	local masterAttrs = EquipmentManager:getEquipMasterById(self.gmId)
	if masterAttrs == nil then
		return
	end

	for _, item in pairs(masterAttrs) do
		local attr = item:getMasterAttr()
		if attr then
			for k,v in pairs(attr) do
				self.masterAttribute:addAttr(k, v)
			end
		end
	end

	self.masterAttribute:refreshByPercent()
end

--宠物属性   
function CardRole:updatePetAttr()
	self.petAttribute:clear()

	local pet = PetRoleManager:getPetByRoleId(self.gmId)
	if pet then
		self.petAttribute:setAddAttData(pet.baseAttribute)
	end
	self:updateTotalAttr()
end

--新神器属性   
function CardRole:updateNewArtifactAttrs()
	self.newArtifactAttribute:clear()

	for k,v in pairs(NewArtifactManager.shenAttr) do
		self.newArtifactAttribute:addAttr(k,v)
	end
	if FormationManager:inFormation(EnumFormationType.PVE,self.gmId) or FormationManager:inFormation(EnumFormationType.PVP,self.gmId) then
		for k,v in pairs(NewArtifactManager.hunAttr) do
			self.newArtifactAttribute:addAttr(k,v)
		end
	end
	if self.isMainRole then
		for k,v in pairs(NewArtifactManager.lingAttr) do
			self.newArtifactAttribute:addAttr(k,v)
		end
	end

	self:updateTotalAttr()
end

--月卡属性
function CardRole:updateYuekaAttribute(  )
	self.yuekaAttribute:clear()
	if not PayManager.yueKaAttribute then
		self:updateTotalAttr()
		return
	end
	if PayManager.cardCount ~= 3 and not self.isMainRole then
		self:updateTotalAttr()
		return
	end
	for k,v in pairs(PayManager.yueKaAttribute) do
		self.yuekaAttribute:addAttr(k,v)
	end
	self:updateTotalAttr()
end

function CardRole:updateFashionAttribute()
	self.fashionAttribute:clear()
	if not self.fashionId then return end
	for k,v in pairs(self.fashionId) do
		local data = FashionData:objectByID(v)
		if data then
			local attach_att = GetAttrByStringForExtra(data.attach_att)
			for m, n in pairs(attach_att) do
				self.fashionAttribute:addAttr(m, n)
			end
		end
	end
end

--称号属性
function CardRole:updateTitleAttribute( ... )
	self.titleAttribute:clear()
	if FormationManager:inFormation(EnumFormationType.PVE,self.gmId) or FormationManager:inFormation(EnumFormationType.PVP,self.gmId) then
		for k,v in pairs(TitleManager.titleAttribute) do
			self.titleAttribute:addAttr(k,v)
		end
	end
	self:updateTotalAttr()
end

--炼体属性
function CardRole:updateRefineAttribute( attrData )
	self.refineAttribute:clear()
	for k,v in pairs(attrData) do
		self.refineAttribute:addAttr(k,v)
	end
	self:updateTotalAttr()
end


--全卡牌属性添加
function CardRole:updateAllCardRoleAttribute()
	self:updateNewArtifactAttrs()
	self:updateYuekaAttribute()
	self:updateTitleAttribute()
end

--==================================  上一阶属性计算 =================================

function CardRole:getPreBookAttr()
	local preAttribute = GameAttributeData:new()
	local bookAttribute = GameAttributeData:new()
	local function bookAttr()
		local promoteLv = self.promoteLv - 1
		local advance  = CardAdvanceData:getObjectByTypeAndLevel(self.template.promote_type, promoteLv)
   		if advance == nil then
   			return
   		end
    	bookAttribute:init(advance.attrs)
	end

	bookAttr()
	preAttribute:clear()
	preAttribute:clone(self.attribute)

	preAttribute:setAddAttData(self.skillAttribute)
	preAttribute:setAddAttData(self.fateAttribute)
	preAttribute:setAddAttData(bookAttribute)
	preAttribute:setAddAttData(self.starAttribute)
	preAttribute:setAddAttData(self.artifactAttribute)
	preAttribute:setAddAttData(self.suitAttribute)
	preAttribute:refreshByPercent()

	preAttribute:setAddAttData(self.destinyAttribute)
	preAttribute:setAddAttData(self.equipAttribute)
	preAttribute:setAddAttData(self.newArtifactAttribute)
	preAttribute:setAddAttData(self.yuekaAttribute)
	preAttribute:refreshByPercent()

	preAttribute:setAddAttData(self.artifactAttribute2)
	preAttribute:setAddAttData(self.masterAttribute)	
	preAttribute:setAddAttData(self.petAttribute)
	preAttribute:setAddAttData(self.fashionAttribute)
	preAttribute:setAddAttData(self.titleAttribute)
	preAttribute:setAddAttData(self.refineAttribute)

	preAttribute:attributeToFloor()
	preAttribute:updatePower()

	bookAttribute:clear()
	bookAttribute = nil
	return preAttribute
end

function CardRole:getPreStarAttr()
	local attribute = GameAttributeData:new()
	local starAttribute = GameAttributeData:new()
	local starLv = self.starLv - 1
	local function attrCalc()
		local function cmp( attr , index ,tbl)
			local attributeUp = tbl.attributeUp:getAttribute()
			local temp = attributeUp[index] or 0

			local num = (attr + temp * tbl.level)  * tbl.cardItem.upgrade_rate/10000
			return num
		end
		local cardItem = CardStarData:getDataByQualityAndStar(self.quality, starLv)
		attribute:setAttByMath(self.baseAttribute,cmp,{level = (self.level -1),attributeUp = self.attributeUp, cardItem = cardItem})
	end

	local function starAttr()
		local cardStar = CardStarUpData:objectByRoleIdAndStar(self.id, starLv)
		if cardStar then
			local attr = GetAttrByString(cardStar.attrs)
			for k,v in pairs(attr) do
				starAttribute:addAttr(k,v)
			end
		end
	end

	local preAttribute = GameAttributeData:new()

	preAttribute:clear()
	attrCalc()
	starAttr()
	preAttribute:clone(attribute)

	preAttribute:setAddAttData(self.skillAttribute)
	preAttribute:setAddAttData(self.fateAttribute)
	preAttribute:setAddAttData(self.bookAttribute)
	preAttribute:setAddAttData(starAttribute)
	preAttribute:setAddAttData(self.artifactAttribute)
	preAttribute:setAddAttData(self.suitAttribute)
	preAttribute:refreshByPercent()

	preAttribute:setAddAttData(self.destinyAttribute)
	preAttribute:setAddAttData(self.equipAttribute)
	preAttribute:setAddAttData(self.newArtifactAttribute)
	preAttribute:setAddAttData(self.yuekaAttribute)
	preAttribute:refreshByPercent()

	preAttribute:setAddAttData(self.artifactAttribute2)
	preAttribute:setAddAttData(self.masterAttribute)
	preAttribute:setAddAttData(self.petAttribute)
	preAttribute:setAddAttData(self.fashionAttribute)
	preAttribute:setAddAttData(self.titleAttribute)
	preAttribute:setAddAttData(self.refineAttribute)

	preAttribute:attributeToFloor()
	preAttribute:updatePower()

	attribute:clear()
	starAttribute:clear()
	attribute = nil
	starAttribute = nil
	return preAttribute
end

function CardRole:getPreQualityAttr()
	local preAttribute = GameAttributeData:new()
	local qualityAttribute = GameAttributeData:new()
	local function calcAttr()
		local function cmp( attr , index ,tbl)
			local attributeUp = tbl.attributeUp:getAttribute()
			local temp = attributeUp[index] or 0

			local num = (attr + temp * tbl.level)  * tbl.upgrade_rate/10000
			return num
		end
		qualityAttribute:clear()

		local cardItem = CardStarData:getDataByQualityAndStar(self.quality - 1,self.starLv)
		local upgrade_rate = cardItem.upgrade_rate
		qualityAttribute:setAttByMath(self.baseAttribute,cmp,{level = (self.level -1),attributeUp = self.attributeUp, upgrade_rate = upgrade_rate})
	end

	calcAttr()
	preAttribute:clear()
	preAttribute:clone(qualityAttribute)

	preAttribute:setAddAttData(self.skillAttribute)
	preAttribute:setAddAttData(self.fateAttribute)
	preAttribute:setAddAttData(self.bookAttribute)
	preAttribute:setAddAttData(self.starAttribute)
	preAttribute:setAddAttData(self.artifactAttribute)
	preAttribute:setAddAttData(self.suitAttribute)
	preAttribute:refreshByPercent()

	preAttribute:setAddAttData(self.destinyAttribute)
	preAttribute:setAddAttData(self.equipAttribute)
	preAttribute:setAddAttData(self.newArtifactAttribute)
	preAttribute:setAddAttData(self.yuekaAttribute)
	preAttribute:refreshByPercent()

	preAttribute:setAddAttData(self.artifactAttribute2)
	preAttribute:setAddAttData(self.masterAttribute)
	preAttribute:setAddAttData(self.petAttribute)
	preAttribute:setAddAttData(self.fashionAttribute)
	preAttribute:setAddAttData(self.titleAttribute)
	preAttribute:setAddAttData(self.refineAttribute)

	preAttribute:attributeToFloor()
	preAttribute:updatePower()
	
	qualityAttribute:clear()
	qualityAttribute = nil
	return preAttribute
end

return CardRole