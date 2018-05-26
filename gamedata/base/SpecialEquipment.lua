-- Created by ZZTENG on 2018/05/17.
-- 专属装备数据管理
local GameObject = require('lua.gamedata.base.GameObject')
local SpecialEquipment = class("SpecialEquipment",GameObject)
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

function SpecialEquipment:ctor( data )
	self.super.ctor(self)
	self:init(data)

end

function SpecialEquipment:dispose()
    self.cardId = nil
    self.equipId = nil
    self.specialEquipPoint = nil
    self.level = nil
    self.masterId = nil
    self.power = nil
    self.template = nil
    self.name = nil
    self.type = nil
    self.kind = nil
    self.quality = nil
    self.need = nil
    self.point_count = nil
    self.icon = nil
    self.pic = nil
    self.comment = nil
    -- self.attribute:clear()
    -- self.baseAttribute:clear()
    -- self.attributeUp:clear()
    self.totalAttribute:clear()
    self.spriteAttribute:clear()
    self.promoteAttribute:clear()
    self.masterAttribute:clear()
    
    -- self.attribute = nil
    -- self.baseAttribute = nil
    -- self.attributeUp = nil
    self.totalAttribute = nil
    self.spriteAttribute = nil
    self.promoteAttribute = nil
    self.masterAttribute = nil
    for k,v in pairs(self.expAttributeList) do
        v:clear()
    end
    self.expAttributeList = nil
    for k,v in pairs(self.spriteAttributeList) do
        v:clear()
    end
    self.spriteAttributeList = nil

end

function SpecialEquipment:init( data )
    self.cardId = data.cardId                    --角色ID
    self.equipId = data.equipId                  --专属装备ID
    self.power = 0

    -- self.attribute 			= GameAttributeData:new() 			--最终基本属性
	-- self.baseAttribute   	= GameAttributeData:new() 			--基本属性
	-- self.attributeUp	 	= GameAttributeData:new()			--成长属性
    self.totalAttribute 	= GameAttributeData:new()			--总属性
    
    self.expTotalAttribute   = GameAttributeData:new()          --注灵总属性
    self.spriteTotalAttribute    = GameAttributeData:new()		--器魂总属性
    self.promoteAttribute   = GameAttributeData:new()			--升灵属性
    self.masterAttribute    = GameAttributeData:new()			--培养大师属性
    
    self.expAttributeList = {}     --注灵属性表
    self.spriteAttributeList = {}  --器魂属性表
    

    self:initConfig()
    self:updateInfo(data)
end

function SpecialEquipment:initConfig()
    local id = self.equipId
    local template = SpecialEquipData:objectByID(id)
    if not template then print('not exist speical equipment',id) return end
    self.template = template
    self.name = template.name
    self.type = template.type
    self.kind = template.kind
    self.quality = template.quality
    self.need = template.need
    self.point_count = template.point_count
    self.icon = template.icon
    self.pic = template.pic
    self.comment = template.comment
end

function SpecialEquipment:updateInfo(data)
    self.specialEquipPoint = data.point or {}    --注灵点信息
    for i,point in ipairs(self.specialEquipPoint) do
        local pos = point.pos
        self.expAttributeList[pos] = GameAttributeData:new()        --单个注灵属性
        self.spriteAttributeList[pos] = GameAttributeData:new()     --单个器魂属性
        self.specialEquipPoint[pos].pos = pos or 0    --注灵点序号
        self.specialEquipPoint[pos].exp = point.exp or 0    --注灵经验 
        self.specialEquipPoint[pos].level = point.level or 0   --注灵等级 
        self.specialEquipPoint[pos].spriteExp = point.spriteExp or 0 --器魂经验
        self.specialEquipPoint[pos].spriteLevel = point.spriteLevel or 0 --器魂等级
        self.specialEquipPoint[pos].spriteStage = point.spriteStage or 0 -- 器魂阶段
        self.specialEquipPoint[pos].spriteAttr = point.spriteAttr or ''
    end
    print('yyyyyyyyyyyyyyyyyyyyy', self.specialEquipPoint)

    self.level = data.level                      --升灵等级
    self.masterId = data.masterId               --装备大师ID

    self:updateExpTotalAttr()
	self:updateSpriteTotalAttr()
	self:updatePromoteAttr()
	self:updateMasterAttr()
    self:updateTotalAttr()
end

----[[属性计算公式：属性计算 = （基础+注灵等级*成长）+器魂属性+升灵属性+装备大师]]
function SpecialEquipment:updateExpTotalAttr( ... )
    self.expTotalAttribute:clear()
    for i,v in pairs(self.expAttributeList) do
        v:clear()
    end
    --重新计算
    for i,point in ipairs(self.specialEquipPoint) do
        local pos = point.pos
        local info = SpecialEquipPointData:getInfoByIdAndPos(self.equipId,pos)
        local base_attr = GetAttrByStringForExtra(info.attr)
        local grow_attr = GetAttrByStringForExtra(info.attr_grow)
        for k,v in pairs(base_attr) do
            self.expAttributeList[pos]:addAttr(k,v)
        end
        for k,v in pairs(grow_attr) do
            self.expAttributeList[pos]:addAttr(k,v * self.level)
        end
    end

    for i,v in pairs(self.expAttributeList) do
        self.expTotalAttribute:setAddAttData(v)
    end
end

function SpecialEquipment:updateSpriteTotalAttr( ... )
    self.spriteTotalAttribute:clear()
    for i,v in pairs(self.spriteAttributeList) do
        v:clear()
    end
    --重新计算
    for i,point in ipairs(self.specialEquipPoint) do
        -- local pos = point.pos
        -- local info = SpecialEquipSpriteData:getSingleLineInfo(self.equipId,pos,point.spriteStage,point.spriteLevel)
        -- local attr_exp, attr_level,attr_stage = {},{},{}
        -- if info then 
        --     attr_exp = GetAttrByStringForExtra(info.attr_exp)
        --     attr_level = GetAttrByStringForExtra(info.attr_level)
        --     attr_stage = GetAttrByStringForExtra(info.attr_stage)

        -- end
        -- for k,v in pairs(attr_exp) do
        --     self.spriteAttributeList[pos]:addAttr(k,v)
        -- end
        -- for k,v in pairs(attr_level) do
        --     self.spriteAttributeList[pos]:addAttr(k,v)
        -- end
        -- for k,v in pairs(attr_stage) do
        --     self.spriteAttributeList[pos]:addAttr(k,v)
        -- end
        local attr = GetAttrByStringForExtra(point.spriteAttr)
        for k,v in pairs(attr) do
            self.spriteAttributeList[point.pos]:addAttr(k,v)
        end
    end

    for i,v in pairs(self.spriteAttributeList) do
        self.spriteTotalAttribute:setAddAttData(v)
    end
end

function SpecialEquipment:updatePromoteAttr( ... )
   self.promoteAttribute:clear()
   local info = SpecialEquipPromoteData:getInfoByIdAndLevel(self.equipId,self.level)
   if not info then return end
   local attr = GetAttrByStringForExtra(info.attr)
   for k,v in pairs(attr) do
       self.promoteAttribute:addAttr(k,v)
   end
end

function SpecialEquipment:updateMasterAttr( ... )
    self.masterAttribute:clear()
    local masterData = CardMasterData:objectByID(self.masterId)
    if not masterData then return end
    local attr = GetAttrByStringForExtra(masterData.attrs)
    for k,v in pairs(attr) do
        self.masterAttribute:addAttr(k,v)
    end
end

function SpecialEquipment:updateTotalAttr()
	self.totalAttribute:clear()

	-- self:refreshRoleBaseAttr()
	-- self.totalAttribute:clone(self.attribute)

	self.totalAttribute:setAddAttData(self.expTotalAttribute)
	self.totalAttribute:setAddAttData(self.spriteTotalAttribute)
	self.totalAttribute:setAddAttData(self.promoteAttribute)
	self.totalAttribute:setAddAttData(self.masterAttribute)
    self.totalAttribute:refreshByPercent()
    
    self.totalAttribute:attributeToFloor()
    self.totalAttribute:updatePower()
	self:updatePower()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_CARD_INFO)
end

function SpecialEquipment:updatePower( ... )
    self.power = self.totalAttribute:getPower()
end

--对外api
function SpecialEquipment:getCardId( ... )
    return self.cardId
end

function SpecialEquipment:getEquipId( ... )
    return self.equipId
end

function SpecialEquipment:getPower( ... )
    return self.power
end

function SpecialEquipment:getIcon( ... )
    return 'icon/specialgearicon/' ..  self.icon .. '.png'
end

function SpecialEquipment:getPic( ... )
    return 'icon/specialgear/' ..  self.pic .. '.png'
end

function SpecialEquipment:getName( ... )
    return self.name
end

function SpecialEquipment:getMasterId( ... )
    return self.masterId
end

function SpecialEquipment:getLevel( ... )
    return self.level
end

function SpecialEquipment:getPointCount( ... )
    return self.point_count
end

function SpecialEquipment:getPointInfoList( ... )
    return self.specialEquipPoint
end

--true:active,false:not active
function SpecialEquipment:getActiveStateByPos( pos )
    if self.specialEquipPoint[pos] == nil then
        return false
    else
        return true
    end
end

function SpecialEquipment:getTotalAttribute( ... )
    return self.totalAttribute.attribute or {}
end

function SpecialEquipment:getExpAttributeByPos( pos )
    return self.expAttributeList[pos].attribute or {}
end

function SpecialEquipment:getSpriteAttributeByPos( pos )
    return self.spriteAttributeList[pos].attribute or {}
end

function SpecialEquipment:getPromoteAttribute( ... )
    return self.promoteAttribute.attribute or {}
end

function SpecialEquipment:getMasterAttribute( ... )
    return self.masterAttribute.attribute or {}
end

return SpecialEquipment