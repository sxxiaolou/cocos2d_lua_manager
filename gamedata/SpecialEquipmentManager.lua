-- Created by ZZTENG on 2018/05/15.
--专属装备管理

local SpecialEquipmentManager = class("SpecialEquipmentManager", BaseManager)
local SpecialEquipment = require('lua.gamedata.base.SpecialEquipment')
SpecialEquipmentManager.UPDATE_SPECIAL_EQUIPMENT = 'SpecialEquipmentManager.UPDATE_SPECIAL_EQUIPMENT'
SpecialEquipmentManager.SPECIAL_EQUIPMENT_EXCHANGE_RES = 'SpecialEquipmentManager.SPECIAL_EQUIPMENT_EXCHANGE_RES'
SpecialEquipmentManager.HUN_ICON_EFFECT_NAME = {
    [0] = 'fire_bai1',
    [1] = {'fire_lv1','fire_lv2','fire_lv3','fire_lv4','fire_lv5'},
    [2] = {'fire_lan1','fire_lan2','fire_lan3','fire_lan4','fire_lan5'},
    [3] = {'fire_zi1','fire_zi2','fire_zi3','fire_zi4','fire_zi5'},
    [4] = {'fire_cheng1','fire_cheng2','fire_cheng3','fire_cheng4','fire_cheng5'},
    [5] = {'fire_hong1','fire_hong2','fire_hong3','fire_hong4','fire_hong5'},
}
SpecialEquipmentManager.HUN_ICON_EFFECT_SCALE = {0.15,0.3,0.6,0.9,1}

function SpecialEquipmentManager:ctor()
	self.super.ctor(self)
end

function SpecialEquipmentManager:init()
    self.super.init(self)
    self:reset()
    
    TFDirector:addProto(s2c.SPECIAL_EQUIP_INFO_RES, self, self.onSpecialEquipInfoRes)
    TFDirector:addProto(s2c.SPECIAL_EQUIP_ACTIVE_RES, self, self.onSpecailEquipActiveRes)
    TFDirector:addProto(s2c.SPECIAL_EQUIP_EXP_ADD_RES, self, self.onSpecailEquipExpAddRes)
    TFDirector:addProto(s2c.SPECIAL_EQUIP_STAGE_RES, self, self.onSpecailEquipStageRes)
    TFDirector:addProto(s2c.SPECIAL_EQUIP_SPRITE_EXP_ADD_RES, self, self.onSpecailEquipSpriteExpAddRes)
    TFDirector:addProto(s2c.SPECIAL_EQUIP_SPRITE_LEVELUP_RES, self, self.onSpecialEquipSpriteLevelupRes)
    TFDirector:addProto(s2c.SPECIAL_EQUIP_SPRITE_STAGE_RES, self, self.onSpecailEquipSpriteStageRes)
    TFDirector:addProto(s2c.SPECIAL_EQUIP_EXCHANGE_RES, self, self.onSpecailEquipExchangeRes)

    

    -- self.updateTeamTaskListen =  function ( event )
    --     self:updateTeamTask(event)
    -- end
    -- TFDirector:addMEGlobalListener(SpecialEquipmentManager.UPDATE_TEAM_TASK, self.updateTeamTaskListen)
end

function SpecialEquipmentManager:restart()
    -- 清除数据
    self:reset()
end

function SpecialEquipmentManager:reset( ... )
    -- body
    self.specialEquipList = {}
    self.curEquipId = nil
    self.curRoleId = nil
    self.openLayerList = {}

    -- self:makeData()
end

--receive proto
function SpecialEquipmentManager:onSpecialEquipInfoRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecialEquipInfoRes',data)
    self:updateSpecialEquipment(data.equip or {})
    self:sortSpecialEquipMentList()
    TFDirector:dispatchGlobalEventWith(SpecialEquipmentManager.UPDATE_SPECIAL_EQUIPMENT, 0)
end

function SpecialEquipmentManager:onSpecailEquipActiveRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecailEquipActiveRes',data)
end

function SpecialEquipmentManager:onSpecailEquipExpAddRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecailEquipExpAddRes',data)
end

function SpecialEquipmentManager:onSpecailEquipStageRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecailEquipStageRes',data)
end

function SpecialEquipmentManager:onSpecailEquipSpriteExpAddRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecailEquipSpriteExpAddRes',data)
end

function SpecialEquipmentManager:onSpecialEquipSpriteLevelupRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecialEquipSpriteLevelupRes',data)
    local layer = AlertManager:getLayerByName('lua.logic.specialEquipment.ExclusiveTpplaye')
    if layer then  AlertManager:close() end
    if data.result then
        toastMessage(localizable.special_equip_hun_up_suc)
    else
        toastMessage(localizable.special_equip_hun_up_fail)
    end
end

function SpecialEquipmentManager:onSpecailEquipSpriteStageRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecailEquipSpriteStageRes',data)
end

function SpecialEquipmentManager:onSpecailEquipExchangeRes( event )
    hideLoading()
    local data = event.data
    print('SpecialEquipmentManager:onSpecailEquipExchangeRes',data)
    toastMessage(localizable.special_equip_frag_exchange_suc)
    TFDirector:dispatchGlobalEventWith(SpecialEquipmentManager.SPECIAL_EQUIPMENT_EXCHANGE_RES, 0)
end

--send proto
function SpecialEquipmentManager:sendSpecialEquipInfoReq( roleId )
    if roleId then
        self:sendWithLoading(c2s.SPECIAL_EQUIP_INFO_REQ, roleId ,false)
    else
        --all
        self:sendWithLoading(c2s.SPECIAL_EQUIP_INFO_REQ,false)
    end
end

function SpecialEquipmentManager:sendSpecialEquipActiveReq( roleId,pos )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_ACTIVE_REQ,roleId,pos)
end

function SpecialEquipmentManager:sendSpecialEquipExpAddReq( items,roleId,pos )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_EXP_ADD_REQ,items,roleId,pos)
end

function SpecialEquipmentManager:sendSpecialEquipStageReq( roleId )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_STAGE_REQ,roleId)
end

function SpecialEquipmentManager:sendSpecialEquipSpriteExpAddReq( roleId,pos,num )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_SPRITE_EXP_ADD_REQ,roleId,pos,num)
end

function SpecialEquipmentManager:sendSpecialEquipSpriteLevelupReq( roleId,pos,itemCount )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_SPRITE_LEVELUP_REQ,roleId,pos,itemCount)
end

function SpecialEquipmentManager:sendSpecialEquipSpriteStageReq( roleId,pos )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_SPRITE_STAGE_REQ,roleId,pos)
end

function SpecialEquipmentManager:sendSpecialEquipExchangeReq( items )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_EXCHANGE_REQ,items,true)
end

function SpecialEquipmentManager:sendSpecialEquipOneKeyExpReq( roleId,pos )
    self:sendWithLoading(c2s.SPECIAL_EQUIP_ONE_KEY_EXP_REQ,roleId,pos)
end

--utils
function SpecialEquipmentManager:getSpecialEquipmentList( ... )
    return self.specialEquipList
end

function SpecialEquipmentManager:getSpecialEquipByCardId( cardId )
     for k,v in pairs(self.specialEquipList) do
         if v.cardId == cardId then
            return v
         end
     end
     return nil
end

function SpecialEquipmentManager:getSpecialEquipByEquipId( equipId )
    for k,v in pairs(self.specialEquipList) do
        if v.equipId == equipId then
            return v
        end
    end
    return nil
end

function SpecialEquipmentManager:updateSpecialEquipment( equipList )
    local function updateSpecialEquipment( specialEquip )
        for k,v in pairs(self.specialEquipList) do
            if v.cardId == specialEquip.cardId and v.equipId == specialEquip.equipId then
                 v:updateInfo(specialEquip)
                 return
            end
        end
        print('update not exist this special equip')
    end
    local function addSpecailEquipment( specialEquip )
        local specialEquipment = SpecialEquipment:new(specialEquip)
        table.insert( self.specialEquipList, specialEquipment )
    end
    for k,v in pairs(equipList) do
       local specialEquipment = self:getSpecialEquipByCardId(v.cardId)
       if specialEquipment then
           updateSpecialEquipment(v)
       else
           addSpecailEquipment(v)
       end
    end
end
--设置注灵点特效
function SpecialEquipmentManager:setPointEffect( pointWidget,pos,specialEquip )
    pointWidget:removeAllChildren()
    local pointInfoList = specialEquip:getPointInfoList()
    local effect_name 
    if pointInfoList[pos] then
        local percent = SpecialEquipmentManager:getPointPercent(pointInfoList[pos].level,specialEquip:getLevel())
        effect_name = SpecialEquipmentManager:getIconEffectNameByStageAndPercent( pointInfoList[pos].spriteStage, percent)
    else
        effect_name = SpecialEquipmentManager:getIconEffectNameByStageAndPercent( 0 )
    end
    local spine =  GameResourceManager:PlaySpineEffectLoop('liushehuoyan',effect_name)
    pointWidget:addChild(spine)
end

--stage:器魄阶段，percent:注灵等级/注灵最高等级
function SpecialEquipmentManager:getIconEffectNameByStageAndPercent( stage,percent )
    if stage == 0 then return SpecialEquipmentManager.HUN_ICON_EFFECT_NAME[stage] end
    for i,v in ipairs(SpecialEquipmentManager.HUN_ICON_EFFECT_SCALE) do
        if i == #SpecialEquipmentManager.HUN_ICON_EFFECT_SCALE then return end
        if i == 1 and percent <= SpecialEquipmentManager.HUN_ICON_EFFECT_SCALE[i] then
            return SpecialEquipmentManager.HUN_ICON_EFFECT_NAME[stage][i]
        end
        if percent > v and percent <= SpecialEquipmentManager.HUN_ICON_EFFECT_SCALE[i + 1] then
            return SpecialEquipmentManager.HUN_ICON_EFFECT_NAME[stage][i + 1]
        end
    end
end
--注灵等级/注灵最高等级
function SpecialEquipmentManager:getPointPercent( pointLevel,promoteLevel )
    local info = SpecialEquipPromoteData:getInfoByIdAndLevel(self.curEquipId,promoteLevel)
    if not info then return 0 end
    local percent = pointLevel / info.point_max_level
    return percent
end

function SpecialEquipmentManager:sortSpecialEquipMentList(type)
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

    local function sortFun(specialEqiupment1, specialEqiupment2)
        local roleId1 = specialEqiupment1:getCardId()
        local roleId2 = specialEqiupment2:getCardId()
        local role1 = CardRoleManager:getRoleByGmId(roleId1)
        local role2 = CardRoleManager:getRoleByGmId(roleId2)
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
    table.sort( self.specialEquipList, sortFun )
end

function SpecialEquipmentManager:getNext(specialEquipment)
	if not specialEquipment then return nil end

	local index = table.indexOf(self.specialEquipList,specialEquipment)
	return self.specialEquipList[index + 1]
end

function SpecialEquipmentManager:getPrev(cardRole)
	if not specialEquipment then return nil end

	local index = table.indexOf(self.specialEquipList,specialEquipment)
	return self.specialEquipList[index - 1]
end

--open layer
function SpecialEquipmentManager:openSpecialEquipmentMainLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.specialEquipment.SpecialEquipmentMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function SpecialEquipmentManager:openSpecialEquipmentExpLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.specialEquipment.SpecailEquipmentExpLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function SpecialEquipmentManager:openSpecialEquipmentPromoteLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.specialEquipment.SpecialEquipmentPromoteLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function SpecialEquipmentManager:openSpecialEquipmentFragLayer( ... )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.specialEquipment.SpecailEquipmentFragLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	AlertManager:show()
end

function SpecialEquipmentManager:openExclusiveTpplaye(specialEquip,spritePos)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.specialEquipment.ExclusiveTpplaye", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    layer:loadData(specialEquip,spritePos)
    AlertManager:show()
end

--red point
function SpecialEquipmentManager:makeData()
    local specialEquip =                {}
    specialEquip.equipId                = 190001
    specialEquip.point                  = {}
    specialEquip.point.pos              = 1
    specialEquip.point.spriteExp        = 200
	specialEquip.point.spriteLevel      = 1
	specialEquip.point.spriteStage      = 1
    specialEquip.point.spriteAttr       = "1_200,2_100,3_100"

    table.insert( self.specialEquipList, specialEquip )
end

return SpecialEquipmentManager:new()