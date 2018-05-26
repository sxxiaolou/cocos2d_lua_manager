--[[
******游戏数据装备牌类*******

	-- by Tony
	-- 2016/9/21
]]

local GameObject = require('lua.gamedata.base.GameObject')
local CardEquipment = class("CardEquipment",GameObject)

local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

-- message GemPos
-- {
-- 	required int32 pos 	  = 1;    // pos
-- 	required int32 id 	  = 2;    // id
-- }

-- message RefineAttr
-- {
-- 	required int32 attrId = 1;			//
-- 	required int32 attrValue = 2;		//
-- 	required int32 refineLevel = 3;		//精炼等级
-- }
function CardEquipment:ctor( data )
	self.super.ctor(self)
	self:init(data)

end

function CardEquipment:dispose()
	self.attribute:clear()
	self.baseAttribute:clear()
	self.attributeUp:clear()
	self.totalAttribute:clear()
	self.starAttribute:clear()
	self.refineAttribute:clear()
	self.gemAttribute:clear()
	self.enhanceAttribute:clear()
	self.firstAttribute:clear()
	self.secondAttribute:clear()

	self.attribute 			= nil
	self.baseAttribute   	= nil
	self.attributeUp	 	= nil
	self.totalAttribute 	= nil
	self.starAttribute  	= nil
	self.refineAttribute    = nil
	self.masterAttribute  	= nil 								--装备大师属性
	self.gemAttribute 		= nil
	self.enhanceAttribute   = nil
	self.firstAttribute		= nil
	self.secondAttribute    = nil

	if self.gemPos then
		for k,v in pairs(self.gemPos) do
			v = nil
		end
		self.gemPos = nil
	end

	if self.refineAttr then
		for k,v in pairs(self.refineAttr) do
			v = nil
		end
		self.refineAttr = nil
	end

	if self.enhAttr then
		for k,v in pairs(self.enhAttr) do
			v = nil
		end
		self.enhAttr = nil
	end
end

function CardEquipment:init( data )
	self.attribute 			= GameAttributeData:new() 			--最终基本属性
	self.baseAttribute   	= GameAttributeData:new() 			--基本属性
	self.attributeUp	 	= GameAttributeData:new()			--成长属性
	self.totalAttribute 	= GameAttributeData:new()			--总属性 --
	self.enhanceAttribute 	= GameAttributeData:new() 			--强化属性
	self.starAttribute  	= GameAttributeData:new()			--升星属性
	self.refineAttribute    = GameAttributeData:new() 			--精炼属性
	self.masterAttribute  	= nil 								--装备大师属性
	self.gemAttribute 		= GameAttributeData:new()			--宝石属性
	self.firstAttribute		= GameAttributeData:new() 			--装备主属性 包括升级、升星
	self.secondAttribute	= GameAttributeData:new() 			--装备副属性 包括强化副属性、精炼属性

	self.type 				= EnumResourceType.Equipment 		--装备资源类型
	self.id 				= 0									--服务器唯一id
	self.equipType 			= 0									--装备子类型
	self.level 				= 0									--装备强化等级
	self.starLv 			= 0									--星级等级
	self.tplId 				= 0									--装备模版id

	self:updateInfo(data)
end

function CardEquipment:updateInfo(equip)
	self.id 				= equip.id
	self.tplId 				= equip.tplId
	self.level 				= equip.level or 1
	self.starLv 			= equip.star or 0
	self.posId 				= equip.posId
	self.lock 				= equip.lock
	self.num 				= equip.num
	self.type 				= equip.type
	self.refineItemNum		= equip.refineItemNum or 0

	self:initConfig()
	self:updateEnhAttr(equip.enhAttr)
	self:updateGemPos(equip.gem)
	self:updateRefining(equip.attr)

	self:updateStarAttribute()

	--更新装备总属性
	self:updateTotalAttr()
end

function CardEquipment:initConfig()
	if self.template and self.template.id == self.tplId then
		return
	end

	local tplId = self.tplId
	local template = EquipData:objectByID(tplId)
	if template == nil then
		toastMessage("装备获取为空(EquipmentData:)-"..tplId)
		return
	end

	self.template 			= template
	self.name 				= template.name
	self.pic_id 			= template.display
	self.equipType			= template.kind
	self.quality 			= template.quality

	self.baseAttribute:init(template.init_att)
	self.attributeUp:init(template.grow_att)
end

function CardEquipment:updateEnhAttr(enhAttr)
	self.enhAttr = {}
	enhAttr = enhAttr or {}
	for _, enh in pairs(enhAttr) do
		self.enhAttr[#self.enhAttr + 1] = {attrId=enh.attrId, attrValue=enh.attrValue}
	end
	self:updateEnhanceAttribute()
end

function CardEquipment:updateGemPos(equipGemPos)
	equipGemPos = equipGemPos or {}
	self.gemPos = {}						--宝石信息  --gem_hole  宝石孔  
	for k,v in pairs(equipGemPos) do
	  	self.gemPos[v.pos] = {pos = v.pos, id = v.id, template = EquipGemData:objectByID(v.id)}
	end
	self:updateGemAttribute()
end

function CardEquipment:updateRefining(refAttr)
	refAttr = refAttr or {}
	self.refineAttr = {} 	 				--精炼信息 
	for _,refine in pairs(refAttr) do
		self.refineAttr[#self.refineAttr + 1] = {attrId=refine.attrId, attrValue=refine.attrValue,level=refine.refineLevel}
	end

	self:updateRefineAttribute()
end

function CardEquipment:getLevel()
	return self.level
end

function CardEquipment:getQuality()
	return self.quality
end

function CardEquipment:getStarLv()
	return self.starLv
end

function CardEquipment:getPower()
	return self.power
end

function CardEquipment:getGemPos()
	return self.gemPos
end

function CardEquipment:getRefineAttr()
	return self.refineAttr
end

function CardEquipment:getEnhAttr()
	return self.enhAttr
end

function CardEquipment:getAttr(attrType)
	-- return self.totalAttribute.attribute[attrType] or 0
end

function CardEquipment:getFirstAttr(attrType)
	return self.firstAttribute.attribute[attrType] or 0
end

function CardEquipment:getSecondAttr(attrType)
	return self.secondAttribute.attribute[attrType] or 0
end

function CardEquipment:getFirstAttribute()
	return self.firstAttribute.attribute
end

function CardEquipment:getSecondAttribute()
	return self.secondAttribute.attribute
end

function CardEquipment:getGemAttribute()
	return self.gemAttribute.attribute
end

function CardEquipment:setQuality(quality)
	if self.quality == quality then
		return
	end
	self.quality = quality
end

function CardEquipment:setLevel(level)
	if level == self.level then
		return
	end
	self.level = level

	self:updateTotalAttr()
end

function CardEquipment:setStarLv(starLv)
	if starLv == self.starLv then
		return
	end
	self.starLv = starLv

	self:updateStarAttribute()
	self:updateTotalAttr()
end

function CardEquipment:updateTotalAttr()
	--print("CardEquipment  updateTotalAttr")

	self.totalAttribute:clear()
	self.firstAttribute:clear()
	self.secondAttribute:clear()

	self:refreshRoleBaseAttr()

	self.firstAttribute:clone(self.attribute)
	self.firstAttribute:setAddAttData(self.starAttribute)
	
	self.secondAttribute:clone(self.enhanceAttribute)
	self.secondAttribute:setAddAttData(self.refineAttribute)

	self.totalAttribute:clone(self.firstAttribute)
	self.totalAttribute:setAddAttData(self.secondAttribute)
	self.totalAttribute:refreshByPercent()
	self.totalAttribute:setAddAttData(self.gemAttribute)

	self.totalAttribute:refreshByPercent()
	self.totalAttribute:attributeToFloor()
	self.totalAttribute:updatePower()
	self:updatePower()
end

function CardEquipment:updatePower()
	self.power = self.totalAttribute:getPower()
end

function CardEquipment:refreshRoleBaseAttr()
	local function cmp( attr , index ,tbl)
		local attributeUp = tbl.attributeUp:getAttribute()
		local temp = attributeUp[index] or 0

		local num = attr + temp * tbl.level
		return num
	end
	self.attribute:clear()

	self.attribute:setAttByMath(self.baseAttribute,cmp,{level = (self.level -1),attributeUp = self.attributeUp})
end

function CardEquipment:updateStarAttribute()
	self.starAttribute:clear()

	local equipStar = EquipStarData:getDataByIdAndStar(self.tplId, self.starLv)
	if equipStar == nil then return end
	local attr = equipStar:getAttr()
	for k,v in pairs(attr) do
		self.starAttribute:addAttr(k,v)
	end
end

function CardEquipment:updateRefineAttribute()
	self.refineAttribute:clear()
	local refineAttr = self.refineAttr or {}
	for _,refine in pairs(refineAttr) do
		self.refineAttribute:addAttr(refine.attrId, refine.attrValue)
	end
	--self:updateTotalAttr()
end

function CardEquipment:updateGemAttribute()
	self.gemAttribute:clear()
	local gemPos = self.gemPos or {}
	for _,gem in pairs(gemPos) do
		if gem and gem.template then
			local attr = gem.template:getAttr()
			for k,v in pairs(attr) do
				self.gemAttribute:addAttr(k,v)
			end
		end
	end
	--self:updateTotalAttr()
end

function CardEquipment:updateEnhanceAttribute()
	self.enhanceAttribute:clear()
	local enhAttr = self.enhAttr or {}
	for _, enh in pairs(enhAttr) do
		self.enhanceAttribute:addAttr(enh.attrId, enh.attrValue)
	end
	--self:updateTotalAttr()
end

function CardEquipment:updateMasterAttribute(masterAttribute)
	self.masterAttribute = masterAttribute
	self:updateTotalAttr()
end

return CardEquipment