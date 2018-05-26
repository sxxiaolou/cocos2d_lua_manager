-- 宠物
-- Author: sunyunpeng
-- Date: 2017-09-12
--

local GameObject = require('lua.gamedata.base.GameObject')
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

local PetRole = class("PetRole", GameObject)

function PetRole:ctor(pet)
	self.super.ctor(self)
	self:init(pet)
end

function PetRole:dispose()
	self.baseAttribute:clear()
end

function PetRole:init(pet)
	-- print("======******----",pet)
	self.gmId 			= pet.id 					--唯一id
	self.uuid 			= self.gmId  				--唯一id
	self.petType		= pet.petType				--宠物类型 0普通宠物 1神宠
	self.tplId 			= pet.tplId					--宠物模板id 神宠为0
	self.level 			= pet.level 				--等级
	self.curExp 		= pet.curexp 				--当前经验
	self.skill			= pet.skill or {}			--技能
	self.roleId 		= pet.roleId 				--角色卡牌id
	self.attr 		 	= pet.attr 				 	--属性
	self.luckAttr		= pet.luckAttr				--幸运属性
	self.quality   		= pet.quality				--品质
	self.division   	= pet.division 				--段位
	self.prefix			= pet.prefix				--前缀
	self.lock			= pet.lock 					--锁状态
	self.viewData		= pet.viewData				--外观
	self.name 			= pet.name					--名字
	self.aptitude  		= {} 				 		--资质
	self.allAptitud		= 0							--总资质
	self.isShow       	= pet.isShow or false		--是否外显
	local itemPet = PetAttrData:getPetAptitudeByIdAndQualityAndDivision( pet.tplId, pet.quality, pet.division )
	if itemPet then
		self.maxLevel 	= itemPet.max_lv				--等级上限
		self.type 		= itemPet.pet_type				--类型
		self.petAttrData= itemPet
	end

	local template 		= nil
	if self.petType == 1 then
		self.template 	= itemPet
	else
		self.template 	= CardData:objectByID(pet.tplId) 
	end

	if self.template == nil then
		toastMessage("角色获取为空(CardData:)-".. pet.tplId)
		return
	end
	
	self.baseAttribute 	= GameAttributeData:new()--属性
	self:updateBaseAttrs()
	
	self:updateAptitude()
	self:setPetPrefixName()
end

function PetRole:updatePet(pet)
	self:init(pet)
end

-- 更新资质
function PetRole:updateAptitude()
	self.aptitude = {}
	self.allAptitud = 0
	local itemAttr = GetAttrByString(self.attr)
	-- print("=====updateAptitude",self.attr,itemAttr)
	for k,attr in pairs(itemAttr) do
		self.aptitude[k] = attr
		self.allAptitud = self.allAptitud + attr
	end
end

-- 更新属性
function PetRole:updateBaseAttrs()
	self.baseAttribute:clear()
	local itemAttr = GetAttrByString(self.attr)
	local conNumber = ConstantData:getValue( "Pet.Adjust" ) or 10000
	for k,attr in pairs(itemAttr) do
		local baseValue = self:getBaseValueByType(k)
		local adjustCoef = self:getAdjustCoefficientByType(k) / 10000
		local qualityCoef = self:getQualityCoefficientByType(self.quality) / 10000
		local coefficient = attr * adjustCoef * qualityCoef
		local itemAttr = math.floor(baseValue + coefficient * self.level)
		self.baseAttribute:addAttr(k, itemAttr)
	end
	self.baseAttribute:updatePower()
end

--基础属性
function PetRole:getBaseValueByType( type )
	if type == 1 then
		return self.petAttrData.base_life
	elseif type == 2 then
		return self.petAttrData.base_attack
	elseif type == 3 then
		return self.petAttrData.base_phy_def
	elseif type == 4 then
		return self.petAttrData.base_mag_def
	elseif type == 5 then
		return self.petAttrData.base_speed
	end
	return 0
end

--转化系数
function PetRole:getAdjustCoefficientByType( type )
	if type == 1 then
		return ConstantData:getValue( "pet.adjust.life" )
	elseif type == 2 then
		return ConstantData:getValue( "pet.adjust.attack" )
	elseif type == 3 then
		return ConstantData:getValue( "pet.adjust.phy.def" )
	elseif type == 4 then
		return ConstantData:getValue( "pet.adjust.mag.def" )
	elseif type == 5 then
		return ConstantData:getValue( "pet.adjust.speed" )
	end
	return ConstantData:getValue( "Pet.Adjust" )
end
--品质系数
function PetRole:getQualityCoefficientByType( quality )
	if quality == 1 then
		return ConstantData:getValue( "pet.adjust.white" )
	elseif quality == 2 then
		return ConstantData:getValue( "pet.adjust.green" )
	elseif quality == 3 then
		return ConstantData:getValue( "pet.adjust.blue" )
	elseif quality == 4 then
		return ConstantData:getValue( "pet.adjust.purple" )
	elseif quality == 5 then
		return ConstantData:getValue( "pet.adjust.orange" )
	elseif quality == 6 then
		return ConstantData:getValue( "pet.adjust.red" )
	end
	return ConstantData:getValue( "Pet.Adjust" )
end

function PetRole:updateLevel(level, exp)
	self.level = level
	self.curExp = exp

	self:updateBaseAttrs()
end

function PetRole:updateRoleId(roleId)
	self.roleId = roleId
end

function PetRole:updatelock(lock)
	self.lock = lock
end

function PetRole:updateIsShow(isShow)
	self.isShow = isShow
end

function PetRole:setPetPrefixName()
	-- for item in PetPrefixData:iterator() do
	-- 	local value = stringToNumberTable(item.percentage, "_")
	-- 	if self.prefix >= value[1] and self.prefix <= value[2] then
	-- 		str = item.prefix
	-- 		break
	-- 	end
	-- end

	-- if self.prefix > 81 then
	-- 	self.prefixName = str
	-- else
		self.prefixName = ""
	-- end
end

return PetRole